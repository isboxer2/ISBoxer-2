objectdef isb2_profileeditor inherits isb2_building
{
    variable weakref Editing
    variable weakref EditingItem
    variable lgui2elementref Window
    
    variable uint SubPage
    variable string EditingType

    method Initialize(weakref _profile)
    {
        Editing:SetReference[_profile]
        LGUI2:PushSkin["${ISB2.UseSkin~}"]
        Window:Set["${LGUI2.LoadReference["LGUI2.Template[isb2.profileEditor]",This].ID}"]
        LGUI2:PopSkin["${ISB2.UseSkin~}"]
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

    method OnSubPageSelected()
    {
;        echo "OnSubPageSelected ${Context(type)} ${Context.Source} ${Context.Source.SelectedItem(type)} ${Context.Source.SelectedItem.Data}" 

        variable jsonvalueref joData="Context.Source.SelectedItem.Data"


        variable jsonvalueref joEditor
        if ${joData.Reference(exists)}
            joEditor:SetReference["LGUI2.Template[\"${joData.Get[template]~}\"]"]

        if !${joEditor.Reference(exists)}
            joEditor:SetReference["LGUI2.Template[isb2.missingEditor]"]

        if ${joEditor.Reference(exists)}
            Window.Locate["profile.editorContainer"]:SetChild["joEditor"]        
        else
            Window.Locate["profile.editorContainer"]:ClearChildren        
    }
}
