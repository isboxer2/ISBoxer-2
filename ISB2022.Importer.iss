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
            return joNew
        }

        echo "ConvertAction unhandled: ${jo.Get[type]~}"        
        jo:SetString[originalActionType,"${jo.Get[type]~}"]
        jo:Erase[type]
        return jo
    }

    member:jsonvalueref ConvertAction_MappedKeyExecuteAction(jsonvalueref jo)
    {
;       echo "ConvertAction_MappedKeyExecuteAction ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,mappable]        
        joNew:SetString[name,"${jo.Get[mappedKey]~}"]
        joNew:SetString[sheet,"${jo.Get[keyMap]~}"]


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

    member:jsonvalueref ConvertAction_Keystroke(jsonvalueref jo)
    {
;       echo "ConvertAction_Keystroke ${jo~}"     
        variable jsonvalue joNew="{}"

        joNew:SetString[type,keystroke]        

        if ${jo.Has[combo,Combo]}
            joNew:SetString[combo,"${jo.Get[combo,Combo]~}"]

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

    member:jsonvalueref ConvertAction_TargetGroupAction(jsonvalueref jo)
    {
        variable jsonvalue joNew="{}"

        joNew:SetString[type,target group]

        joNew:SetString[action,"${jo.Get[Action]~}"]
        joNew:SetString[targetGroup,"${jo.Get[RelayGroupString]~}"]        

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

        joNew:SetString[type,keystroke]        

;        if ${jo.Has[combo,Combo]}
;            joNew:SetString[combo,"${jo.Get[combo,Combo]~}"]
        if ${jo.Has[useFTLModifiers]}
            joNew:SetBool[useFTLModifiers,"${jo.GetBool[useFTLModifiers]}"]    

        if ${jo.Has[WoWMacro]}
        {
            variable string macroSet
            variable string macroName
            macroSet:Set["${jo.Get[WoWMacro,WoWMacroSetString]~}"]
            macroName:Set["${jo.Get[WoWMacro,WoWMacroString]~}"]

            variable jsonvalueref joMacro
            joMacro:SetReference["This.GetWoWMacro[\"${macroSet~}\",\"${macroName~}\"]"]
;            echo "found macro=${joMacro~}"
            if ${joMacro.Type.Equal[object]} && ${joMacro.Has[combo,Combo]}
            {
                joNew:SetString[combo,"${joMacro.Get[combo,Combo]~}"]    
            }
            else
                joNew:Set[WoWMacro,"${jo.Get[WoWMacro]~}"]
        }

        return joNew
    }

}
