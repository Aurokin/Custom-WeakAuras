-- Auro: Archimonde - Shackle Text
-- Version: 0.0.3
-- Load: Zone[Hellfire Citadel]

-- Trigger [ENCOUNTER_START, COMBAT_LOG_EVENT_UNFILTERED, AuroBM_ShackleText]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
  if (event == "ENCOUNTER_START" and aura_env.encounterIDs[encounterID] == true) then
    aura_env.wipe2DTable(aura_env.shackles);
    aura_env.wipeTable(aura_env.rosterIDs);
    aura_env.rosterSize = GetNumGroupMembers();
    for i = 1, aura_env.rosterSize do
      local guid = UnitGUID("raid" .. i);
      aura_env.rosterIDs[guid] = i;
    end
    print("Auro: Archimonde Shackle Text - Loaded");
  end
  if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
    if (msg == "SPELL_AURA_APPLIED" and spellID == aura_env.shackleDebuffSpellID) then
      -- Find Unit
      local raidID = aura_env.rosterIDs[destGUID];
      if not raidID then return false; end
      local x, y, z, map = UnitPosition("raid" .. raidID);
      if not x then return false; end
      local name = UnitName("raid" .. raidID);
      local _, class = UnitClass(name);
      if not class then return end;
      name = string.gsub(name, "%-[^|]+", "");

      aura_env.shackles[destGUID] = {};
      aura_env.shackles[destGUID]["name"] = name;
      aura_env.shackles[destGUID]["x"] = x;
      aura_env.shackles[destGUID]["y"] = y;
      aura_env.shackles[destGUID]["unit"] = raidID;
      aura_env.shackles[destGUID]["color"] = RAID_CLASS_COLORS[class].colorStr;

      return true;
    elseif (msg == "SPELL_AURA_REMOVED" and spellID == aura_env.shackleDebuffSpellID) then
      aura_env.wipeSection(aura_env.shackles, destGUID);
      if not next(aura_env.shackles) then
        WeakAuras.ScanEvents(aura_env.eventName);
      end
    elseif (msg == "UNIT_DIED" and aura_env.shackles[destGUID]) then
      aura_env.wipeSection(aura_env.shackles, destGUID);
      if not next(aura_env.shackles) then
        WeakAuras.ScanEvents(aura_env.eventName);
      end
    elseif (msg == "SPELL_CAST_START" and spellID == aura_env.ascensionSpellID) then
      -- P3
      aura_env.wipe2DTable(aura_env.shackles);
      WeakAuras.ScanEvents(aura_env.eventName);
    elseif (msg == "SPELL_CAST_START" and spellID == aura_env.shackleCastSpellID) then
      aura_env.wipe2DTable(aura_env.shackles);
    end
  end
end

-- Untrigger
function(event)
  if (event == aura_env.eventName) then
    return true;
  end
end

-- Custom Text [Every Frame]
function()
  if not aura_env.rosterSize then return "" end
  if not aura_env.rosterIDs then return "" end
  local shackleString = "";
  local personalID = aura_env.rosterIDs[aura_env.playerGUID];
  local personalX, personalY = UnitPosition("raid" .. personalID);
  if not personalX then return shackleString end
  for guid in pairs (aura_env.shackles) do
    -- Variables
    local num = 0;
    local shackleUnit = aura_env.shackles[guid]["unit"];
    local shackleName = aura_env.shackles[guid]["name"];
    local shackleX = aura_env.shackles[guid]["x"];
    local shackleY = aura_env.shackles[guid]["y"];
    local classColor = aura_env.shackles[guid]["color"];

    for i = 1, aura_env.rosterSize do
      if shackleUnit ~= i then
        local raidX, raidY = UnitPosition("raid" .. i);
        if not raidX then break end
        local distance = aura_env.distance(shackleX, shackleY, raidX, raidY);
        if (distance <= aura_env.shackleRange) then
          num = num + 1;
        end;
      end
    end

    local personalDistance = aura_env.distance(shackleX, shackleY, personalX, personalY);
    local personalColor = aura_env.colorRed;
    if (personalDistance > 25) then
      personalColor = aura_env.colorGreen;
    end

    local shackleColor = aura_env.colorRed;
    if (num == 0) then
      shackleColor = aura_env.colorGreen;
    end
    shackleString = shackleString .. string.format("|c%s%s|r - |c%s%d|r - |c%s%dyd|r\n", classColor, shackleName, shackleColor, num, personalColor, personalDistance);
  end
  if not next(aura_env.shackles) then
    WeakAuras.ScanEvents(aura_env.eventName);
  end
  return shackleString;
end


-- Init
aura_env.eventName = "AuroBM_ShackleHUD";
aura_env.playerGUID = UnitGUID("player");
aura_env.rosterSize = nil;
aura_env.rosterIDs = {};
aura_env.shackleCastSpellID = 184931;
aura_env.shackleDebuffSpellID = 184964;
aura_env.ascensionSpellID = 190313;
aura_env.shackleRange = 25;
aura_env.shackles = {};
aura_env.encounterIDs = {};
aura_env.encounterIDs[1799] = true;
aura_env.colorRed = "FFFF0000";
aura_env.colorGreen = "FF00FF00";
aura_env.wipeTable = function(table)
  -- Clear Table
  for guid in pairs(table) do
      table[guid] = nil;
  end
end
aura_env.wipe2DTable = function(table)
  -- Clear Table
  for guid in pairs(table) do
      for v in pairs(table[guid]) do
        table[guid][v] = nil;
      end
      table[guid] = nil;
  end
end
aura_env.wipeSection = function(table, section)
  if (table[section]) then
    for v in pairs(table[section]) do
      table[section][v] = nil;
    end
    table[section] = nil;
  end
end
aura_env.distance = function(x1, y1, x2, y2)
  local dx = x2 - x1;
  local dy = y2 - y1;
  local distance = (dx * dx) + (dy * dy);
  distance = math.sqrt(distance);
  return distance;
end
