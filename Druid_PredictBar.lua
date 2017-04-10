-- Trigger [Every Frame]
function()
    aura_env.ap = math.min(aura_env.getCurrentAP() + aura_env.getAP(aura_env.castToAP, aura_env.currentCast(), aura_env.hasBota(), aura_env.hasCd()), 100)
    aura_env.lastAP = aura_env.cacheAP(aura_env.lastAP, aura_env.ap, aura_env.event)
    return true
end

-- Untrigger
function()
    return false
end

-- Init
aura_env.ap = 0
aura_env.bota = false
aura_env.cd = false
aura_env.event = "AuroAP"
aura_env.lastAP = 0

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
        SendAddonMessage(event, currentAP, "WHISPER", UnitName("player"))
    end
    return currentAP
end

aura_env.currentCast = function()
    return select(10, UnitCastingInfo("player"))
end

aura_env.getAP = function(data, cast, bota, cd)
    if (data[cast] == nil) then return 0 end
    local ap = data[cast]["ap"]
    if (multi and bota) then ap = ap * 1.25 end
    if (multi and cd) then ap = ap * 1.5 end
    return ap
end

aura_env.getCurrentAP = function()
    return UnitPower("player")
end

aura_env.hasBota = function()
    return UnitBuff("player", "Blessing of Elune") ~= nil
end

aura_env.hasCd = function()
    return UnitBuff("player", "Incarnation: Chosen of Elune") or UnitBuff("player", "Celestial Alignment")
end