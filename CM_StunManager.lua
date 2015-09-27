-- Auro CM Stun Manager
-- Load in 5 man Dungeon (Instance Type) and Challenge (Dungeon Difficulty)

-- Trigger [CHALLENGE_MODE_START, CHALLENGE_MODE_RESET, CHALLENGE_MODE_COMPLETED, AuroCM_SM, COMBAT_LOG_EVENT_UNFILTERED, CHAT_MSG_ADDON]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
  if (event == "CHALLENGE_MODE_START" or (event == "CHAT_MSG_ADDON" and encounterID == aura_env.eventName)) then
      local currentTime = GetTime();
      aura_env.dr = 2;
      aura_env.drTime = currentTime - 15;
      aura_env.rosterSize = GetNumGroupMembers();
      if (aura_env.rosterSize <= 1) then
        return false;
      else
        aura_env.inProgress = true;
      end

      for i in pairs(aura_env.stuns) do
          for j in pairs(aura_env.stuns[i]) do
              aura_env.stuns[i][j] = nil;
          end
          aura_env.stuns[i] = nil;
      end

      for i = 1, aura_env.rosterSize do
          local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
          if (class == "Shaman" or class == "Hunter" or class == "Warlock" or class == "Monk" or class == "Warrior" or class == "Death Knight") then
              aura_env.stuns[name] = {};
              aura_env.stuns[name]["icon"] = aura_env.cdInfo[class]["icon"];
              aura_env.stuns[name]["cd"] = aura_env.cdInfo[class]["cd"];
              aura_env.stuns[name]["dur"] = aura_env.cdInfo[class]["dur"];
              aura_env.stuns[name]["spellID"] = aura_env.cdInfo[class]["spellID"];
              aura_env.stuns[name]["stunID"] = aura_env.cdInfo[class]["stunID"];
              aura_env.stuns[name]["lastUse"] = currentTime - aura_env.cdInfo[class]["cd"];
              aura_env.stuns[name]["charging"] = false;
              aura_env.stuns[name]["chargeTime"] = aura_env.cdInfo[class]["chargeTime"];
              aura_env.stuns[name]["active"] = false;
              aura_env.stuns[name]["activeTime"] = currentTime - aura_env.cdInfo[class]["cd"];
              aura_env.stuns[name]["hidden"] = aura_env.cdInfo[class]["hidden"];
              aura_env.stuns[name]["mobsHit"] = 0;
              aura_env.stuns[name]["trimmedName"] = string.gsub(name, "%-[^|]+", "");
          end
      end
      print("Auro CM Stun Manager - Loaded");
      return true;
  elseif (event == "CHALLENGE_MODE_RESET" or event == "CHALLENGE_MODE_COMPLETED") then
      aura_env.inProgress = false;
      WeakAuras.ScanEvents(aura_env.eventName);
  end
  if (event == "COMBAT_LOG_EVENT_UNFILTERED" and aura_env.inProgress == true) then
    if (msg == "SPELL_CAST_SUCCESS") then -- Stun Used (Start CD)
      if not aura_env.stuns[srcName] then return end
      if (spellID == aura_env.stuns[srcName]["spellID"]) then
        aura_env.stuns[srcName]["lastUse"] = GetTime();
        aura_env.stuns[srcName]["charging"] = true;
        aura_env.stuns[srcName]["hidden"] = false;
        aura_env.stuns[srcName]["mobsHit"] = 0;
        if (aura_env.stuns[srcName]["spellID"] == aura_env.cdInfo["Warrior"]["spellID"]) then -- Shockwave Exception
          aura_env.stuns[srcName]["cd"] = aura_env.cdInfo["Warrior"]["cd"];
        end
        if (spellID == aura_env.cdInfo["Hunter"]["spellID"]) then -- Binding Shot Exception
          aura_env.lastBindingName = srcName;
        end
      end
    elseif (msg == "SPELL_AURA_APPLIED") then -- Stun Hit (Start DR + Duration)
      if (srcGUID == aura_env.lastTotemGUID) then -- Cap Totem Exception
        srcName = aura_env.lastTotemName;
        if (aura_env.stuns[srcName]["lastUse"] + 4 > GetTime()) then
          aura_env.stuns[srcName]["chargeTime"] = 3;
        end
      end
      if (spellID == aura_env.cdInfo["Hunter"]["stunID"]) then -- Binding Shot Exception
        srcName = aura_env.lastBindingName;
      end
      if not aura_env.stuns[srcName] then return end
      if (spellID == aura_env.stuns[srcName]["stunID"]) then
        local currentTime = GetTime();
        if (aura_env.dr > 0.25 and (aura_env.stuns[srcName]["activeTime"] + aura_env.stuns[srcName]["dur"]) < currentTime) then
          aura_env.dr = aura_env.dr / 2;
          aura_env.drTime = currentTime;
          aura_env.stuns[srcName]["activeTime"] = currentTime;
          aura_env.stuns[srcName]["charging"] = false;
          aura_env.stuns[srcName]["active"] = true;
        end
        aura_env.stuns[srcName]["mobsHit"] = aura_env.stuns[srcName]["mobsHit"] + 1; -- Counting for shockwave
        if (aura_env.stuns[srcName]["mobsHit"] == 3 and aura_env.cdInfo["Warrior"]["stunID"] == spellID) then -- Shockwave exception
          aura_env.stuns[srcName]["cd"] = 20;
        end
      end
    elseif (msg == "SPELL_SUMMON" and spellID == aura_env.cdInfo["Shaman"]["spellID"]) then  -- Cap Totem Exception
      if not aura_env.stuns[srcName] then return end
      aura_env.lastTotemGUID = destGUID;
      aura_env.lastTotemName = srcName;
    end
  end
