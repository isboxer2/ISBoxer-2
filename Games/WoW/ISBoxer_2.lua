isboxer2 = { }

isboxer2.Character = { LoadBinds=nil, Name="" }
isboxer2.Team = { LoadBinds=nil, Name="", Members={} }
isboxer2.Following = { Unit="", ReFollow=0 }
isboxer2.Master = { Name="", Self=1}
isboxer2.NextButton = 1;
isboxer2.ManageJambaTeam = false

function isboxer2.DetectJamba5()
	if (isboxer2.JambaDetectionRan) then
		return
	end
	isboxer2.JambaDetectionRan = true;

 if (LibStub and LibStub:GetLibrary("AceAddon-3.0",1)) then	
 	isboxer2.JambaTeam = LibStub("AceAddon-3.0"):GetAddon("JambaTeam",1);
 	isboxer2.JambaFollow = LibStub("AceAddon-3.0"):GetAddon("JambaFollow",1);
 end

end

function isboxer2.ClearMembers()
    
	local max = table.getn(isboxer2.Team.Members)
	for i=1,max,1 do table.remove(isboxer2.Team.Members) end

	if (not isboxer2.ManageJambaTeam) then
		return
	end

	if (JambaComms) then
		JambaComms:DisableAllMembersCommand(nil,nil);
		return
	end
	isboxer2.DetectJamba5();
	if (JambaApi and isboxer2.JambaTeam) then
		for characterName, characterPosition in JambaApi.TeamList() do
			isboxer2.JambaTeam:RemoveMemberCommand(nil,characterName);
		end
	end
end

function isboxer2.AddMember(name)
    table.insert(isboxer2.Team.Members,name)

	if (not isboxer2.ManageJambaTeam) then
		return
	end

	if (JambaComms) then
		JambaComms:AddMemberCommand(nil,name);
		JambaComms:EnableMemberCommand(nil,name);
		return
	end
	isboxer2.DetectJamba5();
	if (isboxer2.JambaTeam) then
		isboxer2.JambaTeam:AddMemberCommand(nil,name);
	end
end

function isboxer2.SetMaster(name)
	if (JambaComms) then
		JambaComms:SetMaster(nil,name);		
	end
	isboxer2.DetectJamba5();
	if (isboxer2.JambaTeam) then
		isboxer2.JambaTeam:AddMemberCommand(nil,name);
	end
end

function isboxer2.Output(text)
	DEFAULT_CHAT_FRAME:AddMessage("ISBoxer 2: "..text,1.0,1.0,1.0); 	
end

function isboxer2.Warning(text)
	DEFAULT_CHAT_FRAME:AddMessage("ISBoxer 2 warning: "..text,1.0,1.0,1.0);
	UIErrorsFrame:AddMessage("ISBoxer 2: "..text,1.0,0.0,0.0,53,15);
end

function isboxer2.CheckBoundCombo(key,combo)
	local action = GetBindingAction(combo);
	if (action and action~="") then
		isboxer2.Warning("Modifier conditions used for targeting on '"..key.."' may not work because "..combo.." is bound to "..action); 	
	end
end

function isboxer2.SetMacro(usename,key,macro)
	if (key and key~="" and key~="none") then
		local action = GetBindingAction(key);
		if (action and action~="") then
			isboxer2.Warning(key.." is bound to "..action..". ISBoxer 2 is overriding this binding.");
		end
	end

	local name
	if (usename and usename~="") then
		name = usename
	else
		name = "ISBoxer2Macro"..isboxer2.NextButton;
	end
	isboxer2.NextButton = isboxer2.NextButton + 1;
	local button = CreateFrame("Button",name,nil,"SecureActionButtonTemplate");
	button:RegisterForClicks("LeftButtonDown")
	button:SetAttribute("type1","macro");
	button:SetAttribute("macrotext1",macro);
	button:Hide();
	if (key and key~="" and key~="none") then
		SetOverrideBindingClick(isboxer2.frame,false,key,name,"LeftButton");
	end
end

