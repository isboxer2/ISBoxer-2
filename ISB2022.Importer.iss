/* isb2022_importer: 
    Read ISBoxer Exported XML, produce ISB2022 JSON profiles

    ISBoxerToolkit.GeneralSettings.XML
    ISBoxerToolkit.KeyMapperSettings.XML
    ISBoxerToolkit.MenuManSettings.XML
    ISBoxerToolkit.RepeaterSettings.XML

*/
objectdef isb2022_importer
{
    variable settingsetref GeneralSettings
    variable settingsetref KeyMapperSettings
    variable settingsetref MenuManSettings
    variable settingsetref RepeaterSettings    

    variable jsonvalue joGeneral
    variable jsonvalue joKeyMapper
    variable jsonvalue joMenuMan
    variable jsonvalue joRepeater

    method LoadXMLFiles()
    {
        variable string scriptsFolder="${LavishScript.HomeDirectory}/Scripts"
        GeneralSettings:Set["${This.LoadXMLFile["ISB2022-Import-General","${scriptsFolder~}/ISBoxerToolkit.GeneralSettings.XML"]}"]
        KeyMapperSettings:Set["${This.LoadXMLFile["ISB2022-Import-KeyMapper","${scriptsFolder~}/ISBoxerToolkit.KeyMapperSettings.XML"]}"]
        MenuManSettings:Set["${This.LoadXMLFile["ISB2022-Import-MenuMan","${scriptsFolder~}/ISBoxerToolkit.MenuManSettings.XML"]}"]
        RepeaterSettings:Set["${This.LoadXMLFile["ISB2022-Import-Repeater","${scriptsFolder~}/ISBoxerToolkit.RepeaterSettings.XML"]}"]

    }

    method StoreJSONFiles()
    {
        variable string scriptsFolder="${LavishScript.HomeDirectory}/Scripts"

        GeneralSettings:ExportJSON["${scriptsFolder~}/ISBoxerToolkit.GeneralSettings.json"]
        KeyMapperSettings:ExportJSON["${scriptsFolder~}/ISBoxerToolkit.KeyMapperSettings.json"]
        MenuManSettings:ExportJSON["${scriptsFolder~}/ISBoxerToolkit.MenuManSettings.json"]
        RepeaterSettings:ExportJSON["${scriptsFolder~}/ISBoxerToolkit.RepeaterSettings.json"]

        joGeneral:ParseFile["${scriptsFolder~}/ISBoxerToolkit.GeneralSettings.json"]
       joKeyMapper:ParseFile["${scriptsFolder~}/ISBoxerToolkit.KeyMapperSettings.json"]
       joMenuMan:ParseFile["${scriptsFolder~}/ISBoxerToolkit.MenuManSettings.json"]
       joRepeater:ParseFile["${scriptsFolder~}/ISBoxerToolkit.RepeaterSettings.json"]


        This:TransformKeyMapper
        This:TransformMenuMan
        This:TransformGeneral

        joGeneral:WriteFile["${scriptsFolder~}/ISBoxerToolkit.GeneralSettings.json",multiline]
       joKeyMapper:WriteFile["${scriptsFolder~}/ISBoxerToolkit.KeyMapperSettings.json",multiline]
       joMenuMan:WriteFile["${scriptsFolder~}/ISBoxerToolkit.MenuManSettings.json",multiline]
       joRepeater:WriteFile["${scriptsFolder~}/ISBoxerToolkit.RepeaterSettings.json",multiline]
    }

    method TransformKeyMapper()
    {
        variable jsonvalue jaKeyMaps="[]"

        joKeyMapper.Get[Key Maps]:ForEach["This:TransformKeyMap[\"\${ForEach.Key~}\",ForEach.Value]"]

        joKeyMapper.Get[Key Maps]:ForEach["jaKeyMaps:AddByRef[ForEach.Value]"]

        joKeyMapper:SetByRef["Key Maps",jaKeyMaps]
;        joKeyMapper:Erase[Key Maps]

    }

    method TransformObjectToArray(jsonvalueref joTransform, string property, string methodName)
    {
        variable jsonvalue ja="[]"
        joTransform.Get["${property~}"]:ForEach["This:${methodName~}[\"\${ForEach.Key~}\",ForEach.Value]"]
        joTransform.Get["${property~}"]:ForEach["ja:AddByRef[ForEach.Value]"]
        joTransform:SetByRef["${property~}",ja]
    }    

    method TransformObjectsToArray(jsonvalueref joTransform, string newProperty, string prefix, string methodName)
    {
        variable jsonvalue ja="[]"
        variable jsonvalueref joCurrent
        variable int numEntry=1
        while 1
        {
            joCurrent:SetReference["joTransform.Get[${prefix~}${numEntry}]"]
            if !${joCurrent.Type.Equal[object]}
            {
                break
            }

            execute "This:${methodName~}[joCurrent]"
            ja:AddByRef[joCurrent]
            joTransform:Erase["${prefix~}${numEntry}"]
            numEntry:Inc
        }
        
        joTransform:SetByRef["${newProperty~}",ja]
    }

    method TransformObjectsToArray(jsonvalueref joTransform, string newProperty, string prefix, string methodName)
    {
        variable jsonvalue ja="[]"
        variable jsonvalueref joCurrent
        variable int numEntry=1
        while 1
        {
            joCurrent:SetReference["joTransform.Get[${prefix~}${numEntry}]"]
            if !${joCurrent.Type.Equal[object]}
            {
                break
            }

            execute "This:${methodName~}[joCurrent]"
            ja:AddByRef[joCurrent]
            joTransform:Erase["${prefix~}${numEntry}"]
            numEntry:Inc
        }
        
        joTransform:SetByRef["${newProperty~}",ja]
    }    

     method TransformValuesToArray(jsonvalueref joTransform, string newProperty, string prefix, string methodName)
    {
        variable jsonvalue ja="[]"
        variable jsonvalueref joCurrent
        variable int numEntry=1
        while 1
        {
            if !${joTransform.Has["${prefix~}${numEntry}"]}
                break

            ja:Add["${joTransform.Get["${prefix~}${numEntry}"].AsJSON~}"]

            joTransform:Erase["${prefix~}${numEntry}"]
            numEntry:Inc
        }
        
        joTransform:SetByRef["${newProperty~}",ja]
    }    

    method TransformSubObjectsToArray(jsonvalueref joTransform, string property, string prefix, string methodName)
    {

        variable jsonvalueref joSub
        joSub:SetReference["joTransform.Get[${property~}]"]
        
        This:TransformObjectsToArray[joSub,"${property~}","${prefix~}","${methodName~}"]

        joTransform:SetByRef["${property~}","joSub.Get[${property~}]"]
    }

    method TransformMenuMan()
    {
        This:TransformObjectToArray[joMenuMan,"Images",TransformImage]
        This:TransformObjectToArray[joMenuMan,"Menus",TransformMenu]
        This:TransformObjectToArray[joMenuMan,"Templates",TransformMenuTemplate]
        This:TransformObjectToArray[joMenuMan,"Hotkey Sets",TransformMenuHotkeySet]
        This:TransformObjectToArray[joMenuMan,"Button Sets",TransformMenuButtonSet]
        This:TransformObjectToArray[joMenuMan,"Action Sets",TransformMenuActionSet]
    }

    method TransformGeneral()
    {
        This:TransformObjectToArray[joGeneral,"Characters",TransformCharacter]
        This:TransformObjectToArray[joGeneral,"Character Sets",TransformCharacterSet]
        This:TransformObjectToArray[joGeneral,"Window Layouts",TransformWindowLayout]
        This:TransformObjectToArray[joGeneral,"Repeater Profiles",TransformRepeaterProfile]
        This:TransformObjectToArray[joGeneral,"Computers",TransformComputer]
;        This:TransformObjectToArray[joGeneral,"Relay Groups",TransformRelayGroup]
        This:TransformObjectToArray[joGeneral,"Action Timer Pools",TransformActionTimerPool]
        This:TransformObjectToArray[joGeneral,"Variable Keystrokes",TransformVariableKeystroke]
    }

    method TransformRepeater()
    {

    }

    method TransformCharacter(string name, jsonvalueref joCharacter)
    {
        joCharacter:SetString[name,"${name~}"]
        
    }

    method TransformCharacterSet(string name, jsonvalueref joCharacterSet)
    {
        joCharacterSet:SetString[name,"${name~}"]

        This:TransformSubObjectsToArray[joCharacterSet,Slots,"Slot ",TransformCharacterSetSlot]
        This:TransformSubObjectsToArray[joCharacterSet,Virtual Mapped Keys,"VMK #",TransformCharacterSetVMK]
    }

    method TransformCharacterSetSlot(jsonvalueref jo)
    {        
        
    }
   
    method TransformCharacterSetVMK(jsonvalueref jo)
    {        
        jo:Erase["value"]
        jo:Erase["_xsi:type"]
    }    
    
    method TransformWindowLayout(string name, jsonvalueref jo)
    {
        jo:SetString[name,"${name~}"]        

        This:TransformSubObjectsToArray[jo,"Regions","",TransformWindowLayoutRegion]
    }

    method TransformWindowLayoutRegion(jsonvalueref jo)
    {        
    }    

    method TransformRepeaterProfile(string name, jsonvalueref jo)
    {
        jo:SetString[name,"${name~}"]        
    }

    method TransformComputer(string name, jsonvalueref jo)
    {
        jo:SetString[name,"${name~}"]        
    }

    method TransformRepeaterProfile(string name, jsonvalueref jo)
    {
        jo:SetString[name,"${name~}"]        
    }

    method TransformComputer(string name, jsonvalueref jo)
    {
        jo:SetString[name,"${name~}"]        
    }

    method TransformRelayGroup(string name, jsonvalueref jo)
    {
        jo:SetString[name,"${name~}"]        
    }

    method TransformActionTimerPool(string name, jsonvalueref jo)
    {
        jo:SetString[name,"${name~}"]        
    }

    method TransformVariableKeystroke(string name, jsonvalueref jo)
    {
        jo:SetString[name,"${name~}"]        

        jo:Erase["_xsi:type"]
    }

    method TransformImage(string name, jsonvalueref joImage)
    {
        joImage:SetString[name,"${name~}"]

        if ${joImage.GetInteger[_Border]}>0
            joImage:SetInteger[border,${joImage.GetInteger[_Border]}]

        if ${joImage.Has[_ColorMask]}
            joImage:SetString[colorMask,"#${joImage.Get[_ColorMask]~.Lower}"]

        joImage:SetString[filename,"${joImage.Get[_Filename]~}"]

        if ${joImage.GetInteger[_Left]}>=0
            joImage:SetInteger[left,${joImage.GetInteger[_Left]}]
        if ${joImage.GetInteger[_Right]}>=0
            joImage:SetInteger[right,${joImage.GetInteger[_Right]}]
        if ${joImage.GetInteger[_Top]}>=0
            joImage:SetInteger[top,${joImage.GetInteger[_Top]}]
        if ${joImage.GetInteger[_Bottom]}>=0
            joImage:SetInteger[bottom,${joImage.GetInteger[_Bottom]}]

        joImage:Erase[_Left]
        joImage:Erase[_Right]
        joImage:Erase[_Top]
        joImage:Erase[_Bottom]
        joImage:Erase[_ColorMask]
        joImage:Erase[_Filename]
        joImage:Erase[_Border]
        joImage:Erase[value]
        joImage:Erase["_xsi:type"]
    }

    method TransformMenu(string name, jsonvalueref joMenu)
    {
        joMenu:SetString[name,"${name~}"]

        joMenu:Erase[value]
        joMenu:Erase["_xsi:type"]
    }

    method TransformMenuTemplate(string name, jsonvalueref joTemplate)
    {
        joTemplate:SetString[name,"${name~}"]

        joTemplate:Erase[value]
        joTemplate:Erase["_xsi:type"]
    }

    method TransformMenuHotkeySet(string name, jsonvalueref joHotkeySet)
    {
        joHotkeySet:SetString[name,"${name~}"]

        This:TransformValuesToArray[joHotkeySet,"hotkeys","Hotkey "]

        joHotkeySet:Erase[value]
        joHotkeySet:Erase["_xsi:type"]
    }

    method TransformMenuButtonSet(string name, jsonvalueref joButtonSet)
    {
        joButtonSet:SetString[name,"${name~}"]

        This:TransformObjectsToArray[joButtonSet,"buttons","Button ",TransformMenuButton]

        joButtonSet:Erase[value]
        joButtonSet:Erase["_xsi:type"]
    }

    method TransformMenuButton(jsonvalueref joButton)
    {
        joButton:Erase[value]
        joButton:Erase["_xsi:type"]
    }

    method TransformMenuActionSet(string name, jsonvalueref joActionSet)
    {
        joActionSet:SetString[name,"${name~}"]

        variable jsonvalueref joStep
        joStep:SetReference["joActionSet.Get[Step 1]"]

        if ${joStep.Reference(exists)}
        {
            This:TransformMappedKeyStep[joStep]
        }

        joActionSet:SetByRef[actions,"joStep.Get[actions]"]

        joActionSet:Erase[Step 1]
        joActionSet:Erase[value]
        joActionSet:Erase["_xsi:type"]
    }

    method TransformKeyMap(string name, jsonvalueref joKeyMap)
    {
        echo "TransformKeyMap ${name~}"

        variable jsonvalue jaMappedKeys="[]"
; todo
        joKeyMap:ForEach["This:TransformMappedKey[\"\${ForEach.Key~}\",jaMappedKeys,ForEach.Value]"]

        jaMappedKeys:ForEach["joKeyMap:Erase[\"\${ForEach.Value.Get[name]~}\"]"]

        joKeyMap:SetString[name,"${name~}"]

        joKeyMap:SetByRef[Mapped Keys,jaMappedKeys]
    }

    method TransformMappedKey(string name, jsonvalueref jaMappedKeys, jsonvalueref joMappedKey)
    {
        if !${joMappedKey.Type.Equal[object]}
            return
        
        echo "TransformMappedKey ${name~}"

        joMappedKey:SetString[name,"${name~}"]

        jaMappedKeys:AddByRef[joMappedKey]

        if ${JoMappedKey.GetBool[Manual Load]}
        {
            joMappedKey:SetBool[enable,FALSE]
        }
        joMappedKey:Erase[Manual Load]

        This:TransformObjectsToArray[joMappedKey,"steps","Step ",TransformMappedKeyStep]
/*
        variable jsonvalue jaSteps="[]"
        variable jsonvalueref joStep
        variable int numStep=1
        while 1
        {
            joStep:SetReference["joMappedKey.Get[Step ${numStep}]"]
            if !${joStep.Type.Equal[object]}
                break

            This:TransformMappedKeyStep[joStep]
            jaSteps:AddByRef[joStep]
            joMappedKey:Erase["Step ${numStep}"]
            numStep:Inc
        }
        
        joMappedKey:SetByRef["steps",jaSteps]
        */
    }

    method TransformMappedKeyStep(jsonvalueref joStep)
    {
        variable jsonvalue jaActions="[]"
        variable jsonvalueref joAction
        variable int numAction=1
        while 1
        {
            joAction:SetReference["joStep.Get[Action_${numAction}]"]
            if !${joAction.Type.Equal[object]}
                break

            This:TransformAction[joAction]

            jaActions:AddByRef[joAction]
            joStep:Erase["Action_${numAction}"]
            numAction:Inc
        }
        
        joStep:SetByRef["actions",jaActions]
    }

    method TransformAction(jsonvalueref joAction)
    {
        joAction:Erase["_xsi:type"]

        if ${joAction.Has["_Target"]}
        {
            joAction:SetString[target,"${joAction.Get[_Target]~}"]
            joAction:Erase["_Target"]
        }

        if ${joAction.Has["_RoundRobin"]}
        {
            if ${joAction.GetBool[_RoundRobin]}
                joAction:SetBool[roundRobin,${joAction.GetBool[_RoundRobin]}]
            joAction:Erase[_RoundRobin]
        }

        if ${joAction.Has[_ActionTimer]} && !${joAction.GetBool[_ActionTimer]}
        {
            joAction:Erase[_ActionTimer]
            joAction:Erase[_ActionTimerSeconds]
            joAction:Erase[_ActionTimerRecurring]
        }

        switch ${joAction.Get[_ActionType]~}
        {
        case DoMappedKey
            This:TransformDoMappedKeyAction[joAction]
            break
        case Keystroke
            This:TransformKeystrokeAction[joAction]
            break
        case KeyMap
            This:TransformKeyMapStateAction[joAction]
            break
        case MappedKey
            This:TransformMappedKeyStateAction[joAction]
            break
        case MappedKeyStep
            This:TransformMappedKeyStepAction[joAction]
            break
        case MenuButton
            This:TransformMenuButtonAction[joAction]
            break
        case MenuState
            This:TransformMenuStateAction[joAction]
            break
        case PopupText
            This:TransformPopupTextAction[joAction]
            break
        case RepeaterState
            This:TransformRepeaterStateAction[joAction]
            break
        case RepeaterTarget
            This:TransformRepeaterTargetAction[joAction]
            break
        case VariableKeystroke
            This:TransformVariableKeystrokeAction[joAction]
            break
        case WindowClose
            This:TransfromWindowCloseAction[joAction]
            break
        case WindowFocus
            This:TransfromWindowFocusAction[joAction]
            break
        }        
    }

    method TransformKeystrokeAction(jsonvalueref joAction)
    {
        joAction:SetString[type,"keystroke"]
        joAction:SetString[key,"${joAction.Get["value"]~}"]        

        joAction:Erase[value]
        joAction:Erase[_ActionType]
    }

    method TransformDoMappedKeyAction(jsonvalueref joAction)
    {
        joAction:SetString[type,"mappable"]
        joAction:SetString[name,"${joAction.Get["value"]~}"]        
        joAction:SetString[sheet,"${joAction.Get["_KeyMap"]~}"]

        if ${joAction.Get[_ConditionalKey]~.NotNULLOrEmpty}
        {
            joAction:SetString[conditionalKey,"${joAction.Get[_ConditionalKey]~}"]
        }

        joAction:Erase[_ConditionalKey]
        joAction:Erase[value]
        joAction:Erase[_KeyMap]
        joAction:Erase[_ActionType]
    }

    method TransformKeyMapStateAction(jsonvalueref joAction)
    {
        joAction:SetString[type,"mappable sheet state"]
        joAction:SetString[sheet,"${joAction.Get["value"]~}"]        

        joAction:Erase[value]
        joAction:Erase[_ActionType]
    }

    method TransformMappedKeyStateAction(jsonvalueref joAction)
    {
        joAction:SetString[type,"mappable state"]
        joAction:SetString[sheet,"${joAction.Get["_KeyMap"]~}"]        
        joAction:SetString[name,"${joAction.Get["value"]~}"]        

        joAction:Erase[_KeyMap]
        joAction:Erase[value]
        joAction:Erase[_ActionType]
    }

    method TransformMappedKeyStepAction(jsonvalueref joAction)
    {
        joAction:SetString[type,"mappable step"]
        joAction:SetInteger[step,"${joAction.Get["value"]~}"]        

        joAction:SetString[name,"${joAction.Get["_MappedKey"]~}"]        
        joAction:SetString[sheet,"${joAction.Get["_KeyMap"]~}"]

        
        joAction:Erase[_MappedKey]
        joAction:Erase[_KeyMap]
        joAction:Erase[value]
        joAction:Erase[_ActionType]
    }

    method TransformMenuButtonAction(jsonvalueref joAction)
    {
        joAction:SetString[type,"menu button"]

        if ${joAction.GetInteger[_Border]}>=0
            joAction:SetInteger[border,${joAction.GetInteger[_Border]}]

        if ${joAction.GetInteger[_Alpha]}>=0
            joAction:SetInteger[alpha,${joAction.GetInteger[_Alpha]}]

        if ${joAction.GetInteger[_FontBold]}>=0
            joAction:SetBool[fontBold,${joAction.GetInteger[_FontBold]}]
        if ${joAction.GetInteger[_FontSize]}>=0
            joAction:SetInteger[fontSize,${joAction.GetInteger[_FontSize]}]

        joAction:SetString[buttonSet,"${joAction.Get[_ButtonSet]~}"]
        joAction:SetInteger[numButton,"${joAction.GetInteger[_NumButton]}"]

        if ${joAction.Assert[_StoreOrRestore,"\"Neither\""]}
        {
            joAction:Erase[_StoreOrRestore]
        }

        joAction:Erase[_NumButton]
        joAction:Erase[_ButtonSet]
        joAction:Erase[_FontBold]
        joAction:Erase[_FontSize]
        joAction:Erase[_Alpha]
        joAction:Erase[_Border]
        joAction:Erase[value]
        joAction:Erase[_ActionType]
    }

    method TransformMenuStateAction(jsonvalueref joAction)
    {
        joAction:SetString[type,"menu state"]
        if ${joAction.Get[value]~.NotNULLOrEmpty}
            joAction:SetString[menu,"${joAction.Get["value"]~}"]        

        joAction:Erase[value]
        joAction:Erase[_ActionType]
    }

    method TransformPopupTextAction(jsonvalueref joAction)
    {
        joAction:SetString[type,"popup text"]
        joAction:SetString[text,"${joAction.Get["value"]~}"]

        joAction:SetInteger[duration,"${joAction.GetInteger[_DurationMS]}"]
        joAction:SetInteger[fadeDuration,"${joAction.GetInteger[_FadeDurationMS]}"]
        joAction:SetString[color,"#${joAction.Get[_Color]~.Lower}"]

        joAction:Erase[_Color]
        joAction:Erase[_DurationMS]
        joAction:Erase[_FadeDurationMS]
        joAction:Erase[value]
        joAction:Erase[_ActionType]
    }

    method TransformRepeaterStateAction(jsonvalueref joAction)
    {
        joAction:SetString[type,"repeater state"]

        if ${joAction.Get[_MouseState]~.NotNULLOrEmpty}
        {
            joAction:SetBool["mouseState",${joAction.Get[_MouseState]~.Equal[On]}]
        }
        if ${joAction.Get[_KeyboardState]~.NotNULLOrEmpty}
        {
            joAction:SetBool["keyboardState",${joAction.Get[_KeyboardState]~.Equal[On]}]
        }
        
        if ${joAction.GetInteger[_VideoFeedState]}>=0
        {
            joAction:SetBool[cursorFeed,${joAction.GetInteger[_VideoFeedState]}]
        }

        if ${joAction.GetInteger[_VideoSourceWidth]} && ${joAction.GetInteger[_VideoSourceHeight]}
        {
            joAction:SetInteger[videoSourceWidth,${joAction.GetInteger[_VideoSourceWidth]}]
            joAction:SetInteger[videoSourceHeight,${joAction.GetInteger[_VideoSourceHeight]}]
        }

        if ${joAction.GetInteger[_VideoOutputWidth]} && ${joAction.GetInteger[_VideoOutputHeight]}
        {
            joAction:SetInteger[videoOutputWidth,${joAction.GetInteger[_VideoOutputWidth]}]
            joAction:SetInteger[videoOutputHeight,${joAction.GetInteger[_VideoOutputHeight]}]
        }

        if ${joAction.GetInteger[_VideoOutputAlpha]}>=0
        {
            joAction:SetInteger[videoOutputAlpha,${joAction.GetInteger[_VideoOutputAlpha]}]
        }

        if ${joAction.Get[_VideoOutputBorderColor]~.Length}>=6
        {
            joAction:SetString[videoOutputBorderColor,"#${joAction.Get[_VideoOutputBorderColor]~.Lower}"]
        }


        joAction:Erase[_VideoSourceWidth]
        joAction:Erase[_VideoSourceHeight]
        joAction:Erase[_VideoOutputWidth]
        joAction:Erase[_VideoOutputHeight]
        joAction:Erase[_VideoOutputAlpha]
        joAction:Erase[_VideoOutputBorderColor]
        joAction:Erase[_VideoFeedState]
        joAction:Erase[_MouseState]
        joAction:Erase[_KeyboardState]        
        joAction:Erase[value]
        joAction:Erase[_ActionType]
    }

    method TransformRepeaterTargetAction(jsonvalueref joAction)
    {
        joAction:SetString[type,"repeater target"]
        joAction:SetString[repeaterTarget,"${joAction.Get["value"]~}"]

        joAction:SetBool[blockLocal,"${joAction.GetBool[_BlockLocal]}"]

        joAction:Erase[_BlockLocal]
        joAction:Erase[value]
        joAction:Erase[_ActionType]
    }

    method TransformVariableKeystrokeAction(jsonvalueref joAction)
    {
        joAction:SetString[type,"game key binding"]
        joAction:SetString[name,"${joAction.Get["value"]~}"]        

        joAction:Erase[value]
        joAction:Erase[_ActionType]
    }

    method TransfromWindowCloseAction(jsonvalueref joAction)
    {
        joAction:SetString[type,"window close"]
        joAction:SetString[mode,"${joAction.Get[value]~}}"]

        joAction:Erase[value]
        joAction:Erase[_ActionType]        
    }

    method TransfromWindowFocusAction(jsonvalueref joAction)
    {
        joAction:SetString[type,"window focus"]

        if ${joAction.Get[_FilterTarget]~.NotNULLOrEmpty}
        {
            joAction:SetString[filterTarget,"${joAction.Get[_FilterTarget]~}"]
        }

        joAction:Erase[_FilterTarget]
        joAction:Erase[_ActionType]        
    }


    member:int LoadXMLFile(string setName, string fileName)
    {
        variable settingsetref loadedSet

   		LavishSettings:AddSet["${setName~}"]
		loadedSet:Set[${LavishSettings.FindSet["${setName~}"]}]
        if ${fileName.NotNULLOrEmpty}
        {
		    loadedSet:Import["${fileName~}"]
        }

        return "${loadedSet}"
    }
}