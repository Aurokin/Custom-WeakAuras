-- Auro: General Range
-- Version: 0.0.3
-- Load: Zone[Hellfire Citadel]
-- Do Not Load: EncounterID

-- Trigger [ENCOUNTER_START, COMBAT_LOG_EVENT_UNFILTERED, AuroBM_Range]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
  if (event == "ENCOUNTER_START" and aura_env.encounterIDs[encounterID] == true) then
    aura_env.rosterSize = GetNumGroupMembers();
    aura_env.wipe2DTable(aura_env.activeMembers);
    aura_env.active = false;
    for i = 1, aura_env.rosterSize do
      local nonTrim = UnitName("raid" .. i);
      local name = string.gsub(nonTrim, "%-[^|]+", "");
      if (aura_env.rangeNames[name]) then
        aura_env.activeMembers[name] = {};
        local _, class = UnitClass(nonTrim);
        if not class then return end;
        aura_env.activeMembers[name]["id"] = i;
        aura_env.activeMembers[name]["class"] = RAID_CLASS_COLORS[class].colorStr;
        aura_env.active = true;
      end
    end
    if (aura_env.active == true) then
      print("Auro: General Range - Loaded");
      return true;
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
  if (aura_env.active == false) then
    WeakAuras.ScanEvents(aura_env.eventName);
  end
  local rangeString = "";
  local personalX, personalY = UnitPosition("player");
  if not personalX then return rangeString end
  if not personalY then return rangeString end
  for name in pairs (aura_env.activeMembers) do
    local id = aura_env.activeMembers[name]["id"];
    local x, y = UnitPosition("raid" .. id);
    if not x then break; end
    if not y then break; end
    local distance = aura_env.distance(personalX, personalY, x, y);
    local dColor = aura_env.colorGreen;
    if (distance > 40) then
      dColor = aura_env.colorRed;
    end
    rangeString = rangeString .. string.format("|c%s%s|r - |c%s%dyd|r\n", aura_env.activeMembers[name]["class"], name, dColor, distance);
  end
  return rangeString
end

-- Init
aura_env.eventName = "AuroBM_Range";
aura_env.playerGUID = UnitGUID("player");
aura_env.playerRaidID = nil;
aura_env.rosterSize = nil;
aura_env.encounterIDs = {};
aura_env.encounterIDs[1799] = true;
aura_env.active = false;
aura_env.activeMembers = {};
aura_env.rangeNames = {};
aura_env.rangeNames["Onchy"] = true;
aura_env.rangeNames["Barely"] = true;
aura_env.rangeNames["Sensations"] = true;
aura_env.rangeNames["Panzerkriegz"] = true;
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
aura_env.distance = function(x1, y1, x2, y2)
  local dx = x2 - x1;
  local dy = y2 - y1;
  local distance = (dx * dx) + (dy * dy);
  distance = math.sqrt(distance);
  return distance;
end
