-- Init
-- Solar: 164545 / Lunar: 164547
aura_env.buffID = 164545;
aura_env.trinketID = 215632;
aura_env.stacks = 0;
aura_env.left = true;
aura_env.event = "Auro_Stormsinger";
aura_env.playerGUID = UnitGUID("Player");
aura_env.getActive = function()
  local buffInfo = {UnitBuff("Player", GetSpellInfo(aura_env.buffID))};
  if (buffInfo ~= nil and next(buffInfo) ~= nil) then
    return true;
  end
  return false;
end
aura_env.getDuration = function()
  local buffInfo = {UnitBuff("Player", GetSpellInfo(aura_env.buffID))};
  if (buffInfo ~= nil and next(buffInfo) ~= nil) then
    return buffInfo[7] - GetTime();
  end
  return -1;
end
aura_env.getStacks = function()
  local trinketInfo = {UnitBuff("Player", GetSpellInfo(aura_env.trinketID))};
  if (trinketInfo ~= nil and next(trinketInfo) ~= nil) then
    return trinketInfo[4];
  end
  return 0;
end
aura_env.printInfoWithDuration = function(stacks, duration)
  if (aura_env.left == true) then
    return string.format("(+%d) %d", stacks, duration);
  else
    return string.format("%d (+%d)", duration, stacks);
  end
end
aura_env.printInfo = function(stacks)
  return string.format("+%d", stacks);
end

-- Custom Text [Every Frame]
function()
  if (WeakAuras.IsOptionsOpen()) then
    return aura_env.printInfo(10);
  end
  local active = aura_env.getActive();
  if (active == true and aura_env.stacks ~= nil) then
    return aura_env.printInfo(aura_env.stacks);
  else
    WeakAuras.ScanEvents(aura_env.event);
    return "";
  end
end

-- Trigger
function(event, ...)
  if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
    local msg = select(2, ...);
    local playerGUID = select(4, ...);
    if (msg == "SPELL_AURA_APPLIED" and playerGUID == aura_env.playerGUID) then
      local spellID = select(12, ...);
      if (spellID == aura_env.buffID) then
        aura_env.stacks = aura_env.getStacks();
        return true;
      end
    elseif (msg == "SPELL_AURA_REMOVED" and playerGUID == aura_env.playerGUID) then
      local spellID = select(12, ...);
      if (spellID == aura_env.buffID) then
        WeakAuras.ScanEvents(aura_env.event);
        return false;
      end
    elseif (msg == "UNIT_DIED" and playerGUID == aura_env.playerGUID) then
      local sourceGUID = select(4, ...);
      if (sourceGUID == aura_env.playerGUID) then
        WeakAuras.ScanEvents(aura_env.event);
        return false;
      end
    end
  end
end

-- Untrigger
function(event, ...)
  if (event == aura_env.event) then
    return true;
  end
end
