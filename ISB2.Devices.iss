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
        LGUI2:UnloadPackageFile[LGUI2/ISB2.Devices.lgui2Package.json]
    }

/*
    static method SetUseSynth(bool newValue)
    {
        ISB2.Settings.Get[-init,{},midi]:SetBool[useSynth,${newValue}]
        ; echo ${ISB2.Settings}
        ISB2:AutoStoreSettings
    }
*/

    method Init()
    {
        ; not currently implemented.
        return

        LGUI2:PushSkin["${ISB2.UseSkin~}"]
        LGUI2:LoadPackageFile[LGUI2/ISB2.Devices.lgui2Package.json]
        LGUI2:PopSkin["${ISB2.UseSkin~}"]

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

    method ExecuteLDIOAction(jsonvalueref joAction)
    {
        echo "\arNOT CURRENTLY IMPLEMENTED \ax\ayExecuteLDIOAction\ax: ${JoAction~}"
        /*
        variable weakref useDevice
        useDevice:SetReference["Devices.Get[\"${joAction.Get[device]~}\"]"]
        if !${useDevice.Reference(exists)}
        {
            useDevice:SetReference["ldiopatch.Get[\"${joAction.Get[patch]~}\"]"]
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
        */
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
    variable jsonvalueref joDevice

    method Initialize(jsonvalueref joDevice)
    {
        
    }

    method Shutdown()
    {
    }

    method ExecuteLDIOAction(jsonvalueref joAction)
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