end

-- Untrigger
function(event)
  if (event == aura_env.eventName) then -- It should be aura_env.eventName but for some reason it causes an error even though it works. Perhaps post untrigger aura_env no longer exists
    print("Auro CM Stun Manager - Unloaded");
    return true;
  end
end

-- Custom Text [Every Frame]
function()
    local AuroCM_StunString = "";
    if not next(aura_env.stuns) then
        WeakAuras.ScanEvents(aura_env.eventName);
    else
        local currentTime = GetTime();
        if (aura_env.drTime + 15 <= currentTime) then
          aura_env.dr = 2;
        end
        for i in pairs(aura_env.stuns) do
            if (aura_env.stuns[i]["active"] == true and (aura_env.stuns[i]["activeTime"] + (aura_env.stuns[i]["dur"] * aura_env.dr)) <= currentTime) then -- No Longer Active
              aura_env.stuns[i]["active"] = false;
            end
            if (aura_env.stuns[i]["charging"] == true and aura_env.stuns[i]["lastUse"] + aura_env.stuns[i]["chargeTime"] <= currentTime) then
              aura_env.stuns[i]["charging"] = false;
            end
            if (aura_env.stuns[i]["active"] == true) then -- Active
              local activeTime = ((aura_env.stuns[i]["dur"] * aura_env.dr) + aura_env.stuns[i]["activeTime"]) - currentTime;
              AuroCM_StunString = AuroCM_StunString .. string.format("|T%s:%s|t  |c%s%s - %.1f|r\n", aura_env.stuns[i]["icon"], aura_env.iconSize, aura_env.drColors[tostring(aura_env.dr)], aura_env.stuns[i]["trimmedName"], activeTime);
            elseif (aura_env.stuns[i]["charging"] == true) then -- Charging
              local chargeTime = (aura_env.stuns[i]["chargeTime"] + aura_env.stuns[i]["lastUse"]) - currentTime;
              AuroCM_StunString = AuroCM_StunString .. string.format("|T%s:%s|t  |c%s%s - %.1f|r\n", aura_env.stuns[i]["icon"], aura_env.iconSize, "FF0099CC", aura_env.stuns[i]["trimmedName"], chargeTime);
            elseif ((aura_env.stuns[i]["lastUse"] + aura_env.stuns[i]["cd"]) > currentTime) then -- CD
              local cdTime = math.floor((aura_env.stuns[i]["cd"] + aura_env.stuns[i]["lastUse"]) - currentTime);
              AuroCM_StunString = AuroCM_StunString .. string.format("|T%s:%s|t  |c%s%s - %d|r\n", aura_env.stuns[i]["icon"], aura_env.iconSize, "FFD3D3D3", aura_env.stuns[i]["trimmedName"], cdTime);
            elseif (aura_env.stuns[i]["hidden"] == true) then
              AuroCM_StunString = AuroCM_StunString;
            else -- Ready
              AuroCM_StunString = AuroCM_StunString .. string.format("|T%s:%s|t  |c%s%s|r\n", aura_env.stuns[i]["icon"], aura_env.iconSize, aura_env.drColors["2"], aura_env.stuns[i]["trimmedName"]);
            end
        end
    end
    return AuroCM_StunString;
