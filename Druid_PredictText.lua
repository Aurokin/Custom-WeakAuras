-- Trigger [CHAT_MSG_ADDON]
function(event, _, ap)
    aura_env.ap = tonumber(ap)
    return true
end

-- Untrigger
function()
    return false
end

-- Custom Text [Every Frame]
function()
    return string.format("%d", aura_env.ap)
end

-- Init
aura_env.event = "AuroAP"
aura_env.ap = 0