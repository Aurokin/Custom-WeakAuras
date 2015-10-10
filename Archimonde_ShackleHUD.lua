-- Auro: Archimonde - ShackleHUD
-- Version: 0.0.2
-- Load: Zone[Hellfire Citadel]
-- Do Not Load: EncounterID

-- Trigger [ENCOUNTER_START, ENCOUNTER_END, COMBAT_LOG_EVENT_UNFILTERED, AuroBM_ShackleHUD]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
  if (event == "ENCOUNTER_START" and aura_env.encounterIDs[encounterID] == true) then
    aura_env.wipeDisks(aura_env.disks);
    print("Auro: Archimonde ShackleHUD - Loaded");
  elseif (event == "ENCOUNTER_END" and aura_env.encounterIDs[encounterID] == true) then
    aura_env.wipeDisks(aura_env.disks);
    -- Turns off HUD
    aura_env.core:Request2Show(aura_env.id, false);
    WeakAuras.ScanEvents(aura_env.eventName);
  end
  if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
    if (msg == "SPELL_AURA_APPLIED" and spellID == aura_env.shackleDebuffSpellID) then
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

      -- Create disk
      local disk = aura_env.core:NewDisk(aura_env.shackleRange * aura_env.core.db.scale);
      -- Assumes destGUID is focused and destGUID is wrought
      disk:Stick(pos);
      -- Color / put in table
      aura_env.disks[destGUID] = disk;

      return true;
    elseif (msg == "SPELL_AURA_REMOVED" and spellID == aura_env.shackleDebuffSpellID) then
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
    elseif (msg == "UNIT_DIED" and aura_env.disks[destGUID]) then
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
    elseif (msg == "SPELL_CAST_START" and spellID == aura_env.shackleCastSpellID) then
      -- If shackles from last shackle are still out the new shackles do not show
      -- I think I should hide here, and show on cast success
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

-- Custom Text [Every Frame]
function()
  if not aura_env.core then return "" end

  for guid in pairs (aura_env.disks) do
    -- Variables
    local shackleUnit = aura_env.core.roster[guid];
    local disk = aura_env.disks[guid];
    local shacklePos = disk.stickTo;
    local num = 0;
    local shackleX, shackleY, shackleMap = unpack(shacklePos);

    for raidUnit, raidPos in pairs(aura_env.core.positions) do
      -- if (shackleUnit ~= raidUnit and shackleUnit ~= "player") then
      -- Currently counting player twice, this solution does not work. Must investigate further.
      if (shackleUnit ~= raidUnit) then
        local raidX, raidY, raidMap = unpack(raidPos);
        if (shackleMap == raidMap) then
          local distance = aura_env.distance(shackleX, shackleY, raidX, raidY);
          if (distance <= aura_env.shackleRange) then
            num = num + 1;
          end
        end
      end
    end

    disk.timer:SetText(num);
    if (num > 0) then
      disk:Color(1, 0, 0, 0.6);
    else
      disk:Color(0, 0.5, 0, 0.6);
    end
  end

  if not next(aura_env.disks) then
    aura_env.core:Request2Show(aura_env.id, false);
    WeakAuras.ScanEvents(aura_env.eventName);
  end
  return "";
end


-- Init
aura_env.core = WA_RaidHUD;
aura_env.hudScale = 6;
aura_env.eventName = "AuroBM_ShackleHUD";
aura_env.playerGUID = UnitGUID("player");
aura_env.shackleCastSpellID = 184931;
aura_env.shackleDebuffSpellID = 184964;
aura_env.ascensionSpellID = 190313;
aura_env.shackleRange = 25;
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
aura_env.distance = function(x1, y1, x2, y2)
  local dx = x2 - x1;
  local dy = y2 - y1;
  local distance = (dx * dx) + (dy * dy);
  distance = math.sqrt(distance);
  return distance;
end
