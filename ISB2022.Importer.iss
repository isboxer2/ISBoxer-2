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

        variable jsonvalue ja="[]"

        jo.Get[Mappings]:ForEach["This:ConvertMappedKeyAsHotkeyInto[ja,jo,ForEach.Value]"]

        if !${ja.Used}
            return NULL

        joNew:SetByRef[hotkeys,ja]    
        return joNew
    }

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

    member:jsonvalueref ConvertAction(jsonvalueref jo)
    {
;       echo "ConvertAction ${jo~}"

        variable jsonvalueref joRef
        variable jsonvalue joNew

        if ${This(type).Member["ConvertAction_${jo.Get[type]~}"]}
        {
            joRef:SetReference["This.ConvertAction_${jo.Get[type]~}[jo]"]
            joNew:SetValue["${joRef~}"]

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

        joNew:SetString[type,mappable sheet state]        

        joNew:SetString[name,"${jo.Get[keyMap]~}"]
        joNew:SetString[value,"${jo.Get[Value]~}"]

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
            joNew:SetString[combo,"${jo.Get[combo,Combo]~}"]

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

    member:jsonvalueref FindInArray(jsonvalueref ja, string name, string fieldName="Name")
    {
        if !${ja.Type.Equal[array]}
            return NULL

        variable uint i
        for (i:Set[1] ; ${i}<=${ja.Used} ; i:Inc)
        {
            if ${ja.Get[${i}].Assert["${fieldName~}","${name.AsJSON~}"]}
            {
                return "ja.Get[${i}]"
            }
        }
        return NULL
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

    member:jsonvalueref ConvertAction_ClickBarStateAction(jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,click bar state]
        joNew:SetString[name,"${jo.Get[ClickBar,ClickBarString]~}"]
        joNew:SetString[value,"${jo.Get[Value]~}"]
        joNew:SetString[action,"${jo.Get[ActionType]~}"]

;        joNew:Set[originalAction,"${jo~}"]
        return joNew
    }

    member:jsonvalueref ConvertAction_MenuStateAction(jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,click bar state]
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
;       echo "ConvertAction_KeyMapAction ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,region sheet state]        

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

}
