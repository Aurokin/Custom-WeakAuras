-- Auro: Archimonde - Stamp Reminder
-- Version: 1.0.0
-- Load: Zone[Hellfire Citadel], EncounterID[1799]

-- Notifies when to Stampede based upon assinged shackle number, change mark in init

-- Trigger [ENCOUNTER_START, COMBAT_LOG_EVENT_UNFILTERED]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
  if (event == "ENCOUNTER_START" and aura_env.encounterIDs[encounterID] == true) then
      aura_env.flameCount = 0;
      aura_env.playerName = UnitName("player");
      aura_env.playerName = string.gsub(aura_env.playerName, "%-[^|]+", "");
      print("Auro: Felbourne Kick - Loaded");
  end
  if (event == "COMBAT_LOG_EVENT_UNFILTERED" and aura_env) then
    if (msg == "SPELL_CAST_START" and spellID == aura_env.flamesCastSpellID) then -- Stun Used (Start CD)
      if not aura_env.flameCount then return end
      if not aura_env.playerName then return end
      aura_env.flameCount = aura_env.flameCount + 1;
      if (aura_env.flameCount >= 4) then
        aura_env.flameCount = aura_env.flameCount - 3;
      end
      if (aura_env.kickOrder[aura_env.flameCount]) then
        if (aura_env.kickOrder[aura_env.flameCount][aura_env.playerName]) then
          return true;
        end
      end
    end
  end
end

-- Untrigger [Hide 3s]

-- Init
aura_env.flameCount = nil;
aura_env.flamesCastSpellID = 186663;
aura_env.encounterIDs = {};
aura_env.encounterIDs[1799] = true;
aura_env.playerName = nil;
aura_env.kickOrder = {};
aura_env.kickOrder[1] = {};
aura_env.kickOrder[2] = {};
aura_env.kickOrder[3] = {};
aura_env.kickOrder[1]["Leethunter"] = true;
aura_env.kickOrder[1]["Procz"] = true;
aura_env.kickOrder[2]["Tenkiei"] = true;
aura_env.kickOrder[2]["Skyline"] = true;
aura_env.kickOrder[3]["Koulikov"] = true;
aura_env.kickOrder[3]["Spiceice"] = true;
