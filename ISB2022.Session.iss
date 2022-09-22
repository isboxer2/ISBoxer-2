#include "ISB2022.Common.iss"
#include "ISB2022.ProfileEngine.iss"

; run "ISBoxer 2022/ISB2022.Session"

objectdef isb2022session inherits isb2022_profileengine
{
    variable bool ValidSession

    variable isb2022_profilecollection ProfileDB

    method Initialize()
    {
        if ${JMB(exists)} && !${JMB.Slot.Metadata.Get[launcher]~.Equal["ISBoxer 2022"]}
        {
            echo "ISBoxer 2022 inactive; Session not launched by ISBoxer 2022."
            return
        }

        if ${InnerSpace.Build} < 6997
        {
            echo "ISBoxer 2022 inactive; Inner Space build 6987 or later required (currently ${InnerSpace.Build})"
            return
        }

        ValidSession:Set[1]
    
        LGUI2:LoadPackageFile[ISB2022.Session.lgui2Package.json]
        This:InstallDefaultActionTypes
    }

    method Shutdown()
    {
        LGUI2:UnloadPackageFile[ISB2022.Session.lgui2Package.json]
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
        wrappedCommand:Set["ISB2022:OnReceiveCommand[\"${Session~}\",\"${command~}\"]"]
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

variable(global) isb2022session ISB2022

function main()
{
    if !${ISB2022.ValidSession}
        return
    while 1
        waitframe
}