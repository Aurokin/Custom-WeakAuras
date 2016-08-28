-- DOES NOT WORK CRASHES COMPUTER HOLY FUCK

-- Trigger
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
    if (msg == "UNIT_DIED" and destName == aura_env.bossName and aura_env.active == true) then
      -- Untrigger
      aura_env.active = false;
      WeakAuras.ScanEvents(aura_env.eventName);
    elseif (msg == "SPELL_PERIODIC_DAMAGE" and destName == aura_env.bossName and spellName == aura_env.spellName) then
      -- Trigger
      aura_env.sweepTime = GetTime();
      aura_env.active = true;
      return true;
    elseif (aura_env.sweepTime) then
      local currentTime = GetTime();
      if (aura_env.sweepTime + aura_env.safeTime < currentTime and aura_env.active == true) then
          -- Untrigger
          aura_env.active = false;
          WeakAuras.ScanEvents(aura_env.eventName);
      end
    end
end

-- Untrigger
function(event)
  if (event == aura_env.eventName) then
      return true;
  end
end

-- Init
aura_env.sweepTime = nil;
aura_env.bossName = "Makogg Emberblade";
aura_env.spellName = "Lava Sweep";
aura_env.safeTime = 2;
aura_env.eventName = "AuroCM_LS";
aura_env.active = false;

-- On Hide
aura_env.sweepTime = nil;

-- String
https://gist.github.com/4416575c32e6ed245799
