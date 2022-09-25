#include "ISB2022.XMLReader.iss"
objectdef isb2022_importer
{

    variable jsonvalueref ISBProfile

    method TransformXML(string filename)
    {
        variable isb2022_isb1transformer ISB1Transformer

        ISBProfile:SetReference["ISB1Transformer.TransformXML[\"${filename~}\"]"]
        
        This:WriteJSON["${filename~}.json"]
    }

    member:jsonvalueref TransformProfileXML(string filename)
    {
        variable isb2022_isb1transformer ISB1Transformer
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
        
        return jo
    }

    method TransformCurrentProfileXML()
    {
        variable jsonvalueref jo
        jo:SetReference["This.TransformProfileXML[\"${LavishScript.HomeDirectory~}/ISBoxerToolkitProfile.LastExported.XML\"]"]
        jo:WriteFile["${LavishScript.HomeDirectory~}/ISBoxerToolkitProfile.LastExported.isb2022.json",multiline]
    }

    member:jsonvalueref TransformRegionsXML(string filename)
    {
        variable isb2022_isb1transformer ISB1Transformer

        variable jsonvalueref joProfile
        joProfile:SetReference["ISB1Transformer.TransformRegionsXML[\"${filename~}\"]"]

        return joProfile
    }

    member:jsonvalueref TransformVideoFXXML(string filename)
    {
        variable isb2022_isb1transformer ISB1Transformer

        variable jsonvalueref joProfile
        joProfile:SetReference["ISB1Transformer.TransformVideoFXXML[\"${filename~}\"]"]

        return joProfile
    }

    method WriteJSON(string filename)
    {
        if !${ISBProfile.Type.Equal[object]}
            return

        ISBProfile:WriteFile["${filename~}",multiline]
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

    member:jsonvalueref ConvertCharacter(jsonvalueref jo)
    {
;        echo "ConvertCharacter ${jo~}"
        variable jsonvalue joNew="{}"

        joNew:SetString[name,"${jo.Get[Name]~}"]
        if ${jo.Has[ActualName]}
            joNew:SetString[actualName,"${jo.Get[ActualName]~}"]

        if ${jo.Has[VirtualFileTargets]}
            joNew:SetByRef["virtualFiles","jo.Get[VirtualFileTargets]"]

        jo:SetString[game,"${jo.Get[KnownGame]~}"]

        variable jsonvalue joGLI="{}"
        joGLI:SetString[game,"${jo.Get[Game]~}"]
        joGLI:SetString[gameProfile,"${jo.Get[GameProfile]~}"]

        joNew:SetByRef[gameLaunchInfo,joGLI]

        return joNew
    }

    member:jsonvalueref ConvertCharacterSet(jsonvalueref jo)
    {
;        echo "ConvertCharacterSet ${jo~}"
        variable jsonvalue joNew="{}"

        joNew:SetString[name,"${jo.Get[Name]~}"]

        if ${jo.Get[WindowLayout,WindowLayoutString].NotNULLOrEmpty}
            joNew:SetString[windowLayout,"${jo.Get[WindowLayout,WindowLayoutString]~}"]

        variable jsonvalue jaSlots="[]"        
        jo.Get[Slots]:ForEach["jaSlots:AddByRef[\"This.ConvertCharacterSetSlot[ForEach.Value]\"]"]
        joNew:SetByRef[slots,jaSlots]        
        return joNew
    }

    member:jsonvalueref ConvertCharacterSetSlot(jsonvalueref jo)
    {
        echo "ConvertCharacterSetSlot ${jo~}"
        variable jsonvalue joNew="{}"

        if ${jo.Has[CharacterString]}
            joNew:SetString[character,"${jo.Get[CharacterString]~}"]
        if ${jo.Has[foregroundMaxFPS]}
            joNew:SetInteger[foregroundFPS,"${jo.GetInteger[foregroundMaxFPS]~}"]
        if ${jo.Has[backgroundMaxFPS]}
            joNew:SetInteger[backgroundFPS,"${jo.GetInteger[backgroundMaxFPS]~}"]

        return joNew
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

        variable jsonvalue ja="[]"

        jo.Get[Mappings]:ForEach["This:ConvertMappedKeyAsMappableInto[ja,jo,ForEach.Value]"]

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

        jo.Get[Mappings]:ForEach["This:ConvertMappedKeyAsHotkeyInto[ja,jo,ForEach.Value]"]

        if !${ja.Used}
            return NULL

        joNew:SetByRef[hotkeys,ja]    
        return joNew
    }

    member:jsonvalueref ConvertClickBar(jsonvalueref jo)
    {
        echo "ConvertClickBar ${jo~}"

        return NULL
    }

    member:jsonvalueref ConvertClickBarImage(jsonvalueref jo)
    {
        echo "ConvertClickBarImage ${jo~}"

        return NULL
    }

    member:jsonvalueref ConvertComputer(jsonvalueref jo)
    {
        echo "ConvertComputer ${jo~}"

        return NULL
    }

    member:jsonvalueref ConvertRepeaterProfile(jsonvalueref jo)
    {
        echo "ConvertRepeaterProfile ${jo~}"

        return NULL
    }

    member:jsonvalueref ConvertVariableKeystroke(jsonvalueref jo)
    {
        echo "ConvertVariableKeystroke ${jo~}"
        return NULL
    }

    member:jsonvalueref ConvertWindowLayout(jsonvalueref jo)
    {
        echo "ConvertWindowLayout ${jo~}"

        return NULL
    }

    member:jsonvalueref ConvertWoWMacroSet(jsonvalueref jo)
    {
        echo "ConvertWoWMacroSet ${jo~}"

        return NULL
    }

    member:jsonvalueref ConvertCrypticMacroSet(jsonvalueref jo)
    {
        echo "ConvertCrypticMacroSet ${jo~}"

        return NULL
    }

    member:jsonvalueref ConvertMenu(jsonvalueref jo)
    {
        echo "ConvertMenu ${jo~}"

        return NULL
    }

    member:jsonvalueref ConvertMenuHotkeySet(jsonvalueref jo)
    {
        echo "ConvertMenuHotkeySet ${jo~}"

        return NULL
    }

    member:jsonvalueref ConvertMenuTemplate(jsonvalueref jo)
    {
        echo "ConvertMenuTemplate ${jo~}"

        return NULL
    }

    member:jsonvalueref ConvertMenuButtonSet(jsonvalueref jo)
    {
        echo "ConvertMenuButtonSet ${jo~}"

        return NULL
    }

#region Mapped Key Conversion
    method ConvertMappedKeyAsHotkeyInto(jsonvalueref ja, jsonvalueref joKeyMap, jsonvalueref jo)
    {
;        echo ConvertMappedKeyAsHotkeyInto
        variable jsonvalueref joNew="This.ConvertMappedKeyAsHotkey[joKeyMap,jo]"
        if !${joNew.Reference(exists)}
            return

        ja:AddByRef[joNew]
    }

    member:jsonvalueref ConvertMappedKeyAsHotkey(jsonvalueref joKeyMap, jsonvalueref jo)
    {
;        echo "ConvertMappedKeyAsHotkey ${jo~}"

        if !${jo.Has[combo]}
            return NULL

        variable jsonvalue joNew="{}"
        joNew:SetString[name,"${jo.Get[Name]~}"]

        if ${jo.GetBool[manualLoad]}
            joNew:SetBool[enable,0]

        joNew:SetString[keyCombo,"${jo.Get[combo,Combo]~}"]
        
        variable jsonvalue joInputMapping="{}"

        joInputMapping:SetString[type,mappable]
        joInputMapping:SetString[sheet,"${joKeyMap.Get[Name]~}"]
        joInputMapping:SetString[name,"${jo.Get[Name]~}"]
        
        joNew:SetByRef[inputMapping,joInputMapping]

        return joNew
    }

    method ConvertMappedKeyAsMappableInto(jsonvalueref ja, jsonvalueref joKeyMap, jsonvalueref jo)
    {
;        echo ConvertMappedKeyAsMappableInto
        variable jsonvalueref joNew="This.ConvertMappedKeyAsMappable[joKeyMap,jo]"
        if !${joNew.Reference(exists)}
            return

        ja:AddByRef[joNew]
    }

    member:jsonvalueref ConvertMappedKeyAsMappable(jsonvalueref joKeyMap, jsonvalueref jo)
    {
;        echo "ConvertMappedKeyAsMappable ${jo~}"
        variable jsonvalue joNew="{}"
        joNew:SetString[name,"${jo.Get[Name]~}"]

        if ${jo.Get[Description].NotNULLOrEmpty}
            joNew:SetString[description,"${jo.Get[Description]~}"]

        if ${jo.Has[resetTimer]}
        {
            joNew:SetNumber[resetTimer,"${jo.GetNumber[resetTimer]}"]
        }

        variable jsonvalue jaSteps="[]"

        jo.Get[Steps]:ForEach["jaSteps:AddByRef[\"This.ConvertMappedKeyStep[ForEach.Value]\"]"]

        joNew:SetByRef[steps,jaSteps]
        return joNew
    }

    member:jsonvalueref ConvertMappedKeyStep(jsonvalueref jo)
    {
;       echo "ConvertMappedKeyStep ${jo~}"        
        variable jsonvalue joNew="{}"

        variable jsonvalue jaActions="[]"

        jo.Get[Actions]:ForEach["jaActions:AddByRef[\"This.ConvertAction[ForEach.Value]\"]"]

        if ${jaActions.Used}
            joNew:SetByRef[actions,jaActions]

        return joNew
    }
#endregion


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


#region Action conversion
    member:jsonvalueref ConvertAction(jsonvalueref jo)
    {
;       echo "ConvertAction ${jo~}"

        variable jsonvalue joNew

        if ${This(type).Member["ConvertAction_${jo.Get[type]~}"]}
        {
            joNew:SetValue["${This.ConvertAction_${jo.Get[type]~}[jo]~}"]

            if ${jo.Has[Target]}
                joNew:SetString[target,"${jo.Get[Target]~}"]
            if ${jo.Has[RoundRobin]}
                joNew:SetBool[roundRobin,"${jo.GetBool[RoundRobin]}"]

            if ${jo.Has[ActionTimer]}
                joNew:SetByRef[actionTimer,"This.ConvertActionTimer[\"jo.Get[ActionTimer]\"]"]

            return joNew
        }

        echo "ConvertAction unhandled: ${jo.Get[type]~}"        
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

    member:jsonvalueref ConvertAction_MappedKeyExecuteAction(jsonvalueref jo)
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

    member:jsonvalueref ConvertAction_MappedKeyStepAction(jsonvalueref jo)
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

    member:jsonvalueref ConvertAction_MappedKeyStepStateAction(jsonvalueref jo)
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

    member:jsonvalueref ConvertAction_KeyMapAction(jsonvalueref jo)
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

    member:jsonvalueref ConvertAction_MappedKeyStateAction(jsonvalueref jo)
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

    member:jsonvalueref ConvertAction_Keystroke(jsonvalueref jo)
    {
;       echo "ConvertAction_Keystroke ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,keystroke]        

        if ${jo.Has[combo,Combo]}
            joNew:SetString[keyCombo,"${jo.Get[combo,Combo]~}"]

        return joNew
    }

    member:jsonvalueref ConvertAction_KeyStringAction(jsonvalueref jo)
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

    member:jsonvalueref ConvertAction_ClickBarStateAction(jsonvalueref jo)
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

    member:jsonvalueref ConvertAction_MenuStateAction(jsonvalueref jo)
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

    member:jsonvalueref ConvertAction_VariableKeystrokeAction(jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,game key binding]
        joNew:SetString[name,"${jo.Get[Name]~}"]
        return joNew
    }

    member:jsonvalueref ConvertAction_SyncCursorAction(jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,sync cursor]

;        joNew:Set[originalAction,"${jo~}"]
        return joNew
    }

    member:jsonvalueref ConvertAction_ClickBarButtonAction(jsonvalueref jo)
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

    member:jsonvalueref ConvertAction_MappedKeyRewriteAction(jsonvalueref jo)
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

    member:jsonvalueref ConvertAction_RepeaterRegionsAction(jsonvalueref jo)
    {
;       echo "ConvertAction_RepeaterRegionsAction ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,region sheet state]        

        if ${jo.Get[Profile]~.NotNULLOrEmpty}
            joNew:SetString[name,"${jo.Get[Profile]~}"]

        joNew:SetString[action,"${jo.Get[Action]~}"]

        return joNew        
    }

    member:jsonvalueref ConvertAction_RepeaterStateAction(jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,broadcasting state]

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

    member:jsonvalueref ConvertAction_SendNextClickAction(jsonvalueref jo)
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

    member:jsonvalueref ConvertAction_TargetGroupAction(jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,target group]

        joNew:SetString[action,"${jo.Get[Action]~}"]
        joNew:SetString[targetGroup,"${jo.Get[RelayGroupString]~}"]        

;        joNew:Set[originalAction,"${jo~}"]
        return joNew
    }

    member:jsonvalueref ConvertAction_WindowStateAction(jsonvalueref jo)
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

    member:jsonvalueref ConvertAction_WindowStyleAction(jsonvalueref jo)
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


    member:jsonvalueref ConvertAction_WindowFocusAction(jsonvalueref jo)
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

    member:jsonvalueref ConvertAction_WindowCloseAction(jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,window close]

        if ${jo.Assert[Action,"\"Terminate\""]}
            joNew:SetBool[terminate,1]

        return joNew
    }

    member:jsonvalueref ConvertAction_RepeaterTargetAction(jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,broadcasting target]

        if ${jo.Has[RepeaterTarget]}
            joNew:SetString[value,"${jo.Get[RepeaterTarget]~}"]

        if ${jo.GetBool[BlockLocal]}
            joNew:SetBool[blockLocal,1]

        return joNew
    }

    member:jsonvalueref ConvertAction_MenuButtonAction(jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,set click bar button]

        


        joNew:Set[originalAction,"${jo~}"]
        return joNew
    }

    member:jsonvalueref ConvertAction_TimerPoolAction(jsonvalueref jo)
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


    member:jsonvalueref ConvertAction_PopupTextAction(jsonvalueref jo)
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

