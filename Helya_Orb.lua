-- Trigger
function(event, ...)
  if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
    local msg = select(2, ...);
    local guid = select(8, ...);
    local spellID = select(12, ...);
    if (msg == "SPELL_AURA_APPLIED" and spellID == aura_env.spellID) then
      -- You have the debuff, timing corrected here
      local now = GetTime();
      if (guid == aura_env.guid) then
        aura_env.expire = now + aura_env.length;
        aura_env.hiddenExpire = now + aura_env.hiddenLength;
        aura_env.hidden = false;
        aura_env.setColor(aura_env.runColor.r, aura_env.runColor.g, aura_env.runColor.b, aura_env.runColor.a);
        return true;
      end
    elseif (msg == "UNIT_DIED" and guid == aura_env.guid) then
      WeakAuras.ScanEvents(aura_env.event);
      return false;
    elseif (msg == "SPELL_CAST_SUCCESS" and spellID == aura_env.castID) then
      -- 0.3ms from now you will be safe if you don't get a whisper
      local now = GetTime();
      if (aura_env.hiddenExpire == nil or aura_env.hiddenExpire < now) then
        aura_env.expire = now - 1;
        aura_env.hiddenExpire = now + aura_env.safeLength;
        aura_env.hidden = true;
        aura_env.setColor(aura_env.safeColor.r, aura_env.safeColor.g, aura_env.safeColor.b, aura_env.safeColor.a);
        -- Manually type delayEvent here, C_Timer.After :(
        C_Timer.After(0.3, function() WeakAuras.ScanEvents("HelyaOrbCorruptionDelay"); end);
      end
    end
  elseif (event == "RAID_BOSS_WHISPER") then
    -- Boss whispers you if you are going to get the orb, before you get the debuff
    local now = GetTime();
    local msg = select(1, ...);
    if (msg:find(aura_env.tooltipID)) then
      aura_env.expire = now + aura_env.length;
      aura_env.hiddenExpire = now + aura_env.hiddenLength;
      aura_env.hidden = false;
      aura_env.setColor(aura_env.runColor.r, aura_env.runColor.g, aura_env.runColor.b, aura_env.runColor.a);
      return true;
    end
  elseif (event == aura_env.delayEvent) then
    return true;
  end
end

-- Untrigger
function(event, ...)
  if (event == aura_env.event) then
    aura_env.hidden = false;
    aura_env.expire = nil;
    aura_env.hiddenExpire = nil;
    return true;
  end
end

-- Custom Text [Every Frame]
function()
  if (aura_env.expire ~= nil and aura_env.hiddenExpire ~= nil) then
    local now = GetTime();
    local expire = aura_env.getExpire(now, aura_env.expire, aura_env.hiddenExpire);
    return aura_env.printStatus(aura_env.hidden, aura_env.printDuration(now, expire));
  end
  return "";
end

-- Duration Info
function()
  if (aura_env.expire ~= nil and aura_env.hiddenExpire ~= nil) then
    return aura_env.getDuration();
  end
end

-- Init
aura_env.event = "HelyaOrbCorruption";
aura_env.delayEvent = "HelyaOrbCorruptionDelay";
aura_env.guid = UnitGUID("player");
aura_env.spellID = 229119;
aura_env.castID = 227903;
aura_env.tooltipID = "227920";
aura_env.length = 8;
aura_env.hiddenLength = 53;
aura_env.safeLength = 5;
aura_env.hidden = false;
aura_env.expire = nil;
aura_env.hiddenExpire = nil;
aura_env.safeColor = {};
aura_env.safeColor.r = 1;
aura_env.safeColor.g = 1;
aura_env.safeColor.b = 1;
aura_env.safeColor.a = 1;
aura_env.runColor = {};
aura_env.runColor.r = 1;
aura_env.runColor.g = 0;
aura_env.runColor.b = 0;
aura_env.safeColor.a = 1;
aura_env.getDuration = function()
  local now = GetTime();
  if (now < aura_env.expire) then
    return aura_env.expire - now, aura_env.length, true;
  elseif (now < aura_env.hiddenExpire) then
    return aura_env.hiddenExpire - now, aura_env.hiddenLength, true;
  else
    return 0, 100, true;
  end
end
aura_env.getExpire = function(now, expire, hiddenExpire)
  if (now < expire) then
    aura_env.hidden = false;
    return expire;
  elseif (now < hiddenExpire) then
    aura_env.hidden = true;
    aura_env.setColor(aura_env.safeColor.r, aura_env.safeColor.g, aura_env.safeColor.b, aura_env.safeColor.a);
    return hiddenExpire
  else
    WeakAuras.ScanEvents(aura_env.event);
    return hiddenExpire;
  end
end
aura_env.printStatus = function(hidden, duration)
  local alert = "RUN!";
  if (hidden == true) then
    alert = "SAFE!";
  end
  return string.format("%s\n%s", alert, duration);
end
aura_env.printDuration = function(now, expire)
  return string.format("%.1f", expire - now);
end
aura_env.setColor = function(r, g, b, a)
  WeakAuras.regions[aura_env.id].region.icon:SetVertexColor(r, g, b, a);
end
