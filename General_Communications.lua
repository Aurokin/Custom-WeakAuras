-- Trigger [CHAT_MSG_ADDON]
function(event, prefix, message, channel, sender)
    if (aura_env.addonMsgs[prefix] ~= nil) then
        aura_env.sender = aura_env.trimName(sender);
        aura_env.msg, aura_env.color = strsplit("~", message, 2);
        aura_env.name = aura_env.getName(aura_env.sender, aura_env.color);
        return true; 
    end
end

-- Untrigger [Hide: 3s]

-- Name Info
function()
   return aura_env.name; 
end

-- Icon Info
function()
    if (aura_env.icons[aura_env.msg] ~= nil) then
        return aura_env.icons[aura_env.msg]
    end
    return 132156; 
end

-- Text [%n]

-- Init
aura_env.addonMsgs = {SkylineYes=true, AuroPM=true}
aura_env.icons = {Innervate=136048, Yes=456032, No=450905}
aura_env.msg = nil
aura_env.sender = nil
aura_env.color = nil
aura_env.name = nil

aura_env.trimName = function(name)
    return string.gsub(name, "%-[^|]+", "")
end

aura_env.register = function(msgs)
    for key, value in pairs(msgs) do
        RegisterAddonMessagePrefix(key)
    end
end

aura_env.getName = function(sender, color)
    return string.format("|c%s%s|r", color, sender)
end

aura_env.register(aura_env.addonMsgs)

-- Client Macro
/script AuroYourClass = RAID_CLASS_COLORS[select(2,UnitClass("player"))].colorStr
/script AuroYourMsg = ""
/script SendAddonMessage("AuroPM", AuroYourMsg .. "|" .. AuroYourClass, "RAID")