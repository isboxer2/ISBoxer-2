
objectdef isb2_profileEditorContext
{
    variable string Name
    variable weakref Editor
    variable weakref Parent

    ; a mapped key, a step, etc.
    variable weakref EditingItem

    variable jsonvalueref Data
    variable lgui2elementref Element
    variable lgui2elementref Container

    method Initialize(weakref _editor, jsonvalueref jo)
    {
;        echo "isb2_profileEditorContext:Initialize ${jo~}"
        Data:SetReference[jo]
        Name:Set["${jo.Get[name]~}"]
        Editor:SetReference[_editor]
    }


    method AddSubItem(jsonvalueref joContainer, jsonvalueref joItem)
    {
        echo "AddSubItem ${joContainer~} ${joItem~}"
        variable jsonvalueref joSubItem="{}"

        if ${joItem.Has[-object,list]}
        {
            joSubItem:Merge["LGUI2.Template[isb2.profileEditor.Context.List]"]

            if ${joItem.Get[list].Has[-string,context]}
            {
                joItem.Get[list]:SetString["_context","${joItem.Get[list,context]~}"]
            }

            joSubItem.Get[content]:Merge["joItem.Get[list]"]
            joSubItem:SetString[contextBinding,"This.Locate[\"\",listbox,ancestor].Context"]


            joSubItem:SetString[header,"${joItem.Get[name]~}"]
            joSubItem:SetString[itemName,"${joItem.Get[name]~}"]
            if ${joItem.Has[-string,init]}
                joSubItem:SetString[init,"${joItem.Get[init]~}"]

            if !${joContainer.Has[items]}
                joContainer:Set[items,"[]"]
            
            joContainer.Get[items]:AddByRef[joSubItem]

            echo "modified ${joContainer~}"
            
            return
        }


        joSubItem:SetString[type,textblock]
        joSubItem:SetString[text,"${joItem.Get[name]~}"]
        joSubItem:SetString[itemName,"${joItem.Get[name]~}"]

        if ${joItem.Has[-string,template]}
            joSubItem:SetString[template,"${joItem.Get[template]~}"]
        if ${joItem.Has[-string,item]}
            joSubItem:SetString[item,"${joItem.Get[item]~}"]

        if ${joItem.Has[-string,init]}
            joSubItem:SetString[init,"${joItem.Get[init]~}"]


        if !${joContainer.Has[items]}
            joContainer:Set[items,"[]"]
            
        joContainer.Get[items]:AddByRef[joSubItem]



    }

    method Attach(lgui2elementref element, string useTemplate)
    {
        Element:Set["${element.ID}"]
        echo "Attach: ${element} ${element.ID} template=${useTemplate~} ${Data~}"

        Element:SetContext[This]

        Element:ClearChildren

        variable jsonvalueref joLeftPane
        variable jsonvalueref joEditor


        variable jsonvalueref joLeftPaneContainer

        if ${Data.Has[-array,subItems]}
        {
            joLeftPane:SetReference["LGUI2.Template[isb2.editorContext.leftPane]"]
            joLeftPane:SetString["_pane","isb2.subPages"]
            echo "joLeftPane ${joLeftPane~}"
            joLeftPaneContainer:SetReference["joLeftPane.Get[content,content]"]
            Data.Get[subItems]:ForEach["This:AddSubItem[joLeftPaneContainer,ForEach.Value]"]          
        }

        if !${useTemplate.NotNULLOrEmpty} && ${Data.Has[-string,template]}
        {
            useTemplate:Set["${Data.Get[template]~}"]
        }

        joEditor:SetReference["LGUI2.Template[\"${useTemplate~}\"]"]

        if !${joEditor.Reference(exists)} || !${joEditor.Used}
        {
            joEditor:SetReference["LGUI2.Template[isb2.missingEditor]"]
            echo "\armissing editor\ax \"${useTemplate~}\" = ${joEditor~}"
        }

        if ${joLeftPane.Reference(exists)}
        {
            echo "adding left pane ${joLeftPane.AsJSON[multiline]~}"
            Element:AddChild[joLeftPane]
        }

        variable jsonvalueref joEditorContainer
        joEditorContainer:SetReference["LGUI2.Template[isb2.profileEditor.container]"]

        if ${joEditor.Reference(exists)}
        {
            joEditorContainer:Set[children,"[]"]
            joEditorContainer.Get[children]:AddByRef[joEditor]
;            echo "adding editor ${joEditor~} => ${joEditorContainer.AsJSON[multiline]~}"

            Container:Set["${Element.AddChild[joEditorContainer].ID}"]

            echo "container = ${Container.ID}"
;            Element:AddChild["joEditorContainer"]
        }
    }

    method InitConfigurationBuilders()
    {
        echo "\ayInitConfigurationBuilders\ax ${EditingItem~}"
        Editor.SelectedBuilderPreset:SetReference["EditingItem"]
        Editor.BuildingCharacters:SetReference["Editor.GetCharactersFromTeam[EditingItem]"]
        
        variable jsonvalueref jaGames
        jaGames:SetReference["LGUI2.Skin[default].Template[isb2.data].Get[games]"]

        Editor.BuildingGame:SetReference["ISB2.FindInArray[jaGames,\"${Editor.BuildingCharacters.Get[1,game]~}\"]"]

        Editor:RefreshBuilders
    }

    method OnConfigurationBuildersDetached()
    {
        echo "\ayOnConfigurationBuildersDetached\ax"
        
        Editor:ApplyBuilders[EditingItem]
    }

    method ResetSelections(string editingType)
    {
        if ${editingType.NotEqual["Character"]}
            Window.Locate["profile.characters"]:ClearSelection
        if ${editingType.NotEqual["HotkeySheet"]}
            Window.Locate["profile.hotkeySheets"]:ClearSelection
        if ${editingType.NotEqual["MappableSheet"]}
            Window.Locate["profile.mappableSheets"]:ClearSelection
        if ${editingType.NotEqual["Team"]}
            Window.Locate["profile.teams"]:ClearSelection
        if ${editingType.NotEqual["GameKeyBinding"]}
            Window.Locate["profile.gameKeyBindings"]:ClearSelection
        if ${editingType.NotEqual["VirtualFile"]}
            Window.Locate["profile.virtualFiles"]:ClearSelection
        if ${editingType.NotEqual["WindowLayout"]}
            Window.Locate["profile.windowLayouts"]:ClearSelection
        if ${editingType.NotEqual["VFXSheet"]}
            Window.Locate["profile.vfxSheets"]:ClearSelection
    }    


    method OnTreeItemSelected()
    {
        echo "context:OnTreeItemSelected ${Context.Source} ${Context.Source.ID} ${Context.Source.Metadata.Get[context]~}"
        
        ; Context.Source.SelectedItem.Data

        variable jsonvalueref joData="Context.Source.SelectedItem.Data"
        echo "data=${joData~}"

        variable string useName
        useName:Set["${Context.Source.Metadata.Get[context]~}"]
        if !${useName.NotNULLOrEmpty}
        {
            useName:Set["${Name~}.${joData.Get[itemName]~}"]
        }

        variable weakref useContext        
        useContext:SetReference["Editor.GetContext[\"${useName~}\"]"]
        if ${useContext.Reference(exists)}
        {
;            echo "useContext: ${useContext.Name~}"

            useContext.Parent:SetReference[This]

            if ${joData.Has[-string,item]}
            {
                useContext.EditingItem:SetReference["${joData.Get[item]~}"]
            }
            else
            {
                useContext.EditingItem:SetReference[EditingItem]
            }

            useContext:Attach[${Container.ID},"${joData.Get[template]~}"]
            if ${joData.Has[-string,init]}
            {
                execute "useContext:${joData.Get[init]~}"
            }
        }
        else
        {
 ;           echo "context ${useName~} not found???"
        }
    }

    method OnSubTreeItemSelected()
    {
        echo "context:OnSubTreeItemSelected ${Context.Source} ${Context.Source.ID} ${Context.Source.Metadata.Get[context]~}"
        
        ; Context.Source.SelectedItem.Data

        variable jsonvalueref joData="Context.Source.SelectedItem.Data"
        echo "data=${joData~}"

        variable string useName
        useName:Set["${Context.Source.Metadata.Get[context]~}"]
        if !${useName.NotNULLOrEmpty}
        {
            useName:Set["${Name~}.${joData.Get[itemName]~}"]
        }

        variable weakref useContext        
        useContext:SetReference["Editor.GetContext[\"${useName~}\"]"]
        if ${useContext.Reference(exists)}
        {
;            echo "useContext: ${useContext.Name~}"

            useContext.Parent:SetReference[This]

            if ${joData.Has[-string,item]}
            {
                useContext.EditingItem:SetReference["${joData.Get[item]~}"]
            }
            else
            {
                useContext.EditingItem:SetReference[joData]                                  
            }

            useContext:Attach[${Container.ID},"${joData.Get[template]~}"]
            if ${joData.Has[-string,init]}
            {
                execute "useContext:${joData.Get[init]~}"
            }
        }
        else
        {
 ;           echo "context ${useName~} not found???"
        }



    }
}


