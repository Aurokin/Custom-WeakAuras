-- Trigger [PLAYER_ENTERING_WORLD, GROUP_ROSTER_UPDATE, COMBAT_LOG_EVENT_UNFILTERED, AURO_AUGERBUDDY, ENCOUNTER_START, ENCOUNTER_END]
function(event, ...)
  if (event == "PLAYER_ENTERING_WORLD") then
    aura_env.group = aura_env.initGroup()
  elseif (event == "GROUP_ROSTER_UPDATE" or event == "ENCOUNTER_START") then
    if (aura_env.group ~= nil and next(aura_env.group) ~= nil) then
      aura_env.group = aura_env.updateGroup(aura_env.group)
    else
      aura_env.group = aura_env.initGroup()
    end
  elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
    local msg = select(2, ...)
    local sGUID = select(4, ...)
    local dGUID = select(8, ...)
    local spellID = select(12, ...)
    if (msg == "SPELL_AURA_APPLIED" and aura_env.spellIDs[spellID] ~= nil) then
      aura_env.group[dGUID]["debuff"] = spellID
      if (dGUID == aura_env.pGUID) then
        return true
      end
    elseif (msg == "UNIT_DIED" and aura_env.group[dGUID] ~= nil) then
      aura_env.group[dGUID]["debuff"] = nil
      if (dGUID == aura_env.pGUID) then
        WeakAuras.ScanEvents(aura_env.event)
      end
    elseif (msg == "SPELL_AURA_REMOVED" and aura_env.spellIDs[spellID] ~= nil) then
      aura_env.group[dGUID]["debuff"] = nil
      if (dGUID == aura_env.pGUID) then
        WeakAuras.ScanEvents(aura_env.event)
      end
    end
  end
end

-- Untrigger [Untrigger Via Re-Zone]
function(event, ...)
  if (event == aura_env.event or event == "ENCOUNTER_END") then
     return true 
  end
end

-- Custom Text [Every Frame]
function()
  if (aura_env.group ~= nil and next(aura_env.group) ~= nil and aura_env.group[aura_env.pGUID]["debuff"] ~= nil) then
    return aura_env.printGroup(aura_env.group, aura_env.group[aura_env.pGUID]["debuff"]);
  elseif (WeakAuras.IsOptionsOpen()) then
    return aura_env.demoPrint()
  end
end

-- Init
aura_env.event = "AURO_AUGERBUDDY"
aura_env.pGUID = UnitGUID("player")
aura_env.group = {}
aura_env.spellIDs = {
    [205429] = true, 
    [216344] = true, 
    [216345] = true, 
    [205445] = true
}
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
  local player = {}
  player["name"] = string.gsub(GetUnitName(unit, false), "%-[^|]+", "")
  player["class"] = UnitClass(unit)
  player["classColor"] = aura_env.getClassColor(unit)
  player["unit"] = unit
  player["debuff"] = nil
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

aura_env.printGroup = function(group, debuff)
  local str = "";
  local player;
  for k, p in pairs(group) do
    if (p["debuff"] == debuff) then
      player = aura_env.printPlayer(p);
      str = str .. player .. "\n";
    end
  end
  return str;
end

aura_env.demoPrint = function()
  local p = aura_env.initPlayer("player")
  p["debuff"] = 1
  local grp = {p, p, p, p}
  return aura_env.printGroup(grp, 1)
end