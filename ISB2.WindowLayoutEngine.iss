/* isb2_windowlayoutengine: 
    An active ISBoxer 2 Window Layout
*/
variable(global) isb2_windowlayoutengine ISB2WindowLayout

enum ewindowlayoutreason
{
    Unknown=0
    OnActivate=1,
    OnDeactivate=2,
    OnSlotActivate=3,
    OnInternalActivate=4,
    Startup=5,
    Remote=6,
}

objectdef isb2_windowlayoutengine
{
    variable jsonvalueref Settings="{}"
    variable jsonvalueref Regions="[]"
    variable jsonvalueref SwapGroup="{}"

    variable jsonvalueref CurrentRegion

    variable string LastApplied

    variable uint Group

    variable bool Roaming
    variable uint RoamingSlot

    variable jsonvalueref ResetRegion
    variable uint NumResetRegion

    variable jsonvalueref ActiveRegion
    variable uint NumActiveRegion=1
    variable jsonvalueref InactiveRegion
    variable uint NumInactiveRegion=2

    variable bool Active=FALSE

    variable bool Attached
    
    method Initialize()
    {
        ISB2WindowLayout:SetReference[This]

        LavishScript:RegisterEvent[On Activate]
        LavishScript:RegisterEvent[On Deactivate]
        LavishScript:RegisterEvent[OnWindowStateChanging]
        LavishScript:RegisterEvent[On Window Position]
        
		LavishScript:RegisterEvent[OnMouseEnter]
		LavishScript:RegisterEvent[OnMouseExit]
        LavishScript:RegisterEvent[OnHotkeyFocused]
        LavishScript:RegisterEvent[OnInternalActivate]
        LavishScript:RegisterEvent[On3DReset]

        Event[On Activate]:AttachAtom[This:Event_OnActivate]
        Event[OnInternalActivate]:AttachAtom[This:Event_OnInternalActivate]
        Event[On Deactivate]:AttachAtom[This:Event_OnDeactivate]
        Event[OnWindowStateChanging]:AttachAtom[This:Event_OnWindowStateChanging]
        Event[On Window Position]:AttachAtom[This:Event_OnWindowPosition]
		Event[OnMouseEnter]:AttachAtom[This:Event_OnMouseEnter]
		Event[OnMouseExit]:AttachAtom[This:Event_OnMouseExit]
        Event[OnHotkeyFocused]:AttachAtom[This:Event_OnHotkeyFocused]
        Event[On3DReset]:AttachAtom[This:Event_On3DReset]

        SwapGroup:SetReference["$$>
        {
            "resetRegion":1,
        }
        <$$"]
        Settings:SetReference["$$>
        {
            "resetRegion":1,
            "frame":"none",
            "swapOnActivate":true,
            "swapOnDeactivate":true,
            "sometimesOnTop":true
        }
        <$$"]

;        LGUI2:LoadPackageFile[WindowLayoutEngine.Session.lgui2Package.json]        
;        This:LoadTests
        This:RefreshActiveStatus[Startup]

;        uplink "ISB2WindowLayout:Event_OnSessionStartup[\"${Session~}\"]"
    }

    method Shutdown()
    {
 ;       uplink "ISB2WindowLayout:Event_OnSessionShutdown[\"${Session~}\"]"
 ;       LGUI2:UnloadPackageFile[WindowLayoutEngine.Session.lgui2Package.json]
    }

    method LoadTests()
    {
        Settings:SetReference["$$>
        {
            "resetRegion":1,
            "frame":"none",
            "swapOnActivate":true,
            "swapOnDeactivate":true,
            "sometimesOnTop":true
        }
        <$$"]
        
        /*
        Regions:SetReference["$$>
        [
            {"bounds":[0,0,640,360],"numRegion":1},
            {"bounds":[640,0,640,360],"numRegion":2},
            {"bounds":[1280,0,640,360],"numRegion":3},
            {"bounds":[0,360,640,360],"numRegion":4},
            {"bounds":[640,360,640,360],"numRegion":5}
        ]
        <$$"]
        /**/
        
        Regions:SetReference["$$>
        [
            {"bounds":[0,0,1920,900],"numRegion":1,"mainRegion":true},
            {"bounds":[0,900,384,180],"numRegion":2},
            {"bounds":[384,900,384,180],"numRegion":3},
            {"bounds":[768,900,384,180],"numRegion":4},
            {"bounds":[1152,900,384,180],"numRegion":5},
            {"bounds":[1536,900,384,180],"numRegion":6}
            ]
        <$$"]
        /**/
        This:SelectRegions[1,2]
        This:SelectResetRegion[1]
    }    

    member:bool RenderSizeMatchesClient()
    {
        ; check desired rendering size
        if ${ResetRegion.Reference(exists)}
        {
            if ${Display.Width}!=${Display.ViewableWidth} || ${Display.Height}!=${Display.ViewableHeight}
                return FALSE
        }
        return TRUE
    }

    member:bool RenderSizeMatchesReset()
    {
        ; check desired rendering size
        if ${ResetRegion.Reference(exists)}
        {
            if ${Display.Width}!=${ResetRegion.GetInteger[bounds,3]} || ${Display.Height}!=${ResetRegion.GetInteger[bounds,4]}
                return FALSE
        }
        return TRUE
    }

    method ApplyRegion(jsonvalueref useRegion)
    {
        if !${useRegion.Reference(exists)} || !${useRegion.Type.Equal[object]}
            return
        
        echo "isb2_windowlayoutengine:ApplyRegion: ${useRegion~}"

        variable bool rescale

        ; check desired rendering size        
        if ${ResetRegion.Reference(exists)}
        {
            rescale:Set[1]
            if ${Display.Width}!=${ResetRegion.GetInteger[bounds,3]} || ${Display.Height}!=${ResetRegion.GetInteger[bounds,4]}
                rescale:Set[0]
        }

        variable string wlParams="-pos -viewable ${useRegion.GetInteger[bounds,1]},${useRegion.GetInteger[bounds,2]} -size -viewable ${useRegion.GetInteger[bounds,3]}x${useRegion.GetInteger[bounds,4]}"

        if !${forceReset} && ${rescale}
            wlParams:Set["-stealth ${wlParams~}"]

        variable string useFrame

        if ${useRegion.Has[frame]}
            useFrame:Set["${useRegion.Get[frame]~}"]
        if ${Settings.Has[frame]}
            useFrame:Set["${Settings.Get[frame]~}"]

        if ${useFrame.NotNULLOrEmpty}
            wlParams:Concat[" -frame ${useFrame~}"]

        echo "WindowCharacteristics ${wlParams~}"
        WindowCharacteristics ${wlParams~}
    }

    method Apply(bool forceReset=FALSE)
    {
        ; we're either going to apply ResetRegion or CurrentRegion.
        if !${Display.AppWindowed}
        {
            ; window not available, do at earliest convenience
            ;echo "isb2_windowlayoutengine:Apply: \ayWindow not available\ax"        
            This:Attach
            return FALSE
        }

        if ${ResetRegion.Reference(exists)}
        {
            if !${This.RenderSizeMatchesReset} || ${forceReset}
            {
                echo "isb2_windowlayoutengine:Apply applying Reset Region"
                LastApplied:Set[ResetRegion]
                This:ApplyRegion[ResetRegion]
                return TRUE
            }
        }

        if !${CurrentRegion.Reference(exists)}
        {
            Script:SetLastError["\arisb2_windowlayoutengine:Apply\ax: No CurrentRegion"]
        }
        LastApplied:Set[CurrentRegion]
        This:ApplyRegion[CurrentRegion]
        ; WindowCharacteristics ${stealthFlag}-pos -viewable ${useX},${mainHeight} -size -viewable ${smallWidth}x${smallHeight} -frame none

        return TRUE
    }

    method Attach()
    {
        if ${Attached}
            return

        Event[OnFrame]:AttachAtom[This:Event_OnFrame]
        Attached:Set[1]
    }

    method Detach()
    {
        if !${Attached}
            return

        Event[OnFrame]:DetachAtom[This:Event_OnFrame]
        Attached:Set[0]
    }

    method Event_OnFrame()
    {
        This:Detach
        This:Apply
    }

    method SetCurrentRegion(jsonvalueref useRegion)
    {
        CurrentRegion:SetReference[useRegion]
        LGUI2.Element["windowLayoutEngine.events"]:FireEventHandler[currentRegionChanged]
    }

    method SelectResetRegion(uint numRegion)
    {
        if ${numRegion}>0 && ${numRegion}<=${Regions.Size}
        {
            NumResetRegion:Set[${numRegion}]
            ResetRegion:SetReference["Regions.Get[${numRegion}]"]
        }
        else
        {
            NumResetRegion:Set[0]
            ResetRegion:SetReference[NULL]
        }
        LGUI2.Element["windowLayoutEngine.events"]:FireEventHandler[resetRegionChanged]
    }


    method SelectActiveRegion(uint numRegion)
    {
        if ${numRegion}>0 && ${numRegion}<=${Regions.Size}
        {
            NumActiveRegion:Set[${numRegion}]
            ActiveRegion:SetReference["Regions.Get[${numRegion}]"]

        }
        else
        {
            NumActiveRegion:Set[0]
            ActiveRegion:SetReference[NULL]
        }
        LGUI2.Element["windowLayoutEngine.events"]:FireEventHandler[activeRegionChanged]

        if ${Active}
            This:SetCurrentRegion[ActiveRegion]

    }

    method SelectInactiveRegion(uint numRegion)
    {
        if ${numRegion}>0 && ${numRegion}<=${Regions.Size}
        {
            NumInactiveRegion:Set[${numRegion}]
            InactiveRegion:SetReference["Regions.Get[${numRegion}]"]
        }
        else
        {
            NumInactiveRegion:Set[0]
            InactiveRegion:SetReference[NULL]
        }

        LGUI2.Element["windowLayoutEngine.events"]:FireEventHandler[inactiveRegionChanged]

        if !${Active}
            This:SetCurrentRegion[InactiveRegion]

    }

    method SelectRegions(uint numActiveRegion, uint numInactiveRegion)
    {
        This:SelectActiveRegion[${numActiveRegion}]
        This:SelectInactiveRegion[${numInactiveRegion}]
    }

    method Remote_ActiveStatusChanged(string sessionName, uint numGroup, bool newValue, ewindowlayoutreason reason=0)
    {
        echo "isb2_windowlayoutengine:\ayRemote_ActiveStatusChanged\ax \"${sessionName~}\" ${numGroup} ${newValue} ${reason}"
        if ${numGroup}==${Group}
        {
            ; roaming slot?
            if ${newValue} && ${Roaming}
            {
                ; take the inactive region
                This:SelectInactiveRegion["${This.GetInactiveRegionForSlot["${sessionName.Right[-2]}"]}"]                    
                echo "Roaming: Inactive Region now ${This.NumInactiveRegion}"
                This:SetActiveStatus[0,Remote]
                This:Apply
                return
            }

            if ${Settings.GetBool[swapOnActivate]} 
            {
                if !${Settings.GetBool[focusFollowsMouse]}
                {
                    if ${This:RefreshActiveStatus[Remote](exists)}
                    {
                        This:Apply
                    }
                }
            }
            else
            {
                if ${newValue}
                {
                    This:SetActiveStatus[0,Remote]
                    This:Apply
                }
            }
        }        
    }

    method SetActiveStatus(bool newValue, ewindowlayoutreason reason=0)
    {
        variable bool oldValue=${Active}
        variable bool fireEvent
        Active:Set[${newValue}]
        echo "isb2_windowlayoutengine:\agSetActiveStatus\ax[${newValue}] oldValue=${oldValue}"

        if !${CurrentRegion.Reference(exists)}
            fireEvent:Set[1]

        if ${Active}
        {
            CurrentRegion:SetReference[ActiveRegion]

            if ${Roaming}
                This:SelectInactiveRegion[0]
        }
        else
            CurrentRegion:SetReference[InactiveRegion]

        if ${fireEvent} || ${oldValue} != ${Active}
        {
;            echo "firing \atRemote_ActiveStatusChanged\ax"
            relay "all other local" -noredirect "ISB2WindowLayout:Remote_ActiveStatusChanged[\"${Session~}\",${Group},${Active},${reason.Value}]"
            LGUI2.Element["windowLayoutEngine.events"]:FireEventHandler[activeStatusChanged]
            return TRUE
        }

        return FALSE
    }

    method RefreshActiveStatus(ewindowlayoutreason reason=0,bool forceUpdate=FALSE)
    {
        variable bool newValue=${Display.Window.IsForeground}
        if ${forceUpdate} || ${newValue}!=${Active}
        {
            return ${This:SetActiveStatus[${newValue},${reason.Value}](exists)}
        }
        return FALSE
    }

    member:uint GetInactiveRegionForSlot(uint numSlot)
    {
        variable jsonvalueref joQuery="$$>
        {
            "eval":"Select.Get[slot]",
            "op":"==",
            "value":${numSlot}
        }
        <$$"
        return ${Regions.SelectKey[joQuery]}
    }
    
    method SetLayout(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
        {
            Script:SetLastError["isb2_windowlayoutengine:SetLayout expected object, got ${jo~}"]
            return
        }

        echo "isb2_windowlayoutengine:SetLayout ${jo~}"
        ISB2ProfileEngine.OnSlotActivate:AttachAtom[This:Event_OnSlotActivate]
        ISSession.OnWindowCaptured:AttachAtom[This:Event_OnWindowCaptured]

        if ${jo.Has[settings]}
            Settings:SetReference["${jo.Get[settings]~}"]

        Regions:SetReference["${jo.Get[regions]}"]
        LGUI2.Element["windowLayoutEngine.events"]:FireEventHandler[regionsChanged]

        if ${Settings.Has[resetRegion]}
            NumResetRegion:Set["${Settings.GetInteger[resetRegion]}"]
        
        Group:Set["${joInactiveRegion.GetInteger[swapGroup]}+1"]
        SwapGroup:SetReference["${jo.Get[swapGroups,${Group}]}"]
        if ${SwapGroup.Type.Equal[object]}
        {
            NumActiveRegion:Set["${SwapGroup.GetInteger[active]}"]
            NumResetRegion:Set["${SwapGroup.GetInteger[reset]}"]
            RoamingSlot:Set["${SwapGroup.GetInteger[roamingSlot]}"]                    
            Roaming:Set[${RoamingSlot.Equal[${ISB2.Slot}]}]            
        }
        else
        {
            NumActiveRegion:Set[1]
            NumResetRegion:Set[1]
            RoamingSlot:Set[0]
            Roaming:Set[0]
        }

        switch ${Settings.GetBool[focusClick]}
        {
            case FALSE
                FocusClick eat
                break
            case TRUE
                FocusClick click
                break
            default
                FocusClick application
                break
        }

        switch ${Settings.Get[swapMode]}
        {
            case Always
            case AlwaysForGames
                FocusClick eat
                break
        }

        if ${Roaming}
            NumInactiveRegion:Set[0]
        else
            NumInactiveRegion:Set[${This.GetInactiveRegionForSlot[${ISB2.Slot}]}]

        variable jsonvalueref joInactiveRegion
        joInactiveRegion:SetReference["Regions.Get[joInactiveRegion]"]

        echo active=${NumActiveRegion} inactive=${NumInactiveRegion} reset=${NumResetRegion}
        This:SelectRegions[${NumActiveRegion},${NumInactiveRegion}]
        This:SelectResetRegion[${NumResetRegion}]

        ISSession:SetFocusFollowsMouse["${Settings.GetBool[focusFollowsMouse]}"]

        WindowCharacteristics -lock
        This:Apply
    }

#region events

    method Event_OnSlotActivate()
    {
        echo "isb2_windowlayoutengine:Event_OnSlotActivate"
        if ${Settings.GetBool[swapOnSlotActivate]}
        {
;            echo calling This:SetActiveStatus[1,OnSlotActivate]
            if !${This:SetActiveStatus[1,OnSlotActivate](exists)}
            {
                echo "isb2_windowlayoutengine:Event_OnSlotActivate: SetActiveStatus=FALSE"
                return
            }
        }

        if ${Settings.GetBool[-default,1,refreshOnSlotActivate]}
        {
            echo "isb2_windowlayoutengine: Applying."
            This:Apply
        }
    }

    method Event_OnInternalActivate()
    {
        echo "isb2_windowlayoutengine:Event_OnInternalActivate"

        if ${Settings.GetBool[swapOnInternalActivate]} && !${Settings.GetBool[focusFollowsMouse]}
        {
            if !${This:RefreshActiveStatus[OnInternalActivate](exists)}
            {
                return
            }
        }

        if ${Settings.GetBool[-default,1,refreshOnInternalActivate]}
        {
            echo "isb2_windowlayoutengine: Applying."
            This:Apply
        }
    }

    method Event_OnActivate()
    {
        echo "isb2_windowlayoutengine:Event_OnActivate"

        if ${Settings.GetBool[swapOnActivate]}
        {
;            echo calling This:RefreshActiveStatus[OnSlotActivate]
            if !${This:RefreshActiveStatus[OnActivate](exists)}
            {
                return
            }
        }

        if ${Settings.GetBool[-default,1,refreshOnActivate]} && !${Settings.GetBool[focusFollowsMouse]}
        {
            echo "isb2_windowlayoutengine: Applying."
            This:Apply
        }
    }

    method Event_OnDeactivate()
    {
        echo "isb2_windowlayoutengine:Event_OnDeactivate"

        if ${Settings.GetBool[swapOnDeactivate]}
        {
            if !${This:RefreshActiveStatus[OnDeactivate](exists)}
            {
                return
            }
        }

        if ${Settings.GetBool[-default,1,refreshOnDeactivate]} && !${Settings.GetBool[focusFollowsMouse]}
        {
            echo "isb2_windowlayoutengine: Applying."
            This:Apply
        }
    }

    method Event_OnHotkeyFocused()
    {
        echo "isb2_windowlayoutengine:Event_OnHotkeyFocused"
        if ${Settings.GetBool[swapOnHotkeyFocused]}
        {
            if !${This:RefreshActiveStatus[OnHotkeyFocused](exists)}
            {
                return
            }
            
        }

        if ${Settings.GetBool[-default,1,refreshOnHotkeyFocused]}
        {
            echo "isb2_windowlayoutengine: Applying."
            This:Apply
        }
    }

    method Event_OnWindowPosition()
    {
        echo "isb2_windowlayoutengine:OnWindowPosition ${Display.ViewableX},${Display.ViewableY} ${Display.ViewableWidth}x${Display.ViewableHeight}  render=${Display.Width}x${Display.Height}"
        This:Attach        
    }

    method Event_OnWindowStateChanging(string change)
    {
        echo "isb2_windowlayoutengine:OnWindowStateChanging ${change~}"
    }

    method Event_OnMouseEnter()
    {
        This:ApplyFocusFollowMouse
    }

    method Event_OnMouseExit()
    {

    }

    method Event_On3DReset()
    {
        echo "isb2_windowlayoutengine:On3DReset"
        This:Attach
    }

    method Event_OnWindowCaptured()
    {
        echo "isb2_windowlayoutengine:Event_OnWindowCaptured, applying..."
        This:Apply
    }
#endregion
    
    method ApplyFocusFollowMouse()
    {
        if !${Settings.GetBool[focusFollowsMouse]}
            return

;        echo "isb2_windowlayoutengine:ApplyFocusFollowsMouse"
        This:FocusSelf
    }

    method FocusSelf()
    {
        if ${Display.Window.IsForeground}
        {
;            echo "isb2_windowlayoutengine:FocusSelf: windowvisibility foreground"
            windowvisibility foreground
            return TRUE
        }

;        echo "isb2_windowlayoutengine:FocusSelf: relay foreground \"BasicCore.WindowLayout:FocusWindow[${Display.Window~}]\""
        relay foreground -noredirect "ISB2WindowLayout:FocusWindow[${Display.Window~}]"
        return TRUE
    }

    method FocusSession(string name)
    {
        if !${Display.Window.IsForeground}
            return FALSE
        uplink focus "${name~}"
        return TRUE
    }

    method FocusWindow(gdiwindow hWnd)
    {
;        echo "isb2_windowlayoutengine:FocusWindow: hWnd=${hWnd} "
        return ${hWnd:SetForegroundWindow(exists)}
    }

}