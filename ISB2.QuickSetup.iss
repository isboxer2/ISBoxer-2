#include "ISB2.WindowLayoutGenerators.iss"

objectdef isb2_quicksetup inherits isb2_building
{
    variable jsonvalueref EditingCharacter="{}"
    variable jsonvalueref Characters="[]"

    variable set DetectedGameFolders
    variable jsonvalueref DetectedCharacters="[]"

    variable jsonvalueref GameLaunchInfo="[]"
    variable jsonvalueref WindowLayoutSettings="{}"
    variable jsonvalueref RegionGeneratorSettings="{}"

    variable windowLayoutGenerators WindowLayoutGenerators
    variable jsonvalueref WindowLayouts="[]"
    variable jsonvalueref WindowLayout

    variable bool ExistingCharacter

    variable string TeamName
    variable string Error
    variable string GameName

    variable jsonvalueref SelectedGame

    method Initialize()
    {
        WindowLayoutSettings:SetBool[instantSwap,1]
        WindowLayoutSettings:SetBool[swapOnActivate,1]
        WindowLayoutSettings:SetBool[swapOnSlotActivate,1]
        BuilderAutoSelect:Set[1]
    }

    method Shutdown()
    {

    }

    method SelectGame(string gameName)
    {
        GameName:Set["${gameName~}"]
        if !${gameName.NotNULLOrEmpty}
        {
            SelectedGame:SetReference[NULL]
            BuildingGame:SetReference[NULL]
            return
        }


        variable jsonvalueref jaGames
        jaGames:SetReference["LGUI2.Skin[default].Template[isb2.data].Get[games]"]

        SelectedGame:SetReference["ISB2.FindInArray[jaGames,\"${gameName~}\"]"]
        BuildingGame:SetReference[SelectedGame]
    }

    method Start()
    {
        This:DetectMonitors
        This:GenerateGameLaunchInfo
        This:RefreshBuilderPresets

        ISB2:BuildStandardAutoComplete
        
        if !${LGUI2.Element[isb2.QuickSetupWindow].Visibility~.Equal[visible]}
        {
            LGUI2.Element["isb2.QuickSetupWindow.pagecontrol"]:SelectPage[1]
            Builders:Clear
            TeamName:Set[]
            Error:Set[]
            DetectedCharacters:Clear
            BuildingCharacters:SetReference[Characters]
            Characters:Clear
            EditingCharacter:SetReference["{}"]
            WindowLayouts:Clear
            WindowLayout:SetReference[NULL]
            ExistingCharacter:Set[0]
            LGUI2.Element[isb2.QuickSetupWindow]:SetVisibility[visible]
        }
        timed 0 "LGUI2.Element[isb2.QuickSetupWindow]:BubbleToTop"       
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
        echo "Added Character Selected: ${Context.Source(type)} ${Context.Source.SelectedItem.Data~}"
    }

    method OnDetectedCharacterSelection()
    {
        echo "Detected Character Selected: ${Context.Source(type)} ${Context.Source.SelectedItem.Data~}"

        variable jsonvalueref joDetected="Context.Source.SelectedItem.Data"

        if !${joDetected.Reference(exists)}
            return

        EditingCharacter:Merge[joDetected,1]
        EditingCharacter:Erase[foundPath]
    }

    method OnDetectedCharacterDoubleClick()
    {
        echo "Detected Character Double Click: ${Context.Source(type)} ${Context.Source.Item.Data~}"
        This:AddCharacter
    }

    method SetCharacterDetail(string fieldName, string newValue)
    {
;        echo "SetCharacterDetail ${fieldName~} ${newValue~}"
        if ${EditingCharacter.Assert["${fieldName~}","${newValue.AsJSON~}"]}
            return

        EditingCharacter:SetString["${fieldName~}","${newValue~}"]

        if ${newValue.NotNULLOrEmpty}
            LGUI2.Element[isb2.events]:FireEventHandler[onCharacterDetails,"{\"field\":\"${fieldName~}\"}"]
    }

    method OnSelectedTabChanged()
    {
        Error:Set[]
        echo "OnSelectedTabChanged: ${Context.Source(type)} ${Context.Source.ID} ${Context.Args~}"

        switch ${Context.Source.SelectedTab.Header.Text}
        {
            case Game Selection
                break
            case Character Selection
                This:DetectCharacters

                ; refresh game name if the user emptied it and went back, etc.
                if !${EditingCharacter.Get[game]~.NotNULLOrEmpty}
                    EditingCharacter:SetString[game,"${GameName~}"]

                LGUI2.Element[isb2.QuickSetup.EditingCharacter.name]:KeyboardFocus
                break
            case Window Layout
                This:RefreshWindowLayouts
                break
            case Team Name
                LGUI2.Element[isb2.QuickSetup.TeamName]:KeyboardFocus
                break
            case Configuration Builder
                Context.Source.SelectedTab:SetContext[This]
                This:RefreshBuilders
                break
        }
    }

    method OnSelectedWindowLayoutChanged()
    {
        echo "\ayOnSelectedWindowLayoutChanged\ax: ${Context.Source(type)} ${Context.Source.ID} ${Context.Source.SelectedItem.Data~}"
        WindowLayout:SetReference[Context.Source.SelectedItem.Data]
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

    member:bool ImaginationCheck(string name)
    {
        if ${name.Length}<3
            return FALSE

        variable bool res=0
        variable int i
        for ( i:Set[1] ; ${i}<${name.Length} ; i:Inc)
        {
            if ${name.GetAt[1]}!=${name.GetAt[${i}]}
            {
                res:Set[1]
                break
            }
        }
        if !${res}
            return FALSE

        if ${name.Equal[main]}
            return FALSE

        if ${name.Find["${BuildingGame.Get[name]~}"]}
        {
            if (${name.Length}-${BuildingGame.Get[name]~.Length}) <= 5
                return FALSE
        }
        if ${name.Find["${BuildingGame.Get[shortName]~}"]}
        {
            if (${name.Length}-${BuildingGame.Get[shortName]~.Length}) <= 5
                return FALSE
        }

        if ${name.Find["new "]}
        {
            if ${name.Length} - 4 <= 5
                return FALSE
        }

        return TRUE
    }

    method ValidatePage(string pageName)
    {
;        echo "ValidatePage ${pageName} ${Context(type)} ${Context.Source.ID}"
        Context:SetHandled[1]
        if ${Context.Source.Content.Text.Equal[Back]}
            return

        switch ${pageName}
        {
            case Game
            {
                if !${GameName.NotNULLOrEmpty}
                {
                    Error:Set["Please select a Game (or 'Other')"]                    
                    Context.Args:SetBool[pageValid,0]
                }

                ; we're advancing to Character page, change the game field to match
                EditingCharacter:SetString[game,"${GameName~}"]
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
                    LGUI2.Element[isb2.QuickSetup.TeamName]:KeyboardFocus
                    Context.Args:SetBool[pageValid,0]
                    return
                }

                if !${This.ImaginationCheck["${TeamName~}"]}
                {
                    LGUI2.Element[isb2.events]:FireEventHandler[noImagination,"{\"name\":\"${TeamName~}\"}"]
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
        ; left-only version
        switch ${jaSlots.Used}
        {
            case 0
                joSlot:Set[ftlModifiers,"[\"lShift\"]"]
                break
            case 1
                joSlot:Set[ftlModifiers,"[\"lAlt\"]"]
                break
            case 2
                joSlot:Set[ftlModifiers,"[\"lCtrl\"]"]
                break
            case 3
                joSlot:Set[ftlModifiers,"[\"lShift\",\"lAlt\"]"]
                break
            case 4
                joSlot:Set[ftlModifiers,"[\"lShift\",\"lCtrl\"]"]
                break
            case 5
                joSlot:Set[ftlModifiers,"[\"lCtrl\",\"lAlt\"]"]
                break
            case 6
                joSlot:Set[ftlModifiers,"[\"lShift\",\"lAlt\",\"lCtrl\"]"]
                break
        }

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
        GameLaunchInfo:Clear

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

    method ConvertLayoutRegion(jsonvalueref joSettings, jsonvalueref jo)
    {
        if ${jo.Has[x]}
        {
            jo:Set[bounds,"[${jo.GetInteger[x]},${jo.GetInteger[y]},${jo.GetInteger[width]},${jo.GetInteger[height]}]"]
            jo:Erase[x]
            jo:Erase[y]
            jo:Erase[width]
            jo:Erase[height]
        }

        variable uint roamingSlot=${joSettings.GetInteger[roamingSlot]}
        if ${jo.Has[numRegion]}
        {            
            if ${roamingSlot}
            {
                if ${jo.GetInteger[numRegion]} != ${roamingSlot}
                    jo:SetInteger[slot,${jo.GetInteger[numRegion]}]                
            }
            else
            {
                ; leave hole
                if !${jo.GetBool[mainRegion]}
                    jo:SetInteger[slot,${jo.GetInteger[numRegion].Dec}]                
            }
            jo:Erase[numRegion]
        }

        jo:Erase[mainRegion]
    }

    member:jsonvalueref GetFinalWindowLayout()
    {
        if !${WindowLayout.Reference(exists)}
            return NULL

        variable jsonvalue jo
        jo:SetValue["{}"]

        jo:SetString[name,"${TeamName~}"]
        jo:SetByRef[regions,"WindowLayout.Get[regions]"]
        variable jsonvalueref joSettings
        joSettings:SetReference["WindowLayout.Get[settings]"]
        jo.Get[regions]:ForEach["This:ConvertLayoutRegion[joSettings,ForEach.Value]"]    

        
        if !${joSettings.Has[frame]}
            joSettings:SetString[frame,none]

        if !${joSettings.Has[instantSwap]}
            joSettings:SetBool[instantSwap,${WindowLayoutSettings.GetBool[-default,true,instantSwap]}]

        if ${joSettings.Has[swapGroups]}        
        {
            if ${WindowLayoutSettings.GetBool[-default,true,swapOnActivate]}
            {
                joSettings:SetBool[swapOnActivate,1]
                joSettings:SetString[swapMode,AlwaysForGames]
            }
            elseif ${WindowLayoutSettings.GetBool[-default,true,swapOnSlotActivate]}
            {
                joSettings:SetBool[swapOnSlotActivate,1]
            }

            if !${joSettings.Has[focusFollowsMouse]}
                joSettings:SetBool[focusFollowsMouse,${WindowLayoutSettings.GetBool[-default,false,focusFollowsMouse]}]

            jo:SetByRef[swapGroups,"joSettings.Get[swapGroups]"]
            joSettings:Erase[swapGroups]
        }
        else
        {
            if !${joSettings.Has[focusFollowsMouse]}
                joSettings:SetBool[focusFollowsMouse,1]
            if !${joSettings.Has[swapOnActivate]}
                joSettings:SetBool[swapOnActivate,0]
            if !${joSettings.Has[swapOnSlotActivate]}
                joSettings:SetBool[swapOnSlotActivate,0]
            if !${joSettings.Has[swapMode]}
                joSettings:SetString[swapMode,Never]
            
        }

        jo:SetByRef[settings,joSettings]
        return jo
    }

    method AddVirtualFiles(jsonvalueref joOwner, jsonvalueref jaVirtualFiles)
    {
        if !${joOwner.Has[-array,virtualFiles]}
        {
            joOwner:SetByRef[virtualFiles,jaVirtualFiles.Duplicate]
            return
        }

        jaVirtualFiles:ForEach["joOwner.Get[virtualFiles]:AddByRef[ForEach.Value]"]
    }


    method Finish()
    {
        echo "\ayisb2_quicksetup:Finish\ax"     

        LGUI2.Element[isb2.QuickSetupWindow]:SetVisibility[hidden]

        ; generate team object
        variable jsonvalue joTeam="{}"
        joTeam:SetString[name,"${TeamName}"]        
        joTeam:SetString[guiToggleCombo,"Ctrl+Shift+Alt+G"]
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

        Characters:ForEach["ForEach.Value:SetBool[useGameVirtualFiles,1]"]

        /*
        variable jsonvalueref jaVirtualFiles
        ; add Virtual Files ...
        if ${SelectedGame.Has[-array,virtualFiles]}
        {            
            jaVirtualFiles:SetReference["SelectedGame.Get[virtualFiles]"]
            Characters:ForEach["This:AddVirtualFiles[ForEach.Value,jaVirtualFiles]"]
        }
        /**/

        variable jsonvalueref joWindowLayout
        if ${WindowLayout.Reference(exists)}
        {
            joWindowLayout:SetReference[This.GetFinalWindowLayout]
            if ${joWindowLayout.Reference(exists)}
            {
                joProfile:Set[windowLayouts,"[]"]
                joTeam:SetString[windowLayout,"${joWindowLayout.Get[name]~}"]
                joProfile.Get[windowLayouts]:AddByRef[joWindowLayout]
            }
        }

        ; apply builders
        This:ApplyBuilders["joTeam"]

        variable string fileName
        fileName:Set["Team.${This.GetSanitizedName["${TeamName~}"]}.isb2.json"]
        echo "Writing new profile to \at${ISB2.ProfilesFolder~}/${fileName~}\ax"

        joProfile:WriteFile["${ISB2.ProfilesFolder~}/${fileName~}",multiline]

        ISB2:LoadFile["${ISB2.ProfilesFolder~}/${fileName~}"]

        LGUI2.Element[isb2.events]:FireEventHandler[quickSetupCompleted]
    }

    method DetectMonitors()
    {
        variable jsonvalue jaMonitors="[]"
        variable uint i
        for ( i:Set[1] ; ${i}<=${Display.Monitors} ; i:Inc)
        {
            jaMonitors:Add["${Display.Monitor[${i}].AsJSON~}"]
        }

        RegionGeneratorSettings:SetByRef[monitors,jaMonitors]
    }

    member:bool HasLayout(jsonvalueref regions)
    {
        variable jsonvalue joQuery="{\"op\":\"==\"}"
        joQuery:SetByRef[value,"regions"]
        joQuery:SetString[eval,"Select.Get[regions]"]

;        echo "using query=${joQuery~}"

        return ${WindowLayouts.SelectKey[joQuery]}
    }

    method AddLayout(string name, string generator, jsonvalueref inputData, jsonvalueref regions, jsonvalueref joSettings)
    {
        if !${regions.Type.Equal[array]} || !${regions.Used}
            return FALSE
        if ${This.HasLayout[regions]}
            return FALSE

        variable jsonvalue jo="{}"

        jo:SetString["name","${name~}"]
        jo:SetString["generator","${generator~}"]
        jo:SetByRef["inputData","inputData.Duplicate"]
        jo:SetByRef["regions","regions"]
        jo:SetByRef[settings,joSettings]

        WindowLayouts:AddByRef[jo]
        return TRUE
    }

    method AddScreen(jsonvalueref ja, jsonvalueref joMonitor)
    {
        variable jsonvalue jo="{}"
        
        jo:SetString["itemType","screen"]
        jo:SetString["name","${joMonitor.Get[name]~}"]
        jo:SetInteger["left",${joMonitor.GetInteger[left]}]
        jo:SetInteger["top",${joMonitor.GetInteger[top]}]
        jo:SetInteger["width",${joMonitor.GetInteger[width]}]
        jo:SetInteger["height",${joMonitor.GetInteger[height]}]

        ja:AddByRef[jo]
    }

    method AddRegion(jsonvalueref ja, jsonvalueref joRegion)
    {
        variable jsonvalue jo="${joRegion.AsJSON~}"

        if ${joRegion.Has[numLayout]}
        {
            jo:SetString["itemType","region${joRegion.GetInteger[numLayout]}"]
        }
        else
        {
            jo:SetString["itemType","region"]
        }
        ja:AddByRef[jo]
    }    

    method AddGeneratedLayouts(string name, string generator, jsonvalueref _useData)
    {
        if !${_useData.Type.Equal[object]}
            return
        variable jsonvalueref useData
        useData:SetReference[_useData.Duplicate]

        variable weakref useGenerator
        useGenerator:SetReference["WindowLayoutGenerators.GetGenerator[\"${generator~}\"]"]


        variable(static) uint numCalls
        numCalls:Inc
;        echo "AddGeneratedLayouts[${numCalls}] ${name~} ${generator~}"

        This:AddLayout["${name~}","${generator~}",useData,"useGenerator.GenerateRegions[useData]","useGenerator.GenerateSettings[useData]"]

        if !${useData.Has[-notnull,avoidTaskbar]}
        {
            useData:SetBool[avoidTaskbar,0]
            This:AddGeneratedLayouts["${name~} (cover taskbar)","${generator~}",useData]
            useData:SetBool[avoidTaskbar,1]
            This:AddGeneratedLayouts["${name~} (avoid taskbar)","${generator~}",useData]
        }

        if !${useData.Has[-notnull,leaveHole]}
        {
            useData:SetBool[leaveHole,0]
            This:AddGeneratedLayouts["${name~} (no hole)","${generator~}",useData]
            useData:SetBool[leaveHole,1]
            This:AddGeneratedLayouts["${name~} (leave hole)","${generator~}",useData]
        }
        
        if ${useGenerator.Uses.Contains[edge]} && (!${useData.Has[-string,edge]} || !${useData.Get[edge].NotNULLOrEmpty})
        {
            useData:SetString[edge,"bottom"]
            This:AddGeneratedLayouts["${name~} (bottom)","${generator~}",useData]
            useData:SetString[edge,"right"]
            This:AddGeneratedLayouts["${name~} (right)","${generator~}",useData]
            useData:SetString[edge,"top"]
            This:AddGeneratedLayouts["${name~} (top)","${generator~}",useData]
            useData:SetString[edge,"left"]
            This:AddGeneratedLayouts["${name~} (left)","${generator~}",useData]
        }

        variable uint row
        variable uint col

        if ${useGenerator.Uses.Contains[rows]} && !${useData.GetInteger[rows]} && !${useData.GetInteger[columns]}
        {
            for (row:Set[2] ; ${row}<=${Characters.Used} ; row:Inc)
            {
                useData:SetInteger[rows,${row}]
                for (col:Set[2] ; ${col}<=${Characters.Used} ; col:Inc)
                {
                    if ${row}*${col} >= ${Characters.Used}
                    {                    
                        useData:SetInteger[columns,${col}]      
;                        This:AddLayout["${name~} (${col}x${row})","${generator~}",useData,"WindowLayoutGenerators.GetGenerator[\"${generator~}\"].GenerateRegions[useData]"]              
                        This:AddGeneratedLayouts["${name~} (${col}x${row})","${generator~}",useData]
                    }
                }
            }            
        }

        /*
        useData:SetString[edge,"bottom"]
        This:AddLayout["Bottom","Edge",useData,"WindowLayoutGenerators.Edge.GenerateRegions["useData"]"]
        useData:SetString[edge,"right"]
        This:AddLayout["Right","Edge",useData,"WindowLayoutGenerators.Edge.GenerateRegions["useData"]"]
        useData:SetString[edge,"top"]
        This:AddLayout["Top","Edge",useData,"WindowLayoutGenerators.Edge.GenerateRegions["useData"]"]
        useData:SetString[edge,"left"]
        This:AddLayout["Left","Edge",useData,"WindowLayoutGenerators.Edge.GenerateRegions["useData"]"]

        This:AddLayout["Stacked","Stacked",useData,"WindowLayoutGenerators.Stacked.GenerateRegions["useData"]"]


        This:AddLayout["Tile","Tile",useData,"WindowLayoutGenerators.Tile.GenerateRegions["useData"]"]

        This:AddLayout["Grid","Grid",useData,"WindowLayoutGenerators.Grid.GenerateRegions["useData"]"]       
        /**/
    }

    method RefreshWindowLayouts()
    {
        echo "\ayRefreshWindowLayouts\ax"
        WindowLayouts:Clear
        variable jsonvalueref useData="RegionGeneratorSettings.Duplicate"
        useData:SetInteger[numSlots,${Characters.Used}]
        /*
        useData:SetValue["$$>
        {
            "numSlots":5,
            "useMonitor":1,
            "monitors":[
                ${Display.Monitor.AsJSON~}
            ],
            "avoidTaskbar":false,
            "leaveHole":true,
            "edge":"bottom",
            "rows":4,
            "columns":2
        }
        <$$"]
        */

        /*
        useData:SetString[edge,"bottom"]
        This:AddGeneratedLayouts["Bottom","Edge",useData]
        useData:SetString[edge,"right"]
        This:AddGeneratedLayouts["Right","Edge",useData]
        useData:SetString[edge,"top"]
        This:AddGeneratedLayouts["Top","Edge",useData]
        useData:SetString[edge,"left"]
        This:AddGeneratedLayouts["Left","Edge",useData]
        /**/

        This:AddGeneratedLayouts["Edge","Edge",useData]
        This:AddGeneratedLayouts["Stacked","Stacked",useData]


        This:AddGeneratedLayouts["Tile","Tile",useData]

        This:AddGeneratedLayouts["Grid","Grid",useData]       

        LGUI2.Element[isb2.QuickSetupWindow]:FireEventHandler[onWindowLayoutsUpdated]
    }

    member:jsonvalue GetLayoutPreviewExtents(jsonvalueref joLayout)
    {
        variable int left
        variable int right
        variable int top
        variable int bottom

        variable uint numMonitor

        variable uint numMonitors

        numMonitors:Set[${joLayout.Get[inputData,monitors].Used}]

        variable jsonvalueref jaMonitors

        variable jsonvalueref joMonitor
        if ${numMonitors}
        {
            jaMonitors:SetReference["joLayout.Get[inputData,monitors]"]
        }
        else
        {
            jaMonitors:SetReference["[]"]

            ; use current system monitors
            variable uint i
            for ( i:Set[1] ; ${i}<=${Display.Monitors} ; i:Inc)
            {
                jaMonitors:Add["${Display.Monitor[${i}].AsJSON~}"]
            }
            numMonitors:Set["${jaMonitors.Used}"]
        }

        for (numMonitor:Set[1] ; ${numMonitor}<=${numMonitors} ; numMonitor:Inc)
        {
            joMonitor:SetReference["jaMonitors.Get[${numMonitor}]"]
            if !${joMonitor.Reference(exists)}
                break

            if ${joMonitor.GetInteger[left]}<${left}
                left:Set["${joMonitor.GetInteger[left]}"]
            if ${joMonitor.GetInteger[top]}<${top}
                top:Set["${joMonitor.GetInteger[top]}"]

            if ${joMonitor.GetInteger[right]}>${right}
                right:Set["${joMonitor.GetInteger[right]}"]
            if ${joMonitor.GetInteger[bottom]}>${bottom}
                bottom:Set["${joMonitor.GetInteger[bottom]}"]
        }

        ;echo GetLayoutPreviewExtents "[${left},${top},${right.Dec[${left}]},${bottom.Dec[${top}]}]"
        return "[${left},${top},${right.Dec[${left}]},${bottom.Dec[${top}]}]"
    }

    member:jsonvalueref GetLayoutPreviewItems(lgui2elementref element)
    {
        variable jsonvalue ja="[]"

        ; echo "\ayGetLayoutPreviewItems\ax: element=${element.ID} context=${element.Context~}"
        variable jsonvalueref joLayout
        joLayout:SetReference[element.Context]
        if !${joLayout.Reference(exists)}
        {
;            echo "\ayGetLayoutPreviewItems\ax: NULL"
            return NULL
        }

;        echo GetLayoutPreviewItems element=${element}
        if ${element.Element(exists)}
        {
            variable jsonvalue jaExtents
            jaExtents:SetValue["${This.GetLayoutPreviewExtents[joLayout]}"]

            element:SetVirtualOrigin[${jaExtents.GetInteger[1]},${jaExtents.GetInteger[2]}]
            element:SetVirtualSize[${jaExtents.GetInteger[3]},${jaExtents.GetInteger[4]}]
        }

        ; screens
        joLayout.Get[inputData,monitors]:ForEach["This:AddScreen[ja,ForEach.Value]"]
        ; regions
        joLayout.Get[regions]:ForEach["This:AddRegion[ja,ForEach.Value]"]

       ;  echo "\ayGetLayoutPreviewItems\ax: ${ja~}"
        return ja
    }   


    member:int CompareDetectedCharacter(jsonvalueref joA, jsonvalueref joB)
    {
        variable int res            
        res:Set[${joA.Get[gameServer]~.Compare["${joB.Get[gameServer]~}"]}]
        if ${res}
            return ${res}

        res:Set[${joA.Get[name]~.Compare["${joB.Get[name]~}"]}]


;        echo "CompareDetectedCharacter ${joA~} ${joB~} ${res}"
        return ${res}
    }

    ; for performing an insert sort
    member:uint GetDetectedCharacterInsertPosition(jsonvalueref joDetected)
    {        
        if !${DetectedCharacters.Used}
        {
            ; add to end.
            return 0
        }

        variable uint i
        variable int cmp
        for (i:Set[1] ; ${i}<=${DetectedCharacters.Used} ; i:Inc)
        {
            if ${This.CompareDetectedCharacter["DetectedCharacters.Get[${i}]",joDetected]}>0
            {
                ; insert before this bad boy
                return ${i}
            }
        }

        ; add to end
        return 0
    }


    method AddDetectedCharacter(jsonvalueref joDetected)
    {
        variable uint pos=${This.GetDetectedCharacterInsertPosition[joDetected]}
;        echo "AddDetectedCharacter position ${pos}"            
        if ${pos}
        {
            DetectedCharacters:InsertByRef[${pos},joDetected]
        }
        else
            DetectedCharacters:AddByRef[joDetected]
    }

    method DetectCharactersFrom(jsonvalueref joGameLaunchInfo)
    {
        variable filepath gameFolder

        if ${joGameLaunchInfo.Has[-string,path]}
        {
            gameFolder:Set["${joGameLaunchInfo.Get[path]~}"]
        }
        else
        {
            ; game/gameProfile
            gameFolder:Set["${ISUplink.Game["${joGameLaunchInfo.Get[game]~}"].Get[Profiles,"${joGameLaunchInfo.Get[gameProfile]~}",Path]~}"]
        }

        if !${gameFolder~.NotNULLOrEmpty}
            return


        if ${DetectedGameFolders.Contains["${gameFolder~}"]}
            return
        DetectedGameFolders:Add["${gameFolder~}"]
        echo "\ayDetectCharactersFrom\ax ${joGameLaunchInfo~}"
        
        variable weakref gameRef
        gameRef:SetReference["ISB2.Games.Get[\"${GameName~}\"]"]

        variable jsonvalueref ja
        ja:SetReference["gameRef.DetectCharacters[\"${gameFolder~}\"]"]

        echo "Detected Characters: ${ja~}"
        ja.Get[characters]:ForEach["This:AddDetectedCharacter[ForEach.Value]"]
    }

    method DetectCharacters()
    {
        echo "\ayDetect Characters\ax ${GameName~}"
        variable weakref gameRef="ISB2.Games.Get[\"${GameName~}\"]"
        DetectedCharacters:Clear
        DetectedGameFolders:Clear
        if !${gameRef.CanDetectCharacters}
        {
            echo "game ${gameRef.Name~} cant detect characters"
            return
        }       
        ; collect game folders for the current game, based on available GameLaunchInfo
        GameLaunchInfo:ForEach["This:DetectCharactersFrom[ForEach.Value]"]
    }
}

variable(global) isb2_quicksetup ISB2QuickSetup