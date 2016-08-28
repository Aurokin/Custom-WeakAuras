-- Auro: Archimonde - ChaosHUD
-- Version: 0.0.2
-- Load: Zone[Hellfire Citadel]
-- Do Not Load: EncounterID

-- Trigger [ENCOUNTER_START, ENCOUNTER_END, COMBAT_LOG_EVENT_UNFILTERED, AuroBM_ChaosHUD]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
  if (event == "ENCOUNTER_START" and aura_env.encounterIDs[encounterID] == true) then
    aura_env.wipeLines(aura_env.lines);
    print("Auro: Archimonde ChaosHUD - Loaded");
  elseif (event == "ENCOUNTER_END" and aura_env.encounterIDs[encounterID] == true) then
    aura_env.wipeLines(aura_env.lines);
    -- Turns off HUD
    aura_env.core:Request2Show(aura_env.id, false);
    WeakAuras.ScanEvents(aura_env.eventName);
  end
  if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
    if (msg == "SPELL_AURA_APPLIED" and spellID == aura_env.focusedSpellID) then
      -- Delete leftover lines
      local deleteLine = aura_env.lines[srcGUID];
      if deleteLine then
          deleteLine:Free();
          aura_env.lines[srcGUID] = nil;
      end
      -- Create Line
      local line = aura_env.core:NewLine(0, 0, 0, 0, aura_env.core.db.scale * 1.5, 1);
      -- Assumes srcGUID is focused and destGUID is wrought
      line:Stick(srcGUID, destGUID);
      -- Color / put in table
      line:Color(0,0.5,0.5, aura_env.lineOpacity);
      if (srcGUID == aura_env.playerGUID or destGUID == aura_env.playerGUID) then
        line:Color(0.5,0,0.5, aura_env.lineOpacity + 0.1);
      end
      aura_env.lines[destGUID] = line;
      aura_env.core:Request2Show(aura_env.id, true, aura_env.hudScale)
      return true;
    elseif ((msg == "SPELL_AURA_REMOVED" and spellID == aura_env.focusedSpellID) or (msg == "UNIT_DIED" and aura_env.lines[destGUID])) then
      local line = aura_env.lines[destGUID];
      if line then
        line:Free();
        aura_env.lines[destGUID] = nil;
      end

      if not next(aura_env.lines) then
        aura_env.core:Request2Show(aura_env.id, false);
        WeakAuras.ScanEvents(aura_env.eventName);
      end
    elseif (msg == "SPELL_CAST_START" and spellID == aura_env.ascensionSpellID) then
      -- P3 Disable HUD
      aura_env.wipeLines(aura_env.lines);
      -- Turns off HUD
      aura_env.core:Request2Show(aura_env.id, false);
      WeakAuras.ScanEvents(aura_env.eventName);
    end
  end
end

-- Untrigger
function(event)
  if (event == aura_env.eventName) then
    return true;
  end
end


-- Init
aura_env.core = WA_RaidHUD;
aura_env.hudScale = 6;
aura_env.lineOpacity = 0.5;
aura_env.eventName = "AuroBM_ChaosHUD";
aura_env.playerGUID = UnitGUID("player");
aura_env.focusedSpellID = 185014;
aura_env.ascensionSpellID = 190313;
aura_env.lines = {};
aura_env.encounterIDs = {};
aura_env.encounterIDs[1799] = true;
aura_env.wipeLines = function(table)
  -- Clears Lines
  for guid in pairs(table) do
      local line = table[guid];
      line:Free();
      table[guid] = nil;
  end
end
