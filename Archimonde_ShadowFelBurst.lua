-- Auro: Archimonde - FelBurstHUD
-- Version: 0.0.5
-- Load: Zone[Hellfire Citadel]
-- Do Not Load: EncounterID

-- Trigger [ENCOUNTER_START, ENCOUNTER_END, COMBAT_LOG_EVENT_UNFILTERED, AuroBM_FelBurstHUD]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
  if (event == "ENCOUNTER_START" and aura_env.encounterIDs[encounterID] == true) then
    aura_env.wipeDisks(aura_env.disks);
    print("Auro: Archimonde FelBurstHUD - Loaded");
  elseif (event == "ENCOUNTER_END" and aura_env.encounterIDs[encounterID] == true) then
    aura_env.wipeDisks(aura_env.disks);
    -- Turns off HUD
    aura_env.core:Request2Show(aura_env.id, false);
    WeakAuras.ScanEvents(aura_env.eventName);
  end
  if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
    if (msg == "SPELL_AURA_APPLIED" and spellID == aura_env.felBurstDebuffSpellID) then
      -- Delete leftover disks
      local deleteDisk = aura_env.disks[destGUID];
      if deleteDisk then
          deleteDisk:Free();
          aura_env.disks[destGUID] = nil;
      end

      -- Find Unit
      local unit = aura_env.core.roster[destGUID];
      if not unit then return end
      local pos = {unpack(aura_env.core.positions[unit])};
      if not pos then return end
      local name = GetUnitName(unit, false);
      if not name then return end;
      local _, class = UnitClass(unit);
      if not class then return end;

      -- Create disk
      local disk = aura_env.core:NewDisk(aura_env.felBurstRange * aura_env.core.db.scale);

      -- Assumes destGUID is focused and destGUID is wrought
      disk:Stick(pos);
      disk:Label(name);
      disk:Color(RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b, 0.6);
      -- Color / put in table
      aura_env.disks[destGUID] = disk;

      return true;
    elseif ((msg == "SPELL_AURA_REMOVED" and spellID == aura_env.felBurstDebuffSpellID) or (msg == "UNIT_DIED" and aura_env.disks[destGUID])) then
      -- Clear Disk
      local disk = aura_env.disks[destGUID];
      if disk then
        disk:Free();
        aura_env.disks[destGUID] = nil;
      end

      if not next(aura_env.disks) then
        aura_env.core:Request2Show(aura_env.id, false);
        WeakAuras.ScanEvents(aura_env.eventName);
      end
    elseif (msg == "SPELL_CAST_START" and spellID == aura_env.ascensionSpellID) then
      -- P3 Disable HUD
      aura_env.wipeDisks(aura_env.disks);
      -- Turns off HUD
      aura_env.core:Request2Show(aura_env.id, false);
      WeakAuras.ScanEvents(aura_env.eventName);
    elseif (msg == "SPELL_CAST_SUCCESS" and spellID == aura_env.felBurstCastSpellID) then
      aura_env.wipeDisks(aura_env.disks);
      aura_env.core:Request2Show(aura_env.id, true, aura_env.hudScale)
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
aura_env.eventName = "AuroBM_FelBurstHUD";
aura_env.playerGUID = UnitGUID("player");
aura_env.felBurstCastSpellID = 183817;
aura_env.felBurstDebuffSpellID = 183634;
aura_env.ascensionSpellID = 190313;
aura_env.felBurstRange = 8;
aura_env.disks = {};
aura_env.encounterIDs = {};
aura_env.encounterIDs[1799] = true;
aura_env.wipeDisks = function(table)
  -- Clears disks
  for guid in pairs(table) do
      local disk = table[guid];
      disk:Free();
      table[guid] = nil;
  end
end
