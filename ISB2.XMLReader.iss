objectdef isb2_isb1transformer
{
    variable jsonvalueref ISBProfile


    member:jsonvalueref TransformXML(string filename)
    {
        ISBProfile:SetReference[NULL]
        variable isb2_xmlreader XMLReader
        ISBProfile:SetReference["XMLReader.Read[\"${filename~}\"]"]
        if !${ISBProfile.Type.Equal[object]}
            return NULL
        This:Transform

       return ISBProfile
    }

    member:jsonvalueref TransformGlobalSettingsXML(string filename)
    {
        variable jsonvalueref joProfile
        
        variable isb2_xmlreader XMLReader
        joProfile:SetReference["XMLReader.Read[\"${filename~}\",ISBoxerToolkitGlobalSettings,1]"]
        if !${joProfile.Type.Equal[object]}
        {
            return NULL
        }
        This:TransformGlobalSettingsRoot[joProfile]

       return joProfile
    }

    member:jsonvalueref TransformRegionsXML(string filename)
    {
        variable jsonvalueref joProfile
        
        variable isb2_xmlreader XMLReader
        joProfile:SetReference["XMLReader.Read[\"${filename~}\",InnerSpaceSettings,1]"]
        if !${joProfile.Type.Equal[object]}
        {
            return NULL
        }
        This:TransformInnerSpaceSettings[joProfile]

        This:TransformRegionsRoot[joProfile]

       return joProfile
    }

    member:jsonvalueref TransformVideoFXXML(string filename)
    {
        variable jsonvalueref joProfile
        
        variable isb2_xmlreader XMLReader
        joProfile:SetReference["XMLReader.Read[\"${filename~}\",InnerSpaceSettings,1]"]
        if !${joProfile.Type.Equal[object]}
        {
            return NULL
        }
        This:TransformInnerSpaceSettings[joProfile]

        This:TransformVideoFXRoot[joProfile]

;        echo "TransformVideoFXXML ${joProfile~}"

       return joProfile
    }

    method TransformInnerSpaceSettings(jsonvalueref joTransform)
    {
;        echo "TransformInnerSpaceSettings ${joTransform~}"
        variable jsonvalue ja="[]"

        This:TransformSingleToArray[joTransform,"Set"]

        joTransform.Get[Set]:ForEach["ja:AddByRef[\"This.TransformInnerSpaceSet\[ForEach.Value\]\"]"]

        joTransform:Erase[Set]

        joTransform:SetByRef[sets,ja]        
        joTransform:Erase[Value]
    }

    member:jsonvalueref TransformInnerSpaceSet(jsonvalueref joTransform)
    {
;        echo "TransformInnerSpaceSet ${joTransform~}"
        variable jsonvalue jaSets="[]"
        variable jsonvalue jaSettings="[]"

        This:TransformSingleToArray[joTransform,"Set"]
        This:TransformSingleToArray[joTransform,"Setting"]

        joTransform.Get[Set]:ForEach["jaSets:AddByRef[\"This.TransformInnerSpaceSet\[ForEach.Value\]\"]"]

        joTransform:Erase[Set]

        joTransform.Get[Setting]:ForEach["jaSettings:AddByRef[\"This.TransformInnerSpaceSetting\[ForEach.Value\]\"]"]

        joTransform:Erase[Setting]

        if ${jaSets.Used}
            joTransform:SetByRef[sets,jaSets]                    
        if ${jaSettings.Used}
            joTransform:SetByRef[settings,jaSettings]        

        return joTransform
    }

    member:jsonvalueref TransformInnerSpaceSetting(jsonvalueref joTransform)
    {
;        echo "TransformInnerSpaceSetting ${joTransform~}"
        return joTransform
    }

    method TransformVideoFXRoot(jsonvalueref joTransform)
    {
;        echo "TransformVideoFXRoot ${joTransform~}"

        variable jsonvalue ja="[]"

        joTransform.Get[sets]:ForEach["ja:AddByRef[\"This.TransformVideoFXSet\[ForEach.Value\]\"]"]

        joTransform:Erase[sets]

        joTransform:SetByRef[vfxSheets,ja]
    }

    method TransformRegionsRoot(jsonvalueref joTransform)
    {
;        echo "TransformRegionsRoot ${joTransform~}"

        variable jsonvalue ja="[]"

        joTransform.Get[sets]:ForEach["ja:AddByRef[\"This.TransformRegionSet\[ForEach.Value\]\"]"]

        joTransform:Erase[sets]

        joTransform:SetByRef[regionSheets,ja]
    }

    method TransformGlobalSettingsRoot(jsonvalueref joTransform)
    {
;        echo "\agTransformGlobalSettingsRoot\ax ${joTransform~}"

        This:TransformSingleToArray[joTransform,"Image"]
        This:TransformSingleToArray[joTransform,"Game"]
        This:TransformSingleToArray[joTransform,"CompatibilityFlags"]

        This:AutoTransform[joTransform,Image,GlobalSettings]
;        This:AutoTransform[joTransform,Game,GlobalSettings]
;        This:AutoTransform[joTransform,CompatibilityFlags,GlobalSettings]

        This:TransformFilename[joTransform,LastProfileFilename,lastProfileFilename]

        This:TransformInteger[joTransform,LastMainSplitter,lastMainSplitter]
        This:TransformInteger[joTransform,LastBottomSplitter,lastBottomSplitter]

        This:TransformBool[joTransform,LastMultiplePCHelperState,lastMultiplePCHelperState]
        This:TransformBool[joTransform,UseInnerSpace64,useInnerSpace64]

        This:TransformBool[joTransform,NeverShowCPUThrottleForm,neverShowCPUThrottleForm]
        This:TransformBool[joTransform,NeverShowCompatibilityForm,neverShowCompatibilityForm]
        This:TransformBool[joTransform,NeverShowMultisamplingWarning,neverShowMultisamplingWarning]
        This:TransformBool[joTransform,NeverShowDxNothingVFXWarning,neverShowDxNothingVFXWarning]
    }
    
    member:jsonvalueref TransformVideoFXSet(jsonvalueref joTransform)
    {
;        echo "TransformVideoFXSet ${joTransform~}"
        variable jsonvalue joNew="{}"

        variable jsonvalue ja="[]"

        joNew:SetString[name,"${joTransform.Get[_Name]~}"]

        joTransform.Get[settings]:ForEach["ja:AddByRef[\"This.TransformVideoFX\[ForEach.Value\]\"]"]

        joNew:SetByRef["vfx",ja]

        return joNew
    }

     member:jsonvalueref TransformVideoFX(jsonvalueref joTransform)
    {
;        echo "TransformVideoFX ${joTransform~}"
        variable jsonvalue joNew="{}"

        if ${joTransform.GetBool[_BlockLocal]}
            joNew:SetBool[blockLocal,1]

        joNew:SetString[name,"${joTransform.Get[_Name]~}"]

        if ${joTransform.Get[_regionname]~.NotNULLOrEmpty}
            joNew:SetString[regionName,"${joTransform.Get[_regionname]~}"]

        if ${joTransform.Get[_mappedkey]~.NotNULLOrEmpty} && ${joTransform.Get[_keymap]~.NotNULLOrEmpty}
        {
            joNew:SetString[keyMap,"${joTransform.Get[_keymap]~}"]
            joNew:SetString[mappedKey,"${joTransform.Get[_mappedkey]~}"]
        }

        joNew:SetString[type,"${joTransform.Get[Value]~}"]
        if ${joTransform.Get[_bordercolor]~.NotNULLOrEmpty}
            joNew:SetString[borderColor,"${joTransform.Get[_bordercolor]~}"]

        if ${joTransform.Has[_opacity]}
            joNew:SetNumber[alpha,"${Math.Calc[${joTransform.GetInteger[_opacity]}/255]}"]

        if ${joTransform.Get[_feedoutput]~.NotNULLOrEmpty}
            joNew:SetString[feedOutput,"${joTransform.Get[_feedoutput]~}"]
        if ${joTransform.Get[_feedsource]~.NotNULLOrEmpty}
            joNew:SetString[feedSource,"${joTransform.Get[_feedsource]~}"]

        joNew:SetInteger[width,"${joTransform.GetInteger[_Width]}"]
        joNew:SetInteger[height,"${joTransform.GetInteger[_Height]}"]
        joNew:SetInteger[x,"${joTransform.GetInteger[_X]}"]
        joNew:SetInteger[y,"${joTransform.GetInteger[_Y]}"]

        if ${joTransform.Has[_usekeyboard]}
            joNew:SetBool[sendKeyboard,"${joTransform.GetBool[_usekeyboard]}"]
        if ${joTransform.Has[_usemouse]}
            joNew:SetBool[sendMouse,"${joTransform.GetBool[_usemouse]}"]

;        joNew:SetByRef[original,joTransform]
        return joNew
    }


    member:jsonvalueref TransformRegionSet(jsonvalueref joTransform)
    {
;        echo "TransformRegionSet ${joTransform~}"
        variable jsonvalue joNew="{}"

        variable jsonvalue ja="[]"

        joNew:SetString[name,"${joTransform.Get[_Name]~}"]

        joTransform.Get[settings]:ForEach["ja:AddByRef[\"This.TransformRegion\[ForEach.Value\]\"]"]

        joNew:SetByRef["regions",ja]

        return joNew
    }

    member:jsonvalueref TransformRegion(jsonvalueref joTransform)
    {
        variable jsonvalue joNew="{}"

        if ${joTransform.GetBool[_BlockLocal]}
            joNew:SetBool[blockLocal,1]

;        joNew:SetString[name,"${joTransform.Get[_Name]~}"]

        if ${joTransform.Get[_regionname]~.NotNULLOrEmpty}
            joNew:SetString[name,"${joTransform.Get[_regionname]~}"]

        if ${joTransform.Get[_mappedkey]~.NotNULLOrEmpty} && ${joTransform.Get[_keymap]~.NotNULLOrEmpty}
        {
            joNew:SetString[keyMap,"${joTransform.Get[_keymap]~}"]
            joNew:SetString[mappedKey,"${joTransform.Get[_mappedkey]~}"]
        }

        joNew:SetString[target,"${joTransform.Get[Value]~}"]


        joNew:SetInteger[width,"${joTransform.GetInteger[_Width]}"]
        joNew:SetInteger[height,"${joTransform.GetInteger[_Height]}"]
        joNew:SetInteger[x,"${joTransform.GetInteger[_X]}"]
        joNew:SetInteger[y,"${joTransform.GetInteger[_Y]}"]

        return joNew
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
        This:TransformSingleToArray[joProfile,"Computer"]
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
        This:AutoTransform[joProfile,"Computer"]        
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

    method TransformSingleToArray(jsonvalueref joTransform, string property, bool spam=0)
    {
        if ${spam}
        {
            echo "\ayTransformSingleToArray[${property~}]:\ax ${joTransform.Get["${property~}"]~}"
        }
        variable jsonvalueref joEntry
        joEntry:SetReference["joTransform.Get[\"${property~}\"]"]

        if !${joEntry.Type.Equal[object]}
        {
            if ${spam}
            {
                echo "\ayTransformSingleToArray:\ax not object"
            }
            return
        }

        variable jsonvalue ja="[]"

        variable jsonvalueref joSubValue
        if ${joEntry.Used} == 1
        {
            joSubValue:SetReference["joEntry.SelectValue[{}]"]
            if ${joSubValue.Reference.Type.Equal[object]}
                ja:AddByRef[joSubValue]
            else
                ja:AddByRef[joEntry]
        }
        elseif ${joEntry.Used}
            ja:AddByRef[joEntry]
        else
        {
            joTransform:Erase["${property~}"]
            return
        }
;        echo Transformed ${property~}
        joTransform:SetByRef["${property~}",ja]
    }

    method TransformSingleToArrayValues(jsonvalueref joTransform, string property)
    {
        variable jsonvalueref joEntry
        joEntry:SetReference["joTransform.Get[\"${property~}\"]"]

        if !${joEntry.Type.Equal[object]}
        {
            if ${joEntry.Reference(exists)}
            {
;                echo "\arTransformSingleToArrayValues\ax ${property~} expected object: ${joEntry~}"
                ; joTransform:SetByRef["${property~}",joEntry]
            }
            return
        }

;        echo "TransformSingleToArrayValues ${joEntry~}"
        variable jsonvalue ja="[]"
        if ${joEntry.Used} == 1        
            joEntry:ForEach["ja:Add[\"\${ForEach.Value.AsJSON~}\"]"]
        elseif ${joEntry.Used}
            ja:AddByRef[joEntry]
        else
        {
            joTransform:Erase["${property~}"]
            return
        }
;        echo "Transformed ${property~}: ${ja~}"
        joTransform:SetByRef["${property~}",ja]
    }

    method TransformBool(jsonvalueref joTransform,string oldProperty, string newProperty, bool defaultValue=0)
    {
        if !${joTransform.Has["${oldProperty~}"]}
            return
        if ${joTransform.GetBool["${oldProperty~}"]}!=${defaultValue}
            joTransform:SetBool["${newProperty~}",${joTransform.GetBool["${oldProperty~}"]}]
        joTransform:Erase["${oldProperty~}"]
    }

    method TransformInteger(jsonvalueref joTransform,string oldProperty, string newProperty, int64 defaultValue=0)
    {
        if !${joTransform.Has["${oldProperty~}"]}
            return
        if ${joTransform.GetInteger["${oldProperty~}"]}!=${defaultValue}
            joTransform:SetInteger["${newProperty~}",${joTransform.GetInteger["${oldProperty~}"]}]
        joTransform:Erase["${oldProperty~}"]
    }

    method TransformNumber(jsonvalueref joTransform,string oldProperty, string newProperty, float64 defaultValue=0)
    {
        if !${joTransform.Has["${oldProperty~}"]}
            return
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

    method TransformFilename(jsonvalueref joTransform,string oldProperty, string newProperty)
    {
        variable filepath fname        

        if ${joTransform.Has["${oldProperty~}"]}
        {
            fname:Set["${joTransform.Get["${oldProperty~}"]~}"]
            if ${fname.StartsWith["${LavishScript.HomeDirectory}/"]}
            {
                ; this will alter the filename to be relative to the current path
                fname:Set["../..${fname.Right[-${LavishScript.HomeDirectory.Length}]}"]
            }

            joTransform:SetString["${newProperty~}","${fname~}"]
            joTransform:Erase["${oldProperty~}"]
        }
    }

    method TransformNullableBool(jsonvalueref joTransform, string oldProperty, string newProperty)
    {
        if ${joTransform.Has["${oldProperty~}",Value]}
        {            
            joTransform:SetBool["${newProperty~}","${joTransform.Get["${oldProperty~}"].GetBool[Value]}"]
            joTransform:Erase["${oldProperty~}"]
        }
    }

    method TransformRect(jsonvalueref joTransform, string oldProperty, string newProperty)
    {
        variable jsonvalueref jo
        jo:SetReference["joTransform.Get[\"${oldProperty~}\"]"]
        if !${jo.Type.Equal[object]}
            return

        variable jsonvalue ja="[]"
        ja:AddInteger["${jo.GetInteger[Left]}"]
        ja:AddInteger["${jo.GetInteger[Top]}"]
        ja:AddInteger["${jo.GetInteger[Width]}"]
        ja:AddInteger["${jo.GetInteger[Height]}"]

        joTransform:SetByRef["${newProperty~}",ja]
        joTransform:Erase["${oldProperty~}"]
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

    method TransformColor(jsonvalueref joTransform, string oldProperty, string newProperty, string defaultValue="")
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

        variable string newValue

        if ${jo.Has[Alpha]}
        {
            newValue:Set["#${Math.Calc64[(${a}<<24) | (${r} << 16) | (${g} << 8) | ${b}].Hex[8]}"]
        }
        else
        {
            newValue:Set["#${Math.Calc64[(${r} << 16) | (${g} << 8) | ${b}].Hex[6]}"]
        }

        if !${newValue.Equal[defaultValue]}
            joTransform:SetString["${newProperty~}","${newValue~}"]

        joTransform:Erase["${oldProperty~}"]
    }

    method AutoTransform_Color(jsonvalueref joTransform, string newProperty, int r=0,int g=0,int b=0,int a=0)
    {
        if ${joTransform.Has[Red]}
            r:Set["${joTransform.GetInteger[Red]}"]
        if ${joTransform.Has[Green]}
            g:Set["${joTransform.GetInteger[Green]}"]
        if ${joTransform.Has[Blue]}
            b:Set["${joTransform.GetInteger[Blue]}"]
        if ${joTransform.Has[Alpha]}
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

    method TransformActionTimer(jsonvalueref joTransform, string oldProperty, string newProperty)
    {
        variable jsonvalueref jo
        jo:SetReference["joTransform.Get[\"${oldProperty~}\"]"]
        if !${jo.Type.Equal[object]}
            return

        This:AutoTransform_ActionTimer[jo]

        if ${jo.Used}
            joTransform:SetByRef["${newProperty~}",jo]
        joTransform:Erase["${oldProperty~}"]
    }

    member:string GetMethodName(string name, string prefix)
    {
        if ${prefix.NotNULLOrEmpty} && ${This(type).Method["AutoTransform_${prefix~}_${name~}"]}
            return "AutoTransform_${prefix~}_${name~}"        
        return "AutoTransform_${name~}"
    }

    method AutoTransform(jsonvalueref joTransform, string name, string prefix, bool spam=0)
    {    
        if !${joTransform.Type.Equal[object]}
        {
            if !${spam}
            {
                echo "AutoTransform: type not object"
            }
            return
        }

        variable string methodName
        methodName:Set["${This.GetMethodName["${name~}","${prefix~}"]}"]

;        echo AutoTransform trying ${methodName~}
        if !${This(type).Method["${methodName~}"]}
        {
            if !${spam}
            {
                echo "\arAutoTransform: no method\ax ${methodName~}"
            }
            return
        }
        variable jsonvalueref jVal
        jVal:SetReference["joTransform.Get[\"${name~}\"]"]
        if ${jVal.Type.Equal[object]}
        {
            variable string cmd
            cmd:Set["This:${methodName~}[jVal]"]

            if ${spam}
               echo "AutoTransform: executing ${cmd~}"
            execute "${cmd~}"
        }
        elseif ${jVal.Type.Equal[array]}
        {
            if ${spam}
                echo "AutoTransform: jsonarray:ForEach"
            jVal:ForEach["This:${methodName~}[ForEach.Value]"]
        }
    }

    method AutoTransform_GlobalSettings_Image(jsonvalueref joTransform)
    {
;        echo "\agAutoTransform_GlobalSettings_Image\ax ${joTransform~}"
        This:TransformColor[joTransform,ColorMask,colorMask,"#ffffff"]
        This:TransformColor[joTransform,ColorKey,colorKey]
        This:TransformRect[joTransform,Crop,crop]
        if ${joTransform.Get[crop,3]}==0 && ${joTransform.Get[crop,4]}==0        
            joTransform:Erase[crop]

        This:TransformInteger[joTransform,Border,border] 
        This:TransformFilename[joTransform,Filename,filename]
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
        This:TransformSingleToArray[joTransform,"KeyMapWhiteOrBlackList"]
        This:TransformSingleToArray[joTransform,"MenuInstances"]
        This:TransformSingleToArray[joTransform,"VirtualMappedKeys"]
        This:TransformSingleToArray[joTransform,"VariableKeystrokeInstances"]
        This:TransformSingleToArray[joTransform,"WoWMacroSets"]
        This:TransformSingleToArrayValues[joTransform,"RelayGroupStrings"]
        This:TransformSingleToArrayValues[joTransform,"KeyMapStrings"]
        This:TransformSingleToArrayValues[joTransform,"ClickBarStrings"]

        This:AutoTransform[joTransform,"VirtualFileTargets"]  

;        This:AutoTransform[joTransform,"MenuInstances",Character]
;        This:AutoTransform[joTransform,"KeyMapWhiteOrBlackList",Character]
        This:AutoTransform[joTransform,"VirtualMappedKeys",Character]

        This:TransformEventAction[joTransform,ExecuteOnLoad,executeOnLoad]

        This:TransformBool[joTransform,MuteBroadcasts,muteBroadcasts]
        This:TransformBool[joTransform,VideoFeedViewersPermanent,videoFeedViewersPermanent]

        This:TransformWoWMacroSets[joTransform,WoWMacroSets,wowMacroSets]

    }

    method AutoTransform_CharacterSet(jsonvalueref joTransform)
    {
;        echo "AutoTransform_CharacterSet ${joTransform~}"


        This:TransformSingleToArrayValues[joTransform,"LaunchCharacterSetStrings"]
        This:TransformSingleToArray[joTransform,"KeyMapWhiteOrBlackList"]
        This:TransformSingleToArray[joTransform,"MenuInstances"]
        This:TransformSingleToArray[joTransform,"Slots"]
        This:TransformSingleToArray[joTransform,"VirtualFileTargets"]
        This:TransformSingleToArray[joTransform,"VirtualMappedKeys"]
        This:TransformSingleToArray[joTransform,"VariableKeystrokeInstances"]
        This:TransformSingleToArray[joTransform,"WoWMacroSets"]        
        This:TransformSingleToArrayValues[joTransform,"KeyMapStrings"]
        This:TransformSingleToArrayValues[joTransform,"ClickBarStrings"]

        This:TransformKeyCombo[joTransform,GUIToggleCombo,guiToggleCombo]
        This:TransformKeyCombo[joTransform,ConsoleToggleCombo,consoleToggleCombo]
        This:TransformKeyCombo[joTransform,VideoFXFocusCombo,videoFXFocusCombo]

        This:TransformEventAction[joTransform,ExecuteOnLoad,executeOnLoad]

        This:TransformInteger[joTransform,LaunchDelay,launchDelay,1]

        This:TransformBool[joTransform,UseConsoleToggleCombo,useConsoleToggleCombo]

        This:TransformBool[joTransform,DynamicLaunchMode,dynamicLaunchMode]
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

;        This:AutoTransform[joTransform,"MenuInstances",CharacterSet]
;        This:AutoTransform[joTransform,"KeyMapWhiteOrBlackList",CharacterSet]
        This:AutoTransform[joTransform,"VirtualFileTargets"]  
        This:AutoTransform[joTransform,"VirtualMappedKeys",CharacterSet]
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
;        echo "\arAutoTransform_CharacterSet_Slots\ax ${joTransform~}"

        This:TransformSingleToArrayValues[joTransform,FTLModifiers]

        if ${joTransform.Has[CPUCores]}
        {
            joTransform:SetByRef[CPUCores,"joTransform.Get[CPUCores,unsignedInt]"]
        }
        This:TransformSingleToArrayValues[joTransform,CPUCores]
        This:TransformSingleToArray[joTransform,VariableKeystrokeInstances]

        This:TransformInteger[joTransform,"ForegroundMaxFPS",foregroundMaxFPS]
        This:TransformInteger[joTransform,"BackgroundMaxFPS",backgroundMaxFPS]

        This:TransformInteger[joTransform,"SwitchToComboIsGlobal",switchToComboIsGlobal]
        This:TransformKeyCombo[joTransform,SwitchToCombo,switchToCombo]
        This:TransformKeyCombo[joTransform,SwitchToEffect,switchToEffect]
        This:TransformString[joTransform,EffectType,effectType,None]

        This:TransformInteger[joTransform,"GenerateFocusTargetMacro",generateFocusTargetMacro]
        This:TransformInteger[joTransform,"GenerateFollowMacro",generateFollowMacro]
        This:TransformInteger[joTransform,"GenerateFollowEnablesJambaStrobing",generateFollowEnablesJambaStrobing]

        This:TransformInteger[joTransform,"LoadOBSRemote",loadOBSRemote]
        This:TransformInteger[joTransform,"LoadTwitch",loadTwitch]

        This:AutoTransform[joTransform,"VariableKeystrokeInstances"]
    }

    method AutoTransform_VirtualMappedKeys(jsonvalueref joTransform)
    {
;        echo "\agAutoTransform_VirtualMappedKeys\ax ${joTransform~}"
        variable jsonvalue jo
        if ${joTransform.Has[FromMappedKey]}
        {
            jo:SetValue["{}"]
            if ${joTransform.Has[FromMappedKey,KeyMapString]}
                jo:SetString[sheet,"${joTransform.Get[FromMappedKey,KeyMapString]~}"]
            if ${joTransform.Has[FromMappedKey,MappedKeyString]}
                jo:SetString[name,"${joTransform.Get[FromMappedKey,MappedKeyString]~}"]
            joTransform:SetByRef[from,jo]

            joTransform:Erase[FromMappedKey]
        }
        if ${joTransform.Has[ToMappedKey]}
        {
            jo:SetValue["{}"]
            if ${joTransform.Has[ToMappedKey,KeyMapString]}
                jo:SetString[sheet,"${joTransform.Get[ToMappedKey,KeyMapString]~}"]
            if ${joTransform.Has[ToMappedKey,MappedKeyString]}
                jo:SetString[name,"${joTransform.Get[ToMappedKey,MappedKeyString]~}"]
            joTransform:SetByRef[to,jo]

            joTransform:Erase[ToMappedKey]
        }
    }

    
    method AutoTransform_Menu(jsonvalueref joTransform)
    {
;        echo "\agAutoTransform_Menu\ax ${joTransform~}"

        This:TransformBool[joTransform,BindSoft,bindSoft]
        This:TransformInteger[joTransform,X,x]
        This:TransformInteger[joTransform,Y,y]
    }

    method AutoTransform_Computer(jsonvalueref joTransform)
    {
;        echo "\arAutoTransform_Computer ${joTransform~}"

        This:TransformInteger[joTransform,"Port","port"]
        This:TransformInteger[joTransform,"ProcessorCount","processorCount"]
        This:TransformString[joTransform,Host,host]
        This:TransformString[joTransform,UplinkName,uplinkName]
        This:TransformString[joTransform,Name,name]

        This:AutoTransform[joTransform,"ScreenSet","Computer"]
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

        This:TransformNumber[joTransform,Stick,stick]
        This:TransformBool[joTransform,Stop,stop]
        This:TransformBool[joTransform,Stump,stump]
        This:TransformBool[joTransform,Disabled,disabled]
    }

    method AutoTransform_ClickBar(jsonvalueref joTransform)
    {
;        echo "\ayAutoTransform_ClickBar\ax ${joTransform~}"

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
;        echo "\ayAutoTransform_ClickBar_Buttons\ax ${joTransform~}"

        This:TransformSingleToArray[joTransform,"ClickActions"]

        This:TransformString[joTransform,Name,name]
        This:TransformString[joTransform,Text,text]
        This:AutoTransform[joTransform,TextStyle,ClickBarButton]

        ; although this setting appears in the profile XML, it is completely unused....
;        This:TransformBool[joTransform,Enabled,enabled,1]
        This:AutoTransform[joTransform,ClickActions,ClickBarButton]
        This:AutoTransform[joTransform,MouseOverAction,ClickBarButton]


        if ${joTransform.Get[MouseOverAction].Used}==0
            joTransform:Erase[MouseOverAction]

        This:TransformEventAction[joTransform,MouseOverAction,mouseoverAction]

        This:TransformBool[joTransform,ClickThrough,clickThrough]        

        This:TransformColor[joTransform,BackgroundColor,backgroundColor]

        if ${joTransform.Has[BackgroundImage,ImageString]}
        {
            joTransform:SetString[backgroundImage,"${joTransform.Get[BackgroundImage,ImageString]~}"]
            joTransform:Erase[BackgroundImage]
        }
    }

    method AutoTransform_ClickBarButton_TextStyle(jsonvalueref joTransform)
    {
        This:TransformString[joTransform,Face,face,Tahoma]

        This:TransformColor[joTransform,Color,color,"#ffffff"]
        This:TransformInteger[joTransform,Size,height,12]
        This:TransformBool[joTransform,Bold,bold,FALSE]
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

        This:TransformNumber[joTransform,Alpha,alpha,-1]
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

        This:TransformSingleToArray[joTransform,"WhiteOrBlackList"]
        This:TransformColor[joTransform,CursorColorMask,cursorColorMask,"#ffffff"]
        
        This:TransformString[joTransform,MouseLight,mouseLight,None]
        This:TransformString[joTransform,KeyboardLight,keyboardLight,None]
        This:TransformString[joTransform,MouseTransformMode,mouseTransformMode,None]

        This:TransformSize[joTransform,CursorFeedSourceSize,cursorFeedSourceSize]
        This:TransformSize[joTransform,CursorFeedOutputSize,cursorFeedOutputSize]
        This:TransformColor[joTransform,CursorFeedBorder,cursorFeedBorder,"#ffffff"]

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
        This:TransformColor[joTransform,BorderColor,borderColor]

        This:TransformSize[joTransform,VideoSourceSize,videoSourceSize]
        This:TransformSize[joTransform,VideoOutputSize,videoOutputSize]
        This:TransformColor[joTransform,VideoOutputBorder,videoOutputBorder]

        This:TransformActionTimer[joTransform,"ActionTimer",timer]

        if ${joTransform.Has[Red]} || ${joTransform.Has[Green]} || ${joTransform.Has[Blue]}
        {
            This:AutoTransform_Color[joTransform,color,255,255,255]
        }

        if ${joTransform.Has[ButtonChanges]}
        {
            This:AutoTransform_MenuButtonSet_Buttons["joTransform.Get[ButtonChanges]"]
        }

        This:TransformString[joTransform,"_xsi:type","type"]
    }

    method AutoTransform_ActionTimer(jsonvalueref joTransform)
    {
        This:TransformString[joTransform,PoolName,name]
        This:TransformNumber[joTransform,Seconds,time]
        This:TransformBool[joTransform,AutoRecurring,recur]
        This:TransformBool[joTransform,Enabled,enabled]
    }

    method AutoTransform_ActionTimerPool(jsonvalueref joTransform)
    {
        This:TransformString[joTransform,Name,name]
        This:TransformString[joTransform,Descrpition,description]
        This:TransformInteger[joTransform,MaxTimers,maxTimers]
        This:TransformBool[joTransform,BackEndRemoval,backEndRemoval]
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
        This:TransformSingleToArray[joTransform,SwapGroups]

        This:TransformString[joTransform,Name,name]
        This:TransformString[joTransform,Description,description]

        This:TransformString[joTransform,SwapMode,swapMode,Never]
        This:TransformString[joTransform,FocusClickMode,focusClickMode,ApplicationDefined]

        This:TransformBool[joTransform,InstantSwap,instantSwap]
        This:TransformBool[joTransform,FocusFollowsMouse,focusFollowsMouse]

        This:AutoTransform[joTransform,Regions,WindowLayout]
        This:AutoTransform[joTransform,SwapGroups,WindowLayout]

        This:AutoTransform[joTransform,UserScreenSet,WindowLayout]
    }

    method AutoTransform_WindowLayout_Regions(jsonvalueref joTransform)
    {
        This:TransformInteger[joTransform,CharacterSetSlot,characterSetSlot]
        This:TransformInteger[joTransform,SwapGroup,swapGroup]

        This:TransformString[joTransform,Name,name]
        This:TransformString[joTransform,Description,description]

        This:TransformBool[joTransform,Permanent,permanent]
        This:TransformString[joTransform,BorderStyle,borderStyle,None]
        This:TransformString[joTransform,AlwaysOnTopMode,alwaysOnTopMode,Normal]

        This:TransformRect[joTransform,Rect,rect]
    }

    method AutoTransform_WindowLayout_SwapGroups(jsonvalueref joTransform)
    {
        This:TransformInteger[joTransform,_ActiveRegion,activeRegion,-1]
        This:TransformInteger[joTransform,_DeactivateSwapGroup,deactivateSwapGroup]
        This:TransformInteger[joTransform,_PiPSqueakSlot,pipSqueakSlot]
        This:TransformInteger[joTransform,_ResetRegion,resetRegion,-1]
    }

    method AutoTransform_UserScreenSet(jsonvalueref joTransform)
    {
        This:AutoTransform_ScreenSet[joTransform]
    }

    method AutoTransform_ScreenSet(jsonvalueref joTransform)
    {
;        echo "AutoTransform_ScreenSet ${joTransform~}"
        This:TransformString[joTransform,Name,name]

        This:TransformSingleToArray[joTransform,AllScreens]

        This:AutoTransform[joTransform,AllScreens,ScreenSet]
    }

    method AutoTransform_ScreenSet_AllScreens(jsonvalueref joTransform)
    {
;        echo "AutoTransform_ScreenSet_AllScreens ${joTransform~}"

        This:TransformString[joTransform,DeviceName,deviceName]

        This:TransformInteger[joTransform,DPIScale,dpiScale,100]
        This:TransformBool[joTransform,Primary,primary]

        This:TransformRect[joTransform,Bounds,bounds]
        This:TransformRect[joTransform,WorkingArea,workingArea]
    }

    
}

objectdef isb2_xmlreader
{
    variable xmlreader XMLReader

    method Read(string filename, string rootNode="ISBoxerToolkitProfile")
    {
        noop ${This.Read["${filename~}","${rootNode~}",1]}
    }

    member:jsonvalueref Read(string filename, string rootNode="ISBoxerToolkitProfile", bool writeFile=0)
    {
        if !${filename.NotNULLOrEmpty}
            filename:Set["${LavishScript.HomeDirectory}/ISBoxerToolkitProfile.LastExported.XML"]

        XMLReader:Reset
        if !${XMLReader:ParseFile["${filename~}"](exists)}
        {
            Script:SetLastError["isb2_xmlreader:Read: Failed to parse file ${filename~}"]
            return NULL
        }

        variable weakref profileNode
        profileNode:SetReference["XMLReader.Root.FindChildElement[\"${rootNode~}\"]"]

        variable jsonvalueref joProfile
        joProfile:SetReference["This.ConvertNodeToObject[profileNode,0]"]

        if ${writeFile} && ${joProfile.Type.Equal[object]}
            joProfile:WriteFile["${filename~}.json",multiline]

        return joProfile
    }    

    member:jsonvalueref ConvertNode(weakref _node)
    {
;        echo "ConvertNode ${_node.AsJSON~}"
        variable jsonvalue jv
        
        if ${_node.Attributes.Type.Equal[object]}
            return "This.ConvertNodeToObject[_node,0]"

        if !${_node.Child(exists)}
        {                        
            jv:SetValue["{}"]
            return jv
        }

        if !${_node.Child.Next(exists)}
        {
            jv:SetValue["${_node.Child.Text.AsJSON~}"]
;            echo "ConvertNode giving VALUE ${jv~}"
            return jv
        }

        return "This.ConvertNodeToObject[_node,1]"
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

    member:jsonvalueref ConvertNodeToObject(weakref _node, bool AutoArray=0)
    {
        variable jsonvalue jo="{}"
        if !${_node.Reference(exists)}
            return jo

;        echo "ConvertNodeToObject ${_node.AsJSON~} Leaf=${_node.Leaf}"

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
;                        jo:Erase[Value]
                    }
                    else
                    {
                        ; no.
                        jo:SetByRef["${_child.Text~}","This.ConvertNode[_child]"]
;                        jo:Erase[Value]
                    }
                    childTypes:Add["${_child.Text~}"]
                }
            }
            else
            {
;                echo "ConvertNodeToObject ${_node.AsJSON~} child=${_child.AsJSON~}"

                if ${_child.Type.Equal[TEXT]} && !${jo.Has[Value]} && ${_node.Leaf}
                {
                    jo:SetString["Value","${_child.Text~}"]
                    break
                }
            }
            _child:SetReference[_child.Next]
        }

        variable jsonvalueref joAttributes
        joAttributes:SetReference[_node.Attributes]

        if ${AutoArray} && ${childTypes.Used}==1 && ${joAttributes.Used}==0 && ${jo.Get["${childTypes.FirstKey~}"](type)~.Equal[jsonarray]}
        {
            ; just contains an array
            if ${_node.Text.Find["${childTypes.FirstKey~}"]}
            {
;                echo "\ayConvertNodeToObject\ax ${_node.AsJSON~} giving ARRAY ${childTypes.FirstKey~}=${jo.Get["${childTypes.FirstKey~}"]}"
                return "jo.Get[\"${childTypes.FirstKey~}\"]"
            }
            switch ${childTypes.FirstKey}
            {
                case MappedKeyAction
                case MappedKey
                case MenuButton
                case FullISKeyCombo
                case ISKey
                case UserScreen            
                case SwapGroup
                case ClickAction
                case unsignedInt
                case FTLModifierEnum
                case MenuInstance
                case KeyMapLooseRef
                case CompatibilityFlagInfo
                    return "jo.Get[\"${childTypes.FirstKey~}\"]"
            }
            

        }
        /**/

        joAttributes:ForEach["jo:SetString[\"_\${ForEach.Key~}\",\"\${ForEach.Value~}\"]"]
        return jo
    }
}