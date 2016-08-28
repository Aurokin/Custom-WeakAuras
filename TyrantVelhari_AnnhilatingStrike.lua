-- Auro: Tyrant Velhari - Annhilating Strike HUD
-- Version: 1.1.0
-- Load: Zone[Hellfire Citadel]
-- Do Not Load: EncounterID
-- Requires: WeakAura Raid HUD

-- Enables HUD connecting lines between the main tank and player targetted with Annhilating Strike
-- Init on Encounter Start, and Cleanup on Encounter End

-- Trigger [COMBAT_LOG_EVENT_UNFILTERED, AUROBM_VELHARISTRIKE, ENCOUNTER_START, ENCOUNTER_END]
function(event, encounterID, msg, _, _, _, _, _, destGUID, destName, _, _, spellID, spellName)
    if (event == "ENCOUNTER_START" and encounterID == 1784) then
        -- Init
        print("Tyrant Velhari Annhilating Strike HUD Loaded");
        aura_env.core = WA_RaidHUD;
        aura_env.playerGUID = UnitGUID("player");
        aura_env.lines = {};
        aura_env.playerOnly = false;
        aura_env.tyrantTargetRole = nil;
        aura_env.tyrantTank = nil;
        aura_env.tyrantStrike = nil;
        aura_env.lineDrawn = false;
        aura_env.raidCount = GetNumGroupMembers() or 20;
    elseif (event == "ENCOUNTER_END" and encounterID == 1784) then
        -- Unload
        print("Tyrant Velhari Annhilating Strike HUD Hiding")
        for guid in pairs(aura_env.lines) do
            -- Clear Lines
            local line = aura_env.lines[guid];
            line:Free();
            aura_env.lines[guid] = nil;
        end
        aura_env.playerOnly = nil;
        aura_env.tyrantTargetRole = nil;
        aura_env.playerGUID = nil;
        aura_env.tyrantTank = nil;
        aura_env.tyrantStrike = nil;
        aura_env.lineDrawn = nil;

        aura_env.core:Request2Show(aura_env.id, false);
        WeakAuras.ScanEvents("AUROBM_VELHARISTRIKE");
    end

    if not aura_env then return end
    if not aura_env.core then return end

    if (spellName == "Annihilating Strike" and msg == "SPELL_CAST_START") then
        if (aura_env.playerOnly == false) then
            aura_env.core:Request2Show(aura_env.id, true, 6);
        end
        return true;
    elseif (spellName == "Annihilating Strike" and msg == "SPELL_CAST_SUCCESS") then
        for guid in pairs(aura_env.lines) do
            -- Clear Disks
            local line = aura_env.lines[guid];
            line:Free();
            aura_env.lines[guid] = nil;
        end

        if not next(aura_env.lines) then
            -- Untrigger
            -- print("Untrigger");
            aura_env.tyrantTank = nil;
            aura_env.tyrantStrike = nil;
            aura_env.tyrantTargetRole = nil;
            aura_env.lineDrawn = false;
            aura_env.core:Request2Show(aura_env.id, false);
            WeakAuras.ScanEvents("AUROBM_VELHARISTRIKE");
        end
    end
end

-- Text [Every Frame]
function()
    aura_env.raidCount = aura_env.raidCount or 20;
    if (aura_env.tyrantStrike == nil) then
        for i = 1, aura_env.raidCount do
            if ("Tyrant Velhari" == GetUnitName("raid" .. i .. "target")) then
                local tyrantSource = UnitInRaid("raid" .. i .. "targettarget");
                if not tyrantSource then return string.format("%s", ""); end
                local _, _, _, _, _, _, _, _, _, _, _, role = GetRaidRosterInfo(tyrantSource);
                -- print("ROLE - " .. aura_env.tyrantTargetRole);
                aura_env.tyrantTargetRole = role;
                if (aura_env.tyrantTargetRole == "TANK") then
                    aura_env.tyrantTank = UnitGUID("raid" .. i .. "targettarget");
                    -- print("TANK" .. aura_env.tyrantTank);
                    -- print("Tank - " .. aura_env.tyrantTank);
                else
                    aura_env.tyrantStrike = UnitGUID("raid" .. i .. "targettarget");
                    -- print("TARGET" .. aura_env.tyrantStrike);
                    -- print("Source - " .. aura_env.tyrantStrike);
                end
                return string.format("%s", " ");
            end
        end
    elseif (aura_env.lineDrawn == false and aura_env.tyrantStrike ~= nil) then
        if (aura_env.tyrantTank == nil) then
            -- print("finding new tank");
            for i = 1, aura_env.raidCount do
                local _, _, _, _, _, _, _, _, _, _, _, role = GetRaidRosterInfo(i);
                aura_env.tyrantTargetRole = role;
                if (aura_env.tyrantTargetRole == "TANK") then
                    aura_env.tyrantTank = UnitGUID("raid" .. i);
                    -- print("found a tank");
                end
            end
        end
        -- Delete lines existing from this target before
        -- If you have two shared fates going at the same time, its a wipe
        -- This helps ensure spare lines do not exist
        local deleteLine = aura_env.lines[destGUID];
        if deleteLine then
            deleteLine:Free();
            aura_env.lines[destGUID] = nil;
        end
        -- Draw Lines
        local line = aura_env.core:NewLine(0, 0, 0, 0, aura_env.core.db.scale * 2, 1);
        line:Color(1,0,0,0.5);
        line:Stick(aura_env.tyrantTank, aura_env.tyrantStrike);
        aura_env.lines[aura_env.tyrantStrike] = line;
        aura_env.lineDrawn = true;
    end
    return string.format("%s", " ");
end

-- Untrigger
function(event)
    if (event == "AUROBM_VELHARISTRIKE") then
        -- print("EVENT FIRED ACTUALLY UNTRIGGER");
        return true;
    end
end
