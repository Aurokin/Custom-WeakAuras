-- Auro: Archimonde - Stamp Reminder
-- Version: 1.0.0
-- Load: Zone[Hellfire Citadel], EncounterID[1799]

-- Notifies when to Stampede based upon assinged shackle number, change mark in init

-- Trigger [ENCOUNTER_START, COMBAT_LOG_EVENT_UNFILTERED]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
  if (event == "ENCOUNTER_START" and aura_env.encounterIDs[encounterID] == true) then
      aura_env.shackleCount = 1;
      print("Auro Stamp Reminder - Loaded");
  end
  if (event == "COMBAT_LOG_EVENT_UNFILTERED" and aura_env) then
    if (msg == "SPELL_CAST_START" and spellID == aura_env.shackleCastSpellID) then -- Stun Used (Start CD)
      if not aura_env.shackleCount then return end
      if (aura_env.shackleCount == 3) then
        return true;
      end
      aura_env.shackleCount = aura_env.shackleCount + 1;
    end
  end
end

-- Untrigger [Hide 3s]

-- Init
aura_env.shackleCount = nil;
aura_env.stampOnMark = 3;
aura_env.shackleCastSpellID = 184931;
aura_env.encounterIDs = {};
aura_env.encounterIDs[1799] = true;
