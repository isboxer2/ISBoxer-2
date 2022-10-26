#include "ISB2.XMLReader.iss"
objectdef isb2_importer
{

    variable jsonvalueref ISBProfile
    
    variable bool MappedKeyHoldState

#region XML Transformers -- API Entry Points 
    method TransformXML(string filename)
    {
        variable isb2_isb1transformer ISB1Transformer

        ISBProfile:SetReference["ISB1Transformer.TransformXML[\"${filename~}\"]"]
        
        This:WriteJSON["${filename~}.json"]
    }

    member:jsonvalueref TransformProfileXML(filepath filename)
    {
        variable isb2_isb1transformer ISB1Transformer
        variable jsonvalue jo="{}"
        variable jsonvalueref jRef

        ISBProfile:SetReference["ISB1Transformer.TransformXML[\"${filename~}\"]"]
        
        This:WriteJSON["${filename~}.json"]

        jRef:SetReference[This.ConvertCharacters]        
        if ${jRef.Used}
        {
            jo:SetByRef[characters,jRef]
        }
        jRef:SetReference[This.ConvertCharacterSets]        
        if ${jRef.Used}
        {
            jo:SetByRef[teams,jRef]
        }
        jRef:SetReference[This.ConvertKeyMapsAsHotkeySheets]        
        if ${jRef.Used}
        {
            jo:SetByRef[hotkeySheets,jRef]
        }
        jRef:SetReference[This.ConvertKeyMapsAsMappableSheets]        
        if ${jRef.Used}
        {
            jo:SetByRef[mappableSheets,jRef]
        }
        jRef:SetReference[This.ConvertWoWMacroSets]        
        if ${jRef.Used}
        {
            jo:SetByRef[gameMacroSheets,jRef]
        }
        jRef:SetReference[This.ConvertVariableKeystrokes]        
        if ${jRef.Used}
        {
            jo:SetByRef[gameKeyBindings,jRef]
        }
        jRef:SetReference[This.ConvertComputers]        
        if ${jRef.Used}
        {
            jo:SetByRef[computers,jRef]
        }
        jRef:SetReference[This.ConvertClickBars]        
        if ${jRef.Used}
        {
            jo:SetByRef[clickBars,jRef]
        }
        jRef:SetReference[This.ConvertMenus]        
        if ${jRef.Used}
        {
            jo:SetByRef[menus,jRef]
        }
        jRef:SetReference[This.ConvertMenuTemplates]        
        if ${jRef.Used}
        {
            jo:SetByRef[menuTemplates,jRef]
        }        
        jRef:SetReference[This.ConvertMenuButtonLayouts]        
        if ${jRef.Used}
        {
            jo:SetByRef[menuButtonLayouts,jRef]
        }        
        
        jRef:SetReference[This.ConvertRepeaterProfiles]        
        if ${jRef.Used}
        {
            jo:SetByRef[broadcastProfiles,jRef]
        }
        jRef:SetReference[This.ConvertWindowLayouts]        
        if ${jRef.Used}
        {
            jo:SetByRef[windowLayouts,jRef]
        }

        jo:SetByRef[vfxSheets,"ISBProfile.Get[vfxSheets]"]

        jo:SetString[name,"${filename.FilenameOnly~}"]
        jo:SetString["$schema","http://www.lavishsoft.com/schema/isb2.json"]
        return jo
    }

    method TransformProfileXML(filepath filename)
    {
        variable jsonvalueref jo
        jo:SetReference["This.TransformProfileXML[\"${filename~}\"]"]
        jo:WriteFile["${LavishScript.HomeDirectory~}/${filename.FilenameOnly~}.isb2.json",multiline]
    }

    method TransformCurrentProfileXML()
    {
        variable jsonvalueref jo
        jo:SetReference["This.TransformProfileXML[\"${LavishScript.HomeDirectory~}/ISBoxerToolkitProfile.LastExported.XML\"]"]
        jo:WriteFile["${LavishScript.HomeDirectory~}/ISBoxerToolkitProfile.LastExported.isb2.json",multiline]
    }

    member:jsonvalueref TransformRegionsXML(string filename)
    {
        variable isb2_isb1transformer ISB1Transformer

        variable jsonvalueref joProfile
        joProfile:SetReference["ISB1Transformer.TransformRegionsXML[\"${filename~}\"]"]

        return joProfile
    }

    member:jsonvalueref TransformVideoFXXML(string filename)
    {
        variable isb2_isb1transformer ISB1Transformer

        variable jsonvalueref joProfile
        joProfile:SetReference["ISB1Transformer.TransformVideoFXXML[\"${filename~}\"]"]

        return joProfile
    }
#endregion

#region Mass Conversion -- Fully implemented
    member:jsonvalueref ConvertActionTimerPools()
    {
        variable jsonvalue ja="[]"
        ISBProfile.Get[ActionTimerPool]:ForEach["ja:AddByRef[\"This.ConvertActionTimerPool[ForEach.Value]\"]"]

        return ja
    }

    member:jsonvalueref ConvertCharacters()
    {
        variable jsonvalue ja="[]"
        ISBProfile.Get[Character]:ForEach["ja:AddByRef[\"This.ConvertCharacter[ForEach.Value]\"]"]

        return ja
    }

    member:jsonvalueref ConvertCharacterSets()
    {
        variable jsonvalue ja="[]"
        ISBProfile.Get[CharacterSet]:ForEach["ja:AddByRef[\"This.ConvertCharacterSet[ForEach.Value]\"]"]

        return ja
    }

    member:jsonvalueref ConvertClickBars()
    {
        variable jsonvalue ja="[]"
        ISBProfile.Get[ClickBar]:ForEach["ja:AddByRef[\"This.ConvertClickBar[ForEach.Value]\"]"]

        return ja
    }

    member:jsonvalueref ConvertClickBarImages()
    {
        variable jsonvalue ja="[]"
        ISBProfile.Get[ClickBarImage]:ForEach["ja:AddByRef[\"This.ConvertClickBarImage[ForEach.Value]\"]"]

        return ja
    }

    member:jsonvalueref ConvertComputers()
    {
        variable jsonvalue ja="[]"
        ISBProfile.Get[Computer]:ForEach["ja:AddByRef[\"This.ConvertComputer[ForEach.Value]\"]"]

        return ja
    }

    member:jsonvalueref ConvertKeyMapsAsHotkeySheets()
    {
        variable jsonvalue ja="[]"
        ISBProfile.Get[KeyMap]:ForEach["ja:AddByRef[\"This.ConvertKeyMapAsHotkeySheet[ForEach.Value]\"]"]

        return ja
    }

    member:jsonvalueref ConvertKeyMapsAsMappableSheets()
    {
        variable jsonvalue ja="[]"
        ISBProfile.Get[KeyMap]:ForEach["ja:AddByRef[\"This.ConvertKeyMapAsMappableSheet[ForEach.Value]\"]"]

        return ja
    }

    member:jsonvalueref ConvertMenus()
    {
        variable jsonvalue ja="[]"
        ISBProfile.Get[Menu]:ForEach["ja:AddByRef[\"This.ConvertMenu[ForEach.Value]\"]"]

        return ja
    }

    member:jsonvalueref ConvertMenuButtonSets()
    {
        variable jsonvalue ja="[]"
        ISBProfile.Get[MenuButtonSet]:ForEach["ja:AddByRef[\"This.ConvertMenuButtonSet[ForEach.Value]\"]"]

        return ja
    }

    member:jsonvalueref ConvertMenuHotkeySets()
    {
        variable jsonvalue ja="[]"
        ISBProfile.Get[MenuHotkeySet]:ForEach["ja:AddByRef[\"This.ConvertMenuHotkeySet[ForEach.Value]\"]"]

        return ja
    }

    member:jsonvalueref ConvertMenuTemplates()
    {
        variable jsonvalue ja="[]"
        ISBProfile.Get[MenuTemplate]:ForEach["ja:AddByRef[\"This.ConvertMenuTemplate[ForEach.Value]\"]"]

        return ja
    }

    member:jsonvalueref ConvertRepeaterProfiles()
    {
        variable jsonvalue ja="[]"
        ISBProfile.Get[RepeaterProfile]:ForEach["ja:AddByRef[\"This.ConvertRepeaterProfile[ForEach.Value]\"]"]
        return ja
    }

    member:jsonvalueref ConvertWindowLayouts()
    {
        variable jsonvalue ja="[]"
        ISBProfile.Get[WindowLayout]:ForEach["ja:AddByRef[\"This.ConvertWindowLayout[ForEach.Value]\"]"]
        return ja
    }

    member:jsonvalueref ConvertWoWMacroSets()
    {
        variable jsonvalue ja="[]"
        ISBProfile.Get[WoWMacroSet]:ForEach["ja:AddByRef[\"This.ConvertWoWMacroSet[ForEach.Value]\"]"]
        return ja
    }

    member:jsonvalueref ConvertCrypticMacroSets()
    {
        variable jsonvalue ja="[]"
        ISBProfile.Get[CrypticMacroSet]:ForEach["ja:AddByRef[\"This.ConvertCrypticMacroSet[ForEach.Value]\"]"]
        return ja
    }

    member:jsonvalueref ConvertVariableKeystrokes()
    {
        variable jsonvalue ja="[]"
        ISBProfile.Get[VariableKeystroke]:ForEach["ja:AddByRef[\"This.ConvertVariableKeystroke[ForEach.Value]\"]"]
        return ja
    }

    member:jsonvalueref ConvertVideoFXSheets()
    {
        variable jsonvalue ja="[]"
        ; ISBProfile.Get[VariableKeystroke]:ForEach["ja:AddByRef[\"This.ConvertVariableKeystroke[ForEach.Value]\"]"]


        return ja
    }
#endregion

#region Individual Conversion -- TODO
    member:jsonvalueref ConvertCharacter(jsonvalueref jo)
    {
;        echo "\agConvertCharacter\ax ${jo~}"
        variable jsonvalue joNew="{}"

        joNew:SetString[name,"${jo.Get[Name]~}"]
        if ${jo.Has[ActualName]}
            joNew:SetString[actualName,"${jo.Get[ActualName]~}"]

        if ${jo.Has[SubAccountName]}
        {
            if ${jo.Has[AccountName]}
                joNew:SetString[email,"${jo.Get[AccountName]~}"]

            joNew:SetString[accountName,"${jo.Get[SubAccountName]~}"]
        }
        elseif ${jo.Has[AccountName]}
        {
            variable string accountName
            accountName:Set["${jo.Get[AccountName]~}"]
            if ${accountName.Find["@"]}
                joNew:SetString[email,"${accountName~}"]
            else
                joNew:SetString[accountName,"${accountName~}"]
        }

        if ${jo.Has[muteBroadcasts]}
            joNew:SetBool[muteBroadcasts,${jo.GetBool[muteBroadcasts]}]
        if ${jo.Has[videoFeedViewersPermanent]}
            joNew:SetBool[vfxViewersPermanent,${jo.GetBool[videoFeedViewersPermanent]}]

        if ${jo.Has[ServerName]}
            joNew:SetString[gameServer,"${jo.Get[ServerName]~}"]

        if ${jo.Has[VirtualFileTargets]}
            joNew:SetByRef["virtualFiles","jo.Get[VirtualFileTargets]"]

        if ${jo.Has[RelayGroupStrings]}
            joNew:SetByRef[targetGroups,"jo.Get[RelayGroupStrings]"]

        if ${jo.Has[KeyMapStrings]}
        {
            joNew:SetByRef[hotkeySheets,"jo.Get[KeyMapStrings]"]
            joNew:SetByRef[mappableSheets,"jo.Get[KeyMapStrings]"]
        }

        if ${jo.Has[ClickBarStrings]}
            joNew:SetByRef[clickBars,"jo.Get[ClickBarStrings]"]


        if ${jo.Has[executeOnLoad]}
        {
            variable jsonvalue joAction="{}"
            joAction:SetString[type,mappable]
            if ${jo.Has[executeOnLoad,Target]}
                joAction:SetString[target,"${jo.Get[executeOnLoad,Target]~}"]

            joAction:SetString[sheet,"${jo.Get[executeOnLoad,KeyMapString]~}"]
            joAction:SetString[name,"${jo.Get[executeOnLoad,MappedKeyString]~}"]

            joNew:SetByRef[onLoad,joAction]
        }

        joNew:SetString[game,"${jo.Get[KnownGame]~}"]

        variable jsonvalue ja
        if ${jo.Has[VariableKeystrokeInstances]}
        {
            ja:SetValue["[]"]
            jo.Get[VariableKeystrokeInstances]:ForEach["This:ConvertVariableKeystrokeInto[ja,ForEach.Value]"]
            joNew:SetByRef[gameKeyBindings,ja]
        }        

        if ${jo.Has[KeyMapWhiteOrBlackListType]} && ${jo.Get[KeyMapWhiteOrBlackListType]~.NotEqual[Ignore]}
        {
            joNew:SetString[mappableSheetWhiteOrBlackListType,"${jo.Get[KeyMapWhiteOrBlackListType]~}"]
            joNew:SetString[hotkeySheetWhiteOrBlackListType,"${jo.Get[KeyMapWhiteOrBlackListType]~}"]

            if ${jo.Has[KeyMapWhiteOrBlackList]}
            {
                ja:SetValue["[]"]
                jo.Get[KeyMapWhiteOrBlackList]:ForEach["ja:AddString[\"\${ForEach.Value.Get[KeyMapString]}\"]"]

                joNew:SetByRef[mappableSheetWhiteOrBlackList,ja]
                joNew:SetByRef[hotkeySheetWhiteOrBlackList,ja]
            }
        }

        if ${jo.Has[VirtualMappedKeys]}
            joNew:SetByRef[virtualMappables,"jo.Get[VirtualMappedKeys]"]

        if ${jo.Has[MenuInstances]}
        {
            ja:SetValue["[]"]
            jo.Get[MenuInstances]:ForEach["ja:AddString[\"\${ForEach.Value.Get[MenuString]}\"]"]

            joNew:SetByRef[menus,ja]
        }

        variable jsonvalue joGLI="{}"
        joGLI:SetString[game,"${jo.Get[Game]~}"]
        joGLI:SetString[gameProfile,"${jo.Get[GameProfile]~}"]

        if ${jo.Has[AppendParameters]}
            joGLI:SetString[appendParameters,"${jo.Get[AppendParameters]~}"]

        joNew:SetByRef[gameLaunchInfo,joGLI]
        return joNew
    }

    member:jsonvalueref ConvertCharacterSet(jsonvalueref jo)
    {
;        echo "\agConvertCharacterSet\ax ${jo~}"
        variable jsonvalue joNew="{}"

        joNew:SetString[name,"${jo.Get[Name]~}"]

        if ${jo.Has[Description]}
            joNew:SetString[description,"${jo.Get[Description]~}"]

        if ${jo.Has[CursorClippingMode]}
        {
            switch ${jo.Get[CursorClippingMode]~}
            {
                case On
                    joNew:SetBool[clipCursor,1]
                    break
                case Off
                    joNew:SetBool[clipCursor,0]
                    break
            }
        }

        if ${jo.Has[ComputerString]}
            joNew:SetString[computer,"${jo.Get[ComputerString]~}"]

        if ${jo.Has[RepeaterProfile]}
            joNew:SetString[broadcastProfile,"${jo.Get[RepeaterProfile]~}"]

        if ${jo.Get[WindowLayout,WindowLayoutString].NotNULLOrEmpty}
            joNew:SetString[windowLayout,"${jo.Get[WindowLayout,WindowLayoutString]~}"]

        if ${jo.Has[VirtualFileTargets]}
            joNew:SetByRef["virtualFiles","jo.Get[VirtualFileTargets]"]

        if ${jo.Has[KeyMapStrings]}
        {
            joNew:SetByRef[hotkeySheets,"jo.Get[KeyMapStrings]"]
            joNew:SetByRef[mappableSheets,"jo.Get[KeyMapStrings]"]
        }

        if ${jo.Has[ClickBarStrings]}
            joNew:SetByRef[clickBars,"jo.Get[ClickBarStrings]"]

        if ${jo.Has[LaunchCharacterSetStrings]}
            joNew:SetByRef[alsoLaunch,"jo.Get[LaunchCharacterSetStrings]"]

        variable jsonvalue ja
        if ${jo.Has[VariableKeystrokeInstances]}
        {
            ja:SetValue["[]"]
            jo.Get[VariableKeystrokeInstances]:ForEach["This:ConvertVariableKeystrokeInto[ja,ForEach.Value]"]
            joNew:SetByRef[gameKeyBindings,ja]
        }        

        if ${jo.Has[KeyMapWhiteOrBlackListType]} && ${jo.Get[KeyMapWhiteOrBlackListType]~.NotEqual[Ignore]}
        {
            joNew:SetString[mappableSheetWhiteOrBlackListType,"${jo.Get[KeyMapWhiteOrBlackListType]~}"]
            joNew:SetString[hotkeySheetWhiteOrBlackListType,"${jo.Get[KeyMapWhiteOrBlackListType]~}"]

            if ${jo.Has[KeyMapWhiteOrBlackList]}
            {
                ja:SetValue["[]"]
                jo.Get[KeyMapWhiteOrBlackList]:ForEach["ja:AddString[\"\${ForEach.Value.Get[KeyMapString]}\"]"]

                joNew:SetByRef[mappableSheetWhiteOrBlackList,ja]
                joNew:SetByRef[hotkeySheetWhiteOrBlackList,ja]
            }
        }

        if ${jo.Has[VirtualMappedKeys]}
            joNew:SetByRef[virtualMappables,"jo.Get[VirtualMappedKeys]"]

        if ${jo.Has[MenuInstances]}
        {
            ja:SetValue["[]"]
            jo.Get[MenuInstances]:ForEach["ja:AddString[\"\${ForEach.Value.Get[MenuString]}\"]"]

            joNew:SetByRef[menus,ja]
        }      

        if ${jo.Has[guiToggleCombo,Combo]}
            joNew:SetString[guiToggleCombo,"${jo.Get[guiToggleCombo,Combo]~}"]

        if !${jo.Has[useConsoleToggleCombo]} || ${jo.GetBool[useConsoleToggleCombo]}
        {
            if ${jo.Has[consoleToggleCombo,Combo]}
                joNew:SetString[consoleToggleCombo,"${jo.Get[consoleToggleCombo,Combo]~}"]
        }
        if ${jo.Has[videoFXFocusCombo,Combo]}
            joNew:SetString[vfxFocusCombo,"${jo.Get[videoFXFocusCombo,Combo]~}"]

        if ${jo.Has[executeOnLoad]}
        {
            variable jsonvalue joAction="{}"
            joAction:SetString[type,mappable]
            if ${jo.Has[executeOnLoad,Target]}
                joAction:SetString[target,"${jo.Get[executeOnLoad,Target]~}"]

            joAction:SetString[sheet,"${jo.Get[executeOnLoad,KeyMapString]~}"]
            joAction:SetString[name,"${jo.Get[executeOnLoad,MappedKeyString]~}"]

            joNew:SetByRef[onLastSlotLoaded,joAction]
        }

        if ${jo.Has[launchDelay]} && ${jo.GetNumber[launchDelay]}
            joNew:SetNumber[launchDelay,"${jo.GetNumber[launchDelay]}"]

        if ${jo.Has[dynamicLaunchMode]}
            joNew:SetBool[dynamicLaunchMode,"${jo.GetBool[dynamicLaunchMode]}"]

; unused setting
;        if ${jo.Has[lockWindow]}
;            joNew:SetBool[lockWindow,"${jo.GetBool[lockWindow]}"]

        if ${jo.Has[lockForeground]}
            joNew:SetBool[lockForeground,"${jo.GetBool[lockForeground]}"]

        if ${jo.Has[disableJambaTeamManagement]}
            joNew:SetBool[disableJambaTeamManagement,"${jo.GetBool[disableJambaTeamManagement]}"]

        if ${jo.Has[disableFPSIndicator]}
            joNew:SetBool[disableFPSIndicator,"${jo.GetBool[disableFPSIndicator]}"]

        if ${jo.Has[disableForceWindowed]}
            joNew:SetBool[disableForceWindowed,"${jo.GetBool[disableForceWindowed]}"]

        if ${jo.Has[autoMuteBackground]}
            joNew:SetBool[autoMuteBackground,"${jo.GetBool[autoMuteBackground]}"]

        if ${jo.Has[enforceSingleWindowControl]} && ${jo.GetBool[enforceSingleWindowControlTested]}
            joNew:SetBool[enforceSingleWindowControl,"${jo.GetBool[enforceSingleWindowControl]}"]


        variable jsonvalue jaSlots="[]"
        jo.Get[Slots]:ForEach["jaSlots:AddByRef[\"This.ConvertCharacterSetSlot[joNew,ForEach.Value]\"]"]
        if ${jaSlots.Used}
            joNew:SetByRef[slots,jaSlots]        
        return joNew
    }

    member:jsonvalueref ConvertCharacterSetSlot(jsonvalueref joCharacterSet, jsonvalueref jo)
    {
;        echo "\agConvertCharacterSetSlot\ax ${jo~}"
        variable jsonvalue joNew="{}"

        if ${jo.Has[CharacterString]}
            joNew:SetString[character,"${jo.Get[CharacterString]~}"]
        if ${jo.Has[foregroundMaxFPS]}
            joNew:SetInteger[foregroundFPS,"${jo.GetInteger[foregroundMaxFPS]~}"]
        if ${jo.Has[backgroundMaxFPS]}
            joNew:SetInteger[backgroundFPS,"${jo.GetInteger[backgroundMaxFPS]~}"]

        if ${jo.Has[switchToCombo,Combo]}
            joNew:SetString[switchToCombo,"${jo.Get[switchToCombo,Combo]~}"]

        if ${jo.Has[switchToComboIsGlobal]}
            joNew:SetBool[switchToComboIsGlobal,"${jo.GetBool[switchToComboIsGlobal]}"]

        if ${jo.Has[effectType]}
            joNew:SetString[switchToEffectType,"${jo.Get[effectType]~}"]

        variable jsonvalue joAction="{}"
        if ${jo.Has[switchToEffect,Combo]}
        {
            joAction:SetString["type","keystroke"]
            joAction:SetString["target","all other"]
            joAction:SetString["keyCombo","${jo.Get[switchToEffect,Combo]~}"]

            joNew:SetByRef[onSwitchTo,joAction]
        }
        elseif ${jo.Has[SwitchToKeyMapString]}
        {
            joAction:SetString["type","mappable"]
            joAction:SetString["sheet","${jo.Get[SwitchToKeyMapString]~}"]
            joAction:SetString["name","${jo.Get[SwitchToMappedKeyString]~}"]

            joNew:SetByRef[onSwitchTo,joAction]
        }
        
        if ${jo.Has[WindowTitle]}
            joNew:SetString[windowTitle,"${jo.Get[WindowTitle]~}"]

        if ${jo.Has[FTLModifiers]}
            joNew:SetByRef[ftlModifiers,"jo.Get[FTLModifiers]"]

        variable jsonvalue ja="[]"
        if ${jo.Has[VariableKeystrokeInstances]}
        {
            jo.Get[VariableKeystrokeInstances]:ForEach["This:ConvertVariableKeystrokeInto[ja,ForEach.Value]"]
            joNew:SetByRef[gameKeyBindings,ja]
        }

        if ${jo.Has[CPUCores]}
        {
            ja:SetValue["[]"]
            jo.Get[CPUCores]:ForEach["ja:AddInteger[\"\${ForEach.Value~}\"]"]
            joNew:SetByRef[cpuCores,ja]
        }

        
        ; check for ClickBars file
        ; check for Repeater Regions file
        ; check for Video FX file
        This:ConvertSlotClickBars[joCharacterSet,joNew]
        This:ConvertSlotRepeaterRegions[joCharacterSet,joNew]
        This:ConvertSlotVFXSheets[joCharacterSet,joNew]

;        joNew:SetByRef[original,jo]
        return joNew
    }

    method ConvertSlotVFX(jsonvalueref joCharacterSet,jsonvalueref joSlot,jsonvalueref joSheet, jsonvalueref joVFX)
    {
        echo "ConvertSlotVFX ${joVFX~}"
        switch ${joVFX.Get[type]}
        {
            case feedoutput
                if !${joSheet.Has[outputs]}
                    joSheet:Set[outputs,"[]"]

                if ${joVFX.Has[regionName]}
                    joVFX:SetString[name,"${joVFX.Get[regionName]~}"]
                else
                    joVFX:SetString[name,"${joSlot.Get[character]~}.${joVFX.Get[name]~}"]

                joVFX:SetString[feedName,"${joVFX.Get[feedOutput]~}"]

                joVFX:Erase[feedOutput]
                joVFX:Erase[type]
                joSheet.Get[outputs]:AddByRef[joVFX]
                break
            case feedsource
                if !${joSheet.Has[sources]}
                    joSheet:Set[sources,"[]"]

                if ${joVFX.Has[regionName]}
                    joVFX:SetString[name,"${joVFX.Get[regionName]~}"]
                else
                    joVFX:SetString[name,"${joSlot.Get[character]~}.${joVFX.Get[name]~}"]

                joVFX:SetString[feedName,"${joVFX.Get[feedSource]~}"]

                joVFX:Erase[feedSource]
                joVFX:Erase[type]
                joSheet.Get[sources]:AddByRef[joVFX]
                break
        }
    }

    method ConvertSlotVFXSheet(jsonvalueref joCharacterSet,jsonvalueref joSlot,jsonvalueref joSheet)
    {
        variable string name="${joSheet.Get[name]~}"
        variable jsonvalueref joNew="{}"

        joNew:SetString[name,"${joCharacterSet.Get[name]~}.${joSlot.Get[character]~}.${name~}"]

        if ${name.Equal[Auto]}
        {
            variable jsonvalue ja="[]"
            ja:AddString["${joNew.Get[name]~}"]
            joSlot:SetByRef["vfxSheets",ja]
        }

        joSheet.Get[vfx]:ForEach["This:ConvertSlotVFX[joCharacterSet,joSlot,joNew,ForEach.Value]"]

        ISBProfile.Get[vfxSheets]:AddByRef[joNew]        
    }

    method ConvertSlotVFXSheets(jsonvalueref joCharacterSet,jsonvalueref joSlot)
    {
        variable jsonvalueref jo        
        variable filepath filename="${LavishScript.HomeDirectory~}/Scripts/ISBoxer.VideoFeeds.${joCharacterSet.Get[name]~}.${joSlot.Get[character]~}.XML"
        if !${filename.PathExists}
            return

        jo:SetReference["This.TransformVideoFXXML[\"${filename~}\"]"]
        
        if !${jo.Reference(exists)}
            return

        echo "\ayConvertSlotVFX ${jo~}"

        if !${jo.Get[vfxSheets].Used}
            return

        if !${ISBProfile.Has[vfxSheets]}
            ISBProfile:Set[vfxSheets,"[]"]

        ; we have multiple sheets, which we need to alter the name for
        jo.Get[vfxSheets]:ForEach["This:ConvertSlotVFXSheet[joCharacterSet,joSlot,ForEach.Value]"]        
    }

    member:jsonvalueref ConvertKeyMapAsMappableSheet(jsonvalueref jo)
    {
;        echo "ConvertKeyMapAsMappableSheet ${jo~}"        
        if !${jo.Get[Mappings].Used}
        {
            return NULL
        }

        variable jsonvalue joNew="{}"
        joNew:SetString[name,"${jo.Get[Name]~}"]

        if ${jo.Has[hold]}
            joNew:SetBool[hold,${jo.GetBool[hold]}]

        if ${jo.Has[mode]}
            joNew:SetString[mode,"${jo.Get[mode]~}"]

        variable jsonvalue ja="[]"

        jo.Get[Mappings]:ForEach["This:ConvertMappedKeyAsMappableInto[ja,joNew,ForEach.Value]"]

        if !${ja.Used}
            return NULL

        joNew:SetByRef[mappables,ja]    
        return joNew
    }

    member:jsonvalueref ConvertKeyMapAsHotkeySheet(jsonvalueref jo)
    {
;        echo "ConvertKeyMapAsHotkeySheet ${jo~}"
        if !${jo.Get[Mappings].Used}
        {
            return NULL
        }

        variable jsonvalue joNew="{}"
        joNew:SetString[name,"${jo.Get[Name]~}"]
        joNew:SetBool[enable,1]

        variable jsonvalue ja="[]"

        jo.Get[Mappings]:ForEach["This:ConvertMappedKeyAsHotkeyInto[ja,joNew,ForEach.Value]"]

        if !${ja.Used}
            return NULL

        joNew:SetByRef[hotkeys,ja]    
        return joNew
    }

    member:jsonvalueref ConvertActionTimerPool(jsonvalueref jo)
    {
        echo "\arConvertActionTimerPool\ax ${jo~}"

        return NULL
    }

    member:jsonvalueref ConvertClickBarButton(jsonvalueref jo)
    {
        echo "\arConvertClickBarButton\ax ${jo~}"

        variable jsonvalue joNew="{}"
        if ${jo.Has[name]}
            joNew:SetString[name,"${jo.Get[name]~}"]
        if ${jo.Has[text]}
            joNew:SetString[text,"${jo.Get[text]~}"]
        if ${jo.Has[enabled]}
            joNew:SetBool[enabled,"${jo.GetBool[enabled]~}"]

        if ${jo.Has[backgroundColor]}
            joNew:SetString[backgroundColor,"${jo.Get[backgroundColor]~}"]

        if ${jo.Has[clickThrough]}
            joNew:SetbBool[clickThrough,"${jo.GetBool[clickThrough]}"]

        variable jsonvalue ja="[]"
        if ${jo.Has[ClickActions]}
        {
            jo.Get[ClickActions]:ForEach["ja:AddByRef[\"This.ConvertClickAction[ForEach.Value]\"]"]            

            if ${ja.Used}
                joNew:SetByRef[clicks,ja]    
        }        

/*
; TODO
        This:AutoTransform[joTransform,TextStyle,ClickBarButton]

        This:AutoTransform[joTransform,MouseOverAction,ClickBarButton]
*/
        return joNew
    }

    member:jsonvalueref ConvertClickBar(jsonvalueref jo)
    {
        echo "\agConvertClickBar\ax ${jo~}"

        variable jsonvalue joNew="{}"
        joNew:SetString[name,"${jo.Get[Name]~}"]
        if ${jo.Has[enable]}
            joNew:SetBool[enable,"${jo.GetBool[enable]}"]

        if ${jo.Has[alpha]}
            joNew:SetInteger[alpha,"${jo.GetInteger[alpha]}"]
        if ${jo.Has[x]}
            joNew:SetInteger[x,"${jo.GetInteger[x]}"]
        if ${jo.Has[y]}
            joNew:SetInteger[y,"${jo.GetInteger[y]}"]
        if ${jo.Has[rows]}
            joNew:SetInteger[rows,"${jo.GetInteger[rows]}"]
        if ${jo.Has[columns]}
            joNew:SetInteger[columns,"${jo.GetInteger[columns]}"]
        if ${jo.Has[rowHeight]}
            joNew:SetInteger[rowHeight,"${jo.GetInteger[rowHeight]}"]
        if ${jo.Has[columnWidth]}
            joNew:SetInteger[columnWidth,"${jo.GetInteger[columnWidth]}"]

        variable jsonvalue ja="[]"
        if ${jo.Has[Buttons]}
        {
            jo.Get[Buttons]:ForEach["ja:AddByRef[\"This.ConvertClickBarButton[ForEach.Value]\"]"]            

            if ${ja.Used}
                joNew:SetByRef[buttons,ja]    
        }        

        return joNew
    }

    member:jsonvalueref ConvertClickBarImage(jsonvalueref jo)
    {
        echo "\arConvertClickBarImage\ax ${jo~}"

        return NULL
    }

    member:jsonvalueref ConvertUserScreen(jsonvalueref jo)
    {
        echo "\agConvertUserScreen\ax ${jo~}"

        variable jsonvalue joNew="{}"

        joNew:SetString[deviceName,"${jo.Get[deviceName]~}"]

        if ${jo.Has[primary]}
            joNew:SetBool[primary,${jo.GetBool[primary]}]

        if ${jo.Has[bounds]}
            joNew:Set[bounds,"${jo.Get[bounds]~}"]
        if ${jo.Has[workingArea]}
            joNew:Set[workingArea,"${jo.Get[workingArea]~}"]

        return joNew
    }

    member:jsonvalueref ConvertUserScreenSet(jsonvalueref jo)
    {
        echo "\agConvertUserScreenSet\ax ${jo~}"

        variable jsonvalue joNew="{}"

        if ${jo.Has[name]}
            joNew:SetString[name,"${jo.Get[name]~}"]
        
        variable jsonvalue ja="[]"
        if ${jo.Has[AllScreens]}
        {
            jo.Get[AllScreens]:ForEach["ja:AddByRef[\"This.ConvertUserScreen[ForEach.Value]\"]"]            

            if ${ja.Used}
                joNew:SetByRef[screens,ja]    
        }        

        return joNew
    }

    member:jsonvalueref ConvertComputer(jsonvalueref jo)
    {
        echo "\agConvertComputer\ax ${jo~}"
        variable jsonvalue joNew="{}"

        joNew:SetString[name,"${jo.Get[name]~}"]
        if ${jo.Has[host]}
            joNew:SetString[host,"${jo.Get[host]~}"]
        if ${jo.Has[port]}
            joNew:SetInteger[port,"${jo.GetInteger[port]}"]
        if ${jo.Has[processorCount]}
            joNew:SetInteger[cpuCount,"${jo.GetInteger[processorCount]}"]

        if ${jo.Has[ScreenSet]}
        {
            joNew:SetByRef["screenSet","This.ConvertUserScreenSet[\"jo.Get[ScreenSet]\"]"]
        }

        return joNew
    }

    member:jsonvalueref ConvertRepeaterProfile(jsonvalueref jo)
    {
        echo "\agConvertRepeaterProfile\ax ${jo~}"
        variable jsonvalue joNew="{}"

        joNew:SetString[name,"${jo.Get[Name]~}"]
        if ${jo.Has[Description]}
            joNew:SetString[description,"${jo.Get[Description]~}"]

        if ${jo.Has[WhiteOrBlackListType]} && !${jo.Assert[WhiteOrBlackListType,"\"Ignore\""]}
            joNew:SetString[whiteOrBlackListType,"${jo.Get[WhiteOrBlackListType]~}"]

        if ${jo.Has[cursorColorMask]} && !${jo.Assert[cursorColorMask,"\"#ffffff\""]}
            joNew:SetString[cursorColorMask,"${jo.Get[cursorColorMask]~}"]

        if ${jo.Has[cursorFeedBorder]} && !${jo.Assert[cursorFeedBorder,"\"#ffffff\""]}
            joNew:SetString[cursorFeedBorder,"${jo.Get[cursorFeedBorder]~}"]

        if ${jo.Has[cursorFeedSourceSize]} && ${jo.GetInteger[cursorFeedSourceSize,Width]} && ${jo.GetInteger[cursorFeedSourceSize,Height]}
            joNew:Set[cursorFeedSourceSize,"[${jo.GetInteger[cursorFeedSourceSize,Width]},${jo.GetInteger[cursorFeedSourceSize,Height]}]"]

        if ${jo.Has[cursorFeedOutputSize]} && ${jo.GetInteger[cursorFeedOutputSize,Width]} && ${jo.GetInteger[cursorFeedOutputSize,Height]}
            joNew:Set[cursorFeedOutputSize,"[${jo.GetInteger[cursorFeedOutputSize,Width]},${jo.GetInteger[cursorFeedOutputSize,Height]}]"]

        if ${jo.Has[cursorFeedAlpha]}
            joNew:SetInteger[cursorFeedAlpha,"${jo.GetInteger[cursorFeedAlpha]~}"]

        if ${jo.Has[RepeaterTarget]}
            joNew:SetString[broadcastTarget,"${jo.Get[RepeaterTarget]~}"]

        if ${jo.Has[mouseTransformMode]}
            joNew:SetString[mouseTransformMode,"${jo.Get[mouseTransformMode]~}"]

        if ${jo.Has[mouseLight]}
            joNew:SetString[mouseLight,"${jo.Get[mouseLight]~}"]

        if ${jo.Has[keyboardLight]}
            joNew:SetString[keyboardLight,"${jo.Get[keyboardLight]~}"]

        if ${jo.Has[blockLocal]}
            joNew:SetBool[blockLocal,${jo.GetBool[blockLocal]}]

        if ${jo.Has[muteCursorWhenForeground]}
            joNew:SetBool[muteCursorWhenForeground,${jo.GetBool[muteCursorWhenForeground]}]

        if ${jo.Has[videoFXAlwaysAffectsBroadcasting]}
            joNew:SetBool[videoFXAlwaysAffectsBroadcasting,${jo.GetBool[videoFXAlwaysAffectsBroadcasting]}]

        if ${jo.Has[keyRepeatEnabled]}
            joNew:SetBool[keyBroadcastEnabled,${jo.GetBool[keyBroadcastEnabled]}]

        if ${jo.Has[mouseRepeatEnabled]}
            joNew:SetBool[mouseBroadcastEnabled,${jo.GetBool[mouseBroadcastEnabled]}]

        if ${jo.Has[falseCursor]}
            joNew:SetBool[falseCursor,${jo.GetBool[falseCursor]}]

        if ${jo.Has[cursorFeed]}
            joNew:SetBool[cursorFeed,${jo.GetBool[cursorFeed]}]

        if ${jo.Has[WhiteOrBlackList]}
        {
                variable jsonvalue ja="[]"

                jo.Get[WhiteOrBlackList]:ForEach["This:AddConvertedISKey[ja,ForEach.Value]"]

                joNew:SetByRef[whiteOrBlackList,ja]

        }

        return joNew
    }

    method ConvertVariableKeystrokeInto(jsonvalueref ja, jsonvalueref jo)
    {
;        echo ConvertVariableKeystrokeInto
        variable jsonvalueref joNew="This.ConvertVariableKeystroke[jo]"
        if !${joNew.Reference(exists)}
            return

        ja:AddByRef[joNew]
    }

    member:jsonvalueref ConvertVariableKeystroke(jsonvalueref jo)
    {
;        echo "\agConvertVariableKeystroke\ax ${jo~}"

        variable jsonvalue joNew="{}"

        joNew:SetString[name,"${jo.Get[Name]~}"]
        if ${jo.Has[Description]}
            joNew:SetString[description,"${jo.Get[Description]~}"]
        if ${jo.Has[Category]}
            joNew:SetString[category,"${jo.Get[Category]~}"]
        ; applies to globally defined variable keystrokes
        if ${jo.Has[defaultValue,Combo]}
            joNew:SetString[keyCombo,"${jo.Get[defaultValue,Combo]~}"]
        ; applies to overrides (e.g. per slot)
        if ${jo.Has[combo,Combo]}
            joNew:SetString[keyCombo,"${jo.Get[combo,Combo]~}"]
        if ${jo.Has[Combo,Combo]}
            joNew:SetString[keyCombo,"${jo.Get[Combo,Combo]~}"]

        return joNew
    }

    method ConvertWindowLayoutRegion(jsonvalueref jaRegions,jsonvalueref jo)
    {  
        variable jsonvalue joNew="${jo~}"

        joNew:Set[bounds,"${jo.Get[rect]~}"]

        if ${jo.Has[characterSetSlot]}
            joNew:SetInteger[slot,"${jo.Get[characterSetSlot]}"]

        if ${jo.Has[borderStyle]}
            joNew:SetString[frame,"${jo.Get[borderStyle]~}"]

        joNew:Erase[rect]
        joNew:Erase[characterSetSlot]

        jaRegions:AddByRef[joNew]    
    }

    method ConvertWindowLayoutSwapGroup(jsonvalueref jaSwapGroups,jsonvalueref jo)
    {  
        variable jsonvalue joNew="{}"

        variable int resetRegion
        variable int activeRegion
        resetRegion:Set["${jo.GetInteger[resetRegion]}+1"]
        activeRegion:Set["${jo.GetInteger[activeRegion]}+1"]

        joNew:SetInteger["reset",${resetRegion}]
        joNew:SetInteger["active",${activeRegion}]

        if ${jo.Has[deactivateSwapGroup]}
            joNew:SetInteger[deactivateSwapGroup,"${jo.GetInteger[deactivateSwapGroup]}"]

        if ${jo.Has[pipSqueakSlot]}
            joNew:SetInteger[roamingSlot,"${jo.GetInteger[pipSqueakSlot]}"]

        jaSwapGroups:AddByRef[joNew]
    }

    member:jsonvalueref ConvertWindowLayout(jsonvalueref jo)
    {
        echo "\agConvertWindowLayout\ax ${jo~}"
        variable jsonvalue joNew="{}"
    
;        joNew:SetByRef[original,jo]

        joNew:SetString[name,"${jo.Get[name]~}"]
        joNew:SetString[description,"${jo.Get[description]~}"]
        
        variable jsonvalueref jaRegions="[]"
        jo.Get[Regions]:ForEach["This:ConvertWindowLayoutRegion[jaRegions,ForEach.Value]"]
        joNew:SetByRef[regions,jaRegions]

        variable jsonvalueref jaSwapGroups="[]"
        jo.Get[SwapGroups]:ForEach["This:ConvertWindowLayoutSwapGroup[jaSwapGroups,ForEach.Value]"]
        joNew:SetByRef[swapGroups,jaSwapGroups]

        variable jsonvalueref joSettings="{}"
        ; all ISB1 window layouts default to no frame
        joSettings:SetString[frame,none]

        joSettings:SetBool[focusFollowsMouse,"${jo.GetBool[focusFollowsMouse]}"]
        joSettings:SetBool[instantSwap,"${jo.GetBool[instantSwap]}"]

        if ${jo.Has[swapMode]}
        {
            switch ${jo.Get[swapMode]}
            {
                case Never
                    break
                case Always
;                    joSettings:SetBool[refreshOnActivate,1]
                    joSettings:SetBool[swapOnActivate,1]

;                    joSettings:SetBool[refreshOnDeactivate,1]
                    joSettings:SetBool[swapOnDeactivate,1]
                    break
                case AlwaysForGames
;                    joSettings:SetBool[refreshOnActivate,1]
                    joSettings:SetBool[swapOnActivate,1]

;                    joSettings:SetBool[refreshOnDeactivate,1]
;                    joSettings:SetBool[swapOnDeactivate,1]
                    break
                case SlotActivate
                    joSettings:SetBool[swapOnSlotActivate,1]
                    break
                case SpecificHotkey
                    break
                case AnyInternal
                    joSettings:SetBool[swapOnInternalActivate,1]
                    break
            }

/*
            [Description("never")]
            Never,
            [Description("always")]
            Always,
            [Description("always, for game windows")]
            AlwaysForGames,
            [Description("only when I press a Slot activate hotkey")]
            SlotActivate,
            [Description("only when I press the Activate Current Window Hotkey")]
            SpecificHotkey,
            [Description("any time ISBoxer focuses a window")]
            AnyInternal,
*/
            joSettings:SetString[swapMode,"${jo.Get[swapMode]~}"]
        }

        joNew:SetByRef[settings,joSettings]


        return joNew
    }

    member:jsonvalueref ConvertWoWMacroSet(jsonvalueref jo)
    {
;        echo "\agConvertWoWMacroSet\ax ${jo~}"

        if !${jo.Get[WoWMacros].Used}
        {
            return NULL
        }

        variable jsonvalue joNew="{}"
        joNew:SetString[name,"${jo.Get[Name]~}"]
        joNew:SetString[game,"World of Warcraft"]
        if ${jo.Has[Description]}
            joNew:SetString[description,"${jo.Get[Description]~}"]

        variable jsonvalue ja="[]"

        jo.Get[WoWMacroSet]:ForEach["This:ConvertWoWMacroInto[ja,ForEach.Value]"]

        if !${ja.Used}
            return NULL

        joNew:SetByRef[macros,ja]    
        return joNew
    }

    method ConvertWoWMacroInto(jsonvalueref ja, jsonvalueref jo)
    {
;        echo "\agConvertWoWMacroInto\ax ${jo~}"

        variable jsonvalue joNew="{}"
        joNew:SetString[name,"${jo.Get[Name]~}"]
        joNew:SetString[colloquialName,"${jo.Get[ColloquialName]~}"]
        joNew:SetString[description,"${jo.Get[Description]~}"]
        joNew:SetString[commands,"${jo.Get[MacroCommands]~}"]
        joNew:SetBool[useFTLModifiers,"${jo.GetBool[useFTLModifiers]}"]

        if ${jo.Has[AllowCustomModifiers]}
            joNew:SetByRef[allowCustomModifiers,"jo.Get[AllowCustomModifiers]"]

        if ${jo.Has[combo,Combo]}
            joNew:SetString[keyCombo,"${jo.Get[combo,Combo]~}"]

        ja:AddByRef[joNew]
    }

    member:jsonvalueref ConvertCrypticMacroSet(jsonvalueref jo)
    {
        echo "\arConvertCrypticMacroSet\ax ${jo~}"

        return NULL
    }

    member:jsonvalueref ConvertMenu(jsonvalueref jo)
    {
        echo "\agConvertMenu\ax ${jo~}"
        variable jsonvalue joNew="{}"

        joNew:SetString[name,"${jo.Get[Name]~}"]
        if ${jo.Has[Template]}
            joNew:SetString[template,"${jo.Get[Template]~}"]
        if ${jo.Has[ButtonLayout]}
            joNew:SetString[buttonLayout,"${jo.Get[ButtonLayout]~}"]
        if ${jo.Has[HotkeyLayout]}
            joNew:SetString[hotkeyLayout,"${jo.Get[HotkeyLayout]~}"]

        if ${jo.Has[x]}
            joNew:SetInteger[x,${jo.GetInteger[x]}]
        if ${jo.Has[y]}
            joNew:SetInteger[y,${jo.GetInteger[y]}]

        return joNew
    }

    member:jsonvalueref ConvertMenuHotkeySet(jsonvalueref jo)
    {
        echo "\arConvertMenuHotkeySet\ax ${jo~}"

        return NULL
    }

    member:jsonvalueref ConvertMenuTemplate(jsonvalueref jo)
    {
        echo "\arConvertMenuTemplate\ax ${jo~}"

        return NULL
    }

    member:jsonvalueref ConvertMenuButtonSet(jsonvalueref jo)
    {
        echo "\arConvertMenuButtonSet\ax ${jo~}"

        return NULL
    }
#endregion

#region Mapped Key Conversion -- Fully implemented
    method ConvertMappedKeyAsHotkeyInto(jsonvalueref ja, jsonvalueref joMappableSheet, jsonvalueref jo)
    {
;        echo ConvertMappedKeyAsHotkeyInto
        variable jsonvalueref joNew="This.ConvertMappedKeyAsHotkey[joMappableSheet,jo]"
        if !${joNew.Reference(exists)}
            return

        ja:AddByRef[joNew]
    }

    member:jsonvalueref ConvertMappedKeyAsHotkey(jsonvalueref joMappableSheet, jsonvalueref jo)
    {
;        echo "ConvertMappedKeyAsHotkey ${jo~}"

        if !${jo.Has[combo]}
            return NULL

        variable jsonvalue joNew="{}"
        joNew:SetString[name,"${jo.Get[Name]~}"]

        if ${jo.GetBool[manualLoad]}
            joNew:SetBool[enable,0]

        if ${jo.Has[combo,Combo]}
            joNew:SetString[keyCombo,"${jo.Get[combo,Combo]~}"]
        
        variable jsonvalue joInputMapping="{}"

        joInputMapping:SetString[type,mappable]
        joInputMapping:SetString[sheet,"${joMappableSheet.Get[name]~}"]
        joInputMapping:SetString[name,"${jo.Get[Name]~}"]
        
        joNew:SetByRef[inputMapping,joInputMapping]

        return joNew
    }

    method ConvertMappedKeyAsMappableInto(jsonvalueref ja, jsonvalueref joMappableSheet, jsonvalueref jo)
    {
;        echo ConvertMappedKeyAsMappableInto
        variable jsonvalueref joNew="This.ConvertMappedKeyAsMappable[joMappableSheet,jo]"
        if !${joNew.Reference(exists)}
            return

        ja:AddByRef[joNew]
    }

    member:jsonvalueref ConvertMappedKeyAsMappable(jsonvalueref joMappableSheet, jsonvalueref jo)
    {
;        echo "ConvertMappedKeyAsMappable ${jo~}"
        variable jsonvalue joNew="{}"
        joNew:SetString[name,"${jo.Get[Name]~}"]

        if ${jo.Get[Description].NotNULLOrEmpty}
            joNew:SetString[description,"${jo.Get[Description]~}"]

        if ${jo.Has[resetTimer]}
            joNew:SetNumber[resetTimer,"${jo.GetNumber[resetTimer]}"]

        switch ${jo.Get[resetType]}
        {
            case FromFirstPress
                joNew:SetString[resetType,firstPress]
                break
            case FromLastPress
                joNew:SetString[resetType,lastPress]
                break
            case FromFirstAdvance
                joNew:SetString[resetType,firstAdvance]
                break
        }

        if ${jo.Has[hold]}
            joNew:SetBool[hold,${jo.GetBool[hold]}]

        switch ${jo.Get[mode]}
        {
        case OnPressAndRelease
            joNew:SetBool[onRelease,1]
            joNew:SetBool[onPress,1]
            break
        case OnPress
            joNew:SetBool[onPress,1]
            break
        case OnRelease
            joNew:SetBool[onRelease,1]
            break
        }

        variable jsonvalue jaSteps="[]"

        jo.Get[Steps]:ForEach["jaSteps:AddByRef[\"This.ConvertMappedKeyStep[joMappableSheet,joNew,ForEach.Value]\"]"]

        joNew:SetByRef[steps,jaSteps]
        return joNew
    }

    member:jsonvalueref ConvertMappedKeyStep(jsonvalueref joMappableSheet,jsonvalueref joMappable,jsonvalueref jo)
    {
;       echo "ConvertMappedKeyStep ${jo~}"        
        variable jsonvalue joNew="{}"

        variable jsonvalue jaActions="[]"

        variable jsonvalue joState="{}"
        joState:SetByRef[sheet,joMappableSheet]
        joState:SetByRef[mappable,joMappable]
        joState:SetByRef[step,jo]

        if ${jo.Has[stick]}
            joNew:SetNumber[stickyTime,"${jo.GetNumber[stick]}"]
        if ${jo.Has[stop]}
            joNew:SetNumber[stickyTime,"-1"]
        if ${jo.Has[stump]}
            joNew:SetBool[triggerOnce,"${jo.GetBool[stump]}"]
        if ${jo.GetBool[disabled]}
            joNew:SetBool[enable,0]

        jo.Get[Actions]:ForEach["jaActions:AddByRef[\"This.ConvertAction[joState,ForEach.Value]\"]"]

        if ${jaActions.Used}
            joNew:SetByRef[actions,jaActions]


;        joNew:SetByRef[original,jo]
        return joNew
    }
#endregion

#region Action conversion -- Fully implemented
    member:jsonvalueref ConvertAction(jsonvalueref joState,jsonvalueref jo)
    {
;       echo "ConvertAction ${jo~}"

        variable jsonvalue joNew

        if ${This(type).Member["ConvertAction_${jo.Get[type]~}"]}
        {
            joNew:SetValue["${This.ConvertAction_${jo.Get[type]~}[joState,jo]~}"]

            if ${jo.Has[Target]}
                joNew:SetString[target,"${jo.Get[Target]~}"]
            if ${jo.Has[RoundRobin]}
                joNew:SetBool[roundRobin,"${jo.GetBool[RoundRobin]}"]

            if ${jo.Has[ActionTimer]}
                joNew:SetByRef[actionTimer,"This.ConvertActionTimer[\"jo.Get[ActionTimer]\"]"]

            return joNew
        }

        echo "\arConvertAction unhandled\ax: ${jo.Get[type]~}"        
        jo:SetString[originalActionType,"${jo.Get[type]~}"]
        jo:Erase[type]
        return jo
    }

    member:jsonvalueref ConvertActionTimer(jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[pool,"${jo.Get[PoolName]~}"]

        joNew:SetBool[enabled,${jo.GetBool[Enabled]}]

        if ${jo.GetBool[AutoRecurring]}
            jo:SetBool[autoRecurring,1]
        
        joNew:SetNumber[seconds,"${jo.GetNumber[Seconds]~}"]      

;        joNew:Set[originalAction,"${jo~}"]
        return joNew        
    }

    member:jsonvalueref ConvertAction_MappedKeyExecuteAction(jsonvalueref joState,jsonvalueref jo)
    {
;       echo "ConvertAction_MappedKeyExecuteAction ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,mappable]        

        if ${jo.Has[mappedKey]}
            joNew:SetString[name,"${jo.Get[mappedKey]~}"]
        if ${jo.Has[keyMap]}
            joNew:SetString[sheet,"${jo.Get[keyMap]~}"]

;        joNew:Set[originalAction,"${jo~}"]
        return joNew
    }

    member:jsonvalueref ConvertAction_MappedKeyStepAction(jsonvalueref joState,jsonvalueref jo)
    {
;       echo "ConvertAction_MappedKeyStepAction ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,mappable step]        

        joNew:SetString[name,"${jo.Get[MappedKey,MappedKeyString]~}"]
        joNew:SetString[sheet,"${jo.Get[MappedKey,KeyMapString]~}"]

        joNew:SetInteger[value,"${jo.GetInteger[Value]}"]
        joNew:SetString[action,"${jo.Get[Action]~}"]

        return joNew        
    }

    member:jsonvalueref ConvertAction_MappedKeyStepStateAction(jsonvalueref joState,jsonvalueref jo)
    {
;       echo "ConvertAction_MappedKeyStepStateAction ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,mappable step state]        

        joNew:SetString[name,"${jo.Get[MappedKey,MappedKeyString]~}"]
        joNew:SetString[sheet,"${jo.Get[MappedKey,KeyMapString]~}"]

        joNew:SetInteger[step,"${jo.GetInteger[Step]}"]

        if ${jo.GetInteger[Enable]}>=0
            joNew:SetBool[enable,"${jo.GetInteger[Enable]}"]

        if ${jo.GetInteger[TriggerOnce]}>=0
            joNew:SetInteger[triggerOnce,"${jo.GetInteger[TriggerOnce]}"]

        joNew:SetInteger[stickyTime,"${jo.GetInteger[StickyTime]}"]



;        joNew:SetInteger[value,"${jo.GetInteger[Value]}"]
;        joNew:SetString[action,"${jo.Get[Action]~}"]

        return joNew        
    }

    member:jsonvalueref ConvertAction_KeyMapAction(jsonvalueref joState,jsonvalueref jo)
    {
;       echo "ConvertAction_KeyMapAction ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,key map state]        

        joNew:SetString[name,"${jo.Get[keyMap]~}"]

        if ${jo.Has[Value]}
            joNew:SetString[value,"${jo.Get[Value]~}"]
        else
            joNew:SetString[value,"On"]

;        joNew:Set[originalAction,"${jo~}"]
        return joNew        
    }

    member:jsonvalueref ConvertAction_MappedKeyStateAction(jsonvalueref joState,jsonvalueref jo)
    {
;       echo "ConvertAction_MappedKeyStateAction ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,mappable state]        

        joNew:SetString[name,"${jo.Get[mappedKey]~}"]
        if ${jo.Has[keyMap]}
            joNew:SetString[sheet,"${jo.Get[keyMap]~}"]

        if ${jo.Has[Value]}
            joNew:SetString[value,"${jo.Get[Value]~}"]
        else
            joNew:SetString[value,"On"]

        return joNew        
    }

    member:jsonvalueref ConvertAction_Keystroke(jsonvalueref joState,jsonvalueref jo)
    {
;       echo "ConvertAction_Keystroke ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,keystroke]        

        if ${jo.Has[combo,Combo]}
            joNew:SetString[keyCombo,"${jo.Get[combo,Combo]~}"]

        variable bool hold
        if ${joState.Has[mappable,hold]}
            hold:Set[${joState.GetBool[mappable,hold]}]
        else
            hold:Set[${joState.GetBool[sheet,hold]}]

        if ${hold}
            joNew:SetBool[hold,1]

        return joNew
    }

    member:jsonvalueref ConvertAction_KeyStringAction(jsonvalueref joState,jsonvalueref jo)
    {
;       echo "ConvertAction_Keystroke ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,keystring]        

        if ${jo.Has[Text]}
            joNew:SetString[text,"${jo.Get[Text]~}"]

        if ${jo.GetBool[FillClipboard]}
            joNew:SetBool[FillClipboard,1]

        return joNew
    }

    member:jsonvalueref ConvertAction_ClickBarStateAction(jsonvalueref joState,jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,click bar state]
        joNew:SetString[name,"${jo.Get[ClickBar,ClickBarString]~}"]

        if ${jo.Get[Value]~.NotNULLOrEmpty}
            joNew:SetString[value,"${jo.Get[Value]~}"]
        else
            joNew:SetString[value,On]

        if ${jo.Get[ActionType]~.NotNULLOrEmpty}
            joNew:SetString[action,"${jo.Get[ActionType]~}"]
        else
            joNew:SetString[action,Single]

        if ${jo.Get[ClickBarSet]~.NotNULLOrEmpty}
            joNew:SetString[sheet,"${jo.Get[ClickBarSet]~}"]

        joNew:Set[originalAction,"${jo~}"]
        return joNew
    }

    member:jsonvalueref ConvertAction_MenuStateAction(jsonvalueref joState,jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,click bar state]
        if ${jo.Get[Menu,MenuString]~.NotNULLOrEmpty}
            joNew:SetString[name,"menu_${jo.Get[Menu,MenuString]~}"]
