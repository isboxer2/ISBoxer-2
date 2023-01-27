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

            if !${ISUplink(exists)}
                joHook:SetString[method,ForwardHookedEvent]
            
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
        {
            if ${ISUplink(exists)} || ${joReq.Get[source]~.Equal[session]}
            {
                This:InstallAchievementHook["${joReq.Get[hook]~}",joAchieve]
            }
        }
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
                    "type":"value",
                    "name":"slideIn",
                    "duration":0.15,
                    "valueName":"yFactor",
                    "originalValue":1.1,
                    "finalValue":0.2
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

    method ApplyAchievementReq(jsonvalueref joEventArgs, jsonvalueref joAchieve, int64 reqId, jsonvalueref joReq, jsonvalueref joResult, jsonvalueref joUserData)
    {
        variable bool ourEvent=${joReq.Assert[hook,"${joEventArgs.Get[event].AsJSON~}"]}
        variable bool completed
        variable jsonvalueref jo="joUserData.Get[-init,\"{}\",reqs].Get[-init,\"{}\",${reqId}]"

        if ${ourEvent}
        {
            if ${joReq.Has[args]}
            {
                ; args has to match too (at least the required parts)
                ourEvent:Set["${This.Object_LooseMatch["joReq.Get[args]","joEventArgs.Get[args]"]}"]
            }
            if ${ourEvent}
            {
                if ${joEventArgs.Has[-string,session]}
                {
                    ; remote event
                    ourEvent:Set[${joReq.Assert[source,"\"session\""]}]
                }
                else
                {
                    ; local event
                    switch ${joReq.Get[source]~}
                    {
                        case uplink
                            ourEvent:Set["${ISUplink(exists)}"]
                            break
                        case session
                            ourEvent:Set["!${ISUplink(exists)}"]
                            break
                    }
                }                    
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

    method ApplyAchievementHook(jsonvalueref joEventArgs, jsonvalueref joAchieve)
    {
        variable jsonvalueref jo="UserData.Get[-init,{},\"${joAchieve.GetInteger[id]}\"]"

  ;      variable bool completed=1

        if ${jo.Has[completed]}
        {
            return
        }
;        echo "ApplyAchievementHook ${joEventargs.Get[event]~} ${joAchieve~}"


        variable jsonvalueref joResult
        joResult:SetReference["{\"completed\":true}"]
        joAchieve.Get[reqs]:ForEach["This:ApplyAchievementReq[\"joEventArgs\",joAchieve,\${ForEach.Key},ForEach.Value,joResult,jo]"]

        if ${joResult.GetBool[completed]}
        {
            ShouldSave:Set[1]
            jo:SetInteger[completed,"${time.Now.Timestamp}"]
    
            This:OnAchievementCompleted[joAchieve]

            if ${joEventArgs.Has[-string,session]}
            {
                InnerSpace:Relay["${joEventArgs.Get[session]~}","isb2_achievements.Instance:OnRemoteAchievementCompleted[${joAchieve.GetInteger[id]}]"]
            }
        }
    }

    method ForwardHookedEvent()
    {
        variable jsonvalue joRelay="{\"object\":\"isb2_achievements.Instance\",\"method\":\"OnRemoteEvent\"}"
        joRelay:SetString[target,"uplink"]
        joRelay:SetByRef[eventargs,"Context.AsJSON"]
        InnerSpace:Relay["${joRelay~}"]
    }

    method OnRemoteAchievementCompleted(int64 id)
    {
        variable jsonvalueref joAchieve="Achievements.Get[${id}]"
        if !${joAchieve.Reference(exists)}
            return

        This:OnAchievementCompleted[joAchieve]
    }

    method OnRemoteEvent()
    {
;        echo "\apOnRemoteEvent\ax ${Context(type)} ${Context~} ${This(type)}"
        variable jsonvalueref joEventArgs="Context.Get[eventargs]"
        joEventArgs:SetString[session,"${Context.Get[source]~}"]
;        echo "joEventArgs=${joEventArgs~}"
        
        variable jsonvalueref ja

        ja:SetReference["This.GetAchievementsFromHook[\"${joEventArgs.Get[event]~}\"]"]

;        echo "applicable achievements: ${ja~}"
        ja:ForEach["This:ApplyAchievementHook[\"joEventArgs\",ForEach.Value]"]

        This:AutoSave
    }

    method OnHookedEvent()
    {
;        echo "\ayisb2_achievements:OnHookedEvent\ax ${Context(type)} ${Context.Event} ${Context.Source} ${Context.Args}"

        variable jsonvalueref ja="This.GetAchievementsFromHook[\"${Context.Event~}\"]"

;        echo "applicable achievements: ${ja~}"
        ja:ForEach["This:ApplyAchievementHook[\"Context.AsJSON\",ForEach.Value]"]

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
        if !${ISUplink(exists)}
            return

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
        if !${ISUplink(exists)}
            return FALSE
        return ${UserData:WriteFile["${This.SettingsFilename~}",multiline](exists)}
    }

}
