-- Auro: Icon Debug
-- Version 1.0.1

-- Trigger [Status -> Conditions -> Always active trigger]

-- Custom Text [Every Frame]
function()
    -- alt 124 for proper |
    local testString = "";
    local icon = "Interface\\Icons\\Spell_Nature_Brilliance";
    local name = "Thundertwerk";
    testString = string.format("|T%s:0|t - %s - Ready", icon, name);
    return testString;
end
