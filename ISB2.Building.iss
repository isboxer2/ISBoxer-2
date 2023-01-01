; For configuring builders
objectdef isb2_building
{
    variable jsonvalueref Builders="[]"
    variable jsonvalueref BuilderGroups="[]"
    variable jsonvalueref BuilderPresets="[]"

    method Initialize()
    {

    }

    method Shutdown()
    {

    }

    method PrepareBuilderHotkeyByName(jsonvalueref jo, jsonvalueref joHotkeyBuilder, string sheet, string name)
    {
        variable jsonvalueref joSheet
        joSheet:SetReference["ISB2.FindOne[HotkeySheets,\"${sheet~}\",\"${jo.Get[profile]~}\"]"]
        if !${joSheet.Reference(exists)}
        {
            echo "PrepareBuilderHotkey: sheet ${sheet~} not found"
            return
        }

        variable jsonvalueref joHotkey
        joHotkey:SetReference["ISB2.FindInArray[\"joSheet.Get[hotkeys]\",\"${name~}\"]"]
        if !${joHotkey.Reference(exists)}
        {
            echo "PrepareBuilderHotkey: hotkey ${name~} not found in sheet ${joSheet.Get[hotkeys]~}"
            return
        }

        if !${joHotkeyBuilder.Has[-string,keyCombo]}
        {
            if ${joHotkey.Has[-string,keyCombo]}
                joHotkeyBuilder:SetString[keyCombo,"${joHotkey.Get[keyCombo]~}"]        
        }
        if !${jo.Get[builder].Has[-array,expandedHotkeys]}
            jo.Get[builder]:Set[expandedHotkeys,"[]"]

        joHotkeyBuilder:SetString[sheet,"${sheet~}"]
        joHotkeyBuilder:SetString[name,"${name~}"]

        jo.Get[builder,expandedHotkeys]:AddByRef[joHotkeyBuilder]
    }
    
    method PrepareBuilderHotkey(jsonvalueref jo, jsonvalueref joHotkeyBuilder)
    {
        variable string sheet="${joHotkeyBuilder.Get[sheet]~}"
        variable string name="${joHotkeyBuilder.Get[name]~}"

        if ${sheet.Find["{"]} || ${name.Find["{"]}
        {
            ; expand per character...
            variable uint i

            for (i:Set[1] ; ${i}<=${Characters.Used} ; i:Inc)
            {
                sheet:Set["${sheet.ReplaceSubstring["{SLOT}",${i}]~}"]
                name:Set["${name.ReplaceSubstring["{SLOT}",${i}]~}"]
                sheet:Set["${sheet.ReplaceSubstring["{CHARACTER}","${Characters.Get[${i},name]~}"]~}"]
                name:Set["${name.ReplaceSubstring["{CHARACTER}","${Characters.Get[${i},name]~}"]~}"]

                This:PrepareBuilderHotkeyByName[jo,joHotkeyBuilder.Duplicate,"${sheet~}","${name~}"]

                sheet:Set["${joHotkeyBuilder.Get[sheet]~}"]
                name:Set["${joHotkeyBuilder.Get[name]~}"]
            }
        }
        else
            This:PrepareBuilderHotkeyByName[jo,joHotkeyBuilder,"${sheet~}","${name~}"]
    } 

    method PrepareBuilderGameKeyBindingByName(jsonvalueref jo, jsonvalueref joGameKeyBindingBuilder, string name)
    {
        variable jsonvalueref joGameKeyBinding
        joGameKeyBinding:SetReference["ISB2.FindOne[GameKeyBindings,\"${name~}\",\"${jo.Get[profile]~}\"]"]
        if !${joGameKeyBinding.Reference(exists)}
        {
;            echo "PrepareBuilderGameKeyBinding: game key binding ${name~} not found, and I'm okay with that"
;            return
        }

        if ${joGameKeyBinding.Has[-string,keyCombo]}
            joGameKeyBindingBuilder:SetString[keyCombo,"${joGameKeyBinding.Get[keyCombo]~}"]        

        if !${jo.Has[-array,builder,expandedGameKeyBindings]}
            jo.Get[builder]:Set[expandedGameKeyBindings,"[]"]

        joGameKeyBindingBuilder:SetString[name,"${name~}"]

        jo.Get[builder,expandedGameKeyBindings]:AddByRef[joGameKeyBindingBuilder]
    }

    method PrepareBuilderGameKeyBinding(jsonvalueref jo, jsonvalueref joGameKeyBindingBuilder)
    {
        variable string name="${joGameKeyBindingBuilder.Get[name]~}"

        if ${name.Find["{"]}
        {
            ; expand per character...
            variable uint i

            for (i:Set[1] ; ${i}<=${Characters.Used} ; i:Inc)
            {
                name:Set["${name.ReplaceSubstring["{SLOT}",${i}]~}"]
                name:Set["${name.ReplaceSubstring["{CHARACTER}","${Characters.Get[${i},name]~}"]~}"]

                This:PrepareBuilderGameKeyBindingByName[jo,joGameKeyBindingBuilder.Duplicate,"${name~}"]

                name:Set["${joGameKeyBindingBuilder.Get[name]~}"]
            }
        }
        else
            This:PrepareBuilderGameKeyBindingByName[jo,joGameKeyBindingBuilder,"${name~}"]
    } 

    member:bool CheckGameName(jsonvalueref joGame, string name)
    {
        if ${joGame.Get[name]~.Equal["${name~}"]}
            return TRUE
        if ${joGame.Get[shortName]~.Equal["${name~}"]}
            return TRUE
        return FALSE
    }

    member:bool ShouldShowBuilder(jsonvalueref joBuilder)
    {        
        switch ${joBuilder.GetType[game]}
        {
            case string
                {
                    if !${This.CheckGameName[SelectedGame,"${joBuilder.Get[game]~}"]}
                    {
                        return FALSE
                    }
                }
                break
            case array
                break
        }

        switch ${joBuilder.GetType[notGame]}
        {
            case string
                {
                    if ${This.CheckGameName[SelectedGame,"${joBuilder.Get[notGame]~}"]}
                    {
                        return FALSE
                    }
                }
                break
            case array
                break
        }        

        switch ${joBuilder.GetType[genre]}
        {
            case string
            {
                if ${SelectedGame.Has[-string,genre]}
                {
                    if !${joBuilder.Get[genre]~.Equal["${SelectedGame.Get[genre]~}"]}
                    {
                        return FALSE
                    }
                }
            }
                break
            case array
                break
        }

        switch ${joBuilder.GetType[notGenre]}
        {
            case string
            {
                if ${SelectedGame.Has[-string,notGenre]}
                {
                    if ${joBuilder.Get[genre]~.Equal["${SelectedGame.Get[notGenre]~}"]}
                    {
                        return FALSE
                    }
                }
            }
                break
            case array
                break
        }        
        
        return TRUE
    }    

    member:jsonvalueref GetBuilderGroup(string name, bool autoCreate)
    {
        variable jsonvalueref joGroup="ISB2.FindInArray[BuilderGroups,\"${name~}\"]"

        if !${joGroup.Reference(exists)}
        {
            if !${autoCreate}
                return NULL

            joGroup:SetReference["{}"]
            joGroup:SetString[name,"${name~}"]
            joGroup:Set[builders,"[]"]
            BuilderGroups:AddByRef[joGroup]
        }

        return joGroup
    }

    method SetElementVisibility(lgui2elementref element, bool newValue)
    {
        echo "SetElementVisibility ${element.ID} ${newValue}"
        if ${newValue}
            element:SetVisibility[visible]
        else
            element:SetVisibility[collapsed]
    }

    method OnBuilderViewCreated()
    {
        echo "\ayOnBuilderViewCreated\ax ${Context(type)} ${Context.Source(type)} ${Context.Source.ID} ${Context.Source.Context~}"

        variable jsonvalueref jo
    
        if ${Context.Source.Context(type)~.Equal[lgui2item]}
            jo:SetReference["Context.Source.Context.Data"]
        else
            jo:SetReference["Context.Source.Context"]
            
        This:SetElementVisibility["${Context.Source.Locate["builderView.Hotkeys","",descendant].ID}",${jo.Get[builder,expandedHotkeys].Used}]
        This:SetElementVisibility["${Context.Source.Locate["builderView.GameKeyBindings","",descendant].ID}",${jo.Get[builder,expandedGameKeyBindings].Used}]
    }

    member:jsonvalueref GetSelectedBuilderView(lgui2elementref someElement)
    {
        echo "\ayGetSelectedBuilderView\ax ${someElement.ID} context=${someElement.Context(type)}"

;        echo "Located=${someElement.Parent.Locate["builderGroup.BuilderList","",descendant].ID}"

        variable jsonvalueref joBuilder="someElement.Parent.Locate["builderGroup.BuilderList","",descendant].SelectedItem.Data"


        variable jsonvalueref joView="{}"
        if !${joBuilder.Reference(exists)}
        {
            joView:SetString[type,panel]
;            joView:SetString[text,"Dynamic content here"]
        }
        else
        {
            joView:SetString[jsonTemplate,isb2.QuickSetup.builderView]
            joView:SetString[horizontalAlignment,stretch]
            someElement:SetContext[joBuilder]
          ;  joView:Set[contextBinding,"{\"pullFormat\":\"\${This.Parent.Locate[builderGroup.BuilderList,\"\",descendant].SelectedItem.Data}\"}"]
        }

        return joView
    }

    method AddToBuilderGroup(string name, jsonvalueref joEntry)
    {
        variable jsonvalueref joGroup="This.GetBuilderGroup[\"${name~}\",1]"
        if !${joGroup.Reference(exists)}
            return FALSE

        joGroup.Get[builders]:AddByRef[joEntry]

        return TRUE
    }

    method AddLocatedBuilder(jsonvalueref joLocated)
    {
        variable jsonvalue jo="{}"
        variable jsonvalueref joBuilder="joLocated.Get[object]"

        if !${This.ShouldShowBuilder[joBuilder]}
            return FALSE

        ; grab pre-set
        variable jsonvalueref joPreset
        joPreset:SetReference["ISB2.FindInArray[\"SelectedBuilderPreset.Get[builders]\",\"${joBuilder.Get[name]~}\"]"]

        if ${joPreset.Reference(exists)}
            jo:SetBool[enable,${joPreset.GetBool[enable]}]
        else
            jo:SetBool[enable,${joBuilder.GetBool[enable]}]

        jo:SetString[profile,"${joLocated.Get[profile]~}"]
        jo:SetString[name,"${joBuilder.Get[name]~}"]

        if !${joBuilder.Has[-object,original]}
            joBuilder:SetByRef[original,joBuilder.Duplicate]

        if ${joPreset.Has[-object,overrides]}
        {
            joBuilder:Merge["joPreset.Get[overrides]",1]
            echo "\atBuilder after merged overrides\ax: ${joBuilder~}"
        }

        jo:SetByRef[builder,joBuilder]

        ; get initial hotkeys
        joBuilder.Get[hotkeys]:ForEach["This:PrepareBuilderHotkey[jo,ForEach.Value]"]
        joBuilder.Get[gameKeyBindings]:ForEach["This:PrepareBuilderGameKeyBinding[jo,ForEach.Value]"]

            echo "\apBuilder after hotkeys and gameKeyBindings\ax: ${joBuilder~}"

        if ${joBuilder.Has[-string,"builderGroup"]}
            This:AddToBuilderGroup["${joBuilder.Get[builderGroup]~}",jo]
        else
            Builders:AddByRef[jo]

        return TRUE
    }

    method MoveSingleBuilders(jsonvalueref joBuilderGroup, jsonvalueref ja, int key)
    {
        if ${joBuilderGroup.Get[builders].Used}==1
        {
            Builders:AddByRef["joBuilderGroup.Get[builders,1]"]
            joBuilderGroup.Get[builders]:Clear

            ja:AddInteger[${key}]
        }
    }

    method OnBuilderGroupSelectionChanged()
    {
        variable jsonvalueref joBuilderGroup="Context.Source.Context.Data"
        if !${joBuilderGroup.Reference(exists)}
            return
        echo "\ayOnBuilderGroupSelectionChanged\ax ${Context.Source(type)} ${Context.Source.ID} ${Context.Source.Context(type)}"

        joBuilderGroup.Get[builders,"${joBuilderGroup.GetInteger[selectedBuilder]}"]:SetBool[enable,0]

        ; located builders...
        if !${Context.Source.SelectedItem(exists)}
        {
            joBuilderGroup:Erase[selectedBuilder]
            return
        }

        joBuilderGroup:SetInteger["selectedBuilder",${Context.Source.SelectedItem.Index}]
        joBuilderGroup.Get[builders,"${Context.Source.SelectedItem.Index}"]:SetBool[enable,1]
    }

    method AddBuilderPreset(jsonvalueref joPreset)
    {
        ; todo: filter out presets for other games, genres
        BuilderPresets:AddByRef[joPreset]
    }

    method RefreshBuilderPresets()
    {
        echo "\ayRefreshBuilderPresets\ax"
        BuilderPresets:Clear
        ISB2.Settings.Get[builderPresets]:ForEach["This:AddBuilderPreset[ForEach.Value]"]
    }

    method AutoSelectBuilder(jsonvalueref joBuilderInstance)
    {
        variable jsonvalueref joBuilder="ISB2.FindOne[Builders,\"${joBuilderInstance.Get[name]~}\",\"${joBuilderInstance.Get[profile]~}\"]"
        echo "\arAutoSelectBuilder\ax ${joBuilderInstance~} ${joBuilder~}"
        if !${joBuilder.Has[-string,builderGroup]}
            return FALSE

        variable jsonvalueref joBuilderGroup
        joBuilderGroup:SetReference["ISB2.FindInArray[BuilderGroups,\"${joBuilder.Get[builderGroup]~}\"]"]
        if !${joBuilderGroup.Reference(exists)}
        {
            echo "AutoSelectBuilder: Group ${joBuilder.Get[builderGroup]~} not found"
            return FALSE
        }

        variable int64 numBuilder
        numBuilder:Set[${ISB2.FindKeyInArray["joBuilderGroup.Get[builders]","${joBuilder.Get[name]~}"]}]
        if !${numBuilder}
        {
            echo "AutoSelectBuilder: Builder ${joBuilder.Get[name]~} not found in ${joBuilderGroup~}"
            return FALSE
        }

        joBuilderGroup:SetInteger["selectedBuilder",${numBuilder}]
        echo "AutoSelectBuilder: ${numBuilder}"
    }

    method RefreshBuilders()
    {            
        echo "\ayRefreshBuilders\ax"
        variable jsonvalueref ja="[]"        
        Builders:Clear
        BuilderGroups:Clear

        ISB2.LocateAll[Builders]:ForEach["This:AddLocatedBuilder[ForEach.Value]"]
        
        BuilderGroups:ForEach["This:MoveSingleBuilders[ForEach.Value,ja,\${ForEach.Key~}]"]
        ja:Reverse
        ja:ForEach["BuilderGroups:Erase[\"\${ForEach.Value~}\"]"]

        SelectedBuilderPreset.Get[builders]:ForEach["This:AutoSelectBuilder[ForEach.Value]"]

        LGUI2.Element[isb2.QuickSetupWindow]:FireEventHandler[onBuildersUpdated]
    }


    method OnSavePreset()
    {
        variable string name=${LGUI2.Element["isb2.QuickSetup.PresetName"].Text~}
        variable jsonvalueref jo
        variable bool existing
        if !${name.NotNULLOrEmpty}
        {
            LGUI2.Element["isb2.QuickSetup.PresetName"]:KeyboardFocus
            return FALSE
        }

        jo:SetReference["ISB2.FindInArray[\"ISB2.Settings.Get[builderPresets]\",\"${name~}\"]"]
        if ${jo.Reference(exists)}
            existing:Set[1]
        else
        {
            jo:SetReference["{}"]    
            jo:SetString[name,"${name~}"]
        }

        if ${LGUI2.Element["isb2.QuickSetup.PresetName"].Text.NotNULLOrEmpty}
            jo:SetString[description,"${LGUI2.Element["isb2.QuickSetup.PresetDescription"].Text~}"]
        else
            jo:Erase[description]

        if ${LGUI2.Element["isb2.QuickSetup.PresetRestrictToGame"].Checked}
            jo:SetString[game,"${GameName~}"]
        else
            jo:Erase[game]

        if ${SelectedGame.Has[-string,genre]} && ${LGUI2.Element["isb2.QuickSetup.PresetRestrictToGenre"].Checked}
            jo:SetString[genre,"${SelectedGame.Get[genre]~}"]
        else
            jo:Erase[genre]

        jo:SetByRef[builders,This.GetAppliedBuilders]

        if !${existing}
        {
            if !${ISB2.Settings.Has[-array,builderPresets]}
                ISB2.Settings:Set[builderPresets,"[]"]
            ISB2.Settings.Get[builderPresets]:AddByRef[jo]
        }

        ISB2:AutoStoreSettings
        This:RefreshBuilderPresets
    }

    member:jsonvalueref GetBuilderDiff(jsonvalueref joBuilder)
    {
        variable jsonvalueref joOriginal="joBuilder.Get[original]"
        if !${joOriginal.Reference(exists)}
            return NULL

        joBuilder:Erase[original]

        variable jsonvalueref joDiff

        echo "\ayGetBuilderDiff\ax ${joOriginal~} => ${joBuilder~}"
        joDiff:SetReference["joOriginal.Diff[joBuilder]"]        
        if ${joDiff.Has[-array,expandedHotkeys]} 
        {
            joDiff:Erase[hotkeys]              
            joDiff:SetByRef[hotkeys,"joDiff.Get[expandedHotkeys]"]
        }

        joDiff:Erase[expandedHotkeys]

        joBuilder:SetByRef[original,joOriginal]

        echo "diff = ${joDiff~}"
        return joDiff
    }

    method ApplyBuilder(jsonvalueref ja, jsonvalueref joLocatedBuilder)
    {
        if !${joLocatedBuilder.GetBool[enable]}
            return FALSE

        echo "\arApplyBuilder:\ax ${joLocatedBuilder~}"

        variable jsonvalueref joBuilder
        joBuilder:SetReference["joLocatedBuilder.Get[builder]"]
    
        variable jsonvalueref joBuilderConfig
        joBuilderConfig:SetReference["{}"]

        joBuilderConfig:SetString[profile,"${joLocatedBuilder.Get[profile]~}"]
        joBuilderConfig:SetString[name,"${joBuilder.Get[name]~}"]
        joBuilderConfig:SetBool[enable,1]
        joBuilderConfig:SetByRef[overrides,"This.GetBuilderDiff[joBuilder]"]
    
        ja:AddByRef[joBuilderConfig]
        return TRUE
    }

    method ApplyBuilderGroup(jsonvalueref ja, jsonvalueref joBuilderGroup)
    {
        variable jsonvalueref joLocatedBuilder="joBuilderGroup.Get[builders,${joBuilderGroup.GetInteger[selectedBuilder]}]"
        if !${joLocatedBuilder.Reference(exists)}
            return

        This:ApplyBuilder[ja,joLocatedBuilder]        
    }

    method ApplyBuilders(jsonvalueref joProfile)
    {
        variable jsonvalueref ja="[]"

        BuilderGroups:ForEach["This:ApplyBuilderGroup[ja,ForEach.Value]"]      
        Builders:ForEach["This:ApplyBuilder[ja,ForEach.Value]"]

        if ${ja.Used}
            joProfile.Get[teams,1]:SetByRef[builders,ja]
    }

    member:jsonvalueref GetAppliedBuilders()
    {
        variable jsonvalueref ja="[]"
        BuilderGroups:ForEach["This:ApplyBuilderGroup[ja,ForEach.Value]"]      
        Builders:ForEach["This:ApplyBuilder[ja,ForEach.Value]"]
        return ja
    }

}
