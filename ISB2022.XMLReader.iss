objectdef isb2022_isb1transformer
{
    variable jsonvalueref ISBProfile


    member:jsonvalueref TransformXML(string filename)
    {
        ISBProfile:SetReference[NULL]
       variable isb2022_xmlreader XMLReader
       ISBProfile:SetReference["XMLReader.Read[\"${filename~}\"]"]
       if !${ISBProfile.Type.Equal[object]}
            return NULL
       This:Transform

       return ISBProfile
    }

/*
    method Test(string filename)
    {
        ISBProfile:SetReference[NULL]
        This:LoadXML["${filename~}"]
        This:Transform
        This:WriteJSON["${filename~}.json"]
    }

    method LoadJSON(string filename)
    {
        variable jsonvalue jo
        jo:ParseFile["${filename~}"]

        ISBProfile:SetReference[jo]

        return ${ISBProfile.Type.Equal[object]}
    }

    method WriteJSON(string filename)
    {
        if !${ISBProfile.Type.Equal[object]}
            return

        ISBProfile:WriteFile["${filename~}",multiline]
    }
    /**/

    method Transform()
    {
        This:TransformProfile[ISBProfile]
    }

    method TransformProfile(jsonvalueref joProfile)
    {
        This:TransformSingleToArray[joProfile,"ActionTimerPool"]
        This:TransformSingleToArray[joProfile,"CharacterSet"]
        This:TransformSingleToArray[joProfile,"Character"]
        This:TransformSingleToArray[joProfile,"ClickBar"]
        This:TransformSingleToArray[joProfile,"KeyMap"]
        This:TransformSingleToArray[joProfile,"Menu"]
        This:TransformSingleToArray[joProfile,"MenuButtonSet"]
        This:TransformSingleToArray[joProfile,"MenuHotkeySet"]
        This:TransformSingleToArray[joProfile,"MenuTemplate"] 
        This:TransformSingleToArray[joProfile,"RepeaterProfile"]
        This:TransformSingleToArray[joProfile,"RelayGroup"]
        This:TransformSingleToArray[joProfile,"VariableKeystroke"]
        This:TransformSingleToArray[joProfile,"VirtualFile"]
        This:TransformSingleToArray[joProfile,"WindowLayout"]
        This:TransformSingleToArray[joProfile,"WoWMacroSet"]        

        
        This:AutoTransform[joProfile,"ActionTimerPool"]
        This:AutoTransform[joProfile,"CharacterSet"]
        This:AutoTransform[joProfile,"Character"]
        This:AutoTransform[joProfile,"ClickBar"]        
        This:AutoTransform[joProfile,"KeyMap"]
        This:AutoTransform[joProfile,"Menu"]
        This:AutoTransform[joProfile,"MenuButtonSet"]
        This:AutoTransform[joProfile,"MenuHotkeySet"]
        This:AutoTransform[joProfile,"MenuTemplate"]
        This:AutoTransform[joProfile,"RepeaterProfile"]
        This:AutoTransform[joProfile,"RelayGroup"]
        This:AutoTransform[joProfile,"VariableKeystroke"]
        This:AutoTransform[joProfile,"VirtualFile"]
        This:AutoTransform[joProfile,"WindowLayout"]
        This:AutoTransform[joProfile,"WoWMacroSet"]
    }    

    method TransformSingleToArray(jsonvalueref joTransform, string property)
    {
        variable jsonvalueref joEntry
        joEntry:SetReference["joTransform.Get[\"${property~}\"]"]

        if !${joEntry.Type.Equal[object]}
            return

        variable jsonvalue ja="[]"
        if ${joEntry.Used} == 1        
            joEntry:ForEach["ja:AddByRef[ForEach.Value]"]
        else
            ja:AddByRef[joEntry]
;        echo Transformed ${property~}
        joTransform:SetByRef["${property~}",ja]
    }

    method TransformSingleToArrayValues(jsonvalueref joTransform, string property)
    {
        variable jsonvalueref joEntry
        joEntry:SetReference["joTransform.Get[\"${property~}\"]"]

        if !${joEntry.Type.Equal[object]}
            return

        variable jsonvalue ja="[]"
        if ${joEntry.Used} == 1        
            joEntry:ForEach["ja:Add[\"\${ForEach.Value.AsJSON~}\"]"]
        else
            ja:AddByRef[joEntry]
;        echo Transformed ${property~}
        joTransform:SetByRef["${property~}",ja]
    }

    method TransformBool(jsonvalueref joTransform,string oldProperty, string newProperty, bool defaultValue=0)
    {
        if ${joTransform.GetBool["${oldProperty~}"]}!=${defaultValue}
            joTransform:SetBool["${newProperty~}",${joTransform.GetBool["${oldProperty~}"]}]
        joTransform:Erase["${oldProperty~}"]
    }

    method TransformInteger(jsonvalueref joTransform,string oldProperty, string newProperty, int64 defaultValue=0)
    {
        if ${joTransform.GetInteger["${oldProperty~}"]}!=${defaultValue}
            joTransform:SetInteger["${newProperty~}",${joTransform.GetInteger["${oldProperty~}"]}]
        joTransform:Erase["${oldProperty~}"]
    }

    method TransformNumber(jsonvalueref joTransform,string oldProperty, string newProperty, float64 defaultValue=0)
    {
        if ${joTransform.GetNumber["${oldProperty~}"]}!=${defaultValue}
            joTransform:SetNumber["${newProperty~}",${joTransform.GetNumber["${oldProperty~}"]}]
        joTransform:Erase["${oldProperty~}"]
    }    

    method TransformString(jsonvalueref joTransform,string oldProperty, string newProperty, string defaultValue="")
    {
        if !${joTransform.Has["${oldProperty~}"]}
            return
        if !${joTransform.Assert["${oldProperty~}","${defaultValue.AsJSON~}"]}
            joTransform:SetString["${newProperty~}","${joTransform.Get["${oldProperty~}"]~}"]
        joTransform:Erase["${oldProperty~}"]
    }    

    method TransformNullableBool(jsonvalueref joTransform, string oldProperty, string newProperty)
    {
        if ${joTransform.Has["${oldProperty~}",Value]}
        {            
            joTransform:SetBool["${newProperty~}","${joTransform.Get["${oldProperty~}"].GetBool[Value]}"]
            joTransform:Erase["${oldProperty~}"]
        }
    }

    method TransformSize(jsonvalueref joTransform, string oldProperty, string newProperty)
    {
        variable jsonvalueref jo
        jo:SetReference["joTransform.Get[\"${oldProperty~}\"]"]
        if !${jo.Type.Equal[object]}
            return

        variable jsonvalue ja="[]"
        ja:AddInteger["${jo.GetInteger[Width]}"]
        ja:AddInteger["${jo.GetInteger[Height]}"]

        joTransform:SetByRef["${newProperty~}",ja]
        joTransform:Erase["${oldProperty~}"]
    }

    method TransformColor(jsonvalueref joTransform, string oldProperty, string newProperty)
    {
        variable jsonvalueref jo
        jo:SetReference["joTransform.Get[\"${oldProperty~}\"]"]
        if !${jo.Type.Equal[object]}
            return

            variable int r
            variable int g
            variable int b
            variable int a
            r:Set["${jo.GetInteger[Red]}"]
            g:Set["${jo.GetInteger[Green]}"]
            b:Set["${jo.GetInteger[Blue]}"]
            a:Set["${jo.GetInteger[Alpha]}"]

        if ${jo.Has[Alpha]}
        {
            joTransform:SetString["${newProperty~}","#${Math.Calc64[(${a}<<24) | (${r} << 16) | (${g} << 8) | ${b}].Hex[8]}"]
        }
        else
        {
            joTransform:SetString["${newProperty~}","#${Math.Calc64[(${r} << 16) | (${g} << 8) | ${b}].Hex[6]}"]
        }

        joTransform:Erase["${oldProperty~}"]
    }

    method AutoTransform_Color(jsonvalueref joTransform, string newProperty)
    {
        variable int r
        variable int g
        variable int b
        variable int a
        r:Set["${joTransform.GetInteger[Red]}"]
        g:Set["${joTransform.GetInteger[Green]}"]
        b:Set["${joTransform.GetInteger[Blue]}"]
        a:Set["${joTransform.GetInteger[Alpha]}"]

        if ${joTransform.Has[Alpha]}
        {
            joTransform:SetString["${newProperty~}","#${Math.Calc64[(${a}<<24) | (${r} << 16) | (${g} << 8) | ${b}].Hex[8]}"]
        }
        else
        {
            joTransform:SetString["${newProperty~}","#${Math.Calc64[(${r} << 16) | (${g} << 8) | ${b}].Hex[6]}"]
        }

        joTransform:Erase["Red"]
        joTransform:Erase["Green"]
        joTransform:Erase["Blue"]
        joTransform:Erase["Alpha"]
    }   

    method TransformKeyCombo(jsonvalueref joTransform, string oldProperty, string newProperty)
    {
        variable jsonvalueref jo
        jo:SetReference["joTransform.Get[\"${oldProperty~}\"]"]
        if !${jo.Type.Equal[object]}
            return

        This:AutoTransform_KeyCombo[jo]
        joTransform:SetByRef["${newProperty~}",jo]
        joTransform:Erase["${oldProperty~}"]
    }

    method TransformEventAction(jsonvalueref joTransform, string oldProperty, string newProperty)
    {
        variable jsonvalueref jo
        jo:SetReference["joTransform.Get[\"${oldProperty~}\"]"]
        if !${jo.Type.Equal[object]}
            return

        This:AutoTransform_EventAction[jo]

        if ${jo.Used}
            joTransform:SetByRef["${newProperty~}",jo]
        joTransform:Erase["${oldProperty~}"]
    }

    member:string GetMethodName(string name, string prefix)
    {
        if ${prefix.NotNULLOrEmpty}
            return "AutoTransform_${prefix~}_${name~}"        
        return "AutoTransform_${name~}"
    }

    method AutoTransform(jsonvalueref joTransform, string name, string prefix)
    {    
        if !${joTransform.Type.Equal[object]}
            return

        variable string methodName
        methodName:Set["${This.GetMethodName["${name~}","${prefix~}"]}"]

;        echo AutoTransform trying ${methodName~}
        if !${This(type).Method["${methodName~}"]}
            return

        variable jsonvalueref jVal
        jVal:SetReference["joTransform.Get[\"${name~}\"]"]
        if ${jVal.Type.Equal[object]}
        {
            variable string cmd
            cmd:Set["This:${methodName~}[jVal]"]

 ;           echo "executing ${cmd~}"
            execute "${cmd~}"
        }
        elseif ${jVal.Type.Equal[array]}
        {
            jVal:ForEach["This:${methodName~}[ForEach.Value]"]
        }
    }

    method AutoTransform_EventAction(jsonvalueref joTransform)
    {
        This:TransformBool[joTransform,RoundRobin,roundRobin]
    }
    method AutoTransform_KeyCombo(jsonvalueref joTransform)
    {
        This:TransformString[joTransform,Modifiers,modifiers,None]

        variable jsonvalueref jo
        jo:SetReference["joTransform.Get[Key]"]
        if !${jo.Type.Equal[object]}
            return

        This:TransformInteger[jo,Code,code]
        if ${jo.Used}==0
        {
            joTransform:Erase[Key]
        }
    }
          
    method AutoTransform_Character(jsonvalueref joTransform)
    {
;        echo "AutoTransform_Character ${joTransform~}"
        This:TransformSingleToArray[joTransform,"VirtualFileTargets"]
        This:TransformSingleToArrayValues[joTransform,"RelayGroupStrings"]
        This:TransformSingleToArrayValues[joTransform,"KeyMapStrings"]

;        echo transforming WoWMacroSets...
        This:TransformSingleToArray[joTransform,"WoWMacroSets"]

        This:AutoTransform[joTransform,"VirtualFileTargets"]        
        This:TransformEventAction[joTransform,ExecuteOnLoad,executeOnLoad]

        This:TransformBool[joTransform,MuteBroadcasts,muteBroadcasts]
        This:TransformBool[joTransform,VideoFeedViewersPermanent,videoFeedViewersPermanent]

        This:TransformWoWMacroSets[joTransform,WoWMacroSets,wowMacroSets]

    }

    method AutoTransform_CharacterSet(jsonvalueref joTransform)
    {
;        echo "AutoTransform_CharacterSet ${joTransform~}"

        This:TransformSingleToArray[joTransform,"Slots"]

        This:TransformSingleToArray[joTransform,"WoWMacroSets"]        

        This:TransformKeyCombo[joTransform,GUIToggleCombo,guiToggleCombo]
        This:TransformKeyCombo[joTransform,ConsoleToggleCombo,consoleToggleCombo]
        This:TransformKeyCombo[joTransform,VideoFXFocusCombo,videoFXFocusCombo]

        This:TransformEventAction[joTransform,ExecuteOnLoad,executeOnLoad]

        This:TransformInteger[joTransform,LaunchDelay,launchDelay,1]

        This:TransformBool[joTransform,UseConsoleToggleCombo,useConsoleToggleCombo]


        This:TransformBool[joTransform,LockForeground,lockForeground]
        This:TransformBool[joTransform,LockWindow,lockWindow]
        This:TransformBool[joTransform,DisableJambaTeamManagement,disableJambaTeamManagement]
        This:TransformBool[joTransform,DisableFPSIndicator,disableFPSIndicator]
        This:TransformBool[joTransform,DisableForceWindowed,disableForceWindowed]
        This:TransformBool[joTransform,DisableVSync,disableVSync]
        This:TransformBool[joTransform,AutoMuteBackground,autoMuteBackground]
        This:TransformBool[joTransform,EnforceSingleWindowControl,enforceSingleWindowControl]
        This:TransformBool[joTransform,EnforceSingleWindowControlTested,enforceSingleWindowControlTested]

        This:TransformWoWMacroSets[joTransform,WoWMacroSets,wowMacroSets]

        This:AutoTransform[joTransform,"Slots","CharacterSet"]
    }

    method TransformWoWMacroSets(jsonvalueref joTransform, string oldProperty, string newProperty)
    {
        ; part of Character/CharacterSet
        variable jsonvalueref jaOld
        jaOld:SetReference["joTransform.Get[\"${oldProperty~}\"]"]

        if !${jaOld.Type.Equal[array]}
            return

        variable jsonvalue ja
        ja:SetValue["[]"]

        jaOld:ForEach["ja:AddString[\"\${ForEach.Value.Get[WoWMacroSetString]~}\"]"]

        joTransform:SetByRef["${newProperty~}",ja]
        joTransform:Erase["${oldProperty~}"]
    }

    method AutoTransform_CharacterSet_Slots(jsonvalueref joTransform)
    {
;        echo "AutoTransform_CharacterSet_Slots ${joTransform~}"

        This:TransformSingleToArrayValues[joTransform,FTLModifiers]
        This:TransformSingleToArrayValues[joTransform,CPUCores]
        This:TransformSingleToArray[joTransform,VariableKeystrokeInstances]

        This:TransformInteger[joTransform,"ForegroundMaxFPS",foregroundMaxFPS]
        This:TransformInteger[joTransform,"BackgroundMaxFPS",backgroundMaxFPS]

        This:TransformInteger[joTransform,"SwitchToComboIsGlobal",switchToComboIsGlobal]
        This:TransformKeyCombo[joTransform,SwitchToCombo,switchToCombo]
        This:TransformString[joTransform,EffectType,effectType,None]

        This:TransformInteger[joTransform,"GenerateFocusTargetMacro",generateFocusTargetMacro]
        This:TransformInteger[joTransform,"GenerateFollowMacro",generateFollowMacro]
        This:TransformInteger[joTransform,"GenerateFollowEnablesJambaStrobing",generateFollowEnablesJambaStrobing]

        This:TransformInteger[joTransform,"LoadOBSRemote",loadOBSRemote]
        This:TransformInteger[joTransform,"LoadTwitch",loadTwitch]

        This:AutoTransform[joTransform,"VariableKeystrokeInstances"]
    }


    method AutoTransform_KeyMap(jsonvalueref joTransform)
    {
;        echo "AutoTransform_KeyMap ${joTransform~}"
        This:TransformSingleToArray[joTransform,"Mappings"]

        This:AutoTransform[joTransform,"Mappings","KeyMap"]

        if ${joTransform.GetBool[Hold]}
            joTransform:SetBool[hold,1]
        joTransform:Erase[Hold]

        if ${joTransform.GetBool[UseFTLModifiers]}
            joTransform:SetBool[useFTLModifiers,1]
        joTransform:Erase[UseFTLModifiers]       
    }

    method AutoTransform_VariableKeystroke(jsonvalueref joTransform)
    {
        This:TransformKeyCombo[joTransform,DefaultValue,defaultValue]
    }

    
    method AutoTransform_VariableKeystrokeInstances(jsonvalueref joTransform)
    {
        This:TransformKeyCombo[joTransform,Combo,combo]
    }

    method AutoTransform_VirtualFileTargets(jsonvalueref joTransform)
    {
;        echo "AutoTransform_VirtualFileTargets ${joTransform~}"
        if !${joTransform.Has[VirtualFileString]}
            return

        joTransform:SetString["replacement","${joTransform.Get[Filename]~}"]
        joTransform:SetString["pattern","${joTransform.Get[VirtualFileString]~}"]

        joTransform:Erase[VirtualFileString]
        joTransform:Erase[Filename]
    }

    method AutoTransform_KeyMap_Mappings(jsonvalueref joTransform)
    {
;        echo "AutoTransform_KeyMap_Mappings ${joTransform~}"

        This:TransformSingleToArray[joTransform,"Steps"]

        This:TransformKeyCombo[joTransform,Combo,combo]

        This:AutoTransform[joTransform,"Steps","MappedKey"]

        This:TransformBool[joTransform,ManualLoad,manualLoad]
        This:TransformNumber[joTransform,ResetTimer,resetTimer]
        This:TransformString[joTransform,ResetType,resetType,"Never"]
        This:TransformString[joTransform,Mode,mode,"Default"]
        This:TransformBool[joTransform,SendNextClickBlockLocal,sendNextClickBlockLocal]

        This:TransformNullableBool[joTransform,Hold,hold]
        This:TransformNullableBool[joTransform,UseFTLModifiers,useFTLModifiers]
    }



    method AutoTransform_MappedKey_Steps(jsonvalueref joTransform)
    {
;        echo "AutoTransform_MappedKey_Steps ${joTransform~}"
        This:TransformSingleToArray[joTransform,"Actions"]

        This:AutoTransform[joTransform,Actions]

        This:TransformInteger[joTransform,Stick,stick]
        This:TransformBool[joTransform,Stop,stop]
        This:TransformBool[joTransform,Stump,stump]
        This:TransformBool[joTransform,Disabled,disabled]
    }

    method AutoTransform_ClickBar(jsonvalueref joTransform)
    {
;        echo "AutoTransform_ClickBar ${joTransform~}"

        This:TransformSingleToArray[joTransform,Buttons]

        This:TransformInteger[joTransform,IconSize,iconSize]
        This:TransformInteger[joTransform,IconBorder,iconBorder]
        This:TransformInteger[joTransform,IconPadding,iconPadding]
        This:TransformInteger[joTransform,Border,border]
        This:TransformInteger[joTransform,CellBorder,cellBorder]
        This:TransformInteger[joTransform,Alpha,alpha,1]

        This:TransformInteger[joTransform,X,x]
        This:TransformInteger[joTransform,Y,y]
        This:TransformInteger[joTransform,Rows,rows]
        This:TransformInteger[joTransform,Columns,columns]
        This:TransformInteger[joTransform,RowHeight,rowHeight]
        This:TransformInteger[joTransform,ColumnWidth,columnWidth]

        This:TransformColor[joTransform,BackgroundColor,backgroundColor]
        This:TransformColor[joTransform,CellBorder_Color,cellborderColor]

        This:AutoTransform[joTransform,Buttons,ClickBar]
    }

    method AutoTransform_ClickBar_Buttons(jsonvalueref joTransform)
    {
;        echo "AutoTransform_ClickBar_Buttons ${joTransform~}"

        Thos:TransformSingleToArray[joTransform,"ClickActions"]

        This:TransformBool[joTransform,Enabled,enabled,1]
        This:AutoTransform[joTransform,ClickActions,ClickBarButton]
        This:AutoTransform[joTransform,MouseOverAction,ClickBarButton]

        if ${joTransform.Get[MouseOverAction].Used}==0
            joTransform:Erase[MouseOverAction]

        This:TransformBool[joTransform,ClickThrough,clickThrough]        

        This:TransformColor[joTransform,BackgroundColor,backgroundColor]
    }

    method AutoTransform_ClickBarButton_ClickActions(jsonvalueref joTransform)
    {
;        echo "AutoTransform_ClickBarButton_ClickActions ${joTransform~}"

        This:TransformEventAction[joTransform,Action,action]
        This:TransformString[joTransform,Modifiers,modifiers,"None"]   
    }

    method AutoTransform_ClickBarButton_MouseOverAction(jsonvalueref joTransform)
    {
;        echo "AutoTransform_ClickBarButton_MouseOverAction ${joTransform~}"
        This:TransformString[joTransform,Modifiers,modifiers,"None"]        
        This:TransformEventAction[joTransform,Action,action]

        joTransform:Erase[LeftRight]
    }

    method AutoTransform_MenuHotkeySet(jsonvalueref joTransform)
    {
;        echo "AutoTransform_MenuButtonSet ${joTransform~}"
        This:TransformSingleToArray[joTransform,Hotkeys]

        This:AutoTransform[joTransform,Hotkeys,MenuHotkeySet]
    }

    method AutoTransform_MenuHotkeySet_Hotkeys(jsonvalueref joTransform)
    {
        ;echo "AutoTransform_MenuHotkeySet_Hotkeys ${joTransform~}"
        This:AutoTransform_KeyCombo[joTransform]
    }    

    method AutoTransform_MenuButtonSet(jsonvalueref joTransform)
    {
;        echo "AutoTransform_MenuButtonSet ${joTransform~}"
        This:TransformSingleToArray[joTransform,Buttons]

        This:AutoTransform[joTransform,Buttons,MenuButtonSet]
    }

    method AutoTransform_MenuButtonSet_Buttons(jsonvalueref joTransform)
    {
;        echo "AutoTransform_MenuButtonSet_Buttons ${joTransform~}"
        This:TransformSingleToArray[joTransform,Actions]

        This:TransformInteger[joTransform,Alpha,alpha,-1]
        This:TransformInteger[joTransform,Border,border,-1]
        This:TransformInteger[joTransform,FontBold,fontBold,-1]
        This:TransformInteger[joTransform,FontSize,fontSize,-1]
        This:TransformBool[joTransform,UseImages,useImages]

        This:TransformColor[joTransform,BackgroundColor,backgroundColor]
        This:TransformColor[joTransform,BorderColor,borderColor]
        This:TransformColor[joTransform,FontColor,fontColor]

        This:AutoTransform[joTransform,Actions]
    }

    method AutoTransform_MenuTemplate(jsonvalueref joTransform)
    {
;        echo "AutoTransform_MenuTemplate ${joTransform~}"

        This:TransformBool[joTransform,ClickThrough,clickThrough]

        This:TransformColor[joTransform,BackgroundColor,backgroundColor]
        This:TransformColor[joTransform,BorderColor,borderColor]
        This:TransformColor[joTransform,buttonBackgroundColor,buttonBackgroundColor]
        This:TransformColor[joTransform,buttonBorderColor,buttonBorderColor]
        This:TransformColor[joTransform,buttonFontColor,buttonFontColor]

        This:TransformInteger[joTransform,Alpha,alpha]
        This:TransformInteger[joTransform,Border,border]
        This:TransformInteger[joTransform,buttonAlpha,buttonAlpha]
        This:TransformInteger[joTransform,buttonBorder,buttonBorder]
        This:TransformInteger[joTransform,buttonFontBold,buttonFontBold]
        This:TransformInteger[joTransform,buttonFontSize,buttonFontSize]

        This:TransformInteger[joTransform,NumButtons,numButtons]

        This:TransformInteger[joTransform,Radial_StartOffset,radial_StartOffset]
        This:TransformInteger[joTransform,Radial_RadiusX,radial_RadiusX]
        This:TransformInteger[joTransform,Radial_RadiusY,radial_RadiusY]

        This:TransformNullableBool[joTransform,Popup,popup]
    }

    method AutoTransform_WoWMacroSet(jsonvalueref joTransform)
    {
;        echo "AutoTransform_WoWMacroSet ${joTransform~}"

        This:TransformSingleToArray[joTransform,WoWMacros]

        This:AutoTransform[joTransform,WoWMacros,WoWMacroSet]

        ;This:TransformBool[joTransform,ClickThrough,clickThrough]
    }

    method AutoTransform_WoWMacroSet_WoWMacros(jsonvalueref joTransform)
    {
;        echo "AutoTransform_WoWMacroSet_WoWMacros ${joTransform~}"


        This:TransformString[joTransform,PreCommand,preCommand,"None"]
        This:TransformBool[joTransform,TargetLastTarget,targetLastTarget]
        This:TransformBool[joTransform,UseFTLModifiers,useFTLModifiers]

        This:TransformKeyCombo[joTransform,Combo,combo]

        This:AutoTransform[joTransform,AllowCustomModifiers,WoWMacro]

        if !${joTransform.Get[AllowCustomModifiers].Used}
            joTransform:Erase[AllowCustomModifiers]
    }

    method AutoTransform_WoWMacro_AllowCustomModifiers(jsonvalueref joTransform)
    {
;        echo "AutoTransform_WoWMacro_AllowCustomModifiers ${joTransform~}"

        This:TransformBool[joTransform,LAlt,lAlt]
        This:TransformBool[joTransform,RAlt,rAlt]
        This:TransformBool[joTransform,LShift,lShift]
        This:TransformBool[joTransform,RShift,rShift]
        This:TransformBool[joTransform,LCtrl,lCtrl]
        This:TransformBool[joTransform,RCtrl,rCtrl]
    }

    method AutoTransform_RepeaterProfile(jsonvalueref joTransform)
    {
;        echo "AutoTransform_RepeaterProfile ${joTransform~}"

        This:TransformBool[joTransform,BlockLocal,blockLocal]
        This:TransformBool[joTransform,MuteCursorWhenForeground,muteCursorWhenForeground]
        This:TransformBool[joTransform,KeyRepeatEnabled,keyRepeatEnabled]
        This:TransformBool[joTransform,MouseRepeatEnabled,mouseRepeatEnabled]
        This:TransformBool[joTransform,FalseCursor,falseCursor]
        This:TransformBool[joTransform,CursorFeed,cursorFeed]
        This:TransformBool[joTransform,VideoFXAlwaysAffectsBroadcasting,videoFXAlwaysAffectsBroadcasting]
        This:TransformInteger[joTransform,CursorFeedAlpha,cursorFeedAlpha]

        This:TransformColor[joTransform,CursorColorMask,cursorColorMask]
        
        This:TransformString[joTransform,MouseLight,mouseLight,None]
        This:TransformString[joTransform,KeyboardLight,keyboardLight,None]
        This:TransformString[joTransform,MouseTransformMode,mouseTransformMode,None]
    }

    method AutoTransform_Actions(jsonvalueref joTransform)
    {
;        echo "AutoTransform_Actions ${joTransform~}"
        This:TransformSingleToArray[joTransform,"WhiteOrBlackList"]

        This:TransformBool[joTransform,"RoundRobin","roundRobin"]
        This:TransformBool[joTransform,"UseFTLModifiers","useFTLModifiers"]

        This:AutoTransform[joTransform,"UseCustomModifiers","Action"]
        if !${joTransform.Get[UseCustomModifiers].Used}
            joTransform:Erase[UseCustomModifiers]

        This:TransformKeyCombo[joTransform,Combo,combo]

        This:TransformString[joTransform,KeyMapString,keyMap]
        This:TransformString[joTransform,MappedKeyString,mappedKey]

        This:TransformInteger[joTransform,DurationMS,durationMS]
        This:TransformInteger[joTransform,FadeDurationMS,fadeDurationMS]

        This:TransformColor[joTransform,BackgroundColor,backgroundColor]

        This:TransformSize[joTransform,VideoSourceSize,videoSourceSize]
        This:TransformSize[joTransform,VideoOutputSize,videoOutputSize]
        This:TransformColor[joTransform,VideoOutputBorder,videoOutputBorder]

        if ${joTransform.Has[Red]} || ${joTransform.Has[Green]} || ${joTransform.Has[Blue]}
        {
            This:AutoTransform_Color[joTransform,color]
        }

        This:TransformString[joTransform,"_xsi:type","type"]
    }

    method AutoTransform_Action_UseCustomModifiers(jsonvalueref joTransform)
    {
        This:TransformBool[joTransform,LAlt,lAlt]
        This:TransformBool[joTransform,RAlt,rAlt]
        This:TransformBool[joTransform,LShift,lShift]
        This:TransformBool[joTransform,RShift,rShift]
        This:TransformBool[joTransform,LCtrl,lCtrl]
        This:TransformBool[joTransform,RCtrl,rCtrl]
    }

    method AutoTransform_WindowLayout(jsonvalueref joTransform)
    {
        This:TransformSingleToArray[joTransform,Regions]

        This:TransformString[joTransform,SwapMode,swapMode,Never]
        This:TransformString[joTransform,FocusClickMode,focusClickMode,ApplicationDefined]

        This:TransformBool[joTransform,InstantSwap,instantSwap]
        This:TransformBool[joTransform,FocusFollowsMouse,focusFollowsMouse]

        This:AutoTransform[joTransform,Regions,WindowLayout]
        This:AutoTransform[joTransform,SwapGroups,WindowLayout]
    }

    method AutoTransform_WindowLayout_Regions(jsonvalueref joTransform)
    {
        This:TransformInteger[joTransform,CharacterSetSlot,characterSetSlot]
        This:TransformInteger[joTransform,SwapGroup,swapGroup]

        This:TransformBool[joTransform,Permanent,permanent]
        This:TransformString[joTransform,BorderStyle,borderStyle,None]
        This:TransformString[joTransform,AlwaysOnTopMode,alwaysOnTopMode,Normal]
    }

    method AutoTransform_WindowLayout_SwapGroups(jsonvalueref joTransform)
    {
        This:TransformInteger[joTransform,_ActiveRegion,activeRegion,-1]
        This:TransformInteger[joTransform,_DeactivateSwapGroup,deactivateSwapGroup]
        This:TransformInteger[joTransform,_PiPSqueakSlot,pipSqueakSlot]
        This:TransformInteger[joTransform,_ResetRegion,resetRegion,-1]
    }
}

