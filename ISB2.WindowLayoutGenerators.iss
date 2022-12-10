objectdef windowLayoutGenerator
{
    variable string Name="Unnamed Window Layout"
    variable string Description="Fails to generate a Window Layout"
    variable set Uses

    member:jsonvalueref GenerateRegions(jsonvalueref joInput)
    {
        return NULL
    }

    member:jsonvalueref GenerateSettings(jsonvalueref joInput)
    {
        return NULL
    }

    member:jsonvalueref GenerateLayout(jsonvalueref joInput)
    {
        return NULL
    }

    member ToText()
    {
        return "${Name~}"
    }
}

objectdef windowLayoutGenerators
{    
    variable windowLayoutGenerator_Edge Edge
    variable windowLayoutGenerator_Stacked Stacked    
    variable windowLayoutGenerator_ScreenPer ScreenPer    
    variable windowLayoutGenerator_Tile Tile    
    variable windowLayoutGenerator_Grid Grid
    variable windowLayoutGenerator_Combo Combo

    variable collection:weakref Generators

    method Initialize()
    {
        Generators:Set["${Edge~}",Edge]
        Generators:Set["${Stacked~}",Stacked]
        Generators:Set["${ScreenPer~}",ScreenPer]
        Generators:Set["${Tile~}",Tile]
        Generators:Set["${Grid~}",Grid]

        Uses:Add[monitors]
        Uses:Add[useMonitor]
        Uses:Add[avoidTaskbar]

;        Generators:Set["${Horizontal~}",Horizontal]
;        Generators:Set["${Vertical~}",Vertical]
    }

    member:weakref GetGenerator(string name)
    {
        return "This.Generators.Get[${name~}]"
    }
}

/*
input
{
    "numSlots":5,
    "useMonitor":1,
    "monitors":[
        {
            "id":0,
            "name":"\\\\.\\DISPLAY609",
            "primary":true,"left":0,"right":1920,"top":0,"bottom":1080,"width":1920,"height":1080,
            "maximizeLeft":0,"maximizeRight":1920,"maximizeTop":0,"maximizeBottom":1040,"maximizeWidth":1920,"maximizeHeight":1040
        }
    ],
    "avoidTaskbar":false,
    "leaveHole":true
}
output:
[
    {"mainRegion":true,"x":0,"y":0,"width":1920,"height":900},
    {"x":0,"y":900,"width":384,"height":180},
    {"x":384,"y":900,"width":384,"height":180},
    {"x":768,"y":900,"width":384,"height":180},
    {"x":1152,"y":900,"width":384,"height":180},
    {"x":1536,"y":900,"width":384,"height":180}
]
*/

