-- Trigger [PLAYER_REGEN_DISABLED,PLAYER_REGEN_ENABLED, ENCOUNTER_START, ENCOUNTER_END]
function(event, ...)
    if (event == "ENCOUNTER_START") then
        aura_env.bossFight = true;
        aura_env.startTime = GetTime();
        return true
    elseif (event == "PLAYER_REGEN_DISABLED" and aura_env.bossFight == false) then
        aura_env.startTime = GetTime();
        return true;
    end
    return false;
end

-- Untrigger
function(event, ...)
    if (event == "ENCOUNTER_END") then
        aura_env.startTime = nil;
        aura_env.bossFight = false;
        return true;
    elseif (event == "PLAYER_REGEN_ENABLED" and aura_env.bossFight == false) then
        aura_env.startTime = nil;
        return true;
    end
    return false;
end

-- Custom Text [Every Frame]
function()
    if (aura_env.startTime ~= nil) then
        local AuroBM_CurrentTime = GetTime();
        local AuroBM_HowLongInCombat = AuroBM_CurrentTime - aura_env.startTime;
        local AuroBM_HowLongInCombat_Minutes = floor(AuroBM_HowLongInCombat / 60);
        local AuroBM_HowLongInCombat_Seconds = AuroBM_HowLongInCombat - (AuroBM_HowLongInCombat_Minutes*60);
        return string.format("%2.2d:%2.2d", AuroBM_HowLongInCombat_Minutes, AuroBM_HowLongInCombat_Seconds);
    end
    return "?"
end

-- Init
aura_env.startTime = nil;
aura_env.bossFight = false;

-- On Hide
aura_env.startTime = nil;
aura_env.bossFight = false;












































