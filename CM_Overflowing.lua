-- Trigger [PLAYER_ENTERING_WORLD, GROUP_ROSTER_UPDATE, COMBAT_LOG_EVENT_UNFILTERED]
function(event, ...)
  if (event == "PLAYER_ENTERING_WORLD") then
    aura_env.group = aura_env.initGroup();
    return true;
  elseif (event == "GROUP_ROSTER_UPDATE") then
    if (aura_env.group ~= nil and next(aura_env.group) ~= nil) then
      aura_env.group = aura_env.updateGroup(aura_env.group);
    else
      aura_env.group = aura_env.initGroup();
    end
    return true;
  elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
    local msg = select(2, ...);
    local guid = select(8, ...);
    local spellID = select(12, ...);
    if (aura_env.overflow == spellID) then
      if (aura_env.group == nil or next(aura_env.group) == nil) then
        aura_env.group = aura_env.initGroup();
      end
      if (aura_env.updateMsgs[msg] == true and aura_env.group[guid] ~= nil) then
        aura_env.group[guid]["overflowing"] = aura_env.getOverflowing(aura_env.group[guid]["unit"]);
      elseif (aura_env.removedMsg == msg and aura_env.group[guid] ~= nil) then
        aura_env.group[guid]["overflowing"] = -1;
      end
      return true;
    end
  end
end

-- Untrigger [Untrigger Via Re-Zone]
function(event, ...)
  return false;
end

-- Custom Text [Every Frame]
function()
  if (WeakAuras.IsOptionsOpen()) then
    aura_env.demoGroup = aura_env.randomizeDemoGroup(aura_env.demoGroup);
    return aura_env.printGroup(aura_env.demoGroup, aura_env.sort);
    end
  elseif (aura_env.group ~= nil and next(aura_env.group) ~= nil) then
    return aura_env.printGroup(aura_env.group, aura_env.sort);
  end
end

-- Init
-- Settings
aura_env.sort = true;
-- Constants
aura_env.update = false;
aura_env.overflow = 221772;
aura_env.updateMsgs = {["SPELL_HEAL_ABSORBED"] = true, ["SPELL_AURA_APPLIED"] = true};
aura_env.removedMsg = "SPELL_AURA_REMOVED";
aura_env.group = {};
-- Functions
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
  player["overflowing"] = -1;
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
  local number, marker = aura_env.shortenNumber(player["overflowing"]);
  return string.format("|c%s%s|r - %.1f%s", player["classColor"], player["name"], number, marker);
end

aura_env.printGroup = function(group, sort)
  local str = "";
  local player;
  if (sort) then
    table.sort(group, function(a, b) return a["overflowing"] > b["overflowing"] end);
  end
  for k, p in pairs(group) do
    if (p["overflowing"] ~= nil and p["overflowing"] >= 0) then
      player = aura_env.printPlayer(p);
      str = str .. player .. "\n";
    end
  end
  return str;
end

aura_env.getOverflowing = function(unit)
  local overflow = select(17, UnitDebuff(unit, GetSpellInfo(aura_env.overflow)));
  if (overflow == nil) then
    return -1;
  end
  return overflow;
end

-- Demo Mode
aura_env.demoGroup = {};
aura_env.demoGroup[1] = {["name"] = "Auro", ["class"] = "DRUID", ["classColor"] = "ffff7d0a", ["unit"] = "player", ["overflowing"] = 500000, ["update"] = nil};
aura_env.demoGroup[2] = {["name"] = "Onchy", ["class"] = "PALADIN", ["classColor"] = "fff58cba", ["unit"] = "party1", ["overflowing"] = 500000, ["update"] = nil};
aura_env.demoGroup[3] = {["name"] = "Buddie", ["class"] = "ROGUE", ["classColor"] = "fffff569", ["unit"] = "party2", ["overflowing"] = 500000, ["update"] = nil};
aura_env.demoGroup[4] = {["name"] = "Skyline", ["class"] = "MAGE", ["classColor"] = "ff3fc7eb", ["unit"] = "party3", ["overflowing"] = 500000, ["update"] = nil};
aura_env.demoGroup[5] = {["name"] = "Sensations", ["class"] = "SHAMAN", ["classColor"] = "ff0070de", ["unit"] = "party4", ["overflowing"] = 500000, ["update"] = nil};

aura_env.randomizeDemoGroup = function(group)
  for k, p in pairs(group) do
    group[k]["overflowing"], group[k]["update"] = aura_env.randomizeOverflow(p["overflowing"], p["update"]);
  end
  return group;
end

aura_env.randomizeOverflow = function(overflow, update)
  local time = GetTime();
  if (update ~= nil and update + 1 > time) then
    return overflow, update;
  else
    update = time;
  end
  local op = math.random(2);
  if (op == 1) then
    return overflow + math.random(50000), update;
  else
    return overflow - math.random(50000), update;
  end
end
