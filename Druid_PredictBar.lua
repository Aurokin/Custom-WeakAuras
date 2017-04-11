-- Trigger [CURRENT_SPELL_CAST_CHANGED, PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED, UNIT_AURA, UNIT_POWER]
function(event, unitID, pType)
    if (event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED") then
        aura_env.inCombat = aura_env.getCombat(aura_env.unitID)
    elseif (event == "CURRENT_SPELL_CAST_CHANGED"
        or (event == "UNIT_AURA" and unitID == aura_env.unitID)
        or (event == "UNIT_POWER" and unitID == aura_env.unitID and pType == aura_env.pType)) then

        if (event == "UNIT_AURA" or aura_env.bota == nil or aura_env.cd == nil) then
            aura_env.bota = aura_env.hasBota()
            aura_env.cd = aura_env.hasCd()
        end

        aura_env.ap = math.min(aura_env.getCurrentAP() + aura_env.getAP(aura_env.castToAP, aura_env.currentCast(), aura_env.bota, aura_env.cd), 100)
        aura_env.lastAP = aura_env.cacheAP(aura_env.lastAP, aura_env.ap, aura_env.event)

    end
    return aura_env.inCombat
end

-- Untrigger
function()
    return not aura_env.inCombat
end

-- Duration Info
function()
    return aura_env.ap, 100, true 
end

-- Init
aura_env.ap = 0
aura_env.bota = nil
aura_env.cd = nil
aura_env.event = "AuroAP"
aura_env.inCombat = false
aura_env.lastAP = 0
aura_env.pType = "LUNAR_POWER"
aura_env.unitID = "player"

RegisterAddonMessagePrefix(aura_env.event)

aura_env.castToAP = {
    [190984] = {
        ["ap"] = 8,
        ["multi"] = true,
        ["name"] = "Solar Wrath",
    },
    [194153] = {
        ["ap"] = 12,
        ["multi"] = true,
        ["name"] = "Lunar Strike"
    },
    [202767] = {
        ["ap"] = 10,
        ["multi"] = false,
        ["name"] = "New Moon"
    },
    [202768] = {
        ["ap"] = 20,
        ["multi"] = false,
        ["name"] = "Half Moon"
    },
    [202771] = {
        ["ap"] = 40,
        ["multi"] = false,
        ["name"] = "Full Moon"
    }
}

aura_env.cacheAP = function(lastAP, currentAP, event)
    if (lastAP ~= currentAP) then
        WeakAuras.ScanEvents(event, currentAP)
    end
    return currentAP
end

aura_env.currentCast = function()
    return select(10, UnitCastingInfo("player"))
end

aura_env.getAP = function(data, cast, bota, cd)
    if (data[cast] == nil) then return 0 end
    local ap = data[cast]["ap"]
    local multi = data[cast]["multi"]
    if (multi and bota) then ap = ap * 1.25 end
    if (multi and cd) then ap = ap * 1.5 end
    return ap
end

aura_env.getCombat = function(unit)
    return UnitAffectingCombat(unit)
end

aura_env.getCurrentAP = function()
    return UnitPower("player", 8)
end

aura_env.hasBota = function()
    return UnitBuff("player", "Blessing of Elune") ~= nil
end

aura_env.hasCd = function()
    return UnitBuff("player", "Incarnation: Chosen of Elune") ~= nil or UnitBuff("player", "Celestial Alignment") ~= nil
end