-- Auro: Xhul'Horac - Void Spawn warning
-- Version: 1.0.1
-- Load: Zone[Hellfire Citadel], EncounterID[?]

-- Trigger[COMBAT_LOG_EVENT_UNFILTERED]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
    if (msg == "SPELL_CAST_START" and spellID == 188939 and aura_env.voids[srcGUID] ~= true) then
        -- print(srcGUID);
        aura_env.voids[srcGUID] = true;
        return true;
    elseif (msg == "UNIT_DIED" and destName == "Unstable Voidfiend") then
        -- print(destName .. " - " .. destGUID);
        aura_env.voids[destGUID] = nil;
    end
end

-- Untrigger [Hide: 2s]

-- Text [VOIDS SPAWN!]

-- Init
aura_env.voids = {};
for guid in pairs(aura_env.voids) do
    aura_env.voids[guid] = nil;
end
