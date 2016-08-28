-- Auro: Archimonde - Void Star Fixate
-- Version: 0.0.1
-- Load: EncounterID[1799]

-- Trigger [ENCOUNTER_START, COMBAT_LOG_EVENT_UNFILTERED, AuroBM_VoidStarFixate]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
  if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
    if (msg == "SPELL_AURA_APPLIED" and aura_env.voidStarFixateSpellIDs[spellID] and destGUID == aura_env.playerGUID) then
      return true;
    elseif ((msg == "SPELL_AURA_REMOVED" and aura_env.voidStarFixateSpellIDs[spellID] and destGUID == aura_env.playerGUID) or (msg == "UNIT_DIED" and destGUID == aura_env.playerGUID)) then
      WeakAuras.ScanEvents(aura_env.eventName);
    end
  elseif (event == "ENCOUNTER_START") then
    aura_env.playerGUID = UnitGUID("player");
  end
end

-- Untrigger
function(event)
  if (event == aura_env.eventName) then
    return true;
  end
end

-- Init
aura_env.eventName = "AuroBM_VoidStarFixate";
aura_env.playerGUID = UnitGUID("player");
aura_env.encounterIDs = {};
aura_env.encounterIDs[1799] = true;
aura_env.voidStarFixateSpellIDs = {};
aura_env.voidStarFixateSpellIDs[190806] = true;
aura_env.voidStarFixateSpellIDs[190807] = true;
aura_env.voidStarFixateSpellIDs[190808] = true;
