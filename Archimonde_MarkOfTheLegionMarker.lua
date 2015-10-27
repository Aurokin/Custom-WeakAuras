-- Auro: Archimonde - Mark of the Legion Marker
-- Version: 0.0.1
-- Load: Zone[Hellfire Citadel], EncounterID[1799]
-- WARNING UNTESTED

-- Trigger [ENCOUNTER_START, COMBAT_LOG_EVENT_UNFILTERED, AuroBM_MarkOfTheLegionMarker]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
  if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
    if (msg == "SPELL_AURA_APPLIED" and aura_env.markOfTheLegionSpellID == spellID and aura_env.markOrder[aura_env.mark]) then
      aura_env.markedPlayers[destGUID] = aura_env.markOrder[aura_env.mark];
      if (markingPlayer == true) then
        SetRaidTarget("raid" .. aura_env.rosterIDs[destGUID], aura_env.markOrder[aura_env.mark]);
      end
      aura_env.mark = aura_env.mark + 1;
      return true;
    elseif ((msg == "SPELL_AURA_REMOVED" and aura_env.markOfTheLegionSpellID == spellID and aura_env.markedPlayers[destGUID]) or (msg == "UNIT_DIED" and aura_env.markedPlayers[destGUID])) then
      if (markingPlayer == true) then
        SetRaidTarget("raid" .. aura_env.rosterIDs[destGUID], 0);
      end
      aura_env.markedPlayers[destGUID] = nil;
      if not next(aura_env.markedPlayers) then
        WeakAuras.ScanEvents(aura_env.eventName);
      end
    elseif (msg == "SPELL_CAST_START" and aura_env.markOfTheLegionSpellID == spellID) then
      aura_env.mark = 1;
      aura_env.wipeTable(aura_env.markedPlayers);
    end
  elseif (event == "ENCOUNTER_START") then
    aura_env.mark = 1;
    aura_env.wipeTable(aura_env.markedPlayers);
    aura_env.wipeTable(aura_env.rosterIDs);
    aura_env.rosterSize = GetNumGroupMembers();
    for i = 1, aura_env.rosterSize do
      local guid = UnitGUID("raid" .. i);
      aura_env.rosterIDs[guid] = i;
    end
    print("Auro: Mark of the Legion Marker - Loaded");
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
  if (aura_env.display == true) then
    return aura_env.markOrder();
  end
  return "";
end

-- Init
aura_env.display = true;
aura_env.markingPlayer = false;
aura_env.eventName = "AuroBM_MarkOfTheLegionMarker";
aura_env.markOfTheLegionSpellID = 187050;
aura_env.markerLocation = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_"
aura_env.mark = nil;
aura_env.rosterSize = nil;
aura_env.markedPlayers = {};
aura_env.rosterIDs = {};
aura_env.markOrder = {};
aura_env.markOrder[1] = 3;
aura_env.markOrder[2] = 4;
aura_env.markOrder[3] = 1;
aura_env.markOrder[4] = 2;
aura_env.wipeTable = function(table)
  -- Clear Table
  for guid in pairs(table) do
      table[guid] = nil;
  end
end
aura_env.markerString = function(markerLocation, mark, color, name, expires)
  return string.format("|T%s%d:32|t |c%s%s|r - %.1f\n", markerLocation, mark, color, name, expires);
end
aura_env.markOrder = function()
  local markOrderString = "";
  local currentTime = GetTime();
  for guid in pairs (aura_env.markedPlayers) do
    local up, _, _, _, _, _, expires = UnitDebuff("raid" .. aura_env.rosterIDs[guid], "Mark of the Legion");
    local name = UnitName("raid" .. aura_env.rosterIDs[guid]);
    local _, class = UnitClass("raid" .. aura_env.rosterIDs[guid]);
    if (up and expires and name) then
      markOrderString = markOrderString .. aura_env.markerString(aura_env.markerLocation, aura_env.markedPlayers[guid], RAID_CLASS_COLORS[class].colorStr, name, expires - currentTime);
    end
  end
  if WeakAuras.IsOptionsOpen() then
    markOrderString = markOrderString .. aura_env.markerString(aura_env.markerLocation, 3, RAID_CLASS_COLORS["DRUID"].colorStr, "Auro", 5.1);
    markOrderString = markOrderString .. aura_env.markerString(aura_env.markerLocation, 4, RAID_CLASS_COLORS["SHAMAN"].colorStr, "Sensations", 8.2);
    markOrderString = markOrderString .. aura_env.markerString(aura_env.markerLocation, 1, RAID_CLASS_COLORS["ROGUE"].colorStr, "Nightshade", 10.3);
    markOrderString = markOrderString .. aura_env.markerString(aura_env.markerLocation, 2, RAID_CLASS_COLORS["HUNTER"].colorStr, "Leethunter", 15);
  end
  return markOrderString
end