;        joNew:SetString[value,"${jo.Get[Value]~}"]
        joNew:SetString[action,"${jo.Get[ActionType]~}"]

;        joNew:Set[originalAction,"${jo~}"]
        return joNew
    }

    member:jsonvalueref ConvertAction_VariableKeystrokeAction(jsonvalueref joState,jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,game key binding]
        joNew:SetString[name,"${jo.Get[Name]~}"]
        return joNew
    }

    member:jsonvalueref ConvertAction_SyncCursorAction(jsonvalueref joState,jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,sync cursor]

;        joNew:Set[originalAction,"${jo~}"]
        return joNew
    }

    member:jsonvalueref ConvertAction_ClickBarButtonAction(jsonvalueref joState,jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,set click bar button]

        if ${jo.Has[Text]}
            joNew:SetString[text,"${jo.Get[Text]~}"]

        if ${jo.Has[backgroundColor]}
            joNew:SetString[backgroundColor,"${jo.Get[backgroundColor]~}"]

        if ${jo.Has[Image,ImageString]}
            joNew:SetString[image,"${jo.Get[Image,ImageString]~}"]

;        joNew:Set[originalAction,"${jo~}"]
        return joNew
    }

    member:jsonvalueref ConvertAction_MappedKeyRewriteAction(jsonvalueref joState,jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,virtualize mappable]

        if ${jo.Has[FromMappedKey,KeyMapString]}
            joNew:SetString[fromSheet,"${jo.Get[FromMappedKey,KeyMapString]~}"]
        if ${jo.Has[FromMappedKey,MappedKeyString]}
            joNew:SetString[fromName,"${jo.Get[FromMappedKey,KeyMapString]~}"]

        if ${jo.Has[ToMappedKey,KeyMapString]}
            joNew:SetString[toSheet,"${jo.Get[ToMappedKey,KeyMapString]~}"]
        if ${jo.Has[ToMappedKey,MappedKeyString]}
            joNew:SetString[toName,"${jo.Get[ToMappedKey,KeyMapString]~}"]

