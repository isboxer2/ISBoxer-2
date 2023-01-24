
objectdef(global) isb2_profileEditorContext
{
    variable string Name
    variable string Title
    variable string MissingEditor

    variable weakref Editor
    variable weakref Parent

    ; a mapped key, a step, etc.
    variable weakref EditingItem

    variable jsonvalueref Data
    variable lgui2elementref Element
    variable lgui2elementref Container
    variable uint SelectedItem=1

    method Initialize(weakref _editor, jsonvalueref jo)
    {
;        echo "isb2_profileEditorContext:Initialize ${jo~}"
        Data:SetReference[jo]
        Name:Set["${jo.Get[name]~}"]
        Editor:SetReference[_editor]
    }


    method AddSubItem(jsonvalueref joContainer, jsonvalueref joItem)
    {
        echo "\ayAddSubItem container\ax=${joContainer~}"
        echo "\ayAddSubItem item\ax=${joItem~}"
        variable jsonvalueref joSubItem="{}"

        variable jsonvalueref joList

        if ${joItem.Has[-object,list]}
        {
            joList:SetReference["joItem.Get[list]"]
            joSubItem:Merge["LGUI2.Skin[default].Template[isb2.profileEditor.Context.List]"]

            if ${joList.Has[-string,context]}
            {
                joList:SetString["_context","${joList.Get[context]~}"]
                joSubItem:SetString["_context","${joList.Get[context]~}"]
            }

            if ${joList.Has[-string,source]}
            {
                joList:Set[itemsBinding,"{\"pullFormat\":\"\${This.Context.${joList.Get[source]~}}\"}"]
                joList:SetString["_source","${joList.Get[source]~}"]
                joSubItem:SetString["_source","${joList.Get[source]~}"]
            }

            if ${joList.Has[new]}
            {
                joList:Set["_new","${joList.Get[new].AsJSON~}"]
                joSubItem:Set["_new","${joList.Get[new].AsJSON~}"]
            }

            variable string useTemplate
            variable jsonvalueref joNewTemplate
            if ${joList.Has[-string,viewTemplate]}
            {
                useTemplate:Set["${joList.Get[viewTemplate]~}"]
                joNewTemplate:SetReference["LGUI2.Template[\"${useTemplate~}\"]"]
;                if !${joNewTemplate.Reference(exists)}
                {
                    if !${joNewTemplate.Reference(exists)}
                    {
                        joNewTemplate:SetReference["LGUI2.Template[\"isb2.commonView\"]"]
                        useTemplate:Set[isb2.commonView]
                    }
                    joNewTemplate:Set[contentContainer,"{\"jsonTemplate\":\"isb2.editorContext.itemviewcontainer\"}"]
                    LGUI2.Skin[default]:SetTemplate["${useTemplate~}.context",joNewTemplate]
                    joList:Set["itemViewGenerators","{\"default\":{\"type\":\"template\",\"template\":\"${joList.Get[viewTemplate]~}.context\"}}"]
                }
            }

            joList:SetString["_name","${joItem.Get[name]~}"]

            joSubItem.Get[content]:Merge["joList"]
            joSubItem:SetString[contextBinding,"This.Locate[\"\",listbox,ancestor].Context"]
        

            joSubItem:SetString[header,"${joItem.Get[name]~}"]
            joSubItem:SetString[itemName,"${joItem.Get[name]~}"]
            if ${joItem.Has[-string,init]}
                joSubItem:SetString[init,"${joItem.Get[init]~}"]

            if !${joContainer.Has[items]}
                joContainer:Set[items,"[]"]
            
            joContainer.Get[items]:AddByRef[joSubItem]

;            echo "modified ${joContainer~}"
            
            return
        }


        joSubItem:SetString[type,textblock]
        joSubItem:SetString[text,"${joItem.Get[name]~}"]
        joSubItem:SetString[itemName,"${joItem.Get[name]~}"]

        if ${joItem.Has[-string,template]}
            joSubItem:SetString[template,"${joItem.Get[template]~}"]
        if ${joItem.Has[-string,context]}
            joSubItem:SetString[context,"${joItem.Get[context]~}"]
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

        if !${element.Element(exists)}
        {
            Script:DumpStack
            return
        }

        Element:SetContext[This]

        Element:ClearChildren

        variable jsonvalueref joLeftPane
        variable jsonvalueref joEditor


        variable jsonvalueref joLeftPaneContainer

        if ${Data.Has[-string,title]}
        {
            Title:Set[${Data.Get[title].AsJSON}]
        }

        ; adding editor title
        variable jsonvalueref joEditorTitle="{}"
        if ${Title.NotNULLOrEmpty}
        {
    ;        joEditorTitle:SetReference["LGUI2.Template[isb2.editorContext.title]"]
            joEditorTitle:SetString[jsonTemplate,isb2.editorContext.title]
            joEditorTitle:SetString[_dock,top]
            Element:AddChild[joEditorTitle]
        }

        if ${Data.Has[-array,subItems]}
        {
            joLeftPane:SetReference["LGUI2.Template[isb2.editorContext.leftPane]"]
            joLeftPane:SetString["_pane","isb2.subPages"]
            echo "joLeftPane ${joLeftPane~}"
            joLeftPaneContainer:SetReference["joLeftPane.Get[content,children,2,content]"]
            Data.Get[subItems]:ForEach["This:AddSubItem[joLeftPaneContainer,ForEach.Value]"]          
        }

        if !${useTemplate.NotNULLOrEmpty}
        {
            if ${Data.Has[-string,template]}
                useTemplate:Set["${Data.Get[template]~}"]
            else
                useTemplate:Set["isb2.${Name}Editor.General"]
        }

        joEditor:SetReference["LGUI2.Template[\"${useTemplate~}\"]"]

        if !${joEditor.Reference(exists)} || !${joEditor.Used}
        {
            joEditor:SetReference["LGUI2.Template[isb2.missingEditor]"]
            echo "\armissing editor\ax \"${useTemplate~}\" = ${joEditor~}"
            if !${MissingEditor.NotNULLOrEmpty}
            {
                if ${useTemplate.NotNULLOrEmpty}
                    MissingEditor:Set["Missing template ${useTemplate~}"]
                else
                    MissingEditor:Set["Editor template missing from ${Name~}"]
            }
        }

        if ${joLeftPane.Reference(exists)}
        {
;            echo "adding left pane ${joLeftPane.AsJSON[multiline]~}"
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

;            echo "container = ${Container.ID}"
;            Element:AddChild["joEditorContainer"]
        }

        if ${joLeftPane.Reference(exists)}
        {
            Element.Locate[editorContext.leftPane.container,listbox,descendant]:SetItemSelected[1,1]
        }

    }

    method UpdateFromJSON(string _json)
    {
        variable jsonvalue jo
        jo:SetValue["${_json~}"]

        if ${jo.Type.Equal[object]}
        {
            EditingItem:Clear
            EditingItem:Merge[jo]
        }
    }

#region Configuration Builders
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
#endregion

#region Input Mappings    
    static member:jsonvalueref GetInputMappingTypeEditor(lgui2elementref element)
    {        
        variable string useTemplate="isb2.inputMappingEditor.${element.Context.Get[type]~}"
        variable jsonvalueref joEditor
        echo "\ayGetInputMappingTypeEditor\ax ${element} ${element.ID} ${element.Context~} ${useTemplate~}=${joEditor~}"


        if ${element.Context.Get[type].NotNULLOrEmpty}
            joEditor:SetReference["LGUI2.Skin[default].Template[\"${useTemplate~}\"]"]
        else
            return NULL
;            joEditor:SetReference["{\"type\":\"panel\"}"]

        if !${joEditor.Reference(exists)} || !${joEditor.Used}
        {
            joEditor:SetReference["LGUI2.Template[isb2.missingContextEditor]"]
            echo "\armissing editor\ax \"${useTemplate~}\" = ${joEditor~}"
            if ${element.Context.Get[type].NotNULLOrEmpty}
                MissingEditor:Set["Missing template ${useTemplate~}"]
        }

        return joEditor
    }
#endregion

#region Actions
    member:jsonvalueref GetActionTypeEditor()
    {        
        variable string useTemplate="isb2.actionEditor.${EditingItem.Get[type]~}"
        variable jsonvalueref joEditor


        if ${EditingItem.Get[type].NotNULLOrEmpty}
            joEditor:SetReference["LGUI2.Skin[default].Template[\"${useTemplate~}\"]"]
        else
            return NULL
;            joEditor:SetReference["{\"type\":\"panel\"}"]

        echo "\ayGetActionTypeEditor\ax ${EditingItem~} ${useTemplate~}=${joEditor~}"

        if !${joEditor.Reference(exists)} || !${joEditor.Used}
        {
            joEditor:SetReference["LGUI2.Template[isb2.missingEditor]"]
            echo "\armissing editor\ax \"${useTemplate~}\" = ${joEditor~}"
            if ${EditingItem.Get[type].NotNULLOrEmpty}
                MissingEditor:Set["Missing template ${useTemplate~}"]
        }

        return joEditor
    }
    
    static member:jsonvalueref GetActionAutoComplete(string _type, string name, string subList)
    {
        echo "\ayGetActionAutoComplete\ax \"${_type~}\" \"${name~}\" \"${subList~}\""

        variable jsonvalueref joMain="ISB2.FindOne[\"${_type~}\",\"${name~}\"]"
        if !${joMain.Reference(exists)}        
        {
            echo "${_type~} named ${name~} not found"
            return NULL
        }

;        echo "joMain=${joMain~}"

        variable jsonvalueref ja
        ja:SetReference["joMain.Get[\"${subList~}\"]"]
        if !${ja.Reference(exists)}
        {
            echo "joMain did not contain ${subList~}"            
            return NULL
        }

        echo "ja ${ja.Used} ${ja~}"
        variable jsonvalueref jo="{}"

        ja:ForEach["jo:SetByRef[\"\${ForEach.Value.Get[name]}\",ForEach.Value]"]
        echo "providing dictionary ${jo.Used} ${jo~}"
        return jo
    }
#endregion

    method OnTreeItemSelected()
    {
        echo "context:OnTreeItemSelected ${Context.Source} ${Context.Source.ID} ${Context.Source.Metadata.Get[context]~}"
        
        ; Context.Source.SelectedItem.Data

        variable jsonvalueref joData="Context.Source.SelectedItem.Data"
;        echo "data=${joData~}"

        variable string missingEditor
        variable string useName
        if ${joData.Has[-string,context]}
            useName:Set["${joData.Get[context]~}"]
        else
            useName:Set["${Context.Source.Metadata.Get[context]~}"]
        if !${useName.NotNULLOrEmpty}
        {
            if !${joData.Has[-string,itemName]}
            {
                echo "\arMissing context and itemName\ax in ${Name~}.${Context.Source.Metadata.Get[name]~}"
                missingEditor:Set["Context missing from ${Name~}.${Context.Source.Metadata.Get[name]~}"]
            }
            useName:Set["${Name~}.${joData.Get[itemName]~}"]
        }

        variable weakref useContext                
        useContext:SetReference["Editor.GetContext[\"${useName~}\"]"]
        if ${useContext.Reference(exists)}
        {
;            echo "useContext: ${useContext.Name~}"
            useContext.MissingEditor:Set["${missingEditor~}"]
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

        Context.Source:FireEventHandler[onSubTreeItemSelected,"{\"name\":\"${useName~}\",\"id\":${Context.Source.ID}}"]
    }

    method OnOtherSubTreeItemSelected(lgui2elementref subList, uint sourceID)
    {
        if ${subList.ID}!=${sourceID}
            subList:ClearSelection
    }

    method OnListContextMenu()
    {
        echo "\apcontext[${Name~}]:OnListContextMenu\ax ${Context.Source} ${Context.Source.ID} ${Context.Args~} ${Context.Source.SelectedItem.Data~} ${Context.Source.Parent[l].Metadata~} ${Context.Source.Context.Data~}"
        variable weakref listElement
        listElement:SetReference["Context.Source.Parent[l].Content"]

        switch ${Context.Source.SelectedItem.Data}
        {
            case New
                {

                    if ${listElement.Metadata.Has[new]}
                    {
                        listElement.ItemsSource:Add["${listElement.Metadata.Get[new].AsJSON~}"]
                    }
                    else
                        listElement.ItemsSource:Add["{}"]

                    listElement:RefreshItems
                    listElement:SetItemSelected[${ja.Used},1]
                }
                break
            case Paste
                {
                    echo "paste=${System.ClipboardText~}"
                    variable jsonvalue jo
                    jo:SetValue["${System.ClipboardText~}"]
                    if !${jo.Type.Equal[object]}
                    {
                        echo "parsing JSON object from clipboard text failed"
                        return
                    }

                    echo "pasted item type=${jo.Get[dragDropItemType]~}"

                    if ${jo.Get[dragDropItemType]~.Equal["${Context.Source.Parent[l].Metadata.Get[context]~}"]}
                    {
                        ; is good.
                        listElement.ItemsSource:Add["${jo.Get[item].AsJSON~}"]
                    }
                    else
                    {
                        ; is not good.
                        echo "expected paste item type ${Context.Source.Parent[l].Metadata.Get[context]~}"
                    }
                }
                break
            case Clear
                {
                    listElement.ItemsSource:Clear
                    listElement:RefreshItems                                        
                }
                break
        }
    }

    method OnContextMenu()
    {
        echo "\apcontext[${Name~}]:OnContextMenu\ax ${Context.Source} ${Context.Source.ID} ${Context.Args~} ${Context.Source.SelectedItem.Data~} ${Context.Source.Context.ItemList.Metadata~} ${Context.Source.Context.Data~}"
        switch ${Context.Source.SelectedItem.Data}
        {
            case Copy
                {
                    variable jsonvalueref joDragDrop
                    joDragDrop:SetReference["This.GetDragDropItem[\"${Context.Source.Context.ItemList.Metadata.Get[context]~}\",Context.Source.Context.Data]"]

                    if ${joDragDrop.Reference(exists)}
                    {
                        System:SetClipboardText["${joDragDrop.AsJSON[multiline]~}"]
                    }                    
                    else
                    {
                        System:SetClipboardText[""]
                    }

                    echo "Copied to clipboard. ${joDragDrop~}"
                }
                break
            case Cut
                break
            case Delete
                {
                    Context.Source.Context.ItemList.ItemsSource:Erase["${Context.Source.Context.Index}"]
                    Context.Source.Context.ItemList:RefreshItems
                }
                break
            case Move Up
                break
            case Move Down
                break
        }
    }

    method OnDragDrop()
    {
        echo "\apcontext:OnDragDrop\ax ${Context.Source} ${Context.Source.ID} ${Context.Args~}"        
        echo "dragdropitem=${LGUI2.DragDropItem~}"

        variable jsonvalueref joDragDrop
        joDragDrop:SetReference["Data.Get[dragDrop,\"${LGUI2.DragDropItem.Get[dragDropItemType]~}\"]"]

        if !${joDragDrop.Reference(exists)}
        {
            echo "dragdrop: ${Name} does not handle ${LGUI2.DragDropItem.Get[dragDropItemType]~}"
            ; we don't handle this drag drop type
            return
        }

        switch ${joDragDrop.Get[type]}
        {
            case copy
                EditingItem:Set["${joDragDrop.Get[outProperty]~}","${LGUI2.DragDropItem.Get[item,"${joDragDrop.Get[inProperty]~}"].AsJSON~}"]
                break
        }
        Context:SetHandled[1]
    }

    member:jsonvalueref GetDragDropItem(string itemType, jsonvalueref joItem)
    {
        variable jsonvalueref joDragDrop="{}"
        joDragDrop:SetByRef["item","joItem"]
        joDragDrop:SetString["profile","${Editor.Editing.Name~}"]

        if ${joItem.Has[name]}
        {
            joDragDrop:SetString["icon","${itemType~}: ${joItem.Get[name]~}"]
        }
        else
        {
            joDragDrop:SetString["icon","${itemType~}"]
        }
        joDragDrop:SetString["dragDropItemType","${itemType~}"]

        return joDragDrop
    }

    method OnSubTreeItemMouse1Press()
    {
        ; handle drag-drop. but only if we're holding shift...
        if !${Context.Args.GetBool[lShift]} && !${Context.Args.GetBool[rShift]}
            return

        echo "\apcontext:OnSubTreeItemMouse1Press\ax ${Context.Source} ${Context.Source.ID} ${Context.Args~} ${Context.Element.Metadata.Get[context]~} ${Context.Source.Item.Data~}"
        variable jsonvalueref joItem
        joItem:SetReference["Context.Source.Item.Data"]
        variable jsonvalueref joDragDrop
        joDragDrop:SetReference["This.GetDragDropItem[\"${Context.Element.Metadata.Get[context]~}\",joItem]"]
        Context.Source:SetDragDropItem[joDragDrop]
    }

    method OnSubTreeItemSelected()
    {
        echo "context:OnSubTreeItemSelected ${Context.Source} ${Context.Source.ID} ${Context.Source.Metadata.Get[context]~}"
        
        ; Context.Source.SelectedItem.Data

        variable string missingEditor
        variable jsonvalueref joData="Context.Source.SelectedItem.Data"
        echo "data=${joData~}"

        variable string useName
        if ${joData.Has[-string,context]}
            useName:Set["${joData.Get[context]~}"]
        else
            useName:Set["${Context.Source.Metadata.Get[context]~}"]
        if !${useName.NotNULLOrEmpty}
        {
            if !${joData.Has[-string,itemName]}
            {
                echo "\arMissing context and itemName\ax in ${Name~}.${Context.Source.Metadata.Get[name]~}"
                missingEditor:Set["Context missing from ${Name~}.${Context.Source.Metadata.Get[name]~}"]
            }
            useName:Set["${Name~}.${joData.Get[itemName]~}"]
        }

        variable weakref useContext        
        useContext:SetReference["Editor.GetContext[\"${useName~}\"]"]
        if ${useContext.Reference(exists)}
        {
;            echo "useContext: ${useContext.Name~}"

            useContext.MissingEditor:Set["${missingEditor~}"]
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


        Context.Source.Locate["",listbox,ancestor]:FireEventHandler[onSubTreeItemSelected,"{\"name\":\"${useName~}\",\"id\":${Context.Source.ID}}"]
        Context.Source.Locate["",listbox,ancestor]:ClearSelection
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

        LGUI2.Skin[default].Template[isb2.editorContexts].Get[contexts]:ForEach["Contexts:Set[\"\${ForEach.Value.Get[name]~}\",This,ForEach.Value]"]
        MainContext:SetReference["Contexts.Get[main]"]
        MainContext.EditingItem:SetReference[Editing]              

        MainContext:Attach[${Window.Locate["editor.container"].ID}]
        This:BuildAutoComplete

        LGUI2.Element[isb2.events]:FireEventHandler[profileEditorOpened]
    }

    method Shutdown()
    {
        Window:Destroy
    }

    method BuildAutoComplete()
    {
        ISB2:BuildAutoComplete[Characters]
        ISB2:BuildAutoComplete[MappableSheets]
        ISB2:BuildAutoComplete[GameKeyBindings]
        ISB2:BuildActionsAutoComplete
        
    }

    method OnWindowClosed()
    {
        ISB2.Editors:Erase["${Editing.Name~}"]
    }

    method OnSaveButton()
    {
        echo "\ayOnSaveButton\ax"
        MainContext:Attach[${Window.Locate["editor.container"].ID}]
        if ${This.Editing:Store(exists)}
        {
            LGUI2.Element[isb2.events]:FireEventHandler[profileSaved]
            echo "\agSaved.\ax"
        }
        else
        {
            echo "\arCould not save.\ax"
        }
    }

    member:weakref GetContext(string name)
    {
        echo "\ayGetContext\ax ${name~}"
        if !${name.NotNULLOrEmpty}
            return NULL

        variable weakref useContext
        useContext:SetReference["Contexts.Get[\"${name~}\"]"]
        if !${useContext.Reference(exists)}
        {
            echo "\atGetContext: Missing/new context\ax ${name~}"
            Contexts:Set["${name~}",This,"{\"name\":\"${name~}\"}"]
            useContext:SetReference["Contexts.Get[\"${name~}\"]"]
        }

        return useContext
    }

    member:string GetLowerCamelCase(string fromString)
    {
        return "${fromString.Lower.Left[1]}${fromString.Right[-1]}"
    }

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
