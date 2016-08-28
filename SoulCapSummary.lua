-- Auro: Soul Cap Summary
-- Version: 0.0.6

-- Trigger [ENCOUNTER_START, ENCOUNTER_END, COMBAT_LOG_EVENT_UNFILTERED, Auro_SoulCapSummary]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName, _, spellDamage)
  if (event == "ENCOUNTER_START") then
    aura_env.inProgress = true;
    aura_env.lastExplosion = GetTime();
    aura_env.explosionCount = 1;
    aura_env.playerGUID = UnitGUID("player");
    aura_env.wipeTable(aura_env.explosions);
    return true;
  elseif (event == "ENCOUNTER_END") then
    aura_env.inProgress = false;
    -- For Display After Encounter End
    -- Move wipeTable / explosionCount reset to on WeakAura Hide
    -- Run ScanEvents with [http://wowprogramming.com/docs/api/C_Timer.After]
    C_Timer.After(aura_env.expireAfterBoss, WeakAuras.ScanEvents(aura_env.eventName));
  end
  if (event == "COMBAT_LOG_EVENT_UNFILTERED" and aura_env.inProgress == true) then
    if (msg == "SPELL_DAMAGE" and spellID == aura_env.spiritEruptionID and srcGUID == aura_env.playerGUID) then
      local currentTime = GetTime();
      if (currentTime <= aura_env.lastExplosion + aura_env.explosionSafetyTime) then
        -- Same Explosion
        aura_env.explosions[aura_env.explosionCount] = aura_env.explosions[aura_env.explosionCount] + spellDamage;
      else
        -- New Explosion
        aura_env.explosions[aura_env.explosionCount] = spellDamage;
        aura_env.lastExplosion = currentTime;
        -- Remove Print
        print("Explosion" .. spellDamage);
        aura_env.explosionCount = aura_env.explosionCount + 1;
      end
    end
  end
end

-- Untrigger
function(event)
  if (event == aura_env.eventName) then
    aura_env.explosionCount = 1;
    aura_env.wipeTable(aura_env.explosions);
    return true;
  end
end

-- Custom Text[Every Frame]
function()
  return aura_env.prepareString();
end


-- Init
aura_env.eventName = "Auro_SoulCapSummary";
aura_env.inProgress = false;
aura_env.playerGUID = UnitGUID("player");
aura_env.lastExplosion = GetTime();
aura_env.explosionSafetyTime = 1;
aura_env.expireAfterBoss = 10;
aura_env.spiritEruptionID = 184559;
aura_env.explosionCount = 1;
aura_env.explosions = {};
aura_env.wipeTable = function(table)
  for i in pairs(table) do
    table[i] = nil;
  end
end
aura_env.shortenNumber = function(number)
  number = tonumber(number);
  local marker = "";
  if (number > 999 and number < 1000000) then
      marker = "k";
      number = number / 1000;
  elseif (number > 999999) then
      marker = "m";
      number = number / 1000000;
  end
  return number, marker;
end
aura_env.prepareString = function()
  local soulCapSummary = "";
  -- Add if WeakAuras.IsOptionsOpen() then, with preview
  for explosion in pairs(aura_env.explosions) do
    local number, marker = aura_env.shortenNumber(aura_env.explosions[explosion]);
    soulCapSummary = soulCapSummary .. string.format("%.1f%s\n", number, marker);
  end
  return soulCapSummary;
end
