 -- Trigger [COMBAT_LOG_EVENT_UNFILTERED, CHAT_MSG_ADDON, ENCOUNTER_START, ENCOUNTER_END]
function(event, ...)
  if (event == "CHAT_MSG_ADDON") then
    local prefix = select(1, ...);
    if (prefix == aura_env.addonMsg) then
      if (aura_env.left == nil) then aura_env.left = false; end
      aura_env.left = not aura_env.left;
    end
  elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
    local msg = select(2, ...);
    if (msg == "SPELL_CAST_SUCCESS" or msg == "SPELL_CAST_START") then
      local spellID = select(12, ...);
      if (spellID == aura_env.spellID) then
        if (msg == "SPELL_CAST_START") then
          aura_env.castEnd = GetTime() + 3;
        else
          if (aura_env.left == nil) then aura_env.left = false; end
          aura_env.left = not aura_env.left;
        end
      end
    end
  elseif (event == "ENCOUNTER_START") then
    aura_env.left = nil;
    return true;
  end
end

-- Untrigger
function(event, ...)
  if (event == "ENCOUNTER_END") then
    aura_env.left = nil;
    return true;
  end
end

-- Duration Info
function()
  -- return aura_env.durationInfo(aura_env.duration, aura_env.castEnd);
end

-- Custom Text [Every Frame]
function()
  return aura_env.print(aura_env.left);
end

-- Init
aura_env.left = nil;
aura_env.addonMsg = "AuroKrosus";
aura_env.castEnd = nil;
aura_env.duration = 3;
aura_env.spellID = 205370;
RegisterAddonMessagePrefix(aura_env.addonMsg);

aura_env.print = function(left)
    local safe = "RIGHT";
    if (left == nil) then return "?"; end
    if (left) then safe = "LEFT"; end
    return string.format("%s%s%s", "SAFE", "\n", safe);
end

aura_env.durationInfo = function(duration, castEnd)
  if (aura_env.castEnd == nil or aura_env.castEnd <= GetTime()) then
    return 1, 1, true;
  end
  return duration, castEnd + 0.1;
end

-- On Hide
aura_env.left = nil;