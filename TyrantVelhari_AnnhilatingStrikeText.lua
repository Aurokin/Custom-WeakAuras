-- Auro: Tyrant Velhari - Annhilating Strike Target
-- Version: 1.0.1
-- Load: EncounterID

-- Trigger [Event -> Combat Log -> Spell -> Cast Start -> Spell NAme: Annihilating Strike]

-- Untrigger [Hide: 3s (Check Cast Time)]

-- Init
aura_env.tyrantTarget = nil;
aura_env.raidCount = GetNumGroupMembers();

-- Hide
aura_env.tyrantTarget = nil;

-- Text [Every Frame]
function()
    if (aura_env.tyrantTarget == nil) then
        aura_env.raidCount = GetNumGroupMembers();
        for i = 1, aura_env.raidCount do
            if ("Tyrant Velhari" == GetUnitName("raid" .. i .. "target")) then
                local tyrantSource = UnitInRaid("raid" .. i .. "targettarget");
                if not tyrantSource then return "?"; end
                local _, _, _, _, _, _, _, _, _, _, _, tyrantRole = GetRaidRosterInfo(tyrantSource);
                if (tyrantRole ~= "TANK") then
                    aura_env.tyrantTarget = GetUnitName("raid" .. i .. "targettarget");
                    return aura_env.tyrantTarget or "?";
                else
                    return aura_env.tyrantTarget or "?";
                end
            end
        end
    end
    return aura_env.tyrantTarget or "?";
end