objectdef isb2_profileeditor inherits isb2_building
{
    variable weakref Editing
    variable lgui2elementref Window

    variable weakref MainContext
    variable collection:isb2_profileEditorContext Contexts

    method Initialize(weakref _profile)
    {
        Editing:SetReference[_profile]
        LGUI2:PushSkin["${ISB2.UseSkin~}"]
        Window:Set["${LGUI2.LoadReference["LGUI2.Template[isb2.profileEditor]",This].ID}"]
        LGUI2:PopSkin["${ISB2.UseSkin~}"]

        This:RefreshBuilderPresets

        LGUI2.Template[isb2.editorContexts].Get[contexts]:ForEach["Contexts:Set[\"\${ForEach.Value.Get[name]~}\",This,ForEach.Value]"]
        MainContext:SetReference["Contexts.Get[main]"]
        MainContext.EditingItem:SetReference[Editing]              

        MainContext:Attach[${Window.Locate["editor.container"].ID}]
    }

    method Shutdown()
    {
        Window:Destroy
    }

    method OnWindowClosed()
    {
        ISB2.Editors:Erase["${Editing.Name~}"]
    }

    member:weakref GetContext(string name)
    {
        echo "\arGetContext\ax ${name~}"
        if !${name.NotNULLOrEmpty}
            return NULL

        variable weakref useContext
        useContext:SetReference["Contexts.Get[\"${name~}\"]"]
        if !${useContext.Reference(exists)}
        {
            Contexts:Set["${name~}",This,"{\"name\":\"${name~}\"}"]
            useContext:SetReference["Contexts.Get[\"${name~}\"]"]
        }

        return useContext
    }

    member:string GetLowerCamelCase(string fromString)
    {
        return "${fromString.Lower.Left[1]}${fromString.Right[-1]}"
    }

/*
    method SetEditingItem(string editingType, uint editingNumber)
    {        
       ; echo "SetEditingItem ${editingType~} ${editingNumber}"
        EditingItem:SetReference["Editing.${editingType~}s.Get[${editingNumber}]"]
        ;echo "EditingItem = ${EditingItem(type)} Container=${Window.Locate["profile.editorContainer"](type)}"

        variable jsonvalueref joList
        joList:SetReference["LGUI2.Template[isb2.${This.GetLowerCamelCase["${editingType~}"]}Editor.List]"]

;        echo selected before = ${LGUI2.Element[isb2.subPage.List].SelectedItem.Index}

        if ${editingType.NotEqual["${EditingType~}"]}
        {
            EditingType:Set["${editingType~}"]
            SubPage:Set[1]
        }

        LGUI2.Element[isb2.subPage.List]:ApplyStyleJSON["joList"]

        ; echo selected after = ${LGUI2.Element[isb2.subPage.List].SelectedItem.Index}
    }

    method OnLeftPaneSelection(string itemType)
    {
        This:ResetSelections["${itemType~}"]
        This:SetEditingItem["${itemType~}",${Context.Source.SelectedItem.Index}]
    }

    method OnSubPageSelected(string useTemplate)
    {
        echo "OnSubPageSelected[${useTemplate~}] ${Context(type)} ${Context.Source} ${Context.Source.SelectedItem(type)} ${Context.Source.SelectedItem.Data}" 

        echo "EditingItem ${MainContext.EditingItem~}"

        variable jsonvalueref joData="Context.Source.SelectedItem.Data"

        variable jsonvalueref joEditor
        if !${useTemplate.NotNULLOrEmpty} && ${joData.Reference(exists)}
        {
            useTemplate:Set["${joData.Get[template]~}"]
        }

        if ${useTemplate.NotNULLOrEmpty}
            joEditor:SetReference["LGUI2.Template[\"${useTemplate~}\"]"]

        if !${joEditor.Reference(exists)}
            joEditor:SetReference["LGUI2.Template[isb2.missingEditor]"]

        if ${joEditor.Reference(exists)}
        {
            Window.Locate["profile.editorContainer"]:SetChild["joEditor"]
            
            if ${joData.Get[text]~.Equal[Configuration Builders]}
            {
                SelectedBuilderPreset:SetReference["MainContext.EditingItem"]
                BuildingCharacters:SetReference["This.GetCharactersFromTeam[MainContext.EditingItem]"]
                
                variable jsonvalueref jaGames
                jaGames:SetReference["LGUI2.Skin[default].Template[isb2.data].Get[games]"]

                BuildingGame:SetReference["ISB2.FindInArray[jaGames,\"${BuildingCharacters.Get[1,game]~}\"]"]

                This:RefreshBuilders
;                Window.Locate["profile.editorContainer"].Child:SetContext[This]
            }

            Window.Locate["profile.editorContainer"].Child:SetContext["MainContext"]            
        }
        else
            Window.Locate["profile.editorContainer"]:ClearChildren        
    }
/**/


    member:jsonvalueref GetCharacters()
    {
        echo "\arGetCharacters\ax"
        return "Editing.Characters"
    }

    method AddCharacterFromSlot(jsonvalueref ja, jsonvalueref joSlot)
    {
        echo "\arAddCharacterFromSlot\ax ${joSlot~}"
        variable jsonvalueref joCharacter
        joCharacter:SetReference["ISB2.FindOne[Characters,\"${joSlot.Get[character]~}\"]"]

        if !${joCharacter.Reference(exists)}
        {
            echo "Character not found: ${joSlot.Get[character]~}"
            return
        }

        ja:AddByRef[joCharacter]
    }

    member:jsonvalueref GetCharactersFromTeam(jsonvalueref joTeam)
    {
        variable jsonvalueref ja="[]"
        echo "\arGetCharactersFromTeam\ax ${joTeam~}"
        joTeam.Get[slots]:ForEach["This:AddCharacterFromSlot[ja,ForEach.Value]"]
        return ja
    }

    method OnConfigurationBuildersDetached()
    {
        echo "OnConfigurationBuildersDetached"
        
        This:ApplyBuilders[MainContext.EditingItem]
    }

}
