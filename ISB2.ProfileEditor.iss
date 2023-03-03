
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
    variable bool HasHiddenItems

    variable jsonvalueref HiddenItems="[]"

    method Initialize(weakref _editor, jsonvalueref jo)
    {
;        echo "isb2_profileEditorContext:Initialize ${jo~}"
        Data:SetReference[jo]
        Name:Set["${jo.Get[name]~}"]
        Editor:SetReference[_editor]
    }


    method AddSubItem(jsonvalueref joContainer, jsonvalueref joItem)
    {
;        echo "\ayAddSubItem container\ax=${joContainer~}"
;        echo "\ayAddSubItem item\ax=${joItem~}"
        variable jsonvalueref joSubItem="{}"

        variable jsonvalueref joList

        variable bool hide

        if ${joItem.Has[-object,list]}
        {
            joList:SetReference["joItem.Get[list]"]
            if ${Data.GetBool[hideEmpties]}
            {
                if ${joList.Has[-string,source]}
                {
                    variable jsonvalueref joSource
                    joSource:SetReference["${joList.Get[source]~}"]

                    if !${joSource.Type.Equal[array]} || !${joSource.Used}
                    {
                        hide:Set[1]
                    }
                }
            }

            joSubItem:Merge["LGUI2.Skin[default].Template[isb2.profileEditor.Context.List]"]

            if ${joList.Has[-string,context]}
            {
                joList:SetString["_context","${joList.Get[context]~}"]
                joSubItem:SetString["_context","${joList.Get[context]~}"]
            }

            if ${joList.Has[-string,source]}
            {
                variable jsonvalueref joItemsBinding
                joItemsBinding:SetReference["{}"]
                joItemsBinding:SetString[pullFormat,"\${This.Context.${joList.Get[source]~}}"]
                

                ; pull hook
                joItemsBinding:Set[pullHook,"$$>
                {
                    "elementName":"editor.container",
                    "flags":"ancestor",
                    "event":"Updated ${joItem.Get[name]~}"
                }
                <$$"]

                joList:SetByRef[itemsBinding,joItemsBinding]

;                joList:Set[itemsBinding,"{\"pullFormat\":\"\${This.Context.${joList.Get[source]~}}\"}"]
                joList:SetString["_source","${joList.Get[source]~}"]
                joSubItem:SetString["_source","${joList.Get[source]~}"]
            }

            if ${joList.Has[-string,sourceInit]}
            {
                joList:SetString["_sourceInit","${joList.Get[sourceInit]~}"]
                joSubItem:SetString["_sourceInit","${joList.Get[sourceInit]~}"]
            }

            if ${joList.Has[expanded]}
            {
                joSubItem:SetBool[expanded,${joList.GetBool[expanded]}]
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

        
            if ${hide}
            {
                HiddenItems:AddByRef[joSubItem]
                return
            }


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
;        echo "Attach: ${element} ${element.ID} template=${useTemplate~} ${Data~}"

        if !${element.Element(exists)}
        {
            echo "\arAttach: No element\ax"
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
;            echo "joLeftPane ${joLeftPane~}"
            joLeftPaneContainer:SetReference["joLeftPane.Get[content,children,3,content]"]
            HiddenItems:Clear
            Data.Get[subItems]:ForEach["This:AddSubItem[joLeftPaneContainer,ForEach.Value]"]

            if ${HiddenItems.Used}
            {
                joLeftPane.Get[content,children,2]:SetString[visibility,visible]
            }
            else
                joLeftPane.Get[content,children,2]:SetString[visibility,collapsed]
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
;                if ${useTemplate.NotNULLOrEmpty}
                {
                    MissingEditor:Set["Missing template ${useTemplate~}"]

                    if !${useTemplate.Equal[isb2.mainEditor.General]}
                        LGUI2.Element[isb2.events]:FireEventHandler[onMissingEditor,"{\"name\":\"${useTemplate~}\"}"]
                }
;                else
;                {
;                    MissingEditor:Set["Editor template missing from ${Name~}"]
;                    LGUI2.Element[isb2.events]:FireEventHandler[onMissingEditor,"{\"name\":\"${Name~}\"}"]
;                }
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

        if ${Data.Has[-string,init]}
        {
            execute "This:${Data.Get[init]~}"
        }        

        echo "\aycontextLoaded:${Name~}\ax"
        LGUI2.Element[isb2.events]:FireEventHandler["contextLoaded","{\"type\":\"${Name~}\"}"]
    }

    method OnShowEmpties()
    {
        echo "OnShowEmpties ${Name~} ${Title~}"

        variable lgui2elementref ListBox="${Context.Source.Parent.Locate[editorContext.leftPane.container,listbox,descendant].ID}"
        if !${ListBox.Element(exists)}
            return

        HiddenItems:ForEach["ListBox:InsertItem[ForEach.Value]"]

        HiddenItems:Clear
        Context.Source:SetVisibility[collapsed]
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
            return "{\"type\":\"panel\",\"visibility\":\"collapsed\"}"
;        else
;            return NULL
;            joEditor:SetReference["{\"type\":\"panel\"}"]

        if !${joEditor.Reference(exists)} || !${joEditor.Used}
        {
            joEditor:SetReference["LGUI2.Template[isb2.missingContextEditor]"]
            echo "\armissing editor\ax \"${useTemplate~}\" = ${joEditor~}"
            if ${element.Context.Get[type].NotNULLOrEmpty}
            {
;                MissingEditor:Set["Missing template ${useTemplate~}"]
                LGUI2.Element[isb2.events]:FireEventHandler[onMissingEditor,"{\"name\":\"${useTemplate~}\"}"]
            }
        }

        return joEditor
    }
#endregion

#region Actions
    static member:jsonvalueref GetActionTypeEditor(lgui2elementref element)
    {        
        variable string useTemplate="isb2.actionEditor.${element.Context.Get[type]~}"
        variable jsonvalueref joEditor


        if ${element.Context.Get[type].NotNULLOrEmpty}
        {
            joEditor:SetReference["LGUI2.Skin[default].Template[\"${useTemplate~}\"]"]
;        else
;            return NULL
;            joEditor:SetReference["{\"type\":\"panel\"}"]
            echo "\ayGetActionTypeEditor\ax ${element} ${element.ID} ${element.Context~} ${useTemplate~}=${joEditor~}"


            if !${joEditor.Reference(exists)} || !${joEditor.Used}
            {
                joEditor:SetReference["LGUI2.Template[isb2.missingActionEditor]"]
                echo "\armissing editor\ax \"${useTemplate~}\" = ${joEditor~}"
                joEditor:SetString[_missingEditor,"Missing template ${useTemplate~}"]
                if ${EditingItem.Get[type].NotNULLOrEmpty}
                {
                    LGUI2.Element[isb2.events]:FireEventHandler[onMissingEditor,"{\"name\":\"${useTemplate~}\"}"]

    ;                MissingEditor:Set["Missing template ${useTemplate~}"]
                }
            }
        
        }
        else
             joEditor:SetReference["{\"type\":\"panel\",\"visibility\":\"collapsed\"}"]

        ; now check the action definition...
        variable jsonvalueref joActionType
        joActionType:SetReference["ISB2.GetActionType[\"${element.Context.Get[type]~}\"]"]

        variable jsonvalueref joContainer
        joContainer:SetReference["LGUI2.Skin[default].Template[isb2.actionEditor.container].Duplicate"]

 ;       echo "actionType=${joActionType~}"

        if ${joActionType.GetBool[retarget]}
        {
            joContainer.Get[children]:AddByRef["LGUI2.Skin[default].Template[isb2.actionEditor.targetEditor]"]
        }

        joContainer.Get[children]:AddByRef[joEditor]

        if ${joActionType.GetBool[timer]}
        {
            ; not yet implemented
            joContainer.Get[children]:AddByRef["LGUI2.Skin[default].Template[isb2.actionEditor.timerEditor]"]            
        }        

        joContainer.Get[children]:AddByRef["LGUI2.Skin[default].Template[isb2.actionEditor.variablePropertiesEditor]"]
;        echo "joContainer=${joContainer.AsJSON[multiline]~}"
        return joContainer
    }
    
    static member:jsonvalueref GetActionAutoComplete(string _type, string name, string subList)
    {
        echo "\ayGetActionAutoComplete\ax \"${_type~}\" \"${name~}\" \"${subList~}\""

        variable jsonvalueref joMain="ISB2.FindOne[\"${_type~}\",\"${name~}\"]"
        if !${joMain.Reference(exists)}        
        {
;            echo "${_type~} named ${name~} not found"
            return NULL
        }

;        echo "joMain=${joMain~}"

        variable jsonvalueref ja
        ja:SetReference["joMain.Get[\"${subList~}\"]"]
        if !${ja.Reference(exists)}
        {
;            echo "joMain did not contain ${subList~}"            
            return NULL
        }

;        echo "ja ${ja.Used} ${ja~}"
        variable jsonvalueref jo="{}"

        ja:ForEach["jo:SetByRef[\"\${ForEach.Value.Get[name]}\",ForEach.Value]"]
;        echo "providing dictionary ${jo.Used} ${jo~}"
        return jo
    }

    static method SetObjectEnabled(jsonvalueref jo, string name, bool newState)
    {
        echo SetObjectEnabled ${jo~} ${name~} ${newState~}
        if ${newState}
        {
            ; enable
            if !${jo.Has[-object,"${name~}"]}
                jo:Set["${name~}","{}"]
        }
        else
        {
            ; disable
            jo:Erase["${name~}"]
        }
    }
#endregion

    method UpdateImagePreview()
    {
        echo "\atcontext:UpdateImagePreview\ax ${Context.Element} ${Context.Element.ID}"

        variable jsonvalueref joImageBrush="{}"

        if ${EditingItem.Has[-string,filename]}
        {
            joImageBrush:SetString[imageFile,"${EditingItem.Get[filename]~}"]            
        }

        if ${EditingItem.Has[colorMask]}
        {
            joImageBrush:Set[color,"${EditingItem.Get[colorMask].AsJSON~}"]
        }
        else
            joImageBrush:SetString[color,"#ffffffff"]

        if ${EditingItem.Has[colorKey]}
        {
            joImageBrush:Set[imageFileTransparencyKey,"${EditingItem.Get[colorKey].AsJSON~}"]
        }

        Element.Locate[imageEditor.preview]:SetImageBrush[joImageBrush]
    }

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

                LGUI2.Element[isb2.events]:FireEventHandler[onMissingEditor,"{\"name\":\"${Name~}.${Context.Source.Metadata.Get[name]~}\"}"]
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
                    if !${listElement.ItemsSource(exists)}
                    {
                        echo "listElement.ItemsSource does not exist, trying ${listElement.Metadata.Get[sourceInit]~}"
                        noop ${${listElement.Metadata.Get[sourceInit]}}
                        listElement:PullItemsBinding
                    }

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
                        if !${listElement.ItemsSource(exists)}
                        {
                            noop ${${listElement.Metadata.Get[sourceInit]~}}
                            listElement:PullItemsBinding
                        }

                        listElement.ItemsSource:Add["${jo.Get[item].AsJSON~}"]
                        listElement:RefreshItems
                        listElement:SetItemSelected[${ja.Used},1]
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
        variable uint idx
        switch ${Context.Source.SelectedItem.Data}
        {
            case Copy
                {
                    variable jsonvalueref joDragDrop
                    joDragDrop:SetReference["This.GetDragDropItem[\"${Context.Source.Context.ItemList.Metadata.Get[context]~}\",Context.Source.Context]"]

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
                {
                    idx:Set[${Context.Source.Context.Index}]
                    Context.Source.Context.ItemList.ItemsSource:Swap[${idx},${idx.Dec}]
                }
                break
            case Move Down
                {
                    idx:Set[${Context.Source.Context.Index}]
                    Context.Source.Context.ItemList.ItemsSource:Swap[${idx},${idx.Inc}]
                }
                break
        }
    }

    ; value is already JSON-ified.
    method AddUnique(jsonvalueref ja, string value)
    {
        if ${ja.Contains["${value~}"]}
            return

        ja:Add["${value~}"]
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

        variable jsonvalueref ja

        switch ${joDragDrop.Get[type]}
        {
            case copy
                EditingItem:Set["${joDragDrop.Get[outProperty]~}","${LGUI2.DragDropItem.Get[item,"${joDragDrop.Get[inProperty]~}"].AsJSON~}"]
                break
            case add
                ja:SetReference["EditingItem.Get[-init,\"[]\",\"${joDragDrop.Get[outProperty]~}\"]"]
                if ${joDragDrop.Has[-string,inProperty]}
                    This:AddUnique[ja,"${LGUI2.DragDropItem.Get[item,"${joDragDrop.Get[inProperty]~}"].AsJSON~}"]
                else
                    This:AddUnique[ja,"${LGUI2.DragDropItem.Get[item].AsJSON~}"]
                break
        }

        if ${joDragDrop.Has[subItem]}
        {
;            echo "\arOnDragDrop\ax \ay${joDragDrop.Get[subItem]~}\ax \atcontainer\ax=${Container} ${Container.ID}"

            Element:FireEventHandler["Updated ${joDragDrop.Get[subItem]~}"]
        }

        LGUI2.Element[isb2.events]:FireEventHandler["onDragDropCompleted","{\"type\":\"${LGUI2.DragDropItem.Get[dragDropItemType]~}\"}"]
        Context:SetHandled[1]
    }

    member:jsonvalueref GetDragDropItem(string itemType, weakref listItem)
    {
        echo "GetDragDropItem ${listItem.Data~}"
        variable jsonvalueref joDragDrop="{}"

        switch ${listItem.Data(type)}
        {
            case jsonobject
                if ${joItem.Has[name]}
                {
                    joDragDrop:SetString["icon","${itemType~}: ${joItem.Get[name]~}"]
                }
                else
                {
                    joDragDrop:SetString["icon","${itemType~}"]
                }
                joDragDrop:SetByRef["item","listItem.Data"]
                break
            case jsonarray
                joDragDrop:SetString["icon","${itemType~}"]
                joDragDrop:SetByRef["item","listItem.Data"]
                break
            default
                joDragDrop:Set["item","${listItem.Data.AsJSON~}"]
                joDragDrop:SetString["icon","${itemType~}: ${listItem.Data~}"]
                break
        }
        joDragDrop:SetString["profile","${Editor.Editing.Name~}"]

        joDragDrop:SetString["dragDropItemType","${itemType~}"]

        return joDragDrop
    }

    method OnSubTreeItemMouse1Press()
    {
        ; handle drag-drop. but only if we're holding shift...
        if !${Context.Args.GetBool[lShift]} && !${Context.Args.GetBool[rShift]}
            return

        echo "\apcontext:OnSubTreeItemMouse1Press\ax ${Context.Source} ${Context.Source.ID} ${Context.Args~} ${Context.Element.Metadata.Get[context]~} ${Context.Source.Item.Data~}"
        variable jsonvalueref joDragDrop
        joDragDrop:SetReference["This.GetDragDropItem[\"${Context.Element.Metadata.Get[context]~}\",Context.Source.Item]"]
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
                LGUI2.Element[isb2.events]:FireEventHandler[onMissingEditor,"{\"name\":\"${Name~}.${Context.Source.Metadata.Get[name]~}\"}"]
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


objectdef(global) isb2_profileeditor inherits isb2_building
{
    variable weakref Editing
    variable weakref MainContext
    variable collection:isb2_profileEditorContext Contexts

    method Init(weakref _profile, lgui2elementref _container)
    {
        Editing:SetReference[_profile]
        LGUI2:PushSkin["${ISB2.UseSkin~}"]
        Window:Set["${LGUI2.LoadReference["LGUI2.Template[isb2.profileEditor]",This].ID}"]
        LGUI2:PopSkin["${ISB2.UseSkin~}"]

        This:RefreshBuilderPresets

        LGUI2.Skin[default].Template[isb2.editorContexts].Get[contexts]:ForEach["Contexts:Set[\"\${ForEach.Value.Get[name]~}\",This,ForEach.Value]"]
        MainContext:SetReference["Contexts.Get[main]"]
        MainContext.EditingItem:SetReference[Editing]              

        MainContext:Attach[${_container.ID}]
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



    static method AddScreen(jsonvalueref ja, jsonvalueref joMonitor)
    {
        variable jsonvalue jo="{}"
        
        jo:SetString["itemType","screen"]
        jo:SetString["name","${joMonitor.Get[name]~}"]
        jo:SetInteger["left",${joMonitor.GetInteger[left]}]
        jo:SetInteger["top",${joMonitor.GetInteger[top]}]
        jo:SetInteger["width",${joMonitor.GetInteger[width]}]
        jo:SetInteger["height",${joMonitor.GetInteger[height]}]

        ja:AddByRef[jo]
    }

    static method AddRegion(jsonvalueref ja, uint numRegion, jsonvalueref joRegion)
    {
        variable jsonvalueref jo="joRegion.Duplicate"

        if ${joRegion.Has[numLayout]}
        {
            jo:SetString["itemType","region${joRegion.GetInteger[numLayout]}"]
        }
        else
        {
            jo:SetString["itemType","region"]
        }

        jo:SetInteger["x",${joRegion.GetInteger[bounds,1]}]
        jo:SetInteger["y",${joRegion.GetInteger[bounds,2]}]
        jo:SetInteger["width",${joRegion.GetInteger[bounds,3]}]
        jo:SetInteger["height",${joRegion.GetInteger[bounds,4]}]
        jo:SetInteger["numRegion",${numRegion}]

        ja:AddByRef[jo]
    }    

    static member:jsonvalue GetLayoutPreviewExtents(jsonvalueref joLayout)
    {
        variable int left
        variable int right
        variable int top
        variable int bottom

        variable uint numMonitor

        variable uint numMonitors

        numMonitors:Set[${joLayout.Get[inputData,monitors].Used}]

        variable jsonvalueref jaMonitors

        variable jsonvalueref joMonitor
        if ${numMonitors}
        {
            jaMonitors:SetReference["joLayout.Get[inputData,monitors]"]
        }
        else
        {
            jaMonitors:SetReference["monitor.List"]
            numMonitors:Set["${jaMonitors.Used}"]
        }

        for (numMonitor:Set[1] ; ${numMonitor}<=${numMonitors} ; numMonitor:Inc)
        {
            joMonitor:SetReference["jaMonitors.Get[${numMonitor}]"]
            if !${joMonitor.Reference(exists)}
                break

            if ${joMonitor.GetInteger[left]}<${left}
                left:Set["${joMonitor.GetInteger[left]}"]
            if ${joMonitor.GetInteger[top]}<${top}
                top:Set["${joMonitor.GetInteger[top]}"]

            if ${joMonitor.GetInteger[right]}>${right}
                right:Set["${joMonitor.GetInteger[right]}"]
            if ${joMonitor.GetInteger[bottom]}>${bottom}
                bottom:Set["${joMonitor.GetInteger[bottom]}"]
        }

        echo GetLayoutPreviewExtents "[${left},${top},${right.Dec[${left}]},${bottom.Dec[${top}]}]"
        return "[${left},${top},${right.Dec[${left}]},${bottom.Dec[${top}]}]"
    }

    static member:jsonvalueref GetLayoutPreviewItems(lgui2elementref element)
    {
        variable jsonvalue ja="[]"

        echo "\ayGetLayoutPreviewItems\ax: element=${element.ID} context=${element.Context~}"
        variable jsonvalueref joLayout
        joLayout:SetReference[element.Context]
        if !${joLayout.Reference(exists)}
        {
;            echo "\ayGetLayoutPreviewItems\ax: NULL"
            return NULL
        }

;        echo GetLayoutPreviewItems element=${element}
        if ${element.Element(exists)}
        {
            variable jsonvalue jaExtents
            jaExtents:SetValue["${This.GetLayoutPreviewExtents[joLayout]}"]

            element:SetVirtualOrigin[${jaExtents.GetInteger[1]},${jaExtents.GetInteger[2]}]
            element:SetVirtualSize[${jaExtents.GetInteger[3]},${jaExtents.GetInteger[4]}]
        }

        if ${joLayout.Has[inputData,monitors]}
        {
        ; screens
            joLayout.Get[inputData,monitors]:ForEach["This:AddScreen[ja,ForEach.Value]"]
        }
        else
        {
            monitor.List:ForEach["This:AddScreen[ja,ForEach.Value]"]
        }

        ; regions
        joLayout.Get[regions]:ForEach["This:AddRegion[ja,\${ForEach.Key},ForEach.Value]"]

        echo "\ayGetLayoutPreviewItems\ax: ${ja~}"
        return ja
    }   
}

objectdef isb2_profileeditorWindow
{
    variable weakref Editing
    variable lgui2elementref Window

    variable isb2_profileeditor TopEditor
    variable isb2_profileeditor BottomEditor
    variable bool SplitEditor

    method Initialize(weakref _profile)
    {
        echo "isb2_profileeditorWindow:Initialize"
        Editing:SetReference[_profile]
        LGUI2:PushSkin["${ISB2.UseSkin~}"]
        Window:Set["${LGUI2.LoadReference["LGUI2.Template[isb2.profileEditor]",This].ID}"]
        LGUI2:PopSkin["${ISB2.UseSkin~}"]

        ISB2:BuildStandardAutoComplete
        
        TopEditor:Init[Editing,"${Window.Locate["editor.container"].ID}"]
        BottomEditor:Init[Editing,"${Window.Locate["editor.bottomContainer"].ID}"]
        This:SetSplitEditor[0]
/*
        LGUI2.Skin[default].Template[isb2.editorContexts].Get[contexts]:ForEach["Contexts:Set[\"\${ForEach.Value.Get[name]~}\",This,ForEach.Value]"]
        MainContext:SetReference["Contexts.Get[main]"]
        MainContext.EditingItem:SetReference[Editing]              

        MainContext:Attach[${Window.Locate["editor.container"].ID}]
*/
        LGUI2.Element[isb2.events]:FireEventHandler[profileEditorOpened]
    }

    method Shutdown()
    {
        Window:Destroy
    }

    method SetSplitEditor(bool newValue)
    {
        SplitEditor:Set[${newValue}]
        if ${newValue}
            Window.Locate["editor.bottompane"]:SetVisibility[Visible]
        else
            Window.Locate["editor.bottompane"]:SetVisibility[Collapsed]

        LGUI2.Element[isb2.events]:FireEventHandler[onSplitEditorChanged,"{\"value\":${newValue.AsJSON~}}"]
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

}
