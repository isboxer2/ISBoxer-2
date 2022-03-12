objectdef isb2022definitions
{
    variable jsonvalue Hotkeys={}
    variable jsonvalue GameKeyBindings={}
    variable jsonvalue Actions={}
    variable jsonvalue GUI={}
    
    variable jsonvalue Layouts={}

    member:jsonvalueref AsJSON()
    {
        variable jsonvalue jo={}
        jo:Set[hotkeys,"${Hotkeys~}"]
        jo:Set[gameKeyBindings,"${GameKeyBindings~}"]
        jo:Set[actions,"${Actions~}"]
        jo:Set[gui,"${GUI~}"]
        jo:Set[layouts,"${Layouts~}"]
    }    
}
