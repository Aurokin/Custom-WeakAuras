-- Trigger [COMBAT_LOG_EVENT_UNFILTERED, ENCOUNTER_START, PLAYER_ENTERING_WORLD, GROUP_ROSTER_UPDATE]
function(event, ...)
    if (event == "PLAYER_ENTERING_WORLD") then
        aura_env.group = aura_env.initGroup();
    elseif (event == "GROUP_ROSTER_UPDATE") then
        if (aura_env.group ~= nil and next(aura_env.group) ~= nil) then
        aura_env.group = aura_env.updateGroup(aura_env.group);
        else
        aura_env.group = aura_env.initGroup();
        end
    elseif (event == "ENCOUNTER_START") then
        aura_env.darkMarks = {}
    elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
        local msg = select(2, ...)
        local destGUID = select(8, ...)
        local spellId = select(12, ...)
        if (msg == "SPELL_AURA_APPLIED" and aura_env.group[destGUID] ~= nil and spellId == aura_env.darkMarkId) then
            aura_env.darkMarks[#aura_env.darkMarks + 1] = {}
            aura_env.darkMarks[#aura_env.darkMarks]["player"] = destGUID
            aura_env.darkMarks[#aura_env.darkMarks]["expirationTime"] = GetTime() + aura_env.baseMark + (aura_env.multiplier * (#aura_env.darkMarks - 1))
            return true
        end
    end
end

-- Untrigger [10s]


-- Custom Text [Every Frame]
function()
  if (aura_env.group ~= nil and next(aura_env.group) ~= nil and aura_env.darkMarks ~= nil and next(aura_env.darkMarks) ~= nil) then
    return aura_env.printMarks(aura_env.darkMarks, aura_env.group, aura_env.desiredLength)
  elseif (WeakAuras.IsOptionsOpen()) then
    if (aura_env.demoMarks[3]["expirationTime"] < GetTime()) then
      aura_env.demoMarks[1]["expirationTime"] = GetTime() + 6
      aura_env.demoMarks[2]["expirationTime"] = GetTime() + 8
      aura_env.demoMarks[3]["expirationTime"] = GetTime() + 10
    end
    return aura_env.printMarks(aura_env.demoMarks, aura_env.demoGroup, aura_env.desiredLength)
  end
end

-- Init
aura_env.group = {}
aura_env.darkMarks = {}
aura_env.baseMark = 6
aura_env.multiplier = 2
aura_env.darkMarkId = 239739
aura_env.desiredLength = 20
aura_env.positions = {
    [1] = "Left",
    [2] = "Middle",
    [3] = "Right",
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
        if (i == members and prefix == "party") then
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
        if (i == members and prefix == "party") then
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

aura_env.printPositions = function(darkMarks, positions, desiredLength)
    local str = ""
    for k, m in ipairs(darkMarks) do
        local positionStr = string.format("%.1f %s", math.max(0, m["expirationTime"] - GetTime()),  positions[k])
        if (#darkMarks ~= k) then positionStr = aura_env.rightPad(positionStr, desiredLength) end
        str = str .. positionStr
    end
    return str
end

aura_env.printPlayers = function(darkMarks, group, desiredLength)
    local str = ""
    for k, m in ipairs(darkMarks) do
        local guid = m["player"]
        local player = aura_env.printPlayer(group[guid])
        if (#darkMarks ~= k) then player = aura_env.rightPadStyledText(player, desiredLength, group[guid]["name"]) end
        str = str .. player
    end
    return str
end

aura_env.printMarks = function(darkMarks, group, desiredLength)
    local str = "";
    local positions = aura_env.printPositions(darkMarks, aura_env.positions, desiredLength)
    local players = aura_env.printPlayers(darkMarks, group, desiredLength)
    str = positions .. '\n' .. players
    return str;
end

aura_env.rightPad = function(str, desiredLength)
    local spaces = desiredLength - string.len(str)
    for i = 1, spaces, 1 do
        str = str .. " "
    end
    return str
end

aura_env.rightPadStyledText = function(str, desiredLength, originalStr)
    local spaces = desiredLength - string.len(originalStr)
    for i = 1, spaces, 1 do
        str = str .. " "
    end
    return str
end

aura_env.leftPad = function(str, desiredLength)
    local spaces = desiredLength - string.len(str)
    for i = 1, spaces, 1 do
        str = " " .. str 
    end
    return str
end

-- Demo Mode
aura_env.demoMarks = {
    [1] = {
        ["player"] = 1,
        ["expirationTime"] = GetTime() + 6
    },
    [2] = {
        ["player"] = 2,
        ["expirationTime"] = GetTime() + 8
    },
    [3] = {
        ["player"] = 3,
        ["expirationTime"] = GetTime() + 10
    }
}
aura_env.demoGroup = {
    [1] = {
        ["name"] = "Auro",
        ["class"] = "Druid",
        ["classColor"] = "FFFF7D0A",
        ["unit"] = "player"
    },
    [2] = {
        ["name"] = "Sensations",
        ["class"] = "Druid",
        ["classColor"] = "FF0070DE",
        ["unit"] = "player"
    },
    [3] = {
        ["name"] = "Procz",
        ["class"] = "Mage",
        ["classColor"] = "FF69CCF0",
        ["unit"] = "player"
    }
}