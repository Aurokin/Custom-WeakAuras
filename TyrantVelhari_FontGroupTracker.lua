-- Auro: Tyrant Velhari - Font Group Tracker
-- Version: 1.0.1
-- Load: Zone[Hellfire Citadel]
-- Do Not Load: EncounterID

-- Trigger [COMBAT_LOG_EVENT_UNFILTERED, CHAT_MSG_MONSTER_YELL, ENCOUNTER_START, ENCOUNTER_END, AuroBM_FontGroupTracker]
function(event, encounterID, msg, _, _, _, _, _, destGUID, destName, _, _, spellID, spellName)
  if (event == "ENCOUNTER_START" and encounterID == 1784) then
      -- Init
      aura_env.fontTimers = {};
      for i in pairs(aura_env.fontTimers) do
          aura_env.fontTimers[i] = nil;
      end
      aura_env.lastTimer = nil;
      print("Font Group Tracker Loaded");
  elseif ((event == "ENCOUNTER_END" and encounterID == 1784) or (event == "CHAT_MSG_MONSTER_YELL" and encounterID == "Enough! This is where you die!" and msg == "Tyrant Velhari")) then
      WeakAuras.ScanEvents("AuroBM_FontGroupTracker");
  end

  -- event == "CHAT_MSG_MONSTER_YELL" and encounterID == "Enough! This is where you die!"
  -- will probably just hook this into the elseif for event== "en"

  if (msg == "SPELL_AURA_APPLIED" and spellID == 180526) then
    local auroBM_fontCurrentTime = GetTime();
    if (aura_env.lastTimer == nil or ((aura_env.lastTimer + 5) < auroBM_fontCurrentTime)) then
      aura_env.lastTimer = auroBM_fontCurrentTime;
      table.insert(aura_env.fontTimers, auroBM_fontCurrentTime);
      -- print("Font Group - " .. auroBM_fontCurrentTime);
    end
    return true;
  end
end

-- Untrigger
function(event)
  if (event == "AuroBM_FontGroupTracker") then
    -- Unload
    for i in pairs(aura_env.fontTimers) do
        aura_env.fontTimers[i] = nil;
    end
    aura_env.lastTimer = nil;
    print("Closing Font Group Tracker");
    return true;
  end
end

-- Custom Text
function()
  local auroBM_fontString = "";
  if not next(aura_env.fontTimers) then
      WeakAuras.ScanEvents("AuroBM_FontGroupTracker");
  else
    local auroBM_fontCurrentTime = GetTime();
    for i in pairs(aura_env.fontTimers) do
      if (aura_env.fontTimers[i] + 52 < auroBM_fontCurrentTime) then
        aura_env.fontTimers[i] = nil;
      else
        local auroBM_fontTimeLeft = math.floor((aura_env.fontTimers[i] + 52) - auroBM_fontCurrentTime);
        if (auroBM_fontTimeLeft > 4) then
          auroBM_fontString = auroBM_fontString .. "Font Group #" .. i .. " - " .. auroBM_fontTimeLeft .. "s\n";
        else
          auroBM_fontString = auroBM_fontString .. "|cFFFF0000Font Group #" .. i .. " - " .. auroBM_fontTimeLeft .. "s|r\n";
        end
      end
    end
  end
  return auroBM_fontString;
end

-- Init
aura_env.fontTimers = {};
aura_env.lastTimer = nil;
