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

    method InstallAchievementHook(string name, jsonvalueref joAchieve)
    {
;        echo "\ayInstallAchievementHook\ax ${name~} ${joAchieve~}"
        variable jsonvalueref joHook

        if !${HookMap.Has["${name~}"]}
        {
            joHook:SetReference["LGUI2.Template[isb2.achievements.eventHandler]"]
            joHook:SetString[event,"${name~}"]
            
            if !${LGUI2.Element[isb2.events]:AddHook["${name~}",joHook](exists)}
            {
                echo "\arAddHook failed:\ax ${name~} = ${joHook~}"
                return
            }
        }
        HookMap.Get[-init,"{}","${name~}"].Get[-init,"[]","achievements"]:AddByRef[joAchieve]
    }

    method InstallAchievementReq(jsonvalueref joReq, jsonvalueref joAchieve)
    {
        if ${joReq.Has[hook]}
            This:InstallAchievementHook["${joReq.Get[hook]~}",joAchieve]        
    }

    method InstallAchievement(jsonvalueref joAchieve)
    {
        ; echo "\ayInstallAchievement\ax ${joAchieve~}"

        variable int64 id="${joAchieve.GetInteger[id]}"

        if ${joAchieve.Has[-array,reqs]}
        {
            joAchieve.Get[reqs]:ForEach["This:InstallAchievementReq[ForEach.Value,joAchieve]"]
        }
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
;        echo "\agOnAchievementCompleted\ax ${joAchieve~}"

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

    ; jaCheck must contain all elements from jaRequired
    member:bool Array_LooseMatch(jsonvalueref jaRequired, jsonvalueref jaCheck)
    {
        if ${jaCheck.Used} < ${jaRequired.Used}
        {
            return FALSE
        }
        variable int64 i
        for (i:Set[1] ; ${i}<=${jaRequired.Used} ; i:Inc)
        {
            if !${jaCheck.Contains["${jaRequired.Get[${i}].AsJSON~}"]}
                return FALSE
        }

        return TRUE
    }

    member:bool Object_LooseMatch(jsonvalueref joRequired, jsonvalueref joCheck)
    {
;        echo "Object_LooseMatch \at${joRequired~}\ax \ay${joCheck~}\ax"
        if ${joCheck.Used} < ${joRequired.Used}
        {
            return FALSE
        }
        variable int64 i
        variable string key

        variable jsonvalueref jaKeys
        jaKeys:SetReference["joRequired.Keys"]

        for (i:Set[1] ; ${i}<=${jaKeys.Used} ; i:Inc)
        {
            key:Set["${jaKeys.Get[${i}]~}"]
 ;           echo "key ${key~} ${joCheck.Get["${key~}"]~} ${joRequired.Get["${key~}"]~}"
            if !${joCheck.Assert["${key~}","${joRequired.Get["${key~}"].AsJSON~}"]}
            {
  ;              echo "Not Matched"
                return FALSE
            }
        }

;        echo "Matched"
        return TRUE
    }

    method ApplyAchievementReq(weakref _eventargs, jsonvalueref joAchieve, int64 reqId, jsonvalueref joReq, jsonvalueref joResult, jsonvalueref joUserData)
    {
        variable bool ourEvent=${joReq.Assert[hook,"${_eventargs.Event.AsJSON~}"]}
        variable bool completed
        variable jsonvalueref jo="joUserData.Get[-init,\"{}\",reqs].Get[-init,\"{}\",${reqId}]"

        if ${ourEvent}
        {
            if ${joReq.Has[args]}
            {
                ; args has to match too (at least the required parts)
                ourEvent:Set["${This.Object_LooseMatch["joReq.Get[args]",_eventargs.Args]}"]
            }
        }

        completed:Set[${ourEvent}]

;        echo "ApplyAchievementReq[${ourEvent}] ${joReq~}"

        if ${joReq.Has[count]}
        {
            variable int64 count
            count:Set[${jo.GetInteger[count]}]

            if ${ourEvent}
            {
                ShouldSave:Set[1]
                count:Inc
                jo:SetInteger[count,${count}]
            }
            if ${count} < ${joReq.GetInteger[count]}
            {
                completed:Set[0]
            }                

;            echo "ApplyAchievementReq count = ${count} of ${joReq.GetInteger[count]}"            
        }

        ; alter result if this requirement is not met.
        if ${completed}
        {
            if !${jo.Has[completed]}
            {
                jo:SetInteger[completed,"${time.Now.Timestamp}"]
                ShouldSave:Set[1]
            }
        }
        else
        {
            if !${jo.Has[completed]}
            {
                joResult:SetBool[completed,0]
            }
        }
        
    }

    method ApplyAchievementHook(weakref _eventargs, jsonvalueref joAchieve)
    {
        variable jsonvalueref jo="UserData.Get[-init,{},\"${joAchieve.GetInteger[id]}\"]"

  ;      variable bool completed=1

        if ${jo.Has[completed]}
        {
            return
        }
;        echo "ApplyAchievementHook ${_eventargs.Event~} ${joAchieve~}"


        variable jsonvalueref joResult
        joResult:SetReference["{\"completed\":true}"]
        joAchieve.Get[reqs]:ForEach["This:ApplyAchievementReq[\"_eventargs\",joAchieve,\${ForEach.Key},ForEach.Value,joResult,jo]"]

        if ${joResult.GetBool[completed]}
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
        ja:ForEach["This:ApplyAchievementHook[\"Context\",ForEach.Value]"]

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
