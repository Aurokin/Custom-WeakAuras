-- Auro: Mannoroth - Stamp Reminder
-- Version: 1.0.1
-- Load: Zone[Hellfire Citadel], EncounterID[1795]

-- Notifies when to Stampede based upon assinged mark number, change mark in init

-- Trigger [ENCOUNTER_START, COMBAT_LOG_EVENT_UNFILTERED]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
  if (event == "ENCOUNTER_START" and aura_env.encounterIDs[encounterID] == true) then
      aura_env.markCount = 0;
      print("Auro Stamp Reminder - Loaded");
  end
  if (event == "COMBAT_LOG_EVENT_UNFILTERED" and aura_env) then
    if (msg == "SPELL_CAST_START" and spellID == aura_env.markOfDoomSpellID) then -- Stun Used (Start CD)
      if not aura_env.markCount then return end
      aura_env.markCount = aura_env.markCount + 1;
      if (aura_env.markCount == 3) then
        return true;
      end
    end
  end
end

-- Untrigger [Hide 3s]

-- Init
aura_env.markCount = nil;
aura_env.stampOnMark = 3;
aura_env.markOfDoomSpellID = 181099;
aura_env.encounterIDs = {};
aura_env.encounterIDs[1795] = true;
