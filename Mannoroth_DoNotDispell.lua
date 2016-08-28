-- Auro: Mannoroth - DO NOT DISPELL
-- Version: 1.0.0
-- Load: Zone[Hellfire Citadel], EncounterID[1795], Dungeon Difficulty[Mythic]

-- Notifies when to Stampede based upon assinged mark number, change mark in init

-- Trigger [ENCOUNTER_START, COMBAT_LOG_EVENT_UNFILTERED, CHAT_MSG_MONSTER_YELL]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
  if (event == "ENCOUNTER_START" and aura_env.encounterIDs[encounterID] == true) then
      aura_env.phase2 = false;
      aura_env.phase2Time = nil;
      print("Auro Stamp Reminder - Loaded");
  end
  if (event == "COMBAT_LOG_EVENT_UNFILTERED" and aura_env) then
    if (msg == "SPELL_AURA_APPLIED" and spellID == aura_env.curseOfLegionSpellID and aura_env.phase2 == true and aura_env.phase2Time) then
      local currentTime = GetTime();
      if (currentTime > aura_env.phase2Time + aura_env.curseOffset) then
        aura_env.phase2 = false; -- So it only triggers on mark 2
        return true;
      end
    end
  elseif (event == "CHAT_MSG_MONSTER_YELL" and encounterID == aura_env.phase2Yell) then
    aura_env.phase2 = true;
    aura_env.phase2Time = GetTime();
  end
end

-- Untrigger [Hide 5s]

-- Init
aura_env.phase2Yell = "Fear not, Mannoroth. The fel gift empowers you... Make them suffer!";
aura_env.curseOffset = 90;
aura_env.phase2Time = nil;
aura_env.phase2 = false;
aura_env.curseOfLegionSpellID = 181275;
aura_env.encounterIDs = {};
aura_env.encounterIDs[1795] = true;
