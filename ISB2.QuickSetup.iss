objectdef isb2_quicksetup
{
    variable jsonvalueref EditingCharacter="{}"
    variable jsonvalueref Characters="[]"

    variable jsonvalueref GameLaunchInfo="[]"

    variable bool ExistingCharacter

    variable string TeamName
    variable string Error
    variable string GameName

    method Initialize()
    {
        This:GenerateGameLaunchInfo
    }

    method Shutdown()
    {

    }

    method OnCharacterContextMenuSelection()
    {
        echo "Context Menu Selection: ${Context.Source(type)} ${Context.Source.Item["${Context.Args.GetInteger[index]}"].Data~} ${Context.Source.Context.Data~}"

        switch ${Context.Source.Item["${Context.Args.GetInteger[index]}"].Data~}
        {
            case Move Up
                This:MoveCharacterUp["Context.Source.Context.Data"]
                break
            case Move Down
                This:MoveCharacterDown["Context.Source.Context.Data"]
                break
            case Remove
                This:RemoveCharacter["Context.Source.Context.Data"]
                break
        }
    }

    method OnAddedCharacterSelection()
    {
        echo "Added Character Selected: ${Context.Source(type)} ${Context.Args~}"
    }

    method OnSelectedTabChanged()
    {
        Error:Set[]
    }

    member:uint FindCharacter(string name)
    {
        variable jsonvalue joQuery="{\"eval\":\"Select.Get[name]\",\"op\":\"==\",\"value\":\"${name~}\"}"

        return "${Characters.SelectKey[joQuery]}"
    }

    member:jsonvalueref GetCharacter(string name)
    {
        variable jsonvalue joQuery="{\"eval\":\"Select.Get[name]\",\"op\":\"==\",\"value\":\"${name~}\"}"

        return "Characters.SelectValue[joQuery]"
    }

    method MoveCharacterUp(jsonvalueref jo)
    {
        variable uint num=${This.FindCharacter["${jo.Get[name]~}"]}
        if ${num}<=1
            return

        Characters:Swap[${num},${num.Dec}]
        LGUI2.Element[isb2.QuickSetupWindow]:FireEventHandler[onCharactersUpdated]
    }

    method MoveCharacterDown(jsonvalueref jo)
    {
        variable uint num=${This.FindCharacter["${jo.Get[name]~}"]}
        if ${num}>=${Characters.Used}
            return

        Characters:Swap[${num},${num.Inc}]
        LGUI2.Element[isb2.QuickSetupWindow]:FireEventHandler[onCharactersUpdated]
    }

    method RemoveCharacter(jsonvalueref jo)
    {
        variable uint num=${This.FindCharacter["${jo.Get[name]~}"]}
        if !${num}
            return

        Characters:Erase[${num}]
        LGUI2.Element[isb2.QuickSetupWindow]:FireEventHandler[onCharactersUpdated]
    }

    method AddCharacter()
    {
        if !${EditingCharacter.Get[name]~.NotNULLOrEmpty}
        {
            Error:Set["Character name required!"]
            LGUI2.Element[isb2.QuickSetup.EditingCharacter.name]:KeyboardFocus
            return
        }

        if ${This.GetCharacter["${EditingCharacter.Get[name]~}"].Reference(exists)}
        {
            Error:Set["Character with that name already added!"]
            LGUI2.Element[isb2.QuickSetup.EditingCharacter.name]:KeyboardFocus
            return
        }

        if !${EditingCharacter.GetInteger[_gameLaunchInfo]}
        {
            Error:Set["Game Launch Info required!"]
            return
        }

        Characters:AddByRef[EditingCharacter.Duplicate]
        LGUI2.Element[isb2.QuickSetupWindow]:FireEventHandler[onCharactersUpdated]
        LGUI2.Element[isb2.QuickSetup.EditingCharacter.name]:KeyboardFocus
    }

    method ValidatePage(string pageName)
    {
;        echo ValidatePage ${pageName} ${Context(type)}
        Context:SetHandled[1]
        switch ${pageName}
        {
            case Game
            {
                if !${GameName.NotNULLOrEmpty}
                {
                    Error:Set["Please select a Game (or 'Other')"]                    
                    Context.Args:SetBool[pageValid,0]
                }
            }            
                break
            case Characters
            {
                if !${Characters.Used}
                {
                    Error:Set["Please add at least one Character to the Team"]
                    Context.Args:SetBool[pageValid,0]
                }
            }
                break
            case TeamName
            {
                if !${TeamName.NotNULLOrEmpty}
                {
                    Error:Set["Team name required"]
                    LGUI2.Element[isb2.QuickSetup.TeamName]:KeyboardFocus
                    Context.Args:SetBool[pageValid,0]
                    return
                }

                ; team name is fine, see if there's already a stored profile with this name
                variable string fileName
                fileName:Set["Team.${This.GetSanitizedName["${TeamName~}"]}.isb2.json"]
                if ${ISB2.ProfilesFolder.FileExists["${fileName~}"]}
                {
                    Error:Set["Profile ${fileName~} already exists"]
                    Context.Args:SetBool[pageValid,0]
                    return
                }
            }
                break
        }
    }

    member:string GetSanitizedName(string name)
    {
        return "${name.Replace["?","","*","",":","","<","",">","","|","","/","","\\","","\"",""]~}"
    }

    method AddSlot(jsonvalueref jaSlots, jsonvalueref joCharacter)
    {
        variable jsonvalue joSlot="{}"
        joSlot:SetString[character,"${joCharacter.Get[name]~}"]

        jaSlots:AddByRef[joSlot]
    }

    method AddGameLaunchInfo_Profile(string gameName, string profileName)
    {
        if !${profileName.NotNULLOrEmpty} || ${profileName.Equal[_set_guid]}
            return
        echo "\ayAddGameLaunchInfo_Profile\ax ${gameName~} -> ${profileName~}"
        variable jsonvalue joGLI="{}"
        joGLI:SetString[game,"${gameName~}"]
        joGLI:SetString[gameProfile,"${profileName~}"]

        GameLaunchInfo:AddByRef[joGLI]
    }

    method AddGameLaunchInfo_Game(string name, jsonvalueref joGame)
    {
        if !${name.NotNULLOrEmpty} || ${name.Equal[_set_guid]}
            return
        echo "\ayAddGameLaunchInfo_Game\ax ${name~} ${joGame~}"

        joGame.Get[Profiles]:ForEach["This:AddGameLaunchInfo_Profile[\"${name~}\",\"\${ForEach.Key~}\"]"]
    }

    method GenerateGameLaunchInfo(string gameName)
    {
        GameLaunchInfo:Set["[]"]

        ISUplink.Games:ForEach["This:AddGameLaunchInfo_Game[\"\${ForEach.Key~}\",ForEach.Value]"]

        LGUI2.Element[isb2.QuickSetupWindow]:FireEventHandler[onGameLaunchInfoUpdated]
    }

    method UpdateGameLaunchInfo(jsonvalueref jo)
    {
        if !${jo.Has[_gameLaunchInfo]}
            return

        jo:SetByRef[gameLaunchInfo,"GameLaunchInfo.Get[${jo.GetInteger[_gameLaunchInfo]}]"]        
        jo:Erase[_gameLaunchInfo]
    }

    method Finish()
    {
        echo "\ayisb2_quicksetup:Finish\ax"     

        LGUI2.Element[isb2.QuickSetupWindow]:SetVisibility[hidden]

        ; generate team object
        variable jsonvalue joTeam="{}"
        joTeam:SetString[name,"${TeamName}"]
        variable jsonvalue jaSlots="[]"
        Characters:ForEach["This:AddSlot[jaSlots,ForEach.Value]"]
        Characters:ForEach["This:UpdateGameLaunchInfo[ForEach.Value]"]

        variable jsonvalue joProfile="{}"
        joProfile:SetString["$schema","http://www.lavishsoft.com/schema/isb2.json"]
        joProfile:SetString[source,"quick setup"]
        joProfile:SetString[isb2Version,"${agent.Get[ISBoxer 2].Version~}"]
        joProfile:SetString[name,"Team ${TeamName~}"]

        joProfile:Set[teams,"[]"]
        joTeam:SetByRef[slots,jaSlots]
        joProfile.Get[teams]:AddByRef[joTeam]
        joProfile:SetByRef[characters,Characters]


        variable string fileName
        fileName:Set["Team.${This.GetSanitizedName["${TeamName~}"]}.isb2.json"]
        echo "Writing new profile to \at${ISB2.ProfilesFolder~}/${fileName~}\ax"

        joProfile:WriteFile["${ISB2.ProfilesFolder~}/${fileName~}",multiline]
    }
}

variable(global) isb2_quicksetup ISB2QuickSetup