#include "ISB2022.Common.iss"
#include "ISB2022.Importer.iss"

objectdef isb2022 inherits isb2022_profilecollection
{
    ; Reference to the currently selected Profile in the main window
    variable weakref SelectedProfile

    variable isb2022_importer Importer

    method Initialize()
    {
        LGUI2:LoadPackageFile[ISB2022.Uplink.lgui2Package.json]
    }

    method Shutdown()
    {
        LGUI2:UnloadPackageFile[ISB2022.Uplink.lgui2Package.json]
    }

    method LoadTests()
    {
        This:LoadFile["Tests/ISBPW.isb2022.json"]
        This:LoadFile["Tests/MyWindowLayout.isb2022.json"]
        This:LoadFile["Tests/Team1.isb2022.json"]
        This:LoadFile["Tests/VariableFollowMe.isb2022.json"]
        This:LoadFile["Tests/WoW.isb2022.json"]
    }

    method SelectProfile(string name)
    {
        SelectedProfile:SetReference["Profiles.Get[\"${name~}\"]"]
        LGUI2.Element[weq2022.events]:FireEventHandler[onSelectedProfileChanged]
    }
}

variable(global) isb2022 ISB2022

function main()
{
    while 1
        waitframe
}