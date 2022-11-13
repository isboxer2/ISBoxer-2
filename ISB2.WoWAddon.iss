
objectdef isb2_wowaddon
{
    ; e.g. "C:/Program Files (x86)/World of Warcraft/_classic_"
    variable filepath GameFolder
    variable filepath AddonFolder

    method Initialize()
    {
        GameFolder:Set["${LavishScript.Executable.PathOnly~}"]
        AddonFolder:Set["${GameFolder~}/Interface/Addons/ISBoxer_2"]
    }

    method MakeAddonFolder()
    {
        if !${AddonFolder.PathExists}
        {
            mkdir "${AddonFolder~}"
        }
    }

    member:uint GetInterfaceVersion()
    {
        ; _classic_
        return 20501
    }

    method WriteTOC()
    {
        variable file out_file="${AddonFolder~}/ISBoxer_2.toc"
        This:MakeAddonFolder
        if !${out_file:Open(exists)}
        {
            Script:SetLastError["isb2_wowaddon:WriteTOC: Failed to open file ${out_file~} for writing"]
            return FALSE
        }
        out_file:Write["## Interface: ${This.GetInterfaceVersion~}\n"]
        out_file:Write["## Title: ISBoxer 2\n"]
        out_file:Write["## Author: Joe Thaler\n"]
        out_file:Write["## Version: ${agent.Get[ISBoxer 2].Version~}\n"]
        out_file:Write["## eMail: lax@lavishsoft.com\n"]
        out_file:Write["## URL: https://isboxer.com\n"]
        out_file:Write["## DefaultState: Enabled\n"]
        out_file:Write["## LoadOnDemand: 0\n"]
        out_file:Write["ISBoxer_2.lua\n"]
        out_file:Write["ISBoxer_2_Team.lua\n"]
        out_file:Write["ISBoxer_2_Character.lua\n"]
        out_file:Truncate:Close

        return TRUE
    }

    method WriteGenericTeamFile()
    {
        variable file out_file="${AddonFolder~}/ISBoxer_2_Team.lua"
        This:MakeAddonFolder
        if !${out_file:Open(exists)}
        {
            Script:SetLastError["isb2_wowaddon:WriteGenericTeamFile: Failed to open file ${out_file~} for writing"]
            return FALSE
        }

        out_file:Write["-- This file will be loaded if no ISBoxer 2 Team is active.\n"]
        out_file:Write["-- Otherwise, a Team-specific file will be used in place of this, via Virtual Files\n"]     
        out_file:Write["isboxer2.Output("No Team activated.");\n"]
        out_file:Truncate:Close
        return TRUE
    }

    method WriteGenericCharacterFile()
    {
        variable file out_file="${AddonFolder~}/ISBoxer_2_Character.lua"
        This:MakeAddonFolder
        if !${out_file:Open(exists)}
        {
            Script:SetLastError["isb2_wowaddon:WriteGenericCharacterFile: Failed to open file ${out_file~} for writing"]
            return FALSE
        }

        out_file:Write["-- This file will be loaded if no ISBoxer 2 Character is active.\n"]
        out_file:Write["-- Otherwise, a Character-specific file will be used in place of this, via Virtual Files\n"]     
        out_file:Write["isboxer2.Output("No Character activated.");\n"]
        out_file:Truncate:Close
        return TRUE
    }

    method WriteMainLuaFile()
    {
        ; ISBoxer_2.lua
        variable filepath inFile="${agent.Get[ISBoxer 2].Directory~}/Games/WoW/ISBoxer_2.lua"
        variable filepath outFile="${AddonFolder~}/ISBoxer_2.lua"

        if !${inFile.PathExists}
            return FALSE

        cp -overwrite "${inFile~}" "${outFile~}"
        return TRUE
    }

    member:string Sanitize(string val)
    {
        return ${val.Replace[" ","_",":","_","/","_","\\","_","?","_","*","_"]~}
    }

    method WriteActiveTeamFile()
    {
        ; ISBoxer_2.lua
        variable file out_file="${AddonFolder~}/ISBoxer_2_Team-${This.Sanitize["${ISB2.Team.Get[name]~}"]}.lua"
        This:MakeAddonFolder
        if !${out_file:Open(exists)}
        {
            Script:SetLastError["isb2_wowaddon:WriteMainLuaFile: Failed to open file ${out_file~} for writing"]
            return FALSE
        }

        out_file:Write["-- This file should be team-specific for ${ISB2.Team.Get[name]~}\n"]

        out_file:Write["isboxer2.Team.Name = "${ISB2.Team.Get[name]~}";\n"]
        out_file:Write["isboxer2.Output(\"Team '${ISB2.Team.Get[name]~}' activated\");"]


        out_file:Truncate:Close
        return TRUE
    }

    member:jsonvalueref GetGameMacroSheets()
    {
        variable set Sheets
        ISB2.Character.Get[gameMacroSheets]:ForEach["Sheets:Add[\"\${ForEach.Value~}\"]"]
        ISB2.Team.Get[gameMacroSheets]:ForEach["Sheets:Add[\"\${ForEach.Value~}\"]"]

        return "${Sheets.AsJSON~}"
    }

    member:string GetWoWCombo(string keyCombo)
    {
        if !${keyCombo.NotNULLOrEmpty}
            return "NONE"

        if ${keyCombo.Find["Shift+"]}
        {
            keyCombo:Set["${keyCombo.ReplaceSubstring["Shift+",""]}"]
            keyCombo:Prepend[Shift-]
        }
        if ${keyCombo.Find["Ctrl+"]}
        {
            keyCombo:Set["${keyCombo.ReplaceSubstring["Ctrl+",""]}"]
            keyCombo:Prepend[Ctrl-]
        }
        if ${keyCombo.Find["Alt+"]}
        {
            keyCombo:Set["${keyCombo.ReplaceSubstring["Alt+",""]}"]
            keyCombo:Prepend[Alt-]
        }

        return "${keyCombo~}"
    }

    member:string GetCharacterNameFromSlot(jsonvalueref joSlot)
    {
        if !${joSlot.Has[character]}
            return ""

        variable jsonvalueref joCharacter
        joCharacter:SetReference["ISB2.Characters.Get[\"${joSlot.Get[character]~}\"]"]

        if !${joCharacter.Reference(exists)}
            return "${joSlot.Get[character]~}"

        if ${joCharacter.Has[actualName]}
            return "${joCharacter.Get[actualName]~}"

        return "${joCharacter.Get[name]~}"
    }
    
    member:string GetKeyComboFromSlot(jsonvalueref joSlot, string keyCombo)
    {
        if !${keyCombo.NotNULLOrEmpty} || ${keyCombo.Equal[NONE]}
            return "NONE"

        variable set ftlmods
        joSlot.Get[ftlModifiers]:ForEach["ftlmods:Add[\"\${ForEach.Value~}\"]"]

        ; ALT
        if ${ftlmods.Contains[LAlt]} || ${ftlmods.Contains[RAlt]}
            keyCombo:Prepend["ALT-"]

        ; CTRL
        if ${ftlmods.Contains[LCtrl]} || ${ftlmods.Contains[RCtrl]}
            keyCombo:Prepend["CTRL-"]

        ; SHIFT
        if ${ftlmods.Contains[LShift]} || ${ftlmods.Contains[RShift]}
            keyCombo:Prepend["SHIFT-"]

        return "${keyCombo~}"
    }

    method GenerateFTLMacroSlot(jsonvalueref ja, jsonvalueref joMacro, string keyCombo, uint numSlot, jsonvalueref joSlot)
    {
        variable string charName="${This.GetCharacterNameFromSlot[joSlot]~}"
;        echo "\ayGenerateFTLMacroSlot\ax ${keyCombo~} ${joMacro~} ${numSlot} ${charName~}"

;        ja:AddString["-- todo: slot ${numSlot} ${This.GetKeyComboFromSlot[joSlot,"${keyCombo~}"]} ${joMacro.Get[commands].ReplaceSubstring[{FTL},"${charName~}"]~~}"]

        ja:AddString["       isboxer2.SetMacro(\"${joMacro.Get[name]~}${numSlot}\",\"${This.GetKeyComboFromSlot[joSlot,"${keyCombo~}"]}\",\"${joMacro.Get[commands].ReplaceSubstring[{FTL},"${charName~}"].ReplaceSubstring["\n","\\n"]~}\");"]
    }

    method GenerateFTLMacro(jsonvalueref ja, jsonvalueref joMacro, string keyCombo)
    {
;        echo "\ayGenerateFTLMacro\ax ${keyCombo~} ${joMacro~}"

        ; for each slot, generate a separate macro
        ISB2.Team.Get[slots]:ForEach["This:GenerateFTLMacroSlot[ja,joMacro,\"${keyCombo~}\",\${ForEach.Key},ForEach.Value]"]
        ja:AddString[""]
    }

    method GenerateInviteMacro(jsonvalueref ja, jsonvalueref joMacro, string keyCombo)
    {
;        echo "\ayGenerateInviteMacro\ax ${keyCombo~} ${joMacro~}"
; 
        variable string commands

        ; filter query to ignore (not invite) current slot 
        variable jsonvalueref joQuery="{\"eval\":\"ForEach.Key\",\"op\":\"!=\",\"value\":${ISB2.Slot}}"
        
        ; for each slot, get the character name and add to commands
        ISB2.Team.Get[slots]:ForEach["commands:Concat[\"/invite \${This.GetCharacterNameFromSlot[ForEach.Value]}\n\"]",joQuery]

        ja:AddString["       isboxer2.SetMacro(\"${joMacro.Get[name]~}\",\"${keyCombo~}\",\"${commands~~}\");"]
        ja:AddString[""]
    }

    method GameMacroToLua(jsonvalueref ja, jsonvalueref joMacro)
    {
        ja:AddString["    -- Macro \"${joMacro.Get[name]~}\""]
        variable string keyCombo="${This.GetWoWCombo["${joMacro.Get[keyCombo]~}"]}"

        if ${joMacro.Get[commands].Find[{FTL}]}
        {
            This:GenerateFTLMacro[ja,joMacro,"${keyCombo~}"]
            return
        }

        if ${joMacro.Get[name].Equal[InviteTeam]} && ${joMacro.Get[commands].Find["!if"]}
        {
            This:GenerateInviteMacro[ja,joMacro,"${keyCombo~}"]
            return
        }

        if ${joMacro.Get[commands].Find["!if"]}
        {
            ja:AddString["-- todo: !if"]
            return
        }
        if ${joMacro.Get[commands].Find["!rem"]}
        {
            ja:AddString["-- todo: !rem"]
            return
        }

        ja:AddString["       isboxer2.SetMacro(\"${joMacro.Get[name]~}\",\"${keyCombo~}\",\"${joMacro.Get[commands]~~}\");"]
        ja:AddString[""]


;     isboxer2.SetMacro("InviteTeam","ALT-CTRL-SHIFT-I","/invite Gigantimus\n/invite Doomlicker\n/invite Qwix\n/invite Holydemon\n");
    }

    method GameMacroSheetToLua(jsonvalueref ja, string sheetName)
    {
        variable weakref gms="ISB2.GameMacroSheets.Get[\"${sheetName~}\"]"
        if !${gms.Reference(exists)}
            return FALSE

        ja:AddString["  -- Macro Sheet \"${sheetName~}\""]
        gms.Macros:ForEach["This:GameMacroToLua[ja,ForEach.Value]"]
        return TRUE
    }


    member:jsonvalueref ResolveGameMacros()
    {
        variable jsonvalueref ja="[]"

        This.GetGameMacroSheets:ForEach["This:GameMacroSheetToLua[ja,\"\${ForEach.Value~}\"]"]
        

        return ja
    }

    method WriteActiveCharacterFile()
    {
        ; ISBoxer_2.lua
        variable file out_file="${AddonFolder~}/ISBoxer_2_Character-${This.Sanitize["${ISB2.Character.Get[name]~}"]}.lua"
        This:MakeAddonFolder
        if !${out_file:Open(exists)}
        {
            Script:SetLastError["isb2_wowaddon:WriteMainLuaFile: Failed to open file ${out_file~} for writing"]
            return FALSE
        }

        out_file:Write["-- This file should be character-specific for ${ISB2.Character.Get[name]~} (from Team ${ISB2.Team.Get[name]~})\n"]
        out_file:Write["\n"]
        out_file:Write["isboxer2.Character.Name = \"${ISB2.Character.Get[name]~}\";\n"]
        if ${ISB2.Character.Has[actualName]}
            out_file:Write["isboxer2.Character.ActualName = \"${ISB2.Character.Get[actualName]~}\";\n"]
        else
            out_file:Write["isboxer2.Character.ActualName = \"${ISB2.Character.Get[name]~}\";\n"]
        out_file:Write["isboxer2.Character.QualifiedName = \"${ISB2.Character.Get[actualName]~}-${ISB2.Character.Get[gameServer]~}\";\n"]

        out_file:Write["function isboxer2.Character_LoadBinds()\n"]
        ; todo: write macros

        This.ResolveGameMacros:ForEach["out_file:Write[\"\${ForEach.Value~}\n\"]"]

        out_file:Write["end\n"]
        out_file:Write["isboxer2.Character.LoadBinds = isboxer2.Character_LoadBinds;\n"]
        out_file:Write["isboxer2.Output(\"Character '${ISB2.Character.Get[name]~}' activated\");\n"]

        out_file:Truncate:Close
        return TRUE
    }

    method Generate()
    {
        ; make sure we have Interface/Addons

        variable filepath addonsPath="${GameFolder~}/Interface/Addons"
        if !${addonsPath.PathExists}
        {
            echo "\ayisb2_wowaddon:Generate\ax: Interface/Addons does not exist. Not generating WoW Addon."
            return FALSE
        }

        if ${ISB2.Slot}==1
        {
            ; these only need to be made once, and we dont want the different instances fighting over them ayway
            This:WriteTOC
            This:WriteMainLuaFile
            This:WriteGenericTeamFile        
            This:WriteGenericCharacterFile
            This:WriteActiveTeamFile
        }
        This:WriteActiveCharacterFile
    }
}