;        joNew:Set[originalAction,"${jo~}"]
        return joNew
    }

    member:jsonvalueref ConvertAction_WoWMacroRefAction(jsonvalueref jo)
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

    member:jsonvalueref ConvertAction_RepeaterListAction(jsonvalueref jo)
    {
;        echo "ConvertAction_RepeaterListAction ${jo~}"

        variable jsonvalue joNew="{}"

        joNew:SetString[type,broadcasting list]        
        joNew:SetString[listType,"${jo.Get[WhiteOrBlackListType]~}"]

        variable jsonvalue ja="[]"

        jo.Get[WhiteOrBlackList]:ForEach["This:AddConvertedISKey[ja,ForEach.Value]"]

        joNew:SetByRef[list,ja]

;        joNew:Set[originalAction,"${jo~}"]
        return joNew
    }

    member:jsonvalueref ConvertAction_InputDeviceKeySetAction(jsonvalueref jo)
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

     member:jsonvalueref ConvertAction_ScreenshotAction(jsonvalueref jo)
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

    member:jsonvalueref ConvertAction_DoMenuButtonAction(jsonvalueref jo)
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

    member:jsonvalueref ConvertAction_HotkeySetAction(jsonvalueref jo)
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

    member:jsonvalueref ConvertAction_MenuStyleAction(jsonvalueref jo)
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


    member:jsonvalueref ConvertAction_LightAction(jsonvalueref jo)
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

    member:jsonvalueref ConvertAction_SoundAction(jsonvalueref jo)
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

    member:jsonvalueref ConvertAction_VolumeAction(jsonvalueref jo)
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

    member:jsonvalueref ConvertAction_SetVariableKeystrokeAction(jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,set game key binding]
        if ${jo.Get[Name]~.NotNULLOrEmpty}
            joNew:SetString[name,"${jo.Get[Name]~}"]
        if ${jo.Has[combo,Combo]}
            joNew:SetString[keyCombo,"${jo.Get[combo,Combo]~}"]

        return joNew
    }

    member:jsonvalueref ConvertAction_VideoFeedsAction(jsonvalueref jo)
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
}