;        joNew:Set[originalAction,"${jo~}"]
        return joNew
    }

    member:jsonvalueref ConvertAction_RepeaterRegionsAction(jsonvalueref joState,jsonvalueref jo)
    {
;       echo "ConvertAction_RepeaterRegionsAction ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,region sheet state]        

        if ${jo.Get[Profile]~.NotNULLOrEmpty}
            joNew:SetString[name,"${jo.Get[Profile]~}"]

        joNew:SetString[action,"${jo.Get[Action]~}"]

        return joNew        
    }

    member:jsonvalueref ConvertAction_RepeaterStateAction(jsonvalueref joState,jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,broadcast state]

        if ${jo.Has[BlockLocal]}
            joNew:SetBool[blockLocal,${jo.GetBool[BlockLocal]}]
        
        if ${jo.GetBool[UseMouseState]}
        {
            if ${jo.Has[MouseState]}
                joNew:SetString[mouseState,"${jo.Get[MouseState]~}"]
            else
                joNew:SetString[mouseState,"On"]
        }
        if ${jo.GetBool[UseKeyboardState]}
        {
            if ${jo.Has[keyboardState]}
               joNew:SetString[keyboardState,"${jo.Get[KeyboardState]~}"]
            else
                joNew:SetString[keyboardState,"On"]
        }

        if ${jo.Has[VideoFeed,Value]}
        {
            joNew:SetBool[videoFeed,1]

            if ${jo.GetInteger[VideoOutputAlpha]}>=0
                joNew:SetInteger[videoOutputAlpha,${jo.GetInteger[VideoOutputAlpha]}]
            if ${jo.Has[videoOutputBorder]}
                joNew:SetString[videoOutputBorder,"${jo.Get[videoOutputBorder]~}"]
            
            if ${jo.Has[videoSourceSize]}
                joNew:SetByRef[videoSourceSize,"jo.Get[videoSourceSize]"]
            if ${jo.Has[videoOutputSize]}
                joNew:SetByRef[videoOutputSize,"jo.Get[videoOutputSize]"]

        }


        joNew:Set[originalAction,"${jo~}"]
        return joNew
    }

    member:jsonvalueref ConvertAction_SendNextClickAction(jsonvalueref joState,jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,send next click]

        joNew:SetBool[blockLocal,${jo.GetBool[BlockLocal]}]

        if ${jo.GetBool[VideoFeed]}
        {
            joNew:SetBool[videoFeed,1]

            if ${jo.GetInteger[VideoOutputAlpha]}>=0
                joNew:SetInteger[videoOutputAlpha,${jo.GetInteger[VideoOutputAlpha]}]
            if ${jo.Has[videoOutputBorder]}
                joNew:SetString[videoOutputBorder,"${jo.Get[videoOutputBorder]~}"]
            
            if ${jo.Has[videoSourceSize]}
                joNew:SetByRef[videoSourceSize,"jo.Get[videoSourceSize]"]
            if ${jo.Has[videoOutputSize]}
                joNew:SetByRef[videoOutputSize,"jo.Get[videoOutputSize]"]

        }


        joNew:Set[originalAction,"${jo~}"]
        return joNew
    }

    member:jsonvalueref ConvertAction_TargetGroupAction(jsonvalueref joState,jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,target group]

        joNew:SetString[action,"${jo.Get[Action]~}"]
        joNew:SetString[name,"${jo.Get[RelayGroupString]~}"]        

