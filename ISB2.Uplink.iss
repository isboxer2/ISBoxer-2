#include "ISB2.Common.iss"
#include "ISB2.Games.iss"
#include "ISB2.Importer.iss"
#include "ISB2.QuickSetup.iss"
#include "ISB2.ProfileEditor.iss"

objectdef isb2 inherits isb2_profilecollection
{
    ; Reference to the currently selected Profile in the main window
    variable weakref SelectedProfile

    variable filepath SettingsFolder
    variable filepath ProfilesFolder

    variable jsonvalueref Settings="{}"

    variable isb2_games Games

    variable isb2_importer Importer
    variable isb2_slotmanager SlotManager
    variable string UseSkin="ISBoxer 2"

    variable bool bAutoStoreSettings=TRUE
    variable string SelectedTeamName

    variable collection:isb2_profileeditor Editors

    method Initialize()
    {
        if !${agent.Get[ISBoxer 2](exists)}
        {
            echo "ISBoxer 2 inactive; Agent not found..."
            return
        }

        if ${InnerSpace.Build} < ${agent.Get[ISBoxer 2].MinimumBuild}
        {
            echo "ISBoxer 2 inactive; Inner Space build ${agent.Get[ISBoxer 2].MinimumBuild} or later required (currently ${InnerSpace.Build})"
            return
        }

        Script.OnSetLastError:AttachAtom[This:OnScriptError]
        This:DetectSettingsFolder
        This:LoadSettings

        echo "ISBoxer 2: Using Profiles Folder ${ProfilesFolder~}"

        LGUI2:LoadPackageFile[ISB2.Skin.lgui2Package.json]
        LGUI2:PushSkin["${UseSkin~}"]
        LGUI2:LoadPackageFile[ISB2.Uplink.lgui2Package.json]
        LGUI2:PopSkin["${UseSkin~}"]

        This:LoadGames
        This:LoadNativeProfiles
        This:LoadPreviousProfiles

        if ${Settings.Has[lastSelectedTeam]}
            This:SelectTeam["${Settings.Get[lastSelectedTeam]~}"]

        LGUI2.Element[isb2.events]:AddHook[onProfilesUpdated,"$$>
        {
            "type":"method",
            "method":"OnProfilesUpdated",
            "object":"ISB2"
        }
        <$$"]
    }

    method Shutdown()
    {
        LGUI2:UnloadPackageFile[ISB2.Uplink.lgui2Package.json]
    }

    method OnScriptError()
    {
        Script:DumpStack
    }


    method OpenEditor(string profileName)
    {
        if ${Editors.Get["${profileName~}"](exists)}
            return

        if !${Profiles.Get["${profileName~}"](exists)}
            return

        Editors:Set["${profileName~}","Profiles.Get[\"${profileName~}\"]"]
    }    

    method OnProfilesUpdated()
    {
        variable jsonvalueref ja="[]"

        variable jsonvalue joQuery="{\"member\":\"Native\",\"op\":\"==\",\"value\":false}"

        Profiles:ForEach["ja:AddString[\"\${ForEach.Value.LocalFilename~}\"]",joQuery]
        Settings:SetByRef[loadedProfiles,ja]

        This:AutoStoreSettings
    }

    method LoadGames()
    {
        variable jsonvalue ja
        ja:SetValue["${LGUI2.Skin[default].Template[isb2.data].Get[games]~}"]

        Games:FromJSON[ja]
    }

    method DetectSettingsFolder()
    {
        ; use Documents folder if it exists
        SettingsFolder:Set["%USERPROFILE%/Documents"]:MakeAbsolute
        if !${SettingsFolder.PathExists}
        {
            ; otherwise try InnerSpace folder
            SettingsFolder:Set["${LavishScript.HomeDirectory}"]:MakeAbsolute
        }

        if ${SettingsFolder.PathExists}
        {
            ; now only use an ISBoxer 2 sub-folder
            if !${SettingsFolder.FileExists[ISBoxer 2]}
            {
                mkdir "${SettingsFolder~}/ISBoxer 2"            
            }
            SettingsFolder:Set["${SettingsFolder~}/ISBoxer 2"]
        }
        
        ProfilesFolder:Set["${SettingsFolder~}/Profiles"]
        if !${SettingsFolder.FileExists[Profiles]}
            mkdir "${ProfilesFolder~}"

        echo "ISBoxer 2: Using Settings Folder ${SettingsFolder~}"
    }

    member:filepath SettingsFilename()
    {
        return "${SettingsFolder~}/ISB2.Settings.json"
    }

    method LoadDefaultSettings()
    {
        Settings:SetReference["{}"]
    }

    method LoadNativeProfiles()
    {
        This:LoadFolder["${agent.Get[ISBoxer 2].Directory~}/Native Profiles/",1]   
    }

    method LoadPreviousProfiles()
    {
        Settings.Get[loadedProfiles]:ForEach["This:LoadFile[\"\${ForEach.Value~}\"]"]
    }

    method LoadSettings()
    {
        if ${SettingsFolder.FileExists[ISB2.Settings.json]}
        {
            Settings:SetReference["jsonobject.ParseFile[\"${This.SettingsFilename~}\"]"]
            if !${Settings.Reference(exists)}
            {
                This:LoadDefaultSettings
            }
        }
        else
        {
            This:LoadDefaultSettings
            This:StoreSettings
        }

        variable filepath newVal
        ; profiles folder...
        if ${Settings.Has[-string,profilesFolder]}
        {
            newVal:Set["${Settings.Get[profilesFolder]~}"]
            if ${newVal.NotNULLOrEmpty} && ${newVal.PathExists}
            {
                ProfilesFolder:Set["${newVal~}"]:MakeAbsolute
            }
        }
    }

    method StoreSettings()
    {        
        return ${Settings:WriteFile["${This.SettingsFilename~}",multiline](exists)}
    }

    method AutoStoreSettings()
    {
        if !${bAutoStoreSettings}
            return

        This:StoreSettings
    }

    method LoadTests()
    {
        This:LoadFile["Tests/ISBPW.isb2.json"]
        This:LoadFile["Tests/MyWindowLayout.isb2.json"]
        This:LoadFile["Tests/Team1.isb2.json"]
        This:LoadFile["Tests/VariableFollowMe.isb2.json"]
        This:LoadFile["Tests/WoW.isb2.json"]
    }

    member:bool QuickLaunch()
    {
        return ${Settings.GetBool[quickLaunch]}
    }

    method SetQuickLaunch(bool newValue=TRUE)
    {
        Settings:SetBool[quickLaunch,${newValue}]
        This:AutoStoreSettings
    }

    method SetLaunchDelay(float newValue)
    {
        Settings:SetNumber[launchDelay,${newValue}]
        This:AutoStoreSettings
    }

    method SelectProfile(string name)
    {
        SelectedProfile:SetReference["Profiles.Get[\"${name~}\"]"]
        LGUI2.Element[isb2.events]:FireEventHandler[onSelectedProfileChanged]
    }

    method SelectTeam(string name)
    {
        echo "\aySelectTeam\ax ${name~}"
        if ${name.NotNULLOrEmpty}
        {
            SelectedTeamName:Set["${name~}"]

            Settings:SetString[lastSelectedTeam,"${name~}"]
        }
        else
        {
            SelectedTeamName:Set[""]
            Settings:Erase[lastSelectedTeam]
        }
        This:AutoStoreSettings
        LGUI2.Element[isb2.events]:FireEventHandler[onSelectedTeamChanged]
    }

    method LaunchSelectedTeam()
    {
        if !${SelectedTeamName.NotNULLOrEmpty}
            return FALSE


        return ${SlotManager:LaunchTeamByName["${SelectedTeamName~}"]}
    }

    method OnImportButton()
    {
        ; select a file to import
        LGUI2.Element[isb2.importWindow]:SetVisibility[Visible]
    }

    method OnImportWindowFinalized()
    {
        variable filepath fileName="${Context.Source.Value~}"
        echo "File selected for import: ${fileName~}"
        LGUI2.Element[isb2.importWindow]:SetVisibility[Hidden]

        Importer:TransformProfileXML["${fileName~}"]

        This:LoadFile["${ProfilesFolder~}/${fileName.FilenameOnly~}.isb2.json"]
    }

    method OnLoadButton()
    {
        ; select a file to load
        LGUI2.Element[isb2.loadWindow]:SetVisibility[Visible]
    }

    method OnLoadWindowFinalized()
    {
        variable filepath fileName="${Context.Source.Value~}"
        echo "File selected for load: ${fileName~}"
        LGUI2.Element[isb2.loadWindow]:SetVisibility[Hidden]

        This:LoadFile["${fileName~}"]
    }

    method FilteredLoadFile(jsonvalueref jo)
    {
        variable string filename
        filename:Set["${jo.Get[filename]~}"]

        if ${filename.EndsWith[isb2.json]}
            This:LoadFile["${filename~}"]
    }

    method OnDragDropProfiles()
    {
;        echo "OnDragDropProfiles ${Context(type)} ${Context.Args~}"

        Context.Args.Get[files]:ForEach["This:FilteredLoadFile[\"\${ForEach.Value~}\"]"]

        Context:SetHandled[1]
    }

    member:jsonvalueref GetUserProfilesArray()
    {
        variable jsonvalue ja="[]"

        variable jsonvalue joQuery="{\"eval\":\"Select.Native\",\"op\":\"==\",\"value\":false}"

        Profiles:ForEach["ja:AddByRef[ForEach.Value.AsJSON]",joQuery]
        return ja
    }

    member:jsonvalueref GetNativeProfilesArray()
    {
        variable jsonvalue ja="[]"

        variable jsonvalue joQuery="{\"eval\":\"Select.Native\",\"op\":\"==\",\"value\":true}"

        Profiles:ForEach["ja:AddByRef[ForEach.Value.AsJSON]",joQuery]
        return ja
    }

}

objectdef isb2_managedSlot
{
    method Initialize(jsonvalueref joLaunch)
    {
        echo "\agisb2_managedSlot:Initialize\ax ${joLaunch~}"

        NumSlot:Set[${joLaunch.GetInteger[slot]}]

        This:SetState[0]
        OriginalState:Set[0]
        SlotObserver:SetReference["slotobserver.New[${NumSlot}]"]

        SlotObserver.OnMainSessionUpdated:AttachAtom[This:OnMainSessionUpdated]
        SlotObserver.OnMainSessionLost:AttachAtom[This:OnMainSessionLost]
        SlotObserver.OnSessionAdded:AttachAtom[This:OnSessionAdded]
        SlotObserver.OnSessionLost:AttachAtom[This:OnSessionLost]

        joCharacter:SetReference["joLaunch.Get[character]"]
        joTeam:SetReference["joLaunch.Get[team]"]

        WaitForMainSession:Set[1]
        if ${joLaunch.Has[waitForMainSession]}
            WaitForMainSession:Set[${joLaunch.GetBool[waitForMainSession]}]
        
        if ${joLaunch.Has[launchDelay]}
            LaunchDelay:Set[${joLaunch.GetNumber[launchDelay].Mul[1000]}]

        if ${SlotObserver.MainSession(exists)}
        {
            This:SetState[5]
            OriginalState:Set[5]
        }
        elseif ${SlotObserver.Sessions.Used}
        {
            This:SetState[6]
            OriginalState:Set[6]
        }

        joLaunchInfo:SetReference[joLaunch]
    }

    method SetState(int newState)
    {
        State:Set[${newState}]
        StateTimestamp:Set[${Script.RunningTime}]
    }

    method Kill()
    {
        SlotObserver.Sessions:ForEach["kill \"\${ForEach.Key~}\""]
        Launcher:Abort
        Launcher:SetReference[0]
    }

    member:jsonvalueref CollectProfiles()
    {
;        variable jsonvalueref ja="ISB2.GetUserProfilesArray"
        variable jsonvalue ja="[]"
        ; add profiles only as directed by team, slot, or character

        This:AddProfile[ja,"${joLaunchInfo.Get[teamProfile]~}"]
        This:AddProfiles[ja,"joTeam"]
        joTeam.Get[builders]:ForEach["This:AddProfile[ja,\"\${ForEach.Value.Get[profile]~}\"]"]
        This:AddProfiles[ja,"joTeam.Get[slots,${NumSlot}]"]
        This:AddProfile[ja,"${joLaunchInfo.Get[characterProfile]~}"]
        This:AddProfiles[ja,"joCharacter"]

        return ja
    }

    method AddProfile(jsonvalueref ja, string name)
    {
        variable weakref _profile="ISB2.Profiles.Get[\"${name~}\"]"
        if !${_profile.Reference(exists)}
            return FALSE

        if ${ja.Contains["${_profile.LocalFilename.AsJSON~}"]}
            return FALSE

        ja:AddString["${_profile.LocalFilename~}"]
        return TRUE
    }

    method AddProfiles(jsonvalueref ja, jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        jo.Get[profiles]:ForEach["This:AddProfile[ja,\"\${ForEach.Value}\"]"]
        return TRUE
    }

    method Launch()
    {
        if ${SlotObserver.Sessions.Used}
        {
            return FALSE
        }

        This:SetState[-1]
        if ${Launcher.Reference(exists)}
        {
            return FALSE
        }

        variable jsonvalue joGLI="${joCharacter.Get[gameLaunchInfo]~}"
        if !${joGLI.Type.Equal[object]}
        {
            return FALSE      
        }

        joLaunchInfo:SetBool[isb2,1]
        joLaunchInfo:SetByRef["isb2profiles",This.CollectProfiles]
        joGLI:SetByRef[metadata,joLaunchInfo]

        Script:SetLastError        
        Launcher:SetReference["SlotObserver.NewLauncher[joGLI]"]
        if ${Script.LastError.NotNULLOrEmpty}
        {
            Error:Set["${Script.LastError~}"]            
        }
        if !${Launcher.Reference(exists)}
        {

            return FALSE
        }

        Launcher.OnLaunchStarted:AttachAtom[This:OnLaunchStarted]
        Launcher.OnLaunchFailed:AttachAtom[This:OnLaunchFailed]
        Launcher.OnLaunchSucceeded:AttachAtom[This:OnLaunchSucceeded]
        LaunchDelay:Set["${ISB2.Settings.GetNumber[launchDelay]}*1000"]


        if !${Launcher:Start(exists)}
            return FALSE
        This:SetState[1]
        return TRUE
    }

    method Abort()
    {
        if !${Launcher.Reference(exists)}
            return FALSE
        Launcher:Abort
        This:SetState[-2]
    }

    method OnLaunchStarted()
    {
        This:SetState[2]
        echo "isb2_managedSlot[${NumSlot}]:OnLaunchStarted"
    }

    method OnLaunchFailed()
    {
        This:SetState[-3]
        echo "isb2_managedSlot[${NumSlot}]:OnLaunchFailed: ${Launcher.Error~}"
    }

    method OnLaunchSucceeded()
    {
        This:SetState[3]
        echo "isb2_managedSlot[${NumSlot}]:OnLaunchSucceeded"
    }

    method OnSessionAdded()
    {
        if ${State}==5
            return FALSE
            
        This:SetState[4]
        echo "isb2_managedSlot[${NumSlot}]:OnSessionAdded"
    }

    method OnSessionLost()
    {
        ; this will occur during many normal launches due to multiple processes        
        echo "isb2_managedSlot[${NumSlot}]:OnSessionLost"
    }

    method OnMainSessionLost()
    {
        ; this was specifically a main session. during startup, this is not normal
        This:SetState[-4]
        echo "isb2_managedSlot[${NumSlot}]:OnMainSessionLost"
    }

    method OnMainSessionUpdated()
    {
        This:SetState[5]
        echo "isb2_managedSlot[${NumSlot}]:OnMainSessionUpdated ${Context.AsJSON~}"

        ISB2.SlotManager.LastLaunchedTime:Set[${Script.RunningTime}]
    }

    member:bool Waiting()
    {
        ; return TRUE if simultaneous/further launching should wait
        ; e.g. because of game launcher mechanics
        if !${State}
            return FALSE

        if ${WaitForMainSession}
        {
            if ${State}!=5
                return TRUE

            ; we have a main session, determine if we should wait before launching the next window.
            if ${LaunchDelay} && ${ISB2.SlotManager.LastLaunchedTime}
            {
;                if ${Script.RunningTime} < (${StateTimestamp} + ${LaunchDelay})
                if ${Script.RunningTime} < (${ISB2.SlotManager.LastLaunchedTime} + ${LaunchDelay})
                    return TRUE
            }
        }        
        return FALSE
    }

    member StateName()
    {
        switch ${State}
        {
            case -4
                return "Lost"
            case -3
                return "Launch Failed"
            case -2
                return "Launch Aborted"
            case -1
                return "Could Not Launch"
            case 0
                return "Idle"
            case 1
                return "Queued"
            case 2
                return "Launching"
            case 3
                return "Pre-Startup"
            case 4
                return "Startup"
            case 5
                return "Live"
            case 6
                return "Questionable"
        }
    }
    
    member:string GetFileNameOnly(filepath fullName)
    {
        variable int numSlashes = ${fullName.Count["/"]}
        if !${numSlashes}
            return "${fullName~}"

        return "${fullName.Token[${numSlashes.Inc[1]},"/"]~}"
    }

    member:string GetFilePathOnly(filepath fullName)
    {
        variable int numSlashes = ${fullName.Count["/"]}
        if !${numSlashes}
            return "${fullName~}"

        return "${fullName.Token[${numSlashes.Inc[1]},"/"]~}"
    }

    member Title()
    {               

        variable filepath fp
        if ${SlotObserver.MainSession(exists)}
        {
            fp:Set["${SlotObserver.MainSession.Executable~}"]
        }
        else
        {
            fp:Set["${joLaunchInfo.Get[character,gameLaunchInfo,path]~}\\${joLaunchInfo.Get[character,gameLaunchInfo,executable]~}"]
        }
        
        if ${joLaunchInfo.Has[character,gameLaunchInfo,game]}
        {
            if ${fp.FilenameOnly.NotNULLOrEmpty}
                return "${This.StateName~}: ${joLaunchInfo.Get[character,gameLaunchInfo,game]} (${fp.FilenameOnly~})"
                
            return "${This.StateName~}: ${joLaunchInfo.Get[character,gameLaunchInfo,game]}"
        }

        return "${This.StateName~}: ${fp.FilenameOnly~}"
    }

    member:jsonvalueref AsJSON()
    {
        variable jsonvalueref jo="{}"

        jo:SetInteger["slot","${NumSlot}"]
        jo:SetString["title","${This.Title~}"]

        jo:SetInteger["state",${State}]
        jo:SetString["error","${This.GetError~}"]
        jo:SetByRef["launchInfo",joLaunchInfo]
        return jo
    }

    member GetError()
    {
        if ${Launcher.Error.NotNULLOrEmpty}
            return "${Launcher.Error~}"
        return "${Error~}"
    }

    variable sessionlauncher Launcher
    variable slotobserver SlotObserver
    variable string Error
    variable uint NumSlot

    variable jsonvalueref joLaunchInfo
    variable jsonvalueref joCharacter
    variable jsonvalueref joTeam
    
    variable int64 StateTimestamp
    variable int State
    variable int OriginalState
    variable bool WaitForMainSession
    variable uint LaunchDelay
}

objectdef isb2_slotmanager
{
    method Clear()
    {
        Slots:Clear
        Launching:SetReference[0]
        LaunchingSlotNum:Set[0]
        LGUI2.Element[isb2.events]:FireEventHandler[onSlotsUpdated]
        
    }

    method Start()
    {
        Slots:GetIterator[LaunchingSlot]        
        if !${LaunchingSlot:First(exists)}
            return FALSE

        LaunchingSlotNum:Set[1]
        LGUI2.Element[isb2.launching]:SetVisibility[Visible]
        StopTime:Set[0]
        StartTime:Set["${Script.RunningTime}"]
        Event[OnFrame]:AttachAtom[This:Pulse]
        LaunchingSlot.Value:Launch
        return TRUE
    }  

    method Stop()
    {
        echo "\arisb2_slotmanager:Stop\ax"
        Event[OnFrame]:DetachAtom[This:Pulse]
        if !${StopTime}
            StopTime:Set["${Script.RunningTime}"]

        relay is1 "ISB2:ResetTaskbarTab[1]"
    }

    member:bool AnyNotLive()
    {
        if !${Slots.Used}
            return FALSE

        variable jsonvalueref joQuery="$$>
        {
            "op":"!=",
            "member":"State",
            "value":5
        }       
        <$$"

        if ${Slots.SelectKey[joQuery]}
        {
            return TRUE
        }

        return FALSE
    }

    member:bool AnyPending()
    {
        if !${Slots.Used}
            return FALSE

        variable jsonvalueref joQuery="$$>
        {
            "member":"State",
            "op":"&&",
            "list":[
                {
                    "op":">="
                    "value":1
                },
                {
                    "op":"<="
                    "value":4
                }
            ]
        }       
        <$$"

        if ${Slots.SelectKey[joQuery]}
        {
            return TRUE
        }

        return FALSE
    }

    member:bool Active()
    {
        return ${This.AnyPending}        
    }

    member:float Duration()
    {
        variable float val

        if !${StartTime}
            return 0

        variable uint useStopTime=${StopTime}
        if !${useStopTime}
            useStopTime:Set["${Script.RunningTime}"]

        val:Set["(${useStopTime}-${StartTime})/1000"]        
        return ${val}
    }

    method Test(int numSlots=1)
    {
        variable jsonvalue jo="{}"

        variable jsonvalue ja="[]"
        jo:SetInteger["slot",1]
        jo:SetString["character","Character Two"]
        jo:SetString["team","Team 1"]
        jo:SetBool[waitForMainSession,FALSE]
        ja:Add["${jo~}"]

        variable int n
        for (n:Set[2] ; ${n}<=${numSlots} ; n:Inc)
        {
            jo:SetInteger["slot",${n}]
            ja:Add["${jo~}"]
        }
/*
        jo:SetInteger["slot",3]
        ja:Add["${jo~}"]

        jo:SetInteger["slot",4]
        ja:Add["${jo~}"]

        jo:SetInteger["slot",5]
        ja:Add["${jo~}"]
*/
        This:Prepare[ja]
        This:Start
    }

    method LaunchTeamByName(string teamName, string profileName="")
    {
        variable jsonvalueref joTeam        

        if ${profileName.NotNULLOrEmpty}
        {
            joTeam:SetReference["ISB2.Profiles.Get[\"${jo.Get[teamProfile]~}\"].FindOne[\"Teams\",\"${jo.Get[team]~}\"]"]
            if !${joTeam.Type.Equal[object]}            
            {
                Script:SetLastError["team ${teamName~} not found in profile ${profileName~}"]
                return FALSE
            }
        }
        else
        {
            joTeam:SetReference["ISB2.Locate[Teams,\"${teamName~}\"]"]
            if !${joTeam.Type.Equal[object]}
            {
                Script:SetLastError["team ${teamName~} not found"]
                return FALSE
            }

            profileName:Set["${joTeam.Get[profile]~}"]
;            echo "Located team=${joTeam~}"
            joTeam:SetReference["joTeam.Get[object]"]

;            echo "Located team=${joTeam~}"
        }

        return ${This:LaunchTeam[joTeam,"${profileName~}"](exists)}
    }

    method AddTeamLaunchSlot(jsonvalueref ja, jsonvalueref joTeam, uint numSlot, jsonvalueref joSlot, jsonvalueref jo)
    {
;        echo "AddTeamLaunchSlot ${numSlot} ${joSlot~}"
        jo:SetInteger["slot",${numSlot}]
        jo:SetString["character","${joSlot.Get[character]~}"]
        jo:SetByRef["team",joTeam]
        ja:Add["${jo~}"]
    }

    method LaunchTeam(jsonvalueref joTeam, string profileName="")
    {
        if !${joTeam.Type.Equal[object]}
        {
            Script:SetLastError["LaunchTeam: expected json object"]
            return FALSE
        }
;        echo "LaunchTeam[${profileName~}] ${joTeam~}"
        variable jsonvalue ja="[]"

        variable jsonvalue jo="{}"
        if ${profileName.NotNULLOrEmpty}
            jo:SetString["teamProfile","${profileName~}"]

        if !${ISB2.Settings.GetBool[quickLaunch]}
            jo:SetBool[waitForMainSession,TRUE]
        else
            jo:SetBool[waitForMainSession,FALSE]      

        joTeam.Get[slots]:ForEach["This:AddTeamLaunchSlot[ja,joTeam,\${ForEach.Key},ForEach.Value,jo]"]

        This:Prepare[ja]
        This:Start
    }

    method ResolveCharacter(jsonvalueref jo)
    {
        if !${jo.Get[character](type)~.Equal[unistring]}
            return

        if ${jo.Has[characterProfile]}
        {
            jo:SetByRef["character","ISB2.Profiles.Get[\"${jo.Get[characterProfile]~}\"].FindOne[\"Characters\",\"${jo.Get[character]~}\"]"]
        }
        elseif ${jo.Has[character]}
        {
            variable jsonvalueref joLocated
            joLocated:SetReference["ISB2.Locate[Characters,\"${jo.Get[character]~}\",\"${jo.Get[teamProfile]~}\"]"]
            if ${joLocated.Type.Equal[object]}
            {
                jo:SetByRef[character,"joLocated.Get[object]"]
                jo:SetString[characterProfile,"${joLocated.Get[profile]~}"]
            }
        }
    }

    method ResolveTeam(jsonvalueref jo)
    {
        if !${jo.Get[team](type)~.Equal[unistring]}
            return

        if ${jo.Has[teamProfile]}
        {
            jo:SetByRef["team","ISB2.Profiles.Get[\"${jo.Get[teamProfile]~}\"].FindOne[\"Teams\",\"${jo.Get[team]~}\"]"]
        }
        elseif ${jo.Has[team]}
        {
            variable jsonvalueref joLocated
            joLocated:SetReference["ISB2.Locate[Teams,\"${jo.Get[team]~}\"]"]
            if ${joLocated.Type.Equal[object]}
            {
                jo:SetByRef[team,"joLocated.Get[object]"]
                jo:SetString[teamProfile,"${joLocated.Get[profile]~}"]
            }
        }
    }

    method Prepare(jsonvalueref jLaunch)
    {
        if ${jLaunch.Type.Equal[array]}
        {
            Slots:Clear
            Launching:SetReference[0]
            jLaunch:ForEach["This:Prepare[ForEach.Value]"]
            return TRUE
        }

        if !${jLaunch.Type.Equal[object]}
            return FALSE

        ; launch a single instance
        /*
        {
            "slot":1
            "character":"My Character",
            "characterProfile":"My Team Profile",
            "team":"My Team",
            "teamProfile":"My Team Profile"            
        }
        */

        variable int numSlot
        numSlot:Set["${jLaunch.GetInteger[slot]}"]
        if !${numSlot}
            return FALSE

        variable jsonvalue joLaunch
        joLaunch:SetValue["${jLaunch~}"]

        ; resolve names into references and place in joLaunch        
        This:ResolveCharacter[joLaunch]
        This:ResolveTeam[joLaunch]
        joLaunch:SetInteger["slot",${numSlot}]

        Slots:Set[${numSlot.LeadingZeroes[3]},"joLaunch"]
        LGUI2.Element[isb2.events]:FireEventHandler[onSlotsUpdated]
        return TRUE
    }

    method Pulse()
    {
;        echo "isb2_launcher:Pulse"

        if !${LaunchingSlot.Value(exists)}
        {
            if ${This.Active}
                return TRUE
            This:Stop
            return FALSE
        }

        do
        {        
            if ${LaunchingSlotNum}<${Slots.Used} && ${LaunchingSlot.Value.Waiting}
            {
                return TRUE
            }

            if !${LaunchingSlot:Next(exists)}
            {
                if ${This.Active}
                    return TRUE

                This:Stop
                return FALSE
            }

            LaunchingSlotNum:Inc
            LaunchingSlot.Value:Launch
        }
        while 1
    }

    method CopyStateToClipboard()
    {
        System:SetClipboardText["${Slots.AsJSON[array,multiline]~}"]        
    }

    variable iterator LaunchingSlot
    variable uint LaunchingSlotNum
    variable collection:isb2_managedSlot Slots
    variable weakref Launching
    variable uint StartTime
    variable uint StopTime

    variable uint LastLaunchedTime
}

variable(global) isb2 ISB2

function main()
{
    while 1
        waitframe
}