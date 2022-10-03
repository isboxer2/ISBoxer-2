/* isb2022_profile: 
    A set of definitions for ISBoxer 2022. Like an ISBoxer Toolkit Profile, but preferably more generic.
*/
objectdef isb2022_profile
{
    variable string LocalFilename
    variable uint Priority

    variable string Name
    variable string Description
    variable string Version
    variable uint MinimumBuild
    variable jsonvalue Metadata

    variable jsonvalue Profiles=[]
    variable jsonvalue Teams=[]
    variable jsonvalue Characters=[]
    variable jsonvalue WindowLayouts=[]
    variable jsonvalue VirtualFiles=[]
    variable jsonvalue Triggers=[]
    variable jsonvalue HotkeySheets=[]
    variable jsonvalue MappableSheets=[]
    variable jsonvalue GameKeyBindings=[]
    variable jsonvalue GameMacroSheets=[]
    variable jsonvalue ClickBars=[]
    variable jsonvalue VFXSheets=[]

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
            Metadata:SetValue["${jo.Get[metadata]~}"]
        if ${jo.Has[profiles]}
            Profiles:SetValue["${jo.Get[profiles]~}"]
        if ${jo.Has[teams]}
            Teams:SetValue["${jo.Get[teams]~}"] 
        if ${jo.Has[characters]}
            Characters:SetValue["${jo.Get[characters]~}"]
        if ${jo.Has[windowLayouts]}
            WindowLayouts:SetValue["${jo.Get[windowLayouts]~}"]
        if ${jo.Has[virtualFiles]}
            VirtualFiles:SetValue["${jo.Get[virtualFiles]~}"]
        if ${jo.Has[triggers]}
            Triggers:SetValue["${jo.Get[triggers]~}"]
        if ${jo.Has[hotkeySheets]}
            HotkeySheets:SetValue["${jo.Get[hotkeySheets]~}"]
        if ${jo.Has[gameKeyBindings]}
            GameKeyBindings:SetValue["${jo.Get[gameKeyBindings]~}"]
        if ${jo.Has[mappableSheets]}
            MappableSheets:SetValue["${jo.Get[mappableSheets]~}"]
        if ${jo.Has[vfxSheets]}
            VFXSheets:SetValue["${jo.Get[vfxSheets]~}"]
        if ${jo.Has[clickBars]}
            ClickBars:SetValue["${jo.Get[clickBars]~}"]
        if ${jo.Has[gameMacroSheets]}
            GameMacroSheets:SetValue["${jo.Get[gameMacroSheets]~}"]
    }

    member:jsonvalueref AsJSON()
    {
        variable jsonvalue jo

        jo:SetValue["$$>
        {
            "$schema":"http://www.lavishsoft.com/schema/isb2022.json",
            "name":${Name.AsJSON~}
        }
        <$$"]

        if ${Description.NotNULLOrEmpty}
            jo:Set["description","${Description.AsJSON~}"]
        if ${Version.NotNULLOrEmpty}
            jo:Set["version","${Version.AsJSON~}"]
        if ${MinimumBuild}
            jo:Set["description","${Description.AsJSON~}"]
        if ${Metadata.Type.Equal[object]}
            jo:Set["metadata","${Metadata.AsJSON~}"]
        if ${Profiles.Used}
            jo:Set["profiles","${Profiles.AsJSON~}"]
        if ${Teams.Used}
            jo:Set["teams","${Teams.AsJSON~}"]
        if ${Characters.Used}
            jo:Set["characters","${Characters.AsJSON~}"]
        if ${WindowLayouts.Used}
            jo:Set["windowLayouts","${WindowLayouts.AsJSON~}"]
        if ${VirtualFiles.Used}
            jo:Set["virtualFiles","${VirtualFiles.AsJSON~}"]
        if ${Triggers.Used}
            jo:Set["triggers","${Triggers.AsJSON~}"]
        if ${HotkeySheets.Used}
            jo:Set["hotkeySheets","${HotkeySheets.AsJSON~}"]
        if ${GameKeyBindings.Used}
            jo:Set["gameKeyBindings","${GameKeyBindings.AsJSON~}"]
        if ${MappableSheets.Used}
            jo:Set["mappableSheets","${MappableSheets.AsJSON~}"]
        if ${VFXSheets.Used}
            jo:Set["vfxSheets","${VFXSheets.AsJSON~}"]
        if ${ClickBars.Used}
            jo:Set["clickBars","${ClickBars.AsJSON~}"]
        if ${GameMacroSheets.Used}
            jo:Set["gameMacroSheets","${GameMacroSheets.AsJSON~}"]
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


/* isb2022_profilecollection: 
    A collection of ISBoxer 2022 profiles
*/
objectdef isb2022_profilecollection
{
    ; The variable that contains the actual list
    variable collection:isb2022_profile Profiles

    variable collection:isb2022_profileeditor Editors

    variable uint LoadCount

    /*
    member:jsonvalueref ScanFolder(filepath filePath)
    {
        echo ${filePath.GetFiles[*.isb2022.json]}
        return "filePath.GetFiles[*.isb2022.json]"
    }
    /**/

    method LoadFolder(filepath filePath)
    {
        echo LoadFolder ${filePath~}
        filePath.GetFiles["*.isb2022.json"]:ForEach["This:LoadFile[\"${filePath~}/\${ForEach.Value.Get[filename]}\"]"]
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
        ; given a path like "Tests/WoW.isb2022.json" this turns it into like "C:/blah blah/Tests/isb2022.json"
        fileName:MakeAbsolute
        
        ; parse the file into, hopefully, a json object
        variable jsonvalue jo        
        if !${jo:ParseFile["${fileName~}"](exists)}
            return FALSE

        ; if we got something else, forget it
        if !${jo.Type.Equal[object]}
        {
            echo "isb2022_profilecollection:LoadFile[${fileName~}]: expected JSON object, got ${jo.Type~}"
            return FALSE
        }

        ; a profile is required to have a name, so we can more easily work with multiple profiles!
        if !${jo.Has[name]}
        {
            echo "isb2022_profilecollection:LoadFile[${fileName~}]: 'name' field required"
            return FALSE
        }

        ; temporarily store the name since we'll need it a few times
        variable string name
        name:Set["${jo.Get[name]~}"]

        LoadCount:Inc
        ; Assign the Profile
        Profiles:Set["${name~}","jo",${LoadCount},"${fileName~}"]

        ; the isb2022_profile object is now created, assign its LocalFilename
        Profiles.Get["${name~}"].LocalFilename:Set["${fileName~}"]
        echo "Profile added: ${name~}"

        ; fire an event for the GUI to refresh its Profiles if needed
        LGUI2.Element[isb2022.events]:FireEventHandler[onProfilesUpdated] 
    }

    method RemoveProfile(string name)
    {
        Profiles:Erase["${name~}"]

        ; fire an event for the GUI to refresh its Profiles if needed
        LGUI2.Element[isb2022.events]:FireEventHandler[onProfilesUpdated] 
    }

    member:jsonvalueref FindOne(string arrayName,string objectName)
    {
        variable uint foundPriority=0
        variable jsonvalueref foundObject

        variable jsonvalueref checkObject

        variable iterator Iterator
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

    member:jsonvalueref Locate(string arrayName,string objectName)
    {
        variable uint foundPriority=0
        variable jsonvalue result

        variable jsonvalueref checkObject

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

objectdef isb2022_profileeditor
{
    variable weakref Editing
    variable weakref EditingItem
    variable lgui2elementref Window

    method Initialize(weakref _profile)
    {
        Editing:SetReference[_profile]
        LGUI2:PushSkin["ISBoxer 2022"]
        Window:Set["${LGUI2.LoadReference["LGUI2.Template[isb2022.profileEditor]",This].ID}"]
        LGUI2:PopSkin["ISBoxer 2022"]
    }

    method Shutdown()
    {

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
        Window.Locate["profile.editorContainer"]:SetChild["${LGUI2.Template[isb2022.${This.GetLowerCamelCase["${editingType~}"]}Editor]~}","EditingItem"]
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

objectdef isb2022_clickbar
{
    variable string Name
    
    variable jsonvalueref Data
    variable lgui2elementref Window

    method Initialize(jsonvalueref jo)
    {
        This:FromJSON[jo]
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

    method GotMouseFocus()
    {
;        echo isb2022_clickbar:GotMouseFocus ${Context(type)} ${Context.Source} numButton=${Context.Source.Metadata.GetInteger[numButton]}
    }

    method LostMouseFocus()
    {
;        echo isb2022_clickbar:LostMouseFocus ${Context(type)} ${Context.Source} numButton=${Context.Source.Metadata.GetInteger[numButton]}
    }

    method GotMouseOver()
    {
        variable uint numButton=${Context.Source.Metadata.GetInteger[numButton]}
;        echo isb2022_clickbar:GotMouseOver numButton=${numButton}

        variable jsonvalueref joButton
        joButton:SetReference["Data.Get[buttons,${numButton}]"]

        if !${joButton.Reference(exists)}
            return

        ; get input mapping
        if !${joButton.Has[mouseOver]}
            return

        ISB2022:ExecuteInputMapping["joButton.Get[mouseover]",1]
    }

    method LostMouseOver()
    {
        variable uint numButton=${Context.Source.Metadata.GetInteger[numButton]}
;        echo isb2022_clickbar:LostMouseOver numButton=${numButton}

        variable jsonvalueref joButton
        joButton:SetReference["Data.Get[buttons,${numButton}]"]

        if !${joButton.Reference(exists)}
            return

        ; get input mapping
        if !${joButton.Has[mouseOver]}
            return

        ISB2022:ExecuteInputMapping["joButton.Get[mouseover]",0]
    }

    member:bool ClickMatches(jsonvalueref joClick, jsonvalueref joMatch)
    {
;        echo ClickMatches ${joClick~} ${joMatch~}
        if ${joClick.GetInteger[button]}!=${joMatch.GetInteger[controlID]}
            return FALSE

        ; TODO: compare modifiers.

;        echo ClickMatches \agTRUE\ax
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

    method OnButtonPress(jsonvalueref joButton, jsonvalueref joData)
    {
        echo onButtonPress ${joButton~} ${joData~}
        variable jsonvalueref joClick
        joClick:SetReference["This.GetClick[\"joButton.Get[clicks]\",joData]"]

        if !${joClick.Reference(exists)}
            return

        if !${joButton.Has[activeClicks]}
            joButton:Set["activeClicks","[null,null,null,null,null]"]

        joButton.Get[activeClicks]:Set[${joData.GetInteger[controlID]},"${joClick~}"]

        ISB2022:ExecuteInputMapping["joClick.Get[inputMapping]",1]
    }

    method OnButtonRelease(jsonvalueref joButton, jsonvalueref joData)
    {
        echo onButtonRelease ${joButton~} ${joData~}
        variable uint mouseButton=${joData.GetInteger[controlID]}
        variable jsonvalueref joClick
        joClick:SetReference["joButton.Get[activeClicks,${mouseButton}]"]

        if !${joClick.Reference.Type.Equal[object]}
            return

        joButton.Get[activeClicks]:Set[${mouseButton},NULL]
        ISB2022:ExecuteInputMapping["joClick.Get[inputMapping]",0]
    }

    method OnMouseButtonMove()
    {
        variable uint numButton=${Context.Source.Metadata.GetInteger[numButton]}
        variable bool pressed=${Context.Args.Get[position]}
        echo isb2022_clickbar:OnMouseButtonMove numButton=${numButton} ${Context(type)} ${Context.Args} 

        variable jsonvalueref joButton
        joButton:SetReference["Data.Get[buttons,${numButton}]"]

        if !${joButton.Reference(exists)}
            return

        if ${pressed}
            This:OnButtonPress[joButton,Context.Args]
        else
            This:OnButtonRelease[joButton,Context.Args]
    }

    member:uint GetButtonHeight()
    {
        if ${Data.Has[rowHeight]}
            return ${Data.GetInteger[rowHeight]}
        return 32
    }

    member:uint GetButtonWidth()
    {
        if ${Data.Has[columnWidth]}
            return ${Data.GetInteger[columnWidth]}

        return 32
    }

    method GenerateButtonView()
    {
        echo isb2022_clickbar:GenerateButtonView ${Context(type)} ${Context.Args}
        ;isb2022_clickbar:GenerateButtonView lgui2itemviewgeneratorargs 
        ; {"name":"Button 2","clicks":[{"button":1,"inputMapping":{"type":"action","action":{"type":"keystroke","keyCombo":"2"}}}]}

        variable jsonvalue joButton
        joButton:SetValue["$$>
        {
            "jsonTemplate":"isb2022.clickbarButton",
            "width":${This.GetButtonHeight},
            "height":${This.GetButtonWidth},
            "_numButton":${Context.Args.Get[numButton]}
        }
        <$$"]


        Context:SetView["${joButton.AsJSON~}"]
    }

    method CreateWindow()
    {
        echo isb2022_clickbar:CreateWindow
        if ${Window.Reference(exists)}
            return

        variable string useName="isb2022.cb.${Name~}"        

        variable jsonvalue joWindow
        joWindow:SetValue["$$>
        {
            "type":"window",
            "jsonTemplate":"isb2022.clickbar",
            "name":${useName.AsJSON~},
            "title":${Name.AsJSON~},
            "x":${Data.GetInteger[x]},
            "y":${Data.GetInteger[y]},
        }
        <$$"]

        LGUI2:PushSkin["ISBoxer 2022"]
        Window:Set["${LGUI2.LoadReference[joWindow,This].ID}"]
        LGUI2:PopSkin["ISBoxer 2022"]
    }

    method FromJSON(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return

        if ${jo.Has[name]}
            Name:Set["${jo.Get[name]~}"]                            

        Data:SetReference[jo]

        Data.Get[buttons]:ForEach["ForEach.Value:SetInteger[numButton,\${ForEach.Key}]"]

        if ${Data.GetBool[enable]}
        {
            This:CreateWindow
        }
    }

}

objectdef isb2022_triggerchain
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

/* isb2022_hotkeysheet: 
    
*/
objectdef isb2022_hotkeysheet
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
        ISB2022:InstallHotkey["${Name~}","${jo.Get[name]~}",jo]

        jo:SetBool["enabled",1]
    }

    method DisableHotkey(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        if !${jo.Has[name]}
            return
        
        ISB2022:UninstallHotkey["${Name~}","${jo.Get[name]~}"]

        jo:SetBool["enabled",0]
    }
}

objectdef isb2022_mappablesheet
{
    variable string Name

    variable jsonvalue Mappables="{}"

    variable bool Enabled

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
        jo:SetByRef[mappables,Mappables]
        return jo
    }

    method Add(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE
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

objectdef isb2022_gamemacrosheet
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

objectdef isb2022_regionsheet
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

objectdef isb2022_vfxsheet
{
    variable string Name
    variable bool Enabled

    variable jsonvalue VFX="{}"

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

        jo.Get[vfx]:ForEach["This:Add[ForEach.Value]"]


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
        jo:SetByRef[vfx,VFX]
        return jo
    }

    method Add(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
            return FALSE
        VFX:SetByRef["${jo.Get[name]~}",jo]
    }

    
    method Enable()
    {
        Enabled:Set[1]
        VFX:ForEach["This:EnableVFX[ForEach.Value]"]
    }

    method Disable()
    {
        Enabled:Set[0]
        VFX:ForEach["This:DisableVFX[ForEach.Value]"]
    }

    method Toggle()
    {
        if ${Enabled}
            This:Disable
        else
            This:Enable
    }

    method EnableVFX(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        if !${jo.Has[name]}
            return

        ISB2022:InstallVFX["${Name~}","${jo.Get[name]~}",jo]

        jo:SetBool["enabled",1]
    }

    method DisableVFX(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        if !${jo.Has[name]}
            return
        
        ISB2022:UninstallVFX["${Name~}","${jo.Get[name]~}",jo]

        jo:SetBool["enabled",0]
    }
}