;        joNew:Set[originalAction,"${jo~}"]
        return joNew
    }

    member:jsonvalueref ConvertAction_WindowStateAction(jsonvalueref joState,jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,window state]

        if ${jo.Has[RegionType]}
            joNew:SetString[regionType,"${jo.Get[RegionType]~}"]
        if ${jo.Has[Action]}
            joNew:SetString[action,"${jo.Get[Action]~}"]
        if ${jo.GetBool[DeactivateOthers]}
            joNew:SetBool[deactivateOthers,1]

;        joNew:SetString[targetGroup,"${jo.Get[RelayGroupString]~}"]        

;        joNew:Set[originalAction,"${jo~}"]
        return joNew
    }

    member:jsonvalueref ConvertAction_WindowStyleAction(jsonvalueref joState,jsonvalueref jo)
    {
;       echo "ConvertAction_WindowStyleAction ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,window style]

        if ${jo.Get[RegionType]~.NotNULLOrEmpty}
            joNew:SetString[regionType,"${jo.Get[RegionType]~}"]
        else
            joNew:SetString[regionType,"Background"]

        if ${jo.GetBool[UseAlwaysOnTop]}
        {
            if ${jo.Get[AlwaysOnTop]~.NotNULLOrEmpty}
                joNew:SetString[alwaysOnTop,"${jo.Get[AlwaysOnTop]~}"]
            else
                joNew:SetString[alwaysOnTop,"On"]
        }

        if ${jo.GetBool[UseSometimesOnTop]}
        {
            if ${jo.Get[SometimesOnTop]~.NotNULLOrEmpty}
                joNew:SetString[sometimesOnTop,"${jo.Get[SometimesOnTop]~}"]
            else
                joNew:SetString[sometimesOnTop,"On"]
        }

        if ${jo.GetBool[UseSize]}
        {
            joNew:SetInteger[width,"${jo.GetInteger[Rect,Width]}"]
            joNew:SetInteger[height,"${jo.GetInteger[Rect,Height]}"]
        }
        if ${jo.GetBool[UsePosition]}
        {
            joNew:SetInteger[x,"${jo.GetInteger[Rect,Left]}"]
            joNew:SetInteger[y,"${jo.GetInteger[Rect,Top]}"]
        }

        if ${jo.GetBool[UseBorder]}
        {
            if ${jo.Get[Border]~.NotNULLOrEmpty}
                joNew:SetString[border,"${jo.Get[Border]~}"]
            else
                joNew:SetString[border,None]
        }

;        joNew:Set[originalAction,"${jo~}"]
        return joNew        
    }


    member:jsonvalueref ConvertAction_WindowFocusAction(jsonvalueref joState,jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,window focus]

        if ${jo.Has[FilterTarget]}
            joNew:SetString[filtertTarget,"${jo.Get[FilterTarget]~}"]
        if ${jo.Has[window]}
            joNew:SetString[window,"${jo.Get[Window]~}"]
        if ${jo.Has[Computer]}
            joNew:SetString[computer,"${jo.Get[Computer,ComputerString]~}"]

        return joNew
    }

    member:jsonvalueref ConvertAction_WindowCloseAction(jsonvalueref joState,jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,window close]

        if ${jo.Assert[Action,"\"Terminate\""]}
            joNew:SetBool[terminate,1]

        return joNew
    }

    member:jsonvalueref ConvertAction_RepeaterTargetAction(jsonvalueref joState,jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,broadcast target]

        if ${jo.Has[RepeaterTarget]}
            joNew:SetString[value,"${jo.Get[RepeaterTarget]~}"]
        else
            joNew:SetString[value,"all other"]

        if ${jo.GetBool[BlockLocal]}
            joNew:SetBool[blockLocal,1]

        return joNew
    }

    member:jsonvalueref ConvertAction_MenuButtonAction(jsonvalueref joState,jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,set click bar button]

        


        joNew:Set[originalAction,"${jo~}"]
        return joNew
    }

    member:jsonvalueref ConvertAction_TimerPoolAction(jsonvalueref joState,jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,timer pool]

        joNew:SetString[action,"${jo.Get[Action]~}"]
        joNew:SetString[timerPool,"${jo.Get[TimerPool]~}"]        
        if ${jo.Has[Target2]}
            joNew:SetString[target,"${jo.Get[Target2]~}"]        

