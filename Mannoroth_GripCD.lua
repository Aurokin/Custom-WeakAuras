-- Mannoroth Grip Manager
-- Load in Hellfire Citadel

-- Trigger [ENCOUNTER_START, ENCOUNTER_END, COMBAT_LOG_EVENT_UNFILTERED, Auro_GripMonitor, Auro_MannorothGripReminder]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
  if (event == "ENCOUNTER_START" and aura_env.encounterIDs[encounterID] == true) then
      local currentTime = GetTime();
      aura_env.rosterSize = GetNumGroupMembers();
      if (aura_env.rosterSize <= 1) then
        return false;
      end
      for i in pairs(aura_env.grips) do
          for j in pairs(aura_env.grips[i]) do
              aura_env.grips[i][j] = nil;
          end
          aura_env.grips[i] = nil;
      end

      for i = 1, aura_env.rosterSize do
          local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
          if (class == "Death Knight") then
              aura_env.grips[name] = {};
              aura_env.grips[name]["icon"] = "Interface\\Icons\\ability_deathknight_aoedeathgrip";
              aura_env.grips[name]["cd"] = 60;
              aura_env.grips[name]["spellID"] = 108199;
              aura_env.grips[name]["lastUse"] = currentTime - 60;
              aura_env.grips[name]["hidden"] = false;
              aura_env.grips[name]["trimmedName"] = string.gsub(name, "%-[^|]+", "");
          end
      end
      print("Auro Grip Manager - Loaded");
      return true;
  elseif (event == "ENCOUNTER_END" and aura_env.encounterIDs[encounterID] == true) then
    WeakAuras.ScanEvents(aura_env.eventName);
  end
  if (event == "COMBAT_LOG_EVENT_UNFILTERED" and aura_env.grips) then
    if (msg == "SPELL_CAST_SUCCESS") then -- Stun Used (Start CD)
      if not aura_env.grips[srcName] then return end
      if (spellID == aura_env.grips[srcName]["spellID"]) then
        aura_env.grips[srcName]["lastUse"] = GetTime();
        aura_env.grips[srcName]["hidden"] = false;
      end
    end
  elseif (event == aura_env.gripReminderEvent and aura_env.grips) then
    -- Trigger is from Mannoroth_ImpBlinkTimer
    -- Works well with two DKs, may not rotate in additional DKs
    local currentTime = GetTime();
    for i in pairs(aura_env.grips) do
      if (aura_env.grips[i]["lastUse"] + aura_env.grips[i]["cd"] <= currentTime) then
        -- print(i .. "Grip!");
        if (aura_env.playerName == aura_env.gripAnnouncer) then
          SendChatMessage(i .. " - Grip!", "RAID_WARNING");
          -- print("AuroReportingIn");
        end
        break;
      end
    end
  end
end

-- Untrigger
function(event)
  if (event == aura_env.eventName) then
    return true;
  end
end

-- Custom Text [Every Frame]
function()
    local Auro_GripMonitor = "";
    if not next(aura_env.grips) then
        WeakAuras.ScanEvents(aura_env.eventName);
    else
        local currentTime = GetTime();
        for i in pairs(aura_env.grips) do
            if (aura_env.grips[i]["lastUse"] + aura_env.grips[i]["cd"] >= currentTime) then
              local cdTime = math.floor((aura_env.grips[i]["cd"] + aura_env.grips[i]["lastUse"]) - currentTime);
              Auro_GripMonitor = Auro_GripMonitor .. string.format("|T%s:%s|t  |c%s%s - %d|r\n", aura_env.grips[i]["icon"], aura_env.iconSize, "FFD3D3D3", aura_env.grips[i]["trimmedName"], cdTime);
            else -- Ready
              Auro_GripMonitor = Auro_GripMonitor .. string.format("|T%s:%s|t  |c%s%s|r\n", aura_env.grips[i]["icon"], aura_env.iconSize, "FFFFFFFF", aura_env.grips[i]["trimmedName"]);
            end
        end
    end
    return Auro_GripMonitor
end

-- Init
aura_env.iconSize = "20";
aura_env.grips = {};
aura_env.cdInfo = {};
aura_env.encounterIDs = {};
aura_env.rosterSize = GetNumGroupMembers();
aura_env.eventName = "Auro_GripMonitor";
aura_env.gripReminderEvent = "Auro_MannorothGripReminder";
aura_env.playerName = GetUnitName("player");
aura_env.gripAnnouncer = "Auro";

aura_env.encounterIDs[1795] = true;
aura_env.encounterIDs[1800] = true;

-- On Hide
print("Auro Grip Manager - Unloaded");
