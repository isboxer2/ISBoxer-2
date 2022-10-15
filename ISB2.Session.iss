#include "ISB2.Common.iss"
#include "ISB2.ProfileEngine.iss"
#include "ISB2.WindowLayoutEngine.iss"

; run "ISBoxer 2/ISB2.Session"

objectdef isb2session inherits isb2_profileengine
{
    variable bool ValidSession

    variable isb2_profilecollection ProfileDB

    method Initialize()
    {
        if ${JMB(exists)} && !${JMB.Slot.Metadata.Get[launcher]~.Equal["ISBoxer 2"]}
        {
            echo "ISBoxer 2 inactive; Session not launched by ISBoxer 2."
            return
        }

        if ${InnerSpace.Build} < 7033
        {
            echo "ISBoxer 2 inactive; Inner Space build 7033 or later required (currently ${InnerSpace.Build})"
            return
        }

        ValidSession:Set[1]
    
        LGUI2:LoadPackageFile[ISB2.Session.lgui2Package.json]
        This:InstallDefaultActionTypes

        if ${ISSession.Metadata.Has[isb2]}
        {
            This:InstallFromSessionMetadata[ISSession.Metadata]
        }

        This:InstallDefaultVirtualFiles
    }

    method Shutdown()
    {
        LGUI2:UnloadPackageFile[ISB2.Session.lgui2Package.json]
    }

    method InstallFromSessionMetadata(jsonvalueref joMetadata)
    {
        echo "isb2session:InstallFromSessionMetadata ${joMetadata~}"

        ProfileDB:LoadFiles["joMetadata.Get[isb2profiles]"]
        
        if ${joMetadata.Has[teamProfile]}
            This:ActivateProfileByName["${joMetadata.Get[teamProfile]~}"]
        if ${joMetadata.Has[characterProfile]}
            This:ActivateProfileByName["${joMetadata.Get[characterProfile]~}"]

        if ${joMetadata.Has[team]}
            This:ActivateTeamByName["${joMetadata.Get[team,name]~}"]
        if ${joMetadata.Has[character]}
            This:ActivateCharacterByName["${joMetadata.Get[character,name]~}"]
    }

    method ActivateProfilesByName(jsonvalueref jaProfiles)
    {
        if !${jaProfiles.Type.Equal[array]}
            return

        jaProfiles:ForEach["This:ActivateProfileByName[\"\${ForEach.Value~}\"]"]
    }

    method ActivateProfileByName(string name)
    {
        variable weakref useProfile="ProfileDB.Profiles.Get[\"${name~}\"]"
        echo "ActivateProfileByName ${name} = ${useProfile.AsJSON~}"
        return "${This:ActivateProfile[useProfile](exists)}"
    }

    method DeactivateProfileByName(string name)
    {
        variable weakref useProfile="ProfileDB.Profiles.Get[\"${name~}\"]"
        echo "DeactivateProfileByName ${name} = ${useProfile.AsJSON~}"
        return "${This:DeactivateProfile[useProfile](exists)}"
    }

    method BeginTest()
    {
        echo "ISB1=${This.DetectISBoxer1~}"

        ProfileDB:LoadFolder["${Script.CurrentDirectory~}/Tests"]

        This:ActivateProfileByName["${ISBoxerCharacterSet~}"]
        This:ActivateTeamByName["${ISBoxerCharacterSet~}"]
        This:ActivateCharacterByName["${ISBoxerCharacter~}"]
    }

    member:jsonvalueref DetectISBoxer1()
    {
        if !${ISBoxerCharacter(exists)}
            return NULL

        variable jsonvalue jo

        jo:SetValue["$$>
        {
            "character":${ISBoxerCharacter.AsJSON~},
            "characterSet":${ISBoxerCharacterSet.AsJSON~},
            "numSlots":${ISBoxerSlots.AsJSON~},
            "slot":${ISBoxerSlot.AsJSON~}
        }<$$"]

        variable jsonvalue jaSlots="[]"
        variable int i

        for (i:Set[1];${i}<=${ISBoxerSlots};i:Inc)
        {
            jaSlots:Add["${ISBoxerSlot${i}.AsJSON~}"]
        }

        jo:SetByRef["slots",jaSlots]

        return jo
    }




    method Unicast(string relay_target, string command)
    {
        variable string wrappedCommand
        wrappedCommand:Set["ISB2:OnReceiveCommand[\"${Session~}\",\"${command~}\"]"]
        echo BeginTask=${TaskManager:BeginTask["$$>
        {
            "type":"unicast",
            "target":${relay_target.AsJSON~},
            "task":{
                "type":"ls1.code",
                "start":${wrappedCommand.AsJSON~}
            }
        }
        <$$"](exists)}
    }

    method OnReceiveCommand(string relay_from, string command)
    {
;        echo "OnReceiveCommand(\"${relay_from~}\",\"${command~}\")"
        execute -reparse "${command~}"
    }

    method Restart()
    {
        variable string cmd="run \"${Script.CurrentDirectory~}/${Script.Filename~}\""
        timed 1 "${cmd~}"
        Script:End
    }

}

variable(global) isb2session ISB2

function main()
{
    if !${ISB2.ValidSession}
        return
    while 1
        waitframe
}