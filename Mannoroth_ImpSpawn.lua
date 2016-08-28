-- Auro: Mannoroth - Imp Spawn
-- Version: 1.0.0
-- Load: EncounterID[1795]

-- Currently unused as the imp blink timer servers as a spawn notice and a blink timer

-- Trigger [COMBAT_LOG_EVENT_UNFILTERED]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
    if (msg == "SPELL_CAST_START" and spellID == 181134 and aura_env.imps[srcGUID] ~= true) then
        aura_env.imps[srcGUID] = true;
        return true;
    elseif (msg == "UNIT_DIED" and destName == "Fel Imp") then
        aura_env.imps[destGUID] = nil;
    end
end

-- Untrigger
-- 3 seconds

-- Init
aura_env.imps = {};
for guid in pairs(aura_env.imps) do
    aura_env.imps[guid] = nil;
end

-- Text
-- "Imps Spawned!"
