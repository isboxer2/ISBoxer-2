objectdef(global) isb2_devices
{
    static variable isb2_devices Instance

    static variable jsonvalueref AddingItem="{}"
    static variable jsonvalue TestingAction="{\"type\":\"midi out\",\"device\":\"synth\",\"output\":\"on 2 64 1.0\"}"

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

        ISB2.Settings.Get[-init,"{}",midi].Get[-init,"[]",outDevices]:AddByRef[joAdd]

        LGUI2.Element[isb2.events]:FireEventHandler[onMidiOutDevicesChanged]

        This:RefreshOutDevices

        ISB2:AutoStoreSettings

        return TRUE
    }

    method AddDevice(jsonvalueref joDevice)
    {
        ; name (e.g. My Launchpad)
        ; deviceName (e.g. Launchpad Mini)
        ; deviceIndex (e.g. 1)
;        echo AddDevice ${joDevice~}
        if !${joDevice.Has[-string,deviceName]}
            return FALSE

        Devices:Set["${joDevice.Get[name]~}","isb2_device.Create[object,joDevice]"]
        return TRUE
    }

    method ExecuteMIDIOutAction(jsonvalueref joAction)
    {
        variable weakref useDevice
        useDevice:SetReference["Devices.Get[\"${joAction.Get[device]~}\"]"]
        if !${useDevice.Reference(exists)}
        {
            useDevice:SetReference["midipatch.Get[\"${joAction.Get[patch]~}\"]"]
            if ${useDevice.Reference(exists)}
            {
                switch ${joAction.GetType[output]}
                {
                    case object
                    case array
                        return ${useDevice:SendJSON["joAction.Get[output]"](exists)}            
                } 
                return ${useDevice:SendJSON["${joAction.Get[output].AsJSON~}"](exists)}
            }


            echo "RemoteMIDIOut: device ${joAction.Get[device]~} not found"
            return
        }

        return ${useDevice:ExecuteMIDIOutAction[joAction](exists)}
    }

    method RemoteMIDIOut()
    {        
        variable jsonvalueref joAction="Context.Get[action]"

        echo "RemoteMIDIOut: ${joAction~}"
        This:ExecuteMIDIOutAction[joAction]
    }    

    method OnTestAction()
    {
        This:ExecuteMIDIOutAction[isb2_devices.TestingAction]
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

        This:DetectDevice
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
        
;        echo "isb2_device:DetectDevice"
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

    method ExecuteMIDIOutAction(jsonvalueref joAction)
    {
        switch ${joAction.GetType[output]}
        {
            case object
            case array
                return ${OutDevice:SendJSON["joAction.Get[output]"](exists)}            
        } 
        return ${OutDevice:SendJSON["${joAction.Get[output].AsJSON~}"](exists)}
    }

}
