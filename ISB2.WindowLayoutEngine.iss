/* isb2_windowlayoutengine: 
    An active ISBoxer 2 Window Layout
*/
variable(global) isb2_windowlayoutengine ISB2WindowLayout

objectdef isb2_windowlayoutengine
{
    variable jsonvalue Settings="{}"
    variable jsonvalue Regions="[]"

    variable jsonvalueref CurrentRegion

    variable uint Group

    variable jsonvalueref ResetRegion
    variable uint NumResetRegion

    variable jsonvalueref ActiveRegion
    variable uint NumActiveRegion
    variable jsonvalueref InactiveRegion
    variable uint NumInactiveRegion

    variable bool Active=FALSE

    method Initialize()
    {
        ISB2WindowLayout:SetReference[This]

        LavishScript:RegisterEvent[On Activate]
        LavishScript:RegisterEvent[On Deactivate]
        LavishScript:RegisterEvent[OnWindowStateChanging]
		LavishScript:RegisterEvent[OnMouseEnter]
		LavishScript:RegisterEvent[OnMouseExit]
        LavishScript:RegisterEvent[OnHotkeyFocused]

        Event[On Activate]:AttachAtom[This:Event_OnActivate]
        Event[On Deactivate]:AttachAtom[This:Event_OnDeactivate]
        Event[OnWindowStateChanging]:AttachAtom[This:Event_OnWindowStateChanging]
		Event[OnMouseEnter]:AttachAtom[This:Event_OnMouseEnter]
		Event[OnMouseExit]:AttachAtom[This:Event_OnMouseExit]
        Event[OnHotkeyFocused]:AttachAtom[This:Event_OnHotkeyFocused]


;        LGUI2:LoadPackageFile[WindowLayoutEngine.Session.lgui2Package.json]        
;        This:LoadTests
        This:RefreshActiveStatus

;        uplink "ISB2WindowLayout:Event_OnSessionStartup[\"${Session~}\"]"
    }

    method Shutdown()
    {
 ;       uplink "ISB2WindowLayout:Event_OnSessionShutdown[\"${Session~}\"]"
 ;       LGUI2:UnloadPackageFile[WindowLayoutEngine.Session.lgui2Package.json]
    }

    method LoadTests()
    {
        Settings:SetValue["$$>
        {
            "resetRegion":1,
            "frame":"none",
            "swapOnActivate":true,
            "swapOnDeactivate":true
        }
        <$$"]
        
        /*
        Regions:SetValue["$$>
        [
            {"bounds":[0,0,640,360],"numRegion":1},
            {"bounds":[640,0,640,360],"numRegion":2},
            {"bounds":[1280,0,640,360],"numRegion":3},
            {"bounds":[0,360,640,360],"numRegion":4},
            {"bounds":[640,360,640,360],"numRegion":5}
        ]
        <$$"]
        /**/
        
        Regions:SetValue["$$>
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

        if ${Settings.Has[frame]}
            wlParams:Concat[" -frame ${Settings.Get[frame]~}"]

        echo "WindowCharacteristics ${wlParams~}"
        WindowCharacteristics ${wlParams~}
    }

    method Apply(bool forceReset=FALSE)
    {
        This:ApplyRegion[CurrentRegion]

        ; WindowCharacteristics ${stealthFlag}-pos -viewable ${useX},${mainHeight} -size -viewable ${smallWidth}x${smallHeight} -frame none
    }

    method SetCurrentRegion(jsonvalueref useRegion)
    {
        CurrentRegion:SetReference[useRegion]
        LGUI2.Element["windowLayoutEngine.events"]:FireEventHandler[currentRegionChanged]
    }

    method SelectResetRegion(uint numRegion)
    {
        if ${numRegion}>0 && ${numRegion}<${Regions.Size}
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
        if ${numRegion}>0 && ${numRegion}<${Regions.Size}
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
        if ${numRegion}>0 && ${numRegion}<${Regions.Size}
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

    method Remote_ActiveStatusChanged(string sessionName, uint numGroup, bool newValue)
    {
        echo "isb2_windowlayoutengine:Remote_ActiveStatusChanged \"${sessionName~}\" ${numGroup} ${newValue}"
        if ${numGroup}==${Group}
        {
            if ${Settings.GetBool[swapOnActivate]} 
            {
                if !${Settings.GetBool[focusFollowsMouse]}
                {
                    if ${This:RefreshActiveStatus(exists)}
                    {
                        This:Apply
                    }
                }
            }
            else
            {
                This:RefreshActiveStatus
            }
        }        
    }

    method SetActiveStatus(bool newValue)
    {
        variable bool oldValue=${Active}
        variable bool fireEvent
        Active:Set[${newValue}]

        if !${CurrentRegion.Reference(exists)}
            fireEvent:Set[1]

        if ${Active}
            CurrentRegion:SetReference[ActiveRegion]
        else
            CurrentRegion:SetReference[InactiveRegion]

        if ${fireEvent} || ${oldValue} != ${Active}
        {
            relay "all other local" -noredirect "ISB2WindowLayout:Remote_ActiveStatusChanged[\"${Session~}\",${Group},${Active}]"
            LGUI2.Element["windowLayoutEngine.events"]:FireEventHandler[activeStatusChanged]
            return TRUE
        }

        return FALSE
    }

    method RefreshActiveStatus(bool forceUpdate=FALSE)
    {
        variable bool newValue=${Display.Window.IsForeground}
        if ${forceUpdate} || ${newValue}!=${Active}       
            return ${This:SetActiveStatus[${newValue}](exists)}
        return FALSE
    }

    method SetLayout(jsonvalueref jo)
    {
        if !${jo.Type.Equal[object]}
        {
            echo "isb2_windowlayoutengine:SetLayout expected object, got ${jo~}"
            return
        }

        echo "isb2_windowlayoutengine:SetLayout ${jo~}"

        Regions:SetValue["${jo.Get[regions]}"]
        LGUI2.Element["windowLayoutEngine.events"]:FireEventHandler[regionsChanged]

        This:SelectRegions[${NumActiveRegion},${NumInactiveRegion}]
        This:SelectResetRegion[${NumResetRegion}]
    }

#region events

    method Event_OnActivate()
    {
        echo "isb2_windowlayoutengine:Event_OnActivate"

        variable bool changed

        if !${Settings.GetBool[swapOnActivate]} && !${Settings.GetBool[refreshOnActivate]} 
        {
            echo !${Settings.GetBool[swapOnActivate]} && !${Settings.GetBool[refreshOnActivate]} 
            return
        }

        if !${This:RefreshActiveStatus(exists)}
        {
            echo "!\${This:RefreshActiveStatus(exists)}"
            return
        }

        if ${Settings.GetBool[swapOnActivate]} && !${Settings.GetBool[focusFollowsMouse]}
        {
            echo Applying.
            This:Apply
        }
    }

    method Event_OnDeactivate()
    {
        echo "isb2_windowlayoutengine:Event_OnDeactivate"

        variable bool changed

        if !${Settings.GetBool[swapOnDeactivate]} && !${Settings.GetBool[refreshOnDeactivate]} 
        {
            echo !${Settings.GetBool[swapOnDeactivate]} && !${Settings.GetBool[refreshOnDeactivate]} 
            return
        }

        if !${This:RefreshActiveStatus(exists)}
        {
            echo "!\${This:RefreshActiveStatus(exists)}"
            return
        }

        if ${Settings.GetBool[swapOnDeactivate]} && !${Settings.GetBool[focusFollowsMouse]}
        {
            echo Applying.
            This:Apply
        }
    }

    method Event_OnHotkeyFocused()
    {
        echo "isb2_windowlayoutengine:Event_OnHotkeyFocused"
        if !${Settings.GetBool[swapOnHotkeyFocused]}
            return

        if ${This:RefreshActiveStatus(exists)}
            This:Apply
    }

    method Event_OnWindowStateChanging(string change)
    {
      ;  echo "isb2_windowlayoutengine:OnWindowStateChanging ${change~}"
    }

    method Event_OnMouseEnter()
    {
        This:ApplyFocusFollowMouse
    }

    method Event_OnMouseExit()
    {

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