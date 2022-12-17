objectdef isb2_game
{
    variable string Name
    variable jsonvalueref Data

    method Initialize(jsonvalueref data)
    {
;        echo "isb2_game initialize ${data~}"
        Data:SetReference[data]
        Name:Set["${jo.Get[name]~}"]
    }

    member:jsonvalueref AsJSON()
    {
        return Data
    }

    member:bool CanDetectCharacters()
    {
        return FALSE
    }

    member:jsonvalueref DetectCharacters(filepath gameFolder)
    {
;        echo "\arisb2_game.DetectCharacters\ax ${gameFolder~}"
        return NULL
    }
}

objectdef isb2_game_WoW inherits isb2_game
{
    method Initialize(jsonvalueref data)
    {
        This[parent]:Initialize[data]
    }

    method ScanCharacterFolderInto(jsonvalueref jo, string accountName, string serverName, filepath characterFolder)
    {
        variable string characterName="${characterFolder.FilenameOnly~}"
        if ${characterName.Equal[SavedVariables]}
            return FALSE

;        echo "\ayisb2_game_WoW:ScanCharacterFolderInto\ax ${characterFolder~}"

        echo "\agDetected Character\ax: ${characterName~}-${serverName} (${accountName})"

        if !${jo.Has[-array,characters]}
            jo:Set[characters,"[]"]


        variable jsonvalue joCharacter="{}"

        joCharacter:SetString[name,"${characterName~}-${serverName~}"]
        joCharacter:SetString[actualName,"${characterName~}"]
        joCharacter:SetString[gameServer,"${serverName~}"]
        joCharacter:SetString[accountName,"${accountName~}"]
        joCharacter:SetString[game,"World of Warcraft"]
        joCharacter:SetString[foundPath,"${characterFolder~}"]

        jo.Get[characters]:AddByRef[joCharacter]
    }

    method ScanServerFolderInto(jsonvalueref jo, string accountName, filepath serverFolder)
    {
        variable string serverName="${serverFolder.FilenameOnly~}"
        if ${serverName.Equal[SavedVariables]}
            return FALSE

;        echo "\ayisb2_game_WoW:ScanServerFolderInto\ax ${serverFolder~}"
        variable jsonvalueref jaFolders="serverFolder.GetDirectories"

;        echo "folders=${jaFolders~}"
        jaFolders:ForEach["This:ScanCharacterFolderInto[jo,\"${accountName~}\",\"${serverName~}\",\"${serverFolder~}/\${ForEach.Value.Get[filename]~}\"]"]

    }

    method ScanAccountFolderInto(jsonvalueref jo, filepath accountFolder)
    {
        variable string accountName="${accountFolder.FilenameOnly~}"
        if ${accountName.Equal[SavedVariables]}
            return FALSE

;        echo "\ayisb2_game_WoW:ScanAccountFolderInto\ax ${accountFolder~}"
        variable jsonvalueref jaFolders="accountFolder.GetDirectories"

;        echo "folders=${jaFolders~}"
        jaFolders:ForEach["This:ScanServerFolderInto[jo,\"${accountName~}\",\"${accountFolder~}/\${ForEach.Value.Get[filename]~}\"]"]
    }

    method ScanAccountFoldersInto(jsonvalueref jo, filepath gameFolder)
    {
;        echo "\ayScanAccountFoldersInto\ax ${gameFolder~}"
        variable jsonvalueref jaFolders="gameFolder.GetDirectories[\"WTF/Account/\*\"]"

;        echo "folders=${jaFolders~}"
        jaFolders:ForEach["This:ScanAccountFolderInto[jo,\"${gameFolder~}/WTF/Account/\${ForEach.Value.Get[filename]~}\"]"]
    }

    member:bool CanDetectCharacters()
    {
        return TRUE
    }

    member:jsonvalueref DetectCharacters(filepath gameFolder)
    {
        if !${gameFolder~.NotNULLOrEmpty}
            return NULL

        echo "\arisb2_game_WoW.DetectCharacters\ax ${gameFolder~}"

        ; WTF/Account/<ACCOUNTNAME>/<SERVERNAME>/<CHARACTERNAME>/AddOns.txt

        variable jsonvalue jo="{}"
        This:ScanAccountFoldersInto[jo,"${gameFolder~}"]

        return jo
    }

}

objectdef isb2_games
{
    variable collection:weakref Games

    method Initialize()
    {

    }

    method Shutdown()
    {

    }

    member:weakref Get(string name)
    {
        return "Games.Get[\"${name~}\"]"
    }

    method AddGame(jsonvalueref jo)
    {
        echo "AddGame ${jo~}"
        if ${This.VariableScope.Get["game_${jo.Get[shortName]~}"](exists)}
        {
            ; already added...            
            return
        }

        if ${Script.ObjectDef["isb2_game_${jo.Get[shortName]~}"](exists)}
        {
            ; e.g. isb2_game_WoW
            This.VariableScope:CreateVariable["isb2_game_${jo.Get[shortName]~}","game_${jo.Get[shortName]~}",jo]
            Games:Set["${jo.Get[name]~}","This.game_${jo.Get[shortName]~}"]
            return
        }

        This.VariableScope:CreateVariable["isb2_game","game_${jo.Get[shortName]~}",jo]
        Games:Set["${jo.Get[name]~}","This.game_${jo.Get[shortName]~}"]
    }

    method FromJSON(jsonvalueref ja)
    {
        ja:ForEach["This:AddGame[ForEach.Value]"]
        ; ja:ForEach["Games:Set[\"\${ForEach.Value.Get[name]~}\",ForEach.Value]"]
    }

    member:jsonvalueref AsJSON()
    {
        return "${Games.AsJSON~}"
    }
}