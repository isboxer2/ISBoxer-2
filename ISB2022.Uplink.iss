#include "ISB2022.Common.iss"

objectdef isb2022 inherits isb2022_profilecollection
{
    

    method Initialize()
    {

    }

    method Shutdown()
    {

    }

    method LoadTests()
    {
        This:LoadFile["Tests/ISBPW.isb2022.json"]
        This:LoadFile["Tests/MyWindowLayout.isb2022.json"]
        This:LoadFile["Tests/Team1.isb2022.json"]
        This:LoadFile["Tests/VariableFollowMe.isb2022.json"]
        This:LoadFile["Tests/WoW.isb2022.json"]
    }
}

variable(global) isb2022 ISB2022

function main()
{
    while 1
        waitframe
}