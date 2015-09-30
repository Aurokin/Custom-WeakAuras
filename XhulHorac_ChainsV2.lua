-- Auro: Xhul'Horac - Chains of Fel Target
-- Version: 3.0.0
-- Load: Zone[Hellfire Citadel]

-- Trigger [COMBAT_LOG_EVENT_UNFILTERED, ENCOUNTER_START]
function(event, encounterID, msg, _, _, _, _, _, destGUID, destName, _, _, spellID, spellName)
    if (event == "ENCOUNTER_START" and aura_env.encounterIDs[encounterID] == true) then
        print("Auro: Xhul'Horac - Chians of Fel Target");
        aura_env.raidCount = GetNumGroupMembers() or 20;
    end
    if (msg == "SPELL_CAST_START" and aura_env.spellIDs[spellID]) then
      aura_env.currentTarget = nil;
      aura_env.currentSpellID = spellID;
      return true;
    end
end

-- Untrigger [Hide: 3s]

-- Custom Text [Every Frame]
function()
    if (aura_env.currentTarget == nil and aura_env.currentSpellID and aura_env.raidCount) then
        for i = 1, aura_env.raidCount do
            if (aura_env.spellIDs[aura_env.currentSpellID] == GetUnitName("raid" .. i .. "target")) then
                local targetID = UnitInRaid("raid" .. i .. "targettarget");
                if not targetID then return "?"; end
                local _, _, _, _, _, _, _, _, _, _, _, role = GetRaidRosterInfo(targetID);
                if (role ~= "TANK") then
                    aura_env.currentTarget = GetUnitName("raid" .. i .. "targettarget");
                    return aura_env.currentTarget or "?";
                else
                    return aura_env.currentTarget or "?";
                end
            end
        end
    end
    return aura_env.currentTarget or "?";
end

-- Hide
aura_env.currentTarget = nil;
aura_env.currentSpellID = nil;

-- Init
aura_env.raidCount = nil;
aura_env.encounterIDs = {};
aura_env.spellIDs = {};
aura_env.encounterIDs[1800] = true;
aura_env.spellIDs[186490] = "Vanguard Akkelion";
aura_env.spellIDs[189775] = "Xhul'horac";
aura_env.currentSpellID = nil;
aura_env.currentTarget = nil;
