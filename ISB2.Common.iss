/* isb2_profile: 
    A set of definitions for ISBoxer 2. Like an ISBoxer Toolkit Profile, but preferably more generic.
*/
objectdef isb2_profile
{
    variable string LocalFilename
    variable uint Priority

    variable string Name
    variable string Description
    variable string Version
    variable uint MinimumBuild
    variable jsonvalueref Metadata

    variable jsonvalueref Profiles=[]
    variable jsonvalueref Teams=[]
    variable jsonvalueref Characters=[]
    variable jsonvalueref BroadcastProfiles=[]
    variable jsonvalueref WindowLayouts=[]
    variable jsonvalueref VirtualFiles=[]
    variable jsonvalueref Triggers=[]
    variable jsonvalueref HotkeySheets=[]
    variable jsonvalueref MappableSheets=[]
    variable jsonvalueref GameKeyBindings=[]
    variable jsonvalueref GameMacroSheets=[]
    variable jsonvalueref ClickBars=[]
    variable jsonvalueref ClickBarTemplates=[]
    variable jsonvalueref ClickBarButtonLayouts=[]
    variable jsonvalueref ImageSheets=[]
    variable jsonvalueref VFXSheets=[]

    method Initialize(jsonvalueref jo, uint priority, string localFilename)
    {
        This:FromJSON[jo]
        Priority:Set[${priority}]
        if ${localFilename.NotNULLOrEmpty}
            LocalFilename:Set["${localFilename~}"]
    }

    method FromJSON(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        if ${jo.Has[name]}
            Name:Set["${jo.Get[name]~}"]
        if ${jo.Has[description]}
            Name:Set["${jo.Get[description]~}"]
        if ${jo.Has[version]}
            Name:Set["${jo.Get[version]~}"]
        if ${jo.Has[minimumBuild]}
            Name:Set["${jo.Get[minimumBuild]~}"]

        if ${jo.Has[metadata]}
            Metadata:SetReference["jo.Get[metadata]"]
        if ${jo.Has[profiles]}
            Profiles:SetReference["jo.Get[profiles]"]
        if ${jo.Has[teams]}
            Teams:SetReference["jo.Get[teams]"] 
        if ${jo.Has[characters]}
            Characters:SetReference["jo.Get[characters]"]
        if ${jo.Has[broadcastProfiles]}
            BroadcastProfiles:SetReference["jo.Get[broadcastProfiles]"]
        if ${jo.Has[windowLayouts]}
            WindowLayouts:SetReference["jo.Get[windowLayouts]"]
        if ${jo.Has[virtualFiles]}
            VirtualFiles:SetReference["jo.Get[virtualFiles]"]
        if ${jo.Has[triggers]}
            Triggers:SetReference["jo.Get[triggers]"]
        if ${jo.Has[hotkeySheets]}
            HotkeySheets:SetReference["jo.Get[hotkeySheets]"]
        if ${jo.Has[gameKeyBindings]}
            GameKeyBindings:SetReference["jo.Get[gameKeyBindings]"]
        if ${jo.Has[mappableSheets]}
            MappableSheets:SetReference["jo.Get[mappableSheets]"]
        if ${jo.Has[vfxSheets]}
            VFXSheets:SetReference["jo.Get[vfxSheets]"]
        if ${jo.Has[imageSheets]}
            ImageSheets:SetReference["jo.Get[imageSheets]"]
        if ${jo.Has[clickBars]}
            ClickBars:SetReference["jo.Get[clickBars]"]
        if ${jo.Has[clickBarTemplates]}
            ClickBarTemplates:SetReference["jo.Get[clickBarTemplates]"]
        if ${jo.Has[clickBarButtonLayouts]}
            ClickBarButtonLayouts:SetReference["jo.Get[clickBarButtonLayouts]"]
        if ${jo.Has[gameMacroSheets]}
            GameMacroSheets:SetReference["jo.Get[gameMacroSheets]"]
    }

    member:jsonvalueref AsJSON()
    {
        variable jsonvalue jo

        jo:SetValue["$$>
        {
            "$schema":"http://www.lavishsoft.com/schema/isb2.json",
            "name":${Name.AsJSON~}
        }
        <$$"]

        if ${Description.NotNULLOrEmpty}
            jo:Set["description",Description]
        if ${Version.NotNULLOrEmpty}
            jo:Set["version",Version]
        if ${MinimumBuild}
            jo:Set["description",Description]
        if ${Metadata.Type.Equal[object]}
            jo:SetByRef["metadata","Metadata"]
        if ${Profiles.Used}
            jo:SetByRef["profiles",Profiles]
        if ${Teams.Used}
            jo:SetByRef["teams",Teams]
        if ${Characters.Used}
            jo:SetByRef["characters",Characters]
        if ${WindowLayouts.Used}
            jo:SetByRef["windowLayouts",WindowLayouts]
        if ${BroadcastProfiles.Used}
            jo:SetByRef["broadcastProfiles",BroadcastProfiles]
        if ${VirtualFiles.Used}
            jo:SetByRef["virtualFiles",VirtualFiles]
        if ${Triggers.Used}
            jo:SetByRef["triggers",Triggers]
        if ${HotkeySheets.Used}
            jo:SetByRef["hotkeySheets",HotkeySheets]
        if ${GameKeyBindings.Used}
            jo:SetByRef["gameKeyBindings",GameKeyBindings]
        if ${MappableSheets.Used}
            jo:SetByRef["mappableSheets",MappableSheets]
        if ${VFXSheets.Used}
            jo:SetByRef["vfxSheets",VFXSheets]
        if ${ImageSheets.Used}
            jo:SetByRef["imageSheets",ImageSheets]
        if ${ClickBars.Used}
            jo:SetByRef["clickBars",ClickBars]
        if ${ClickBarTemplates.Used}
            jo:SetByRef["clickBarTemplates",ClickBarTemplates]
        if ${ClickBarButtonLayouts.Used}
            jo:SetByRef["clickBarButtonLayouts",ClickBarButtonLayouts]
        if ${GameMacroSheets.Used}
            jo:SetByRef["gameMacroSheets","GameMacroSheets"]
        return jo
    }

    method Store()
    {
        if ${LocalFilename.NotNULLOrEmpty}
        {
            This.AsJSON:WriteFile["${LocalFilename~}",multiline]
            return TRUE
        }
        return FALSE
    }

    member:jsonvalueref SelectNames(string arrayName)
    {
        if !${arrayName.NotNULLOrEmpty}
            return NULL

        variable set Names

        variable jsonvalueref ja="This.${arrayName~}"

        ja:ForEach["Names:Add[\"\${ForEach.Value.Get[name]~}\"]"]

        variable jsonvalue jaOutput
        jaOutput:SetValue["${Names.AsJSON~}"]

        return jaOutput
    }

    member:jsonvalueref FindOne(string arrayName,string objectName)
    {
        variable jsonvalue joSelect="$$>
        {
            "eval":"Select.Get[name]",
            "op":"==",
            "value":${objectName.AsJSON~}
        }
        <$$"
        return "This.${arrayName~}.SelectValue[joSelect]"
    }
}


/* isb2_profilecollection: 
    A collection of ISBoxer 2 profiles
*/
objectdef isb2_profilecollection
{
    ; The variable that contains the actual list
    variable collection:isb2_profile Profiles

    variable collection:isb2_profileeditor Editors

    variable uint LoadCount

    /*
    member:jsonvalueref ScanFolder(filepath filePath)
    {
        echo ${filePath.GetFiles[*.isb2.json]}
        return "filePath.GetFiles[*.isb2.json]"
    }
    /**/

    member:jsonvalueref GetLoadedFilenames()
    {
        variable set Filenames
        Profiles:ForEach["Filenames:Add[\"\${ForEach.Value.LocalFilename~}\"]"]

        variable jsonvalue ja
        ja:SetValue["${Filenames.AsJSON~}"]
        return ja
    }

    method LoadFiles(jsonvalueref jaFilenames)
    {
        if !${jaFilenames.Type.Equal[array]}
            return FALSE

        jaFilenames:ForEach["This:LoadFile[\"\${ForEach.Value~}\"]"]
        return TRUE
    }

    method LoadFolder(filepath filePath)
    {
        echo LoadFolder ${filePath~}
        filePath.GetFiles["*.isb2.json"]:ForEach["This:LoadFile[\"${filePath~}/\${ForEach.Value.Get[filename]}\"]"]
    }

    method OpenEditor(string profileName)
    {
        if ${Editors.Get["${profileName~}"](exists)}
            return

        if !${Profiles.Get["${profileName~}"](exists)}
            return

        Editors:Set["${profileName~}","Profiles.Get[\"${profileName~}\"]"]
    }

    ; Loads a profile from a given file
    method LoadFile(filepath fileName)
    {
        ; given a path like "Tests/WoW.isb2.json" this turns it into like "C:/blah blah/Tests/isb2.json"
        fileName:MakeAbsolute
        
        ; parse the file into, hopefully, a json object
        variable jsonvalue jo        
        if !${jo:ParseFile["${fileName~}"](exists)}
            return FALSE

        ; if we got something else, forget it
        if !${jo.Type.Equal[object]}
        {
            echo "isb2_profilecollection:LoadFile[${fileName~}]: expected JSON object, got ${jo.Type~}"
            return FALSE
        }

        ; a profile is required to have a name, so we can more easily work with multiple profiles!
        if !${jo.Has[name]}
        {
            echo "isb2_profilecollection:LoadFile[${fileName~}]: 'name' field required"
            return FALSE
        }

        ; temporarily store the name since we'll need it a few times
        variable string name
        name:Set["${jo.Get[name]~}"]

        LoadCount:Inc
        ; Assign the Profile
        Profiles:Set["${name~}","jo",${LoadCount},"${fileName~}"]

        ; the isb2_profile object is now created, assign its LocalFilename
        Profiles.Get["${name~}"].LocalFilename:Set["${fileName~}"]
;        echo "Profile added: ${name~}"

        ; fire an event for the GUI to refresh its Profiles if needed
        LGUI2.Element[isb2.events]:FireEventHandler[onProfilesUpdated] 
    }

    method RemoveProfile(string name)
    {
        Profiles:Erase["${name~}"]

        ; fire an event for the GUI to refresh its Profiles if needed
        LGUI2.Element[isb2.events]:FireEventHandler[onProfilesUpdated] 
    }

    member:jsonvalueref SelectAllNames(string arrayName)
    {
        variable set Names

        Profiles:ForEach["ForEach.Value.SelectNames[\"${arrayName~}\"]:ForEach[\"Names:Add[\"\\\${ForEach.Value~}\"]\"]"]

        variable jsonvalue ja
        ja:SetValue["${Names.AsJSON~}"]

        return ja
    }

    member:jsonvalueref FindOne(string arrayName,string objectName, string preferProfile="")
    {
        variable uint foundPriority=0
        variable jsonvalueref foundObject

        variable jsonvalueref checkObject

        variable iterator Iterator

        if !${preferProfile.NotNULLOrEmpty}
        {
            checkObject:SetReference["Profiles.Get[\"${preferProfile~}\"].FindOne[\"${arrayName~}\",\"${objectName~}\"]"]
            if ${checkObject.Type.Equal[object]}
                return checkObject            
        }

        Profiles:GetIterator[Iterator]

        if !${Iterator:First(exists)}
        {
 ;           echo "FindOne[${arrayName~},${objectName~}] !Iterator:First"
            return NULL
        }
        do
        {
            if ${Iterator.Value.Priority} > ${foundPriority}
            {
                checkObject:SetReference["Iterator.Value.FindOne[\"${arrayName~}\",\"${objectName~}\"]"]
;                echo checkObject:SetReference["Iterator.Value.FindOne[\"${arrayName~}\",\"${objectName~}\"]"]
;                echo "FindOne: Profile ${Iterator.Key~} had ${checkObject~}"
                if ${checkObject.Type.Equal[object]}
                {
                    foundObject:SetReference[checkObject]
                    foundPriority:Set[${Iterator.Value.Priorioty}]
                }
            }
        }
        while ${Iterator:Next(exists)}

        return foundObject
    }

    member:jsonvalueref Locate(string arrayName,string objectName, string preferProfile="")
    {
        variable uint foundPriority=0
        variable jsonvalue result

        variable jsonvalueref checkObject

        if !${preferProfile.NotNULLOrEmpty}
        {
            checkObject:SetReference["Profiles.Get[\"${preferProfile~}\"].FindOne[\"${arrayName~}\",\"${objectName~}\"]"]
            if ${checkObject.Type.Equal[object]}
            {
                result:SetValue["{}"]
                result:SetString["profile","${Iterator.Key~}"]
                result:SetByRef["object",checkObject]
                return result
            }
        }

        variable iterator Iterator
        Profiles:GetIterator[Iterator]

        if !${Iterator:First(exists)}
            return NULL

        do
        {
            if ${Iterator.Value.Priority} > ${foundPriority}
            {
                checkObject:SetReference["Iterator.Value.FindOne[\"${arrayName~}\",\"${objectName~}\"]"]
                if ${checkObject.Type.Equal[object]}
                {
                    result:SetValue["{}"]
                    result:SetString["profile","${Iterator.Key~}"]
                    result:SetByRef["object",checkObject]
                    foundPriority:Set[${Iterator.Value.Priorioty}]
                }
            }
        }
        while ${Iterator:Next(exists)}

        return result
    }
}

objectdef isb2_profileeditor
{
    variable weakref Editing
    variable weakref EditingItem
    variable lgui2elementref Window

    method Initialize(weakref _profile)
    {
        Editing:SetReference[_profile]
        LGUI2:PushSkin["ISBoxer 2"]
        Window:Set["${LGUI2.LoadReference["LGUI2.Template[isb2.profileEditor]",This].ID}"]
        Window:AddHook["onVisualDetached","$$>
        {
            "type":"method",
            "object":"This.Context",
            "method":"OnWindowClosed"
        }
        <$$"]
        LGUI2:PopSkin["ISBoxer 2"]
    }

    method Shutdown()
    {
        Window:Destroy
    }

    method OnWindowClosed()
    {
        ISB2.Editors:Erase["${Editing.Name~}"]
    }

    member:string GetLowerCamelCase(string fromString)
    {
        return "${fromString.Lower.Left[1]}${fromString.Right[-1]}"
    }

    method ResetSelections(string editingType)
    {
        if ${editingType.NotEqual["Character"]}
            Window.Locate["profile.characters"]:ClearSelection
        if ${editingType.NotEqual["MappableSheet"]}
            Window.Locate["profile.mappableSheets"]:ClearSelection
        if ${editingType.NotEqual["Team"]}
            Window.Locate["profile.teams"]:ClearSelection
        if ${editingType.NotEqual["GameKeyBinding"]}
            Window.Locate["profile.gameKeyBindings"]:ClearSelection
        if ${editingType.NotEqual["VirtualFile"]}
            Window.Locate["profile.virtualFiles"]:ClearSelection
    }

    method SetEditingItem(string editingType, uint editingNumber)
    {
        EditingItem:SetReference["Editing.${editingType~}s.Get[${editingNumber}]"]
        Window.Locate["profile.editorContainer"]:SetChild["${LGUI2.Template[isb2.${This.GetLowerCamelCase["${editingType~}"]}Editor]~}","EditingItem"]
    }

    method OnCharacterSelected()
    {
        This:ResetSelections[Character]
        This:SetEditingItem[Character,${Context.Source.SelectedItem.Index}]
    }

    method OnMappableSheetSelected()
    {
        This:ResetSelections[MappableSheet]
        This:SetEditingItem[MappableSheet,${Context.Source.SelectedItem.Index}]
    }

    method OnTeamSelected()
    {
        This:ResetSelections[Team]
        This:SetEditingItem[Team,${Context.Source.SelectedItem.Index}]
    }

    method OnGameKeyBindingSelected()
    {
        This:ResetSelections[GameKeyBinding]
        This:SetEditingItem[GameKeyBinding,${Context.Source.SelectedItem.Index}]        
    }

    method OnVirtualFileSelected()
    {
;        echo "OnVirtualFileSelected Context(type)=${Context(type)} Source(type)=${Context.Source(type)} Args=${Context.Args~}"
;        echo "SelectedItem.Index=${Context.Source.SelectedItem.Index} SelectedItem.Data=${Context.Source.SelectedItem.Data~}"

        This:ResetSelections[VirtualFile]
        This:SetEditingItem[VirtualFile,${Context.Source.SelectedItem.Index}]
;        echo "OnVirtualFileSelected. EditingItem = ${EditingItem~}"        
    }
}

objectdef isb2_clickbarButton
{
    variable weakref ClickBar
    variable int NumButton
    variable jsonvalueref Data
    variable lgui2elementref Element
    variable jsonvalue ActiveClicks="[null,null,null,null,null]"

    method Initialize(weakref _clickBar, int _numButton, jsonvalueref jo)
    {
        ClickBar:SetReference[_clickBar]
        NumButton:Set[${_numButton}]
        Data:SetReference[jo]
    }

    method Shutdown()
    {
        Element:Destroy
    }

    member:jsonvalueref GetImageBrush(jsonvalueref joImage)
    {
        if !${joImage.Type.Equal[object]}
            return NULL

        variable jsonvalue joImageBrush="{}"

        if ${joImage.Has[filename]}
            joImageBrush:SetString[imageFile,"${joImage.Get[filename]~}"]
        if ${joImage.Has[colorMask]}
            joImageBrush:SetString[color,"${joImage.Get[colorMask]~}"]
        elseif ${joImage.Has[filename]}
            joImageBrush:SetString[color,"#ffffffff"]

        if ${joImage.Has[colorKey]}
            joImageBrush:SetString[imageFileTransparencyKey,"${joImage.Get[colorKey]~}"]

        return joImageBrush
    }

    member:jsonvalueref GetBackgroundBrush(string backgroundColor, string useImage, string useImageOverride, string colorMask="#ffffffff")
    {
;        echo "\ayGetBackgroundBrush\ax ${backgroundColor~} ${useImage~} ${useImageOverride~}"
        variable jsonvalue joBrush="{}"

        if ${useImageOverride.NotNULLOrEmpty}
        {
            joBrush:SetString[color,"#${LGUI2.Skin[ISBoxer 2].Brush["${useImageOverride~}"].Color.Hex}"]
            joBrush:SetString[imageBrush,"${useImageOverride~}"]
        }
        elseif ${useImage.NotNULLOrEmpty}
        {
            joBrush:SetString[color,"#${LGUI2.Skin[ISBoxer 2].Brush["${useImage~}"].Color.Hex}"]
            joBrush:SetString[imageBrush,"${useImage~}"]
        }
        elseif ${backgroundColor.NotNULLOrEmpty}
            joBrush:SetString[color,"${backgroundColor~}"]

        return joBrush
    }

    member:jsonvalueref GenerateView()
    {
;        echo "isb2_clickbarButton:GenerateView ${Data~}"
        ;isb2_clickbar:GenerateButtonView lgui2itemviewgeneratorargs 
        ; {"name":"Button 2","clicks":[{"button":1,"inputMapping":{"type":"action","action":{"type":"keystroke","keyCombo":"2"}}}]}

        variable jsonvalue joButton
        joButton:SetValue["$$>
        {
            "jsonTemplate":"isb2.clickbarButton",
            "width":${ClickBar.GetButtonWidth},
            "height":${ClickBar.GetButtonHeight},
            "_numButton":${NumButton},
            "tooltip":${Data.Get[tooltip].AsJSON}
            "content":{
                "type":"panel",
                "horizontalAlignment":"stretch",
                "verticalAlignment":"stretch",
                "children":[]
            },
            "styles":{
                "onVisualPress": {
                },
                "onVisualRelease": {
                },
                "gotMouseOver": {
                },
                "lostMouseOver": {
                }
            }
        }
        <$$"]

;        variable jsonvalue joImagebox        
        variable jsonvalue joTextblock

        variable jsonvalueref joImage
/*
        joImagebox:SetValue["$$>
        {
            "type":"imagebox",
            "name":"clickbarButton.imagebox",
            "horizontalAlignment":"center",
            "verticalAlignment":"center",
            "scaleToFit":true
        }
        <$$"]
/**/

        joTextblock:SetValue["$$>
        {
            "type":"textblock",
            "name":"clickbarButton.buttontext",
            "horizontalAlignment":"center",
            "verticalAlignment":"center",
            "strata":0.6
        }
        <$$"]

        if ${Data.Has[text]}
            joTextblock:SetString[text,"${Data.Get[text]~}"]
        else
            joTextblock:SetString[visibility,collapsed]

        if ${Data.Has[font]}
        {
            joButton:Set[font,"${Data.Get[font]~}"]
            if ${joButton.Has[font,color]}
                joButton:SetString[color,"${joButton.Get[font,color]~}"]
        }

        if ${Data.Has[backgroundColor]}
            joButton:Set["backgroundBrush","{\"color\":\"${Data.Get[backgroundColor]~}\"}"]

        variable string backgroundColor
        variable string useImage
        variable string useImageHover
        variable string useImagePressed

        if ${Data.Has[backgroundColor]}
            backgroundColor:Set["${Data.Get[backgroundColor]~}"]

        if ${Data.Has[image]}
            useImage:Set["${Data.Get[image,sheet]~}.${Data.Get[image,name]~}"]
        if ${Data.Has[imageHover]}
            useImageHover:Set["${Data.Get[imageHover,sheet]~}.${Data.Get[imageHover,name]~}"]
        if ${Data.Has[imagePressed]}
            useImagePressed:Set["${Data.Get[imagePressed,sheet]~}.${Data.Get[imagePressed,name]~}"]


        variable jsonvalueref joRef
        joRef:SetReference["This.GetBackgroundBrush[\"${backgroundColor~}\",\"${useImage~}\"]"]
        if ${joRef.Reference(exists)}
        {            
            joButton.Get[styles,lostMouseOver]:SetByRef[backgroundBrush,joRef]
            joButton.Get[styles,onVisualRelease]:SetByRef[backgroundBrush,joRef]
            joButton:SetByRef[backgroundBrush,joRef]
        }

        joRef:SetReference["This.GetBackgroundBrush[\"${backgroundColor~}\",\"${useImage~}\",\"${useImageHover~}\"]"]
        if ${joRef.Reference(exists)}
            joButton.Get[styles,gotMouseOver]:SetByRef[backgroundBrush,joRef]

        joRef:SetReference["This.GetBackgroundBrush[\"${backgroundColor~}\",\"${useImage~}\",\"${useImagePressed~}\"]"]
        if ${joRef.Reference(exists)}
            joButton.Get[styles,onVisualPress]:SetByRef[backgroundBrush,joRef]

/*
      "styles": {
        "onVisualPress": {
          "backgroundBrush": {
            "imageBrush":"ImagePressed",
            "color":"#ffffffff"
          }          
        },
        "onVisualRelease": {
          "backgroundBrush": {
            "imageBrush":"Image",
            "color":"#ffffffff"
          }          
        },
        "gotMouseOver": {
          "backgroundBrush": {
            "imageBrush":"ImageHover",
            "color":"#ffffffff"
          }          
        },
        "lostMouseOver": {
          "backgroundBrush": {
            "imageBrush":"Image",
            "color":"#ffffffff"
          }          
        }
      }
*/


;        joButton.Get[content,children]:AddByRef[joImagebox]
        joButton.Get[content,children]:AddByRef[joTextblock]

;        echo "\ayfinal\ax ${joButton.AsJSON~}"
        return joButton
    }


    member:bool ClickMatches(jsonvalueref joClick, jsonvalueref joMatch)
    {
;        echo "\ayClickMatches\ax ${joClick~} ${joMatch~}"
        if ${joClick.GetInteger[button]}!=${joMatch.GetInteger[controlID]}
            return FALSE

        if ${joClick.Has[modifiers,ctrl]}
        {
            if ${joClick.GetBool[modifiers,ctrl]}
            {
                if !${joMatch.GetBool[lCtrl]} && !${joMatch.GetBool[rCtrl]}
                    return FALSE
            }
            else
            {
                if ${joMatch.GetBool[lCtrl]} || ${joMatch.GetBool[rCtrl]}
                    return FALSE
            }
        }

        if ${joClick.Has[modifiers,alt]}
        {
            if ${joClick.GetBool[modifiers,alt]}
            {
                if !${joMatch.GetBool[lAlt]} && !${joMatch.GetBool[rAlt]}
                    return FALSE
            }
            else
            {
                if ${joMatch.GetBool[lAlt]} || ${joMatch.GetBool[rAlt]}
                    return FALSE
            }
        }

        if ${joClick.Has[modifiers,shift]}
        {
            if ${joClick.GetBool[modifiers,shift]}
            {
                if !${joMatch.GetBool[lShift]} && !${joMatch.GetBool[rShift]}
                    return FALSE
            }
            else
            {
                if ${joMatch.GetBool[lShift]} || ${joMatch.GetBool[rShift]}
                    return FALSE
            }
        }

;        echo "ClickMatches \agTRUE\ax"
        return TRUE
    }

    member:jsonvalueref GetClick(jsonvalueref jaClicks, jsonvalueref joMatch)
    {
;        echo GetClick ${jaClicks~} ${joMatch~}

        variable uint i
        for (i:Set[1] ; ${i} <= ${jaClicks.Used} ; i:Inc )
        {
            if ${This.ClickMatches["jaClicks.Get[${i}]",joMatch]}
                return "jaClicks.Get[${i}]"
        }

        return NULL
    }

    method OnButtonPress(jsonvalueref joData)
    {
;        echo onButtonPress ${Data~} ${joData~}
        variable jsonvalueref joClick
        joClick:SetReference["This.GetClick[\"Data.Get[clicks]\",joData]"]

        if !${joClick.Reference(exists)}
            return

        ActiveClicks:Set[${joData.GetInteger[controlID]},"${joClick~}"]

        ISB2:ExecuteInputMapping["joClick.Get[inputMapping]",1]
    }

    method OnButtonRelease(jsonvalueref joData)
    {
;        echo onButtonRelease ${Data~} ${joData~}
        variable uint mouseButton=${joData.GetInteger[controlID]}
        variable jsonvalueref joClick
        joClick:SetReference["ActiveClicks[${mouseButton}]"]

        if !${joClick.Reference.Type.Equal[object]}
            return

        ActiveClicks:Set[${mouseButton},NULL]
        ISB2:ExecuteInputMapping["joClick.Get[inputMapping]",0]
    }

    
    method GotMouseOver()
    {
        ; get input mapping
        if !${Data.Has[mouseOver]}
            return

        ISB2:ExecuteInputMapping["Data.Get[mouseOver]",1]
    }

    method LostMouseOver()
    {
        ; get input mapping
        if !${Data.Has[mouseOver]}
            return

        ISB2:ExecuteInputMapping["Data.Get[mouseOver]",0]
    }

    method OnLoad(weakref _element)
    {
;        echo "isb2_clickbarButton:OnLoad ${_element.Reference(type)}"

        Element:Set[${_element.ID}]
    }
}

objectdef isb2_clickbar
{
    variable string Name
    
    variable jsonvalueref Data
    variable jsonvalueref Template
    variable jsonvalueref ButtonLayout

    variable lgui2elementref Window

    variable index:isb2_clickbarButton Buttons

    method Initialize(jsonvalueref jo)
    {
        This:FromJSON[jo]
    }

    method FromJSON(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return

        if ${jo.Has[name]}
            Name:Set["${jo.Get[name]~}"]                            

        Data:SetReference[jo]

        if ${Data.GetType[template].Equal[string]}
        {
            ; get click bar template from profile
            Template:SetReference["ISB2.ClickBarTemplates.Get[\"${Data.Get[template]~}\"]"]
;            echo "\auisb2_clickbar.Template\ax ${Template~}"
        }
        else
            Template:SetReference["Data.Get[template]"]

        if ${Data.GetType[buttonLayout].Equal[string]}
        {
            ; get click bar button layout from profile
            ButtonLayout:SetReference["ISB2.ClickBarButtonLayouts.Get[\"${Data.Get[buttonLayout]~}\"]"]
;            echo "\auisb2_clickbar.ButtonLayout\ax ${ButtonLayout~}"
        }
        else
            ButtonLayout:SetReference["Data.Get[buttonLayout]"]

        if ${ButtonLayout.Get[buttons].Used}
        {
            ButtonLayout.Get[buttons]:ForEach["ForEach.Value:SetInteger[numButton,\${ForEach.Key}]"]
            Buttons:Resize[${ButtonLayout.Get[buttons].Used}]
            ButtonLayout.Get[buttons]:ForEach["Buttons:Set[\${ForEach.Key},This,\${ForEach.Key},ForEach.Value]"]
        }

        if ${Data.GetBool[enable]}
        {
            This:CreateWindow
        }
    }

    method Shutdown()
    {
        Window:Destroy
    }

    method Disable()
    {
        Window:Destroy
    }

    method Enable()
    {
        if ${Window.Reference(exists)}
            return

        This:CreateWindow
    }

    method Toggle()
    {
        if ${Window.Reference(exists)}
            This:Disable
        else
            This:CreateWindow
    }

    method OnButtonLoaded()
    {
         variable uint numButton=${Context.Source.Metadata.GetInteger[numButton]}
;        echo isb2_clickbar:OnButtonLoaded numButton=${numButton}

        Buttons.Get[${numButton}]:OnLoad[Context.Source]
    }

    method GotMouseFocus()
    {
;        echo isb2_clickbar:GotMouseFocus ${Context(type)} ${Context.Source} numButton=${Context.Source.Metadata.GetInteger[numButton]}
    }

    method LostMouseFocus()
    {
;        echo isb2_clickbar:LostMouseFocus ${Context(type)} ${Context.Source} numButton=${Context.Source.Metadata.GetInteger[numButton]}
    }

    method GotMouseOver()
    {
        variable uint numButton=${Context.Source.Metadata.GetInteger[numButton]}
;        echo isb2_clickbar:GotMouseOver numButton=${numButton}

        Buttons.Get[${numButton}]:GotMouseOver
    }

    method LostMouseOver()
    {
        variable uint numButton=${Context.Source.Metadata.GetInteger[numButton]}
;        echo isb2_clickbar:LostMouseOver numButton=${numButton}
        Buttons.Get[${numButton}]:LostMouseOver
    }


    method OnMouseButtonMove()
    {
        variable uint numButton=${Context.Source.Metadata.GetInteger[numButton]}
        variable bool pressed=${Context.Args.Get[position]}
        echo isb2_clickbar:OnMouseButtonMove numButton=${numButton} ${Context(type)} ${Context.Args} 

        if ${pressed}
            Buttons.Get[${numButton}]:OnButtonPress[Context.Args]
        else
            Buttons.Get[${numButton}]:OnButtonRelease[Context.Args]
    }

    member:uint GetButtonHeight()
    {
        return ${Template.GetInteger[-default,32,buttonHeight]}
    }

    member:uint GetButtonWidth()
    {
        return ${Template.GetInteger[-default,32,buttonWidth]}
    }

    method GenerateButtonView()
    {
;        echo isb2_clickbar:GenerateButtonView ${Context(type)} ${Context.Args}
        ;isb2_clickbar:GenerateButtonView lgui2itemviewgeneratorargs 
        ; {"name":"Button 2","clicks":[{"button":1,"inputMapping":{"type":"action","action":{"type":"keystroke","keyCombo":"2"}}}]}

        variable int numButton
        numButton:Set[${Context.Args.GetInteger[numButton]}]

        variable jsonvalueref joButton
        joButton:SetReference["Buttons.Get[${numButton}].GenerateView"]

        if !${joButton.Reference(exists)}
        {
            Context:SetError["Buttons.Get[${numButton}].GenerateView ??"]
            return FALSE
        }

        Context:SetView["${joButton~}"]
    }

    method CreateWindow()
    {
        echo isb2_clickbar:CreateWindow
        if ${Window.Reference(exists)}
            return

        variable string useName="isb2.cb.${Name~}"        

        variable jsonvalue joWindow
        joWindow:SetValue["$$>
        {
            "type":"window",
            "jsonTemplate":"isb2.clickbar",
            "name":${useName.AsJSON~},
            "title":${Name.AsJSON~},
            "x":${Data.GetInteger[-default,0,x]},
            "y":${Data.GetInteger[-default,0,y]},
        }
        <$$"]

        LGUI2:PushSkin["ISBoxer 2"]
        Window:Set["${LGUI2.LoadReference[joWindow,This].ID}"]
        LGUI2:PopSkin["ISBoxer 2"]
    }

    

}

objectdef isb2_triggerchain
{
    variable string Name
    variable jsonvalue Handlers="{}"

    method Initialize(string name)
    {
        Name:Set["${name~}"]
    }

    member:jsonvalueref AsJSON()
    {
        variable jsonvalue jo="{}"
        jo:SetString[name,"${Name~}"]
        jo:SetByRef[handlers,Handlers]
        return jo
    }

    method AddHandler(jsonvalueref joTrigger)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        Handlers:SetByRef["${joTrigger.Get[name]~}",joTrigger]
        return TRUE
    }

    method RemoveHandler(jsonvalueref joTrigger)
    {
        Handlers:Erase["${joTrigger.Get[name]~}"]
    }

    method RemoveHandlerByName(string name)
    {
        Handlers:Erase["${name~}"]
    }

    method Execute(weakref obj, bool newState)
    {
        Handlers:ForEach["obj:ExecuteTrigger[ForEach.Value,${newState}]"]
    }
}

/* isb2_hotkeysheet: 
    
*/
objectdef isb2_hotkeysheet
{
    variable string Name
    variable bool Enabled

    variable jsonvalue Hotkeys="{}"

    method Initialize(jsonvalueref jo)
    {
        This:FromJSON[jo]
    }

    method Shutdown()
    {
        This:Disable
    }

    method FromJSON(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        if ${jo.Has[name]}
            Name:Set["${jo.Get[name]~}"]

        jo.Get[hotkeys]:ForEach["This:Add[ForEach.Value]"]

        if ${jo.GetBool[enable]}
        {
            This:Enable
        }
    }

    method Add(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE
        Hotkeys:SetByRef["${jo.Get[name]~}",jo]
    }

    method Enable()
    {
        Enabled:Set[1]

        variable jsonvalue joQuery="{}"
        joQuery:SetString[op,"!="]
        joQuery:SetBool[value,0]
        joQuery:SetString[eval,"Select.GetBool[enable]"]
        Hotkeys:ForEach["This:EnableHotkey[ForEach.Value]",joQuery]
    }

    method Disable()
    {
        Enabled:Set[0]
        Hotkeys:ForEach["This:DisableHotkey[ForEach.Value]"]
    }

    method Toggle()
    {
        if ${Enabled}
            This:Disable
        else
            This:Enable
    }

    method EnableHotkey(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        if !${jo.Has[name]}
            return

        ; install binding
        ISB2:InstallHotkey["${Name~}","${jo.Get[name]~}",jo]

        jo:SetBool["enabled",1]
    }

    method DisableHotkey(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        if !${jo.Has[name]}
            return
        
        ISB2:UninstallHotkey["${Name~}","${jo.Get[name]~}"]

        jo:SetBool["enabled",0]
    }
}

objectdef isb2_mappablesheet
{
    variable string Name

    variable jsonvalue Mappables="{}"

    variable bool Enabled
    
    variable string VirtualizeAs

    method Initialize(jsonvalueref jo)
    {
        Enabled:Set[1]
        This:FromJSON[jo]
    }

    method FromJSON(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        if ${jo.Has[name]}
            Name:Set["${jo.Get[name]~}"]

        if ${jo.Has[enable]}
            Enabled:Set[${jo.GetBool[enable]}]

        jo.Get[mappables]:ForEach["This:Add[ForEach.Value]"]
    }

    member:jsonvalueref AsJSON()
    {
        variable jsonvalue jo="{}"
        jo:SetString[name,"${Name~}"]
        if ${VirtualizeAs.NotNULLOrEmpty}
            jo:SetString[virtualizeAs,"${VirtualizeAs~}"]
        jo:SetByRef[mappables,Mappables]
        return jo
    }

    method Add(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        jo:SetString[sheet,"${Name~}"]
        Mappables:SetByRef["${jo.Get[name]~}",jo]
    }


    method Enable()
    {
        Enabled:Set[1]
    }

    method Disable()
    {
        Enabled:Set[0]
    }

    method Toggle()
    {
        if ${Enabled}
            This:Disable
        else
            This:Enable
    }    
}

objectdef isb2_gamemacrosheet
{
    variable string Name
    variable string Game

    variable jsonvalue Macros="{}"

    method Initialize(jsonvalueref jo)
    {
        This:FromJSON[jo]
    }

    method FromJSON(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        if ${jo.Has[name]}
            Name:Set["${jo.Get[name]~}"]

        if ${jo.Has[game]}
            Game:Set["${jo.Get[game]~}"]

        jo.Get[macros]:ForEach["This:Add[ForEach.Value]"]
    }

    member:jsonvalueref AsJSON()
    {
        variable jsonvalue jo="{}"
        jo:SetString[name,"${Name~}"]
        jo:SetString[game,"${Game~}"]
        jo:SetByRef[macros,Macros]
        return jo
    }

    method Add(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE
        Macros:SetByRef["${jo.Get[name]~}",jo]
    }
}

objectdef isb2_imagesheet
{
    variable string Name

    variable jsonvalue Images="{}"

    method Initialize(jsonvalueref jo)
    {
        This:FromJSON[jo]
    }

    method FromJSON(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        if ${jo.Has[name]}
            Name:Set["${jo.Get[name]~}"]

        jo.Get[images]:ForEach["This:Add[ForEach.Value]"]
    }

    member:jsonvalueref AsJSON()
    {
        variable jsonvalue jo="{}"
        jo:SetString[name,"${Name~}"]
        jo:SetByRef[images,Images]
        return jo
    }

    method Add(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE
        Images:SetByRef["${jo.Get[name]~}",jo]

        variable jsonvalue joImageBrush="{}"

        if ${jo.Has[filename]}
            joImageBrush:SetString[imageFile,"${jo.Get[filename]~}"]
        if ${jo.Has[colorMask]}
            joImageBrush:SetString[color,"${jo.Get[colorMask]~}"]
        elseif ${jo.Has[filename]}
            joImageBrush:SetString[color,"#ffffffff"]

        if ${jo.Has[colorKey]}
            joImageBrush:SetString[imageFileTransparencyKey,"${jo.Get[colorKey]~}"]

        LGUI2.Skin["ISBoxer 2"]:SetBrush["${Name~}.${jo.Get[name]~}",joImageBrush]
    }
}

objectdef isb2_regionsheet
{
    variable string Name
    variable bool Enabled

    variable jsonvalue Regions="{}"

    method Initialize(jsonvalueref jo)
    {
        This:FromJSON[jo]
    }

    method FromJSON(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        if ${jo.Has[name]}
            Name:Set["${jo.Get[name]~}"]

        jo.Get[regions]:ForEach["This:Add[ForEach.Value]"]


        if ${jo.GetBool[enable]}
        {
            This:Enable
        }
    }

    member:jsonvalueref AsJSON()
    {
        variable jsonvalue jo="{}"
        jo:SetString[name,"${Name~}"]
        jo:SetByRef[regions,Regions]
        return jo
    }

    method Add(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE
        Regions:SetByRef["${jo.Get[name]~}",jo]
    }
}

objectdef isb2_vfxsheet
{
    variable string Name
    variable bool Enabled

    variable jsonvalue Outputs="{}"
    variable jsonvalue Sources="{}"

    method Initialize(jsonvalueref jo)
    {
        This:FromJSON[jo]
    }

    method Shutdown()
    {
        This:Disable
    }

    method FromJSON(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        if ${jo.Has[name]}
            Name:Set["${jo.Get[name]~}"]

        jo.Get[outputs]:ForEach["This:AddOutput[ForEach.Value]"]
        jo.Get[sources]:ForEach["This:AddSource[ForEach.Value]"]

        if ${jo.GetBool[enable]}
        {
            This:Enable
        }
    }

    member:jsonvalueref AsJSON()
    {
        variable jsonvalue jo="{}"
        jo:SetString[name,"${Name~}"]
        jo:SetBool[enabled,${Enabled}]
        jo:SetByRef[outputs,Outputs]
        jo:SetByRef[sources,Sources]
        return jo
    }

    method AddOutput(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE
        Outputs:SetByRef["${jo.Get[name]~}",jo]
    }

    method AddSource(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE
        Sources:SetByRef["${jo.Get[name]~}",jo]
    }
    
    method Enable()
    {
        echo "\arisb2_vfxsheet:Enable\ax ${Name~}"
        Enabled:Set[1]
        Outputs:ForEach["This:EnableOutput[ForEach.Value]"]
        Sources:ForEach["This:EnableSource[ForEach.Value]"]
    }

    method Disable()
    {
        if !${Enabled}
            return
        echo "\arisb2_vfxsheet:Disable\ax ${Name~}"
        Enabled:Set[0]
        Outputs:ForEach["This:DisableOutput[ForEach.Value]"]
        Sources:ForEach["This:DisableSource[ForEach.Value]"]
    }

    method Toggle()
    {
        if ${Enabled}
            This:Disable
        else
            This:Enable
    }

    method EnableOutput(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        if !${jo.Has[name]}
            return

        ISB2:InstallVFXOutput["${Name~}","${jo.Get[name]~}",jo]

        jo:SetBool["enabled",1]
    }

    method DisableOutput(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        if !${jo.Has[name]}
            return
        
        ISB2:UninstallVFXOutput["${Name~}","${jo.Get[name]~}",jo]

        jo:SetBool["enabled",0]
    }

    method EnableSource(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        if !${jo.Has[name]}
            return

        ISB2:InstallVFXSource["${Name~}","${jo.Get[name]~}",jo]

        jo:SetBool["enabled",1]
    }

    method DisableSource(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        if !${jo.Has[name]}
            return
        
        ISB2:UninstallVFXSource["${Name~}","${jo.Get[name]~}",jo]

        jo:SetBool["enabled",0]
    }
}