;        joNew:Set[originalAction,"${jo~}"]
        return joNew
    }


    member:jsonvalueref ConvertAction_PopupTextAction(jsonvalueref joState,jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,popup text]
        joNew:SetString[text,"${jo.Get[Text]~}"]

        if ${jo.GetInteger[durationMS]}
            joNew:SetNumber[duration,${Math.Calc[${jo.GetInteger[durationMS]}/1000]}]
        if ${jo.GetInteger[fadeDurationMS]}
            joNew:SetNumber[fadeDuration,${Math.Calc[${jo.GetInteger[fadeDurationMS]}/1000]}]

        if ${jo.Has[color]}
            joNew:Set[color,"${jo.Get[color].AsJSON~}"]

        return joNew
    }

    member:jsonvalueref ConvertAction_WoWMacroRefAction(jsonvalueref joState,jsonvalueref jo)
    {
;       echo "ConvertAction_WoWMacroRefAction ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,game macro]        

        if ${jo.Has[useFTLModifiers]}
            joNew:SetBool[useFTLModifiers,"${jo.GetBool[useFTLModifiers]}"]    

        joNew:SetString[sheet,"${jo.Get[WoWMacro,WoWMacroSetString]}"]
        joNew:SetString[name,"${jo.Get[WoWMacro,WoWMacroString].ReplaceSubstring["{FTL}","(FTL)"]}"]

        return joNew
    }

    member:jsonvalueref ConvertAction_RepeaterListAction(jsonvalueref joState,jsonvalueref jo)
    {
;        echo "ConvertAction_RepeaterListAction ${jo~}"

        variable jsonvalue joNew="{}"

        joNew:SetString[type,broadcast list]        
        joNew:SetString[listType,"${jo.Get[WhiteOrBlackListType]~}"]

        variable jsonvalue ja="[]"

        jo.Get[WhiteOrBlackList]:ForEach["This:AddConvertedISKey[ja,ForEach.Value]"]

        joNew:SetByRef[list,ja]

;        joNew:Set[originalAction,"${jo~}"]
        return joNew
    }

    member:jsonvalueref ConvertAction_InputDeviceKeySetAction(jsonvalueref joState,jsonvalueref jo)
    {
;       echo "ConvertAction_InputDeviceKeySetAction ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,input device key set]        
        

        if ${jo.Get[InputDevice]~.NotNULLOrEmpty}
            joNew:SetString[device,"${jo.Get[InputDevice]~}"]
        if ${jo.Get[KeySet]~.NotNULLOrEmpty}
            joNew:SetString[keySet,"${jo.Get[KeySet]~}"]

;        joNew:Set[originalAction,"${jo~}"]
        return joNew        
    }

     member:jsonvalueref ConvertAction_ScreenshotAction(jsonvalueref joState,jsonvalueref jo)
    {
;       echo "ConvertAction_ScreenshotAction ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,screenshot]        
        

        if ${jo.Get[Filename]~.NotNULLOrEmpty}
            joNew:SetString[filename,"${jo.Get[Filename]~}"]

        if !${jo.GetBool[DirectXCapture]}
            joNew:SetBool[DirectXCapture,0]

        if ${jo.GetBool[UseRect]}
        {
            joNew:SetInteger[x,${jo.Get[Rect,Left]}]
            joNew:SetInteger[y,${jo.Get[Rect,Top]}]
            joNew:SetInteger[width,${jo.Get[Rect,Width]}]
            joNew:SetInteger[height,${jo.Get[Rect,Height]}]
        }

        if !${jo.GetBool[UseClientCoords]}
            joNew:SetBool[useClientCoords,0]

        if ${jo.Get[Encoding]~.NotNULLOrEmpty}
            joNew:SetString[encoding,"${jo.Get[Encoding]~}"]
        else
            joNew:SetString[encoding,"PNG"]

;        joNew:Set[originalAction,"${jo~}"]
        return joNew        
    }

    member:jsonvalueref ConvertAction_DoMenuButtonAction(jsonvalueref joState,jsonvalueref jo)
    {
;       echo "ConvertAction_DoMenuButtonAction ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,do menu button]        
        

        if ${jo.Get[Menu,MenuString]~.NotNULLOrEmpty}
            joNew:SetString[menu,"${jo.Get[Menu,MenuString]~}"]

        if ${jo.GetInteger[NumButton]}
            jo:SetInteger[numButton,${jo.GetInteger[NumButton]}]
        else
            jo:SetInteger[numButton,1]

;        joNew:Set[originalAction,"${jo~}"]
        return joNew        
    }

    member:jsonvalueref ConvertAction_HotkeySetAction(jsonvalueref joState,jsonvalueref jo)
    {
;       echo "ConvertAction_HotkeySetAction ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,menu hotkey set]        
            
        if ${jo.Get[HotkeySet,HotkeySetString]~.NotNULLOrEmpty}
            joNew:SetString[hotkeySet,"${jo.Get[HotkeySet,HotkeySetString]~}"]

        if ${jo.Get[OtherHotkeySet]~.NotNULLOrEmpty}
            joNew:SetString[otherHotkeySet,"${jo.Get[OtherHotkeySet]~}"]

        if ${jo.Get[Menu]~.NotNULLOrEmpty}
            joNew:SetString[menu,"${jo.Get[Menu]~}"]

        if ${jo.GetBool[BindSoft]}
            joNew:SetBool[bindSoft,1]

        if ${jo.GetInteger[StartHotkeySetAtNumHotkey]}
            joNew:SetInteger[startAtHotkey,"${jo.GetInteger[StartHotkeySetAtNumHotkey]}"]

        joNew:Set[originalAction,"${jo~}"]
        return joNew        
    }

    member:jsonvalueref ConvertAction_MenuStyleAction(jsonvalueref joState,jsonvalueref jo)
    {
;       echo "ConvertAction_MenuStyleAction ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,menu style]        
            
        if ${jo.Get[Menu,MenuString]~.NotNULLOrEmpty}
            joNew:SetString[menu,"${jo.Get[Menu,MenuString]~}"]

        if ${jo.Get[HotkeySet]~.NotNULLOrEmpty}
            joNew:SetString[hotkeySet,"${jo.Get[HotkeySet]~}"]

        if ${jo.GetBool[BindSoft]}
            joNew:SetBool[bindSoft,1]

        if ${jo.GetInteger[StartButtonSetAtNumButton]}
            joNew:SetInteger[startAtButton,"${jo.GetInteger[StartButtonSetAtNumButton]}"]

        joNew:Set[originalAction,"${jo~}"]
        return joNew        
    }


    member:jsonvalueref ConvertAction_LightAction(jsonvalueref joState,jsonvalueref jo)
    {
;       echo "ConvertAction_LightAction ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,light]        
            
        joNew:SetString[light,"${jo.Get[Light]~}"]

;        if ${jo.Get[Value]~}
        joNew:SetString[value,"${jo.Get[Value]~}"]

        if ${jo.Get[ComputerString]~.NotNULLOrEmpty}
            joNew:SetString[computer,"${jo.Get[ComputerString]~}"]

        joNew:Set[originalAction,"${jo~}"]
        return joNew        
    }

    member:jsonvalueref ConvertAction_SoundAction(jsonvalueref joState,jsonvalueref jo)
    {
;       echo "ConvertAction_SoundAction ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,sound]        
        

        if ${jo.Get[Filename]~.NotNULLOrEmpty}
            joNew:SetString[filename,"${jo.Get[Filename]~}"]
        if ${jo.Get[ComputerString]~.NotNULLOrEmpty}
            joNew:SetString[computer,"${jo.Get[ComputerString]~}"]

;        joNew:Set[originalAction,"${jo~}"]
        return joNew        
    }

    member:jsonvalueref ConvertAction_VolumeAction(jsonvalueref joState,jsonvalueref jo)
    {
;       echo "ConvertAction_VolumeAction ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,volume]        
            
        joNew:SetString[action,"${jo.Get[Action]~}"]

        if ${jo.GetNumber[Value]}
            joNew:SetNumber[value,"${jo.GetNumber[Value]}"]
        if ${jo.GetNumber[OverSeconds]}
            joNew:SetNumber[seconds,"${jo.GetNumber[OverSeconds]}"]

;        joNew:Set[originalAction,"${jo~}"]
        return joNew        
    }

    member:jsonvalueref ConvertAction_SetVariableKeystrokeAction(jsonvalueref joState,jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,set game key binding]
        if ${jo.Get[Name]~.NotNULLOrEmpty}
            joNew:SetString[name,"${jo.Get[Name]~}"]
        if ${jo.Has[combo,Combo]}
            joNew:SetString[keyCombo,"${jo.Get[combo,Combo]~}"]

        return joNew
    }

    member:jsonvalueref ConvertAction_VideoFeedsAction(jsonvalueref joState,jsonvalueref jo)
    {
;       echo "ConvertAction_VideoFeedsAction ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,video fx]        
            
        if ${jo.Get[Name]~.NotNULLOrEmpty}
            joNew:SetString[name,"${jo.Get[Name]~}"]
        if ${jo.Get[Action]~.NotNULLOrEmpty}
            joNew:SetString[action,"${jo.Get[Action]~}"]


        if ${jo.Get[KeyMap,KeyMapString]~.NotNULLOrEmpty}
            joNew:SetString[keyMap,"${jo.Get[MappedKey,KeyMapString]~}"]
        if ${jo.Get[MappedKey,MappedKeyString]~.NotNULLOrEmpty}
            joNew:SetString[mappedKey,"${jo.Get[MappedKey,MappedKeyString]~}"]

        if ${jo.GetBool[IsSource]}
            joNew:SetBool[isSource,"${jo.GetBool[IsSource]}"]
        if ${jo.GetBool[UseKeyRepeat]}
            joNew:SetBool[useKeyRepeat,"${jo.GetBool[UseKeyRepeat]}"]
        if ${jo.GetBool[UseMouseRepeat]}
            joNew:SetBool[useMouseRepeat,"${jo.GetBool[UseMouseRepeat]}"]
        if ${jo.GetBool[UseFocusHotkey]}
            joNew:SetBool[useFocusHotkey,"${jo.GetBool[UseFocusHotkey]}"]
        
        if ${jo.GetInteger[Rect,X]}
            joNew:SetInteger[X,${jo.GetInteger[Rect,X]}]
        if ${jo.GetInteger[Rect,Y]}
            joNew:SetInteger[Y,${jo.GetInteger[Rect,Y]}]
        if ${jo.GetInteger[Rect,Width]}
            joNew:SetInteger[Width,${jo.GetInteger[Rect,Width]}]
        if ${jo.GetInteger[Rect,Height]}
            joNew:SetInteger[Height,${jo.GetInteger[Rect,Height]}]


        if ${jo.Get[borderColor]~.NotNULLOrEmpty}
            joNew:SetString[borderColor,"${jo.Get[borderColor]~}"]

;        joNew:Set[originalAction,"${jo~}"]
        return joNew        
    }
