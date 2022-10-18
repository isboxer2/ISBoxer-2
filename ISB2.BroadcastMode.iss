variable(global) isb2_broadcastmode ISB2BroadcastMode

objectdef isb2_broadcastmode
{
    variable bool Enabled=FALSE

    method Initialize()
    {
    }

    method Shutdown()
    {

    }

    method SetBroadcastProfile(jsonvalueref joProfile)
    {
        LavishScript:RegisterEvent[On Activate]
        LavishScript:RegisterEvent[On Deactivate]
        Event[On Activate]:AttachAtom[This:Event_OnActivate]
        Event[On Deactivate]:AttachAtom[This:Event_OnDeactivate]


    }

    method Event_OnActivate()
    {
        if ${Enabled}
            LGUI2.Element[isb2.MainBroadcaster]:SetVisibility[Visible]
    }

    method Event_OnDeactivate()
    {
        LGUI2.Element[isb2.MainBroadcaster]:SetVisibility[Hidden]
    }

    method Toggle()
    {
        if ${Enabled}
            This:Disable
        else
            This:Enable
    }

    method Enable()
    {
        Enabled:Set[1]
        LGUI2.Element[isb2.MainBroadcaster]:SetVisibility[Visible]
    }

    method Disable()
    {
        Enabled:Set[0]
        LGUI2.Element[isb2.MainBroadcaster]:SetVisibility[Hidden]
    }
}