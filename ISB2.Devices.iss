objectdef(global) isb2_devices
{
    static variable isb2_devices Instance

    static variable jsonvalueref AddingItem="{}"

    variable collection:weakref Devices

    method Initialize()
    {
        
    }

    method Shutdown()
    {
        midi:CloseAllDevicesOut
        LGUI2:UnloadPackageFile[ISB2.Devices.lgui2Package.json]
    }

    static method SetUseSynth(bool newValue)
    {
        ISB2.Settings.Get[-init,{},midi]:SetBool[useSynth,${newValue}]
        ; echo ${ISB2.Settings}
        ISB2:AutoStoreSettings
    }

    method Init()
    {
        LGUI2:PushSkin["${ISB2.UseSkin~}"]
        LGUI2:LoadPackageFile[ISB2.Devices.lgui2Package.json]
        LGUI2:PopSkin["${ISB2.UseSkin~}"]

        /*
        jo:SetValue["$$>{
            "name":"synth",
            "deviceName":"Microsoft GS Wavetable Synth",
            "deviceType":"isb2_synthGS",
            "deviceIndex":1
            }
            <$$"]
        This:AddDevice[jo]


        joTest:SetValue["$$>{
            "name":"launchpad mini",
            "deviceName":"Launchpad Mini",
            "deviceType":"isb2_launchpadMiniMK2",
            "deviceIndex":1
            }
            <$$"]
        This:AddDevice[joTest]

        joTest:SetValue["$$>{
            "name":"launchpad mk2",
            "deviceName":"Launchpad MK2",
            "deviceType":"isb2_launchpadMK2",
            "deviceIndex":1
            }
            <$$"]
        This:AddDevice[joTest]       
        /**/

        This:RefreshOutDevices

    }



    method RefreshOutDevices()
    {
        Devices:Clear

        variable jsonvalue jo

        if ${ISB2.Settings.GetBool[midi,useSynth]}
        {
            jo:SetValue["$$>{
                "name":"synth",
                "deviceName":"Microsoft GS Wavetable Synth",
                "deviceType":"isb2_synthGS",
                "deviceIndex":1
                }
                <$$"]
            This:AddDevice[jo]
        }

        ISB2.Settings.Get[midi,outDevices]:ForEach["This:AddDevice[ForEach.Value]"]
    }

    method OnRemoveOutputDevice()
    {
        echo "OnRemoveOutputDevice ${Context(type)} ${Context.Element.ID} ${Context.Element.Context(type)} ${Context.Element.Context.Index}"
        Context.Element.Context.ItemList.ItemsSource:Erase[${Context.Element.Context.Index}]
        ISB2:AutoStoreSettings

        This:RefreshOutDevices

        return TRUE
    }

    method OnAddOutputDevice()
    {
        variable jsonvalueref joAdd="isb2_devices.AddingItem.Duplicate"
        if !${joAdd.Reference(exists)}
            return FALSE

        if !${joAdd.Get[name]~.NotNULLOrEmpty}
            return FALSE
        if !${joAdd.Get[deviceName]~.NotNULLOrEmpty}
            return FALSE
        if !${joAdd.Get[deviceType]~.NotNULLOrEmpty}
            return FALSE

        ISB2.Settings.Get[-init,"{}",midi].Get[-init,"[]",outDevices]:AddByRef[joAdd]

        LGUI2.Element[isb2.events]:FireEventHandler[onMidiOutDevicesChanged]

        This:RefreshOutDevices

        ISB2:AutoStoreSettings

        return TRUE
    }

    member:string GetDeviceType(string name)
    {
        echo "GetDeviceType ${name~}"
        switch ${name}
        {
            case Launchpad Mini
                return isb2_launchpadMiniMK2
            case Launchpad MK2
                return isb2_launchpadMK2
        }
        return ""
    }

    method AddDevice(jsonvalueref joDevice)
    {
        ; name (e.g. My Launchpad)
        ; deviceName (e.g. Launchpad Mini)
        ; deviceIndex (e.g. 1)
;        echo AddDevice ${joDevice~}
        if !${joDevice.Has[-string,deviceName]}
            return

        variable string deviceType
        if ${joDevice.Has[-string,deviceType]}
            deviceType:Set["${joDevice.Get[deviceType]~}"]
        else
            deviceType:Set["${This.GetDeviceType["${joDevice.Get[deviceName]~}"]~}"]

        if !${deviceType.NotNULLOrEmpty}
        {
            ; no ISBoxer 2 native support
            ;echo GetDeviceType failed
            return
        }

        Devices:Set["${joDevice.Get[name]~}","${deviceType~}.Create[object,joDevice]"]
    }

    method RemoteMIDIOut()
    {        
        variable jsonvalueref joAction="Context.Get[action]"

        echo "RemoteMIDIOut: ${joAction~}"

        variable weakref useDevice
        useDevice:SetReference["Devices.Get[\"${joAction.Get[device]~}\"]"]
        if !${useDevice.Reference(exists)}
        {
            echo "RemoteMIDIOut: device ${joAction.Get[device]~} not found"
            return
        }

        useDevice:Output["joAction.Get[output]"]
    }    
}

