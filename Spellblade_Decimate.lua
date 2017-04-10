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
    if ((msg == "SPELL_PERIODIC_DAMAGE" or msg == "SPELL_ABSORBED") and (aura_env.lastTrue == nil or aura_env.lastTrue + 10 < GetTime())) then
      local spellID = select(12, ...);
      if (aura_env.spellID == spellID) then
        aura_env.lastTrue = GetTime();
        return true;
      end
    end
  end
end

-- Untrigger [15s]

-- Custom Text [Every Frame]
function()
  if (aura_env.group ~= nil and next(aura_env.group) ~= nil) then
    local player = aura_env.findTarget(aura_env.group, aura_env.enemy);
    if (player ~= nil) then return aura_env.printPlayer(player); end
    return "?";
  end
  return "?";
end

-- Init
aura_env.enemy = "Fel Soul";
aura_env.playerGUID = UnitGUID("player");
aura_env.spellID = 230423;
aura_env.spellName = GetSpellInfo(aura_env.spellID);
aura_env.lastMatch = nil;
aura_env.lastTrue = nil;
aura_env.group = {};
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

aura_env.checkSource = function(unit, enemy)
  local name = UnitName(unit);
  if (name == enemy) then return unit; end
  return nil;
end

aura_env.findSource = function(group, enemy)
  local unit;
  if (aura_env.lastMatch ~= nil and aura_env.lastMatch ~= aura_env.playerGUID and group[aura_env.lastMatch] ~= nil) then
    unit = aura_env.checkSource(group[aura_env.lastMatch]["unit"] .. "target", enemy);
    if (unit ~= nil) then
      return unit;
    end
  end
  if (aura_env.checkSource("target", enemy) ~= nil) then return "target"; end
  if (aura_env.checkSource("focus", enemy) ~= nil) then return "focus"; end
  for k, p in pairs(group) do
    if (p["unit"] ~= "player" and aura_env.checkSource(p["unit"] .. "target", enemy) ~= nil) then aura_env.lastMatch = k; return p["unit"] .. "target"; end
  end
  aura_env.lastMatch = nil;
  return nil;
end

aura_env.findTarget = function(group, enemy)
  local source = aura_env.findSource(group, enemy);
  if (source == nil) then return nil; end
  local player = UnitGUID(source .. "target");
  if (group[player] ~= nil) then return group[player]; end
  return nil;
end