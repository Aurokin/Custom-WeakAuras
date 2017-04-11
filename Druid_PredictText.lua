-- Trigger [AuroAP, PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED]
function(event, ap)
    if (event == aura_env.event) then
        aura_env.ap = ap
    elseif (event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED") then
        aura_env.inCombat = aura_env.getCombat("player")
    end
    return true
end

-- Untrigger
function()
    return false
end

-- Custom Text [Every Frame]
function()
    if (not aura_env.inCombat and aura_env.ap == 0) then return "" end
    return string.format("%d", aura_env.ap)
end

-- Init
aura_env.event = "AuroAP"
aura_env.ap = 0
aura_env.inCombat = false

RegisterAddonMessagePrefix(aura_env.event)

aura_env.getCombat = function(unit)
    return UnitAffectingCombat(unit)
end