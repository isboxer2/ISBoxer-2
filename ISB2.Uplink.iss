#include "ISB2.Common.iss"
#include "ISB2.Importer.iss"

objectdef isb2 inherits isb2_profilecollection
{
    ; Reference to the currently selected Profile in the main window
    variable weakref SelectedProfile

    variable isb2_importer Importer
    variable isb2_slotmanager SlotManager

    method Initialize()
    {
        LGUI2:LoadPackageFile[ISB2.Uplink.lgui2Package.json]
    }

    method Shutdown()
    {
        LGUI2:UnloadPackageFile[ISB2.Uplink.lgui2Package.json]
    }

    method LoadTests()
    {
        This:LoadFile["Tests/ISBPW.isb2.json"]
        This:LoadFile["Tests/MyWindowLayout.isb2.json"]
        This:LoadFile["Tests/Team1.isb2.json"]
        This:LoadFile["Tests/VariableFollowMe.isb2.json"]
        This:LoadFile["Tests/WoW.isb2.json"]
    }

    method SelectProfile(string name)
    {
        SelectedProfile:SetReference["Profiles.Get[\"${name~}\"]"]
        LGUI2.Element[isb2.events]:FireEventHandler[onSelectedProfileChanged]
    }
}

objectdef isb2_managedSlot
{
    method Initialize(jsonvalueref joLaunch)
    {
        echo "\agisb2_managedSlot:Initialize\ax ${joLaunch~}"

        NumSlot:Set[${joLaunch.GetInteger[slot]}]

        State:Set[0]
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
        
        joLaunchInfo:SetReference[joLaunch]
    }

    method Launch()
    {
        State:Set[-1]
        if ${Launcher.Reference(exists)}
            return FALSE

        variable jsonvalue joGLI="${joCharacter.Get[gameLaunchInfo]~}"
        if !${joGLI.Type.Equal[object]}
            return FALSE      

        joLaunchInfo:SetBool[isb2,1]
        joLaunchInfo:SetByRef["isb2profiles",ISB2.GetLoadedFilenames]
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



        if !${Launcher:Start(exists)}
            return FALSE
        State:Set[1]
        return TRUE
    }

    method Abort()
    {
        if !${Launcher.Reference(exists)}
            return FALSE
        Launcher:Abort
        State:Set[-2]
    }

    method OnLaunchStarted()
    {
        State:Set[2]
        echo "isb2_managedSlot[${NumSlot}]:OnLaunchStarted"
    }

    method OnLaunchFailed()
    {
        State:Set[-3]
        echo "isb2_managedSlot[${NumSlot}]:OnLaunchFailed: ${Launcher.Error~}"
    }

    method OnLaunchSucceeded()
    {
        State:Set[3]
        echo "isb2_managedSlot[${NumSlot}]:OnLaunchSucceeded"
    }

    method OnSessionAdded()
    {
        State:Set[4]
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
        State:Set[-4]
        echo "isb2_managedSlot[${NumSlot}]:OnMainSessionLost"
    }

    method OnMainSessionUpdated()
    {
        State:Set[5]
        echo "isb2_managedSlot[${NumSlot}]:OnMainSessionUpdated"
    }

    member:bool Waiting()
    {
        ; return TRUE if simultaneous/further launching should wait
        ; e.g. because of game launcher mechanics
        if !${State}
            return FALSE

        if ${WaitForMainSession}
        {
            if ${State}<5
                return TRUE
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
    
    variable int State
    variable bool WaitForMainSession
}

objectdef isb2_slotmanager
{
    method Clear()
    {
        Slots:Clear
        Launching:SetReference[0]
        LGUI2.Element[isb2.events]:FireEventHandler[onSlotsUpdated]
        
    }

    method Start()
    {
        Slots:GetIterator[LaunchingSlot]        
        if !${LaunchingSlot:First(exists)}
            return FALSE

        Event[OnFrame]:AttachAtom[This:Pulse]
        LaunchingSlot.Value:Launch
        return TRUE
    }

    method Stop()
    {
        Event[OnFrame]:DetachAtom[This:Pulse]
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

        Slots:Set[${numSlot},"joLaunch"]
        LGUI2.Element[isb2.events]:FireEventHandler[onSlotsUpdated]
        return TRUE
    }

    method Pulse()
    {
;        echo "isb2_launcher:Pulse"

        if !${LaunchingSlot.Value(exists)}
        {
            This:Stop
            return FALSE
        }

        do
        {        
            if ${LaunchingSlot.Value.Waiting}
                return TRUE

            if !${LaunchingSlot:Next(exists)}
            {
                This:Stop
                return FALSE
            }

            LaunchingSlot.Value:Launch
        }
        while 1
    }

    variable iterator LaunchingSlot
    variable collection:isb2_managedSlot Slots
    variable weakref Launching
}

variable(global) isb2 ISB2

function main()
{
    while 1
        waitframe
}