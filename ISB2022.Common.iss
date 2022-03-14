/* isb2022_profile: 
    A set of definitions for ISBoxer 2022. Like an ISBoxer Toolkit Profile, but preferably more generic.
*/
objectdef isb2022_profile
{
    variable string LocalFilename

    variable string Name
    variable string Description
    variable string Version
    variable uint MinimumBuild
    variable jsonvalue Metadata

    variable jsonvalue Profiles=[]
    variable jsonvalue Teams=[]
    variable jsonvalue Characters=[]
    variable jsonvalue WindowLayouts=[]
    variable jsonvalue VirtualFiles=[]
    variable jsonvalue Triggers=[]
    variable jsonvalue Hotkeys=[]
    variable jsonvalue GameKeyBindings=[]
    variable jsonvalue KeyLayouts=[]

    method Initialize(jsonvalueref jo)
    {
        This:FromJSON[jo]
    }

    method FromJSON(jsonvalueref jo)
    {
        if !${jo.Reference(exists)}
            return

        if ${jo.Has[name]}
            Name:Set["${jo.Get[name]~}"]
        if ${jo.Has[description]}
            Name:Set["${jo.Get[description]~}"]
        if ${jo.Has[version]}
            Name:Set["${jo.Get[version]~}"]
        if ${jo.Has[minimumBuild]}
            Name:Set["${jo.Get[minimumBuild]~}"]

        if ${jo.Has[metadata]}
            Metadata:SetValue["${jo.Get[metadata]~}"]
        if ${jo.Has[profiles]}
            Profiles:SetValue["${jo.Get[profiles]~}"]
        if ${jo.Has[teams]}
            Teams:SetValue["${jo.Get[teams]~}"] 
        if ${jo.Has[characters]}
            Characters:SetValue["${jo.Get[characters]~}"]
        if ${jo.Has[windowLayouts]}
            WindowLayouts:SetValue["${jo.Get[windowLayouts]~}"]
        if ${jo.Has[virtualFiles]}
            VirtualFiles:SetValue["${jo.Get[virtualFiles]~}"]
        if ${jo.Has[triggers]}
            Triggers:SetValue["${jo.Get[triggers]~}"]
        if ${jo.Has[hotkeys]}
            Hotkeys:SetValue["${jo.Get[hotkeys]~}"]
        if ${jo.Has[gameKeyBindings]}
            GameKeyBindings:SetValue["${jo.Get[gameKeyBindings]~}"]
        if ${jo.Has[keyLayouts]}
            KeyLayouts:SetValue["${jo.Get[keyLayouts]~}"]
    }

    member:jsonvalueref AsJSON()
    {
        variable jsonvalue jo
        /*
        ; this version produces a larger footprint than necessary, but this is basically what gets generated
        jo:SetValue["$$>
        {
            "$schema":"http://www.lavishsoft.com/schema/isb2022.json",
            "name":${Name.AsJSON~},
            "description":${Description.AsJSON~},
            "version":${Version.AsJSON~},
            "minimumBuild":${MinimumBuild.AsJSON~},
            "metadata":${Metadata.AsJSON~},
            "profiles":${Profiles.AsJSON~},
            "teams":${Teams.AsJSON~},
            "characters":${Characters.AsJSON~},
            "windowLayouts":${WindowLayouts.AsJSON~},
            "virtualFiles":${VirtualFiles.AsJSON~},
            "triggers":${Triggers.AsJSON~},
            "hotkeys":${Hotkeys.AsJSON~},
            "gameKeyBindings":${GameKeyBindings.AsJSON~},
            "keyLayouts":${KeyLayouts.AsJSON~}
        }
        <$$"]
        */

        jo:SetValue["$$>
        {
            "$schema":"http://www.lavishsoft.com/schema/isb2022.json",
            "name":${Name.AsJSON~}
        }
        <$$"]

        if ${Description.NotNULLOrEmpty}
            jo:Set["description","${Description.AsJSON~}"]
        if ${Version.NotNULLOrEmpty}
            jo:Set["version","${Version.AsJSON~}"]
        if ${MinimumBuild}
            jo:Set["description","${Description.AsJSON~}"]
        if ${Metadata.Type.Equal[object]}
            jo:Set["metadata","${Metadata.AsJSON~}"]
        if ${Profiles.Used}
            jo:Set["profiles","${Profiles.AsJSON~}"]
        if ${Teams.Used}
            jo:Set["teams","${Teams.AsJSON~}"]
        if ${Characters.Used}
            jo:Set["characters","${Characters.AsJSON~}"]
        if ${WindowLayouts.Used}
            jo:Set["windowLayouts","${WindowLayouts.AsJSON~}"]
        if ${VirtualFiles.Used}
            jo:Set["virtualFiles","${VirtualFiles.AsJSON~}"]
        if ${Triggers.Used}
            jo:Set["triggers","${Triggers.AsJSON~}"]
        if ${Hotkeys.Used}
            jo:Set["hotkeys","${Hotkeys.AsJSON~}"]
        if ${GameKeyBindings.Used}
            jo:Set["gameKeyBindings","${GameKeyBindings.AsJSON~}"]
        if ${KeyLayouts.Used}
            jo:Set["keyLayouts","${KeyLayouts.AsJSON~}"]
        return jo
    }
}

/* isb2022_profilecollection: 
    A collection of ISBoxer 2022 profiles
*/
objectdef isb2022_profilecollection
{
    ; The variable that contains the actual list
    variable collection:isb2022_profile Profiles

    ; Loads a profile from a given file
    method LoadFile(filepath fileName)
    {
        ; given a path like "Tests/WoW.isb2022.json" this turns it into like "C:/blah blah/Tests/isb2022.json"
        fileName:MakeAbsolute
        
        ; parse the file into, hopefully, a json object
        variable jsonvalue jo        
        if !${jo:ParseFile["${fileName~}"](exists)}
            return FALSE

        ; if we got something else, forget it
        if !${jo.Type.Equal[object]}
        {
            echo "isb2022_profilecollection:LoadFile[${fileName~}]: expected JSON object, got ${jo.Type~}"
            return FALSE
        }

        ; a profile is required to have a name, so we can more easily work with multiple profiles!
        if !${jo.Has[name]}
        {
            echo "isb2022_profilecollection:LoadFile[${fileName~}]: 'name' field required"
            return FALSE
        }

        ; temporarily store the name since we'll need it a few times
        variable string name
        name:Set["${jo.Get[name]~}"]

        ; Assign the Profile
        Profiles:Set["${name~}","jo"]
        Profiles["${name~}"].LocalFilename:Set["${fileName~}"]
        echo "Profile added: ${name~}"
    }
}