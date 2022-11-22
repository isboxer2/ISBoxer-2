variable(global) isb2_broadcastmode ISB2BroadcastMode

objectdef isb2_broadcastmode
{
    variable bool Enabled=FALSE
    variable lgui2elementref Broadcaster

    method Initialize()
    {
        Broadcaster:SetReference["${LGUI2.Element[isb2.MainBroadcaster].ID}"]
    }

    method Shutdown()
    {

    }

    method LateInitialize()
    {
        echo "isb2_broadcastmode:LateInitialize"
        Broadcaster:Set["${LGUI2.Element[isb2.MainBroadcaster].ID}"]
        echo Broadcaster:Set["${LGUI2.Element[isb2.MainBroadcaster].ID}"]
        if !${Broadcaster.Element(exists)}
        {
            echo "\arisb2_broadcastmode:LateInitialize\ax: No isb2.MainBroadcaster element"        
            return
        }
        
        LavishScript:RegisterEvent[On Activate]
        LavishScript:RegisterEvent[On Deactivate]
        Event[On Activate]:AttachAtom[This:Event_OnActivate]
        Event[On Deactivate]:AttachAtom[This:Event_OnDeactivate]
    }

    method SetBroadcastProfile(jsonvalueref joProfile)
    {
    }

    method ApplyState(jsonvalueref joState)
    {
        if !${Broadcaster.Element(exists)}
        {
            Broadcaster:Set["${LGUI2.Element[isb2.MainBroadcaster].ID}"]
            if !${Broadcaster.Element(exists)}
            {
                echo "\arisb2_broadcastmode:ApplyState\ax: No isb2.MainBroadcaster element"        
                return
            }
        }

        echo "\ayisb2_broadcastmode:ApplyState\ax ${joState~}"
        switch ${joState.Get[mouseState]}
        {
        case On
            This:SetMouseBroadcasting[1]
            break
        case Off
            This:SetMouseBroadcasting[0]
            break
        case Toggle
            This:SetMouseBroadcasting[${This.IsMouseBroadcasting.Not}]
            break
        }

        switch ${joState.Get[keyboardState]}
        {
        case On
            This:SetKeyBroadcasting[1]
            break
        case Off
            This:SetKeyBroadcasting[0]
            break
        case Toggle
            This:SetKeyBroadcasting[${This.IsKeyBroadcasting.Not}]
            break
        }

        if ${This.IsAnyBroadcasting}
            This:Enable
        else
            This:Disable

        /*
                  "mouseState":"On",
                  "keyboardState":"On"
         */
    }

    member:bool IsAnyBroadcasting()
    {
        if ${Broadcaster.KeyboardEnabled} || ${Broadcaster.MouseEnabled}
            return 1
        return 0
    }

    member:bool IsKeyBroadcasting()
    {
        return ${Broadcaster.KeyboardEnabled}
    }

    member:bool IsMouseBroadcasting()
    {
        return ${Broadcaster.MouseEnabled}
    }

    method SetKeyBroadcasting(bool newValue)
    {
        echo "\atisb2_broadcastmode\ax SetKeyBroadcasting ${newValue}"
        Broadcaster.Element:SetKeyboardEnabled[${newValue}]
    }

    method SetMouseBroadcasting(bool newValue)
    {
        echo "\atisb2_broadcastmode\ax SetMouseBroadcasting ${newValue}"
        Broadcaster.Element:SetMouseEnabled[${newValue}]
    }

    member:string Target()
    {
        return "${Broadcaster.BroadcastTarget~}"
    }

    method SetTarget(string target)
    {
        Broadcaster.Element:SetBroadcastTarget["${target~}"]
    }

    method Event_OnActivate()
    {
        if ${Enabled}
            Broadcaster.Element:SetVisibility[Visible]
    }

    method Event_OnDeactivate()
    {
        Broadcaster.Element:SetVisibility[Hidden]
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
        if ${Enabled}
            return

        Enabled:Set[1]
        Broadcaster.Element:SetVisibility[Visible]:KeyboardFocus

        LGUI2.Element[isb2.events]:FireEventHandler[onBroadcastingStateChanged]
    }

    method Disable()
    {
        if !${Enabled}
            return

        Enabled:Set[0]
        Broadcaster.Element:SetVisibility[Hidden]
        LGUI2.Screen:KeyboardFocus

        LGUI2.Element[isb2.events]:FireEventHandler[onBroadcastingStateChanged]
    }
}