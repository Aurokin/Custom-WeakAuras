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
          aura_env.group[sourceGUID]["mark"] = GetTime();
        else
          aura_env.group[sourceGUID]["mark"] = nil;
        end
      end
    elseif (msg == "UNIT_DIED") then
      local destGUID = select(8, ...);
      if (destGUID ~= nil and aura_env.group[destGUID] ~= nil) then
        aura_env.group[destGUID]["mark"] = nil;
      end
    end
  end
  return true;
end

-- Untrigger [Untrigger Via Re-Zone]
function(event, ...)
  return false;
end

-- Custom Text [Every Frame]
function()
  if (aura_env.group ~= nil and aura_env.group[aura_env.playerGUID] ~= nil and aura_env.group[aura_env.playerGUID]["mark"] ~= nil) then
    local buddy = aura_env.findMark(aura_env.group, aura_env.group[aura_env.playerGUID]["mark"]);
    local duration = aura_env.getDuration();
    
    if (buddy ~= nil and duration == nil) then return aura_env.printPlayer(buddy);
    elseif (buddy == nil and duration ~= nil) then return string.format("%.1f", duration);
    elseif (buddy == nil and duration == nil) then return "?"; end
    
    return aura_env.printInformation(buddy, duration);
  end
  return "?";
end

-- Init
aura_env.playerGUID = UnitGUID("player");
aura_env.spellID = 212587;
aura_env.spellName = GetSpellInfo(aura_env.spellID);
aura_env.lastMatch = nil;
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
  player["mark"] = nil;
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

aura_env.getDuration = function()
  local endTime = select(7, UnitDebuff("player", aura_env.spellName));
  if (endTime == nil) then return nil end
  return endTime - GetTime();
end

aura_env.compareMark = function(mark1, mark2, safety)
  if (mark1 == nil or mark2 == nil) then
    return false;
  end
  local diff = mark1 - mark2;
  return (diff <= safety and diff >= -safety);
end

aura_env.findMark = function(group, mark)
  if (aura_env.lastMatch ~= nil and aura_env.compareMark(group[aura_env.lastMatch]["mark"], mark, 0.1)) then
    return group[aura_env.lastMatch];
  else
    aura_env.lastMatch = nil;
  end  
  for k, p in pairs(group) do
    if (k ~= aura_env.playerGUID and aura_env.compareMark(p["mark"], mark, 0.01)) then
      aura_env.lastMatch = k;
      return p;
    end
  end
  for k, p in pairs(group) do
    if (k ~= aura_env.playerGUID and aura_env.compareMark(p["mark"], mark, 0.1)) then
      aura_env.lastMatch = k;
      return p;
    end
  end
  return nil;
end

aura_env.printPlayer = function(player)
  return string.format("|c%s%s|r", player["classColor"], player["name"]);
end

aura_env.printInformation = function(player, duration)
    return string.format("%s%s%.1f", aura_env.printPlayer(player), "\n", duration);
end
