-- Trigger [ENCOUNTER_START, ENCOUNTER_END, COMBAT_LOG_EVENT_UNFILTERED]
function(event, ...)
  if (event == "ENCOUNTER_START" or event == "ENCOUNTER_END") then
    local id = select(1, ...);
    if (id == aura_env.eID or aura_env.eID == nil) then
      aura_env.strikeCounter = 0;
    end
  elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
    local msg = select(2, ...);
    local spellName = select(13, ...);
    if (msg == "SPELL_CAST_START" and spellName == aura_env.spellName) then
      local now = GetTime();
      if (aura_env.lastTick == nil or (aura_env.lastTick + aura_env.safety) < now) then
        aura_env.lastTick = now;
        aura_env.strikeCounter = aura_env.strikeCounter + 1;
      end
      return true;
    end
  end
end

-- Untrigger [Hide 8s]

-- Custom Text [Every Frame]
function()
  if (aura_env.strikeCounter ~= nil) then
    return string.format("%s%d%s", "Tentacle Strike Set *", aura_env.strikeCounter, "*");
  end
  return "?";
end

-- Init
aura_env.eID = 2008;
aura_env.spellName = "Tentacle Strike";
aura_env.safety = 15;
aura_env.lastTick = nil;
aura_env.strikeCounter = 0;
