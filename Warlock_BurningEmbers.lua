-- Auro: Burning Embers
-- Version: 1.0.0

-- Trigger [COMBAT_LOG_EVENT_UNFILTERED]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
  return true;
end

-- Untrigger
function()
  return false;
end

-- Duration
function()
  local embers = UnitPower("player", SPELL_POWER_BURNING_EMBERS, true);
  if not embers then
    return 0, 1, true;
  end
  if (embers >= aura_env.max) then
    return 1, 1, true;
  elseif (embers < aura_env.min) then
    return 0, 1, true;
  else
    embers = embers - (aura_env.min - 1);
    local max = aura_env.max - (aura_env.min - 1);
    return embers, max, true;
  end
  return 0, 1, true;
end

-- Init
aura_env.min = 1;
aura_env.max = 10;
