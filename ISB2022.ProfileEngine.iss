/* isb2022_profileengine: 
    An active ISBoxer 2022 Profile collection
*/
objectdef isb2022_profileengine
{
    variable isb2022_actiontypemanager Actions

    variable set Profiles

    variable set Hotkeys

    variable collection:isb2022_hotkeysheet HotkeySheets
    variable collection:isb2022_mappablesheet MappableSheets
    variable jsonvalue InputMappings="{}"

    variable taskmanager TaskManager=${LMAC.NewTaskManager["profileEngine"]}

    method Initialize()
    {
    }

    method Shutdown()
    {
        This:UninstallHotkeys
        TaskManager:Destroy
    }

    method InstallActionTypes(string actionObject)
    {
        Actions.ActionObject:Set["${actionObject~}"]
        Actions:InstallActionType["Keystroke","Action_Keystroke"]
    }

    method InstallVirtualFile(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        variable string pattern
        variable string replacement

        pattern:Set["${This.ProcessVariables["${jo.Get[pattern]~}"]~}"]
        replacement:Set["${This.ProcessVariables["${jo.Get[replacement]~}"]~}"]

        fileredirect "${pattern~}" "${replacement~}"
    }

    method UninstallVirtualFile(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        variable string pattern

        pattern:Set["${This.ProcessVariables["${jo.Get[pattern]~}"]~}"]

        fileredirect -remove "${pattern~}" 
    }


    method InstallProfile(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE
    }

    method InstallTriggers(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallTrigger[ForEach.Value]"]
    }    

    method InstallTeams(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallTeam[ForEach.Value]"]
    }    

    method InstallCharacters(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallCharacter[ForEach.Value]"]
    }    

    
    method InstallHotkeySheet(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        variable string name
        name:Set["${jo.Get[name]~}"]

        HotkeySheets:Erase["${name~}"]

        HotkeySheets:Set["${name~}",jo]
    }

    method InstallMappableSheet(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        variable string name
        name:Set["${jo.Get[name]~}"]

        MappableSheets:Erase["${name~}"]

        MappableSheets:Set["${name~}",jo]
    }


    method InstallHotkeySheets(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallHotkeySheet[ForEach.Value]"]
    }

    method InstallGameKeyBindings(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallGameKeyBinding[ForEach.Value]"]
    }

    method InstallKeyLayouts(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallKeyLayout[ForEach.Value]"]
    }    

    method InstallProfiles(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallProfile[ForEach.Value]"]
    }    

    method InstallVirtualFiles(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallVirtualFile[ForEach.Value]"]
    }

    method InstallWindowLayouts(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallWindowLayout[ForEach.Value]"]
    }

    method ActivateProfile(weakref _profile)
    {
        if !${_profile.Reference(exists)}
            return

        ; already activated.
        if ${Profiles.Contains["${_profile.Name~}"]}
            return
        Profiles:Add["${_profile.Name~}"]

        This:InstallProfiles[_profile.Profiles]

        This:InstallVirtualFiles[_profile.VirtualFiles]
        This:InstallWindowLayouts[_profile.WindowLayouts]
        This:InstallTriggers[_profile.Triggers]
;        This:InstallHotkeys[_profile.Hotkeys]
        This:InstallGameKeyBindings[_profile.GameKeyBindings]
        This:InstallKeyLayouts[_profile.KeyLayouts]

        This:InstallCharacters[_profile.Characters]
        This:InstallTeams[_profile.Teams]
    }

    method DeactivateProfile(weakref _profile)
    {
        if !${_profile.Reference(exists)}
            return

        ; not already activated.
        if !${Profiles.Contains["${_profile.Name~}"]}
            return

        Profiles:Erase["${_profile.Name~}"]

        This:UninstallProfiles[_profile.Profiles]

        This:UninstallVirtualFiles[_profile.VirtualFiles]
        This:UninstallWindowLayouts[_profile.WindowLayouts]
        This:UninstallTriggers[_profile.Triggers]
;        This:UninstallHotkeys[_profile.Hotkeys]
        This:UninstallGameKeyBindings[_profile.GameKeyBindings]
        This:UninstallKeyLayouts[_profile.KeyLayouts]

        This:UninstallCharacters[_profile.Characters]
        This:UninstallTeams[_profile.Teams]
    }

    member:string ProcessVariables(string text)
    {
        ; todo
        return "${text~}"
    }



    method TestKeystroke(string key)
    {
        variable jsonvalue joAction="{}"
        joAction:SetString["key","${key~}"]

        This:Action_Keystroke[NULL,joAction,TRUE]
        This:Action_Keystroke[NULL,joAction,FALSE]
    }

    method Action_Keystroke(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "Action_Keystroke[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        variable string keystroke
        keystroke:Set["${joAction.Get[key]~}"]
        if !${keystroke.NotNULLOrEmpty}
            return

        if ${activate}
        {
            echo press -hold "${keystroke}"
            press -hold "${keystroke}"
        }
        else
        {
            echo press -release "${keystroke}"
            press -release "${keystroke}"
        }
    }


    method InstallInputMapping(string name,jsonvalueref joMapping)
    {
        echo "InstallInputMapping ${name~}: ${joMapping}"
        InputMappings:SetByRef["${name~}",joMapping]
    }

    method UninstallInputMapping(string name)
    {
        InputMappings:Erase["${name~}"]
    }

    method InstallHotkey(string sheet, string name, jsonvalueref joHotkey)
    {
        echo "InstallHotkey[${sheet~},${name~}] ${joHotkey~}"
        variable jsonvalue joBinding
        ; initialize a LGUI2 input binding object with JSON
        variable string fullName="isb2022.hks.${sheet~}.${name~}"
        variable string onPress="ISB2022:ExecuteHotkeyByName[${sheet.AsJSON~},${name.AsJSON~},1]"
        variable string onRelease="ISB2022:ExecuteHotkeyByName[${sheet.AsJSON~},${name.AsJSON~},0]"
        variable string keyCombo="${joHotkey.Get[keyCombo]~}"

        joBinding:SetValue["$$>
        {
            "name":${fullName.AsJSON~},
            "combo":${keyCombo.AsJSON~},
            "eventHandler":{
                "type":"task",
                "taskManager":"profileEngine",
                "task":{
                    "type":"ls1.code",
                    "start":${onPress.AsJSON~},
                    "stop":${onRelease.AsJSON~}
                }
            }
        }
        <$$"]

        ; now add the binding to LGUI2!
        echo "AddBinding ${joBinding~}"
        LGUI2:AddBinding["${joBinding~}"]

        Hotkeys:Add["${fullName~}"]
    }

    ; Installs a Hotkey, given a name, a key combination, and LavishScript code to execute on PRESS
    method InstallHotkeyEx(string name, string keyCombo, string onPress, string onRelease)
    {
        echo "InstallHotkeyEx ${name~}: ${keyCombo~}"

        if !${onPress.NotNULLOrEmpty} && !${onRelease.NotNULLOrEmpty}
        {
            ; defaults
            onPress:Set["ISB2022:OnHotkeyState[${name.AsJSON~},1]"]
            onRelease:Set["ISB2022:OnHotkeyState[${name.AsJSON~},0]"]
        }


        variable jsonvalue joBinding
        ; initialize a LGUI2 input binding object with JSON
        joBinding:SetValue["$$>
        {
            "name":${name.AsJSON~},
            "combo":${keyCombo.AsJSON~},
            "eventHandler":{
                "type":"task",
                "taskManager":"profileEngine",
                "task":{
                    "type":"ls1.code",
                    "start":${onPress.AsJSON~},
                    "stop":${onRelease.AsJSON~}
                }
            }
        }
        <$$"]

        ; now add the binding to LGUI2!
        LGUI2:AddBinding["${joBinding~}"]

        Hotkeys:Add["${name~}"]
    }

    method UninstallHotkey(string sheet, string name)
    {
        variable string fullName="isb2022.hks.${sheet~}.${name~}"
        This:UninstallHotkeyEx["${fullName~}"]
    }

    method UninstallHotkeyEx(string name)
    {
        echo "UninstallHotkeyEx[${name~}]"
        LGUI2:RemoveBinding["${name~}"]
        Hotkeys:Remove["${name~}"]
    }

    method UninstallHotkeys()
    {
        echo UninstallHotkeys
        Hotkeys:ForEach["This:UninstallHotkeyEx[\"\${ForEach.Value~}\"]"]
    }

    method OnHotkeyState(string name, bool newState)
    {
        echo "OnHotkeyState[${name.AsJSON~},${newState}]"

        variable jsonvalueref joMapping
        joMapping:SetReference["This.InputMappings.Get[\"${name~}\"]"]

        if ${joMapping.Reference(exists)}
            This:ExecuteInputMapping[joMapping,${newState}]
        else
        {
            echo "Hotkey ${name~} NOT mapped"
        }
    }

    method ExecuteInputMappingByName(string name, bool newState)
    {
        variable jsonvalueref joMapping
        joMapping:SetReference["This.InputMappings.Get[\"${name~}\"]"]

        if ${joMapping.Reference(exists)}
        {
            return ${This:ExecuteInputMapping[joMapping,${newState}](exists)}
        }
        return FALSE
    }

    method ExecuteHotkeyByName(string sheet, string name, bool newState)
    {
        variable jsonvalueref joHotkey
        joHotkey:SetReference["HotkeySheets.Get[${sheet.AsJSON~}].Hotkeys.Get[${name.AsJSON~}]"]
        
        This:ExecuteInputMapping["joHotkey.Get[inputMapping]",${newState}]
    }

    method ExecuteMappableByName(string sheet, string name, bool newState)
    {
        variable jsonvalueref joMappable
        joMappable:SetReference["MappableSheets.Get[${sheet.AsJSON~}].Mappables.Get[${name.AsJSON~}]"]
        
        This:ExecuteMappable["joMappable",${newState}]
    }

    method ExecuteGameKeyBindingByName(string name, bool newState)
    {

    }

    method ExecuteTriggerByName(string name, bool newState)
    {

    }

    method ExecuteTrigger(jsonvalueref joTrigger, bool newState)
    {
        This:ExecuteActionList[joTrigger,"joTrigger.Get[actions]",${newState}]
    }

    method ExecuteMappable(jsonvalueref joMappable, bool newState)
    {
        ; get current step, then call This:ExecuteRotatorStep
        echo "ExecuteMappable[${newState}] ${joMappable~}"
        ; for now, just assume the first step
        This:ExecuteRotatorStep[joMappable,"joMappable.Get[steps,1]",${newState}]
    }

    method ExecuteRotatorStep(jsonvalueref joRotator, jsonvalueref joStep, bool newState)
    {
        echo "ExecuteRotatorStep[${newState}] ${joStep~}"
        This:ExecuteActionList[joStep,"joStep.Get[actions]",${newState}]
    }

    method ExecuteActionList(jsonvalueref joState, jsonvalueref jaList, bool newState)
    {
        echo "ExecuteActionList[${newState}] ${jaList~}"
        jaList:ForEach["ISB2022.Actions:ExecuteAction[joState,ForEach.Value,${newState}]"]
    }

    method ExecuteInputMapping(jsonvalueref joMapping, bool newState)
    {
        echo "ExecuteInputMapping[${newState}] ${joMapping~}"

        variable string targetName
        targetName:Set["${joMapping.Get[name]~}"]
        if !${targetName.NotNULLOrEmpty}
            return FALSE

        switch ${joMapping.Get[type]~}
        {
            case mappable                
                return ${This:ExecuteMappableByName["${joMapping.Get[sheet]~}","${targetName~}",${newState}](exists)}
            case inputMapping
                return ${This:ExecuteInputMappingByName["${targetName~}",${newState}](exists)}
            case gameKeyBinding
                return ${This:ExecuteGameKeyBindingByName["${targetName~}",${newState}](exists)}
            case hotkey
                return ${This:ExecuteHotkeyByName["${joMapping.Get[sheet]~}","${targetName~}",${newState}](exists)}
            case trigger
                return ${This:ExecuteTriggerByName["${targetName~}",${newState}](exists)}
        }

        return FALSE
    }
}
