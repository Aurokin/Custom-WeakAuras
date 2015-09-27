-- Auro Icon Debug
-- Good for testing out icon pathes

-- Custom Text [Every Frame]
function()
    -- alt 124 for proper |
    local testString = "";
    local icon = "Interface\\Icons\\Spell_Nature_Brilliance";
    local name = "Thundertwerk";
    testString = string.format("|T%s:0|t - %s - Ready", icon, name);

    return testString;
end
