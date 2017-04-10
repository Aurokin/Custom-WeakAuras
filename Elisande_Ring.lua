-- Trigger [PLAYER_ENTERING_WORLD, GROUP_ROSTER_UPDATE, COMBAT_LOG_EVENT_UNFILTERED, ENCOUNTER_END]
function(event, ...)
  if (event == "PLAYER_ENTERING_WORLD") then
    aura_env.group = aura_env.initGroup();
  elseif (event == "GROUP_ROSTER_UPDATE") then
    if (aura_env.group ~= nil and next(aura_env.group) ~= nil) then
      aura_env.group = aura_env.updateGroup(aura_env.group);
    else
      aura_env.group = aura_env.initGroup();
    end
  elseif (evnet == "ENCOUNTER_END") then
    local groupBreakdown = aura_env.printGroup(aura_env.group, 20)
    print(groupBreakdown)
  elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
    local msg = select(2, ...);
    local guid = select(8, ...);
    local spellID = select(12, ...);

    if (aura_env.group == nil and next(aura_env.group) == nil) then
      aura_env.group = aura_env.initGroup();
    elseif (aura_env.group[guid] == nil) then
      aura_env.group = aura_env.updateGroup(aura_env.group);
    end

    if (msg == "SPELL_PERIODIC_DAMAGE" and aura_env.group[guid] ~= nil and spellID == aura_env.spellID) then
      aura_env.update = true
      aura_env.group[guid]["hits"] = aura_env.group[guid]["hits"] + 1 or 1
      aura_env.sendMessage(aura_env.sender, aura_env.group[guid])
      return true
    end
  end
end

-- Untrigger [Untrigger Via Re-Zone]
function(event, ...)
  return false;
end

-- Custom Text [Every Frame]
function()
  if (aura_env.group ~= nil and next(aura_env.group) ~= nil and aura_env.update == true) then
    aura_env.update = false
    aura_env.text = aura_env.printGroup(aura_env.group, aura_env.limit)
  elseif (WeakAuras.IsOptionsOpen()) then
    return aura_env.printGroup(aura_env.demoGroup, aura_env.limit)
  end
  return aura_env.text
end

-- Init
aura_env.group = {};
aura_env.player = UnitGUID("player")
aura_env.spellID = 208659
aura_env.update = true
aura_env.text = ""

aura_env.limit = 5
aura_env.sender = true

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
  player["hits"] = 0
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
  return string.format("|c%s%s|r - %d", player["classColor"], player["name"], player["hits"]);
end

aura_env.printGroup = function(group, limit)
  local str = "";
  local printed = 0;
  local player;

  local sorted = {};
  for k, p in pairs(group) do
    table.insert(sorted, p);
  end
  group = sorted
  table.sort(group, function(a, b) return a["hits"] > b["hits"] end)

  for k, p in pairs(group) do
    if (p["hits"] > 0 and printed < limit) then
      player = aura_env.printPlayer(p);
      str = str .. player .. "\n";
      printed = printed + 1
    end
  end
  return str;
end

aura_env.sendMessage = function(sender, player)
  if (sender == true) then
    local string = string.format("%s - %d", player["name"], player["hits"])
    SendChatMessage(string, "RAID")
  end
end

-- Demo
aura_env.demoGroup = {}
aura_env.demoGroup["Player-1129-0831D429"] = {["name"] = "Auro", ["class"] = "DRUID", ["classColor"] = "ffff7d0a", ["unit"] = "player", ["hits"] = 1};
aura_env.demoGroup["Player-1129-092B57E5"] = {["name"] = "Onchy", ["class"] = "PALADIN", ["classColor"] = "fff58cba", ["unit"] = "party1", ["hits"] = 2};
aura_env.demoGroup["Player-1129-07D2ABB5"] = {["name"] = "Buddie", ["class"] = "ROGUE", ["classColor"] = "fffff569", ["unit"] = "party2", ["hits"] = 3};
aura_env.demoGroup["Player-1129-08546CD9"] = {["name"] = "Skyline", ["class"] = "MAGE", ["classColor"] = "ff3fc7eb", ["unit"] = "party3", ["hits"] = 4};
aura_env.demoGroup["Player-1129-05C41ZT2"] = {["name"] = "Sensations", ["class"] = "SHAMAN", ["classColor"] = "ff0070de", ["unit"] = "party4", ["hits"] = 5};
