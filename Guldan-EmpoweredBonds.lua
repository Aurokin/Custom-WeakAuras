-- Custom Text [Every Frame]
function()
    -- Demo Mode
    if (WeakAuras.IsOptionsOpen()) then return aura_env.buildString(aura_env.dangerColor, 4, "m") end
    -- Calculate Damage
    local inRange = aura_env.raidRangeCheck()
    local damage = aura_env.calculateDamage(aura_env.baseDamage, inRange)
    -- Calculate Safety
    local health = aura_env.getUnitHealth("player")
    -- Build Output
    local number, marker = aura_env.shortenNumber(damage)
    local color = aura_env.getSafetyColor(health, damage, aura_env.safeColor, aura_env.dangerColor)

    return aura_env.buildString(color, number, marker)
end


-- Init
aura_env.baseDamage = 12000000
aura_env.dangerColor = "ffc23cff"
aura_env.safeColor = "ff66ff6d"

aura_env.buildString = function(color, number, marker)
    return string.format("|c%s%.1f%s|r", color, number, marker)
end

aura_env.calculateDamage = function(base, inRange)
    return base / math.max(inRange, 1)
end

aura_env.getSafetyColor = function(health, damage, safeColor, dangerColor)
    if (health > damage) then
        return safeColor
    else
        return dangerColor
    end
end

aura_env.getUnitHealth = function(unit)
    return UnitHealth(unit) + UnitGetTotalAbsorbs(unit)
end

aura_env.raidRangeCheck = function()
    local inRange = 0
    for i = 1, GetNumGroupMembers() do
        local unit = GetRaidRosterInfo(i)
        if aura_env.rangeCheck(unit) then
            inRange = inRange + 1
        end
    end

    return inRange
end

aura_env.rangeCheck = function(unit)
    -- <= 8yds
    return IsItemInRange(63427, unit)
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