function isboxer2.LoadBinds()
	if (isboxer2.Team.LoadBinds or isboxer2.Character.LoadBinds) then
		if (isboxer2.Team.LoadBinds) then
			isboxer2.Team.LoadBinds();
			isboxer2.Output("WoW Macros for Character Set '"..isboxer2.Team.Name.."' Loaded.");
		end
		if (isboxer2.Character.LoadBinds) then
			isboxer2.Character.LoadBinds();
			isboxer2.Output("WoW Macros for Character '"..isboxer2.Character.Name.."' in Set '"..isboxer2.Team.Name.."' Loaded.");
			if (isboxer2.Character.ActualName~="*" and isboxer2.Character.ActualName:upper()~=GetUnitName("player"):upper()) then

				StaticPopupDialogs["ISBOXER2_WRONGCHARACTER"] = {
				  text = "Character in wrong window? ISBoxer 2 expected "..isboxer2.Character.ActualName.." but got "..GetUnitName("player")..". Some functionality may not work correctly!",
				  button1 = OKAY,
				  timeout = 0,
				  whileDead = true,
				  hideOnEscape = true,
				}
				StaticPopup_Show("ISBOXER2_WRONGCHARACTER");
				isboxer2.Warning("Expected "..isboxer2.Character.ActualName.." but got "..GetUnitName("player"));
			end
		end
	else
		isboxer2.Output("No WoW Macros loaded.");
	end
end

function isboxer2_eventHandler(self, event, ...)
    if (event=="UPDATE_BINDINGS" or event=="PLAYER_ENTERING_WORLD") then
	    self:UnregisterEvent("UPDATE_BINDINGS");
	    self:UnregisterEvent("PLAYER_ENTERING_WORLD");
	    isboxer2.Output("Loading Key Bindings...");
            isboxer2.LoadBinds();       
    end
    if (event=="AUTOFOLLOW_BEGIN") then
    end
    if (event=="AUTOFOLLOW_END") then
    end
    if (event=="PARTY_INVITE_REQUEST") then
    end
    if (event=="PARTY_LEADER_CHANGED") then
    end
    if (event=="PARTY_MEMBERS_CHANGED") then
    end
    if (event=="CHAT_MSG_WHISPER") then
    end
end

--function isboxer_onUpdate(self, elapsed)
--  local now = GetTime();
--   
--end

isboxer2.frame = CreateFrame("FRAME", "ISBoxer2EventFrame");
isboxer2.frame:RegisterEvent("UPDATE_BINDINGS");
isboxer2.frame:RegisterEvent("PLAYER_ENTERING_WORLD");
isboxer2.frame:SetScript("OnEvent", isboxer2_eventHandler);
--isboxer2.frame:SetScript("OnUpdate", isboxer_onUpdate);

function isboxer2.Follow(target)
	if (JambaFollow) then
		-- hack for Jamba's self-detection checking against the player name...
		local name = target;
		--if (UnitIsUnit(target,"player")) then
			name = UnitName(target);
		--end
		
		if (not name or name=="") then
			name = target
		end
		
		if (JambaFollow.followingStrobing) then
			JambaFollow:FollowStrobeOn(name);
		else
			JambaFollow:FollowTarget(name);
		end
	end
	isboxer2.DetectJamba5();
	if (isboxer2.JambaFollow) then
		-- hack for Jamba's self-detection checking against the player name...
		local name = target;
		--if (UnitIsUnit(target,"player")) then
			name = UnitName(target);
		--end
		
		if (not name or name=="") then
			name = target
		end
		
		if (JambaApi.Follow:IsFollowingStrobing()) then
			isboxer2.JambaFollow:FollowStrobeOn(name);
		else
			isboxer2.JambaFollow:FollowTarget(name);
		end		
	end

	FollowUnit(target);
end

SlashCmdList["FOLLOW"]=function(msg)
	msg = SecureCmdOptionParse(msg);
	if (not msg or msg=="") then
		msg="target";
	end
	
	if (UnitIsPlayer(msg)) then
		isboxer2.Follow(msg);
		return
	end
	for i=1,5 do
		if (UnitIsUnit(msg,"partypet"..i)) then
			isboxer2.Follow("party"..i);
			return
		end
	end
	for i=1,40 do
		if (UnitIsUnit(msg,"raidpet"..i)) then
			isboxer2.Follow("raid"..i);
			return
		end
	end
	
	isboxer2.Follow(msg);	
end

isboxer2.Output("ISBoxer 2 Addon v1.0 (2022-11-12) Loaded.");
