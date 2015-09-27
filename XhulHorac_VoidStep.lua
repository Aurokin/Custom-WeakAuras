-- Author: Hunter Sadler (Auro)
-- Date: 09/02/2015
-- Version: 0.0.5
-- Name: XhulHorac_VoidStep

-- THIS DOES NOT WORK, ITS APPROACH IS NOT POSSIBLE ATM

-- Trigger [COMBAT_LOG_EVENT_UNFILTERED, AUROBM_VOIDSTEP, ENCOUNTER_START, ENCOUNTER_END, UNIT_DIED]

function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
    if (event == "ENCOUNTER_START" and encounterID == 1800) then
        -- Init
        aura_env.core = WA_RaidHUD;
        aura_env.playerGUID = UnitGUID("player");
        aura_env.disks = {};

        print("Voidstep HUD Loaded");
    elseif (event == "ENCOUNTER_END" and encounterID == 1800) then
        -- Unload
        for guid in pairs(aura_env.disks) do
            -- Clear Disks
            local disk = aura_env.disks[guid];
            disk:Free();
            aura_env.disks[guid] = nil;
        end

        aura_env.core:Request2Show(aura_env.id, false);
        print("Voidstep HUD Hiding");
        WeakAuras.ScanEvents("AUROBM_VOIDSTEP");
    end

    if not aura_env.core then return end

    if (msg == "SPELL_CAST_START" and spellID == 188939) then
        print("IM HERE");
        -- CAST_START does not give destName / destGUID
        -- Furthermore they do not voidstep who they are targetting
        -- They voidstep the closest person, and then the closest person to the circle after that
        -- If we had the Voids original location, or the location of the first void step we could get a working version of this
        -- Until then it is not possible
        print("Name - " .. destName);
        print("GUID - " .. destGUID);
        -- print("Void at - " .. destGUID .. " - " .. destName);
        -- Get dest position
        local unitID = aura_env.core.roster[destGUID];
        -- if not unitID then return end
        print(unitID);
        local pos = {unpack(aura_env.core.positions[unitID])};
        -- if not pos then return end
        print(pos);
        aura_env.core:Request2Show(aura_env.id, true, 6);
        local disk = aura_env.core:NewDisk(aura_env.core.db.scale * 6);
        -- 6 yard
        disk:Color(0, .7, 0, .2);
        disk:Stick(pos);
        print("Saving Disk");
        aura_env.disks[srcGUID] = disk;
        print("Should Be Returning True");
        return true;
    elseif (msg == "SPELL_CAST_SUCCESS" and spellID == 188939) then
        print("Disk - " .. srcGUID);
        local disk = aura_env.disks[srcGUID];
        -- print("Should Remove Disk");
        if disk then
            -- Clear Disk
            disk:Free();
            aura_env.disks[srcGUID] = nil;
            -- print("Disk is poof");
        end

        if not next(aura_env.disks) then
            -- Untrigger
            -- print("Untrigger");
            aura_env.core:Request2Show(aura_env.id, false);
            WeakAuras.ScanEvents("AUROBM_VOIDSTEP");
        end
    elseif (msg == "UNIT_DIED" and destName == "Unstable Voidfiend") then  -- Links
      print("Disk - " .. destGUID);
      local disk = aura_env.disks[destGUID];
      -- print("Should Remove Disk");
      if disk then
          -- Clear Disk
          disk:Free();
          aura_env.disks[destGUID] = nil;
          -- print("Disk is poof");
      end

      if not next(aura_env.disks) then
          -- Untrigger
          -- print("Untrigger");
          aura_env.core:Request2Show(aura_env.id, false);
          WeakAuras.ScanEvents("AUROBM_VOIDSTEP");
      end
    end
end

-- Untrigger

function(event)
    if (event == "AUROBM_VOIDSTEP") then
        -- print("EVENT FIRED ACTUALLY UNTRIGGER");
        return true;
    end
end

-- WeakAura String
