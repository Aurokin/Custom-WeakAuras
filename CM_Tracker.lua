-- Auro: CM Tracker
-- Version: 1.2
-- Place Both Auras In Group
-- Font: Arial Narrow
-- Timer - Justified: Center, Size: 28, Anchor: Top, Y Offset: 25
-- Objectives - Justified: Left, Size: 17, Anchor: Top, Y Offset: 0

-- Auro: CM Tracker Timer
-- Version: 1.1.1
-- Load: Dungeon Difficulty[Challenge]

-- Trigger [COMBAT_LOG_EVENT_UNFILTERED, ENCOUNTER_START, ZONE_CHANGED_NEW_AREA, PLAYER_LOGIN, CHALLENGE_MODE_START, CHALLENGE_MODE_RESET, CHAT_MSG_ADDON]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
  if (event == "CHALLENGE_MODE_START") then
    local _, _, _, difficultyName, _, _, _, currentZoneID = GetInstanceInfo();
    aura_env.trackerString = nil;
    aura_env.currentZoneID = currentZoneID;
    aura_env.cmStart = GetTime();
    return true;
  elseif (event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_LOGIN"  or (event == "CHAT_MSG_ADDON" and encounterID == aura_env.eventName)) then
    local _, _, _, difficultyName, _, _, _, currentZoneID = GetInstanceInfo();
    aura_env.currentZoneID = currentZoneID;
    if difficultyName == "Challenge Mode" then
        -- hide blizzard challenge mode frame
        aura_env.trackerString = nil;
        aura_env.cmStart = nil;
        ObjectiveTrackerFrame:SetScript("OnEvent", nil);
        ObjectiveTrackerFrame:Hide();
        return true;
    end
  elseif (event == "CHALLENGE_MODE_RESET") then
    aura_env.trackerString = nil;
    aura_env.cmStart = nil;
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
aura_env.trueTimer = true;
aura_env.currentZoneID = nil;
aura_env.trackerString = nil;
aura_env.cmStart = nil;
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
  local currentTime = "";
  local time_CM = nil;
  local sysTime = nil;
  local timeMin = nil;
  local timeSec = nil;
  local timeMS = nil;
  if (aura_env.trueTimer == true and aura_env.cmStart) then
    sysTime = GetTime();
    timeCM = sysTime - aura_env.cmStart;
  else
    _, timeCM = GetWorldElapsedTime(1);
  end
  if not timeCM then return ""; end
  timeMin = timeCM / 60;
  if (timeMin < 10) then
    timeMin = string.format("0%d", timeMin);
  else
    timeMin = string.format("%d", timeMin);
  end
  timeSec = timeCM - (timeMin * 60);
  if (aura_env.trueTimer == true and aura_env.cmStart) then
    if (timeSec < 10) then
      timeSec = string.format("0%.3f", timeSec);
    else
      timeSec = string.format("%.3f", timeSec);
    end
  else
    if (timeSec < 10) then
      timeSec = string.format("0%d", timeSec);
    else
      timeSec = string.format("%d", timeSec);
    end
  end
  -- timeMS = timeCM - timeMin - timeSec;
  currentTime = string.format("%s:%s", timeMin, timeSec);
  return currentTime;
end
aura_env.prepareString = function()
  -- Conditions Start
  if WeakAuras.IsOptionsOpen() then
    if aura_env.trueTimer == true and aura_env.reportEndTime == true then
      return "00:00.000" .. " / " .. "20:00";
    elseif aura_env.trueTimer == true and aura_env.reportEndTime == false then
      return "00:00.000";
    elseif aura_env.trueTimer == false and aura_env.reportEndTime == true then
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
    local timerStartString = "00:00";
    if (aura_env.trueTimer == true) then
      timerStartString = "00:00.000";
    end
    return aura_env.trackerString or timerStartString;
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
-- Version: 1.1.4
-- Load: Dungeon Difficulty[Challenge]

-- Trigger [COMBAT_LOG_EVENT_UNFILTERED, ENCOUNTER_START, ZONE_CHANGED_NEW_AREA, PLAYER_LOGIN, CHALLENGE_MODE_START, CHALLENGE_MODE_COMPLETED, CHAT_MSG_ADDON]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
  if (event == "CHALLENGE_MODE_START") then
    aura_env.trackerString = nil;
    aura_env.fillTables();
    return true;
  elseif (event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_LOGIN" or (event == "CHAT_MSG_ADDON" and encounterID == aura_env.eventName)) then
    local _, _, _, difficultyName = GetInstanceInfo();
    if aura_env.areWeGood() == false then aura_env.fillTables(); end
    if difficultyName == "Challenge Mode" then
        -- hide blizzard challenge mode frame
        ObjectiveTrackerFrame:SetScript("OnEvent", nil);
        ObjectiveTrackerFrame:Hide();
        return true;
    end
  elseif (event == "CHALLENGE_MODE_COMPLETED") then
    if not aura_env.steps then return false; end
    local finalString = "";
    for i = 1, aura_env.steps do
      local name = aura_env.names[i];
      local finalValue = aura_env.finalValues[i];
      local curValue = finalValue;
      if not name or not finalValue then return false; end
      -- Text is not green this way, just need to make it green!
      -- if not aura_env.completeTimes[i] then aura_env.completeTimes[i] = aura_env.lastTime; end
      finalString = finalString .. aura_env.objectiveString(name, curValue, finalValue, aura_env.completeTimes[i], i);
    end
    aura_env.trackerString = finalString;
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
aura_env.names = {};
aura_env.finalValues = {};
aura_env.steps = nil;
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
aura_env.fillTables = function()
  aura_env.wipeTable(aura_env.completeTimes);
  aura_env.wipeTable(aura_env.names);
  aura_env.wipeTable(aura_env.finalValues);
  local _, _, steps = C_Scenario.GetStepInfo();
  aura_env.steps = steps;
  for i = 1, steps do
    local name, _, _, _, finalValue = C_Scenario.GetCriteriaInfo(i);
    aura_env.names[i] = name;
    aura_env.finalValues[i] = finalValue;
  end
end
aura_env.areWeGood = function()
  if not next(aura_env.names) or not next(aura_env.finalValues) or not aura_env.steps then
    return false;
  end
  return true;
end
aura_env.objectiveString = function(name, curValue, finalValue, completeTime, i)
  if (curValue == finalValue) then
    if not completeTime then
      completeTime = aura_env.currentTimeString();
      if completeTime == "" or 0 then
        completeTime = aura_env.lastTime;
      end
      completeTime = string.format("|c%s%s|r", aura_env.colorSuccess, completeTime);
      aura_env.completeTimes[i] = completeTime;
    end
    return string.format("%s - %d/%d - %s\n",  name, curValue, finalValue, completeTime);
  end
  return string.format("%s - %d/%d\n", name, curValue, finalValue);
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
  aura_env.lastTime = aura_env.currentTimeString();
  -- Objectives
  for i = 1, steps do
    local name, _, status, curValue, finalValue = C_Scenario.GetCriteriaInfo(i);
    aura_env.trackerString = aura_env.trackerString .. aura_env.objectiveString(name, curValue, finalValue, aura_env.completeTimes[i], i);
  end
  return aura_env.trackerString;
end