objectdef windowLayoutGenerator_Common inherits windowLayoutGenerator
{
        variable uint numSlots
        variable uint useMonitor
        variable uint numInactiveRegions
        variable jsonvalueref joMonitor
        variable uint monitorWidth
        variable uint monitorHeight
        variable int monitorX
        variable int monitorY

    member:jsonvalueref GenerateRegions_Subclass(jsonvalueref joInput)
    {
        return NULL
    }

    method GenerateSettings_Subclass(jsonvalueref joInput, jsonvalueref joSettings)
    {

    }


    member:jsonvalueref GenerateSettings(jsonvalueref joInput)
    {
        variable jsonvalueref joSettings="{}"

        This:GenerateSettings_Subclass[joInput,joSettings]
        return joSettings
    }

    member:jsonvalueref GenerateLayout(jsonvalueref joInput)
    {
        variable jsonvalueref jaRegions="This.GenerateRegions[joInput]"

        if !${jaRegions.Reference(exists)}
            return NULL

        variable jsonvalue joLayout
        joLayout:SetValue["{}"]
        joLayout:SetByRef[regions,jaRegions]

        variable jsonvalueref joSettings
        joSettings:SetReference["This.GenerateSettings[joInput]"]
        if ${joSettings.Reference(exists)}
            joLayout:SetByRef[settings,joSettings]

        return joLayout
    }

    member:jsonvalueref GenerateRegions(jsonvalueref joInput)
    {
;        echo "GenerateRegions ${joInput~}"
        variable jsonvalue ja
        useMonitor:Set[${joInput.GetInteger[useMonitor]}]
        
        if !${useMonitor}
            useMonitor:Set[1]

        joMonitor:SetReference["joInput.Get[monitors,${useMonitor}]"]
        if !${joMonitor.Reference(exists)}
            return NULL

        numInactiveRegions:Set[${joInput.GetInteger[numInactiveRegions]}]

        numSlots:Set[${joInput.GetInteger[numSlots]}]
        if !${numSlots}
            numSlots:Set[1]
;        echo monitor=${joMonitor~} width=${joMonitor.GetNumber[width]}

        if !${numInactiveRegions}
            numInactiveRegions:Set[${numSlots}]

        if ${joInput.GetBool[avoidTaskbar]}
        {
            monitorX:Set["${joMonitor.GetNumber[maximizeLeft]}"]
            monitorY:Set["${joMonitor.GetNumber[maximizeTop]}"]
            monitorWidth:Set["${joMonitor.GetNumber[maximizeWidth]}"]
            monitorHeight:Set["${joMonitor.GetNumber[maximizeHeight]}"]
        }
        else
        {
            monitorX:Set["${joMonitor.GetNumber[left]}"]
            monitorY:Set["${joMonitor.GetNumber[top]}"]
            monitorWidth:Set["${joMonitor.GetNumber[width]}"]
            monitorHeight:Set["${joMonitor.GetNumber[height]}"]
        }

        ; if there's only 1 window, just go full screen windowed
        if ${numSlots}==1
        {
            ja:SetValue["$$>
            [
                {
                    "mainRegion":true,
                    "x":${monitorX},
                    "y":${monitorY},
                    "width":${monitorWidth},
                    "height":${monitorHeight},
                    "numRegion":1
                }
            ]
            <$$"]
            return ja
        }

        return "This.GenerateRegions_Subclass[joInput]"
    }

}


objectdef windowLayoutGenerator_Combo inherits windowLayoutGenerator
{
    method Initialize()
    {
        Name:Set[Combo]
        Description:Set["Generates a layout composed of multiple other layouts! Layoutception."]
    }

    method AddLayout(uint numLayout, jsonvalueref ja, jsonvalueref joCombo, jsonvalueref joInput)
    {
;        echo "Combo:AddLayout ${joInput.Type} ${joInput~}"
        variable weakref wlGenerator
        wlGenerator:SetReference["ISB2QuickSetup.WindowLayoutGenerators.GetGenerator[\"${joInput.Get[generator]~}\"]"]
        
        variable jsonvalue joMerged="${joCombo~}"
        joMerged:Erase[layouts]
        joMerged:Merge[joInput]

;        echo "merged=${joMerged~}"

        variable jsonvalue jaRegions        
        jaRegions:SetValue["${wlGenerator.GenerateRegions["joMerged"]~}"]
        jaRegions:ForEach["ForEach.Value:SetInteger[numLayout,${numLayout}]"]

;        echo "result=${jaRegions~}"

        if ${jaRegions.Type~.Equal[Array]}
        {
            jaRegions:ForEach["ja:AddByRef[ForEach.Value]"]
        }
    }

    member:jsonvalueref GenerateRegions(jsonvalueref joInput)
    {
        variable jsonvalue ja="[]"

        variable uint numLayout

        variable jsonvalueref joLayout
        
;        echo "Combo:GenerateRegions ${joInput~}"
        joInput.Get[layouts]:ForEach["This:AddLayout[\${ForEach.Key},ja,joInput,ForEach.Value]"]

;        echo "Combo:GenerateRegions result=${ja~}"
        return ja
    }

}

objectdef windowLayoutGenerator_ScreenPer inherits windowLayoutGenerator
{
    method Initialize()
    {
        Name:Set[ScreenPer]
        Description:Set["Generates a layout where each window is assigned to its own monitor (reusing monitors if there's too many characters)"]
    }

    member:jsonvalueref GenerateForScreen(jsonvalueref joInput, uint numMonitor, bool mainRegion)
    {
        variable jsonvalue joRegion

        variable bool avoidTaskbar=${joInput.GetBool[avoidTaskbar]}

        variable jsonvalueref joMonitor
        variable uint monitorWidth
        variable uint monitorHeight
        variable int monitorX
        variable int monitorY
        
        joMonitor:SetReference["joInput.Get[monitors,${numMonitor}]"]
        if !${joMonitor.Reference(exists)}
            return NULL

        if ${avoidTaskbar}
        {
            monitorX:Set["${joMonitor.GetNumber[maximizeLeft]}"]
            monitorY:Set["${joMonitor.GetNumber[maximizeTop]}"]
            monitorWidth:Set["${joMonitor.GetNumber[maximizeWidth]}"]
            monitorHeight:Set["${joMonitor.GetNumber[maximizeHeight]}"]
        }
        else
        {
            monitorX:Set["${joMonitor.GetNumber[left]}"]
            monitorY:Set["${joMonitor.GetNumber[top]}"]
            monitorWidth:Set["${joMonitor.GetNumber[width]}"]
            monitorHeight:Set["${joMonitor.GetNumber[height]}"]
        }

        joRegion:SetValue["$$>
            {
                "x":${monitorX},
                "y":${monitorY},
                "width":${monitorWidth},
                "height":${monitorHeight}
            }
        <$$"]

        if ${mainRegion}
            joRegion:SetBool[mainRegion,1]

        return joRegion
    }
    
    member:jsonvalueref GenerateRegions(jsonvalueref joInput)
    {
        variable jsonvalue ja=[]
        variable uint numMonitors=${joInput.Get[monitors].Used}
        variable uint numInactiveRegions=${joInput.GetInteger[numInactiveRegions]}
        variable uint numSlots=${joInput.GetInteger[numSlots]}

        if !${numSlots}
            numSlots:Set[1]

        if !${numInactiveRegions}
            numInactiveRegions:Set[${numSlots}-1]

        numSlots:Set[${numInactiveRegions}+1]

        variable uint numSlot
        variable jsonvalue joRegion
        variable bool mainRegion=1
        variable uint useMonitor
        for (numSlot:Set[1] ; ${numSlot}<=${numSlots} ; numSlot:Inc)
        {
            useMonitor:Set[(${numSlot.Dec}%${numMonitors})+1]            
            joRegion:SetValue["${This.GenerateForScreen[joInput,${useMonitor},${mainRegion}]~}"]
            joRegion:SetInteger["numRegion",${numSlot}]

            ja:Add["${joRegion~}"]

            mainRegion:Set[0]            
        }

        return ja
    }
}

objectdef windowLayoutGenerator_Stacked inherits windowLayoutGenerator_Common
{
    method Initialize()
    {
        Name:Set[Stacked]
        Description:Set["Generates a layout where all windows are stacked on top of each other in the same place (for example, full screen)"]
    }


    method GenerateSettings_Subclass(jsonvalueref joInput, jsonvalueref joSettings)
    {
        joSettings:SetBool[focusFollowsMouse,0]
        joSettings:SetBool[swapOnActivate,0]
        joSettings:SetString[swapMode,Never]
    }

    member:jsonvalueref GenerateRegions_Subclass(jsonvalueref joInput)
    {
        variable jsonvalue ja="[]"
        variable jsonvalue joRegion

        /*
        ; main region
        joRegion:SetValue["$$>
            {
                "mainRegion":true,
                "x":${monitorX},
                "y":${monitorY},
                "width":${monitorWidth},
                "height":${monitorHeight},
                "numRegion":1
            }
        <$$"]

        ja:Add["${joRegion~}"]
        /**/

        variable uint numSlot

        joRegion:SetValue["$$>
            {
                "x":${monitorX},
                "y":${monitorY},
                "width":${monitorWidth},
                "height":${monitorHeight}
            }
        <$$"]

        for (numSlot:Set[1] ; ${numSlot}<=${numInactiveRegions} ; numSlot:Inc)
        {
            joRegion:SetInteger[numRegion,${numSlot.Inc}]
            ja:Add["${joRegion~}"]
        }
        return ja
    }
}

objectdef windowLayoutGenerator_Edge inherits windowLayoutGenerator_Common
{
    method Initialize()
    {
        Name:Set[Edge]
        Description:Set["Generates a standard layout with small regions along an edge of the screen"]
        Uses:Add[edge]
    }

    method GenerateSettings_Subclass(jsonvalueref joInput, jsonvalueref joSettings)
    {
        variable jsonvalue joSwapGroup="{\"reset\":1,\"active\":1}"
        variable jsonvalue jaSwapGroups="[]"

        if !${joInput.GetBool[leaveHole]}
            joSwapGroup:SetInteger[roamingSlot,1]

        jaSwapGroups:AddByRef[joSwapGroup]

        joSettings:SetByRef[swapGroups,jaSwapGroups]
    }

    member:jsonvalueref GenerateRegions_Subclass(jsonvalueref joInput)
    {
        switch ${joInput.Get[edge]~}
        {
            case left
            case right
                return "This.GenerateRegions_Vertical[joInput]"
            case top
            case bottom
                return "This.GenerateRegions_Horizontal[joInput]"
        }
    }

     member:jsonvalueref GenerateRegions_Horizontal(jsonvalueref joInput)
    {
        variable jsonvalue ja="[]"
        variable jsonvalue joRegion

        variable uint mainHeight
        variable uint mainWidth
        variable uint smallHeight
        variable uint smallWidth            

        variable bool useBottom=${joInput.Get[edge]~.NotEqual[top]}

        if !${joInput.GetBool[leaveHole]} && !${joInput.Has[numInactiveRegions]}
            numInactiveRegions:Dec

        ; 2 windows is actually a 50/50 split screen and should probably handle differently..., pretend there's 3
        if ${numInactiveRegions}<3
            numInactiveRegions:Set[3]

        mainWidth:Set["${monitorWidth}"]
        mainHeight:Set["${monitorHeight}*${numInactiveRegions}/(${numInactiveRegions}+1)"]

        smallHeight:Set["${monitorHeight}-${mainHeight}"]
        smallWidth:Set["${monitorWidth}/${numInactiveRegions}"]

        variable int useY=${monitorY}
        if !${useBottom}
            useY:Set[${monitorY}+${smallHeight}]

        ; main region
        joRegion:SetValue["$$>
            {
                "mainRegion":true,
                "x":${monitorX},
                "y":${useY},
                "width":${mainWidth},
                "height":${mainHeight},
                "numRegion":1
            }
        <$$"]

        ja:Add["${joRegion~}"]

        variable int useX=${monitorX}
        variable uint numSlot

        useY:Set[${mainHeight}+${monitorY}]
        if !${useBottom}
        {
            useY:Set[${monitorY}]
        }

        joRegion:SetValue["$$>
            {
                "x":${useX},
                "y":${useY},
                "width":${smallWidth},
                "height":${smallHeight}
            }
        <$$"]

        for (numSlot:Set[1] ; ${numSlot}<=${numInactiveRegions} ; numSlot:Inc)
        {
            joRegion:SetInteger[x,${useX}]
            joRegion:SetInteger[numRegion,${numSlot.Inc}]
            ja:Add["${joRegion~}"]
            useX:Inc["${smallWidth}"]
        }

        return ja
    }

    member:jsonvalueref GenerateRegions_Vertical(jsonvalueref joInput)
    {
        variable jsonvalue ja="[]"
        variable jsonvalue joRegion

        variable uint mainHeight
        variable uint mainWidth
        variable uint smallHeight
        variable uint smallWidth            

        variable bool useRight=${joInput.Get[edge]~.NotEqual[left]}

        if !${joInput.GetBool[leaveHole]} && !${joInput.Has[numInactiveRegions]}
            numInactiveRegions:Dec

        ; 2 windows is actually a 50/50 split screen and should probably handle differently..., pretend there's 3
        if ${numInactiveRegions}<3
            numInactiveRegions:Set[3]

        mainHeight:Set["${monitorHeight}"]
        mainWidth:Set["${monitorWidth}*${numInactiveRegions}/(${numInactiveRegions}+1)"]

        smallWidth:Set["${monitorWidth}-${mainWidth}"]
        smallHeight:Set["${monitorHeight}/${numInactiveRegions}"]

        variable int useX=${monitorX}
        if !${useRight}
            useX:Set[${monitorX}+${smallWidth}]

        ; main region
        joRegion:SetValue["$$>
            {
                "mainRegion":true,
                "x":${useX},
                "y":${monitorY},
                "width":${mainWidth},
                "height":${mainHeight},
                "numRegion":1
            }
        <$$"]

        ja:Add["${joRegion~}"]

        variable int useY=${monitorY}
        variable uint numSlot

        useX:Set[${mainWidth}+${monitorX}]
        if !${useRight}
        {
            useX:Set[${monitorX}]
        }
        joRegion:SetValue["$$>
            {
                "x":${useX},
                "y":${useY},
                "width":${smallWidth},
                "height":${smallHeight}
            }
        <$$"]

        for (numSlot:Set[1] ; ${numSlot}<=${numInactiveRegions} ; numSlot:Inc)
        {
            joRegion:SetInteger[y,${useY}]
            joRegion:SetInteger[numRegion,${numSlot.Inc}]
            ja:Add["${joRegion~}"]
            useY:Inc["${smallHeight}"]
        }

        return ja
    }
}

objectdef windowLayoutGenerator_Tile inherits windowLayoutGenerator_Common
{
    method Initialize()
    {
        Name:Set[Tile]
        Description:Set["Generates a layout where all windows are tiled"]
    }

    method GenerateSettings_Subclass(jsonvalueref joInput, jsonvalueref joSettings)
    {
        joSettings:SetBool[focusFollowsMouse,1]
        joSettings:SetBool[swapOnActivate,0]
        joSettings:SetString[swapMode,Never]
    }

    member:uint GetSquareSize(uint numRegions)
    {
        ; find the best square
        ; size: max regions
        ; 2: 4
        ; 3: 9
        ; 4: 16
        ; 5: 25
        ; 6: 36
        ; 7: 49
        ; 8: 64
        ;echo GetSquareSize[${numRegions}]
        variable uint squareSize=1

        while ${squareSize}*${squareSize} < ${numRegions}
        {
            squareSize:Inc
        }

        return ${squareSize}
    }

    member:jsonvalueref GenerateRegions_Subclass(jsonvalueref joInput)
    {
        variable jsonvalue ja="[]"
        variable jsonvalue joRegion


        variable uint squareSize
        squareSize:Set[${This.GetSquareSize[${numSlots}]}]
        if !${squareSize}
            return NULL

        variable uint nX
        variable uint nY

        variable uint smallHeight
        variable uint smallWidth            

        smallWidth:Set["${monitorWidth}/${squareSize}"]
        smallHeight:Set["${monitorHeight}/${squareSize}"]

        variable uint numSlot

        joRegion:SetValue["$$>
            {
                "x":${monitorX},
                "y":${monitorY},
                "width":${smallWidth},
                "height":${smallHeight}
            }
        <$$"]

        for (nY:Set[0] ; ${nY} < ${squareSize} ; nY:Inc )
        {
            for (nX:Set[0] ; ${nX} < ${squareSize} ; nX:Inc )
            {
                numSlot:Inc
                if ${numSlot} > ${numSlots}
                    break
                joRegion:SetInteger[x,${monitorX.Inc[${nX} * ${smallWidth}]}]
                joRegion:SetInteger[y,${monitorY.Inc[${nY} * ${smallHeight}]}]
                joRegion:SetInteger[numRegion,${numSlot}]
                ja:Add["${joRegion~}"]

            }

            if ${numSlot} > ${numSlots}
                break
        }

        return ja
    }
}


objectdef windowLayoutGenerator_Grid inherits windowLayoutGenerator_Common
{
    method Initialize()
    {
        Name:Set[Grid]
        Description:Set["Generates a layout where all windows are tiled within a specified grid"]
        Uses:Add[columns]
        Uses:Add[rows]
    }

    method GenerateSettings_Subclass(jsonvalueref joInput, jsonvalueref joSettings)
    {
        joSettings:SetBool[focusFollowsMouse,1]
        joSettings:SetBool[swapOnActivate,0]
        joSettings:SetString[swapMode,Never]
    }

    member:jsonvalueref GenerateRegions_Subclass(jsonvalueref joInput)
    {
        variable jsonvalue ja="[]"
        variable jsonvalue joRegion


        variable uint gridSizeX=${joInput.GetInteger[columns]}
        variable uint gridSizeY=${joInput.GetInteger[rows]}
        if ${gridSizeX}<1 || ${gridSizeY}<1
            return NULL
        
;        echo Grid size ${gridSizeX}x${gridSizeY}

        variable uint nX
        variable uint nY

        variable uint smallHeight
        variable uint smallWidth            

        smallWidth:Set["${monitorWidth}/${gridSizeX}"]
        smallHeight:Set["${monitorHeight}/${gridSizeY}"]

        variable uint numSlot

        joRegion:SetValue["$$>
            {
                "x":${monitorX},
                "y":${monitorY},
                "width":${smallWidth},
                "height":${smallHeight}
            }
        <$$"]

        while ${numSlot} <= ${numSlots}
        {
            for (nY:Set[0] ; ${nY} < ${gridSizeY} ; nY:Inc )
            {
                for (nX:Set[0] ; ${nX} < ${gridSizeX} ; nX:Inc )
                {
                    numSlot:Inc
                    if ${numSlot} > ${numSlots}
                        break
                    joRegion:SetInteger[x,${monitorX.Inc[${nX} * ${smallWidth}]}]
                    joRegion:SetInteger[y,${monitorY.Inc[${nY} * ${smallHeight}]}]
                    joRegion:SetInteger[numRegion,${numSlot}]
                    ja:Add["${joRegion~}"]

                }

                if ${numSlot} > ${numSlots}
                    break
            }
        }

        return ja
    }
}