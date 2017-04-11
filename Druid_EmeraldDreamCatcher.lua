-- Trigger [PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED, UNIT_AURA]
function(event, unitID)
    if ((event == "UNIT_AURA" and unitID == aura_env.unitID) or event ~= "UNIT_AURA") then 
        aura_env.point = aura_env.getPoint(aura_env.breakpoints, aura_env.getHaste())
    end
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
aura_env.point = 0
aura_env.unitID = "player"

aura_env.breakpoints = {83.3, 66.7, 56.7, 50, 40, 33.3, 30, 16.7, 0}
aura_env.breakpointInfo = {
    [0] = {
        ["icon"] = 535045,
        ["text"] = "No Emp",
        ["description"] = "Solar Wrath",
        ["custom"] = false
    },
    [16.7] = {
        ["icon"] = 135753,
        ["text"] = "Emp",
        ["description"] = "Half Moon or Lunar Strike w/ Starlord",
        ["custom"] = false
    },
    [30] = {
        ["icon"] = 535045,
        ["text"] = "2x",
        ["description"] = "2x Solar Wrath w/ Starlord",
        ["custom"] = false
    },
    [33.3] = {
        ["icon"] = 135753,
        ["text"] = "No Emp",
        ["description"] = "Lunar Strike No Empowerment",
        ["custom"] = false
    },
    [40] = {
        ["icon"] = 535045,
        ["text"] = "+1 GCD",
        ["description"] = "Solar Wrath w/ Starlord and 1 GCD",
        ["custom"] = false
    },
    [50] = {
        ["icon"] = 1392542,
        ["text"] = "FM",
        ["description"] = "Full Moon or 2 GCDs",
        ["custom"] = false
    },
    [56.7] = {
        ["icon"] = 135753,
        ["text"] = "LS / SW",
        ["description"] = "Lunar Strike w/ Starlord and Solar Wrath w/ Starlord or Solar Wrath w/ Starlord and Half Moon",
        ["custom"] = false
    },
    [66.7] = {
        ["icon"] = 135753,
        ["text"] = "+1 GCD",
        ["description"]="Lunar Strike w/ Starlord and 1 GCD or Half Moon and 1 GCD",
        ["custom"] = false
    },
    [83.3] = {
        ["icon"] = 135753,
        ["text"] = "2x",
        ["description"]="2x Lunar Strike w/ Starlord",
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