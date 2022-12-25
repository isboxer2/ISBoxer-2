objectdef isb2_profileeditor
{
    variable weakref Editing
    variable weakref EditingItem
    variable lgui2elementref Window

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

        variable jsonvalueref joEditor
        joEditor:SetReference["LGUI2.Template[isb2.${This.GetLowerCamelCase["${editingType~}"]}Editor]"]
        if !${joEditor.Reference(exists)}
            joEditor:SetReference["LGUI2.Template[isb2.missingEditor]"]

        if ${joEditor.Reference(exists)}
            Window.Locate["profile.editorContainer"]:SetChild["joEditor","EditingItem"]        
        else
            Window.Locate["profile.editorContainer"]:ClearChildren
    }

    method OnLeftPaneSelection(string itemType)
    {
        This:ResetSelections["${itemType~}"]
        This:SetEditingItem["${itemType~}",${Context.Source.SelectedItem.Index}]
    }

    method OnCharacterSelected()
    {
        This:ResetSelections[Character]
        This:SetEditingItem[Character,${Context.Source.SelectedItem.Index}]
    }

    method OnHotkeySheetSelected()
    {
        This:ResetSelections[HotkeySheet]
        This:SetEditingItem[HotkeySheet,${Context.Source.SelectedItem.Index}]
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
