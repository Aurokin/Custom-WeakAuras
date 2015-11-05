-- Auro: CM Tracker
-- Version: 1.0.6
-- Place Both Auras In Group
-- Timer - Justified: Center, Anchor: Top, Y Offset: 25
-- Objectives - Justified: Left, Anchor: Top, Y Offset: 0

-- Auro: CM Tracker Timer
-- Version: 1.0.6
-- Load: Dungeon Difficulty[Challenge]

-- Trigger [COMBAT_LOG_EVENT_UNFILTERED, ENCOUNTER_START, ZONE_CHANGED_NEW_AREA, PLAYER_LOGIN, CHALLENGE_MODE_START, CHAT_MSG_ADDON]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
  if (event == "CHALLENGE_MODE_START") then
    local _, _, _, difficultyName, _, _, _, currentZoneID = GetInstanceInfo();
    aura_env.trackerString = nil;
    aura_env.currentZoneID = currentZoneID;
    return true;
  elseif (event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_LOGIN"  or (event == "CHAT_MSG_ADDON" and encounterID == aura_env.eventName)) then
    local _, _, _, difficultyName, _, _, _, currentZoneID = GetInstanceInfo();
    aura_env.currentZoneID = currentZoneID;
    if difficultyName == "Challenge Mode" then
        -- hide blizzard challenge mode frame
        aura_env.trackerString = nil;
        ObjectiveTrackerFrame:SetScript("OnEvent", nil);
        ObjectiveTrackerFrame:Hide();
        return true;
    end
  end
end

-- Untrigger
function()
  return false;
end

-- Custom Text [Every Frame]
function()
  return aura_env.prepareString();
end

-- Init
aura_env.eventName = "AuroCM_Timer";
RegisterAddonMessagePrefix(aura_env.eventName);
aura_env.colorSuccess = "000ff000";
aura_env.reportEndTime = true;
aura_env.currentZoneID = nil;
aura_env.trackerString = nil;
aura_env.goldTimes = {};
aura_env.goldTimes[1195] = "20:00";  -- Iron Docks
aura_env.goldTimes[1208] = "14:30";  -- Grimrail Depot
aura_env.goldTimes[1279] = "17:30";  -- The Everbloom
aura_env.goldTimes[1175] = "22:00";  -- Bloodmaul Slag Mines
aura_env.goldTimes[1182] = "19:00";  -- Auchindoun
aura_env.goldTimes[1209] = "17:00";  -- Skyreach
aura_env.goldTimes[1176] = "17:30";  -- Shadowmoon Burial Grounds
aura_env.goldTimes[1358] = "25:00";  -- Upper Blackrock Spire
aura_env.currentTimeString = function()
  -- Timer
  local _, timeCM = GetWorldElapsedTime(1);
  if not timeCM then return ""; end
  local timeMin = timeCM / 60;
  if (timeMin < 10) then
    timeMin = string.format("0%d", timeMin);
  else
    timeMin = string.format("%d", timeMin);
  end
  local timeSec = timeCM - (timeMin * 60);
  if (timeSec < 10) then
    timeSec = string.format("0%d", timeSec);
  else
    timeSec = string.format("%d", timeSec);
  end
  local currentTime = string.format("%s:%s", timeMin, timeSec);
  return currentTime;
end
aura_env.prepareString = function()
  -- Conditions Start
  if WeakAuras.IsOptionsOpen() then
    if aura_env.reportEndTime == true then
      return "00:00" .. " / " .. "20:00";
    else
      return "00:00";
    end
  end
  local _, _, _, difficultyName = GetInstanceInfo();
  if difficultyName ~= "Challenge Mode" then
    return "Not In CM";
  end
  local dungeon, _, steps = C_Scenario.GetStepInfo();
  if steps == 0 then
    return aura_env.trackerString or "00:00";
  end
  -- Conditions End
  aura_env.trackerString = "";
  -- Objectives
  local currentTime = aura_env.currentTimeString();
  if (aura_env.reportEndTime == true and aura_env.goldTimes[aura_env.currentZoneID]) then
    aura_env.trackerString = currentTime .. " / " .. aura_env.goldTimes[aura_env.currentZoneID];
  else
    aura_env.trackerString = currentTime;
  end
  return aura_env.trackerString;
end

-- Auro: CM Tracker Objectives
-- Version: 1.0.6
-- Load: Dungeon Difficulty[Challenge]

-- Trigger [COMBAT_LOG_EVENT_UNFILTERED, ENCOUNTER_START, ZONE_CHANGED_NEW_AREA, PLAYER_LOGIN, CHALLENGE_MODE_START, CHAT_MSG_ADDON]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
  if (event == "CHALLENGE_MODE_START") then
    aura_env.trackerString = nil;
    aura_env.wipeTable(aura_env.completeTimes);
    return true;
  elseif (event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_LOGIN"  or (event == "CHAT_MSG_ADDON" and encounterID == aura_env.eventName)) then
    local _, _, _, difficultyName = GetInstanceInfo();
    if difficultyName == "Challenge Mode" then
        -- hide blizzard challenge mode frame
        ObjectiveTrackerFrame:SetScript("OnEvent", nil);
        ObjectiveTrackerFrame:Hide();
        return true;
    end
  end
end

-- Untrigger
function()
  return false;
end

-- Custom Text [Every Frame]
function()
  return aura_env.prepareString();
end

-- Init
aura_env.eventName = "AuroCM_Timer";
RegisterAddonMessagePrefix(aura_env.eventName);
aura_env.trackerString = nil;
aura_env.colorSuccess = "000ff000";
aura_env.completeTimes = {};
aura_env.wipeTable = function(table)
  -- Clear Table
  for guid in pairs(table) do
      table[guid] = nil;
  end
end
aura_env.currentTimeString = function()
  -- Timer
  local _, timeCM = GetWorldElapsedTime(1);
  if not timeCM then return ""; end
  local timeMin = timeCM / 60;
  if (timeMin < 10) then
    timeMin = string.format("0%d", timeMin);
  else
    timeMin = string.format("%d", timeMin);
  end
  local timeSec = timeCM - (timeMin * 60);
  if (timeSec < 10) then
    timeSec = string.format("0%d", timeSec);
  else
    timeSec = string.format("%d", timeSec);
  end
  local currentTime = string.format("%s:%s", timeMin, timeSec);
  return currentTime;
end
aura_env.prepareString = function()
  -- Conditions Start
  if WeakAuras.IsOptionsOpen() then
    local preview = "";
    preview = preview .. "Fleshrender Nok'gar - 0/1\n";
    preview = preview .. "Enemies - 0/44\n";
    preview = preview .. "Grimrail Enforcers - 0/1\n";
    preview = preview .. "Oshir - 0/1\n";
    preview = preview .. "Skulloc - 0/1\n";
    return preview;
  end
  local _, _, _, difficultyName = GetInstanceInfo();
  if difficultyName ~= "Challenge Mode" then
    return "Not In CM";
  end
  local dungeon, _, steps = C_Scenario.GetStepInfo();
  if steps == 0 then
    return aura_env.trackerString or "CM Not Started";
  end
  -- Conditions End
  aura_env.trackerString = "";
  -- Objectives
  for i = 1, steps do
    local name, _, status, curValue, finalValue = C_Scenario.GetCriteriaInfo(i);
    if (status == false) then
      aura_env.trackerString = aura_env.trackerString .. string.format("%s - %d/%d\n", name, curValue, finalValue);
    elseif (status == true) then
      if not aura_env.completeTimes[i] then
        local currentTime = aura_env.currentTimeString();
        aura_env.completeTimes[i] = string.format("|c%s%s|r", aura_env.colorSuccess, currentTime);
      end
      aura_env.trackerString = aura_env.trackerString .. string.format("%s - %d/%d - %s\n",  name, curValue, finalValue, aura_env.completeTimes[i]);
    end
  end
  return aura_env.trackerString;
end
