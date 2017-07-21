-- Trigger [RAID_BOSS_WHISPER]
function(event, ...)
    local msg = select(1, ...);
    if (msg:find(aura_env.tooltipId)) then
        return true
    end
end

-- Untrigger [Hide 5s]

-- Init
aura_env.tooltipId = 238430