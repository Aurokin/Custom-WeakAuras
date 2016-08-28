-- Auro: Tyrant Velhari - Touch of Harm
-- Version: 1.0.2
-- Load: Zone[Hellfire Citadel], EncounterID[1784]

-- Trigger [COMBAT_LOG_EVENT_UNFILTERED, ENCOUNTER_START, AuroBM_TouchofHarm]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
  if (event == "ENCOUNTER_START" and encounterID == aura_env.encounterID) then
    aura_env.rosterSize = GetNumGroupMembers();
    -- Clear Old Roster
    local currentRosterGUID = nil;
    for guid in pairs(aura_env.tohRosterIDs) do
        aura_env.tohRosterIDs[guid] = nil;
    end
    -- Fill Current Roster
    for i = 1, aura_env.rosterSize do
      currentRosterGUID = UnitGUID("raid" .. i);
      aura_env.tohRosterIDs[currentRosterGUID] = i;
      -- print(i .. " - " .. currentRosterGUID);
    end
    print("Tyrant Velhari - Touch of Harm Loaded")
  end
  if (msg == "SPELL_AURA_APPLIED" and (spellID == aura_env.spellID or spellID == (aura_env.spellID + 1))) then
    aura_env.tohGUID = destGUID;
    aura_env.tohName = destName;
    return true;
  elseif (msg == "SPELL_AURA_REMOVED" and (spellID == aura_env.spellID or spellID == (aura_env.spellID + 1))) then
    WeakAuras.ScanEvents(aura_env.eventName);
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
    local tohString = "";
    if not next(aura_env.tohRosterIDs) then return tohString; end
    if not aura_env.tohGUID then return tohString; end
    if not aura_env.tohName then return tohString; end
    local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId, canApplyAura, isBossDebuff, value1, value2, value3 = UnitDebuff("raid" .. tostring(aura_env.tohRosterIDs[aura_env.tohGUID]),"Touch of Harm");
    if not value2 then return tohString; end
    local number, marker = aura_env.shortenNumber(value2);
    tohString = string.format("|T%s:0|t - %s - %.1f%s", "Interface\\Icons\\Spell_Shadow_ChillTouch", tostring(aura_env.tohName), number, marker);
    return tohString;
end

-- Init
aura_env.tohGUID = nil;
aura_env.tohName = nil;
aura_env.encounterID = 1784;
aura_env.spellID = 185237;
aura_env.eventName = "AuroBM_TouchofHarm";
aura_env.tohRosterIDs = {};
aura_env.rosterSize = GetNumGroupMembers();
aura_env.shortenNumber = function(number)
  number = tonumber(number);
  local marker = "";
  if (number > 999 and number < 1000000) then
      marker = "k";
      number = number / 1000;
  elseif (number > 999999) then
      marker = "m";
      number = number / 1000000;
  end
  return number, marker;
end

-- Hide
aura_env.tohGUID = nil;
aura_env.tohName = nil;
