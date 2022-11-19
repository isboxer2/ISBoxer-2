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
    variable jsonvalueref TimerPools=[]

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
        if ${jo.Has[timerPools]}
            TimerPools:SetReference["jo.Get[timerPools]"]
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
        if ${TimerPools.Used}
            jo:SetByRef["timerPools","TimerPools"]
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

    ; propagation
    variable weakref Source
    variable anonevent OnPropagate

    method Initialize(weakref _clickBar, int _numButton, jsonvalueref jo)
    {
        ClickBar:SetReference[_clickBar]
        NumButton:Set[${_numButton}]
        Data:SetReference[jo]
        if !${Data.Reference(exists)}
            Data:SetReference["{}"]

        This:SortClicks
    }

    method Shutdown()
    {
        Element:Destroy
    }

    
    member:uint FindInsertPosition(jsonvalueref ja, jsonvalueref jo)
    {
        ; return 0 to add to the end
        if !${ja.Used}
            return 0

        variable uint numModifiers
        numModifiers:Set[${jo.Get[modifiers].Used}]

        ; no modifiers? always at the end.
        if !${numModifiers}
            return 0

        variable jsonvalue joQuery
        joQuery:SetValue["$$>
        {
            "eval":"Select.Get[modifiers].Used",
            "op":"<=",
            "value":${numModifiers}
        }
        <$$"]

        ; if the query finds no match ("modifiers" count <= numModifiers), then this returns 0
        ; and we add to the end of ActionTimers
        return ${ja.SelectKey[joQuery]}        
    }

    method SortedInsert(jsonvalueref ja, jsonvalueref jo)
    {
        variable uint pos=${This.FindInsertPosition[ja,jo]}

        if ${pos}
            ja:InsertByRef[${pos},jo]
        else
            ja:AddByRef[jo]
    }

    method SortClicks()
    {
        variable jsonvalueref jaClicks="Data.Get[clicks]"

        variable jsonvalue jaNew="[]"
        jaClicks:ForEach["This:SortedInsert[jaNew,ForEach.Value]"]

        Data:SetByRef[clicks,jaNew]
    }

    method Push()
    {
        OnPropagate:Execute
    }

    method Pull()
    {
        if !${Source.Reference(exists)}
            return
        
        This:ApplyChanges[Source.Data]
    }

    method PullFrom(weakref newSource)
    {
;        echo "\ayPullFrom\ax ${newSource.Data~}"
        if ${Source.Reference(exists)}
            Source.OnPropagate:DetachAtom[This:OnSourcePush]

        Source:SetReference[newSource]
        if ${Source.Reference(exists)}
        {
            This:ApplyChanges[Source.Data]
            Source.OnPropagate:AttachAtom[This:OnSourcePush]
        }
    }

    method OnSourcePush()
    {
        This:ApplyChanges[Source.Data]
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

    method ApplyChanges(jsonvalueref jo, bool shouldPush=1)
    {
;        echo "\ayisb2_clickbarButton:ApplyChanges\ax ${jo~}"
        jo:SetReference[jo.Duplicate]
        jo:Erase[numButton]
        jo:Erase[pullFrom]
        Data:Merge[jo]

 ;       echo "\arApplyChanges\ax post-merge: ${Data~}"

        Element:ApplyStyleJSON[This.GenerateView]

        if ${shouldPush}
            This:Push
    }

    member:jsonvalueref GenerateView()
    {
;        echo "\ayisb2_clickbarButton:GenerateView\ax ${Data~}"
        ;isb2_clickbar:GenerateButtonView lgui2itemviewgeneratorargs 
        ; {"name":"Button 2","clicks":[{"button":1,"inputMapping":{"type":"action","action":{"type":"keystroke","keyCombo":"2"}}}]}

        variable jsonvalueref Template="ClickBar.Template"

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

        variable jsonvalueref joFont
        if ${Template.Has[font]}
            joFont:SetReference["Template.Get[font]"]
        else
            joFont:SetReference["{}"]

        if ${Data.Has[font]}
        {
            joFont:Merge["Data.Get[font]"]

            if ${joFont.Has[font,color]}
                joButton:SetString[color,"${joButton.Get[font,color]~}"]
            
            joButton:SetByRef[font,joFont]
        }

        if ${Data.Has[backgroundColor]}
            joButton:Set["backgroundBrush","{\"color\":\"${Data.Get[backgroundColor]~}\"}"]
        elseif ${Template.Has[backgroundColor]}
            joButton:Set["backgroundBrush","{\"color\":\"${Template.Get[backgroundColor]~}\"}"]

        variable string backgroundColor
        variable string useImage
        variable string useImageHover
        variable string useImagePressed

        if ${Data.Has[backgroundColor]}
            backgroundColor:Set["${Data.Get[backgroundColor]~}"]
        elseif ${Template.Has[backgroundColor]}
            backgroundColor:Set["${Template.Get[backgroundColor]~}"]

        if ${Data.Has[image]}
            useImage:Set["${Data.Get[image,sheet]~}.${Data.Get[image,name]~}"]
        elseif ${Template.Has[image]}
            useImage:Set["${Template.Get[image,sheet]~}.${Template.Get[image,name]~}"]

        if ${Data.Has[imageHover]}
            useImageHover:Set["${Data.Get[imageHover,sheet]~}.${Data.Get[imageHover,name]~}"]
        elseif ${Template.Has[imageHover]}
            useImageHover:Set["${Template.Get[imageHover,sheet]~}.${Template.Get[imageHover,name]~}"]

        if ${Data.Has[imagePressed]}
            useImagePressed:Set["${Data.Get[imagePressed,sheet]~}.${Data.Get[imagePressed,name]~}"]
        elseif ${Template.Has[imagePressed]}
            useImagePressed:Set["${Template.Get[imagePressed,sheet]~}.${Template.Get[imagePressed,name]~}"]


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

        if ${Data.Has[buttonMargin]}
            joButton:Set[margin,"[${Data.GetNumber[buttonMargin,1].Div[2]},${Data.GetNumber[buttonMargin,2].Div[2]}]"]
        elseif ${Template.Has[buttonMargin]}
            joButton:Set[margin,"[${Template.GetNumber[buttonMargin,1].Div[2]},${Template.GetNumber[buttonMargin,2].Div[2]}]"]


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

objectdef isb2_clickbarButtonLayout
{
    variable string Name

;    variable jsonvalueref Data
    variable index:isb2_clickbarButton Buttons

    method Initialize(jsonvalueref jo)
    {
        This:FromJSON[jo]
    }

    method FromJSON(jsonvalueref jo)
    {
        echo "\apisb2_clickbarButtonLayout\ax:FromJSON ${jo~}"
        if !${jo.Type.Equal[object]}
            return

        Data:SetReference[jo]

        if ${jo.Has[name]}
            Name:Set["${jo.Get[name]~}"]

        if ${jo.Get[buttons].Used}
        {
            jo.Get[buttons]:ForEach["ForEach.Value:SetInteger[numButton,\${ForEach.Key}]"]
            Buttons:Resize[${jo.Get[buttons].Used}]
            jo.Get[buttons]:ForEach["Buttons:Set[\${ForEach.Key},This,\${ForEach.Key},ForEach.Value]"]
        }            
    }

    method AddButtonToClickBar(weakref clickBar, uint numButton, weakref _Button)
    {
;       echo "\ayAddButtonToClickBar\ax ${numButton} ${_Button.Data~}"
        clickBar.Buttons:Set[${numButton},clickBar,${numButton}]
        clickBar.Buttons.Get[${numButton}]:PullFrom[_Button]
    }

    method AddButtonsToClickBar(weakref clickBar)
    {
        Buttons:ForEach["This:AddButtonToClickBar[clickBar,\${ForEach.Key},ForEach.Value]"]
    }

    method ApplyChanges(int numButton, jsonvalueref joChanges)
    {
;        echo "\apisb2_clickbarButtonLayout\ax:ApplyChanges[${numButton}] ${joChanges~}"

        if ${numButton}
        {
            Buttons.Get[${numButton}]:ApplyChanges[joChanges]
        }        
    }
}

objectdef isb2_clickbar
{
    variable string Name
    variable int X
    variable int Y
    
;    variable jsonvalueref Data
    variable jsonvalueref Template
;    variable jsonvalueref ButtonLayout

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

        if ${jo.Has[x]}
            X:Set["${jo.GetInteger[x]}"]
        if ${jo.Has[y]}
            Y:Set["${jo.GetInteger[y]}"]

;        Data:SetReference[jo]

        if ${jo.Has[template]}
        {
            if ${jo.GetType[template].Equal[string]}
            {
                ; get click bar template from profile
                Template:SetReference["ISB2.ClickBarTemplates.Get[\"${jo.Get[template]~}\"]"]
    ;            echo "\auisb2_clickbar.Template\ax ${Template~}"
            }
            else
                Template:SetReference["jo.Get[template]"]
        }
        variable weakref ButtonLayout
        variable jsonvalueref joButtonLayout

        if ${jo.GetType[buttonLayout].Equal[string]}
        {
            ;echo "\apUsing Named Button Layout\ax"
            ; get click bar button layout from profile
            ButtonLayout:SetReference["ISB2.ClickBarButtonLayouts.Get[\"${jo.Get[buttonLayout]~}\"]"]
            if !${ButtonLayout.Reference(exists)}
            {
                echo "\arButtonLayout not found\ax ${jo.Get[buttonLayout]~}"
            }
            if ${ButtonLayout.Buttons.Used}
            {
;                joButtonLayout.Get[buttons]:ForEach["ForEach.Value:SetInteger[numButton,\${ForEach.Key}]"]
                Buttons:Resize[${ButtonLayout.Buttons.Used}]
                
               ButtonLayout:AddButtonsToClickBar[This]
            }            
        }
        else
        {
            ;echo "\apUsing Nested Button Layout\ax"
            joButtonLayout:SetReference["jo.Get[buttonLayout]"]
            if ${joButtonLayout.Get[buttons].Used}
            {
                joButtonLayout.Get[buttons]:ForEach["ForEach.Value:SetInteger[numButton,\${ForEach.Key}]"]
                Buttons:Resize[${joButtonLayout.Get[buttons].Used}]
                joButtonLayout.Get[buttons]:ForEach["Buttons:Set[\${ForEach.Key},This,\${ForEach.Key},ForEach.Value]"]
            }
        }

        if ${jo.GetBool[enable]}
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
        if ${Window.Element(exists)}
            return

        This:CreateWindow
    }

    method Toggle()
    {
        if ${Window.Element(exists)}
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

    member:jsonvalueref GetButtons()
    {
        variable jsonvalue ja="[]"

        Buttons:ForEach["ja:Add[{\"numButton\":\${ForEach.Key}}]"]

        return ja
    }

    method ApplyChanges(int numButton, jsonvalueref joChanges)
    {
;        echo "\apisb2_clickbar\ax:ApplyChanges[${numButton}] ${joChanges~}"

        if ${numButton}
        {
            Buttons.Get[${numButton}]:ApplyChanges[joChanges]
        }
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
        if ${Window.Element(exists)}
            return

        variable string useName="isb2.cb.${Name~}"        

        variable jsonvalue joWindow
        joWindow:SetValue["$$>
        {
            "type":"window",
            "jsonTemplate":"isb2.clickbar",
            "name":${useName.AsJSON~},
            "title":${Name.AsJSON~},
            "x":${X},
            "y":${Y}
        }
        <$$"]

        if ${Template.Has[backgroundColor]}
            joWindow:Set[backgroundBrush,"{\"color\":\"${Template.Get[backgroundColor]~}\"}"]

        if ${Template.Has[borderColor]}
            joWindow:Set[borderBrush,"{\"color\":\"${Template.Get[borderColor]~}\"}"]

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

    variable bool Enable
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

        if ${jo.GetBool[-default,true,enable]}
            Enable:Set[1]
    }

    method Add(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        jo:SetString[sheet,"${Name~}"]
        Hotkeys:SetByRef["${jo.Get[name]~}",jo]
    }

    method Activate()
    {
        if !${Enable}
            return FALSE

        This:Enable
        return TRUE
    }

    method Enable()
    {
        if ${Enabled}
            return TRUE
        
        if !${ISB2.AllowHotkeySheet["${Name~}"]}
            return FALSE

        Enabled:Set[1]

        variable jsonvalue joQuery="{}"
        joQuery:SetString[op,"!="]
        joQuery:SetBool[value,0]
        joQuery:SetString[eval,"Select.GetBool[enable]"]
        Hotkeys:ForEach["This:EnableHotkey[ForEach.Value]",joQuery]

        return TRUE
    }

    method Disable()
    {
        if !${Enabled}
            return TRUE
        Enabled:Set[0]
        Hotkeys:ForEach["This:DisableHotkey[ForEach.Value]"]

        return TRUE
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

    variable bool Enable
    variable bool Enabled

    variable bool Hold
    variable string Mode="OnRelease"
    
    variable string VirtualizeAs

    method Initialize(jsonvalueref jo)
    {
;        Enabled:Set[1]
        This:FromJSON[jo]
    }

    method FromJSON(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        if ${jo.Has[name]}
            Name:Set["${jo.Get[name]~}"]

        if ${jo.GetBool[-default,true,enable]}
            Enable:Set[1]

        if ${jo.Has[hold]}
            Hold:Set[${jo.GetBool[hold]}]

        if ${jo.Has[mode]}
            Mode:Set["${jo.Get[mode]~}"]

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

    method Activate()
    {
        if !${Enable}
        {
;            echo "isb2_mappablesheet[${Name~}]:Activate: enable=false"
            return FALSE
        }

        This:Enable
        return TRUE
    }

    method Enable()
    {
        if ${Enabled}
            return TRUE
        if !${ISB2.AllowMappableSheet["${Name~}"]}
            return FALSE

        Enabled:Set[1]
        return TRUE
    }

    method Disable()
    {
        Enabled:Set[0]
        return TRUE
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
    variable string GameName

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
            GameName:Set["${jo.Get[game]~}"]

        jo.Get[macros]:ForEach["This:Add[ForEach.Value]"]
    }

    member:jsonvalueref AsJSON()
    {
        variable jsonvalue jo="{}"
        jo:SetString[name,"${Name~}"]
        jo:SetString[game,"${GameName~}"]
        jo:SetByRef[macros,Macros]
        return jo
    }

    method Add(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE
        Macros:SetByRef["${jo.Get[displayName]~}",jo]
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
        echo "\arisb2_vfxsheet:Disable\ax ${Name~} ${Outputs~} ${Sources~}"
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

        This:InstallVFXOutput["${Name~}","${jo.Get[name]~}",jo]

        jo:SetBool["enabled",1]
    }

    method DisableOutput(jsonvalueref jo)
    {
        echo "\arvfxsheet:DisableOutput ${jo~}"
        if !${jo.Reference(exists)}
            return

        if !${jo.Has[name]}
            return
        
        This:UninstallVFXOutput["${Name~}","${jo.Get[name]~}",jo]

        jo:SetBool["enabled",0]
    }

    method EnableSource(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        if !${jo.Has[name]}
            return

        This:InstallVFXSource["${Name~}","${jo.Get[name]~}",jo]

        jo:SetBool["enabled",1]
    }

    method DisableSource(jsonvalueref jo)
    {
        echo "\arvfxsheet:DisableSource ${jo~}"
        if !${jo.Reference(exists)}
            return
        if !${jo.Has[name]}
            return
        
        This:UninstallVFXSource["${Name~}","${jo.Get[name]~}",jo]

        jo:SetBool["enabled",0]
    }


    method InstallVFXOutput(string sheet, string name, jsonvalueref joVFX)
    {
        echo "\agInstallVFXOutput\ax ${sheet~} ${name~} ${joVFX~}"
        variable int x=${joVFX.GetInteger[x]}
        variable int y=${joVFX.GetInteger[y]}
        variable int w=${joVFX.GetInteger[width]}
        variable int h=${joVFX.GetInteger[height]}

        variable jsonvalueref joAdjust="LGUI2.Skin[ISBoxer 2].Template[window.adjustments]"

        ; adjust for extra window size beyond the VFX output element
        x:Inc["${joAdjust.GetInteger[x]}"]
        y:Inc["${joAdjust.GetInteger[y]}"]
        w:Inc["${joAdjust.GetInteger[width]}"]
        h:Inc["${joAdjust.GetInteger[height]}"]

        variable jsonvalue joVideofeed
        joVideofeed:SetValue["$$>
        {
            "name":"isb2.vfx.${sheet~}.${name~}",
            "type":"videofeed",
            "horizontalAlignment":"stretch",
            "verticalAlignment":"stretch",
            "feedName":${joVFX.Get[feedName]~.AsJSON~},
            "sendMouse":${joVFX.GetBool[sendMouse]},
            "sendKeyboard":${joVFX.GetBool[sendKeyboard]},
            "useLocalBindings":true
        }
        <$$"]

        variable jsonvalue joView
        joView:SetValue["$$>
        {
            "name":"isb2.vfxWindow.${sheet~}.${name~}",
            "type":"window",
            "jsonTemplate":"isb2.vfx",
            "x":${x},
            "y":${y},
            "width":${w},
            "height":${h},
            "title":"VFX Output: ${joVFX.Get[feedName]~}"
        }
        <$$"]


        joView:SetByRef[content,joVideofeed]

;        echo "\ayfinal\ax ${joView~}"

        LGUI2:PushSkin["ISBoxer 2"]
        joVFX:SetInteger["elementID",${LGUI2.LoadReference[joView,joVFX].ID}]        
        LGUI2:PopSkin["ISBoxer 2"]
    }

    method UninstallVFXOutput(string sheet, string name, jsonvalueref joVFX)
    {
        echo "\agUninstallVFXOutput\ax ${sheet~} ${name~} ${joVFX~}"
        LGUI2.Element["isb2.vfxWindow.${sheet~}.${name~}"]:Destroy

        joVFX:SetInteger["elementID",0]
    }
    
    method InstallVFXSource(string sheet, string name, jsonvalueref joVFX)
    {
        echo "\agInstallVFXSource\ax ${sheet~} ${name~} ${joVFX~}"

        variable int x=${joVFX.GetInteger[x]}
        variable int y=${joVFX.GetInteger[y]}
        variable int w=${joVFX.GetInteger[width]}
        variable int h=${joVFX.GetInteger[height]}

        variable jsonvalueref joAdjust="LGUI2.Skin[ISBoxer 2].Template[window.adjustments]"

        ; adjust for extra window size beyond the VFX source element
        x:Inc["${joAdjust.GetInteger[x]}"]
        y:Inc["${joAdjust.GetInteger[y]}"]
        w:Inc["${joAdjust.GetInteger[width]}"]
        h:Inc["${joAdjust.GetInteger[height]}"]

        variable jsonvalue joVideofeed
        joVideofeed:SetValue["$$>
        {
            "name":"isb2.vfx.${sheet~}.${name~}",
            "type":"videofeedsource",
            "horizontalAlignment":"stretch",
            "verticalAlignment":"stretch",
            "feedName":${joVFX.Get[feedName]~.AsJSON~}
        }
        <$$"]

        variable jsonvalue joView
        joView:SetValue["$$>
        {
            "name":"isb2.vfxWindow.${sheet~}.${name~}",
            "type":"window",
            "jsonTemplate":"isb2.vfx",
            "x":${x},
            "y":${y},
            "width":${w},
            "height":${h},
            "title":"VFX Source: ${joVFX.Get[feedName]~}"
        }
        <$$"]
        joView:SetByRef[content,joVideofeed]

;        echo "\ayfinal\ax ${joView~}"
        LGUI2:PushSkin["ISBoxer 2"]
        joVFX:SetInteger["elementID",${LGUI2.LoadReference[joView,joVFX].ID}]        
        LGUI2:PopSkin["ISBoxer 2"]
    }   

    method UninstallVFXSource(string sheet, string name, jsonvalueref joVFX)
    {
        echo "\agUninstallVFXSource\ax ${sheet~} ${name~} ${joVFX~}"
        LGUI2.Element["isb2.vfxWindow.${sheet~}.${name~}"]:Destroy

        joVFX:SetInteger["elementID",0]
    }    
}

objectdef isb2_timerpool
{
    variable string Name
    variable string Description
    variable uint MaxTimers
    variable bool BackEndRemoval

    variable jsonvalue ActiveTimers="[]"
    variable bool Attached

    method Initialize(jsonvalueref jo)
    {
        This:FromJSON[jo]
    }

    method Shutdown()
    {
        This:Detach
    }

    method FromJSON(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        if ${jo.Has[name]}
            Name:Set["${jo.Get[name]~}"]
        if ${jo.Has[description]}
            Description:Set["${jo.Get[description]~}"]
        if ${jo.Has[backEndRemoval]}
            BackEndRemoval:Set[${jo.GetBool[backEndRemoval]}]
        
        MaxTimers:Set[${jo.GetInteger[-default,0,maxTimers]}]
    }

    member:jsonvalueref AsJSON()
    {
        variable jsonvalue jo="{}"
        jo:SetString[name,"${Name~}"]

        if ${Description.NotNULLOrEmpty}
            jo:SetString[description,"${Description~}"]

        if ${MaxTimers}
            jo:SetInteger[maxTimers,${maxTimers}]

        if ${BackEndRemoval}
            jo:SetBool[backEndRemoval,${BackEndRemoval}]

        return jo
    }    

    method Attach()
    {
        if ${Attached}
            return

        Event[OnFrame]:AttachAtom[This:OnFrame]
        Attached:Set[1]
    }

    method Detach()
    {
        if !${Attached}
            return

        Event[OnFrame]:DetachAtom[This:OnFrame]
        Attached:Set[0]
    }

    member:uint FindInsertPosition(uint timestamp)
    {
        if !${ActionTimers.Used}
            return 0

        variable jsonvalue joQuery="$$>
        {
            "eval":"Select.GetInteger[time]",
            "op":">",
            "value":${timestamp}
        }
        <$$"

        ; we are guaranteed to have a timer in the pool
        ; if the query finds no match ("time" field > timestamp), then this returns 0
        ; and we add to the end of ActionTimers
        return ${ActionTimers.SelectKey[joQuery]}        
    }

    method RetimeAction(jsonvalueref joTimer, jsonvalueref joState, jsonvalueref joAction, bool activate)
    {
		; make room if we're supposed to...
		if ${ActiveTimers.Size}>=${MaxTimers} && ${MaxTimers}
		{
			if ${This.BackEndRemoval}
			{
				; ignore new timer, this one's on the back end. sorry!
				return TRUE
			}
		}

        ; calculate end time
        variable uint EndTime
        EndTime:Set[${Script.RunningTime}+(${joTimer.GetNumber[time]}*1000)]
        
        variable jsonvalue joActiveTimer
        joActiveTimer:SetValue["{}"]

        joActiveTimer:SetByRef[state,joState]
        joActiveTimer:SetByRef[action,joAction]
        joActiveTimer:SetByRef[timer,joTimer]
        joActiveTimer:SetBool[activate,${activate}]
        joActiveTimer:SetInteger[time,${EndTime}]
        if ${joTimer.GetBool[recur]}
            joActiveTimer:SetBool[recur,1]

        ; insert into position by time
        variable uint pos
        pos:Set[${This.FindInsertPosition[${timestamp}]}]
        if ${pos}
            ActiveTimers:InsertByRef[${pos},joActiveTimer]
        else
            ActiveTimers:AddByRef[joActiveTimer]

;        echo "action retimed ${joActiveTimer~}"
        This:Attach
        return TRUE
    }

    method OnFrame()
    {
        variable jsonvalueref joTimer
        variable uint EndTime
		variable uint pos

        while 1
		{
			if !${ActiveTimers.Used}
			{
                This:Detach
				return
			}

            joTimer:SetReference["ActiveTimers.Get[1]"]

			if ${joTimer.GetInteger[time]}>${Script.RunningTime}
			{
;				echo ${Name~}: ${joTimer.GetInteger[time]}>${Script.RunningTime}
				return
			}

            ActiveTimers:Erase[1]

;            echo "Executing timed action ${joTimer~}"
            ; execute the action as intended
            ISB2:ExecuteAction["joTimer.Get[state]","joTimer.Get[action]","${joTimer.GetBool[activate]}"]
    
			; check if auto-recurring
			if ${joTimer.GetBool[recur]}
			{
				; generate the new timestamp, using a consistent interval
                EndTime:Set[${joTimer.GetInteger[time]}+(${joTimer.GetNumber[timer,time]}*1000)]

				; insert again
				pos:Set[${This.FindInsertPosition[${EndTime}]}]

                if ${pos}
                    ActiveTimers:InsertByRef[${pos},joActiveTimer]
                else
                    ActiveTimers:AddByRef[joActiveTimer]
			}
		}		
    }
}