objectdef isb2022_xmlreader
{
    variable xmlreader XMLReader

    method Read(string filename)
    {
        noop ${This.Read["${filename~}",1]}
    }

    member:jsonvalueref Read(string filename, bool writeFile)
    {
        if !${filename.NotNULLOrEmpty}
            filename:Set["${LavishScript.HomeDirectory}/ISBoxerToolkitProfile.LastExported.XML"]

        XMLReader:Reset
        XMLReader:ParseFile["${filename~}"]

        variable weakref profileNode
        profileNode:SetReference["XMLReader.Root.FindChildElement[ISBoxerToolkitProfile]"]

        variable jsonvalueref joProfile
        joProfile:SetReference["This.ConvertNodeToObject[profileNode]"]

        if ${writeFile} && ${joProfile.Type.Equal[object]}
            joProfile:WriteFile["${filename~}.json",multiline]

        return joProfile
    }

    member:jsonvalueref ConvertNode(weakref _node)
    {
;        echo ConvertNode ${_node}
        variable jsonvalue jv
        
        if ${_node.Attributes.Type.Equal[object]}
            return "This.ConvertNodeToObject[_node]"

        if !${_node.Child(exists)}
        {                        
            jv:SetValue[""]
            return jv
        }

        if !${_node.Child.Next(exists)}
        {
            jv:SetValue["${_node.Child.Text.AsJSON~}"]
            return jv
        }

        return "This.ConvertNodeToObject[_node]"
    }

    member:jsonvalueref ConvertNodesToArray(weakref _parent, string _tag)
    {
        variable jsonvalue ja="[]"
        if !${_parent.Reference(exists)}
            return ja

;        echo "ConvertNodesToArray ${_tag~}"

        variable weakref _child
        _child:SetReference["_parent.FindChildElement[\"${_tag~}\"]"]

        variable jsonvalueref joConverted

        while ${_child.Reference(exists)}
        {
            joConverted:SetReference["This.ConvertNode[_child]"]
  ;          echo "joConverted=${joConverted~}"
            ja:AddByRef[joConverted]

            _child:SetReference["_parent.FindNextChildElement[_child,\"${_tag~}\"]"]
        }
        return ja
    }

    member:jsonvalueref ConvertNodeToObject(weakref _node)
    {
        variable jsonvalue jo="{}"
        if !${_node.Reference(exists)}
            return jo


        variable weakref _child

        variable set childTypes

        _child:SetReference[_node.Child]

        while ${_child.Reference(exists)}
        {
            if ${_child.Type.Equal[ELEMENT]}
            {
                if !${childTypes.Contains["${_child.Text~}"]}
                {
                    ; do we have more than one of these?
                    if ${_node.FindNextChildElement[_child,"${_child.Text~}"](exists)}
                    {
                        ; yes.
 ;                       echo "ConvertNode ${_child.AsJSON~}"
 ;                       echo "... build an array of ${_child.Text~}"

                        jo:SetByRef["${_child.Text~}","This.ConvertNodesToArray[_node,\"${_child.Text~}\"]"]
                    }
                    else
                    {
                        ; no.
                        jo:SetByRef["${_child.Text~}","This.ConvertNode[_child]"]
                    }
                    childTypes:Add["${_child.Text~}"]
                }
            }
            _child:SetReference[_child.Next]
        }

        variable jsonvalueref joAttributes
        joAttributes:SetReference[_node.Attributes]

        if ${childTypes.Used}==1 && ${joAttributes.Used}==0 && ${jo.Get["${childTypes.FirstKey~}"](type)~.Equal[jsonarray]}
        {
            ; just contains an array
            if ${_node.Text.Find["${childTypes.FirstKey~}"]} || ${childTypes.FirstKey.Equal[MappedKeyAction]} || ${childTypes.FirstKey.Equal[MappedKey]} || ${childTypes.FirstKey.Equal[MenuButton]} || ${childTypes.FirstKey.Equal[FullISKeyCombo]} || ${childTypes.FirstKey.Equal[ISKey]}
                return "jo.Get[\"${childTypes.FirstKey~}\"]"
        }
        /**/

        joAttributes:ForEach["jo:SetString[\"_\${ForEach.Key~}\",\"\${ForEach.Value~}\"]"]

        return jo
    }
}