end

-- Init
aura_env.inProgress = false;
aura_env.lastTotemGUID = nil;
aura_env.lastTotemName = nil;
aura_env.lastBindingName = nil;
aura_env.dr = nil;
aura_env.drTime = nil;
aura_env.iconSize = "20";
aura_env.drColors = {};
aura_env.stuns = {};
aura_env.cdInfo = {};
aura_env.rosterSize = GetNumGroupMembers();
aura_env.eventName = "AuroCM_SM";
RegisterAddonMessagePrefix(aura_env.eventName);

aura_env.drColors["2"] = "FFFFFFFF";
aura_env.drColors["1"] = "FF00FF00";
aura_env.drColors["0.5"] = "FFFFFF00";
aura_env.drColors["0.25"] = "FFFF0000";

aura_env.cdInfo["Shaman"] = {};
aura_env.cdInfo["Shaman"]["icon"] = "Interface\\Icons\\Spell_Nature_Brilliance";
aura_env.cdInfo["Shaman"]["cd"] = 45;
aura_env.cdInfo["Shaman"]["dur"] = 5;
aura_env.cdInfo["Shaman"]["spellID"] = 108269;
aura_env.cdInfo["Shaman"]["stunID"] = 118905;
aura_env.cdInfo["Shaman"]["chargeTime"] = 5;
aura_env.cdInfo["Shaman"]["hidden"] = false;

aura_env.cdInfo["Hunter"] = {};
aura_env.cdInfo["Hunter"]["icon"] = "Interface\\Icons\\spell_shaman_bindelemental";
aura_env.cdInfo["Hunter"]["cd"] = 45;
aura_env.cdInfo["Hunter"]["dur"] = 5;
aura_env.cdInfo["Hunter"]["spellID"] = 109248;
aura_env.cdInfo["Hunter"]["stunID"] = 117526;
aura_env.cdInfo["Hunter"]["chargeTime"] = 10;
aura_env.cdInfo["Hunter"]["hidden"] = false;

aura_env.cdInfo["Monk"] = {};
aura_env.cdInfo["Monk"]["icon"] = "Interface\\Icons\\ability_monk_legsweep";
aura_env.cdInfo["Monk"]["cd"] = 45;
aura_env.cdInfo["Monk"]["dur"] = 5;
aura_env.cdInfo["Monk"]["spellID"] = 119381;
aura_env.cdInfo["Monk"]["stunID"] = 119381;
aura_env.cdInfo["Monk"]["chargeTime"] = 0;
aura_env.cdInfo["Monk"]["hidden"] = false;

aura_env.cdInfo["Warrior"] = {};
aura_env.cdInfo["Warrior"]["icon"] = "Interface\\Icons\\Ability_Warrior_Shockwave";
aura_env.cdInfo["Warrior"]["cd"] = 40;
aura_env.cdInfo["Warrior"]["dur"] = 4;
aura_env.cdInfo["Warrior"]["spellID"] = 46968;
aura_env.cdInfo["Warrior"]["stunID"] = 132168;
aura_env.cdInfo["Warrior"]["chargeTime"] = 0;
aura_env.cdInfo["Warrior"]["hidden"] = true;

aura_env.cdInfo["Death Knight"] = {};
aura_env.cdInfo["Death Knight"]["icon"] = "Interface\\Icons\\ability_deathknight_remorselesswinters2";
aura_env.cdInfo["Death Knight"]["cd"] = 60;
aura_env.cdInfo["Death Knight"]["dur"] = 6;
aura_env.cdInfo["Death Knight"]["spellID"] = 108200;
aura_env.cdInfo["Death Knight"]["stunID"] = 115001;
aura_env.cdInfo["Death Knight"]["chargeTime"] = 5;
aura_env.cdInfo["Death Knight"]["hidden"] = true;

aura_env.cdInfo["Warlock"] = {};
aura_env.cdInfo["Warlock"]["icon"] = "Interface\\Icons\\ability_warlock_shadowfurytga";
aura_env.cdInfo["Warlock"]["cd"] = 30;
aura_env.cdInfo["Warlock"]["dur"] = 3;
aura_env.cdInfo["Warlock"]["spellID"] = 30283;
aura_env.cdInfo["Warlock"]["stunID"] = 30283;
aura_env.cdInfo["Warlock"]["chargeTime"] = 0;
aura_env.cdInfo["Warlock"]["hidden"] = false;
