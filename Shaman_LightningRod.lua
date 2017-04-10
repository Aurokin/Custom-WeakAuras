-- Trigger [COMBAT_LOG_EVENT_UNFILTERED, AURO_LROD]
function(event, ...)
    if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
        local msg = select(2, ...)
        local sGUID = select(4, ...)
        local dGUID = select(8, ...)
        local spellID = select(12, ...)
        if (msg == "SPELL_AURA_APPLIED" and sGUID == aura_env.guid and spellID == aura_env.spellID) then
            aura_env.active = aura_env.active + 1
            aura_env.guids[dGUID] = GetTime()
            return true
        elseif (((msg == "SPELL_AURA_REMOVED" and sGUID == aura_env.guid and spellID == aura_env.spellID) or (msg == "UNIT_DIED")) and aura_env.guids[dGUID] ~= nil) then
            aura_env.active = aura_env.active - 1
            aura_env.guids[dGUID] = nil
        end
    end
end

-- Untrigger
function(event, ...)
    if (event == aura_env.event) then
        return true 
    end
end

-- Custom Text [Every Frame]
function()
    if (aura_env.active ~= nil) then
        if (aura_env.active <= 0) then
            WeakAuras.ScanEvents(aura_env.event)
        end
        return string.format("%d", aura_env.active)
    end 
end

-- Init
aura_env.event = "AURO_LROD"
aura_env.guid = UnitGUID("player")
aura_env.guids = {}
aura_env.spellID = 197209
aura_env.active = 0

-- Hide
aura_env.active = 0
aura_env.guids = {}