/* isb2_profileengine: 
    An active ISBoxer 2 Profile collection
*/
variable(global) weakref ISB2ProfileEngine
objectdef isb2_profileengine
{    

    ; a list of active Profiles
    variable set Profiles

    ; a list of active Hotkeys
    variable set Hotkeys

    ; a list of active Relay Groups
    variable set RelayGroups

    variable set MappableSheetBlackList
    variable set MappableSheetWhiteList
    variable bool MappableSheetListExclusive

    variable set HotkeySheetBlackList
    variable set HotkeySheetWhiteList
    variable bool HotkeySheetListExclusive

    ; a distributed scope which shares data with the Team
    variable weakref TeamScope

    variable collection:isb2_hotkeysheet HotkeySheets
    variable collection:isb2_mappablesheet MappableSheets
    variable collection:isb2_regionsheet RegionSheets
    variable collection:isb2_gamemacrosheet GameMacroSheets
    variable collection:isb2_vfxsheet VFXSheets
    variable collection:isb2_clickbar ClickBars
    variable collection:isb2_clickbarButtonLayout ClickBarButtonLayouts
    variable collection:isb2_imagesheet ImageSheets
    variable collection:isb2_timerpool TimerPools
    variable collection:isb2_variable Variables

    variable isb2_triggerchains TriggerChains

    variable jsonvalue InputMappings="{}"
    variable jsonvalue GameKeyBindings="{}"
    variable jsonvalue ActionTypes="{}"

    variable jsonvalue Characters="{}"
    variable jsonvalue ClickBarTemplates="{}"
    variable jsonvalue Teams="{}"
    variable jsonvalue WindowLayouts="{}"
    variable jsonvalue BroadcastProfiles="{}"

    variable jsonvalueref Character
    variable jsonvalueref Team
    variable jsonvalueref SlotRef
    variable uint Slot

    variable bool GUIMode=1

    ; reference to the last hotkeys used
    variable jsonvalueref LastHotkeys="[]"
    ; reference to the last mappables executed
    variable jsonvalueref LastMappables="[]"
    ; reference to the last actions executed
    variable jsonvalueref LastActions="[]"

    variable jsonvalueref LastInputs="[]"

    variable jsonvalueref Inputs="{}"

    ; task manager used for hotkeys and such
    variable taskmanager TaskManager=${LMAC.NewTaskManager["profileEngine"]}

    variable anonevent OnSlotActivate

    method Initialize()
    {
        ISB2ProfileEngine:SetReference[This]
    }

    method Shutdown()
    {
        This:DeactivateTeam
        This:DeactivateSlot
        This:DeactivateCharacter
        This:UninstallVFXs
        This:UninstallHotkeys
        This:UninstallRelayGroups
        TaskManager:Destroy
        ISB2ProfileEngine:SetReference[NULL]
    }

    method InstallDefaultVirtualFiles()
    {

		;fileredirect "SavedVariables/Jamba.lua" "SavedVariables/Jamba-ISBoxer.lua"
		fileredirect "Global/DAoCi1" "Global\\DAoCi1-${ISSession.Slot}-${Time.Timestamp}-${Math.Rand[1000]}"
		fileredirect "Global/DAoCi2" "Global\\DAoCi2-${ISSession.Slot}-${Time.Timestamp}-${Math.Rand[1000]}"
		fileredirect "ui.log" "ui.Slot-${ISSession.Slot}.log"

		fileredirect "SwgClientInstanceRunning" "SwgClientInstanceRunning-${ISSession.Slot}-${Time.Timestamp}-${Math.Rand[1000]}"
		fileredirect "AN-Mutex-Window-Guild Wars 2" "AN-Mutex-Window-Guild Wars 2-${ISSession.Slot}-${Time.Timestamp}-${Math.Rand[1000]}"
		fileredirect "AN-Mutex-Window-Guild Wars" "AN-Mutex-Window-Guild Wars-${ISSession.Slot}-${Time.Timestamp}-${Math.Rand[1000]}"
;		fileredirect "AN-Mutex-OsPatch" "AN-Mutex-OsPatch-${ISSession.Slot}"
		fileredirect "wot_client_mutex" "wot_client_mutex-${ISSession.Slot}-${Time.Timestamp}-${Math.Rand[1000]}"
		fileredirect "AionClientLaunchedCounter" "AionClientLaunchedCounter-${ISSession.Slot}-${Time.Timestamp}-${Math.Rand[1000]}"
		
		; fileredirect "gw2.dat" "gw2-ISBoxerSlot${ISSession.Slot}.dat"

		; Star Wars: The Old Republic
		fileredirect "DiskCacheArena" "DiskCacheArena-${ISSession.Slot}"
		fileredirect "DiskCacheStatic" "DiskCacheStatic-${ISSession.Slot}"
		fileredirect "DiskCacheStream" "DiskCacheStream-${ISSession.Slot}"

		fileredirect "Empyrean Client" "Empyrean Client-${ISSession.Slot}"
		fileredirect "Heroes of the Storm IPC Mem" "Heroes of the Storm IPC Mem-${ISSession.Slot}"
		fileredirect "Heroes of the Storm Game Application" "Heroes of the Storm Game Application-${ISSession.Slot}"
		
		fileredirect "DiabloII Check For Other Instances" "DiabloII Check For Other Instances-${ISSession.Slot}"
		fileredirect "Data_D3/PC/MPQs/Cache/" "Data_D3/PC/MPQs/Cache-${ISSession.Slot}/"
		fileredirect "DSOClient/dlcache/" "DSOClient/dlcache-${ISSession.Slot}/"
		fileredirect "Entropia_0" "Entropia_0-${ISSession.Slot}"
		fileredirect "PlanetSide 2.running" "PlanetSide 2.running-${ISSession.Slot}"
		fileredirect "Wizardry Online Beta.running" "Wizardry Online Beta.running-${ISSession.Slot}"
		fileredirect "Wizardry Online.running" "Wizardry Online.running-${ISSession.Slot}"
		fileredirect "Dragon" "Dragon-${ISSession.Slot}"
		fileredirect "Global/Lunia" "Global/Lunia-${ISSession.Slot}"
		fileredirect "Global/6AA83AB5-BAC4-4a36-9F66-A309770760CB_ffxiv_game00" "Global/6AA83AB5-BAC4-4a36-9F66-A309770760CB_ffxiv_game00-${ISSession.Slot}"
		fileredirect "Global/6AA83AB5-BAC4-4a36-9F66-A309770760CB_ffxiv_game01" "Global/6AA83AB5-BAC4-4a36-9F66-A309770760CB_ffxiv_game01-${ISSession.Slot}"
		fileredirect "Global/PoERunMutexA" "Global/PoERunMutexA-${ISSession.Slot}"
		fileredirect "Global/PoERunMutexB" "Global/PoERunMutexB-${ISSession.Slot}"

		fileredirect "Global/Valve_SteamIPC_Class" "Global/Valve_SteamIPC_Class-${ISSession.Slot}"
		fileredirect "Global/SteamInstanceGlobal" "Global/SteamInstanceGlobal-${ISSession.Slot}"
        
        fileredirect "STEAM_DIPC_*" "STEAM_DIPC_{1}-${ISSession.Slot}"
        fileredirect "SREAM_DIPC_*" "SREAM_DIPC_{1}-${ISSession.Slot}"
        fileredirect "STEAM_DRM_IPC" "STEAM_DRM_IPC-${ISSession.Slot}"
        fileredirect "SteamOverlayRunning_*" "SteamOverlayRunning_${ISSession.Slot}_{1}"
        fileredirect "Steam3Master_*" "Steam3Master_${ISSession.Slot}_{1}"

		fileredirect "Software/Valve/Steam/" "Software/Valve/Steam-ISBoxer/Slot${ISSession.Slot}/"
		; config.vdf, SteamAppData.vdf, loginusers.vdf

		; Glyph
		fileredirect "glyphcrashhandler" "glyphcrashhandler-${ISSession.Slot}"

		; Tree of Savior
		fileredirect "/TreeOfSavior/" "/TreeOfSavior-${ISSession.Slot}/"
		fileredirect "tosUpdater$%&%%^@&^*($#" "tosUpdater$%&%%^@&^*($#-${ISSession.Slot}"
		fileredirect "^&(%($$#^@@%$^!Project_R1!@$%^&!#*()#$%^" "^&(%($$#^@@%$^!Project_R1!@$%^&!#*()#$%^-${ISSession.Slot}"

		; The Secret World
		fileredirect lock2.txt lock2-${ISSession.Slot}
;		fileredirect "${System.CurrentDirectory(string)~}/Default/"  "${System.CurrentDirectory(string)~}/Default-${ISSession.Slot}/"

		fileredirect "Allods_Online_Game" "Allods_Online_Game-${ISSession.Slot}"
		fileredirect "wgc_running_games_mtx" "wgc_running_games_mtx-${ISSession.Slot}"
		fileredirect "World of Warships" "World of Warships-${ISSession.Slot}"

		fileredirect "ROBLOX_singletonEvent" "ROBLOX_singletonEvent-${ISSession.Slot}"

		; SWTOR Bitraider
		fileredirect "Local/BRWCExtApp_FM_V1" "Local/BRWCExtApp_FM_V1-${ISSession.Slot}"

		if ${LavishScript.Executable.Find[acclient.exe]} || ${LavishScript.Executable.Find[aclauncher.exe]}
		{
			fileredirect "client_highres.dat" "ISBoxer.Slot${ISSession.Slot}.client_highres.dat"
			fileredirect "client_portal.dat" "ISBoxer.Slot${ISSession.Slot}.client_portal.dat"
			fileredirect "client_local_English.dat" "ISBoxer.Slot${ISSession.Slot}.client_local_English.dat"
			fileredirect "client_cell_1.dat" "ISBoxer.Slot${ISSession.Slot}.client_cell_1.dat"
		}
		if ${LavishScript.Executable.Find[ac2client.exe]} || ${LavishScript.Executable.Find[ac2launcher.exe]}
		{
			fileredirect "highres.dat" "ISBoxer.Slot${ISSession.Slot}.highres.dat"
			fileredirect "portal.dat" "ISBoxer.Slot${ISSession.Slot}.portal.dat"
			fileredirect "cell_1.dat" "ISBoxer.Slot${ISSession.Slot}.cell_1.dat"
			fileredirect "cell_2.dat" "ISBoxer.Slot${ISSession.Slot}.cell_2.dat"
			fileredirect "country.dat" "ISBoxer.Slot${ISSession.Slot}.country.dat"

			fileredirect "local_Chinese.dat" "ISBoxer.Slot${ISSession.Slot}.local_Chinese.dat"
			fileredirect "local_Deutsch.dat" "ISBoxer.Slot${ISSession.Slot}.local_Deutsch.dat"
			fileredirect "local_English.dat" "ISBoxer.Slot${ISSession.Slot}.local_English.dat"
			fileredirect "local_Francais.dat" "ISBoxer.Slot${ISSession.Slot}.local_Francais.dat"
			fileredirect "local_Japanese.dat" "ISBoxer.Slot${ISSession.Slot}.local_Japanese.dat"
			fileredirect "local_Korean.dat" "ISBoxer.Slot${ISSession.Slot}.local_Korean.dat"
		}

		if ${LavishScript.Executable.Find[swtor.exe]}
		{
			fileredirect "Local/" "Local/${ISSession.Slot}::"
		}


		fileredirect "isboxer-binds.txt" "isboxer-${Team.Get[name]~}-${Character.Get[name]~}-binds.txt"
		
		fileredirect "ISBoxer_Character_Set.lua" "ISBoxer_Character_Set-${Team.Get[name]~}.lua"
		fileredirect "ISBoxer_Character.lua" "ISBoxer_Character-${Character.Get[name]~}.lua"

		fileredirect "ISBoxer_2_Team.lua" "ISBoxer_2_Team-${WoWAddon.Sanitize["${Team.Get[name]~}"]~}.lua"
		fileredirect "ISBoxer_2_Character.lua" "ISBoxer_2_Character-${WoWAddon.Sanitize["${Character.Get[name]~}"]~}.lua"

    }

    method InstallDefaultActionTypes()
    {
;        Actions.ActionObject:Set["${actionObject~}"]
;        Actions:InstallActionType["Keystroke","Action_Keystroke"]


        variable jsonvalue ja
        ja:SetValue["${LGUI2.Skin[default].Template[isb2.data].Get[defaultActionTypes]~}"]

;        echo "InstallDefaultActionTypes ${ja~}"
        This:InstallActionTypes[ja]
    }

    member:uint GetCharacterSlot(string name)
    {
        variable jsonvalueref jaSlots="Team.Get[slots]"
        if !${jaSlots.Type.Equal[array]}
            return 0
        
/*
    {
        "eval":"This.Get[character]",
        "op":"==",
        "value":"${name~}"
    }
/**/

        variable jsonvalue joQuery="{}"
        joQuery:SetString[eval,"Select.Get[character]"]
        joQuery:SetString[op,"=="]
        joQuery:SetString[value,"${name~}"]

        return ${jaSlots.SelectKey[joQuery]}
    }

    method ApplyWindowSettings()
    {
        echo "\atisb2_profileengine\ax:ApplyWindowSettings\ax"
        This:InstallSlotActivateHotkeys
        This:AssignCPUCores

        if ${SlotRef.Has[windowTitle]}
            windowtext "${This.ProcessVariables["${SlotRef.Get[windowTitle]~}"]~}"
    }

	method MuteBackground()
	{
		if ${Display.Window.IsForeground}
		{
			Audio:SetMute[0]
		}
		else
		{
			Audio:SetMute[1]
		}
	}

    method Event_OnFrame()
    {
        if ${Team.GetBool[autoMuteBackground]}
            This:MuteBackground
    }

    method Event_OnScriptStopped()
    {
        echo "\atisb2_profileengine\ax:\ayEvent_OnScriptStopped ${Context.Filename~}\ax"
        if ${Context.Filename.Equal[DefaultStartup]}
            This:ApplyWindowSettings    
    }

    method Event_OnWindowCaptured()
    {
        echo "\atisb2_profileengine\ax:\ayEvent_OnWindowCaptured\ax"
        This:ApplyWindowSettings

    }

    ; slot activation hotkey
    method OnSwitchTo(bool isGlobal)
    {
        if ${isGlobal}
        {
            WindowVisibility foreground
            Event[OnInternalActivate]:Execute
            ISSession.OnFocused:Execute[1]
            OnSlotActivate:Execute
            return
        }

        OnSlotActivate:Execute
    }

    member:bool AllowHotkeySheet(string name)
    {
        if ${HotkeySheetWhiteList.Contains["${name~}"]}
            return TRUE
        if ${HotkeySheetBlackList.Contains["${name~}"]}
            return FALSE

        if ${HotkeySheetListExclusive}
            return FALSE
        return TRUE
    }

    member:bool AllowMappableSheet(string name)
    {
        if ${HotkeySheetWhiteList.Contains["${name~}"]}
            return TRUE
        if ${HotkeySheetBlackList.Contains["${name~}"]}
        {
;            echo "AllowMappableSheet[${name~}]: \arBlackListed\ax"
            return FALSE
        }

        if ${HotkeySheetListExclusive}
        {
;            echo "AllowMappableSheet[${name~}]: \rExclusive\ax"
            return FALSE
        }
        return TRUE
    }

#region Object Installers/Uninstallers
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

        if !${This(type).Method["${jo.Get[handler]~}"]}
        {
            echo "\arAction Type Missing Handler:\ax ${jo.Get[handler]~}"
        }
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

        LGUI2.Element[isb2.events]:FireEventHandler[onTriggersUpdated]        
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

        LGUI2.Element[isb2.events]:FireEventHandler[onTeamsUpdated]        
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

        LGUI2.Element[isb2.events]:FireEventHandler[onCharactersUpdated]        
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

        LGUI2.Element[isb2.events]:FireEventHandler[onClickBarsUpdated]        
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

    method InstallMappableSheetList(bool whiteList, jsonvalueref ja)
    {
        if ${whiteList}
        {
            ja:ForEach["MappableSheetWhiteList:Add[\"\${ForEach.Value~}\"]"]            
        }
        else
        {
            ja:ForEach["MappableSheetBlackList:Add[\"\${ForEach.Value~}\"]"]
        }
        ;MappableSheetListExclusive:Set[1]
    }

    method InstallHotkeySheetList(bool whiteList, jsonvalueref ja)
    {
        if ${whiteList}
        {
            ja:ForEach["HotkeySheetWhiteList:Add[\"\${ForEach.Value~}\"]"]            
        }
        else
        {
            ja:ForEach["HotkeySheetBlackList:Add[\"\${ForEach.Value~}\"]"]
        }
        ;HotkeySheetListExclusive:Set[1]
    }

    method InstallHotkeySheet(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        variable string name
        name:Set["${jo.Get[name]~}"]

        HotkeySheets:Erase["${name~}"]

        HotkeySheets:Set["${name~}",jo]

        LGUI2.Element[isb2.events]:FireEventHandler[onHotkeySheetsUpdated]        
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

        LGUI2.Element[isb2.events]:FireEventHandler[onMappableSheetsUpdated]        
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

        LGUI2.Element[isb2.events]:FireEventHandler[onGameKeyBindingsUpdated]        
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

    method InstallImageSheet(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        ImageSheets:Erase["${jo.Get[name]~}"]

        ImageSheets:Set["${jo.Get[name]~}",jo]

        LGUI2.Element[isb2.events]:FireEventHandler[onImageSheetsUpdated]        
    }

    method InstallImageSheets(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallImageSheet[ForEach.Value]"]
    }

    method UninstallImageSheet(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        ImageSheets:Erase["${jo.Get[name]~}"]
    }

    method UninstallImageSheets(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:UninstallImageSheet[ForEach.Value]"]
    }    

    method InstallGameMacroSheet(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        echo "\ayInstallGameMacroSheet\ax ${jo~}"
        GameMacroSheets:Erase["${jo.Get[name]~}"]

        GameMacroSheets:Set["${jo.Get[name]~}",jo]

        LGUI2.Element[isb2.events]:FireEventHandler[onGameMacroSheetsUpdated]        
    }

    method InstallGameMacroSheets(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallGameMacroSheet[ForEach.Value]"]
    }

    method UninstallGameMacroSheet(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        GameMacroSheets:Erase["${jo.Get[name]~}"]
    }

    method UninstallGameMacroSheets(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:UninstallGameMacroSheet[ForEach.Value]"]
    }    


    method InstallTimerPool(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        TimerPools:Erase["${jo.Get[name]~}"]
        TimerPools:Set["${jo.Get[name]~}",jo]

        LGUI2.Element[isb2.events]:FireEventHandler[onTimerPoolsUpdated]        
    }

    method InstallTimerPools(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallTimerPool[ForEach.Value]"]
    }

    method UninstallTimerPool(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        TimerPools:Erase["${jo.Get[name]~}"]
    }

    method UninstallTimerPools(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:UninstallTimerPool[ForEach.Value]"]
    }    


    method InstallVariable(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        if ${Variables.Has["${jo.Get[name]~}"]}
        {
            Variables.Get["${jo.Get[name]~}"]:FromJSON[jo]
            return
        }

        Variables:Set["${jo.Get[name]~}",jo]
        LGUI2.Element[isb2.events]:FireEventHandler[onVariablesUpdated]
    }

    method InstallVariables(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallVariable[ForEach.Value]"]

    }

    method UninstallVariable(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        Variables:Erase["${jo.Get[name]~}"]
        LGUI2.Element[isb2.events]:FireEventHandler[onVariablesUpdated]
    }

    method UninstallVariables(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:UninstallVariable[ForEach.Value]"]
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

    method UninstallVirtualFile(string name)
    {
        VirtualFiles:Erase["${name~}"]
    }


    method InstallBroadcastProfile(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

;        echo InstallBroadcastProfile: BroadcastProfiles:SetByRef["${jo.Get[name]~}",jo] 
        BroadcastProfiles:SetByRef["${jo.Get[name]~}",jo]
        LGUI2.Element[isb2.events]:FireEventHandler[onBroadcastProfilesUpdated]        
    }

    method InstallBroadcastProfiles(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallBroadcastProfile[ForEach.Value]"]
    }

    method UninstallBroadcastProfiles(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:UninstallBroadcastProfile[ForEach.Value]"]
    }

    method UninstallBroadcastProfile(string name)
    {
        BroadcastProfiles:Erase["${name~}"]
    }

    
    method InstallClickBarTemplate(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

;        echo InstallClickBarTemplate: ClickBarTemplates:SetByRef["${jo.Get[name]~}",jo] 
        ClickBarTemplates:SetByRef["${jo.Get[name]~}",jo]

        LGUI2.Element[isb2.events]:FireEventHandler[onClickBarTemplatesUpdated]        
    }

    method InstallClickBarTemplates(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallClickBarTemplate[ForEach.Value]"]
    }

    method UninstallClickBarTemplates(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:UninstallClickBarTemplate[ForEach.Value]"]
    }

    method UninstallClickBarTemplate(string name)
    {
        ClickBarTemplates:Erase["${name~}"]
    }

     method InstallClickBarButtonLayout(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

;        echo "\apInstallClickBarButtonLayout\ax ${jo~}"
        ClickBarButtonLayouts:Erase["${jo.Get[name]~}"]

        ClickBarButtonLayouts:Set["${jo.Get[name]~}",jo]

        LGUI2.Element[isb2.events]:FireEventHandler[onClickBarButtonLayoutsUpdated]        
    }

    method InstallClickBarButtonLayouts(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:InstallClickBarButtonLayout[ForEach.Value]"]
    }

    method UninstallClickBarButtonLayouts(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:UninstallClickBarButtonLayout[ForEach.Value]"]
    }

    method UninstallClickBarButtonLayout(string name)
    {
        ClickBarButtonLayouts:Erase["${name~}"]
    }

    method InstallWindowLayout(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

;        echo InstallWindowLayout: WindowLayouts:SetByRef["${jo.Get[name]~}",jo] 
        WindowLayouts:SetByRef["${jo.Get[name]~}",jo]

        LGUI2.Element[isb2.events]:FireEventHandler[onWindowLayoutsUpdated]        
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

        VFXSheets:Erase["${jo.Get[name]~}"]

        VFXSheets:Set["${jo.Get[name]~}",jo]

        LGUI2.Element[isb2.events]:FireEventHandler[onVFXSheetsUpdated]        
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

        VFXSheets:Erase["${jo.Get[name]~}"]
    }

    method UninstallVFXSheets(jsonvalueref ja)
    {
        if ${ja.Type.Equal[array]}
            ja:ForEach["This:UninstallVFXSheet[ForEach.Value]"]
    }    

     method InstallInputMapping(string name,jsonvalueref joMapping)
    {
        name:Set["${This.ProcessVariables["${name~}"]~}"]

        echo "\agInstallInputMapping\ax ${name~}: ${joMapping}"
        InputMappings:SetByRef["${name~}",joMapping]

        LGUI2.Element[isb2.events]:FireEventHandler[onInputMappingsUpdated]        
    }

    method UninstallInputMapping(string name)
    {
        InputMappings:Erase["${name~}"]
    }
    
    
    method InstallHotkey(string sheet, string name, jsonvalueref joHotkey)
    {
        name:Set["${This.ProcessVariables["${name~}"]~}"]
        sheet:Set["${This.ProcessVariables["${sheet~}"]~}"]

;        echo "\agInstallHotkey\ax[${sheet~},${name~}] ${joHotkey~}"
        variable jsonvalue joBinding
        ; initialize a LGUI2 input binding object with JSON
        variable string fullName="isb2.hks.${sheet~}.${name~}"
        variable string onPress="ISB2:ExecuteHotkeyByName[${sheet.AsJSON~},${name.AsJSON~},1]"
        variable string onRelease="ISB2:ExecuteHotkeyByName[${sheet.AsJSON~},${name.AsJSON~},0]"
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

        LGUI2.Element[isb2.events]:FireEventHandler[onHotkeysUpdated]        
    }

    ; Installs a Hotkey, given a name, a key combination, and LavishScript code to execute
    method InstallHotkeyEx(string name, string keyCombo, string onPress, string onRelease)
    {
        name:Set["${This.ProcessVariables["${name~}"]~}"]

        echo "InstallHotkeyEx ${name~}: ${keyCombo~}"

        if !${onPress.NotNULLOrEmpty} && !${onRelease.NotNULLOrEmpty}
        {
            ; defaults
            onPress:Set["ISB2:OnHotkeyState[${name.AsJSON~},1]"]
            onRelease:Set["ISB2:OnHotkeyState[${name.AsJSON~},0]"]
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

        LGUI2.Element[isb2.events]:FireEventHandler[onHotkeysUpdated]        
    }

    method UninstallHotkey(string sheet, string name)
    {
        variable string fullName="isb2.hks.${sheet~}.${name~}"
        This:UninstallHotkeyEx["${fullName~}"]
    }

    method UninstallHotkeyEx(string name)
    {
;        echo "\agUninstallHotkeyEx\ax[${name~}]"
        LGUI2:RemoveBinding["${name~}"]
        Hotkeys:Remove["${name~}"]
    }

    method UninstallVFXs()
    {
        VFXSheets:ForEach["ForEach.Value:Disable"]
    }

    method UninstallHotkeys()
    {
        echo "\agUninstallHotkeys\ax"
        Hotkeys:ForEach["This:UninstallHotkeyEx[\"\${ForEach.Value~}\"]"]
    }

    method UninstallRelayGroups()
    {
        RelayGroups:ForEach["This:SetRelayGroup[\"${ForEach.Value~}\",0]"]
    }
#endregion

#region Object Activators/Deactivators
    method ActivateCharacterByName(string name)
    {
        variable weakref useCharacter="Characters.Get[\"${name~}\"]"
        echo "\agActivateCharacterByName\ax ${name} = ${useCharacter.AsJSON~}"
        return "${This:ActivateCharacter[useCharacter](exists)}"
    }

    method ActivateTeamByName(string name)
    {
        variable weakref useTeam="Teams.Get[\"${name~}\"]"
        echo "\agActivateTeamByName\ax ${name} = ${useTeam.AsJSON~}"
        return "${This:ActivateTeam[useTeam](exists)}"
    }

    method ActivateBroadcastProfileByName(string name)
    {
        variable weakref useLayout="BroadcastProfiles.Get[\"${name~}\"]"
        echo "\ayActivateBroadcastProfileByName\ax ${name} = ${useLayout.AsJSON~}"
        return "${This:ActivateBroadcastProfile[useLayout](exists)}"
    }

    method ActivateBroadcastProfile(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return
        
        ISB2BroadcastMode:SetBroadcastProfile[jo]
        ; echo "TODO: ActivateBroadcastProfile ${jo~}"
    }

    method ActivateWindowLayoutByName(string name)
    {
        variable weakref useLayout="WindowLayouts.Get[\"${name~}\"]"
        echo "\agActivateWindowLayoutByName\ax ${name} = ${useLayout.AsJSON~}"
        return "${This:ActivateWindowLayout[useLayout](exists)}"
    }

    method ActivateWindowLayout(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return
        
        ISB2WindowLayout:SetLayout[jo]
        ; echo "TODO: ActivateWindowLayout ${jo~}"
    }

    method DeactivateCharacter()
    {
        if !${Character.Type.Equal[object]}
            return

        This:SetRelayGroups["Character.Get[targetGroups]",0]
        This:SetRelayGroup["${Character.Get[name]~}",1]
        Character:SetReference[NULL]
    }

    method InstallSlotActivateHotkey(uint numSlot, jsonvalueref joSlot)
    {
        if ${joSlot.Has[switchToCombo]}
            bind is${numSlot}_key "${joSlot.Get[switchToCombo]~}" "uplink focus is${numSlot};relay is${numSlot} -noredirect ISB2ProfileEngine:OnSwitchTo"
    }

    method InstallSlotActivateHotkeys()
    {
        if !${Team.Type.Equal[object]} || !${Team.Get[slots].Type.Equal[array]}
            return

        Team.Get[slots]:ForEach["This:InstallSlotActivateHotkey[\${ForEach.Key},ForEach.Value]"]

        if ${SlotRef.Has[switchToCombo]}
        {
            if !${SlotRef.Has[switchToComboIsGlobal]} || ${SlotRef.GetBool[switchToComboIsGlobal]}
            {
                globalbind -delete isb2_switchto
                globalbind isb2_switchto "${SlotRef.Get[switchToCombo]~}" "ISB2ProfileEngine:OnSwitchTo[1]"
            }
        }

        ISSession.OnWindowCaptured:AttachAtom[This:Event_OnWindowCaptured]        
    }

    method UninstallSlotActivateHotkey(uint numSlot, jsonvalueref joSlot)
    {
        if ${joSlot.Has[switchToCombo]}
            bind -delete is${numSlot}_key
    }

    method UninstallSlotActivateHotkeys()
    {
        if !${Team.Type.Equal[object]} || !${Team.Get[slots].Type.Equal[array]}
            return

        Team.Get[slots]:ForEach["This:UninstallSlotActivateHotkey[\${ForEach.Key},ForEach.Value]"]

        if ${SlotRef.Has[switchToCombo]}
        {
            if !${SlotRef.Has[switchToComboIsGlobal]} || ${SlotRef.GetBool[switchToComboIsGlobal]}
            {
                globalbind -delete isb2_switchto
            }
        }
    }

    method DeactivateSlot()
    {
        if !${SlotRef.Type.Equal[object]}
            return

        This:SetRelayGroups["SlotRef.Get[targetGroups]",0]
        This:UninstallSlotActivateHotkeys
        SlotRef:SetReference[NULL]
    }

    method AssignCPUCores()
    {
        variable jsonvalueref jaCores="SlotRef.Get[cpuCores]"

        proclock on
        if !${jaCores.Type.Equal[array]} || !${jaCores.Used}
        {
            timed 1 proc -all
            return
        }

        variable string output
        jaCores:ForEach["output:Concat[\" \${ForEach.Value} \${If[\${output.NotNULLOrEmpty},on,only]}\"]"]

        echo "\atAssignCPUCores\ax ${output}"
        timed 1 proc ${output~}
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

        script.OnScriptStopped:AttachAtom[This:Event_OnScriptStopped]
        Event[OnFrame]:AttachAtom[This:Event_OnFrame]

        This:ApplyWindowSettings

        This:SetRelayGroup["isboxer",1]
        This:SetRelayGroups["SlotRef.Get[targetGroups]",1]
        This:InstallVariables["SlotRef.Get[variables]"]
        This:VirtualizeMappables["SlotRef.Get[virtualMappables]"]
        This:ActivateProfilesByName["SlotRef.Get[profiles]"]

;        echo "\atInstalling Slot vfxSheets\ax ${SlotRef.Get[vfxSheets]~}"
        SlotRef.Get[vfxSheets]:ForEach["VFXSheets.Get[\"\${ForEach.Value~}\"]:Enable"]


        This:ExecuteEventAction[SlotRef,onLoad]

        echo "\agActivateSlot complete\ax"
    }

    method ActivateCharacter(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return

        This:DeactivateCharacter
        Character:SetReference[jo]
        This:ActivateSlot["${This.GetCharacterSlot["${Character.Get[name]~}"]}"]
        This:ActivateProfilesByName["Character.Get[profiles]"]

        ; white/black lists
        switch ${jo.Get[mappableSheetWhiteOrBlackListType]}
        {
            case BlackList
                This:InstallMappableSheetList[FALSE,"jo.Get[mappableSheetWhiteOrBlackList]"]
                break
            case WhiteList
                This:InstallMappableSheetList[TRUE,"jo.Get[mappableSheetWhiteOrBlackList]"]
                break
        }

        switch ${jo.Get[hotkeySheetWhiteOrBlackListType]}
        {
            case BlackList
                This:InstallHotkeySheetList[FALSE,"jo.Get[hotkeySheetWhiteOrBlackList]"]
                break
            case WhiteList
                This:InstallHotkeySheetList[TRUE,"jo.Get[hotkeySheetWhiteOrBlackList]"]
                break
        }

        This:ActivateWindowLayoutByName["${Team.Get["windowLayout"]~}"]

        This:SetRelayGroup["${Character.Get[name]~}",1]
        This:SetRelayGroups["Character.Get[targetGroups]",1]
        This:InstallVirtualFiles["Character.Get[virtualFiles]"]
        This:InstallVariables["Character.Get[variables]"]
        This:VirtualizeMappables["Character.Get[virtualMappables]"]

        LGUI2.Element[isb2.events]:FireEventHandler[onCharacterChanged]

        Character.Get[clickBars]:ForEach["ClickBars.Get[\"\${ForEach.Value~}\"]:Enable"]
        Character.Get[vfxSheets]:ForEach["VFXSheets.Get[\"\${ForEach.Value~}\"]:Enable"]

        Character.Get[hotkeySheets]:ForEach["HotkeySheets.Get[\"\${ForEach.Value~}\"]:Activate"]
        Character.Get[mappableSheets]:ForEach["MappableSheets.Get[\"\${ForEach.Value~}\"]:Activate"]
        Team.Get[hotkeySheets]:ForEach["HotkeySheets.Get[\"\${ForEach.Value~}\"]:Activate"]
        Team.Get[mappableSheets]:ForEach["MappableSheets.Get[\"\${ForEach.Value~}\"]:Activate"]

        This:SetGUIMode[0]

        This:ExecuteEventAction[Character,onLoad]

        if ${Slot} == ${Team.Get[slots].Used}
        {
            This:ExecuteEventAction[Team,onLastSlotLoaded]
        }

        echo "\agActivateCharacter complete\ax"
    }

    method DeactivateTeam()
    {
        if !${Team.Type.Equal[object]}
            return

        variable string qualifiedName
        qualifiedName:Set["isb2team_${Team.Get[name]~}"]
        This:SetRelayGroup["${qualifiedName~}",0]
        This:SetRelayGroups["Team.Get[targetGroups]",0]
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
        qualifiedName:Set["isb2team_${Team.Get[name]~}"]
        This:SetRelayGroup["${qualifiedName~}",1]
        
        This:ActivateProfilesByName["Team.Get[profiles]"]

        ; white/black lists
        switch ${jo.Get[mappableSheetWhiteOrBlackListType]}
        {
            case BlackList
                This:InstallMappableSheetList[FALSE,"jo.Get[mappableSheetWhiteOrBlackList]"]
                break
            case WhiteList
                This:InstallMappableSheetList[TRUE,"jo.Get[mappableSheetWhiteOrBlackList]"]
                break
        }

        switch ${jo.Get[hotkeySheetWhiteOrBlackListType]}
        {
            case BlackList
                This:InstallHotkeySheetList[FALSE,"jo.Get[hotkeySheetWhiteOrBlackList]"]
                break
            case WhiteList
                This:InstallHotkeySheetList[TRUE,"jo.Get[hotkeySheetWhiteOrBlackList]"]
                break
        }

        This:SetRelayGroups["Team.Get[targetGroups]",1]
        This:InstallVirtualFiles["Team.Get[virtualFiles]"]
        This:InstallVariables["Team.Get[variables]"]
        This:VirtualizeMappables["Team.Get[virtualMappables]"]

        This:ActivateBroadcastProfileByName["${Team.Get["broadcastProfile"]~}"]

        if ${jo.Has[guiToggleCombo]}
        {
            This:InstallHotkeyEx[guiToggle,"${jo.Get[guiToggleCombo]}","ISB2:ToggleGUIMode"]
        }        
        if ${jo.Has[consoleToggleCombo]}
        {
            This:InstallHotkeyEx[consoleToggle,"${jo.Get[consoleToggleCombo]}","console toggle"]
        }        

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

        echo TeamScope:SetReference["distributedscope.New[\"${dscopeDefinition.AsJSON~}\"]"]
        TeamScope:SetReference["distributedscope.New[\"${dscopeDefinition.AsJSON~}\"]"]

        echo "ActivateTeam: TeamScope.active=${TeamScope.GetBool[active]}"

        Team.Get[clickBars]:ForEach["ClickBars.Get[\"\${ForEach.Value~}\"]:Enable"]
        Team.Get[vfxSheets]:ForEach["VFXSheets.Get[\"\${ForEach.Value~}\"]:Enable"]

        LGUI2.Element[isb2.events]:FireEventHandler[onTeamChanged]

        This:ExecuteEventAction[Team,onLoad]

        echo "\agActivateTeam complete\ax"
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
        This:InstallImageSheets[_profile.ImageSheets]
        This:InstallGameMacroSheets[_profile.GameMacroSheets]
        This:InstallVirtualFiles[_profile.VirtualFiles]
        This:InstallBroadcastProfiles[_profile.BroadcastProfiles]
        This:InstallWindowLayouts[_profile.WindowLayouts]
        This:InstallTriggers[_profile.Triggers]
        This:InstallHotkeySheets[_profile.HotkeySheets]
        This:InstallGameKeyBindings[_profile.GameKeyBindings]
        This:InstallMappableSheets[_profile.MappableSheets]
        This:InstallClickBarTemplates[_profile.ClickBarTemplates]
        This:InstallClickBarButtonLayouts[_profile.ClickBarButtonLayouts]
        This:InstallClickBars[_profile.ClickBars]
        This:InstallVFXSheets[_profile.VFXSheets]
        This:InstallTimerPools[_profile.TimerPools]
        This:InstallVariables[_profile.Variables]

        This:InstallCharacters[_profile.Characters]
        This:InstallTeams[_profile.Teams]

        echo ActivateProfile ${_profile.Name} complete.

        LGUI2.Element[isb2.events]:FireEventHandler[onProfilesUpdated]
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
        This:UninstallGameMacroSheets[_profile.GameMacroSheets]
        This:UninstallVirtualFiles[_profile.VirtualFiles]
        This:UninstallWindowLayouts[_profile.WindowLayouts]
        This:UninstallTriggers[_profile.Triggers]
        This:UninstallHotkeySheets[_profile.HotkeySheets]
        This:UninstallGameKeyBindings[_profile.GameKeyBindings]
        This:UninstallMappableSheets[_profile.MappableSheets]
        This:UninstallClickBars[_profile.ClickBars]
        This:UninstallClickBarTemplates[_profile.ClickBarTemplates]
        This:UninstallClickBarButtonLayouts[_profile.ClickBarButtonLayouts]
        This:UninstallVFXSheets[_profile.VFXSheets]
        This:UninstallTimerPools[_profile.TimerPools]

        This:UninstallCharacters[_profile.Characters]
        This:UninstallTeams[_profile.Teams]

        LGUI2.Element[isb2.events]:FireEventHandler[onProfilesUpdated]
    }
#endregion

#region Variable Processors
    member:string ProcessVariables(string text)
    {
        if !${text.Find["{"]}
            return "${text~}"        

        variable int pos
        variable int endpos
        variable string name

        pos:Set["${text.Find["{U:"]}"]
        while ${pos}
        {
;            echo "\ayProcessVariables\ax: User variable in ${text~}"
            ; user variable
            endpos:Set["${text.FindFrom[${pos.Inc},"}"]}"]
            if !${endpos}
            {
                ; unterminated user variable reference
                text:Set["${text.Left[${pos.Dec}]~}"]
                Script:SetLastError["unterminated user variable reference in ${text~}"]
                break
            }

            ; get variable name
            ; convert end position to length
            endpos:Set["${endpos}-(${pos}+3)"]            
            name:Set["${text.Mid[${pos.Inc[3]},${endpos}]}"]

            variable weakref vRef
            vRef:SetReference["Variables.Get[\"${name~}\"]"]
            if ${vRef.Reference(exists)}
                text:Set["${text.ReplaceSubstring["{U:${name~}}","${vRef.Value~}"]}"]    
            else
                text:Set["${text.ReplaceSubstring["{U:${name~}}",""]}"]    

            pos:Set["${text.FindFrom[${pos.Inc},"{U:"]}"]
        }


        if ${Slot}
            text:Set["${text.ReplaceSubstring["{SLOT}",${Slot}]}"]
        elseif ${ISBoxerSlot(exists)}        
            text:Set["${text.ReplaceSubstring["{SLOT}",${ISBoxerSlot}]}"]
        else
            text:Set["${text.ReplaceSubstring["{SLOT}",1]}"]

        if ${Character.Reference(exists)}
            text:Set["${text.ReplaceSubstring["{CHARACTER}","${Character.Get[name]}"]}"]

        return "${text~}"        
    }
    ; for any object, process variables within a specific property 
    method ProcessVariableProperty(jsonvalueref jo, string varName)
    {
;        echo "ProcessVariableProperty[${varName~}] ${jo~}"
        if !${jo.Has[-string,"${varName~}"]}
            return

        jo:SetString["${varName~}","${This.ProcessVariables["${jo.Get["${varName~}"]~}"]~}"]        
    }

    ; for any Action object of a given action type, process its variableProperties
    method ProcessActionVariables(jsonvalueref joActionType, jsonvalueref joAction)
    {
        if !${joActionType.Get[variableProperties].Type.Equal[array]}
            return

        joActionType.Get[variableProperties]:ForEach["This:ProcessVariableProperty[joAction,\"\${ForEach.Value~}\"]"]
        This:ProcessVariableProperty[joAction,target]
    }
#endregion

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

    method TestKeystroke(string key)
    {
        variable jsonvalue joAction="{}"
        joAction:SetString["keyCombo","${key~}"]

        This:Action_Keystroke[NULL,joAction,TRUE]
        This:Action_Keystroke[NULL,joAction,FALSE]
    }


    method RemoteAction()
    {        
        variable jsonvalueref joState="Context.Get[actionState,state]"
        variable jsonvalueref joAction="Context.Get[actionState,action]"

;        echo "\ayRemoteAction\ax \apstate\ax=${joState~} \apaction\ax=${joAction~}"

        joAction:Erase[target]

        This:ExecuteAction[joState,joAction,${Context.GetBool[actionState,activate]}]
    }

    member:string ResolveTarget(jsonvalueref joState, jsonvalueref joAction, string propertyName="target")
    {
        variable string useTarget="${joAction.Get["${propertyName~}"]~}"

        if !${useTarget.NotNULLOrEmpty}
            return ""

        if ${useTarget.Equal[self]}
            return ""

        if ${useTarget.Equal[${Int64["${useTarget~}"]}]}
        {
            return "is${useTarget~}"
        }

        variable int64 rrCounter
        if ${joAction.GetBool[roundRobin]}
        {
            rrCounter:Set["${This.Rotator_GetCurrentStepCounter[joState]}"]
            rrCounter:Inc
            return "(${useTarget~})%${rrCounter}"
        }

        return "${useTarget~}"
    }

    method RetargetAction(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        variable string useTarget="${This.ResolveTarget[joState,joAction]~}"

        if !${useTarget.NotNULLOrEmpty}
            return FALSE

        variable jsonvalue joActionState="{}"
        joActionState:SetByRef[action,joAction]
        joActionState:SetByRef[state,joState]
        joActionState:SetBool[activate,${activate}]

        variable jsonvalue joRelay="{\"object\":\"ISB2\",\"method\":\"RemoteAction\"}"
        joRelay:SetString[target,"${useTarget~}"]
        joRelay:SetByRef[actionState,joActionState]
        InnerSpace:Relay["${joRelay~}"]

;        echo relay "${useTarget~}" "noop \${ISB2:RemoteAction[\"${joActionState~}\"]}"
        return TRUE
    }

    method RetimeAction(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        variable jsonvalueref joTimer="joAction.Get[timer]"
        if ${!joTimer.Reference(exists)}
            return FALSE

        variable string name
        name:Set["${joTimer.Get[name]~}"]
        if !${name.NotNULLOrEmpty}
            return FALSE

        echo "\ayRetimeAction\ax pool=${joTimer.Get[name]}"

        joAction:Erase[timer]
        return ${TimerPools.Get["${name~}"]:RetimeAction[joTimer,joState,joAction,${activate}](exists)}        
    }

    member:jsonvalueref ActionStateFromMappable(jsonvalueref joMappable, bool hold)
    {
        variable jsonvalueref joState="{}"

        joState:SetByRef[mappable,joMappable]
        joState:SetString[sheet,"${joMappable.Get[sheet]~}"]

        if ${joMappable.Has[hold]}
            joState:SetBool[hold,${joMappable.GetBool[hold]}]
        elseif ${hold} || ${MappableSheets.Get["${joMappable.Get[sheet]~}"].Hold}
            joState:SetBool[hold,1]        
        return joState
    }

    member:jsonvalueref ActionStateFromOwner(jsonvalueref joOwner, bool hold)
    {
        variable jsonvalueref joState="{}"
        joState:SetByRef[owner,joOwner]
        if ${joOwner.Has[hold]}
            joState:SetBool[hold,${joOwner.GetBool[hold]}]
        elseif ${hold}
            joState:SetBool[hold,1]
        return joState
    }

    member:bool ActionHoldState(jsonvalueref joState, jsonvalueref joAction)
    {
        if ${joAction.Has[hold]}
            return ${joAction.GetBool[hold]}

        if ${joAction.GetBool[onPress]} || ${joAction.GetBool[onRelease]}
            return FALSE
        
        if ${joState.Has[hold]}
            return ${joState.GetBool[hold]}

        ; this is now implemented by ActionStateFromMappable/ActionStateFromOwner
;        if ${joState.Has[sheet]}
;            return ${MappableSheets.Get["${joState.Get[sheet]~}"].Hold}

        return FALSE
    }

#region Action Types
    method Action_Keystroke(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\agAction_Keystroke\ax[${activate}] ${joAction~} ${joState~}"
        if !${joAction.Type.Equal[object]}
            return

        variable string keystroke
        keystroke:Set["${joAction.Get[keyCombo]~}"]
        if !${keystroke.NotNULLOrEmpty}
            return

        variable bool hold
        hold:Set[${This.ActionHoldState[joState,joAction]}]

        if !${hold} || ${joAction.Has[activationState]}
        {
            echo press -nomodifiers "${keystroke~}"
            press -nomodifiers "${keystroke~}"
            This:OnInput["${keystroke~}",1]
            This:OnInput["${keystroke~}",0]
            return
        }

        if ${activate}
        {
            echo press -hold "${keystroke~}"
            press -hold "${keystroke~}"
            This:OnInput["${keystroke~}",1]
        }
        else
        {
            echo press -release "${keystroke~}"
            press -release "${keystroke~}"
            This:OnInput["${keystroke~}",0]
        }
    }

    method Action_GameKeyBinding(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\agAction_GameKeyBinding\ax[${activate}] ${joAction~}"
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


        variable bool hold
        hold:Set[${This.ActionHoldState[joState,joAction]}]

        if !${hold} || ${joAction.Has[activationState]}
        {
            echo press -nomodifiers "${keystroke~}"
            press -nomodifiers "${keystroke~}"
            This:OnInput["${keystroke~}",1]
            This:OnInput["${keystroke~}",0]
            return
        }

        if ${activate}
        {
            echo press -hold "${keystroke~}"
            press -hold "${keystroke~}"
            This:OnInput["${keystroke~}",1]
        }
        else
        {
            echo press -release "${keystroke~}"
            press -release "${keystroke~}"
            This:OnInput["${keystroke~}",0]
        }
    }

    method Action_SetGameKeyBinding(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\agAction_SetGameKeyBinding\ax[${activate}] ${joAction~}"

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
        echo "\agAction_ClickBarState\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        variable string name
        name:Set["${joAction.Get[name]~}"]

        if ${joAction.Get[action]~.Equal[Single]}
        {
            switch ${joAction.Get[value]}
            {
                case On
                    ClickBars.Get["${name~}"]:Enable
                    break
                case Off
                    ClickBars.Get["${name~}"]:Disable
                    break
                case Toggle
                    ClickBars.Get["${name~}"]:Toggle
                    break
            }
        }
        else
        {
            ; todo
        }
    }

    method Action_HotkeySheetState(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\agAction_HotkeySheetState\ax[${activate}] ${joAction~}"
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

    method Action_MappableSheetState(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\agAction_MappableSheetState\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        variable string name
        name:Set["${joAction.Get[name]~}"]

        switch ${joAction.GetBool[state]}
        {
            case TRUE
                MappableSheets.Get["${name~}"]:Enable
                break
            case FALSE
                MappableSheets.Get["${name~}"]:Disable
                break
            case NULL
                MappableSheets.Get["${name~}"]:Toggle
                break
        }
    }

    method Action_KeyMapState(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        This:Action_HotkeySheetState[joState,joAction,${activate}]
        This:Action_MappableSheetState[joState,joAction,${activate}]
    }

    method Action_VFXSheetState(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\agAction_VFXSheetState\ax[${activate}] ${joAction~}"
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

    method Action_BroadcastState(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\arAction_BroadcastState\ax[${activate}] ${joAction~}"
        ISB2BroadcastMode:ApplyState[joAction]

    }

    method Action_BroadcastTarget(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\agAction_BroadcasTarget\ax[${activate}] ${joAction~}"
        ISB2BroadcastMode:SetTarget["${joAction.Get[value]~}"]
    }

    method Action_BroadcastList(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\arAction_BroadcastList\ax[${activate}] ${joAction~}"
        /*
                  "listType":"WhiteList",
                  "list":[
                    {
                      "Key":"1",
                      "code":2
                    },
                    {
                      "Key":"2",
                      "code":3
                    },
        */


    }

    method Action_PopupText(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\ayAction_PopupText\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        variable jsonvalue joStyle={}
        joStyle:SetString[text,"${joAction.Get[text]~}"]

        joStyle:SetString[color,"${joAction.Get[-default,"\"#ffffff\"",color]~}"]

        variable float duration=1
        variable float fadeDuration=0.25
        if ${joAction.Has[duration]}
            duration:Set[${joAction.GetNumber[duration]}]
        if ${joAction.Has[fadeDuration]}
            fadeDuration:Set[${joAction.GetNumber[fadeDuration]}]

        variable jsonvalue joAnimation="$$>
        {
            "type":"chain",
            "name":"fade",
            "animations":[
                {
                    "type":"fade",
                    "name":"fadeIn",
                    "opacity":1.0,
                    "duration":0.1,
                },
                {
                    "type":"delay",
                    "name":"fadeDelay",
                    "duration":${duration}
                },
                {
                    "type":"fade",
                    "name":"fadeOut",
                    "opacity":0.0,
                    "duration":${fadeDuration}
                }
            ]
        }
        <$$"

        LGUI2.Element[isb2.popupText]:ApplyStyleJSON[joStyle]
        LGUI2.Element[isb2.popupTextPanel]:ApplyStyleJSON["{\"opacity\":1.0}"]
        LGUI2.Element[isb2.popupTextPanel]:Animate[joAnimation]

    }

    method Action_WindowFocus(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\arAction_WindowFocus\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        ; todo: computer.
        variable string useTarget="${This.ResolveTarget[joState,joAction,window]~}"

        This:FocusWindow["${This.ResolveTarget[joState,joAction,window]~}","${joAction.Get[filterTarget]~}"]
        return
    }

    method FocusWindow(string windowTarget, string filterTarget)
    {
        if !${windowTarget.NotNULLOrEmpty}
        {
            ; our selves...

            if ${Display.Window.IsForeground}
            {
                ; already foreground
                return
            }
            else
            {
                echo "\ayRequesting focus from foreground window ...\ax"
                InnerSpace:Relay[foreground,"ISB2:FocusWindow[\"${Display.Window~}\"]"]
            }
            return
        }

        if ${Display.Window.IsForeground}
        {
            if ${filterTarget.NotNULLOrEmpty}
            {
                ;echo "focus -hotkey \"${windowTarget~}\" \"${filterTarget~}\""
                InnerSpace:Relay[uplink,"focus -hotkey \"${windowTarget~}\" \"${filterTarget~}\""]
            }
            else
            {
;                echo "focus -hotkey \"${windowTarget~}\""
                InnerSpace:Relay[uplink,"focus -hotkey \"${windowTarget~}\""]
            }
            return
        }

        InnerSpace:Relay[foreground,"ISB2:FocusWindow[\"${windowTarget~}\",\"${filterTarget~}\"]"]
    }

    method Action_WindowClose(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\arAction_WindowClose\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

    }

    method Action_Mappable(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\agAction_Mappable\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        variable bool hold
        hold:Set[${This.ActionHoldState[joState,joAction]}]

        if !${hold} || ${joAction.Has[activationState]}
        {
            This:ExecuteMappableByName["${joAction.Get[sheet]~}","${joAction.Get[name]~}",1]
            This:ExecuteMappableByName["${joAction.Get[sheet]~}","${joAction.Get[name]~}",0]
            return
        }

        This:ExecuteMappableByName["${joAction.Get[sheet]~}","${joAction.Get[name]~}",${activate}]
    }

    method Action_VirtualizeMappable(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\arAction_VirtualizeMappable\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        This:VirtualizeMappable["joAction.Get[from]","joAction.Get[to]"]
    }

    method Action_InputMapping(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\agAction_InputMapping\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        variable bool hold
        hold:Set[${This.ActionHoldState[joState,joAction]}]

        if !${hold} || ${joAction.Has[activationState]}
        {
            This:ExecuteInputMappingByName["${joAction.Get[name]~}",1]
            This:ExecuteInputMappingByName["${joAction.Get[name]~}",0]
            return
        }        

        This:ExecuteInputMappingByName["${joAction.Get[name]~}",${activate}]
    }

    method Action_SetInputMapping(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\agAction_SetInputMapping\ax[${activate}] ${joAction~}"

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
        echo "\agAction_MappableStep\ax[${activate}] ${joAction~}"

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
        echo "\agAction_MappableState\ax[${activate}] ${joAction~}"

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

        switch ${joAction.Get[value]}
        {
            case On
                joMappable:SetBool[enable,1]
                break
            case Off
                joMappable:SetBool[enable,0]
                break
            case Toggle
                if ${joMappable.GetBool[enable]}
                    joMappable:SetBool[enable,0]
                else
                    joMappable:SetBool[enable,1]
                break
        }

    }    

    method Action_GameMacro(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\ayAction_GameMacro\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        variable string keystroke

        ; "name":"Click-to-Move ON","sheet":"Quick Setup 42","type":"game macro"

        keystroke:Set["${GameMacroSheets.Get["${joAction.Get[sheet]~}"].Macros.Get["${joAction.Get[name]~}",keyCombo]~}"]
        if !${keystroke.NotNULLOrEmpty}
        {
            echo "\argame macro not found\ax: \"${joAction.Get[sheet]~}\" \"${joAction.Get[name]~}\""
            return
        }

        variable bool hold
        hold:Set[${This.ActionHoldState[joState,joAction]}]

        if !${hold} || ${joAction.Has[activationState]}
        {
            echo press -nomodifiers "${keystroke}"
            press -nomodifiers "${keystroke}"
            This:OnInput["${keystroke~}",1]
            This:OnInput["${keystroke~}",0]
            return
        }

        if ${activate}
        {
            echo press -hold "${keystroke}"
            press -hold "${keystroke}"
            This:OnInput["${keystroke~}",1]
        }
        else
        {
            echo press -release "${keystroke}"
            press -release "${keystroke}"
            This:OnInput["${keystroke~}",0]
        }
    }

    method Action_TargetGroup(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\arAction_TargetGroup\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        This:SetRelayGroup["${joAction.Get[name]~}",${joAction.GetBool[enable]}]
    }

    method Action_MappableStepState(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\ayAction_MappableStepState\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        variable jsonvalueref joStep
        joStep:SetReference["MappableSheets.Get[\"${joAction.Get[sheet]~}\"].Mappables.Get[\"${joAction.Get[name]~}\",${joAction.GetInteger[step]}]"]

        if !${joStep.Reference(exists)}
        {
            echo "\arMappable Step not found\ax"
            return
        }

        if ${joAction.Has[enable]}
            joStep:SetBool[enable,${joAction.GetBool[enable]}]
        if ${joAction.Has[triggerOnce]}
            joStep:SetBool[triggerOnce,${joAction.GetBool[triggerOnce]}]
        if ${joAction.Has[stickyTime]}
            joStep:SetNumber[stickyTime,${joAction.GetNumber[stickyTime]}]
    }

    method Action_SetClickBarButton(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\agAction_SetClickBarButton\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        if ${joAction.Has[buttonLayout]}
        {            
            ClickBarButtonLayouts.Get["${joAction.Get[buttonLayout]~}"]:ApplyChanges["joAction.Get[changes]",${joAction.GetInteger[numButton]}]
        }
        elseif ${joAction.Has[clickBar]}
        {
            ClickBars.Get["${joAction.Get[clickBar]~}"]:ApplyChanges["joAction.Get[changes]",${joAction.GetInteger[numButton]}]
        }
    }

    method Action_Style(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\ayAction_Style\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return FALSE

        variable weakref obj
        obj:SetReference["This.ResolveGUIObject[\"joAction.Get[object]\"]"]
        if !${obj.Reference(exists)}
            return FALSE

        if !${obj:ApplyStyleJSON["joAction.Get[style]"](exists)}
        {
            return FALSE
        }

        return TRUE
    }

    method Action_Animate(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\ayAction_Animate\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return FALSE

        if ${joAction.Has[-notnull,animationName]}
        {
            joAction.Get[animation]:SetString[name,"${joAction.Get[animationName]~}"]
        }

        variable weakref obj
        obj:SetReference["This.ResolveGUIObject[\"joAction.Get[object]\"]"]
        if !${obj.Reference(exists)}
        {
            echo "GUI object not found ${joAction.Get[object]~}"
            return FALSE
        }

        if !${obj:Animate["joAction.Get[animation]"](exists)}
        {
            echo "Animate failed"
            return FALSE
        }

        return TRUE
    }

    method Action_StopAnimation(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\ayAction_StopAnimation\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        variable weakref obj
        obj:SetReference["This.ResolveGUIObject[\"joAction.Get[object]\"]"]
        if !${obj.Reference(exists)}
            return FALSE

        if !${obj:StopAnimation["${joAction.Get[animationName]~}"](exists)}
        {
            return FALSE
        }

        return TRUE
    }

    method Action_SetVariable(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\agAction_SetVariable\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        if ${joAction.Has[value]}
        {
            Variables.Get["${joAction.Get[name]~}"]:Set["${joAction.Get[value].AsJSON~}"]
            return
        }

        switch ${joAction.Get[rotate]}
        {
            case forward
                Variables.Get["${joAction.Get[name]~}"]:Forward
                break
            case backward
                Variables.Get["${joAction.Get[name]~}"]:Backward
                break
        }
    }

    method Action_Random(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\agAction_Random\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return FALSE

        if !${joAction.Has[-array,actions]}
            return FALSE

        variable int64 key
        key:Set["${Math.Rand[${joAction.Get[actions].Used}]}+1"]

        echo "\ayAction_Random\ax: executing ${joAction.Get[actions,${key}]~}"
        This:ExecuteAction["joState","joAction.Get[actions,${key}]",1]
        This:ExecuteAction["joState","joAction.Get[actions,${key}]",0]        
        return TRUE
    }

    method Action_Switch(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\agAction_Switch\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return FALSE

        if !${joAction.Has[variableName]} || !${joAction.Has[-array,cases]}
            return FALSE

        variable weakref vRef
        vRef:SetReference["Variables.Get[\"${joAction.Get[variableName]~}\"]"]
        if !${vRef.Reference(exists)}
        {
            echo "\arAction_Switch\ax: Variable not found \"${joAction.Get[variableName]~}\""
            return FALSE
        }

        variable int64 key

        ; form a Select query
        variable jsonvalue joQuery
        joQuery:SetValue["{\"op\":\"==\"}"]
        joQuery:SetString[eval,"Select.Get[value]"]
        joQuery:SetByRef[value,"vRef.Value"]

        key:Set[${joAction.Get[cases].SelectKey[joQuery]}]
        if !${key}
        {
            if ${joAction.Has[default]}
            {
                echo "\ayAction_Switch\ax: executing ${joAction.Get[default]~}"
                This:ExecuteAction["joState","joAction.Get[default]",1]
                This:ExecuteAction["joState","joAction.Get[default]",0]
                return TRUE
            }

            echo "\ayAction_Switch\ax: switch case not found for ${vRef.Value.AsJSON~}"
            return TRUE
        }      

        echo "\ayAction_Switch\ax: executing ${joAction.Get[cases,${key},action]~}"
        This:ExecuteAction["joState","joAction.Get[cases,${key},action]",1]
        This:ExecuteAction["joState","joAction.Get[cases,${key},action]",0]        
        return TRUE
    }

    method Action_If(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\agAction_If\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return FALSE

        if !${joAction.Has[variableName]}
            return FALSE

        variable weakref vRef
        vRef:SetReference["Variables.Get[\"${joAction.Get[variableName]~}\"]"]
        if !${vRef.Reference(exists)}
        {
            echo "\arAction_If\ax: Variable not found \"${joAction.Get[variableName]~}\""
            return FALSE
        }

        ; form a Select query
        variable jsonvalue joQuery
        joQuery:SetValue["{}"]
        if ${joAction.Has[-notnull,op]}
            joQuery:SetString[op,"${joAction.Get[op]~}"]
        if ${joAction.Has[value]}
            joQuery:Set[value,"${joAction.Get[value].AsJSON~}"]
        if ${joAction.Has[with]}
            joQuery:SetByRef[with,"joAction.Get[with]"]
        if ${joAction.Has[list]}
            joQuery:SetByRef[list,"joAction.Get[list]"]

        ; check the result against the Variable's value
        variable bool result
        result:Set[${LavishScript.SelectEvaluate["vRef.Value",joQuery]}] 

;        echo "\ayAction_If\ax: result=${result}"

        if ${result}
        {
            if ${joAction.Has[true]}
            {
;                echo "\ayAction_If\ax: executing ${joAction.Get[true]~}"
                This:ExecuteAction["joState","joAction.Get[true]",1]
                This:ExecuteAction["joState","joAction.Get[true]",0]
            }
        }
        else
        {
            if ${joAction.Has[false]}
            {
;               echo "\ayAction_If\ax: executing ${joAction.Get[false]~}"
                This:ExecuteAction["joState","joAction.Get[false]",1]
                This:ExecuteAction["joState","joAction.Get[false]",0]
            }
        }

        return TRUE
    }

    method Action_KeyString(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\arAction_KeyString\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        ; text
    }

    method Action_SyncCursor(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\arAction_SyncCursor\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        ; target
    }

    method Action_WindowStyle(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\arAction_WindowStyle\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

    }

    method Action_WindowState(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\arAction_WindowState\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return
    }

    method Action_ClickBarStyle(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\arAction_ClickBarStyle\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

    }

    method Action_ClickBarHotkeySheet(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\arAction_ClickBarHotkeySheet\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

    }

    method Action_Sound(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\arAction_Sound\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

    }

    method Action_Light(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\arAction_Light\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

    }

    method Action_Volume(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\arAction_Volume\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

    }

    method Action_VFX(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\ayAction_VFX\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        variable string sheetName="default"
        if ${joAction.Has[-notnull,sheet]}
        {
            sheetName:Set["${joAction.Get[sheet]~}"]
        }

        switch ${joAction.Get[action]}
        {
            case Load
                {
                    VFXSheets.Get["${sheetName~}"]:Enable
                }
                break
            case Clear
                {
                    VFXSheets:ForEach["ForEach.Value:Disable"]
                }
                break
            case Show
                {
                    VFXSheets.Get["${sheetName~}"]:SetVFXState["${joAction.Get[name]~}",1]
                }
                break
            case Hide
                {
                    VFXSheets.Get["${sheetName~}"]:SetVFXState["${joAction.Get[name]~}",0]
                }
                break
            case Add
                {
                    if !${VFXSheets.Get["${sheetName~}"](exists)}
                    {
                        This:InstallVFXSheet["{\"name\":\"${sheetName~}\"}"]
                    }

                    if ${joAction.Has[vfxOutput]}
                    {
                        VFXSheets.Get["${sheetName~}"]:AddOutput["joAction.Get[vfxOutput]"]:SetVFXState["${joAction.Get[vfxOutput,name]~}",1]
                    }
                    elseif ${joAction.Has[vfxSource]}
                    {
                        VFXSheets.Get["${sheetName~}"]:AddSource["joAction.Get[vfxSource]"]:SetVFXState["${joAction.Get[vfxSource,name]~}",1,1]
                    }
                }
                break
            case Remove
                {
                    if ${joAction.Has[vfxOutput]}
                    {
                        VFXSheets.Get["${sheetName~}"]:RemoveVFX["${joAction.Get[vfxOutput,name]~}"]
                    }
                    elseif ${joAction.Has[vfxSource]}
                    {
                        VFXSheets.Get["${sheetName~}"]:RemoveVFX["${joAction.Get[vfxSource,name]~}"]
                    }
                }
                break
        }
    }

    method Action_Screenshot(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\arAction_Screenshot\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

    }

    method Action_InputDeviceKeySet(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\arAction_InputDeviceKeySet\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

    }

    method Action_TimerPool(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\arAction_TimerPool\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

    }

    method Action_SendNextClick(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\arAction_SendNextClick\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

    }

    method Action_RegionSheetState(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\arAction_RegionSheetState\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

    }

    method Action_AddTrigger(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\ayAction_AddTrigger\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return FALSE

        variable weakref triggerChain

        ; object
        ; name
        triggerChain:SetReference["This.ResolveTriggerChain[joAction,1]"]
        if !${triggerChain.Reference(exists)}
            return FALSE

        ; trigger
        triggerChain:AddTrigger["joAction.Get[trigger]"]
        return TRUE
    }

    method Action_RemoveTrigger(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\ayAction_RemoveTrigger\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        variable weakref triggerChain
        triggerChain:SetReference["This.ResolveTriggerChain[joAction,0]"]
        if !${triggerChain.Reference(exists)}
            return FALSE

        if ${joAction.Has[-notnull,triggerName]}
            triggerChain:RemoveTrigger["${triggerName}"]
        elseif ${joAction.Has[trigger,name]}
            triggerChain:RemoveTrigger["${jo.Get[trigger,name]~}"]
        else
            return FALSE

        return TRUE
    }

    method Action_Trigger(jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
        echo "\ayAction_Trigger\ax[${activate}] ${joAction~}"
        if !${joAction.Type.Equal[object]}
            return

        variable weakref triggerChain
        triggerChain:SetReference["This.ResolveTriggerChain[joAction,0]"]
        if !${triggerChain.Reference(exists)}
            return FALSE

        variable bool hold
        hold:Set[${This.ActionHoldState[joState,joAction]}]

        if !${hold} || ${joAction.Has[activationState]}
        {
            triggerChain:FireState[1]
            triggerChain:FireState[0]
            return
        }

        if ${activate}
        {
            triggerChain:FireState[1]
        }
        else
        {
            triggerChain:FireState[0]
        }            
        return TRUE
    }

#endregion

#region Rotator Implementation
    ; for any Rotator object, gets the current `step` value (or 1 by default)
    member:int Rotator_GetCurrentStepNum(jsonvalueref joRotator)
    {
        if !${joRotator.Type.Equal[object]}
            return 0

        variable int numStep
        numStep:Set[${joRotator.GetInteger[step]}]
        if !${numStep}
        {
            joRotator:SetInteger[step,1]
            return 1
        }
        return ${numStep}
    }

    member:jsonvalueref Rotator_GetCurrentStep(jsonvalueref joRotator)
    {
        if !${joRotator.Type.Equal[object]}
        {
        ;    echo "\arRotator_GetCurrentStep\ax ${joRotator~}"
            return NULL
        }
        variable int numStep
        numStep:Set[${This.Rotator_GetCurrentStepNum[joRotator]}]
        return "joRotator.Get[steps,${numStep}]"
    }

    method Rotator_SetStep(jsonvalueref joRotator, int numStep)
    {
        variable int totalSteps = ${joRotator.Get[steps].Used}

        if ${numStep}<1
			numStep:Set[1]
			
		if ${This.Rotator_GetCurrentStepNum[joRotator]}==1
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
        numStep:Set[${This.Rotator_GetCurrentStepNum[joRotator]}]			
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

    member:int64 Rotator_GetStepCounter(jsonvalueref joRotator,int numStep)
    {
        if !${joRotator.Type.Equal[object]}
            return 0
        return ${joRotator.GetInteger[steps,${numStep},counter]}
    }

    member:int64 Rotator_GetCurrentStepCounter(jsonvalueref joRotator)
    {
        if !${joRotator.Type.Equal[object]}
            return 0
        variable int numStep
        numStep:Set[${This.Rotator_GetCurrentStepNum[joRotator]}]
        return ${joRotator.GetInteger[steps,${numStep},counter]}
    }

    ; for any Rotator object, increments the step counter for a specified step
    method Rotator_IncrementStepCounter(jsonvalueref joRotator,int numStep)
    {
        This:IncrementCounter["joRotator.Get[steps,${numStep}]"]
    }

    ; for any Rotator object, attempts to advance to the next Step depending on the press/release state
    method Rotator_Advance(jsonvalueref joRotator,bool newState)
    {
        variable int numStep = ${This.Rotator_GetCurrentStepNum[joRotator]}
        variable int fromStep
        variable int stepCounter

;        echo "\ayRotator_Advance\ax ${newState} ${joRotator~}"

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

    member:float Rotator_GetStickyProgress(jsonvalueref joRotator)
    {
        variable int numStep = ${This.Rotator_GetCurrentStepNum[joRotator]}
        variable float stickyTime = ${joRotator.GetNumber[steps,${numStep},stickyTime]} 
        variable int timeNow
        if ${stickyTime}==0
            return 1

        if ${stickyTime}<0
            return 0

        timeNow:Set[${Script.RunningTime}]

        variable float progress        
        
        progress:Set[((${timeNow} - ${joRotator.GetInteger[stepTime]}) / 1000) / ${stickyTime}]

        if ${progress}>1
            return 1

        return ${progress}
    }


    member:float Rotator_GetResetProgress(jsonvalueref joRotator)
    {
        variable int numStep = ${This.Rotator_GetCurrentStepNum[joRotator]}
        variable float resetTime = ${joRotator.GetNumber[resetTimer]}
        variable float progress
        variable int timeNow

        if ${resetTime}==0
            return 0

        if ${numStep}<=1
            return 0
        timeNow:Set[${Script.RunningTime}]

        /* Pre-press reset check */
        switch ${joRotator.Get[resetType]~}
        {
        case firstPress
            progress:Set[((${timeNow} - ${joRotator.GetInteger[firstPress]}) / 1000) / ${resetTime}]
            break
        case firstAdvance
            progress:Set[((${timeNow} - ${joRotator.GetInteger[firstAdvance]}) / 1000) / ${resetTime}]
            break
        case lastPress
            progress:Set[((${timeNow} - ${joRotator.GetInteger[lastPress]}) / 1000) / ${resetTime}]
            break
        default
            return 0
        }

        if ${progress}>1
            return 1
        return ${progress}
    }

    member:string Rotator_GetResetType(jsonvalueref joRotator)
    {
        return ${joRotator.Get[-default,"\"never\"",resetType]}
    }

    member:float Rotator_GetRemainingResetTime(jsonvalueref joRotator)
    {
        variable int numStep = ${This.Rotator_GetCurrentStepNum[joRotator]}
        variable float remaining
        variable int timeNow

        if ${numStep}<=1
            return -1
        timeNow:Set[${Script.RunningTime}]

        /* Pre-press reset check */
        switch ${joRotator.Get[resetType]~}
        {
        case firstPress
            remaining:Set[((${joRotator.GetNumber[resetTimer]}*1000) + ${joRotator.GetInteger[firstPress]} - ${timeNow}) / 1000]
            break
        case firstAdvance
            remaining:Set[((${joRotator.GetNumber[resetTimer]}*1000) + ${joRotator.GetInteger[firstAdvance]} - ${timeNow}) / 1000]
            break
        case lastPress
            remaining:Set[((${joRotator.GetNumber[resetTimer]}*1000) + ${joRotator.GetInteger[lastPress]} - ${timeNow}) / 1000]
            break
        default
            return -1
        }

        if ${remaining}<=0
            return 0
        return ${remaining}
    }

    member:float Rotator_GetRemainingStickyTime(jsonvalueref joRotator)
    {
        variable int numStep = ${This.Rotator_GetCurrentStepNum[joRotator]}
        variable float stickyTime = ${joRotator.GetNumber[steps,${numStep},stickyTime]} 
        variable int timeNow
        if ${stickyTime}==0
            return
        timeNow:Set[${Script.RunningTime}]

        variable float remaining

        remaining:Set[((${stickyTime}*1000) + ${joRotator.GetInteger[stepTime]} - ${timeNow}) / 1000]

        if ${remaining}<=0
            return 0

        return ${remaining}
    }

    method Rotator_StickyAdvance(jsonvalueref joRotator)
    {
        variable int numStep = ${This.Rotator_GetCurrentStepNum[joRotator]}
        variable float stickyTime = ${joRotator.GetNumber[steps,${numStep},stickyTime]} 
        variable int timeNow
        if ${stickyTime}<=0
            return
        timeNow:Set[${Script.RunningTime}]
;        echo "\ayRotator_StickyAdvance\ax ${stickyTime}"

        if !${joRotator.GetInteger[stepTime]}
            joRotator:SetInteger[stepTime,${timeNow}]
        
        ; stepTime is the timestamp when we first used the step this cycle. 
        ; we advance when that timestamp, plus the sticky time, is now in the past
        if ${timeNow} >= (${stickyTime}*1000) + ${joRotator.GetInteger[stepTime]}
        {
            This:Rotator_Advance[joRotator,1]
        }
        else
        {
            ; echo "\arRotator_StickyAdvance\ax ${timeNow}>=(${stickyTime}*1000)+${joRotator.GetInteger[stepTime]}"
        }

    }

    ; for any Rotator object, perform pre-execution mechanics, depending on press/release state
    method Rotator_PreExecute(jsonvalueref joRotator,bool newState)
    {
        variable int numStep = ${This.Rotator_GetCurrentStepNum[joRotator]}
        variable int timeNow=${Script.RunningTime}

;        echo "\ayRotator_PreExecute\ax ${newState} ${numStep} ${joRotator~}"

        if ${newState}
        {
            This:Rotator_StickyAdvance[joRotator]
            numStep:Set[${joRotator.GetInteger[step]}]

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
                        numStep:Set[${joRotator.GetInteger[step]}]
                    }
    ;					else
    ;						echo \ayFromFirstPress ${timeNow}<${ResetTimer}+${FirstPress}
                    break
                case firstAdvance
    ;					echo FromFirstAdvance checking ${timeNow}>=${ResetTimer}+${FirstAdvance}
    ;					if ${timeNow}>=${ResetTimer}+${CurrentStepTimestamp}
                    if ${timeNow}>=(${joRotator.GetNumber[resetTimer]}*1000)+${joRotator.GetInteger[firstAdvance]}
                    {
                        This:Rotator_Reset[joRotator]
                        numStep:Set[${joRotator.GetInteger[step]}]
                    }
                    break
                case lastPress
                    if ${timeNow}>=(${joRotator.GetNumber[resetTimer]}*1000)+${joRotator.GetInteger[lastPress]}
                    {
                        This:Rotator_Reset[joRotator]
                        numStep:Set[${joRotator.GetInteger[step]}]
                    }
                    break
                }

            }		
            
            joRotator:SetInteger[lastPress,${timeNow}]
        }

        if !${This.Rotator_IsStepEnabled[joRotator,${numStep}]}
		{
;            echo Rotator_PreExecute calling Rotator_Advance[0] due to step ${numStep} disabled
			This:Rotator_Advance[joRotator,${newState}]
            numStep:Set[${joRotator.GetInteger[step]}]
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
;        echo "\ayRotator_PostExecute\ax: ${newState} ${executedStep} ${joRotator~}"

; call advance if ALL of these conditions are met....
; 1. newState == FALSE
; 2. has not already advanced (current step == executed step)
; 3. current step is NOT sticky

        if ${newState}
            return
        
        variable int numStep
        numStep:Set[${This.Rotator_GetCurrentStepNum[joRotator]}]

        if ${numStep}!=${executedStep}
        {
            echo "\arRotator_PostExecute\ax: numStep ${numStep}!=${executedStep}"
            return
        }

        ; is step sticky?
        if ${joRotator.GetNumber[steps,${numStep},stickyTime]}!=0
        {
            echo "\arRotator_PostExecute\ax: stickyTime ${joRotator.GetNumber[steps,${numStep},stickyTime]}!=0 ${joRotator~}"
            return
        }

;        echo Rotator_PostExecute calling Rotator_Advance
        This:Rotator_Advance[joRotator,0]
    }

    ; for any Rotator object, reset to the first step (often due to auto-reset mechanics)
    method Rotator_Reset(jsonvalueref joRotator)
    {
        variable int numStep = ${This.Rotator_GetCurrentStepNum[joRotator]}
        variable int timeNow=${Script.RunningTime}

        This:Rotator_IncrementStepCounter[joRotator,${numStep}]
        joRotator:SetInteger[firstPress,${timeNew}]
        joRotator:SetInteger[step,1]
        joRotator:SetInteger[stepTriggered,0]
		joRotator:SetInteger[stepTime,${timeNew}]
    }
#endregion

#region Input/Mappable Executors
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

        This:SetLastHotkey[joHotkey,${newState}]
        This:ExecuteInputMapping["joHotkey.Get[inputMapping]",${newState}]
    }

    member:jsonvalueref GetMappable(string sheet, string name)
    {
        variable jsonvalueref joMappable
        joMappable:SetReference["MappableSheets.Get[${sheet.AsJSON~}].Mappables.Get[${name.AsJSON~}]"]

        return joMappable
    }

    member:weakref ResolveMappableSheet(string sheet)
    {
        variable weakref mappableSheet
        mappableSheet:SetReference["MappableSheets.Get[${sheet.AsJSON~}]"]

        if !${mappableSheet.Enabled}
            return NULL

        if ${mappableSheet.VirtualizeAs.NotNULLOrEmpty}
        {
            ; do we want to allow multiple virtualization layers? 
            ; if yes ....

            echo "\ayResolveMappableSheet\ax Virtualized from ${sheet.AsJSON~} to ${mappableSheet.VirtualizeAs.AsJSON~}"
           return "This.ResolveMappableSheet[${mappableSheet.VirtualizeAs.AsJSON~}]"

            ; if not...
            /*
            {
                mappableSheet:SetReference["MappableSheets.Get[${mappableSheet.VirtualizeAs.AsJSON~}]"]
                if !${mappableSheet.Enabled}
                    return NULL
                return mappableSheet
            }
            */
        }
        return mappableSheet
    }

    member:jsonvalueref ResolveMappable(string sheet, string name)    
    {
        variable string originalSheet
        variable string originalName

        variable weakref mappableSheet
        mappableSheet:SetReference["This.ResolveMappableSheet[\"${sheet~}\"]"]

        if !${mappableSheet.Reference(exists)}
            return NULL

        variable jsonvalueref joMappable
        joMappable:SetReference["mappableSheet.Mappables.Get[${name.AsJSON~}]"]

        variable bool specified
        if ${joMappable.Has[virtualizeAs]}
        {
            originalSheet:Set["${sheet~}"]
            originalName:Set["${name~}"]

            if ${joMappable.Has[virtualizeAs,sheet]}
            {
                specified:Set[1]
                sheet:Set["${joMappable.Get[virtualizeAs,sheet]~}"]
            }
            if ${joMappable.Has[virtualizeAs,name]}
            {
                specified:Set[1]
                name:Set["${joMappable.Get[virtualizeAs,name]~}"]
            }

            if ${specified}
            {
                echo "\ayResolveMappable\ax Virtualized from [${originalSheet.AsJSON~},${originalName.AsJSON~}] to [${sheet.AsJSON~},${name.AsJSON~}]"
                return "This.ResolveMappable[${sheet.AsJSON~},${name.AsJSON~}]"
            }
        }

        return joMappable
    }

    method VirtualizeMappables(jsonvalueref ja)
    {
        echo "\ayVirtualizeMappables\ax ${ja~}"
        ja:ForEach["This:VirtualizeMappable[\"ForEach.Value.Get[from]\",\"ForEach.Value.Get[to]\"]"]
    }

    method VirtualizeMappable(jsonvalueref joFrom, jsonvalueref joTo)
    {
        if !${joFrom.Type.Equal[object]}
            return

        variable string fromSheet
        fromSheet:Set["${joFrom.Get[sheet]~}"]
        if !${fromSheet.NotNULLOrEmpty}
            return
        
        variable weakref mappableSheet
        mappableSheet:SetReference["MappableSheets.Get[${fromSheet.AsJSON~}]"]
        if !${mappableSheet.Reference(exists)}
            return

        variable string fromMappable
        fromMappable:Set["${joFrom.Get[name]~}"]
        if ${fromMappable.NotNULLOrEmpty}
        {
            ; virtualize specific mappable            
            if ${joTo.Type.Equal[object]}
                mappableSheet.Mappables.Get["${fromMappable~}"]:Set[virtualizeAs,"${joTo~}"]
            else
            {
                joTo:SetReference[NULL]
                mappableSheet.Mappables.Get["${fromMappable~}"]:Erase[virtualizeAs]
            }
            echo "\ayVirtualizeMappable\ax ${joFrom~} => ${joTo~}"
        }
        else
        {            
            ; virtualize mappable sheet
            if ${joTo.Type.Equal[object]} && ${joTo.Has[sheet]}
            {
                mappableSheet.VirtualizeAs:Set["${joTo.Get[sheet]~}"]
                echo "\ayVirtualizeMappable\ax Sheet ${fromSheet~} => ${joTo.Get[sheet]~}"
            }
            else
            {
                mappableSheet.VirtualizeAs:Set[""]
                echo "\ayVirtualizeMappable\ax Sheet ${fromSheet~} => NULL"
            }
        }
    }

    method ExecuteMappableByName(string sheet, string name, bool newState)
    {
        sheet:Set["${This.ProcessVariables["${sheet~}"]~}"]
        name:Set["${This.ProcessVariables["${name~}"]~}"]

        variable jsonvalueref joMappable
        joMappable:SetReference["This.ResolveMappable[${sheet.AsJSON~},${name.AsJSON~}]"]
        if !${joMappable.Reference(exists)}
            return


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
            echo "\aupress -hold \"${keystroke~}\"\ax"
            press -hold "${keystroke~}"
        }
        else
        {
            echo "\aupress -release \"${keystroke~}\"\ax"
            press -release "${keystroke~}"
        }
    }

    method RemoveLastHotkey(jsonvalueref joHotkey)
    {
        if !${joHotkey.Type.Equal[object]}
        {
            echo "\arRemoveLastHotkey\ax: joHotkey.Type is not object: ${joHotkey~}"
            return FALSE
        }
        variable int key
        variable jsonvalue joQuery
        joQuery:SetValue["$$>
        {
            "op":"&&",
            "list":[
                {
                    "op":"==",
                    "eval":"Select.Get[name\]",
                    "value":${joHotkey.Get[name].AsJSON~}
                },
                {
                    "op":"==",
                    "eval":"Select.Get[sheet\]",
                    "value":${joHotkey.Get[sheet].AsJSON~}
                }
            ]
        }
        <$$"]
        key:Set[${LastHotkeys.SelectKey[joQuery]}]
;        if !${key}
;        {
;            echo "\arRemoveLastHotkey\ax query failed ${joQuery~}"
;        }
        LastHotkeys:Erase[${key}]
    }

    method SetLastHotkey(jsonvalueref joHotkey,bool newState)
    {
;        echo "\arSetLastHotkey\ax ${joHotkey~}"
        This:RemoveLastHotkey[joHotkey]
        LastHotkeys:InsertByRef[1,joHotkey]
        LastHotkeys:Erase[11]
        LGUI2.Element[isb2.events]:FireEventHandler[onLastHotkeysUpdated]
    }    

    method RemoveLastMappable(jsonvalueref joMappable)
    {
        if !${joMappable.Type.Equal[object]}
        {
            echo "\arRemoveLastMappable\ax: joMappable.Type is not object: ${joMappable~}"
            return FALSE
        }
        variable int key
        variable jsonvalue joQuery
        joQuery:SetValue["$$>
        {
            "op":"&&",
            "list":[
                {
                    "op":"==",
                    "eval":"Select.Get[name\]",
                    "value":${joMappable.Get[name].AsJSON~}
                },
                {
                    "op":"==",
                    "eval":"Select.Get[sheet\]",
                    "value":${joMappable.Get[sheet].AsJSON~}
                }
            ]
        }
        <$$"]
        key:Set[${LastMappables.SelectKey[joQuery]}]
;        if !${key}
;        {
;            echo "\arRemoveLastMappable\ax query failed ${joQuery~}"
;        }
        LastMappables:Erase[${key}]
    }

    method RemoveLastInput(jsonvalueref joInput)
    {
        if !${joInput.Type.Equal[object]}
        {
            echo "\arRemoveLastInput\ax: joInput.Type is not object: ${joInput~}"
            return FALSE
        }
        variable int key
        variable jsonvalue joQuery
        joQuery:SetValue["$$>
        {
            "op":"&&",
            "list":[
                {
                    "op":"==",
                    "eval":"Select.Get[state\]",
                    "value":${joInput.Get[state].AsJSON~}
                },
                {
                    "op":"==",
                    "eval":"Select.Get[keyCombo\]",
                    "value":${joInput.Get[keyCombo].AsJSON~}
                }
            ]
        }
        <$$"]
        key:Set[${LastInputs.SelectKey[joQuery]}]
;        if !${key}
;        {
;            echo "\arRemoveLastInput\ax query failed ${joQuery~}"
;        }
        LastInputs:Erase[${key}]
    }

    method SetLastAction(jsonvalueref joAction,string newState)
    {
        variable int counter
        counter:Set[${joAction.GetInteger["${newState~}.counter"]}+1]
        joAction:SetInteger["${newState~}.counter",${counter}]
        joAction:SetInteger["${newState~}.counterTime",${Script.RunningTime}]



        variable jsonvalue joActionRef="{}"
        joActionRef:SetByRef[action,joAction]
        joActionRef:SetString[state,"${newState~}"]

        LastActions:InsertByRef[1,joActionRef]
        LastActions:Erase[11]
        LGUI2.Element[isb2.events]:FireEventHandler[onLastActionsUpdated]        
    }

    method OnInput(string keyCombo, bool newState)
    {
        variable jsonvalueref jo="Inputs.Get[\"${keyCombo~}\"]"
        if !${jo.Reference(exists)}
        {
;            echo "OnInput: new ${keyCombo~}"
            jo:SetReference["{}"]
            jo:SetString[keyCombo,"${keyCombo~}"]

            Inputs:SetByRef["${keyCombo~}",jo]
        }
        else
        {
;            echo "OnInput: existing ${keyCombo~}"
        }

        variable int counter
        variable string sState
        if ${newState}
            sState:Set[press]
        else
            sState:Set[release]

        counter:Set[${jo.GetInteger["${sState~}.counter"]}+1]
        jo:SetInteger["${sState~}.counter",${counter}]
        jo:SetInteger["${sState~}.counterTime",${Script.RunningTime}]

        This:SetLastInput[jo,${newState}]
    }

    method SetLastInput(jsonvalueref joInput, bool newState)
    {
        variable jsonvalue joInputRef="{}"
        joInputRef:SetByRef[input,joInput]
        joInputRef:SetBool[state,${newState}]
        joInputRef:SetInteger[time,${Script.RunningTime}]
        joInputRef:SetInteger[press.counter,${joInput.GetInteger[press.counter]}]
        joInputRef:SetInteger[release.counter,${joInput.GetInteger[release.counter]}]

;        This:RemoveLastInput[joInputRef]
        LastInputs:InsertByRef[1,joInputRef]
        LastInputs:Erase[11]

        LGUI2.Element[isb2.events]:FireEventHandler[onLastInputsUpdated]
    }

    method SetLastMappable(jsonvalueref joMappable,bool newState)
    {
;        echo "\arSetLastMappable\ax ${joMappable~}"
        This:RemoveLastMappable[joMappable]
        LastMappables:InsertByRef[1,joMappable]
        LastMappables:Erase[11]
        LGUI2.Element[isb2.events]:FireEventHandler[onLastMappablesUpdated]
    }

    method ExecuteMappableActivationState(jsonvalueref joMappable, bool newState)
    {
        ; get current step, then call This:ExecuteRotatorStep
        if !${newState}
        {
            This:IncrementCounter[joMappable]
        }

        variable int numStep=1
        This:Rotator_PreExecute[joMappable,${newState}]

        numStep:Set[${This.Rotator_GetCurrentStepNum[joMappable]}]
        if ${numStep}>0
        {
            This:ExecuteRotatorStep[joMappable,"joMappable.Get[steps,${numStep}]","This.ActionStateFromMappable[joMappable]",${newState}]
            This:Rotator_PostExecute[joMappable,${newState},${numStep}]
        }
        else
        {
            echo "\arExecuteMappableActivationState\ax numStep=0"
        }

        This:SetLastMappable[joMappable,${newState}]
    }

    method ExecuteMappable(jsonvalueref joMappable, bool newState)
    {
        if !${joMappable.Type.Equal[object]}
            return

;        echo "\agExecuteMappable\ax[${newState}] ${joMappable~}"

        ; make sure it's not disabled. to be disabled requires "enable":false
        if ${joMappable.GetBool[enable].Equal[FALSE]}
            return

        variable weakref mappableSheet
        mappableSheet:SetReference["MappableSheets.Get[\"${joMappable.Get[sheet]~}\"]"]
        if ${joMappable.GetBool[hold]}
        {
;            echo "\ayExecuteMappable\ax: Hold"
            This:ExecuteMappableActivationState[joMappable,${newState}]
            return
        }
        
        ; the onPress/onRelease state might be specified by the sheet instead of the mappable
        if ${newState}
        {
            ; if we have "onPress", fire both press/release mechanics now
            if ${joMappable.Has[onPress]}
            {
                if !${joMappable.GetBool[onPress]}
                    return

;                echo "\ayExecuteMappable\ax: onPress"
                This:ExecuteMappableActivationState[joMappable,1]
                This:ExecuteMappableActivationState[joMappable,0]
                return
            }


            if ${joMappable.GetBool[onRelease]}
            {
                return
            }

            if ${mappableSheet.Reference(exists)}
            {
                if !${mappableSheet.Hold}
                {
                    switch ${mappableSheet.Mode}
                    {
                        case OnRelease
                            return
                        case OnPress
                        case OnPressAndRelease
;                            echo "\ayExecuteMappable\ax: ${mappableSheet.Mode} (sheet)"
                            This:ExecuteMappableActivationState[joMappable,1]
                            This:ExecuteMappableActivationState[joMappable,0]
                            return
                    }
;                    echo "\ayExecuteMappable\ax: ${newState} ${mappableSheet.Mode} post-check"
                }
            }
        }
        else
        {
            ; if we have "onRelease", fire both press/release mechanics now
            if ${joMappable.Has[onRelease]}
            {
                if !${joMappable.GetBool[onRelease]}
                    return

;                echo "\ayExecuteMappable\ax: onRelease"
                This:ExecuteMappableActivationState[joMappable,1]
                This:ExecuteMappableActivationState[joMappable,0]
                return
            }

            if ${joMappable.GetBool[onPress]}
            {
                return
            }

            if ${mappableSheet.Reference(exists)}
            {
                if !${mappableSheet.Hold}
                {
                    switch ${mappableSheet.Mode}
                    {
                        case OnRelease
                        case OnPressAndRelease
                            echo "\ayExecuteMappable\ax: ${mappableSheet.Mode} (sheet)"
                            This:ExecuteMappableActivationState[joMappable,1]
                            This:ExecuteMappableActivationState[joMappable,0]
                            return
                        case OnPress
                            return
                    }
;                    echo "\ayExecuteMappable\ax: ${newState} ${mappableSheet.Mode} post-check"
                }
            }
        }
        
;        echo "\ayExecuteMappable\ax: Split ${mappableSheet.Name~} ${mappableSheet.Mode~} ${mappableSheet.Hold}"
        This:ExecuteMappableActivationState[joMappable,${newState}]
    }

    ; for any Rotate object, execute a given step, depending on press/release state
    method ExecuteRotatorStep(jsonvalueref joRotator, jsonvalueref joStep, jsonvalueref joState, bool newState)
    {
        if !${joRotator.Type.Equal[object]}
            return
        if !${joStep.Type.Equal[object]}
            return

;        echo "\agExecuteRotatorStep\ax[${newState}] ${joStep~}"
;        echo "\ayExecuteRotatorStep\ax triggered=${joStep.GetInteger[stepTriggered]} triggerOnce=${joStep.GetBool[triggerOnce]}"

        ; if the step is disabled, don't execute it.
        if ${joStep.GetBool[enable].Equal[FALSE]}
            return

        if ${newState}
        {
            if ${joRotator.GetInteger[stepTriggered]}<1
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
            if ${joRotator.GetInteger[stepTriggered]}<2
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
        
        This:ExecuteActionList[joState,"joStep.Get[actions]",${newState}]        
    }

    ; for any Action List, execute all actions depending on press/release state
    method ExecuteActionList(jsonvalueref joState, jsonvalueref jaList, bool newState)
    {
        if !${jaList.Type.Equal[array]}
            return

;        echo "\agExecuteActionList\ax[${newState}] ${jaList~}"
        jaList:ForEach["This:ExecuteAction[joState,ForEach.Value,${newState}]"]
    }



    member:bool ShouldExecuteAction(jsonvalueref joState, jsonvalueref joActionType, jsonvalueref joAction, bool activate)
    {
        ; hold is enabled, need both states
        if ${This.ActionHoldState[joState,joAction]}
        {
            return TRUE
        }

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

    method ExecuteEventAction(jsonvalueref joOwner, string eventName)
    {
        if !${joOwner.Type.Equal[object]}
            return FALSE

        variable jsonvalueref joAction
        joAction:SetReference["joOwner.Get[\"${eventName~}\"]"]

        if !${joAction.Type.Equal[object]}
            return FALSE

        variable jsonvalueref joState
        joState:SetReference["This.ActionStateFromOwner[joOwner]"]        
        This:ExecuteAction[joState,joAction,1]
        This:ExecuteAction[joState,joAction,0]
    }

    method ManualExecuteAction(jsonvalueref joAction)
    {
        echo "\ayManualExecuteAction\ax ${joAction~}"
        variable jsonvalue joState="{}"
        This:ExecuteAction[joState,joAction,1]
        This:ExecuteAction[joState,joAction,0]
    } 
    
    method ExecuteAction(jsonvalueref joState, jsonvalueref _joAction, bool activate)
    {
;        echo \ayExecuteAction\ax
        ; ensure we have a valid json object representing the action
        if !${_joAction.Type.Equal[object]}
        {
;            echo "!\${_joAction.Type.Equal[object]}"
            return FALSE
        }

        variable string actionType = "${_joAction.Get[type].Lower~}"
        variable jsonvalueref joActionType = "ActionTypes.Get[\"${actionType~}\"]"

        if !${joActionType.Reference(exists)}
        {
            Script:SetLastError["ExecuteAction: \arUnhandled action type: \"${actionType~}\"\ax"]
            return FALSE
        }
        
        ; check activationState settings to make sure we should execute the action here
        if !${This.ShouldExecuteAction[joState,joActionType,_joAction,${activate}]}
        {
;            echo "!\${This.ShouldExecuteAction[joState,joActionType,_joAction,${activate}]}"
            return TRUE
        }

        variable jsonvalueref joAction
        ; we will use a copy of the action, so as to not modify the original action for the next execution
        joAction:SetReference[_joAction.Duplicate]
        
        ; process any variableProperties
        This:ProcessActionVariables[joActionType,joAction]

        ; see if the action type supports action timers
        if ${joActionType.GetBool[timer]}
        {
            ; yeah see if we should retime the action
            if ${This:RetimeAction[joState,joAction,${activate}](exists)}
            {
                This:SetLastAction[joAction,retime]
;                echo "Action retimed"
                return TRUE
            }
            ; we didn't retime the action
        }

        ; see if the action type supports retargeting 
        if ${joActionType.GetBool[retarget]}
        {
            ; yeah see if we should retarget the action
            if ${This:RetargetAction[joState,joAction,${activate}](exists)}
            {
                This:SetLastAction[joAction,retarget]
;                echo "Action retargeted"
                return TRUE
            }
            ; we didn't retarget the action, execute it here
        }
        
        variable string actionMethod
        actionMethod:Set["${joActionType.Get[handler]~}"]
   
 ;       echo "ExecuteAction[${actionType~}]=${actionMethod~}"
        if ${actionMethod.NotNULLOrEmpty}
        {
            if ${activate}
                This:SetLastAction[_joAction,press]
            else
                This:SetLastAction[_joAction,release]

            execute "This:${actionMethod}[joState,joAction,${activate}]"
            return TRUE
        }
        return FALSE
    }

    method ExecuteInputMapping(jsonvalueref joMapping, bool newState)
    {
        echo "\ayExecuteInputMapping\ax[${newState}] ${joMapping~}"

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
                {
                    variable weakref triggerChain

                    ; object
                    ; name
                    triggerChain:SetReference["This.ResolveTriggerChain[joMapping,0]"]
                    if !${triggerChain.Reference(exists)}
                        return FALSE

                    return ${triggerChain:Fire[${newState}](exists)}
                }
            case action
                return ${This:ExecuteAction["This.ActionStateFromOwner[joMapping,1]","joMapping.Get[action]",${newState}](exists)}
            case actions
                return ${This:ExecuteActionList["This.ActionStateFromOwner[joMapping,1]","joMapping.Get[actions]",${newState}](exists)}
        }

        return FALSE
    }
#endregion

    member:weakref ResolveGUIObject(jsonvalueref jo)
    {
        switch ${jo.Get[type]}
        {
            case clickbar
                return "ClickBars.Get[\"${jo.Get[name]~}\"]"
            case clickbarbutton
                {
                    if ${jo.Has[-notnull,clickBar]}
                        return "ClickBars.Get[\"${jo.Get[clickBar]~}\"].Buttons[${jo.GetInteger[button]}]"
                    if ${jo.Has[-notnull,buttonLayout]}
                        return "ClickBarButtonLayouts.Get[\"${jo.Get[buttonLayout]~}\"].Buttons[${jo.GetInteger[button]}]"
                }
                break
            case vfxsource
                return "VFXSheets.Get[\"${jo.Get[-default,"\"default\"",sheet]~}\"].Sources.Get[\"${jo.Get[name]~}\"]"
            case vfxoutput
                return "VFXSheets.Get[\"${jo.Get[-default,"\"default\"",sheet]~}\"].Outputs.Get[\"${jo.Get[name]~}\"]"
        }
    }

    member:weakref ResolveObject(jsonvalueref jo)
    {
        switch ${jo.Get[type]}
        {
            case clickbar
                return "ClickBars.Get[\"${jo.Get[name]~}\"]"
            case clickbarbutton
                {
                    if ${jo.Has[-notnull,clickBar]}
                        return "ClickBars.Get[\"${jo.Get[clickBar]~}\"].Buttons[${jo.GetInteger[button]}]"
                    if ${jo.Has[-notnull,buttonLayout]}
                        return "ClickBarButtonLayouts.Get[\"${jo.Get[buttonLayout]~}\"].Buttons[${jo.GetInteger[button]}]"
                }
                break
            case buttonlayout
                return "ClickBarButtonLayouts.Get[\"${jo.Get[name]~}\"]"
            case variable
                return "Variables.Get[\"${jo.Get[name]~}\"]"
            case timerpool
                return "TimerPools.Get[\"${jo.Get[name]~}\"]"
            case hotkeysheet
                return "HotkeySheets.Get[\"${jo.Get[name]~}\"]"
            case imagesheet
                return "ImageSheets.Get[\"${jo.Get[name]~}\"]"
            case mappablesheet
                return "MappableSheets.Get[\"${jo.Get[name]~}\"]"
            case regionsheet
                return "RegionSheets.Get[\"${jo.Get[name]~}\"]"
            case gamemacrosheet
                return "GameMacroSheets.Get[\"${jo.Get[name]~}\"]"
            case vfxsheet
                return "VFXSheets.Get[\"${jo.Get[name]~}\"]"
            case vfxsource
                return "VFXSheets.Get[\"${jo.Get[-default,default,sheet]~}\"].Sources.Get[\"${jo.Get[name]~}\"]"
            case vfxoutput
                return "VFXSheets.Get[\"${jo.Get[-default,default,sheet]~}\"].Outputs.Get[\"${jo.Get[name]~}\"]"
            case isboxer2
                return "This"
        }
    }

    member:weakref ResolveTriggerChain(jsonvalueref jo, bool autoCreate)
    {
        variable jsonvalueref joObject="jo.Get[object]"
        if !${joObject.Reference(exists)}
            return 0

        variable weakref obj
        obj:SetReference["This.ResolveObject[joObject]"]

        if !${obj.Reference(exists)}
            return 0

        return "obj.TriggerChains.Get[\"${jo.Get[name]}\",${autoCreate}]"
    }

    method ApplyGUIModeTo(lgui2elementref element)
    {
        This:ShowTitleBar[${GUIMode},${element.ID}]            
    }

    method ShowTitleBar(bool show, lgui2elementref element)
    {
        if !${element.Element(exists)}
            return

        if !${element.ElementType.Name.Equal[window]}
            return

        if ${element.Metadata.GetBool[keepTitleBar]}
            return

        if ${show}
        {
            element.Locate[titlebar]:SetVisibility["Visible"]
			element:ApplyStyle["onShowTitleBar"]
			element:FireEventHandler["onShowTitleBar"]
        }
        else
        {
            element.Locate[titlebar]:SetVisibility["Hidden"]
			element:ApplyStyle["onHideTitleBar"]
			element:FireEventHandler["onHideTitleBar"]
        }     
    }

    method ShowTitleBars(bool show=1)
    {
        variable(static) jsonvalueref joQuery="$$>
        {
            "eval":"Select.Metadata.Has[isboxer2]"
        }<$$"

        LGUI2.Screen:ForEachChild["This:ShowTitleBar[${show},\"\${ForEach.Key}\"]",joQuery]
    }

    method SetGUIMode(bool newValue)
    {
        if ${newValue} == ${GUIMode}
            return
        GUIMode:Set[${newValue}]
        if ${newValue}
        {
            LGUI2.Element[isb2.mainWindow]:SetVisibility[Visible]
            This:ShowTitleBars[1]
        }
        else
        {
            LGUI2.Element[isb2.mainWindow]:SetVisibility[Hidden]
            This:ShowTitleBars[0]
        }
        
        LGUI2.Element[isb2.events]:FireEventHandler[onGUIModeChanged]
    }

    method ToggleGUIMode()
    {
        This:SetGUIMode["${GUIMode.Not}"]
    }

    method SetRelayGroup(string name, bool newState)
    {
        if !${name.NotNULLOrEmpty}
            return FALSE

        if ${newState}
        {
            RelayGroups:Add["${name~}"]
;            echo "\aprelaygroup -join \"${name~}\""
            uplink relaygroup -join "${name~}"
        }
        else
        {
            RelayGroups:Erase["${name~}"]
;            echo "\aprelaygroup -leave \"${name~}\""
            uplink relaygroup -leave "${name~}"
        }
        return TRUE
    }

    method SetRelayGroups(jsonvalueref ja, bool newState)
    {
        if !${ja.Type.Equal[array]}
            return FALSE

        ja:ForEach["This:SetRelayGroup[\"\${ForEach.Value~}\",${newState}]"]

        return TRUE
    }
}









