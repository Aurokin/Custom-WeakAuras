-- Auro: Gorefiend - Shared Fate HUD
-- Version: 3.1.2
-- Load: Zone[Hellfire Citadel]
-- Do Not Load: EncounterID
-- Requires: WeakAura Raid HUD

-- Enables HUD connecting lines between the rooted player with SharedFate and the other players
-- Currently enables even if you do not have SharedFate (I will probably change this to be option based)
-- Init on Encounter Start, and Cleanup on Encounter End

-- Trigger [COMBAT_LOG_EVENT_UNFILTERED, AUROBM_SHARED_FATE, ENCOUNTER_START, ENCOUNTER_END]
function(event, encounterID, msg, _, _, _, _, _, destGUID, destName, _, _, spellID, spellName)
    if (event == "ENCOUNTER_START" and encounterID == 1783) then
        -- Init
        print("Gorefiend HUD Loaded");

        -- Set playerOnly to false if you want to see every Shared Fate on the HUD, not just onces your attached too
        aura_env.core = WA_RaidHUD;
        aura_env.playerGUID = UnitGUID("player");
        aura_env.disks = {};
        aura_env.lines = {};
        aura_env.playerOnly = true;
        auroBM_sharedFateLastRoot = nil;
    elseif (event == "ENCOUNTER_END" and encounterID == 1783) then
        -- Unload
        print("Gorefiend HUD Hiding")
        for guid in pairs(aura_env.lines) do
            -- Clear Lines
            local line = aura_env.lines[guid];
            line:Free();
            aura_env.lines[guid] = nil;
        end

        for guid in pairs(aura_env.disks) do
            -- Clear Disks
            local disk = aura_env.disks[guid];
            disk:Free();
            aura_env.disks[guid] = nil;
        end

        auroBM_sharedFateLastRoot = nil;
        aura_env.core:Request2Show(aura_env.id, false);
        WeakAuras.ScanEvents("AUROBM_SHARED_FATE");
    end

    if not aura_env then return end
    if not aura_env.core then return end

    if (spellID == 179909 and msg == "SPELL_AURA_APPLIED") then    -- Rooted Player
        -- print("Chained - " .. destGUID);
        if (aura_env.playerOnly == false or destGUID == aura_env.playerGUID) then
          aura_env.core:Request2Show(aura_env.id, true, 6)
        end
        auroBM_sharedFateLastRoot = destGUID;
        local disk = aura_env.core:NewDisk(aura_env.core.db.scale * 5);
        -- 5 yard
        disk:Label(destName);
        disk:Color(0, .7, 0, .2);
        disk:Stick(destGUID);
        -- print("Saving Disk");
        aura_env.disks[destGUID] = disk;
        -- print("Should Be Returning True");
        return true;
    elseif (spellID == 179909 and msg == "SPELL_AURA_REMOVED") then
        -- print("Disk - " .. destGUID);
        local disk = aura_env.disks[destGUID];
        -- print("Should Remove Disk");
        if disk then
            -- Clear Disk
            disk:Free();
            aura_env.disks[destGUID] = nil;
            -- print("Disk is poof");
        end

        if not next(aura_env.disks) then
            for guid in pairs(aura_env.lines) do
                -- Clear Lines
                -- print("Killing Line - " .. guid);
                local line = aura_env.lines[guid];
                line:Free();
                aura_env.lines[guid] = nil;
            end
            -- Untrigger
            -- print("Untrigger");
            aura_env.core:Request2Show(aura_env.id, false);
            WeakAuras.ScanEvents("AUROBM_SHARED_FATE");
        end
    elseif (spellID == 179908 and msg == "SPELL_AURA_APPLIED") then  -- Links
        -- Delete lines existing from this target before
        -- If you have two shared fates going at the same time, its a wipe
        -- This helps ensure spare lines do not exist
        local deleteLine = aura_env.lines[destGUID];
        if deleteLine then
            deleteLine:Free();
            aura_env.lines[destGUID] = nil;
        end
        -- Draw Lines
        local line = aura_env.core:NewLine(0, 0, 0, 0, aura_env.core.db.scale, 0);
        -- print("Line - " .. destGUID);
        line:Stick(auroBM_sharedFateLastRoot, destGUID);
        line:Color(0.5,0,0.5,1);
        aura_env.lines[destGUID] = line;
        if (aura_env.playerOnly == true and destGUID == aura_env.playerGUID) then
          aura_env.core:Request2Show(aura_env.id, true, 6)
        end
    end
end

-- Untrigger
function(event)
    if (event == "AUROBM_SHARED_FATE") then
        -- print("EVENT FIRED ACTUALLY UNTRIGGER");
        return true;
    end
end
