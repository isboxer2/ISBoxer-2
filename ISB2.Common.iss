/* isb2_profile: 
    A set of definitions for ISBoxer 2. Like an ISBoxer Toolkit Profile, but preferably more generic.
*/
objectdef isb2_profile
{
    variable string LocalFilename
    variable uint Priority
    variable bool Native

    variable string Name
    variable string Description
    variable string Version
    variable string Source
    variable uint MinimumBuild
    variable jsonvalueref Metadata

    variable jsonvalueref Profiles=[]
    variable jsonvalueref Builders=[]
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
    variable jsonvalueref Variables=[]

    variable isb2_triggerchains TriggerChains

    method Initialize(jsonvalueref jo, uint priority, string localFilename, bool native)
    {
        This:FromJSON[jo]
        Priority:Set[${priority}]
        if ${localFilename.NotNULLOrEmpty}
            LocalFilename:Set["${localFilename~}"]
        Native:Set[${native}]

        TriggerChains:ApplyPendingTriggersAs[profile,"${Name~}"]
    }

    method FromJSON(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        if ${jo.Has[-notnull,name]}
            Name:Set["${jo.Get[name]~}"]
        if ${jo.Has[-notnull,description]}
            Description:Set["${jo.Get[description]~}"]
        if ${jo.Has[-notnull,source]}
            Source:Set["${jo.Get[source]~}"]
        if ${jo.Has[-notnull,isb2Version]}
            Version:Set["${jo.Get[isb2Version]~}"]
        if ${jo.Has[minimumBuild]}
            MinimumBuild:Set["${jo.GetInteger[minimumBuild]~}"]

        if ${jo.Has[metadata]}
            Metadata:SetReference["jo.Get[metadata]"]
        if ${jo.Has[builders]}
            Builders:SetReference["jo.Get[builders]"]
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
        if ${jo.Has[variables]}
            Variables:SetReference["jo.Get[variables]"]
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
            jo:SetString["description","${Description~}"]
        if ${Version.NotNULLOrEmpty}
            jo:SetString["isb2Version","${Version~}"]
        if ${Source.NotNULLOrEmpty}
            jo:SetString["source","${Source~}"]
        if ${MinimumBuild}
            jo:SetInteger["minimumBuild","${MinimumBuild}"]
        if ${Metadata.Type.Equal[object]}
            jo:SetByRef["metadata","Metadata"]
        if ${Builders.Used}
            jo:SetByRef["builders",Builders]
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
        if ${Variables.Used}
            jo:SetByRef["variables","Variables"]
        return jo
    }

    method Store()
    {
        if ${Native}
        {
            ; dont overwrite native profiles            
            return FALSE
        }
        if ${LocalFilename.NotNULLOrEmpty}
        {
            return ${This.AsJSON:WriteFile["${LocalFilename~}",multiline](exists)}
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
    variable collection:autocomplete AutoComplete

    variable uint LoadCount

    /*
    member:jsonvalueref ScanFolder(filepath filePath)
    {
        echo ${filePath.GetFiles[*.isb2.json]}
        return "filePath.GetFiles[*.isb2.json]"
    }
    /**/

    method BuildActionsAutoComplete()
    {
        variable jsonvalueref ja="LGUI2.Skin[default].Template[isb2.data].Get[defaultActionTypes]"

        variable jsonvalueref jo="{}"
        ja:ForEach["jo:SetByRef[\"\${ForEach.Value.Get[name]}\",ForEach.Value]"]

        if !${AutoComplete.Get[Actions](exists)}
        {
            AutoComplete:Set[Actions]
        }

        AutoComplete.Get[Actions]:SetDictionary[jo]
    }

    method BuildAutoComplete(string name, string fieldName="name")
    {
        variable jsonvalueref ja="This.LocateAll[\"${name~}\"]"

        variable jsonvalueref jo="{}"

        ja:ForEach["jo:SetByRef[\"\${ForEach.Value.Get[object,\"${fieldName~}\"]}\",ForEach.Value]"]

        if !${AutoComplete.Get["${name~}"](exists)}
        {
            AutoComplete:Set[${name~}]
        }

        AutoComplete.Get["${name~}"]:SetDictionary[jo]
    }

    member:autocomplete GetAutoComplete(string name, string fieldName="name")
    {
        if !${AutoComplete.Get["${name~}"](exists)}
        {
            This:BuildAutoComplete["${name~}","${fieldName~}"]
        }

        return "AutoComplete.Get[\"${name~}\"]"
    }

    member:jsonvalueref GetLoadedFilenames()
    {
        variable set Filenames
        Profiles:ForEach["Filenames:Add[\"\${ForEach.Value.LocalFilename~}\"]"]

        variable jsonvalue ja
        ja:SetValue["${Filenames.AsJSON~}"]
        return ja
    }

    method LoadFiles(jsonvalueref jaFilenames, bool native)
    {
        if !${jaFilenames.Type.Equal[array]}
            return FALSE

        jaFilenames:ForEach["This:LoadFile[\"\${ForEach.Value~}\",${native}]"]
        return TRUE
    }

    method LoadFolder(filepath filePath, bool native)
    {
        echo LoadFolder ${filePath~}
        filePath.GetFiles["*.isb2.json"]:ForEach["This:LoadFile[\"${filePath~}/\${ForEach.Value.Get[filename]}\",${native}]"]
    }

    ; Loads a profile from a given file
    method LoadFile(filepath fileName, bool native)
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
        Profiles:Set["${name~}","jo",${LoadCount},"${fileName~}",${native}]

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

    member:jsonvalueref SelectAll(string arrayName)
    {
        variable jsonvalue ja="[]"

        Profiles:ForEach["ForEach.Value.${arrayName~}:ForEach[\"ja:AddByRef[ForEach.Value]\"]"]

        return ja
    }

    member:jsonvalueref FindInArray(jsonvalueref ja, string name, string fieldName="name")
    {
        if !${ja.Type.Equal[array]}
            return NULL

        variable jsonvalue joQuery="{}"
        joQuery:SetString[eval,"Select.Get[\"${fieldName~}\"]"]
        joQuery:SetString[op,"=="]
        joQuery:SetString[value,"${name~}"]

        return "ja.SelectValue[joQuery]"
    }

    member:int FindKeyInArray(jsonvalueref ja, string name, string fieldName="name")
    {
        if !${ja.Type.Equal[array]}
            return NULL

        variable jsonvalue joQuery="{}"
        joQuery:SetString[eval,"Select.Get[\"${fieldName~}\"]"]
        joQuery:SetString[op,"=="]
        joQuery:SetString[value,"${name~}"]

        return "${ja.SelectKey[joQuery]}"
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

    member:jsonvalueref NewLocated(string profileName, jsonvalueref jo)
    {
        variable jsonvalue joLocated="{}"

        joLocated:SetString[profile,"${profileName~}"]
        joLocated:SetByRef[object,jo]
        return joLocated
    }

    method AddNewLocated(jsonvalueref ja, string profileName, jsonvalueref jo)
    {
        ja:AddByRef["This.NewLocated[\"${profileName~}\",jo]"]
    }

    member:jsonvalueref LocateAll(string arrayName,string objectName)
    {
        variable jsonvalue result="[]"

        variable jsonvalueref checkObject

        variable iterator Iterator
        Profiles:GetIterator[Iterator]

        if ${objectName.NotNULLOrEmpty}
        {
            if !${Iterator:First(exists)}
                return NULL

            do
            {            
                checkObject:SetReference["Iterator.Value.FindOne[\"${arrayName~}\",\"${objectName~}\"]"]
                if ${checkObject.Type.Equal[object]}
                {
                    result:AddByRef["This.NewLocated[\"${Iterator.Key~}\",checkObject]"]
                }
            }
            while ${Iterator:Next(exists)}
        }
        else
        {
            if !${Iterator:First(exists)}
                return NULL

            do
            {            
                checkObject:SetReference["Iterator.Value.${arrayName~}"]
                checkObject:ForEach["This:AddNewLocated[result,\"${Iterator.Key~}\",ForEach.Value]"]                                
            }
            while ${Iterator:Next(exists)}
        }

        return result        
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

objectdef isb2_clickbarButton
{
    variable weakref ClickBar
    variable int NumButton
    variable jsonvalueref Data
    variable lgui2elementref Element
    variable jsonvalue ActiveClicks="[null,null,null,null,null]"
    variable isb2_triggerchains TriggerChains

    ; propagation
    variable weakref Source
    variable anonevent OnPropagate
    variable anonevent OnAnimate
    variable anonevent OnStyle
    variable anonevent OnStopAnimation

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
        {
            Source.OnPropagate:DetachAtom[This:OnSourcePush]
            Source.OnAnimate:DetachAtom[This:OnSourceAnimate]
            Source.OnStyle:DetachAtom[This:OnSourceStyle]
            Source.OnStopAnimation:DetachAtom[This:OnSourceStopAnimation]
        }

        Source:SetReference[newSource]
        if ${Source.Reference(exists)}
        {
            This:ApplyChanges[Source.Data]
            Source.OnPropagate:AttachAtom[This:OnSourcePush]
            Source.OnAnimate:AttachAtom[This:OnSourceAnimate]
            Source.OnStyle:AttachAtom[This:OnSourceStyle]
            Source.OnStopAnimation:AttachAtom[This:OnSourceStopAnimation]
        }
    }

    method OnSourcePush()
    {
        This:ApplyChanges[Source.Data]
    }

    method OnSourceAnimate()
    {
        This:Animate[Context]
    }

    method OnSourceStopAnimation(string name)
    {
        This:StopAnimation["${name~}"]
    }

    method OnSourceStyle()
    {
        This:ApplyStyleJSON[Context]
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
            joBrush:SetString[color,"#${LGUI2.Skin[default].Brush["${useImageOverride~}"].Color.Hex}"]
            joBrush:SetString[imageBrush,"${useImageOverride~}"]
        }
        elseif ${useImage.NotNULLOrEmpty}
        {
            joBrush:SetString[color,"#${LGUI2.Skin[default].Brush["${useImage~}"].Color.Hex}"]
            joBrush:SetString[imageBrush,"${useImage~}"]
        }
        elseif ${backgroundColor.NotNULLOrEmpty}
            joBrush:SetString[color,"${backgroundColor~}"]

        return joBrush
    }

    method StopAnimation(string name)
    {
        Element.Animation["${name~}"]:Stop
        OnStopAnimation:Execute["${name~}"]
    }

    method Animate(jsonvalueref joAnimation)
    {
        Element:Animate[joAnimation]
        OnAnimate:ThisExecute[joAnimation]
    }

    method ApplyStyleJSON(jsonvalueref joStyle)
    {
        Element:ApplyStyleJSON[joStyle]
        OnStyle:ThisExecute[joStyle]
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

        if ${Element.IsMouseOver}
            Element:ApplyStyle["gotMouseOver"]
        if ${Element.Pressed}
            Element:ApplyStyle["onVisualPress"]

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

            if ${joFont.Has[color]}
                joTextblock:SetString[color,"${joFont.Get[color]~}"]
            
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

        echo "\aybutton final\ax ${joButton.AsJSON~}"
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
    variable isb2_triggerchains TriggerChains

    method Initialize(jsonvalueref jo)
    {
        This:FromJSON[jo]

        TriggerChains:ApplyPendingTriggersAs[buttonlayout,"${Name~}"]        
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

    method ApplyChanges(jsonvalueref joChanges, int numButton)
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
    variable isb2_triggerchains TriggerChains

    method Initialize(jsonvalueref jo)
    {
        This:FromJSON[jo]

        TriggerChains:ApplyPendingTriggersAs[clickbar,"${Name~}"]        
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
            This:Enable
        }
    }

    method Shutdown()
    {
        This:Disable
    }

    method Disable()
    {
        if !${Window.Element(exists)}
            return

        Window:Destroy
        TriggerChains:Fire["OnDisabled"]
    }

    method Enable()
    {
        if ${Window.Element(exists)}
            return

        This:CreateWindow
        TriggerChains:Fire["OnEnabled"]
    }

    method Toggle()
    {
        if ${Window.Element(exists)}
            This:Disable
        else
            This:Enable
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

    method ApplyChanges(jsonvalueref joChanges, int numButton)
    {
;        echo "\apisb2_clickbar\ax:ApplyChanges[${numButton}] ${joChanges~}"

        if ${numButton}
        {
            Buttons.Get[${numButton}]:ApplyChanges[joChanges]
        }
    }

    method StopAnimation(string name)
    {
        Window.Animation["${name~}"]:Stop
    }

    method Animate(jsonvalueref joAnimation)
    {
        Window:Animate[joAnimation]
    }

    method ApplyStyleJSON(jsonvalueref joStyle)
    {
        Window:ApplyStyleJSON[joStyle]
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

    member:jsonvalueref GetFrameSize()
    {
        if ${Template.Has[frameSize]}
            return "Template.Get[frameSize]"

        variable jsonvalue ja
        ja:SetValue["[0,0]"]

        variable uint cols
        variable uint rows
        variable uint buttonWidth
        variable uint buttonHeight

        buttonWidth:Set[${Template.GetInteger[-default,32,buttonWidth]}]
        buttonHeight:Set[${Template.GetInteger[-default,32,buttonHeight]}]
        marginWidth:Set[${Template.GetInteger[buttonMargin,1]}]
        marginHeight:Set[${Template.GetInteger[buttonMargin,2]}]
        cols:Set[${Template.GetInteger[-default,1,columns]}]
        rows:Set[${Template.GetInteger[-default,1,rows]}]

;        ja:Set[1,${Math.Calc[ (${buttonWidth}*${cols}) + (${marginWidth}*(${cols}-1))  ].Int}]
;        ja:Set[2,${Math.Calc[ (${buttonHeight}*${rows}) + (${marginHeight}*(${rows}-1))  ].Int}]

        ja:Set[1,${Math.Calc[ 2 + (( ${buttonWidth} + ${marginWidth} ) * ${cols}) ].Int}]
        ja:Set[2,${Math.Calc[ 2 + (( ${buttonHeight} + ${marginHeight} ) * ${rows}) ].Int}]

        return ja        
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
            "y":${Y},
            "content":{
                "opacity":${Template.GetNumber[-default,1.0,alpha]},
                "jsonTemplate":"isb2.clickbar.listbox",
                "content":{
                    "jsonTemplate":"isb2.clickbar.listbox.content",
                    "childSize":[${Template.GetInteger[-default,32,buttonWidth].Inc[${Template.GetInteger[buttonMargin,1]}]},${Template.GetInteger[-default,32,buttonHeight].Inc[${Template.GetInteger[buttonMargin,2]}]}]      
                }
            }
        }
        <$$"]

        variable jsonvalueref jaFrameSize
        jaFrameSize:SetReference["This.GetFrameSize"]
        joWindow.Get[content]:SetInteger[width,${jaFrameSize.GetInteger[1]}]
        joWindow.Get[content]:SetInteger[height,${jaFrameSize.GetInteger[2]}]

        if ${Template.Has[backgroundColor]}
            joWindow:Set[backgroundBrush,"{\"color\":\"${Template.Get[backgroundColor]~}\"}"]

        if ${Template.Has[borderColor]}
            joWindow:Set[borderBrush,"{\"color\":\"${Template.Get[borderColor]~}\"}"]

        echo "\ayCreateWindow final\ax ${joWindow~}"
        LGUI2:PushSkin["${ISB2.UseSkin~}"]
        Window:Set["${LGUI2.LoadReference[joWindow,This].ID}"]
        LGUI2:PopSkin["${ISB2.UseSkin~}"]

        ISB2:ApplyGUIModeTo["${Window.ID}"]
    }

    

}

objectdef isb2_triggerchain
{
    variable string Name
    variable jsonvalueref Triggers="{}"

    method Initialize(string name)
    {
        Name:Set["${name~}"]
    }

    member:jsonvalueref AsJSON()
    {
        variable jsonvalue jo="{}"
        jo:SetString[name,"${Name~}"]
        jo:SetByRef[triggers,Triggers]
        return jo
    }

    method AddTrigger(jsonvalueref joTrigger)
    {
        if !${joTrigger.Type.Equal[object]}
            return FALSE

        Triggers:SetByRef["${joTrigger.Get[name]~}",joTrigger]
        return TRUE
    }

    method RemoveTrigger(jsonvalueref joTrigger)
    {
        Triggers:Erase["${joTrigger.Get[name]~}"]
    }

    method RemoveTriggerByName(string name)
    {
        Triggers:Erase["${name~}"]
    }

    method Fire(bool newState)
    {
;        echo "\ayisb2_triggerchain:Fire\ax ${Name~} ${newState}"
        Triggers:ForEach["This:FireTrigger[ForEach.Value,${newState}]"]
        return TRUE
    }

    method FireTrigger(jsonvalueref joTrigger, bool newState)
    {
;        echo "\ayisb2_triggerchain:FireTrigger\ax ${joTrigger~} ${newState}"
        ISB2:ExecuteInputMapping["joTrigger.Get[inputMapping]",${newState}]
    }
}

objectdef isb2_triggerchains
{
    variable collection:isb2_triggerchain Chains

    member:jsonvalueref AsJSON()
    {
        variable jsonvalue jo="{}"    
        jo:Set[chains,"${Chains.AsJSON~}"]
        return jo
    }

    method ApplyPendingTriggersAs(string _type, string _name)
    {
        variable jsonvalue jo="{\"type\":\"${_type~}\"}"
        if ${_name.NotNULLOrEmpty}
            jo:SetString[name,"${_name~}"]

        return ${This:ApplyPendingTriggers[jo](exists)}
    }

    method ApplyPendingTriggers(jsonvalueref joObject)
    {
        ; grab pending triggers specified for this object
        variable weakref obj="ISB2.PendingTriggerChains.Get[\"${joObject~}\"]"

        if !${obj.Reference(exists)}
            return FALSE

        echo "\ayApplyPendingTriggers\ax ${joObject~} => ${obj.AsJSON~}"
        obj.Chains:ForEach["This:MoveChain[ForEach.Value]"]

        ISB2.PendingTriggerChains:Erase["${joObject~}"]
        return TRUE
    }

    method MoveChain(weakref other_chain)
    {
        variable weakref my_chain="This.Get[\"${other_chain.Name~}\",1]"

        echo "MoveChain other ${other_chain.AsJSON~}"
        my_chain.Triggers:SetReference[other_chain.Triggers]
        echo "MoveChain result ${my_chain.AsJSON~}"
    }

    member:weakref Get(string name, bool autoCreate)
    {
        if ${autoCreate}
        {
            if !${Chains.Get["${name~}"](exists)}
                Chains:Set["${name~}","${name~}"]
        }
        return "Chains.Get[\"${name~}\"]"
    }

    method Fire(string name)
    {
        Chains.Get["${name~}"]:Fire[1]
        return ${Chains.Get["${name~}"]:Fire[0](exists)}
    }

    method FireState(string name, bool newState)
    {
;        echo "\ayisb2_triggerchains:FireState\ax ${name~} ${newState}"
        return ${Chains.Get["${name~}"]:Fire[${newState}](exists)}
    }
}

/* isb2_hotkeysheet: 
    
*/
objectdef isb2_hotkeysheet
{
    variable string Name

    variable bool Enable
    variable bool Enabled

    variable bool WasEnabled

    variable jsonvalue Hotkeys="{}"
    variable isb2_triggerchains TriggerChains

    method Initialize(jsonvalueref jo)
    {
        This:FromJSON[jo]

        TriggerChains:ApplyPendingTriggersAs[hotkeysheet,"${Name~}"]        
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

    member:jsonvalueref AsJSON()
    {
        variable jsonvalue jo="{}"
        jo:SetString[name,"${Name~}"]
        jo:SetBool[enabled,${Enabled}]
        jo:SetBool[wasEnabled,${WasEnabled}]
        jo:SetByRef[hotkeys,Hotkeys]

        return jo
    }

    method Add(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        jo:SetString[sheet,"${Name~}"]

        variable jsonvalueref joOverride
        joOverride:SetReference["ISB2.FindHotkeyOverride[\"${Name~}\",\"${jo.Get[name]~}\"]"]

        if ${joOverride.Reference(exists)}
            jo:Set[keyCombo,"${joOverride.Get[keyCombo].AsJSON~}"]

        Hotkeys:SetByRef["${jo.Get[name]~}",jo]
    }

    method Activate()
    {
        echo "hotkey sheet ${Name~} Activate"
        if !${Enable}
            return FALSE

        This:Enable
        return TRUE
    }

    method Enable(bool maybeNot)
    {
        if ${Enabled}
            return TRUE

        if ${maybeNot} && !${WasEnabled}
            return FALSE
        
        if !${ISB2.AllowHotkeySheet["${Name~}"]}
            return FALSE

        Enabled:Set[1]
        WasEnabled:Set[1]

        variable jsonvalue joQuery="{}"
        joQuery:SetString[op,"!="]
        joQuery:SetBool[value,0]
        joQuery:SetString[eval,"Select.GetBool[enable]"]
        Hotkeys:ForEach["This:EnableHotkey[ForEach.Value]",joQuery]

        TriggerChains:Fire["OnEnabled"]
        return TRUE
    }

    method Disable()
    {
        if !${Enabled}
            return TRUE
        Enabled:Set[0]
        Hotkeys:ForEach["This:DisableHotkey[ForEach.Value]"]

        TriggerChains:Fire["OnDisabled"]
        return TRUE
    }

    method Toggle(bool maybeNot)
    {
        if ${Enabled}
            This:Disable
        else
            This:Enable[${maybeNot}]
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
    variable bool WasEnabled

    variable bool Hold
    variable string Mode="OnRelease"
    
    variable string VirtualizeAs
    variable isb2_triggerchains TriggerChains

    method Initialize(jsonvalueref jo)
    {
;        Enabled:Set[1]
        This:FromJSON[jo]

        TriggerChains:ApplyPendingTriggersAs[mappablesheet,"${Name~}"]        
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

    method Enable(bool maybeNot)
    {
        if ${Enabled}
            return TRUE

        if ${maybeNot} && !${WasEnabled}
            return FALSE

        if !${ISB2.AllowMappableSheet["${Name~}"]}
            return FALSE

        Enabled:Set[1]
        WasEnabled:Set[1]
        TriggerChains:Fire["OnEnabled"]
        return TRUE
    }

    method Disable()
    {
        if !${Enabled}
            return TRUE

        Enabled:Set[0]
        TriggerChains:Fire["OnDisabled"]
        return TRUE
    }

    method Toggle(bool maybeNot)
    {
        if ${Enabled}
            This:Disable
        else
            This:Enable[${maybeNot}]
    }    
}

objectdef isb2_gamemacrosheet
{
    variable string Name
    variable string GameName

    variable jsonvalue Macros="{}"
    variable isb2_triggerchains TriggerChains

    method Initialize(jsonvalueref jo)
    {        
        This:FromJSON[jo]

        TriggerChains:ApplyPendingTriggersAs[gamemacrosheet,"${Name~}"]        
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
    variable isb2_triggerchains TriggerChains

    method Initialize(jsonvalueref jo)
    {
        This:FromJSON[jo]

        TriggerChains:ApplyPendingTriggersAs[imagesheet,"${Name~}"]        
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

        LGUI2.Skin["default"]:SetBrush["${Name~}.${jo.Get[name]~}",joImageBrush]
    }
}

objectdef isb2_regionsheet
{
    variable string Name
    variable bool Enabled

    variable jsonvalue Regions="{}"
    variable isb2_triggerchains TriggerChains

    method Initialize(jsonvalueref jo)
    {
        This:FromJSON[jo]

        TriggerChains:ApplyPendingTriggersAs[regionsheet,"${Name~}"]        
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

objectdef isb2_vfxOutput
{
    variable string Name
    variable jsonvalueref Data
    variable isb2_triggerchains TriggerChains
    variable weakref Sheet
    variable lgui2elementref Window

    method Initialize(weakref sheet, jsonvalueref jo)
    {
        Sheet:SetReference[sheet]
        This:FromJSON[jo]
        
        
        ; TriggerChains:ApplyPendingTriggersAs[vfxoutput,"${Name~}"]                
    }

    method Shutdown()
    {
        This:Disable
    }

    method FromJSON(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        Data:SetReference[jo]

        if ${jo.Has[name]}
            Name:Set["${jo.Get[name]~}"]

        if ${jo.GetBool[enable]}
        {
            This:Enable
        }        
    }

    member:jsonvalueref AsJSON()
    {
        return Data
    }

    method SetState(bool newState)
    {
        if ${newState}
            This:Enable
        else
            This:Disable
    }
    
    method Enable()
    {
        if ${Window.Element(exists)}
            return

        if !${Data.Reference(exists)}
            return

        if !${Data.Has[name]}
            return

        This:CreateWindow
        TriggerChains:Fire["OnEnabled"]
    }

    method Disable()
    {
        if !${Window.Element(exists)}
            return

        Window:Destroy
        TriggerChains:Fire["OnDisabled"]
    }

    method CreateWindow()
    {
;        echo "\agisb2_vfxOutput:CreateWindow\ax"
        variable int x=${Data.GetInteger[x]}
        variable int y=${Data.GetInteger[y]}
        variable int w=${Data.GetInteger[width]}
        variable int h=${Data.GetInteger[height]}

        variable jsonvalueref joAdjust="LGUI2.Skin[\"${ISB2.UseSkin~}\"].Template[window.adjustments]"

        ; adjust for extra window size beyond the VFX output element
        x:Inc["${joAdjust.GetInteger[x]}"]
        y:Inc["${joAdjust.GetInteger[y]}"]
        w:Inc["${joAdjust.GetInteger[width]}"]
        h:Inc["${joAdjust.GetInteger[height]}"]

        variable jsonvalue joVideofeed
        joVideofeed:SetValue["$$>
        {
            "name":"isb2.vfx.${Sheet.Name~}.${Name~}",
            "type":"videofeed",
            "horizontalAlignment":"stretch",
            "verticalAlignment":"stretch",
            "feedName":${Data.Get[feedName]~.AsJSON~},
            "sendMouse":${Data.GetBool[-default,false,sendMouse]},
            "sendKeyboard":${Data.GetBool[-default,false,sendKeyboard]},
            "useLocalBindings":${Data.GetBool[-default,true,useLocalBindings]},
            "permanent":${Data.GetBool[-default,false,permanent]}
            "opacity":${Data.GetNumber[-default,1.0,opacity]}
        }
        <$$"]

        variable jsonvalue joWindow
        joWindow:SetValue["$$>
        {
            "name":"isb2.vfxOutputWindow.${Sheet.Name~}.${Name~}",
            "type":"window",
            "jsonTemplate":"isb2.vfx",
            "x":${x},
            "y":${y},
            "width":${w},
            "height":${h},
            "title":"VFX Output: ${Data.Get[feedName]~}"
        }
        <$$"]


        joWindow:SetByRef[content,joVideofeed]

;        echo "\ayfinal\ax ${joView~}"

        LGUI2:PushSkin["${ISB2.UseSkin~}"]
        Window:Set["${LGUI2.LoadReference[joWindow,This].ID}"]
        LGUI2:PopSkin["${ISB2.UseSkin~}"]

        ISB2:ApplyGUIModeTo["${Window.ID}"]
    }

    method StopAnimation(string name)
    {
        Window.Animation["${name~}"]:Stop
    }

    method Animate(jsonvalueref joAnimation)
    {
        Window:Animate[joAnimation]
    }

    method ApplyStyleJSON(jsonvalueref joStyle)
    {
        Window:ApplyStyleJSON[joStyle]
    }
}

objectdef isb2_vfxSource
{
    variable string Name
    variable jsonvalueref Data
    variable isb2_triggerchains TriggerChains
    variable weakref Sheet
    variable lgui2elementref Window

    method Initialize(weakref sheet, jsonvalueref jo)
    {
        Sheet:SetReference[sheet]
        This:FromJSON[jo]

        ; TriggerChains:ApplyPendingTriggersAs[vfxsource,"${Name~}"]        
    }

    method Shutdown()
    {
        This:Disable
    }

    method FromJSON(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        Data:SetReference[jo]

        if ${jo.Has[name]}
            Name:Set["${jo.Get[name]~}"]

        if ${jo.GetBool[enable]}
        {
            This:Enable
        }
    }

    member:jsonvalueref AsJSON()
    {
        return Data
    }

    method SetState(bool newState)
    {
        if ${newState}
            This:Enable
        else
            This:Disable
    }

    method Enable()
    {
;        echo "\agisb2_vfxSource:Enable\ax ${Data~}"
        if ${Window.Element(exists)}
            return

        if !${Data.Reference(exists)}
            return

        if !${Data.Has[name]}
            return

        This:CreateWindow
        TriggerChains:Fire["OnEnabled"]        
    }

    method Disable()
    {
        if !${Window.Element(exists)}
            return

        Window:Destroy
        TriggerChains:Fire["OnDisabled"]
    }


    method CreateWindow()
    {
;        echo "\agisb2_vfxSource:CreateWindow\ax"

        variable int x=${Data.GetInteger[x]}
        variable int y=${Data.GetInteger[y]}
        variable int w=${Data.GetInteger[width]}
        variable int h=${Data.GetInteger[height]}

        variable jsonvalueref joAdjust="LGUI2.Skin[ISBoxer 2].Template[window.adjustments]"

        ; adjust for extra window size beyond the VFX source element
        x:Inc["${joAdjust.GetInteger[x]}"]
        y:Inc["${joAdjust.GetInteger[y]}"]
        w:Inc["${joAdjust.GetInteger[width]}"]
        h:Inc["${joAdjust.GetInteger[height]}"]

        variable jsonvalue joVideofeed
        joVideofeed:SetValue["$$>
        {
            "name":"isb2.vfx.${Sheet.Name~}.${Name~}",
            "type":"videofeedsource",
            "horizontalAlignment":"stretch",
            "verticalAlignment":"stretch",
            "feedName":${Data.Get[feedName]~.AsJSON~}
        }
        <$$"]

        variable jsonvalue joWindow
        joWindow:SetValue["$$>
        {
            "name":"isb2.vfxSourceWindow.${Sheet.Name~}.${Name~}",
            "type":"window",
            "jsonTemplate":"isb2.vfx",
            "x":${x},
            "y":${y},
            "width":${w},
            "height":${h},
            "title":"VFX Source: ${Data.Get[feedName]~}"
        }
        <$$"]
        joWindow:SetByRef[content,joVideofeed]

;        echo "\ayfinal\ax ${joWindow~}"
        LGUI2:PushSkin["${ISB2.UseSkin~}"]
        Window:Set["${LGUI2.LoadReference[joWindow,This].ID}"]
        LGUI2:PopSkin["${ISB2.UseSkin~}"]

        ISB2:ApplyGUIModeTo["${Window.ID}"]
    }   
    
    method StopAnimation(string name)
    {
        Window.Animation["${name~}"]:Stop
    }

    method Animate(jsonvalueref joAnimation)
    {
        Window:Animate[joAnimation]
    }

    method ApplyStyleJSON(jsonvalueref joStyle)
    {
        Window:ApplyStyleJSON[joStyle]
    }    
}

objectdef isb2_vfxsheet
{
    variable string Name
    variable bool Enabled

    variable collection:isb2_vfxOutput Outputs
    variable collection:isb2_vfxSource Sources

    variable isb2_triggerchains TriggerChains

    method Initialize(jsonvalueref jo)
    {
        This:FromJSON[jo]

        TriggerChains:ApplyPendingTriggersAs[vfxsheet,"${Name~}"]        
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

        echo "\agVFX Sheet installed\ax \ay${Name~}\ax"
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

        Outputs:Set["${jo.Get[name]~}",This,jo]
    }

    method AddSource(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE

        Sources:Set["${jo.Get[name]~}",This,jo]
    }
    
    method Enable()
    {
        echo "\arisb2_vfxsheet:Enable\ax ${Name~}"
        Enabled:Set[1]
        
        Outputs:ForEach["ForEach.Value:Enable"]
        Sources:ForEach["ForEach.Value:Enable"]

        TriggerChains:Fire["OnEnabled"]
    }

    method Disable()
    {
;        if !${Enabled}
;            return
        echo "\arisb2_vfxsheet:Disable\ax ${Name~} ${Outputs~} ${Sources~}"
        Enabled:Set[0]
        Outputs:ForEach["ForEach.Value:Disable"]
        Sources:ForEach["ForEach.Value:Disable"]

        TriggerChains:Fire["OnDisabled"]
    }

    method Toggle()
    {
        if ${Enabled}
            This:Disable
        else
            This:Enable
    }

    method SetVFXState(string name, bool newState, bool isSource)
    {
        if ${isSource}
        {
            Sources.Get["${name~}"]:SetState[${newState}]
        }
        else
        {
            Outputs.Get["${name~}"]:SetState[${newState}]
        }
    }

    method RemoveVFX(string name, bool isSource)
    {
        if ${isSource}
        {
            Sources:Erase["${name~}"]
        }
        else
        {
            Outputs:Erase["${name~}"]
        }
    }
}

objectdef isb2_variable
{
    variable string Name
    variable string Description

    variable jsonvalue Value

    variable jsonvalue Schema="{}"

    variable isb2_triggerchains TriggerChains

    variable bool Initializing

    method Initialize(jsonvalueref jo)
    {
        This:FromJSON[jo]

        TriggerChains:ApplyPendingTriggersAs[variable,"${Name~}"]        
    }

    method FromJSON(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        Initializing:Set[1]
        if ${jo.Has[name]}
            Name:Set["${jo.Get[name]~}"]
        if ${jo.Has[description]}
            Description:Set["${jo.Get[description]~}"]

        if ${jo.Has[schema]}
            Schema:SetValue["${jo.Get[schema].AsJSON~}"]        

        if ${jo.Has[value]}
            This:Set["${jo.Get[value].AsJSON~}"]        

        Initializing:Set[0]
    }

    member:jsonvalueref AsJSON()
    {
        variable jsonvalue jo="{}"

        jo:SetString[name,"${Name~}"]
        if ${Description.NotNULLOrEmpty}
            jo:SetString[description,"${Description~}"]
        jo:Set[value,"${Value.AsJSON~}"]

        if ${Schema.Used}
            jo:Set[schema,"${Schema.AsJSON~}"]

        return jo
    }

    method Set(string val)
    {
;        variable jsonvalue oldValue="${Value~}"
        echo "\ayisb2_variable:Set\ax \"${Name~}\"=${val~}"

        Value:SetValue["${val~}"]

        TriggerChains:Fire["OnValueChanged"]

        if !${Initializing}
            LGUI2.Element[isb2.events]:FireEventHandler["onVariableChanged","{\"name\":\"${Name~}\",\"value\":${Value.AsJSON~}}"]
    }

    method Forward()
    {
        variable jsonvalue joQuery
        if ${Schema.Has[enum]}
        {
            joQuery:SetValue["{\"op\":\"==\"}"]
            joQuery:Set["value","${Value.AsJSON~}"]

            ; find the enum value matching this one
            variable uint numVal
            numVal:Set[${Schema.Get[enum].SelectKey[joQuery]}]

            ; increment
            numVal:Set[  (${numVal}  % ${Schema.Get[enum].Used}) + 1] 

            ; set to this enum value
            This:Set["${Schema.Get[enum,${numVal}].AsJSON~}"]

            return TRUE
        }

        switch ${Schema.Get[type]}
        {
            case boolean
            {
                This:Set["${Bool["${Value~}"].Not.AsJSON~}"]
                return TRUE
            }
                break
            case integer
                This:Set["${Int64["${Value~}"].Inc}"]
                ; todo: apply Schema-defined limits
                break
            case number
                This:Set["${Float64["${Value~}"].Inc}"]
                ; todo: apply Schema-defined limits
                break
        }

        return FALSE
    }

    method Backward()
    {
        variable jsonvalue joQuery
        if ${Schema.Has[enum]}
        {
            joQuery:SetValue["{\"op\":\"==\"}"]
            joQuery:Set["value","${Value.AsJSON~}"]

            ; find the enum value matching this one
            variable uint numVal
            numVal:Set[${Schema.Get[enum].SelectKey[joQuery]}]

            if ${numVal}<=1
                numVal:Set[${Schema.Get[enum].Used}]
            else
                numVal:Dec
            
            ; set to this enum value
            This:Set["${Schema.Get[enum,${numVal}].AsJSON~}"]

            return TRUE
        }

        switch ${Schema.Get[type]}
        {
            case boolean
            {
                This:Set["${Bool["${Value~}"].Not.AsJSON~}"]
                return TRUE
            }
                break
            case integer
                This:Set["${Int64["${Value~}"].Dec}"]
                ; todo: apply Schema-defined limits
                break
            case number
                This:Set["${Float64["${Value~}"].Dec}"]
                ; todo: apply Schema-defined limits
                break
        }

        return FALSE
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

    variable isb2_triggerchains TriggerChains

    method Initialize(jsonvalueref jo)
    {
        This:FromJSON[jo]
        TriggerChains:ApplyPendingTriggersAs[timerpool,"${Name~}"]                
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
		if ${ActiveTimers.Used}>=${MaxTimers} && ${MaxTimers}
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
