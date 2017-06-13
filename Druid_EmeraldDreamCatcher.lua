-- Trigger [COMBAT_LOG_EVENT_UNFILTERED]
function()
    aura_env.point = aura_env.getPoint(aura_env.breakpoints, aura_env.getHaste())
    return true
end

-- Untrigger
function()
    return false
end

-- Text [Every Frame]
function()
    return string.format("%s\n%1.f%s", aura_env.getText(aura_env.breakpointInfo, aura_env.point), aura_env.getHaste(), "%%")
end

-- Icon
function()
    return aura_env.getIcon(aura_env.breakpointInfo, aura_env.point)
end

-- On Show / On Hide
aura_env.point = 0

-- Init

-- https://docs.google.com/spreadsheets/d/1dsmvRHlLXEmVAOV8govKKIhuL1GD3aSAWU9PqfWT_9E/preview
-- Breakpoints Assume 1 Empowerment Of Each Kind
-- 2x SW (1 Emp) = Full Moon
-- New Moon + Half Moon = Full Moon
-- Half Moon = Emp Lunar Strike
-- GCD Slightly Longer Than SW
-- SW Slightly Longer Than NM

aura_env.point = 0
aura_env.breakpoints = {80, 70, 54, 50, 44, 40, 34, 30, 24, 20, 14, 0}
aura_env.breakpointInfo = {
    [0] = {
        ["icon"] = 535045,
        ["text"] = "2x",
        ["description"] = "2x Solar Wrath",
        ["custom"] = false
    },
    [14] = {
        ["icon"] = 1392542,
        ["text"] = "+SW",
        ["description"] = "Full Moon + Solar Wrath",
        ["custom"] = false
    },
    [20] = {
        ["icon"] = 135753,
        ["text"] = "+NM + GCD",
        ["description"] = "Lunar Strike + New Moon + GCD",
        ["custom"] = false
    },
    [24] = {
        ["icon"] = 535045,
        ["text"] = "x2 + LS",
        ["description"] = "2x Solar Wrath + Lunar Strike or GCD + Solar Wrath + Lunar Strike",
        ["custom"] = false
    },
    [30] = {
        ["icon"] = 1392542,
        ["text"] = "+LS",
        ["description"] = "Full Moon (New Moon / Half Moon) + Lunar Strike",
        ["custom"] = false
    },
    [34] = {
        -- Add Half Moon Icon
        ["icon"] = 135753,
        ["text"] = "+LS + SW",
        ["description"] = "Half Moon + Lunar Strike + Solar Wrath",
        ["custom"] = false
    },
    [40] = {
        -- Add Half Moon Icon
        ["icon"] = 135753,
        ["text"] = "+LS + GCD",
        ["description"] = "Half Moon + Lunar Strike + GCD",
        ["custom"] = false
    },
    [44] = {
        ["icon"] = 135753,
        ["text"] = "2x + SW",
        ["description"] = "2x Lunar Strike + Solar Wrath",
        ["custom"] = false
    },
    [50] = {
        ["icon"] = 135753,
        ["text"] = "2x + GCD",
        ["description"] = "2x Lunar Strike + GCD",
        ["custom"] = false
    },
    [54] = {
        ["icon"] = 1392542,
        ["text"] = "+SW + LS",
        ["description"] = "Full Moon + Lunar Strike + Solar Wrath",
        ["custom"] = false
    },
    [70] = {
        ["icon"] = 135753,
        ["text"] = "3x",
        ["description"]="3x Lunar Strike",
        ["custom"] = false
    },
    [80] = {
        ["icon"] = 135753,
        ["text"] = "2x + FM",
        ["description"]="FM + 2x Lunar Strike",
        ["custom"] = false
    }
}

aura_env.icons = {
    ["Full Moon"] = 1392542,
    -- ["Half Moon"],
    ["Lunar Strike"] = 135753,
    ["Solar Wrath"] = 535045

}

aura_env.getPoint = function(breakpoints, haste)
    for i, req in ipairs(breakpoints) do
        if (haste > req) then return req end
    end
    return 0
end

aura_env.getText = function(breakpoints, point)
    return breakpoints[point]["text"]
end

aura_env.getIcon = function(breakpoints, point)
    return breakpoints[point]["icon"]
end

aura_env.getHaste = function()
    return UnitSpellHaste("player")
end