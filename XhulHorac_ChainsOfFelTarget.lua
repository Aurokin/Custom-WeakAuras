-- Author: Hunter Sadler (Auro)
-- Date: 08/29/2015
-- Version: 2.0
-- Name: XhulHorac_ChainsOfFelTarget

-- This WeakAura tracks the current ChainsOfFel Target while its being casted.
-- It finds someone in the raid who is targetting the caster, and reports back the casters target
-- Since the WeakAura reacts immediatley it often reports the tank, however the tank cannot receive ChainsOfFel
-- It continues to query for the casters target until it finds someone who is not a Tank (Actual Target)
-- If however the raid member being used to query the casters target swaps to a different target in the time frame this may report bad information
-- Generally this reports within 500ms, most often way sooner, the chances of this happening are very slim, but none the less could occur.

-- Trigger (Event [COMBAT_LOG_EVENT_UNFILTERED])
function(_, _, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
    if (msg == "SPELL_CAST_START" and spellName == "Chains of Fel") then
        -- Reset Variables
        --   This would be better in init, but for some reason init is looping on pull
        auroBM_ChainsRaidCount = GetNumGroupMembers();
        auroBM_ChainsTanks = {};
        auroBM_ChainsOfFelTarget = nil;
        auroBM_ChainsTargetIndex = nil;
        auroBM_ChainsInfoSourceIndex = nil;
        auroBM_ChainsTargetRole = nil;
        -- Reset Finished
        for i = 1, auroBM_ChainsRaidCount do
            -- Find someone targeting Vanguard
            if (GetUnitName("raid" .. i .. "target", false) == "Vanguard Akkelion") then
                -- Return Index
                auroBM_ChainsTargetIndex = i;
                return true
            end
        end
        print("BUTWHY");
        return true;

    elseif (msg == "SPELL_CAST_START" and spellName == "Empowered Chains of Fel") then
        -- Reset
        auroBM_ChainsRaidCount = GetNumGroupMembers();
        auroBM_ChainsTanks = {};
        auroBM_ChainsOfFelTarget = nil;
        auroBM_ChainsTargetIndex = nil;
        auroBM_ChainsInfoSourceIndex = nil;
        auroBM_ChainsTargetRole = nil;
        -- Reset End
        for i = 1, auroBM_ChainsRaidCount do
            -- Find someone targeting Xhul
            if (GetUnitName("raid" .. i .. "target", false) == "Xhul'horac") then
                auroBM_ChainsTargetIndex = i;
                return true
            end
        end
        print("BUTWHYY");
        return true;
    end
end

-- Untrigger
-- Hide in 3 seconds

-- Custom Text [Every Frame]
function()
    -- Check if target has already been set
    if (auroBM_ChainsOfFelTarget == nil and auroBM_ChainsTargetIndex ~= nil) then
        -- Verify it is not going to a tank (they cannot get fel chains)
        auroBM_ChainsInfoSourceIndex = UnitInRaid("raid" .. auroBM_ChainsTargetIndex .. "targettarget");
        _, _, _, _, _, _, _, _, _, _, _,auroBM_ChainsTargetRole = GetRaidRosterInfo(auroBM_ChainsInfoSourceIndex);
        -- print(auroBM_ChainsTargetRole);
        if (auroBM_ChainsTargetRole ~= "TANK") then
            -- Set target, as long as its not a tank
            auroBM_ChainsOfFelTarget = GetUnitName("raid" .. auroBM_ChainsTargetIndex .. "targettarget", false);
        end
        -- print(auroBM_ChainsOfFelTarget);
    end
    -- Print Target
    local auroBM_ChainsPrintMe = auroBM_ChainsOfFelTarget or "?";
    return string.format("%s", auroBM_ChainsPrintMe);
end

-- init
-- CURRENTLY unused
-- I believe its looping because lag is created and the print at the top is looped
-- Clear variables
print("Chains Of Fel Addon Started");

auroBM_ChainsRaidCount = GetNumGroupMembers();
auroBM_ChainsTanks = {};
auroBM_ChainsOfFelTarget = nil;
auroBM_ChainsTargetIndex = nil;
auroBM_ChainsInfoSourceIndex = nil;
auroBM_ChainsTargetRole = nil;

for k,v in ipairs(auroBM_ChainsTanks) do
    auroBM_ChainsTanks[k] = nil;
end

-- Fill tanks into table
for i = 1, AuroBM_ChainsRaidCount do
    local name, _, _, _, _, _, _, _, _, _, z, role = GetRaidRosterInfo(i);
    print(name .. ' - ' .. role .. ' - ' .. z);
    if (role == "TANK") then
        table.insert(AuroBM_ChainsTanks, name);
        print(name);
    end
end

-- Hide
-- CURRENTLY unused
-- If I could get init to work, then I could reset on hide here, and remove redudent reset from Trigger
-- Clear variables
auroBM_ChainsRaidCount = GetNumGroupMembers();
auroBM_ChainsOfFelTarget = nil;
auroBM_ChainsTargetIndex = nil;
auroBM_ChainsInfoSourceIndex = nil;
auroBM_ChainsTargetRole = nil;

print("All Clear!");
