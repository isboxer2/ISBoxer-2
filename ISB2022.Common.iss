/* isb2022definitions: 
    A set of definitions for ISBoxer 2022. Essentially a "profile" (like an ISBoxer Toolkit Profile) but preferably more generic.
*/
objectdef isb2022definitions
{
    variable jsonvalue Hotkeys={}
    variable jsonvalue GameKeyBindings={}
    variable jsonvalue Actions={}
    variable jsonvalue GUI={}    
    variable jsonvalue KeyLayouts={}

    member:jsonvalueref AsJSON()
    {
        variable jsonvalue jo={}
        jo:Set[hotkeys,"${Hotkeys~}"]
        jo:Set[gameKeyBindings,"${GameKeyBindings~}"]
        jo:Set[actions,"${Actions~}"]
        jo:Set[gui,"${GUI~}"]
        jo:Set[keyLayouts,"${KeyLayouts~}"]
        return jo
    }
}

/* isb2022_actiontype:
    An "Action Type" implements a type of Action, such as "Keystroke", which would typically press and release a key or key combination.

    Example:
        {
            "name":"Keystroke",
            "fields":{                                      note: probably actually JSON schema, but simplifying for now
                "keyCombination":"string",
                "target":"string"
            }
        }

*/
objectdef isb2022_actiontype
{
    ; Name of the Action Type, such as "Keystroke"
    variable string Name

    ; A list of fields that the Action Type can use (e.g. "Key Combination" and "Target")
    variable jsonvalue Fields={}

    member:jsonvalueref AsJSON()
    {
        variable jsonvalue jo={}
        jo:Set[name,"${Name~}"]
        jo:Set[fields,"${Fields~}"]
        return jo
    }
}

/* isb2022_mappedkey:
    A "Mapped Key" executes when a Hotkey is pressed/released.
    
    Example:
        {
            "name":"Follow Me",
            "actions":[
                {
                    "type":"Keystroke",
                    "keyCombination":"Shift+F11",
                    "target":"self"
                }
            ]
        }
*/
objectdef isb2022_mappedkey
{
    ; Name of the Mapped Key
    variable string Name

    ; Name of assigned Hotkey
    variable string HotkeyName

    ; Array of Actions to perform
    variable jsonvalue Actions="[]"

    member:jsonvalueref AsJSON()
    {
        variable jsonvalue jo={}
        jo:Set[name,"${Name~}"]
        jo:Set[hotkey,"${HotkeyName~}"]
        jo:Set[actions,"${Actions~}"]
        return jo
    }
}
