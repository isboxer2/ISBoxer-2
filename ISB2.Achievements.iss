objectdef(global) isb2_achievements
{
    variable(static) isb2_achievements Instance

    variable jsonvalueref Achievements="{}"
    variable jsonvalueref UserData="{}"

    variable jsonvalueref HookMap="{}"

    variable bool ShouldSave

    method Initialize()
    {
    }

    member:filepath SettingsFilename()
    {
        return "${ISB2.SettingsFolder~}/ISB2.Achievements.json"
    }

    method Init()
    {
        LGUI2:PushSkin["${ISB2.UseSkin~}"]
        LGUI2:LoadPackageFile[ISB2.Achievements.lgui2Package.json]
        LGUI2:PopSkin["${ISB2.UseSkin~}"]

        This:InstallAchievements
        This:LoadSettings
    }

    method InstallAchievement(jsonvalueref joAchieve)
    {
        ; echo "\ayInstallAchievement\ax ${joAchieve~}"

        variable int64 id="${joAchieve.GetInteger[id]}"
        variable string name="${joAchieve.Get[hook]~}"

        variable jsonvalueref joHook

        if !${HookMap.Has["${name~}"]}
        {
            joHook:SetReference["LGUI2.Template[isb2.achievements.eventHandler]"]
            joHook:SetString[event,"${name~}"]
            
            if !${LGUI2.Element[isb2.events]:AddHook["${name~}",joHook](exists)}
            {
                echo "AddHook failed: ${name~} = ${joHook~}"
                return
            }
        }
        HookMap.Get[-init,"{}","${name~}"].Get[-init,"[]","achievements"]:AddByRef[joAchieve]
        Achievements:SetByRef["${id}",joAchieve]
    }

    method InstallAchievements()
    {
        variable jsonvalueref ja="LGUI2.Skin[default].Template[isb2.achievements].Get[achievements]"
;        echo "\ayInstallAchievements\ax ${ja.Type~} ${ja~}"
        ja:ForEach["This:InstallAchievement[ForEach.Value]"]
    }

    method Shutdown()
    {
        LGUI2:UnloadPackageFile[ISB2.Achievements.lgui2Package.json]
    }

    member:jsonvalueref GetAchievementsFromHook(string eventName)
    {
        return "HookMap.Get[\"${eventName~}\",achievements]"
    }

    method OnAchievementCompleted(jsonvalueref joAchieve)
    {
        echo "\agOnAchievementCompleted\ax ${joAchieve~}"

        LGUI2.Element[isb2.achievementDisplay]:SetContext[joAchieve]:SetVisibility[Visible]

        variable float duration=4
        variable float fadeDuration=1.5

        variable jsonvalue joAnimation
        joAnimation:SetValue["$$>
        {
            "type":"chain",
            "name":"fade",
            "animations":[
                {
                    "type":"fade",
                    "name":"fadeIn",
                    "opacity":1.0,
                    "duration":0.1,
                },
                {
                    "type":"delay",
                    "name":"fadeDelay",
                    "duration":${duration}
                },
                {
                    "type":"fade",
                    "name":"fadeOut",
                    "opacity":0.0,
                    "duration":${fadeDuration}
                }
            ]
        }
        <$$"]

;        LGUI2.Element[isb2.popupText]:ApplyStyleJSON[joStyle]
        LGUI2.Element[isb2.achievementDisplay]:ApplyStyleJSON["{\"opacity\":1.0}"]
        LGUI2.Element[isb2.achievementDisplay]:Animate[joAnimation]

    }

    method ApplyAchievementHook(string eventName, jsonvalueref joAchieve)
    {
        variable jsonvalueref jo="UserData.Get[-init,{},\"${joAchieve.GetInteger[id]}\"]"

        variable bool completed=1

        if ${jo.Has[completed]}
        {
            return
        }
;        echo "ApplyAchievementHook ${eventName~} ${joAchieve~}"

        if ${joAchieve.Has[count]}
        {
            variable int64 count
            ShouldSave:Set[1]
            count:Set[${jo.GetInteger[count]}]
            count:Inc
            jo:SetInteger[count,${count}]

            if ${count} < ${joAchieve.GetInteger[count]}
            {
                completed:Set[0]
            }

 ;           echo "ApplyAchievementHook count = ${count} of ${joAchieve.GetInteger[count]}"
        }

        if ${completed}
        {
            ShouldSave:Set[1]
            jo:SetInteger[completed,"${time.Now.Timestamp}"]
            This:OnAchievementCompleted[joAchieve]
        }
    }

    method OnHookedEvent()
    {
;        echo "\ayisb2_achievements:OnHookedEvent\ax ${Context(type)} ${Context.Event} ${Context.Source} ${Context.Args}"

        variable jsonvalueref ja="This.GetAchievementsFromHook[\"${Context.Event~}\"]"

;        echo "applicable achievements: ${ja~}"
        ja:ForEach["This:ApplyAchievementHook[\"${Context.Event~}\",ForEach.Value]"]

        This:AutoSave
    }

    method AutoSave()
    {
        if !${ShouldSave}
            return

        ShouldSave:Set[0]
        This:StoreSettings
    }

    
    method LoadSettings()
    {
        if ${ISB2.SettingsFolder.FileExists[ISB2.Achievements.json]}
        {
            UserData:SetReference["jsonobject.ParseFile[\"${This.SettingsFilename~}\"]"]
            if !${UserData.Reference(exists)}
            {
                UserData:SetReference["{}"]
            }
        }
    }

    method StoreSettings()
    {        
        return ${UserData:WriteFile["${This.SettingsFilename~}",multiline](exists)}
    }

}
