/* isb2022_profileengine: 
    An active ISBoxer 2022 Profile collection
*/
objectdef isb2022_profileengine
{
    ; a list of active Profiles
    variable set Profiles

    ; a list of active Hotkeys
    variable set Hotkeys

    ; a distributed scope which shares data with the Team
    variable weakref TeamScope

    variable collection:isb2022_hotkeysheet HotkeySheets
    variable collection:isb2022_mappablesheet MappableSheets
    variable collection:isb2022_regionsheet RegionSheets
    variable collection:isb2022_gamemacrosheet GameMacroSheets
    variable collection:isb2022_vfxsheet VFXSheets
    variable collection:isb2022_triggerchain TriggerChains
    variable collection:isb2022_clickbar ClickBars

    variable jsonvalue InputMappings="{}"
    variable jsonvalue GameKeyBindings="{}"
    variable jsonvalue ActionTypes="{}"

    variable jsonvalue Characters="{}"
    variable jsonvalue Teams="{}"
    variable jsonvalue WindowLayouts="{}"

    variable jsonvalueref Character
    variable jsonvalueref Team
    variable jsonvalueref SlotRef
    variable uint Slot

    ; reference to the last hotkey used
    variable jsonvalueref LastHotkey
    ; reference to the last mappable executed
    variable jsonvalueref LastMappable

    ; task manager used for hotkeys and such
    variable taskmanager TaskManager=${LMAC.NewTaskManager["profileEngine"]}

    method Initialize()
    {
    }

    method Shutdown()
    {
        This:UninstallVFXs
        This:UninstallHotkeys
        TaskManager:Destroy
    }

    method InstallDefaultActionTypes()
    {
;        Actions.ActionObject:Set["${actionObject~}"]
;        Actions:InstallActionType["Keystroke","Action_Keystroke"]

        variable jsonvalue ja
        ja:SetValue["$$>[
            {
                "name":"keystroke",
                "handler":"Action_Keystroke",
                "retarget":true
            },
            {
                "name":"game key binding",
                "handler":"Action_GameKeyBinding",
                "retarget":true,
                "variableProperties":["name"]
            },
            {
                "name":"game macro",
                "handler":"Action_GameMacro",
                "retarget":true,
                "variableProperties":["name","sheet"]
            }
            {
                "name":"keystring",
                "handler":"Action_KeyString",
                "retarget":true,
                "activationState":true
                "variableProperties":["text"]
            },
            {
                "name":"target group",
                "handler":"Action_TargetGroup",
                "retarget":true,
                "activationState":true
                "variableProperties":["name"]
            },
            {
                "name":"sync cursor",
                "handler":"Action_SyncCursor",
                "activationState":true
            },
            {
                "name":"set game key binding",
                "handler":"Action_SetGameKeyBinding",
                "variableProperties":["name"],
                "activationState":true,
                "retarget":true
            },
            {
                "name":"hotkey sheet state",
                "handler":"Action_HotkeySheetState",
                "variableProperties":["name"],
                "activationState":true,
                "retarget":true
            },
            {
                "name":"vfx sheet state",
                "handler":"Action_VFXSheetState",
                "variableProperties":["name"],
                "activationState":true,
                "retarget":true
            },
            {
                "name":"window focus",
                "handler":"Action_WindowFocus",
                "activationState":true,
                "variableProperties":["window","computer","filterTarget"]
            },
            {
                "name":"window close",
                "handler":"Action_WindowClose",
                "activationState":true,
                "retarget":true
            },
            {
                "name":"mappable",
                "handler":"Action_Mappable",
                "variableProperties":["name","sheet"],
                "retarget":true
            },
            {
                "name":"input mapping",
                "handler":"Action_InputMapping",
                "variableProperties":["name"],
                "retarget":true
            },
            {
                "name":"set input mapping",
                "handler":"Action_SetInputMapping",
                "variableProperties":["name"],
                "activationState":true,
                "retarget":true
            },
            {
                "name":"mappable step",
                "handler":"Action_MappableStep",
                "variableProperties":["name","sheet"],
                "activationState":true,
                "retarget":true
            },
            {
                "name":"mappable step state",
                "handler":"Action_MappableStepState",
                "variableProperties":["name","sheet"],
                "activationState":true,
                "retarget":true
            },
            {
                "name":"mappable state",
                "handler":"Action_MappableState",
                "variableProperties":["name","sheet"],
                "activationState":true,
                "retarget":true
            },
            {
                "name":"mappable sheet state",
                "handler":"Action_MappableSheetState",
                "variableProperties":["name"],
                "activationState":true,
                "retarget":true
            },
            {
                "name":"virtualize mappable",
                "handler":"Action_MappableSheetState",
                "variableProperties":["fromSheet","toSheet","fromName","toName"],
                "activationState":true,
                "retarget":true
            },
            {
                "name":"click bar state",
                "handler":"Action_ClickBarState",
                "variableProperties":["name"],
                "activationState":true,
                "retarget":true
            },
            {
                "name":"set click bar button",
                "handler":"Action_SetClickBarButton",
                "variableProperties":["name"],
                "activationState":true,
                "retarget":true
            },
            {
                "name":"add trigger",
                "handler":"Action_AddTrigger",
                "variableProperties":["name"],
                "activationState":true,
                "retarget":true
            },
            {
                "name":"remove trigger",
                "handler":"Action_RemoveTrigger",
                "variableProperties":["name"],
                "activationState":true,
                "retarget":true
            },
            {
                "name":"broadcasting target",
                "handler":"Action_BroadcastingTarget",
                "variableProperties":["value"],
                "activationState":true,
                "retarget":true
            },
            {
                "name":"broadcasting list",
                "handler":"Action_BroadcastingList",
                "activationState":true,
                "retarget":true
            }
        ]<$$"]

;        echo "InstallDefaultActionTypes ${ja~}"
        This:InstallActionTypes[ja]
    }

    member:uint GetCharacterSlot(string name)
    {
        variable jsonvalueref jaSlots="Team.Get[slots]"
        if !${jaSlots.Type.Equal[array]}
            return 0
        
        variable uint i
        for (i:Set[1] ; ${i}<=${jaSlots.Used} ; i:Inc )
        {
            if ${jaSlots.Assert[${i},character,"${name.AsJSON~}"]}
            {
                return ${i}
            }
        }

        return 0
    }

    method InstallActionTypes(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallActionType[ForEach.Value]"]
    }

    method InstallActionType(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        ; echo InstallActionType: ActionTypes:SetByRef["${jo.Get[name].Lower~}",jo] 
        ActionTypes:SetByRef["${jo.Get[name].Lower~}",jo]
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

        echo "TODO: InstallProfile"
    }

    method InstallTrigger(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        variable string name
        name:Set["${jo.Get[name]~}"]

        if !${TriggerChains.Get["${name~}"](exists)}
        {
            TriggerChains:Set["${name~}","${name~}"]
        }

        TriggerChains.Get["${name~}"]:AddHandler[jo]
    }

    method InstallTriggers(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallTrigger[ForEach.Value]"]
    }    

    method UninstallTrigger(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        variable string name
        name:Set["${jo.Get[name]~}"]

        if !${TriggerChains.Get["${name~}"](exists)}
        {
            return
        }

        TriggerChains.Get["${name~}"]:RemoveHandler[jo]
    }

    method UninstallTriggers(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:UninstallTrigger[ForEach.Value]"]
    }    

    method InstallTeam(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

;        echo InstallTeam: Teams:SetByRef["${jo.Get[name]~}",jo] 
        Teams:SetByRef["${jo.Get[name]~}",jo]
    }

    method InstallTeams(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallTeam[ForEach.Value]"]
    }    

    method UninstallTeams(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:UninstallTeam[ForEach.Value]"]
    }    

    method InstallCharacter(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

;        echo InstallCharacter: Characters:SetByRef["${jo.Get[name]~}",jo] 
        Characters:SetByRef["${jo.Get[name]~}",jo]
    }

    method InstallCharacters(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallCharacter[ForEach.Value]"]
    }    

    method UninstallCharacters(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:UninstallCharacter[ForEach.Value]"]
    }    

    method InstallClickBar(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        variable string name
        name:Set["${jo.Get[name]~}"]

        ClickBars:Erase["${name~}"]

        ClickBars:Set["${name~}",jo]
    }

    method InstallClickBars(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallClickBar[ForEach.Value]"]
    }    

    
    method UninstallClickBar(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        variable string name
        name:Set["${jo.Get[name]~}"]

        ClickBars:Erase["${name~}"]
    }

    method UninstallClickBars(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:UninstallClickBar[ForEach.Value]"]
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

    method InstallHotkeySheets(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallHotkeySheet[ForEach.Value]"]
    }

    method UninstallHotkeySheet(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        variable string name
        name:Set["${jo.Get[name]~}"]

        HotkeySheets:Erase["${name~}"]
    }

    method UninstallHotkeySheets(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:UninstallHotkeySheet[ForEach.Value]"]
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

    method InstallMappableSheets(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallMappableSheet[ForEach.Value]"]
    }

    method UninstallMappableSheet(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        variable string name
        name:Set["${jo.Get[name]~}"]

        MappableSheets:Erase["${name~}"]
    }

    method UninstallMappableSheets(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:UninstallMappableSheet[ForEach.Value]"]
    }

    method InstallGameKeyBinding(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        GameKeyBindings:SetByRef["${jo.Get[name].Lower~}",jo]
    }
    method InstallGameKeyBindings(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallGameKeyBinding[ForEach.Value]"]
    }

    method UninstallGameKeyBinding(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        GameKeyBindings:Erase["${jo.Get[name].Lower~}"]
    }
    method UninstallGameKeyBindings(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:UninstallGameKeyBinding[ForEach.Value]"]
    }

    method InstallKeyLayouts(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallKeyLayout[ForEach.Value]"]
    }

    method UninstallKeyLayouts(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:UninstallKeyLayout[ForEach.Value]"]
    }

    method InstallProfiles(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallProfile[ForEach.Value]"]
    }    

    method UninstallProfiles(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:UninstallProfile[ForEach.Value]"]
    }    

    method InstallVirtualFiles(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallVirtualFile[ForEach.Value]"]
    }

    method UninstallVirtualFiles(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:UninstallVirtualFile[ForEach.Value]"]
    }

    method InstallWindowLayout(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

;        echo InstallWindowLayout: WindowLayouts:SetByRef["${jo.Get[name]~}",jo] 
        WindowLayouts:SetByRef["${jo.Get[name]~}",jo]
    }

    method InstallWindowLayouts(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallWindowLayout[ForEach.Value]"]
    }

    method UninstallWindowLayouts(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:UninstallWindowLayout[ForEach.Value]"]
    }

    method InstallVFXSheet(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        VFXSheets:Erase["${name~}"]

        VFXSheets:Set["${name~}",jo]
    }

    method InstallVFXSheets(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallVFXSheet[ForEach.Value]"]
    }

    method UninstallVFXSheet(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        VFXSheets:Erase["${name~}"]
    }

    method UninstallVFXSheets(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:UninstallVFXSheet[ForEach.Value]"]
    }    

    method ActivateCharacterByName(string name)
    {
        variable weakref useCharacter="Characters.Get[\"${name~}\"]"
        echo "ActivateCharacterByName ${name} = ${useCharacter.AsJSON~}"
        return "${This:ActivateCharacter[useCharacter](exists)}"
    }

    method ActivateTeamByName(string name)
    {
        variable weakref useTeam="Teams.Get[\"${name~}\"]"
        echo "ActivateTeamByName ${name} = ${useTeam.AsJSON~}"
        return "${This:ActivateTeam[useTeam](exists)}"
    }

    method ActivateWindowLayoutByName(string name)
    {
        variable weakref useLayout="WindowLayouts.Get[\"${name~}\"]"
        echo "ActivateWindowLayoutByName ${name} = ${useLayout.AsJSON~}"
        return "${This:ActivateWindowLayout[useLayout](exists)}"
    }

    method ActivateWindowLayout(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return
        
        echo "TODO: ActivateWindowLayout ${jo~}"
    }

    method DeactivateCharacter()
    {
        if !${Character.Type.Equal[object]}
            return

        Character:SetReference[NULL]
    }

    method ActivateSlot(uint numSlot)
    {
        Slot:Set[${numSlot}]
        SlotRef:SetReference["Team.Get[slots,${numSlot}]"]

        if !${SlotRef.Type.Equal[object]}
            return

        echo "ActivateSlot ${numSlot} = ${SlotRef~}"
        if ${SlotRef.Has[foregroundFPS]}
            maxfps -fg -calculate ${SlotRef.Get[foregroundFPS]}

        if ${SlotRef.Has[backgroundFPS]}
            maxfps -bg -calculate ${SlotRef.Get[backgroundFPS]}

        This:ActivateProfilesByName["SlotRef.Get[profiles]"]
    }

    method ActivateCharacter(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return

        This:DeactivateCharacter
        Character:SetReference[jo]
        This:ActivateSlot["${This.GetCharacterSlot["${Character.Get[name]~}"]}"]
        This:ActivateProfilesByName["Character.Get[profiles]"]

        LGUI2.Element[isb2022.events]:FireEventHandler[onCharacterChanged]
    }

    method DeactivateTeam()
    {
        if !${Team.Type.Equal[object]}
            return

        variable string qualifiedName
        qualifiedName:Set["isb2022team_${Team.Get[name]~}"]
        uplink relaygroup -leave "${qualifiedName~}"

        TeamScope:Remove

        Team:SetReference[NULL]
    }

    method ActivateTeam(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return

        This:DeactivateTeam
        Team:SetReference[jo]

        variable string qualifiedName
        qualifiedName:Set["isb2022team_${Team.Get[name]~}"]
        uplink relaygroup -join "${qualifiedName~}"

        This:ActivateProfilesByName["Team.Get[profiles]"]

        variable jsonvalue dscopeDefinition
        dscopeDefinition:SetValue["$$>
        {
            "name":${qualifiedName.AsJSON},
            "distribution":${qualifiedName.AsJSON},
            "initialValues":{
                "active":true
            }
        }
        <$$"]

        echo TeamScope:SetReference["InnerSpace.AddDistributedScope[\"${dscopeDefinition.AsJSON~}\"]"]
        TeamScope:SetReference["InnerSpace.AddDistributedScope[\"${dscopeDefinition.AsJSON~}\"]"]

        echo "ActivateTeam: TeamScope.active=${TeamScope.GetBool[active]}"

        LGUI2.Element[isb2022.events]:FireEventHandler[onTeamChanged]
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
        This:InstallHotkeySheets[_profile.HotkeySheets]
        This:InstallGameKeyBindings[_profile.GameKeyBindings]
        This:InstallMappableSheets[_profile.MappableSheets]
        This:InstallClickBars[_profile.ClickBars]
        This:InstallVFXSheets[_profile.VFXSheets]

        This:InstallCharacters[_profile.Characters]
        This:InstallTeams[_profile.Teams]

        echo ActivateProfile ${_profile.Name} complete.

        LGUI2.Element[isb2022.events]:FireEventHandler[onProfilesUpdated]
    }

    method DeactivateProfile(weakref _profile)
    {
        if !${_profile.Reference(exists)}
            return

        ; not already activated.
        if !${Profiles.Contains["${_profile.Name~}"]}
            return

        Profiles:Remove["${_profile.Name~}"]

        This:UninstallProfiles[_profile.Profiles]

        This:UninstallVirtualFiles[_profile.VirtualFiles]
        This:UninstallWindowLayouts[_profile.WindowLayouts]
        This:UninstallTriggers[_profile.Triggers]
        This:UninstallHotkeySheets[_profile.HotkeySheets]
        This:UninstallGameKeyBindings[_profile.GameKeyBindings]
        This:UninstallMappableSheets[_profile.MappableSheets]
        This:UninstallClickBars[_profile.ClickBars]
        This:UninstallVFXSheets[_profile.VFXSheets]

        This:UninstallCharacters[_profile.Characters]
        This:UninstallTeams[_profile.Teams]

        LGUI2.Element[isb2022.events]:FireEventHandler[onProfilesUpdated]
    }

    member:string ProcessVariables(string text)
    {
        if !${text.Find["{"]}
            return "${text~}"        

        ; todo ... handle variables!

        if ${ISBoxerSlot(exists)}        
            text:Set["${text.ReplaceSubstring["{SLOT}",${ISBoxerSlot}]}"]
        else
            text:Set["${text.ReplaceSubstring["{SLOT}",1]}"]

        return "${text~}"        
    }



    method TestKeystroke(string key)
    {
        variable jsonvalue joAction="{}"
        joAction:SetString["key","${key~}"]

        This:Action_Keystroke[NULL,joAction,TRUE]
        This:Action_Keystroke[NULL,joAction,FALSE]
    }


    method RemoteAction(jsonvalue joActionState)
    {
        echo "RemoteAction[${joActionState~}]"
        variable jsonvalueref joState="joActionState.Get[state]"
        variable jsonvalueref joAction="joActionState.Get[action]"

        joAction:Erase[target]

        This:ExecuteAction[joState,joAction,${joActionState.GetBool[activate]}]
    }

    method RetargetAction(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        variable string useTarget="${joAction.Get[target]~}"

        if !${useTarget.NotNULLOrEmpty}
            return FALSE

        if ${useTarget.Equal[self]}
            return FALSE

        variable jsonvalue joActionState="{}"
        joActionState:SetByRef[action,joAction]
        joActionState:SetByRef[state,joState]
        joActionState:SetBool[activate,${activate}]

        relay "${useTarget~}" "noop \${ISB2022:RemoteAction[\"${joActionState~}\"]}"
;        echo relay "${useTarget~}" "noop \${ISB2022:RemoteAction[\"${joActionState~}\"]}"
        return TRUE
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

    method Action_GameKeyBinding(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "Action_GameKeyBinding[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        variable string name
        name:Set["${joAction.Get[name]~}"]

        variable jsonvalueref gkb
        gkb:SetReference["This.GameKeyBindings.Get[\"${name.Lower~}\"]"]
        if !${gkb.Reference(exists)}
        {
            echo Game Key Binding ${name~} not found
            return
        }

        variable string keystroke
        keystroke:Set["${gkb.Get[keyCombo]~}"]
        if !${keystroke.NotNULLOrEmpty}
        {
            echo Game Key Binding invalid keystroke
            return
        }

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

    method Action_SetGameKeyBinding(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "Action_SetGameKeyBinding[${activate}] ${joAction~}"

        if !${joAction.Type.Equal[object]}
            return

        variable string name
        name:Set["${joAction.Get[name].Lower~}"]
        if !${name.NotNULLOrEmpty}
            return

        GameKeyBindings.Get["${name~}"]:Set["keyCombo","${joAction.Get[keyCombo].AsJSON~}"]
    }
    
    method Action_ClickBarState(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "Action_ClickBarState[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        variable string name
        name:Set["${joAction.Get[name]~}"]

        switch ${joAction.GetBool[state]}
        {
            case TRUE
                ClickBars.Get["${name~}"]:Enable
                break
            case FALSE
                ClickBars.Get["${name~}"]:Disable
                break
            case NULL
                ClickBars.Get["${name~}"]:Toggle
                break
        }
    }

    method Action_HotkeySheetState(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "Action_HotkeySheetState[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        variable string name
        name:Set["${joAction.Get[name]~}"]

        switch ${joAction.GetBool[state]}
        {
            case TRUE
                HotkeySheets.Get["${name~}"]:Enable
                break
            case FALSE
                HotkeySheets.Get["${name~}"]:Disable
                break
            case NULL
                HotkeySheets.Get["${name~}"]:Toggle
                break
        }
    }

    method Action_VFXSheetState(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "Action_VFXSheetState[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        variable string name
        name:Set["${joAction.Get[name]~}"]

        switch ${joAction.GetBool[state]}
        {
            case TRUE
                VFXSheets.Get["${name~}"]:Enable
                break
            case FALSE
                VFXSheets.Get["${name~}"]:Disable
                break
            case NULL
                VFXSheets.Get["${name~}"]:Toggle
                break
        }
    }

    method Action_WindowFocus(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "Action_WindowFocus[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

    }

    method Action_WindowClose(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "Action_WindowClose[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

    }

    method Action_Mappable(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "Action_Mappable[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        This:ExecuteMappableByName["${joAction.Get[sheet]~}","${joAction.Get[name]~}",${activate}]
    }

    method Action_InputMapping(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "Action_InputMapping[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        This:ExecuteInputMappingByName["${joAction.Get[name]~}",${activate}]
    }

    method Action_SetInputMapping(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "Action_SetInputMapping[${activate}] ${joAction~}"

        if !${joAction.Type.Equal[object]}
            return
        variable string name
        name:Set["${joAction.Get[name]~}"]

        if !${name.NotNULLOrEmpty}
            return

        variable jsonvalueref joMapping
        joMapping:SetReference["joAction.Get[inputMapping]"]

        This:InstallInputMapping["${name~}",joMapping]
    }

    method Action_MappableStep(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "Action_MappableStep[${activate}] ${joAction~}"

        if !${joAction.Type.Equal[object]}
            return

        variable string sheet
        sheet:Set["${joAction.Get[sheet]~}"]

        if !${sheet.NotNULLOrEmpty}
            return

        variable string name
        name:Set["${joAction.Get[name]~}"]

        if !${name.NotNULLOrEmpty}
            return

    
        variable jsonvalueref joMappable
        joMappable:SetReference["MappableSheets.Get[${sheet.AsJSON~}].Mappables.Get[${name.AsJSON~}]"]

        switch ${joAction.Get[action]}
        {
            default
            case Set
                This:Rotator_SetStep[joMappable,${joAction.GetInteger[value]}]
                break
            case Inc
                This:Rotator_IncStep[joMappable,${joAction.GetInteger[value]}]
                break
            case Dec
                This:Rotator_DecStep[joMappable,${joAction.GetInteger[value]}]
                break
        }


/*
        joMappable:SetBool["${joAction.GetBool[value]}"]
        /**/
    }

    method Action_MappableState(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "Action_MappableState[${activate}] ${joAction~}"

        if !${joAction.Type.Equal[object]}
            return

        variable string sheet
        sheet:Set["${joAction.Get[sheet]~}"]

        if !${sheet.NotNULLOrEmpty}
            return

        variable string name
        name:Set["${joAction.Get[name]~}"]

        if !${name.NotNULLOrEmpty}
            return

        variable jsonvalueref joMappable
        joMappable:SetReference["MappableSheets.Get[${sheet.AsJSON~}].Mappables.Get[${name.AsJSON~}]"]

        joMappable:SetBool["${joAction.GetBool[value]}"]
    }

    method InstallInputMapping(string name,jsonvalueref joMapping)
    {
        name:Set["${This.ProcessVariables["${name~}"]~}"]

        echo "InstallInputMapping ${name~}: ${joMapping}"
        InputMappings:SetByRef["${name~}",joMapping]
    }

    method UninstallInputMapping(string name)
    {
        InputMappings:Erase["${name~}"]
    }
    
    method InstallVFX(string sheet, string name, jsonvalueref joVFX)
    {
        echo "InstallVFX ${sheet~} ${name~} ${joVFX~}"

        variable jsonvalue joView
        joView:SetValue["$$>
        {
            "name":"isb2022.vfx.${sheet~}.${name~}",
            "type":"videofeed",
            "x":${joVFX.GetInteger[x]},
            "y":${joVFX.GetInteger[y]},
            "width":${joVFX.GetInteger[width]},
            "height":${joVFX.GetInteger[height]},
            "feedName":${joVFX.Get[feedName]~.AsJSON~}
        }
        <$$"]

        joVFX:SetInteger["elementID",${LGUI2.LoadReference[joView,joVFX].ID}]        
    }

    method UninstallVFX(string sheet, string name, jsonvalueref joVFX)
    {
        echo "UninnstallVFX ${sheet~} ${name~} ${joVFX~}"
        LGUI2.Element["isb2022.vfx.${sheet~}.${name~}"]:Destroy

        joVFX:SetInteger["elementID",0]
    }
    
    method InstallHotkey(string sheet, string name, jsonvalueref joHotkey)
    {
        name:Set["${This.ProcessVariables["${name~}"]~}"]
        sheet:Set["${This.ProcessVariables["${sheet~}"]~}"]

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
        name:Set["${This.ProcessVariables["${name~}"]~}"]

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

    method UninstallVFXs()
    {
        VFXSheets:ForEach["ForEach.Value:Disable"]
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
        name:Set["${This.ProcessVariables["${name~}"]~}"]

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
        name:Set["${This.ProcessVariables["${name~}"]~}"]
        sheet:Set["${This.ProcessVariables["${sheet~}"]~}"]

        variable jsonvalueref joHotkey
        joHotkey:SetReference["HotkeySheets.Get[${sheet.AsJSON~}].Hotkeys.Get[${name.AsJSON~}]"]

        This:ExecuteHotkey[joHotkey,${newState}]
    }

    method ExecuteHotkey(jsonvalueref joHotkey, bool newState)
    {
        if !${newState}
        {
            This:IncrementCounter[joHotkey]
        }

        This:ExecuteInputMapping["joHotkey.Get[inputMapping]",${newState}]
    }

    method ExecuteMappableByName(string sheet, string name, bool newState)
    {
        name:Set["${This.ProcessVariables["${name~}"]~}"]
        sheet:Set["${This.ProcessVariables["${sheet~}"]~}"]

        variable jsonvalueref joMappable
        joMappable:SetReference["MappableSheets.Get[${sheet.AsJSON~}].Mappables.Get[${name.AsJSON~}]"]
        
        This:ExecuteMappable["joMappable",${newState}]
    }

    method ExecuteGameKeyBindingByName(string name, bool newState)
    {
        name:Set["${This.ProcessVariables["${name~}"]~}"]

        variable jsonvalueref joGameKeyBinding
        joGameKeyBinding:SetReference["GameKeyBindings.Get[${name.AsJSON~}]"]
        
        This:ExecuteGameKeyBinding["joGameKeyBinding",${newState}]
    }

    method ExecuteGameKeyBinding(jsonvalueref joGameKeyBinding, bool newState)
    {
        if !${joGameKeyBinding.Type.Equal[object]}
            return

        variable string keystroke
        keystroke:Set["${joGameKeyBinding.Get[key]~}"]
        if !${keystroke.NotNULLOrEmpty}
            return

        if ${newState}
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

    method ExecuteTriggerByName(string name, bool newState)
    {
        name:Set["${This.ProcessVariables["${name~}"]~}"]

        TriggerChains.Get["${name}"].Handlers:ForEach["This:ExecuteTrigger[ForEach.Value,${newState}]"]
    }

    method ExecuteTrigger(jsonvalueref joTrigger, bool newState)
    {
        if !${joTrigger.Type.Equal[object]}
            return
        This:ExecuteInputMapping["joTrigger.Get[inputMapping]",${newState}]
    }

    method ExecuteMappable(jsonvalueref joMappable, bool newState)
    {
        if !${joMappable.Type.Equal[object]}
            return

        echo "ExecuteMappable[${newState}] ${joMappable~}"

        ; make sure it's not disabled. to be disabled requires "enable":false
        if ${joMappable.GetBool[enable].Equal[FALSE]}
            return

        ; get current step, then call This:ExecuteRotatorStep
        if !${newState}
        {
            This:IncrementCounter[joMappable]
        }

        variable int numStep=1
        This:Rotator_PreExecute[joMappable,${newState}]

        numStep:Set[${This.Rotator_GetCurrentStep[joMappable]}]
        if ${numStep}>0
        {
            This:ExecuteRotatorStep[joMappable,"joMappable.Get[steps,${numStep}]",${newState}]
            This:Rotator_PostExecute[joMappable,${newState},${numStep}]
        }

        LastMappable:SetReference[joMappable]
    }

    ; for any Rotator object, gets the current `step` value (or 1 by default)
    member:int Rotator_GetCurrentStep(jsonvalueref joRotator)
    {
        variable int numStep
        numStep:Set[${joRotator.GetInteger[step]}]
        if !${numStep}
            return 1
        return ${numStep}
    }    

    method Rotator_SetStep(jsonvalueref joRotator, int numStep)
    {
        variable int totalSteps = ${joRotator.Get[steps].Used}

        if ${numStep}<1
			numStep:Set[1]
			
		if ${This.Rotator_GetCurrentStep[joRotator]}==1
            joRotator:SetInteger[firstAdvance,${Script.RunningTime}]
		
        ; increment step counter
        This:Rotator_IncrementStepCounter[joRotator,${numStep}]


		numStep:Set[ ((${numStep}-1) % ${totalSteps}) + 1 ]
			
        joRotator:SetInteger[step,${numStep}]

        joRotator:SetInteger["stepTriggered",0]

		if ${newState}
		{
            joRotator:SetInteger[stepTime,${Script.RunningTime}]
		}
		else
		{
            joRotator:SetInteger[stepTime,0]
		}
    }

    method Rotator_IncStep(jsonvalueref joRotator, int value)
    {
        variable int totalSteps = ${joRotator.Get[steps].Used}
        if ${totalSteps}==0
            return

        if ${value}==0
			value:Set[1]            

        variable int numStep
        numStep:Set[${This.Rotator_GetCurrentStep[joRotator]}]			
		if ${numStep}==1
            joRotator:SetInteger[firstAdvance,${Script.RunningTime}]
		
        ; increment step counter
        This:Rotator_IncrementStepCounter[joRotator,${numStep}]

        numStep:Set[ ((${numStep}-1 + ${value} ) % ${totalSteps}) + 1 ]
        while ${numStep} < 1
        {
            numStep:Inc[${totalSteps}]
        }
			
        joRotator:SetInteger[step,${numStep}]

        joRotator:SetInteger["stepTriggered",0]

		if ${newState}
		{
            joRotator:SetInteger[stepTime,${Script.RunningTime}]
		}
		else
		{
            joRotator:SetInteger[stepTime,0]
		}
    }

    method Rotator_DecStep(jsonvalueref joRotator, int value)
    {
        value:Set[-1*${value}]
        This:Rotator_IncStep[joRotator,${value}]
    }

    ; for any Rotator object, determines if the given step number is enabled
    member:bool Rotator_IsStepEnabled(jsonvalueref joRotator, int numStep)
    {
        switch ${joRotator.GetBool[steps,${numStep},enable]}
        {
        case NULL
        case TRUE
            return TRUE
        case FALSE
            return FALSE
        default
            echo "Rotator_IsStepEnabled unexpected value ${joRotator.GetBool[steps,${numStep},enable]}"
            break
        }
        return FALSE
    }

    ; for any Rotator object, gets the next step to advance to (from a given step number)
    member:int Rotator_GetNextStep(jsonvalueref joRotator, int fromStep)
    {
        variable int totalSteps = ${joRotator.Get[steps].Used}
        variable int nextStep=${fromStep.Inc}
        if ${totalSteps}<=1
            return 1

        while 1
        {
            if ${nextStep} > ${totalSteps}
                nextStep:Set[1]

            if ${nextStep} == ${fromStep}
                return ${fromStep}

            switch ${joRotator.GetBool[steps,${nextStep},enable]}
            {
            case NULL
            case TRUE
                return ${nextStep}
            case FALSE
                break
            default
                echo "Rotator_GetNextStep unexpected value ${joRotator.GetBool[steps,${nextStep},enable]}"
                break
            }

            nextStep:Inc
        }
    }

    ; for any object, increments `counter` and sets `counterTime` to the current script running time
    method IncrementCounter(jsonvalueref joCountable)
    {
        variable int counter=${joCountable.GetInteger[counter]}
        counter:Inc
        joCountable:SetInteger[counter,${counter}]
        joCountable:SetInteger[counterTime,${Script.RunningTime}]
    }

    ; for any Rotator object, increments the step counter for a specified step
    method Rotator_IncrementStepCounter(jsonvalueref joRotator,int numStep)
    {
        This:IncrementCounter["joRotator.Get[steps,${numStep}]"]
    }

    ; for any Rotator object, attempts to advance to the next Step depending on the press/release state
    method Rotator_Advance(jsonvalueref joRotator,bool newState)
    {
        variable int numStep = ${This.Rotator_GetCurrentStep[joRotator]}
        variable int fromStep
        variable int stepCounter

        echo Rotator_Advance ${newState}

        fromStep:Set[${numStep}]

        if ${numStep}==1
            joRotator:SetInteger[firstAdvance,${Script.RunningTime}]

        ; increment step counter
        This:Rotator_IncrementStepCounter[joRotator,${numStep}]
        
		numStep:Inc
		while 1
		{
			if ${numStep}>${joRotator.Get[steps].Used}
			{
				numStep:Set[1]

				if ${newState}
				{
                    joRotator:SetInteger[firstPress,${Script.RunningTime}]
				}
				else
				{
                    joRotator:SetInteger[firstPress,0]
				}
			}

            ; stop rotating in 3 possible ways...
            ; 1. we went through ALL the other steps and arrived back at this one
            ; 2. this is a release and not a press
            ; 3. the step we land on is actually enabled

			if ${numStep}==${fromStep}
				break

			if !${newState} || ${This.Rotator_IsStepEnabled[joRotator,${numStep}]}
			{
				break
			}

			numStep:Inc
		}

        joRotator:SetInteger[step,${numStep}]

        joRotator:SetInteger["stepTriggered",0]

		if ${newState}
		{
            joRotator:SetInteger[stepTime,${Script.RunningTime}]
		}
		else
		{
            joRotator:SetInteger[stepTime,0]
		}
    }

    ; for any Rotator object, perform pre-execution mechanics, depending on press/release state
    method Rotator_PreExecute(jsonvalueref joRotator,bool newState)
    {
        variable int numStep = ${This.Rotator_GetCurrentStep[joRotator]}
        variable int timeNow=${Script.RunningTime}
        variable float stickyTime

        if ${newState}
        {
            stickyTime:Set[${joRotator.GetNumber[step,${numStep},stickyTime]}]
            if ${stickyTime}
            {
                if !${joRotator.GetInteger[stepTime]}
                    joRotator:SetInteger[stepTime,${timeNow}]
                /* Pre-press advance check */
                if ${stickyTime}>0 && ${timeNow}>=(${stickyTime}*1000)+${jo.GetInteger[stepTime]}
                {
                    This:Rotator_Advance[joRotator,1]
                }
            }

            if !${joRotator.GetInteger[firstPress]}
            {
                joRotator:SetInteger[firstPress,${timeNow}]
                joRotator:SetInteger[stepTime,${timeNow}]
            }
            if ${numStep}>1
            {                
                /* Pre-press reset check */
                switch ${joRotator.Get[resetType]~}
                {
                case firstPress
                    if ${timeNow}>=(${joRotator.GetNumber[resetTimer]}*1000)+${joRotator.GetInteger[firstPress]}
                    {
    ;						echo \agFromFirstPress ${timeNow}>=${ResetTimer}+${FirstPress}
                        This:Rotator_Reset[joRotator]
                    }
    ;					else
    ;						echo \ayFromFirstPress ${timeNow}<${ResetTimer}+${FirstPress}
                    break
                case firstAdvance
    ;					echo FromFirstAdvance checking ${timeNow}>=${ResetTimer}+${FirstAdvance}
    ;					if ${timeNow}>=${ResetTimer}+${CurrentStepTimestamp}
                    if ${timeNow}>=(${joRotator.GetNumber[resetTimer]}*1000)+${joRotator.GetInteger[firstAdvance]}
                        This:Rotator_Reset[joRotator]
                    break
                case lastPress
                    if ${timeNow}>=(${joRotator.GetNumber[resetTimer]}*1000)+${joRotator.GetInteger[lastPress]}
                        This:Rotator_Reset[joRotator]
                    break
                }

            }		
            
            joRotator:SetInteger[lastPress,${timeNow}]
        }

        if !${This.Rotator_IsStepEnabled[joRotator,${numStep}]}
		{
;            echo Rotator_PreExecute calling Rotator_Advance[0] due to step ${numStep} disabled
			This:Rotator_Advance[joRotator,${newState}]
            if !${This.Rotator_IsStepEnabled[joRotator,${numStep}]}
			{
				return FALSE
			}
		}

        return TRUE
    }

    ; for any Rotator object, perform post-execution mechanics, depending on press/release state
    method Rotator_PostExecute(jsonvalueref joRotator,bool newState, int executedStep)
    {

; call advance if ALL of these conditions are met....
; 1. newState == FALSE
; 2. has not already advanced (current step == executed step)
; 3. current step is NOT sticky

        if ${newState}
            return
        
        variable int numStep
        numStep:Set[${This.Rotator_GetCurrentStep[joRotator]}]

        if ${numStep}!=${executedStep}
            return

        ; is step sticky?
        if ${joRotator.GetNumber[steps,${numStep},stickyTime]}>0
            return

;        echo Rotator_PostExecute calling Rotator_Advance
        This:Rotator_Advance[joRotator,0]
    }

    ; for any Rotator object, reset to the first step (often due to auto-reset mechanics)
    method Rotator_Reset(jsonvalueref joRotator)
    {
        variable int numStep = ${This.Rotator_GetCurrentStep[joRotator]}
        variable int timeNow=${Script.RunningTime}

        This:Rotator_IncrementStepCounter[joRotator,${numStep}]
        joRotator:SetInteger[firstPress,${timeNew}]
        joRotator:SetInteger[step,1]
        joRotator:SetInteger[stepTriggered,0]
		joRotator:SetInteger[stepTime,${timeNew}]
    }

    ; for any Rotate object, execute a given step, depending on press/release state
    method ExecuteRotatorStep(jsonvalueref joRotator, jsonvalueref joStep, bool newState)
    {
        if !${joRotator.Type.Equal[object]}
            return
        if !${joStep.Type.Equal[object]}
            return

        echo "ExecuteRotatorStep[${newState}] ${joStep~}"

        ; if the step is disabled, don't execute it.
        if ${joStep.GetBool[enable].Equal[FALSE]}
            return

        if ${newState}
        {
            if ${jo.GetInteger[stepTriggered]}<1
            {
                ; safe to execute, but mark as triggered
                joRotator:SetInteger["stepTriggered",1]    
            }
            else
            {
                if ${joStep.GetBool[triggerOnce]}
                    return
            }
        }
        else
        {
            if ${jo.GetInteger[stepTriggered]}<2
            {
                ; safe to execute, but mark as triggered
                joRotator:SetInteger["stepTriggered",2]    
            }
            else
            {
                if ${joStep.GetBool[triggerOnce]}
                    return
            }
        }
        
        This:ExecuteActionList[joStep,"joStep.Get[actions]",${newState}]        
    }

    ; for any Action List, execute all actions depending on press/release state
    method ExecuteActionList(jsonvalueref joState, jsonvalueref jaList, bool newState)
    {
        if !${jaList.Type.Equal[array]}
            return

        echo "ExecuteActionList[${newState}] ${jaList~}"
        jaList:ForEach["This:ExecuteAction[joState,ForEach.Value,${newState}]"]
    }

    ; for any object, process variables within a specific property 
    method ProcessVariableProperty(jsonvalueref jo, string varName)
    {
;        echo "ProcessVariableProperty[${varName~}] ${jo~}"
        if !${jo.Has["${varName~}"]}
            return

        jo:SetString["${varName~}","${This.ProcessVariables["${jo.Get["${varName~}"]~}"]~}"]        
    }

    ; for any Action object of a given action type, process its variableProperties
    method ProcessActionVariables(jsonvalueref joActionType, jsonvalueref joAction)
    {
        if !${joActionType.Get[variableProperties].Type.Equal[array]}
            return

        joActionType.Get[variableProperties]:ForEach["This:ProcessVariableProperty[joAction,\"\${ForEach.Value~}\"]"]
    }

    member:bool ShouldExecuteAction(jsonvalueref joState, jsonvalueref joActionType, jsonvalueref joAction, bool activate)
    {
        ; action-specific activationState
        if ${joAction.Has[activationState]}
        {
            return ${activate.Equal[${joAction.GetBool[activationState]}]}
        }

        ; action type-specific activationState
        if ${joActionType.Has[activationState]}
        {
            return ${activate.Equal[${joActionType.GetBool[activationState]}]}
        }
        
        return TRUE
    }
    
    method ExecuteAction(jsonvalueref joState, jsonvalueref _joAction, bool activate)
    {
        ; ensure we have a valid json object representing the action
        if !${_joAction.Type.Equal[object]}
            return

        variable string actionType = "${_joAction.Get[type].Lower~}"
        variable jsonvalueref joActionType = "ActionTypes.Get[\"${actionType~}\"]"

        ; check activationState settings to make sure we should execute the action here
        if !${This.ShouldExecuteAction[joState,joActionType,_joAction,${activate}]}
            return

        variable jsonvalue joAction
        joAction:SetValue["${_joAction~}"]
        
        ; process any variableProperties
        This:ProcessActionVariables[joActionType,joAction]

        ; see if the action type supports retargeting 
        if ${joActionType.GetBool[retarget]}
        {
            ; yeah see if we should retarget the action
            if ${This:RetargetAction[joState,joAction,${activate}](exists)}
                return
            ; we didn't retarget the action, execute it here
        }
        
        variable string actionMethod
        actionMethod:Set["${joActionType.Get[handler]~}"]
   
        echo "ExecuteAction[${actionType~}]=${actionMethod~}"
        if ${actionMethod.NotNULLOrEmpty}
        {
            execute "This:${actionMethod}[joState,joAction,${activate}]"
        }
    }

    method ExecuteInputMapping(jsonvalueref joMapping, bool newState)
    {
        echo "ExecuteInputMapping[${newState}] ${joMapping~}"

        variable string targetName

        switch ${joMapping.Get[type]~}
        {
            case mappable                
                targetName:Set["${joMapping.Get[name]~}"]
                if !${targetName.NotNULLOrEmpty}
                    return FALSE
                return ${This:ExecuteMappableByName["${joMapping.Get[sheet]~}","${targetName~}",${newState}](exists)}
            case inputMapping
                targetName:Set["${joMapping.Get[name]~}"]
                if !${targetName.NotNULLOrEmpty}
                    return FALSE
                return ${This:ExecuteInputMappingByName["${targetName~}",${newState}](exists)}
            case gameKeyBinding
                targetName:Set["${joMapping.Get[name]~}"]
                if !${targetName.NotNULLOrEmpty}
                    return FALSE
                return ${This:ExecuteGameKeyBindingByName["${targetName~}",${newState}](exists)}
            case hotkey
                targetName:Set["${joMapping.Get[name]~}"]
                if !${targetName.NotNULLOrEmpty}
                    return FALSE
                return ${This:ExecuteHotkeyByName["${joMapping.Get[sheet]~}","${targetName~}",${newState}](exists)}
            case trigger
                targetName:Set["${joMapping.Get[name]~}"]
                if !${targetName.NotNULLOrEmpty}
                    return FALSE
                return ${This:ExecuteTriggerByName["${targetName~}",${newState}](exists)}
            case action
                return ${This:ExecuteAction[joMapping,"joMapping.Get[action]",${newState}](exists)}
            case actions
                return ${This:ExecuteActionList[joMapping,"joMapping.Get[actions]",${newState}](exists)}
        }

        return FALSE
    }
}