#endregion

#region Utilities
    method WriteJSON(string filename)
    {
        if !${ISBProfile.Type.Equal[object]}
            return

        ISBProfile:WriteFile["${filename~}",multiline]
    }

    member:jsonvalueref FindInArray(jsonvalueref ja, string name, string fieldName="Name")
    {
        if !${ja.Type.Equal[array]}
            return NULL

/*
    {
        "eval":"Select.Get[\"${fieldName~}\"]",
        "op":"==",
        "value":"${name~}"
    }
/**/

        variable jsonvalue joQuery="{}"
        joQuery:SetString[eval,"Select.Get[\"${fieldName~}\"]"]
        joQuery:SetString[op,"=="]
        joQuery:SetString[value,"${name~}"]

        return "ja.SelectValue[joQuery]"
    }

    member:jsonvalueref GetWoWMacroSet(string name)
    {
        variable jsonvalueref ja="ISBProfile.Get[WoWMacroSet]"

        return "This.FindInArray[ja,\"${name~}\"]"
    }

    member:jsonvalueref GetWoWMacro(string setName, string name)
    {
        variable jsonvalueref jo="This.GetWoWMacroSet[\"${setName~}\"]"
        if !${jo.Type.Equal[object]}
        {
            echo "GetWoWMacro: Set ${setName~} not found ${jo~}"
            return NULL
        }
        variable jsonvalueref ja
        ja:SetReference["jo.Get[WoWMacros]"]
        if !${ja.Type.Equal[array]}
        {
            echo "GetWoWMacro: Set ${setName~} missing WoWMacros"
            return NULL
        }

;        echo "GetWoWMacro checking for ${name~} in ${ja~}"
        return "This.FindInArray[ja,\"${name~}\",ColloquialName]"
    }

    member:jsonvalueref ConvertISKey(jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[Key,"${jo.Get[Key]~}"]

        if ${jo.GetInteger[Code]}
            joNew:SetInteger[code,${jo.GetInteger[Code]}]    
        return joNew
    }

    method AddConvertedISKey(jsonvalueref ja, jsonvalueref jo)
    {
        ja:AddByRef["This.ConvertISKey[jo]"]
    }

#endregion
}