objectdef isb2_device
{
    variable weakref OutDevice

    ; name of the device, e.g. "My Launchpad"
    variable string Name
    ; index of the device, e.g. 1 being the first "Launchpad Mini" instance
    variable uint Index
    ; device-specified name
    variable string DeviceName

    method Initialize(jsonvalueref joDevice)
    {
        Name:Set["${joDevice.Get[name]~}"]
        Index:Set["${joDevice.GetInteger[-default,1,deviceIndex]}"]
        DeviceName:Set["${joDevice.Get[-default,"",deviceName]~}"]
    }

    method Shutdown()
    {
        echo "isb2_device:Shutdown ${OutDevice.Name}"
        OutDevice:Close
    }

    method DetectDevice()
    {
        if ${OutDevice.Reference(exists)}
            return
        
;        echo "isb2_launchpadMK2:DetectDevice"
        variable jsonvalueref joQuery
        joQuery:SetReference["{\"op\":\"==\",\"value\":true}"]
        joQuery:SetString[eval,"Select.Get[deviceName].StartsWith[\"${DeviceName~}\"]"]        
;        joQuery:SetReference["$$>{"eval":"Select.Get[deviceName\].StartsWith[\"${DeviceName~}\"\]","op":"==","value":true}<$$"]

;        echo "query=${joQuery~}"
        variable jsonvalueref joDevice

;        echo "selected values=${midi.OutDevices.SelectValues[joQuery]~}"

;        echo "index = ${Index}"
        joDevice:SetReference["midi.OutDevices.SelectValues[joQuery].Get[${Index}]"]
;        echo "device=${joDevice~}"

        if !${joDevice.Reference(exists)}
        {
            ; check attached devices
            variable int idx
;            echo "${midi.AttachedOutDevices.SelectKeys[joQuery]~}"
            idx:Set[${midi.AttachedOutDevices.SelectKeys[joQuery].Get[${Index}]}]
;            echo idx = ${idx}

            if ${idx}
            {
;                echo "isb2_devices: OpenDeviceOut ${idx} for ${Name~}"
                midi:OpenDeviceOut[${idx}]
            }

            joDevice:SetReference["midi.OutDevices.SelectValues[joQuery].Get[${Index}]"]
        }

        OutDevice:SetReference["midi.OutDevice[\"${joDevice.Get[name]~}\"]"]
    }    

    method TestOutput()
    {
        variable jsonvalueref ja="[]"
;        ja:Add["{\"type\":\"note on\",\"note\":64,\"value\":1.0}"]
        ja:Add["{\"type\":\"rgb all\",\"value\":[0.0,0.6,0.0]}"]
;        ja:Add["{\"type\":\"rgb\",\"x\":1,\"y\":1,\"value\":[0.0,0.3,0.0]}"]
;        ja:Add["{\"type\":\"rgb\",\"x\":2,\"y\":1,\"value\":[0.0,0.6,0.0]}"]
;        ja:Add["{\"type\":\"rgb\",\"x\":3,\"y\":1,\"value\":[0.0,1.0,0.0]}"]
;        ja:Add["{\"type\":\"rgb\",\"x\":1,\"y\":2,\"value\":[0.3,0.0,0.0]}"]
;        ja:Add["{\"type\":\"rgb\",\"x\":2,\"y\":2,\"value\":[0.6,0.0,0.0]}"]
;        ja:Add["{\"type\":\"rgb\",\"x\":3,\"y\":2,\"value\":[1.0,0.0,0.0]}"]
;        ja:Add["{\"type\":\"text\",\"value\":\"well hello there\",\"speed\":7,\"color\":54}"]

        echo TestOutput ${ja~}
        This:Output[ja]
    }

    method Output(jsonvalueref val)
    {
        if ${val.Type.Equal[object]}
        {            
            return ${This:OutputObject[val](exists)}
        }

        if !${val.Type.Equal[array]}
            return FALSE

        val:ForEach["This:OutputObject[ForEach.Value]"]
        return TRUE
    }

    method OutputObject(jsonvalueref jo)
    {
;        echo "isb2_device:OutputObject ${jo~}"
        switch ${jo.Get[type]}
        {
            case note on
                {
;                    echo OutDevice:SendNoteOn[${jo.GetInteger[-default,0,channel]},${jo.GetInteger[note]},${jo.GetNumber[value]}]
                    OutDevice:SendNoteOn[${jo.GetInteger[-default,0,channel]},${jo.GetInteger[note]},${jo.GetNumber[value]}]
                    return TRUE
                }
                break
            case note off
                {
                    OutDevice:SendNoteOff[${jo.GetInteger[channel]},${jo.GetInteger[note]},${jo.GetNumber[value]}]
                    return TRUE
                }
                break
        }
        return FALSE
    }
}

objectdef(global) isb2_synthGS inherits isb2_device
{

    method Initialize(jsonvalueref joDevice)
    {
        This[parent]:Initialize[joDevice]

        if !${DeviceName.NotNULLOrEmpty}
            DeviceName:Set["Microsoft GS Wavetable Synth"]

        This:DetectDevice
    }


    
}

objectdef(global) isb2_launchpadMK2 inherits isb2_device
{
    method Initialize(jsonvalueref joDevice)
    {
        This[parent]:Initialize[joDevice]

        ; Launchpad MK2
        if !${DeviceName.NotNULLOrEmpty}
            DeviceName:Set["Launchpad MK2"]

        This:DetectDevice

;        Event[OnFrame]:AttachAtom[This:Pulse]

        if ${ISUplink(exists)}
            This:SetAllRGB[0,0,0]
    }

    variable int imgX=1
    variable int imgY=1
    variable int pulseDelay=0

    variable int dirX=2
    variable int dirY=3

    method Pulse()
    {
        pulseDelay:Dec
        if ${pulseDelay}>0
            return

        variable bool nextY
        imgX:Inc[${dirX}]
        if ${imgX}<1
        {
            imgX:Set[1]
            dirX:Set["${Math.Abs[${dirX}]}"]
            nextY:Set[1]
        }
        elseif ${imgX}>25
        {
            imgX:Set[25]
            dirX:Set["-${dirX}"]
            nextY:Set[1]
        }

        if ${nextY}
        {
            imgY:Inc[${dirY}]
            if ${imgY}<1
            {
                imgY:Set[1]
                dirY:Set["${Math.Abs[${dirY}]}"]
            }
            elseif ${imgY}>25
            {
                imgY:Set[25]
                dirY:Set["-${dirY}"]
            }
        }

        This:TestSetGridByBitmap[${imgX},${imgY},9,9]
        pulseDelay:Set[8]
    }

    method OutputObject(jsonvalueref jo)
    {
;        echo "isb2_launchpadMK2:OutputObject ${jo~}"
        switch ${jo.Get[type]}
        {
            case note on
                return FALSE
            case note off
                return FALSE
            case rgb
                {
 ;                   echo This:SetGridRGB[${jo.GetInteger[-default,1,y]}${jo.GetInteger[-default,1,x]},${jo.GetNumber[value,1]},${jo.GetNumber[value,2]},${jo.GetNumber[value,3]}]
                    This:SetGridRGB[${jo.GetInteger[-default,1,y]}${jo.GetInteger[-default,1,x]},${jo.GetNumber[value,1]},${jo.GetNumber[value,2]},${jo.GetNumber[value,3]}]
                    return TRUE
                }
                break
            case rgb all
                {
;                    echo This:SetAllRGB[${jo.GetNumber[value,1]},${jo.GetNumber[value,2]},${jo.GetNumber[value,3]}]
                    This:SetAllRGB[${jo.GetNumber[value,1]},${jo.GetNumber[value,2]},${jo.GetNumber[value,3]}]
                    return TRUE
                }
                break
            case text
                {
                    ; string text uint color=124, uint speed=5, int loop=0
                    This:ScrollText["${jo.Get[value]~}",${jo.GetInteger[-default,124,color]},${jo.GetInteger[-default,5,speed]},${jo.GetBool[loop]}]
                    return TRUE
                }
                break
        }

        if ${This[parent]:OutputObject[jo](exists)}
            return TRUE

        return FALSE        
    }    

    method SetGrid(uint nLED, uint color1, uint mode, uint color2)
    {        
        ;echo OutDevice:SendNoteOnInt[${numChannel},${nLED},${numColor}]
        switch ${mode}
        {
            case 0
                OutDevice:SendNoteOnInt[1,${nLED},0]            
                OutDevice:SendNoteOnInt[0,${nLED},${color1}]            
                break
            case 1
                OutDevice:SendNoteOnInt[0,${nLED},${color1}]            
                OutDevice:SendNoteOnInt[1,${nLED},${color2}]            
                break
            case 2
                OutDevice:SendNoteOnInt[1,${nLED},0]            
                OutDevice:SendNoteOnInt[0,${nLED},${color1}]            
                OutDevice:SendNoteOnInt[2,${nLED},${color1}]            
                break
        }        
    }

    method RandomizeGrid()
    {
        variable int col
        variable int row

        variable jsonvalueref ja="[]"
        for (row:Set[1] ; ${row} <= 8 ; row:Inc)
        {
            for (col:Set[1] ; ${col} <= 9 ; col:Inc)
            {
                ja:Add["{\"type\":\"sysex\",\"value\":[0,32,41,2,24,11,${row}${col},${Math.Rand[64]},${Math.Rand[64]},${Math.Rand[64]}]}"]
            }
        }

        OutDevice:SendJSON[ja]
    }

    method AppendSysExValue(jsonvalueref jaSysex, jsonvalueref ja, int numValue)
    {
        ; echo "AppendSysExValue ${jaSysex~} ${ja~} ${numValue~}"
        switch ${ja.GetType[${numValue}]}
        {
            case integer
                jaSysex:AddInteger["${ja.GetInteger[${numValue}]}"]
                break
            case number
                jaSysex:AddInteger["${ja.GetNumber[${numValue}].Mul[63]}"]
                break
        }
    }

    method AppendSysEx(jsonvalueref joSysex, jsonvalueref ja)
    {
        variable jsonvalueref jaSysex
        
        variable int count=${joSysex.GetInteger[count]}
        
        if ${count}>=50
        {
;            echo ${joSysex~}            
            OutDevice:SendJSON[joSysex]
            count:Set[0]
            joSysex:Set[value,"[0,32,41,2,24,11]"]
        }
        joSysex:SetInteger[count,${count.Inc}]

        jaSysex:SetReference["joSysex.Get[value]"]

        ;ja:ForEach["jaSysex:Add[\${ForEach.Value.AsJSON~}]"]
        ja:ForEach["This:AppendSysExValue[jaSysex,ja,\${ForEach.Key}]"]
    }

    method SetGridByArray(jsonvalueref ja)
    {
        variable jsonvalueref joSysex="{\"type\":\"sysex\",\"value\":[0,32,41,2,24,11]}"

        ja:ForEach["This:AppendSysEx[joSysex,ForEach.Value]"]

;        echo ${joSysex~}
        if ${joSysex.GetInteger[count]}
            OutDevice:SendJSON[joSysex]
    }

    method TestSetGridByArray()
    {
        variable jsonvalueref ja="[]"
        ja:Add["[11,0.0,0.4,0.0]"]
        ja:Add["[22,0.0,0.4,0.0]"]
        ja:Add["[33,0.0,0.4,0.0]"]
        ja:Add["[44,0.0,0.4,0.0]"]
        ja:Add["[55,0.0,0.4,0.0]"]
        ja:Add["[66,0.0,0.4,0.0]"]
        ja:Add["[77,0.0,0.4,0.0]"]
        ja:Add["[88,0.0,0.4,0.0]"]

        This:SetGridByArray[ja]
    }


    method SetGridByBitmap(jsonvalueref jaBitmap, jsonvalueref joSourceRect, jsonvalueref joDestRect)
    {

        variable jsonvalueref ja="[]"

        variable int x = 1
        variable int y = 1
        variable int w = 8
        variable int h = 8
        variable int maxX = ${jaBitmap.Get[1].Used}
        variable int maxY = ${jaBitmap.Used}

        if ${joSourceRect.Reference(exists)}
        {
            x:Set[${joSourceRect.GetInteger[-default,1,x]}]
            y:Set[${joSourceRect.GetInteger[-default,1,y]}]
            w:Set[${joSourceRect.GetInteger[-default,8,w]}]
            h:Set[${joSourceRect.GetInteger[-default,8,h]}]

;            if ${w}>9
;                w:Set[9]
;            if ${h}>9
;                h:Set[9]
        }

        if ${maxX} > ${x}+${w}
            maxX:Set[${x}+${w}+1]

        if ${maxY} > ${y}+${h}
            maxY:Set[${y}+${h}+1]

        variable int _x
        variable int _y
        variable int _bmpX
        variable int _bmpY

        variable int fromX=1
        variable int fromY=1
        variable int toX=8
        variable int toY=8

        if ${joDestRect.Reference(exists)}
        {
            fromX:Set[${joDestRect.GetInteger[-default,1,x]}]
            fromY:Set[${joDestRect.GetInteger[-default,1,y]}]
            w:Set[${joDestRect.GetInteger[-default,8,w]}]
            h:Set[${joDestRect.GetInteger[-default,8,h]}]

;            if ${toX} > ${fromX} + ${w}
                toX:Set[${fromX} + ${w} -1] 

;            if ${toY} > ${fromY} + ${h}
                toY:Set[${fromY} + ${h} -1]

            if ${toX} > 9
                toX:Set[9]
            if ${toY} > 8
                toY:Set[8]
;            echo "fromX ${fromX} toX ${toX} fromY ${fromY} toY ${toY}"
        }

        variable jsonvalueref jaPixel

        _bmpY:Set[${y}]
        for (_y:Set[${toY}] ; ${_y}>=${fromY} ; _y:Dec)
        {
            _bmpX:Set[${x}]
            for (_x:Set[${fromX}] ; ${_x}<=${toX} ; _x:Inc)            
            {

                if ${_bmpY} <= ${maxY} && ${_bmpX} <= ${maxX}
                {
                    jaPixel:SetReference["jaBitmap.Get[${_bmpY},${_bmpX}]"]
                    if ${jaPixel.Reference(exists)}
                        ja:Add["[${_y}${_x},${jaPixel~.Left[-2].Right[-1]}]"]
                    else
                        ja:Add["[${_y}${_x},0,0,0]"]
                }
                else
                {
                    ja:Add["[${_y}${_x},0,0,0]"]
                }

                _bmpX:Inc
            }

            _bmpY:Inc
        }

/*
        for (_y:Set[${y}] ; ${_y}<${maxY} ; _y:Inc)
        {
            for (_x:Set[${x}] ; ${_x}<${maxX} ; _x:Inc)
            {
                ja:Add["[${outY}${outX},${jaBitmap.Get[${_y},${_x}]~.Left[-2].Right[-1]}]"]
                outX:Inc
            }
            outX:Set[1]
            outY:Dec
        }
*/
;        echo ${ja~}
        This:SetGridByArray[ja]
    }

    method TestSetGridByBitmap(int x=1, int y=1, int w=8, int h=8)
    {        
        variable jsonvalueref jaBitmap="LGUI2.Skin[default].Template[isb2-logo-bitmap].Get[bitmap]"
        /*
        variable jsonvalueref jaBitmap="[]"

        jaBitmap:Add["[[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0]]"]
        jaBitmap:Add["[[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0]]"]
        jaBitmap:Add["[[1.0,0.4,1.0],[1.0,0.4,1.0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0]]"]
        jaBitmap:Add["[[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0]]"]
        jaBitmap:Add["[[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0]]"]
        jaBitmap:Add["[[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0]]"]
        jaBitmap:Add["[[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0]]"]
        jaBitmap:Add["[[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0]]"]
        jaBitmap:Add["[[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0]]"]
        jaBitmap:Add["[[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0]]"]
        jaBitmap:Add["[[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0],[0,0.4,0]]"]
/**/
        variable jsonvalueref joSourceRect="{\"x\":${x},\"y\":${y},\"w\":${w},\"h\":${h}}"
        variable jsonvalueref joDestRect="{\"x\":1,\"y\":1,\"w\":9,\"h\":8}"


        This:SetGridByBitmap[jaBitmap,joSourceRect,joDestRect]
    }


    method SetAllRGB(float r, float g, float b)
    {
        variable int col
        variable int row


        variable int ir=${r.Mul[63]}
        variable int ig=${g.Mul[63]}
        variable int ib=${b.Mul[63]}

        variable jsonvalueref ja="[]"

        for (row:Set[1] ; ${row} <= 8 ; row:Inc)
        {            
            ja:Add["{\"type\":\"sysex\",\"value\":[0,32,41,2,24,11,${row}1,${ir},${ig},${ib},${row}2,${ir},${ig},${ib},${row}3,${ir},${ig},${ib},${row}4,${ir},${ig},${ib},${row}5,${ir},${ig},${ib},${row}6,${ir},${ig},${ib},${row}7,${ir},${ig},${ib},${row}8,${ir},${ig},${ib},${row}9,${ir},${ig},${ib}]}"]

;            for (col:Set[1] ; ${col} <= 9 ; col:Inc)
;            {
;                ja:Add["{\"type\":\"sysex\",\"value\":[0,32,41,2,24,11,${row}${col},${ir},${ig},${ib}]}"]
;            }
        }

        OutDevice:SendJSON[ja]
    }

    method SetGridRGB(uint nLED, float r, float g, float b)
    {
        variable jsonvalueref jo="{\"type\":\"sysex\",\"value\":[0,32,41,2,24,11,${nLED}]}"

        jo.Get[value]:AddInteger[${r.Mul[63]}]
        jo.Get[value]:AddInteger[${g.Mul[63]}]
        jo.Get[value]:AddInteger[${b.Mul[63]}]

        OutDevice:SendJSON[jo]
    }

    method ScrollText(string text, uint color=124, uint speed=5, int loop=0)
    {
        variable jsonvalueref jo="{\"type\":\"sysex\",\"value\":[0,32,41,2,24,20,${color},${loop},${speed}]}"

        jo.Get[value]:AddString["${text~}"]

        OutDevice:SendJSON[jo]
/*
        variable jsonvalueref ja="[0,32,41,2,24,20,${color},${loop},${speed}]"

        variable uint i
        for ( i:Set[1] ; ${i} <= ${text.Length} ; i:Inc)
        {
            ja:AddInteger["${text.GetAt[${i}]}"]
        }

;        ja:AddInteger[247]

        noop ${OutDevice:SendSysEx${ja}}
        ; OutDevice:SendSysEx[0,32,41,2,4,20,124,0,5,72,101,108,108,111,247]}
*/
    }
}

; Launchpad Mini
objectdef(global) isb2_launchpadMiniMK2 inherits isb2_device
{
    method Initialize(jsonvalueref joDevice)
    {
        This[parent]:Initialize[joDevice]

        if !${DeviceName.NotNULLOrEmpty}
            DeviceName:Set["Launchpad Mini"]

        This:DetectDevice

        if ${ISUplink(exists)}
            This:ISLogo
    }

    method ISLogo()
    {
        if !${OutDevice.Reference(exists)}
            return

        This:Reset
        ; outer circle
        This:SetGridXY[3,1,1]
        This:SetGridXY[4,1,1]
        This:SetGridXY[5,1,1]
        This:SetGridXY[6,1,1]
        This:SetGridXY[6,1,1]

        This:SetGridXY[2,2,1]
        This:SetGridXY[7,2,1]

        This:SetGridXY[1,3,1]
        This:SetGridXY[8,3,1]
        This:SetGridXY[1,4,1]
        This:SetGridXY[8,4,1]
        This:SetGridXY[1,5,1]
        This:SetGridXY[8,5,1]
        This:SetGridXY[1,6,1]
        This:SetGridXY[8,6,1]

        This:SetGridXY[2,7,1]
        This:SetGridXY[7,7,1]

        This:SetGridXY[3,8,1]
        This:SetGridXY[4,8,1]
        This:SetGridXY[5,8,1]
        This:SetGridXY[6,8,1]
        This:SetGridXY[6,8,1]

        ; inner cross
        This:SetGridXY[4,2,3]
        This:SetGridXY[4,3,3]
        This:SetGridXY[4,4,1]
        This:SetGridXY[4,5,1]
        This:SetGridXY[4,6,3]
        This:SetGridXY[4,7,3]

        This:SetGridXY[5,2,3]
        This:SetGridXY[5,3,3]
        This:SetGridXY[5,4,1]
        This:SetGridXY[5,5,1]
        This:SetGridXY[5,6,3]
        This:SetGridXY[5,7,3]

        This:SetGridXY[2,4,3]
        This:SetGridXY[3,4,3]
;        This:SetGridXY[4,4,3]
;        This:SetGridXY[5,4,3]
        This:SetGridXY[6,4,3]
        This:SetGridXY[7,4,3]

        This:SetGridXY[2,5,3]
        This:SetGridXY[3,5,3]
;        This:SetGridXY[4,5,3]
;        This:SetGridXY[5,5,3]
        This:SetGridXY[6,5,3]
        This:SetGridXY[7,5,3]

    }

    method OutputObject(jsonvalueref jo)
    {
;        echo "isb2_launchpadMiniMK2:OutputObject ${jo~}"
        switch ${jo.Get[type]}
        {
            case note on
                return FALSE
            case note off
                return FALSE
            case rgb all
                {
                    This:SetAllRGB[${jo.GetNumber[value,1]},${jo.GetNumber[value,2]},${jo.GetNumber[value,3]}]
                    return TRUE
                }
                break
            case rgb
                {
                    ;echo This:SetGridRGB[${jo.GetInteger[-default,1,y]}${jo.GetInteger[-default,1,x]},${jo.GetNumber[value,1]},${jo.GetNumber[value,2]},${jo.GetNumber[value,3]}]
                    ;This:SetGridRGB[${jo.GetInteger[-default,1,y]}${jo.GetInteger[-default,1,x]},${jo.GetNumber[value,1]},${jo.GetNumber[value,2]},${jo.GetNumber[value,3]}]

                    This:SetGridXY[${jo.GetInteger[-default,1,x]},${jo.GetInteger[-default,1,y]},${jo.GetNumber[value,1].Mul[3]},${jo.GetNumber[value,2].Mul[3]}]
                    return TRUE
                }
                break
        }

        if ${This[parent]:OutputObject[jo](exists)}
            return TRUE

        return FALSE        
    }    


	method Reset()
	{
		OutDevice:SendControlInt[0,0,0]
	}

	method SetMode(bool display, bool update, bool flash, bool copy)
	{
		variable uint bits=32
		if ${display}
			bits:Inc[1]
		if ${update}
			bits:Inc[4]
		if ${flash}
			bits:Inc[8]
		if ${copy}
			bits:Inc[16]

		OutDevice:SendControlInt[0,0,${bits}]
	}

	method SetGridMode(bool drumRack)
	{
		if ${drumRack}
			OutDevice:SendControlInt[0,0,2]
		else
			OutDevice:SendControlInt[0,0,1]
	}

    method SetAllRGB(float r, float g, float b)
    {
        variable int x
        variable int y

        variable uint red=${r.Mul[3]}
        variable uint green=${g.Mul[3]}

		if ${red}>3
			red:Set[3]
		if ${green}>3
			green:Set[3]

		variable uint bits=${red}+(16*${green})
        bits:Inc[12]

		variable uint nLed
		

        for (y:Set[1] ; ${y}<=8 ; y:Inc)
        {
            for (x:Set[0] ; ${x}<=8 ; x:Inc)
            {
                nLed:Set[(${y}*16)+${x}]
                OutDevice:SendNoteOnInt[0,${nLed},${bits}]
            }
        }
    }

	method SetGrid(uint nLed, uint red, uint green, bool copy=1, bool clear=1)
	{
;		echo SetGrid ${nLed} ${red} ${green}
		if ${nLed}>120
			nLed:Set[120]

		if ${red}>3
			red:Set[3]
		if ${green}>3
			green:Set[3]

		variable uint bits=${red}+(16*${green})
		if ${copy}
			bits:Inc[4]
		if ${clear}
			bits:Inc[8]

		OutDevice:SendNoteOnInt[0,${nLed},${bits}]

        variable uint X
        variable uint Y
        X:Set[(${nLed}%16)+1]
        Y:Set[(${nLed}/16)+2]
        This:UpdateUI[${X},${Y},${red},${green}]
	}

	method SetGridXY(uint X, uint Y, uint red, uint green, bool copy=1, bool clear=1)
	{
        X:Dec
        Y:Dec
		if ${X}>8
			X:Set[8]
		if ${Y}>8
			Y:Set[8]

		if ${red}>3
			red:Set[3]
		if ${green}>3
			green:Set[3]

		variable uint bits=${red}+(16*${green})
		if ${copy}
			bits:Inc[4]
		if ${clear}
			bits:Inc[8]

		variable uint nLed
		nLed:Set[(${Y}*16)+${X}]

		OutDevice:SendNoteOnInt[,${nLed},${bits}]
        X:Inc
        Y:Inc[2]
        This:UpdateUI[${X},${Y},${red},${green}]
	}
	    

	method TurnOnAll(int level)
	{
		if ${level}<1
			level:Set[1]
		elseif ${level}>3
			level:Set[3]

		OutDevice:SendControlInt[0,0,${Math.Calc[124+${level}].Int}]
	}

	method SetDutyCycle(int numerator, int denominator)
	{
		if ${numerator}<1
			numerator:Set[1]
		elseif ${numerator}>16
			numerator:Set[16]

		if ${denominator}<3
			denominator:Set[3]
		elseif ${denominator}>18
			denominator:Set[18]

		if ${numerator}<9
		{
			OutDevice:SendControlInt[0,30,${Math.Calc[(16*(${numerator}-1))+${denominator}-3].Int}]
		}
		else
		{
			OutDevice:SendControlInt[0,31,${Math.Calc[(16*(${numerator}-9))+${denominator}-3].Int}]
		}
	}        
}