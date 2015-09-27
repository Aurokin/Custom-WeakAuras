-- Auro: Debuff Debug
-- Version 1.0.0

-- Trigger [Aura -> Debuff -> DebuffName]

-- Custom Text[Every Frame]
-- Set UnitDebuff("player", "DebuffName");
function()
    local name,rank,icon,count,debuffType,duration,expirationTime,unitCaster,isStealable,shouldConsolidate,spellId,canApplyAura,isBossDebuff,value1,value2,value3 = UnitDebuff("player", "Frost Shock");
    local debuffTestString = "";
    debuffTestString = debuffTestString .. "Name : " .. tostring(name) .. "\n";
    debuffTestString = debuffTestString .. "rank : " .. tostring(rank) .. "\n";
    debuffTestString = debuffTestString .. "icon : " .. tostring(icon) .. "\n";
    debuffTestString = debuffTestString .. "count : " .. tostring(count) .. "\n";
    debuffTestString = debuffTestString .. "debuffType : " .. tostring(debuffType) .. "\n";
    debuffTestString = debuffTestString .. "duration : " .. tostring(duration) .. "\n";
    debuffTestString = debuffTestString .. "expirationTime : " .. tostring(expirationTime) .. "\n";
    debuffTestString = debuffTestString .. "unitCaster : " .. tostring(unitCaster) .. "\n";
    debuffTestString = debuffTestString .. "isStealable : " .. tostring(isStealable) .. "\n";
    debuffTestString = debuffTestString .. "shouldConsolidate : " .. tostring(shouldConsolidate) .. "\n";
    debuffTestString = debuffTestString .. "spellId : " .. tostring(spellId) .. "\n";
    debuffTestString = debuffTestString .. "canApplyAura : " .. tostring(canApplyAura) .. "\n";
    debuffTestString = debuffTestString .. "isBossDebuff : " .. tostring(isBossDebuff) .. "\n";
    debuffTestString = debuffTestString .. "value1 : " .. tostring(value1)  .. "\n";
    debuffTestString = debuffTestString .. "value2 : " .. tostring(value2) .. "\n";
    debuffTestString = debuffTestString .. "value3 : " .. tostring(value3) .. "\n";
    return debuffTestString;

end
