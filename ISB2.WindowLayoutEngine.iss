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
    variable jsonvalueref SwapGroups="[]"

    variable jsonvalueref VFXSettings="{}"

    variable jsonvalueref CurrentRegion

    variable string LastApplied

    variable bool FocusFollowsMouse
    variable bool VFXRenderer
    variable bool VFXLayout
    variable uint Group

    variable bool Roaming
    variable uint RoamingSlot
    variable uint BorrowedSlot

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

    method VFXLayout_OnSlotActiveStatusChanged(uint numSlot, bool newValue)
    {
;        InnerSpace:Relay[uplink,"echo VFXLayout_OnSlotActiveStatusChanged ${numSlot} ${newValue} (borrowed=${BorrowedSlot})"]

                if ${newValue}
                {
                    if ${RoamingSlot} != ${numSlot}
                    {                      
;                        InnerSpace:Relay[uplink,"echo SetFeedName modify is${RoamingSlot}"]
                        LGUI2.Element["isb2.vfx.VFX Window Layout.vfx.slot${numSlot}"]:SetFeedName[is${RoamingSlot}]
                    }
                    else
                    {
                        ; turn off vfx for slot
                        if ${RoamingSlot}
                        {
;                            InnerSpace:Relay[uplink,"echo SetFeedName restore is${BorrowedSlot}"]
                            LGUI2.Element["isb2.vfx.VFX Window Layout.vfx.slot${BorrowedSlot}"]:SetFeedName[is${BorrowedSlot}]
                        }
                        else
                        {
;                            InnerSpace:Relay[uplink,"echo SetFeedName hide is${numSlot}"]
                            LGUI2.Element["isb2.vfxWindow.VFX Window Layout.vfx.slot${numSlot}"]:SetVisibility[Hidden]
                        }
                    }
                    BorrowedSlot:Set[${numSlot}]
                }
                else
                {
                    ; turn on vfx for slot                    
                    if ${BorrowedSlot} != ${numSlot}
                    {
;                        InnerSpace:Relay[uplink,"echo SetFeedName restore is${BorrowedSlot} show ${numSlot}"]
                        LGUI2.Element["isb2.vfx.VFX Window Layout.vfx.slot${BorrowedSlot}"]:SetFeedName[is${BorrowedSlot}]
                        LGUI2.Element["isb2.vfxWindow.VFX Window Layout.vfx.slot${numSlot}"]:SetVisibility[Visible]
                    }
                }

    }

    method Remote_ActiveStatusChanged(string sessionName, uint numGroup, bool newValue, ewindowlayoutreason reason=0)
    {
        echo "isb2_windowlayoutengine:\ayRemote_ActiveStatusChanged\ax \"${sessionName~}\" ${numGroup} ${newValue} ${reason}"
        if ${numGroup}==${Group}
        {
            if ${VFXRenderer}
            {
                This:VFXLayout_OnSlotActiveStatusChanged["${sessionName.Right[-2]}",${newValue}]
            }

            if !${VFXLayout}
            {
                ; roaming slot?
                if ${newValue} && ${Roaming}
                {
                    ; take the inactive region
                    BorrowedSlot:Set["${sessionName.Right[-2]}"]
                    This:SelectInactiveRegion["${This.GetInactiveRegionForSlot["${BorrowedSlot}"]}"]                    
                    echo "Roaming: Inactive Region now ${This.NumInactiveRegion}"
                    This:SetActiveStatus[0,Remote]
                    This:Apply
                    return
                }
            }

            if ${Settings.GetBool[swapOnActivate]} 
            {
                if ${This:RefreshActiveStatus[Remote](exists)}
                {
                    if !${FocusFollowsMouse}
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
        echo "\agRefreshActiveStatus\ax ${reason}"
        variable bool newValue=${Display.Window.IsForeground}
        if ${forceUpdate} || ${newValue}!=${Active}
        {
            return ${This:SetActiveStatus[${newValue},${reason.Value}](exists)}
        }
        return FALSE
    }

    member:uint GetSwapGroupForSlot(uint numSlot)
    {
        variable uint numRegion=${This.GetInactiveRegionForSlot[${numSlot}]}
        if ${numRegion}
        {
            if ${Regions.Has[${numRegion},swapGroup]}
                return ${Regions.GetInteger[${numRegion},swapGroup]}
            return 1
        }

        variable jsonvalue joQuery
        joQuery:SetValue["$$>
        {
            "eval":"Select.Get[roamingSlot\]",
            "op":"==",
            "value":${numSlot}
        }
        <$$"]
    ;    echo "${Session}: GetSwapGroupForSlot giving ${SwapGroups.SelectKey[joQuery]} from ${joQuery~}"
        return ${SwapGroups.SelectKey[joQuery]}
    }

    member:uint GetInactiveRegionForSlot(uint numSlot)
    {
        variable jsonvalueref joQuery="$$>
        {
            "eval":"Select.Get[slot\]",
            "op":"==",
            "value":${numSlot}
        }
        <$$"
        return ${Regions.SelectKey[joQuery]}
    }

    member:uint VFXLayout_GetSwapGroup()
    {
        ; compare ISB2.Slot to highest slot number actually in use, noting that swap groups can have a roamingSlot
        ; that will identify the Swap Group assigned to this dxnothing window


        variable uint highestSlot=0

        variable uint n
        variable uint checkSlot
        variable jsonvalueref ja="Regions"
        for ( n:Set[1] ; ${n} <= ${ja.Used} ; n:Inc )
        {
            checkSlot:Set[${ja.GetInteger[${n},slot]}]

            if ${checkSlot} > ${highestSlot}
                highestSlot:Set[${checkSlot}]
        }

        ja:SetReference["SwapGroups"]
        for ( n:Set[1] ; ${n} <= ${ja.Used} ; n:Inc )
        {
            checkSlot:Set[${ja.GetInteger[${n},roamingSlot]}]

            if ${checkSlot} > ${highestSlot}
                highestSlot:Set[${checkSlot}]
        }

;        echo "VFXLayout_GetSwapGroup ${ISB2.Slot}-${highestSlot}=${ISB2.Slot.Dec[${highestSlot}]}"
        return ${ISB2.Slot.Dec[${highestSlot}]}
    }

    method OffsetRegion(jsonvalueref jo, int offsetX, int offsetY)
    {
        variable int x=${jo.GetInteger[bounds,1]}
        variable int y=${jo.GetInteger[bounds,2]}

;        echo OffsetRegion ${offsetX},${offsetY} ${jo~}

        jo.Get[bounds]:SetInteger[1,"${x.Dec[${offsetX}]}"]
        jo.Get[bounds]:SetInteger[2,"${y.Dec[${offsetY}]}"]

        echo After=${jo~}
    }

    method ExpandEdge(jsonvalueref ja, jsonvalueref jaRegion, uint num)
    {
        variable int newVal = ${jaRegion.GetInteger[${num}]}
        variable int oldVal = ${ja.GetInteger[${num}]}


        if ${num}>=3
        {
            ; right/bottom edge
            
            ; first convert width/height to right/bottom
            newVal:Inc["${jaRegion.GetInteger[${num.Dec[2]}]}"]

            if ${newVal} > ${oldVal}
                ja:SetInteger[${num},${newVal}]
        }
        else
        {
            ; left/top edge
            if ${newVal} < ${oldVal}
                ja:SetInteger[${num},${newVal}]
        }
    }

    method ExpandEdges(jsonvalueref ja, jsonvalueref joRegion)
    {
        if !${ja.Used}
        {
            ja:AddInteger["${joRegion.GetInteger[bounds,1]}"]
            ja:AddInteger["${joRegion.GetInteger[bounds,2]}"]
            ja:AddInteger["${joRegion.GetInteger[bounds,3].Inc[${joRegion.GetInteger[bounds,1]}]}"]
            ja:AddInteger["${joRegion.GetInteger[bounds,4].Inc[${joRegion.GetInteger[bounds,2]}]}"]

;            echo "ExpandEdges: ${joRegion~} ${ja~}"
            return
        }

        This:ExpandEdge[ja,"joRegion.Get[bounds]",1]
        This:ExpandEdge[ja,"joRegion.Get[bounds]",2]
        This:ExpandEdge[ja,"joRegion.Get[bounds]",3]
        This:ExpandEdge[ja,"joRegion.Get[bounds]",4]

;        echo "ExpandEdges: ${ja~}"
    }

    member:jsonvalueref Regions_GetEdges(jsonvalueref joRegions)
    {
        variable jsonvalue ja="[]"

        joRegions:ForEach["This:ExpandEdges[ja,ForEach.Value]"]

        if !${ja.Used}
            ja:SetValue["[0,0,0,0]"]

        return ja
    }

    member:jsonvalueref SwapGroup_GetRegions(uint numSwapGroup)
    {
        variable jsonvalue joQuery
        if ${numSwapGroup}==1
        {
            joQuery:SetValue["$$>
            {
                "eval":"Select.Get[swapGroup\]",
                "op":"||",
                "list":[
                    {
                        "op":"==",
                        "value":null
                    },
                    {
                        "op":"==",
                        "value":${numSwapGroup}
                    }
                \]
            }
            <$$"]
        }
        else
        {

            joQuery:SetValue["$$>
            {
                "eval":"Select.Get[swapGroup]",
                "op":"==",
                "value":${numSwapGroup}
            }
            <$$"]

        }
;        echo "Regions.SelectValues[${joQuery~}]"
        return "Regions.SelectValues[joQuery]"
    }

    member:jsonvalueref SwapGroup_GetHomeRegions(uint numSwapGroup)
    {
        variable jsonvalue joQuery
        if ${numSwapGroup}==1
        {
            joQuery:SetValue["$$>
            {
                "op":"&&",
                "list":[
                    {
                        "eval":"Select.Has[slot\]"
                    },
                    {
                        "eval":"Select.Get[swapGroup\]",
                        "op":"||",
                        "list":[
                            {
                                "op":"==",
                                "value":null
                            },
                            {
                                "op":"==",
                                "value":${numSwapGroup}
                            }
                        \]
                    }
                \]
            }
            <$$"]
        }
        else
        {

            joQuery:SetValue["$$>
            {
                "op":"&&",
                "list":[
                    {
                        "eval":"Select.Has[slot\]"
                    },
                    {
                        "eval":"Select.Get[swapGroup]",
                        "op":"==",
                        "value":${numSwapGroup}
                    }
                \]
            }
            <$$"]

        }
;        echo "Regions.SelectValues[${joQuery~}]"
        return "Regions.SelectValues[joQuery]"
    }    

    member:jsonvalueref VFXLayout_GenerateVFXOutput(uint numRegion, jsonvalueref joRegion)
    {
        variable jsonvalue jo="{}"

        jo:SetString[name,"vfx.slot${joRegion.GetInteger[slot]}"]
        jo:SetInteger[x,${joRegion.GetInteger[bounds,1]}]
        jo:SetInteger[y,${joRegion.GetInteger[bounds,2]}]
        jo:SetInteger[width,${joRegion.GetInteger[bounds,3]}]
        jo:SetInteger[height,${joRegion.GetInteger[bounds,4]}]
        jo:SetString[feedName,"is${joRegion.GetInteger[slot]}"]

        jo:SetBool[sendKeyboard,1]
        jo:SetBool[sendMouse,1]
        jo:SetBool[useLocalBindings,0]
        jo:SetBool[permanent,1]

        return jo
    }

    member:jsonvalueref VFXLayout_GetSettings()
    {
        ; assume this is a DxNothing window.
        
        ; 1. determine the dxnothing window number
        ; that will identify the Swap Group assigned to this dxnothing window
        
        ; 2. gather the desktop area bounds for the swap group
        ; that becomes the region for the dxNothing window

        ; 3. generate VFX Regions for each of the Slots

        variable jsonvalue jo="{}"
        
        variable uint numDxNothing="${This.VFXLayout_GetSwapGroup}"
        if !${numDxNothing}
            numDxNothing:Set[1]
        jo:SetInteger["swapGroup",${numDxNothing}]
        jo:SetByRef["regions","This.SwapGroup_GetRegions[${numDxNothing}]"]
        jo:SetByRef["homeRegions","This.SwapGroup_GetHomeRegions[${numDxNothing}]"]
        jo:SetByRef["edges","This.Regions_GetEdges[\"jo.Get[homeRegions]\"]"]

        variable jsonvalue joLayoutRegion="{\"bounds\":[0,0,0,0]}"
        joLayoutRegion.Get[bounds]:SetInteger[1,${jo.GetInteger[edges,1]}]
        joLayoutRegion.Get[bounds]:SetInteger[2,${jo.GetInteger[edges,2]}]
        joLayoutRegion.Get[bounds]:SetInteger[3,${jo.GetInteger[edges,3].Dec[${jo.GetInteger[edges,1]}]}]
        joLayoutRegion.Get[bounds]:SetInteger[4,${jo.GetInteger[edges,4].Dec[${jo.GetInteger[edges,2]}]}]
        jo:SetByRef[layoutRegion,joLayoutRegion]

        jo.Get[homeRegions]:ForEach["This:OffsetRegion[ForEach.Value,${jo.GetInteger[edges,1]},${jo.GetInteger[edges,2]}]"]

        ; build a VFX Sheet out of the home regions
        variable jsonvalue joVFXSheet="{\"name\":\"VFX Window Layout\",\"enable\":true,\"outputs\":[]}"
        jo.Get[homeRegions]:ForEach["joVFXSheet.Get[outputs]:AddByRef[\"This.VFXLayout_GenerateVFXOutput[\${ForEach.Key},ForEach.Value]\"]"]

        jo:SetByRef[vfxSheet,joVFXSheet]
        return jo
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

        VFXSettings:SetReference["{}"]
        VFXLayout:Set["${Settings.GetBool[useVFXLayout]}"]

        Regions:SetReference["${jo.Get[regions]}"]
        SwapGroups:SetReference["${jo.Get[swapGroups]}"]

        if ${Settings.Has[resetRegion]}
            NumResetRegion:Set["${Settings.GetInteger[resetRegion]}"]

        Group:Set["${This.GetSwapGroupForSlot[${ISB2.Slot}]}"]
        if !${Group}
        {
            Group:Set[1]

            if ${VFXLayout}
            {
                VFXRenderer:Set[1]
                VFXSettings:SetReference[This.VFXLayout_GetSettings]

                Group:Set["${VFXSettings.GetInteger[swapGroup]}"]
            }
        }
        else
            VFXRenderer:Set[0]

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

        if ${VFXRenderer}
        {
            echo "isb2_windowlayoutengine: \atActivating VFX Layout Renderer for Swap Group ${Group}\ax"
            ; echo "${VFXSettings~}"
            ; add a new region for our VFX Layout area
            Regions:AddByRef["VFXSettings.Get[layoutRegion]"]
            ; pick this region
            NumActiveRegion:Set["${Regions.Used}"]
            NumResetRegion:Set["${Regions.Used}"]

            ISB2BroadcastMode:Suppress
            ISB2:InstallVFXSheet["VFXSettings.Get[vfxSheet]"]
        }

        LGUI2.Element["windowLayoutEngine.events"]:FireEventHandler[regionsChanged]

        if ${VFXLayout}
        {
            FocusClick click
            ISSession:SetFocusFollowsMouse[1]        
            FocusFollowsMouse:Set[1]

            if ${Roaming} && !${VFXRenderer}
                Roaming:Set[0]            
        }
        else
        {
            FocusFollowsMouse:Set[${Settings.GetBool[focusFollowsMouse]}]
            ISSession:SetFocusFollowsMouse[${FocusFollowsMouse}]

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
        }

        if ${Roaming} || ${VFXLayout}
            NumInactiveRegion:Set[0]
        else
        {
            NumInactiveRegion:Set[${This.GetInactiveRegionForSlot[${ISB2.Slot}]}]
        }
        variable jsonvalueref joInactiveRegion
        joInactiveRegion:SetReference["Regions.Get[joInactiveRegion]"]

        echo active=${NumActiveRegion} inactive=${NumInactiveRegion} reset=${NumResetRegion}
        This:SelectRegions[${NumActiveRegion},${NumInactiveRegion}]
        This:SelectResetRegion[${NumResetRegion}]

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

        if ${Settings.GetBool[swapOnInternalActivate]} 
        {
            if !${This:RefreshActiveStatus[OnInternalActivate](exists)}
            {
                return
            }
        }

        if ${Settings.GetBool[-default,1,refreshOnInternalActivate]} && !${FocusFollowsMouse}
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

        if ${Settings.GetBool[-default,1,refreshOnActivate]} && !${FocusFollowsMouse}
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

        if ${Settings.GetBool[-default,1,refreshOnDeactivate]} && !${FocusFollowsMouse}
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
        if !${VFXLayout}
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
        if !${FocusFollowsMouse}
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

;        InnerSpace:Relay[uplink,"echo \"foreground=\${ISUplink.Resolve[foreground]}\""]
;        echo "isb2_windowlayoutengine:FocusSelf: relay foreground \"ISB2WindowLayout:FocusWindow[${Display.Window~}]\""
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