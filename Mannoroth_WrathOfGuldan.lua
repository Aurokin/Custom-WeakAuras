-- Auro: Mannoroth - Wrath of Gul'Dan
-- Version: 1.0.0

-- Trigger [COMBAT_LOG_EVENT_UNFILTERED, ENCOUNTER_START, AuroBM_WrathOfGuldan]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
  if (event == "ENCOUNTER_START" and aura_env.encounterIDs[encounterID] == true) then
    aura_env.wipeTable(aura_env.wraths);
    print("Auro: Wrath of Gul'Dan - Loaded");
  end
  if (msg == "SPELL_AURA_APPLIED" and spellID == aura_env.spellID) then
    aura_env.wraths[destGUID] = {};
    aura_env.wraths[destGUID]["name"] = string.gsub(destName, "%-[^|]+", "");
    aura_env.wraths[destGUID]["stacks"] = 40;
    return true;
  elseif (msg == "SPELL_AURA_REMOVED_DOSE" and spellID == aura_env.spellID and aura_env.wraths[destGUID]) then
    aura_env.wraths[destGUID]["stacks"] = aura_env.wraths[destGUID]["stacks"] - 1;
    if (aura_env.wraths[destGUID]["stacks"] <= 0) then
      aura_env.wipeSection(aura_env.wraths, destGUID);
    end
    if not next(aura_env.wraths) then
      WeakAuras.ScanEvents(aura_env.eventName);
    end
  elseif (msg == "SPELL_AURA_REMOVED" and spellID == aura_env.spellID and aura_env.wraths[destGUID]) then
    aura_env.wipeSection(aura_env.wraths, destGUID);
    if not next(aura_env.wraths) then
      WeakAuras.ScanEvents(aura_env.eventName);
    end
  elseif (msg == "UNIT_DIED" and aura_env.wraths[destGUID]) then
    aura_env.wipeSection(aura_env.wraths, destGUID);
    if not next(aura_env.wraths) then
      WeakAuras.ScanEvents(aura_env.eventName);
    end
  end
end

-- Untrigger
function(event)
  if (event == aura_env.eventName) then
    return true;
  end
end

-- Text [Every Frame]
function()
  local WrathsString = "";
  if not aura_env.wraths then
    WeakAuras.ScanEvents(aura_env.eventName);
    return WrathsString;
  end
  for guid in pairs(aura_env.wraths) do
    WrathsString = WrathsString .. string.format("%s - %d\n", aura_env.wraths[guid]["name"], aura_env.wraths[guid]["stacks"]);
  end
  return WrathsString;
end

-- Init
aura_env.spellID = 186362;
aura_env.eventName = "AuroBM_WrathOfGuldan";
aura_env.wraths = {};
aura_env.encounterIDs = {};
aura_env.encounterIDs[1795] = true;
aura_env.wipeTable = function(table)
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
