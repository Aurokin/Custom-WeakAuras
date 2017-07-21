-- Trigger [PLAYER_ENTERING_WORLD, GROUP_ROSTER_UPDATE, COMBAT_LOG_EVENT_UNFILTERED]
function(event, ...)
  if (event == "PLAYER_ENTERING_WORLD") then
    aura_env.group = aura_env.initGroup();
  elseif (event == "GROUP_ROSTER_UPDATE") then
    if (aura_env.group ~= nil and next(aura_env.group) ~= nil) then
      aura_env.group = aura_env.updateGroup(aura_env.group);
    else
      aura_env.group = aura_env.initGroup();
    end
  elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
    local msg = select(2, ...);
    if (aura_env.group == nil or next(aura_env.group) == nil) then
      aura_env.group = aura_env.initGroup();
    end
    if (msg == "SPELL_AURA_APPLIED" or msg == "SPELL_AURA_REMOVED") then
      local sourceGUID = select(8, ...);
      local spellID = select(12, ...);
      if (aura_env.group[sourceGUID] ~= nil and aura_env.spellID == spellID) then
        if (msg == "SPELL_AURA_APPLIED") then
          aura_env.group[sourceGUID]["hydraShot"] = true;
          return true
        else
          aura_env.group[sourceGUID]["hydraShot"] = false;
        end
      end
    elseif (msg == "UNIT_DIED") then
      local destGUID = select(8, ...);
      if (destGUID ~= nil and aura_env.group[destGUID] ~= nil) then
        aura_env.group[destGUID]["hydraShot"] = false;
      end
    end
  end
end

-- Untrigger [Untrigger Via Re-Zone]
function(event, ...)
  return false;
end

-- Custom Text [Every Frame]
function()
  if (aura_env.group ~= nil and next(aura_env.group) ~= nil) then
    return aura_env.printGroup(aura_env.group);
  end
end

-- Init
-- Set Your Marker Here!
-- 1: Star
-- 2: Circle
-- 3: Diamond
-- 5: Moon
aura_env.soaks = {
    1 = true,
    2 = false,
    3 = false,
    5 = false,
}
aura_env.group = {};
aura_env.spellId = 230139
-- Functions
aura_env.getPrefix = function()
  if IsInRaid() then
    return "raid";
  else
    return "party";
  end
end

aura_env.getClassColor = function(unit)
  local color = "ffffffff";
  local colorTemp = RAID_CLASS_COLORS[select(2, UnitClass(unit))];
  if (colorTemp ~= nil) then
    color = colorTemp.colorStr;
  end
  return color
end

aura_env.initPlayer = function(unit)
  local player = {};
  player["name"] = string.gsub(GetUnitName(unit, false), "%-[^|]+", "");
  player["class"] = UnitClass(unit);
  player["classColor"] = aura_env.getClassColor(unit);
  player["unit"] = unit;
  player["hydraShot"] = false;
  return player;
end

aura_env.initGroup = function()
  local group = {};
  local members = GetNumGroupMembers();
  local prefix = aura_env.getPrefix();
  local guid;
  local unit;
  for i = 1, members do
    unit = prefix .. i;
    if (i == members) then
      unit = 'player';
    end
    guid = UnitGUID(unit);
    group[guid] = aura_env.initPlayer(unit);
  end
  return group;
end

aura_env.updateGroup = function(group)
  local newGroup = {};
  local members = GetNumGroupMembers();
  local prefix = aura_env.getPrefix();
  local guid;
  for i = 1, members do
    unit = prefix .. i;
    if (i == members) then
      unit = 'player';
    end
    guid = UnitGUID(unit);
    if (group[guid] ~= nil) then
      newGroup[guid] = group[guid];
    else
      newGroup[guid] = aura_env.initPlayer(unit);
    end
  end
  return newGroup;
end

aura_env.printPlayer = function(player)
  return string.format("|c%s%s|r", player["classColor"], player["name"]);
end

aura_env.printGroup = function(group)
  local str = "";
  local player;
  for k, p in pairs(group) do
    player = aura_env.printPlayer(p);
    str = str .. player .. "\n";
  end
  return str;
end

-- Specific Functions
aura_env.getIcon = function(icons)
    for k, i = pairs(icons) do
        if (i == true) then
            return k
        end
    end
    return 1
end

aura_env.getPlayer = function(group, icon)
    for k, p = pairs(group) do

    end
end

aura_env.printString = function(icon, player)
    local iconS = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. icon .. ":0|t"
    return iconS .. " SOAK! " .. iconS .. "\n" .. aura_env.printPlayer(player)
end