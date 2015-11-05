-- Auro: Archimonde - Mark of the Legion
-- Version: 0.0.1
-- Load: EncounterID[1799]
-- Assumes BigWigs marking

-- Trigger [ENCOUNTER_START, COMBAT_LOG_EVENT_UNFILTERED, AuroBM_MarkOfTheLegion]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
  if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
    if (msg == "SPELL_AURA_APPLIED" and aura_env.markOfTheLegionSpellID == spellID and destGUID == aura_env.playerGUID) then
      return true;
    elseif ((msg == "SPELL_AURA_REMOVED" and aura_env.markOfTheLegionSpellID == spellID and destGUID == aura_env.playerGUID) or (msg == "UNIT_DIED" and destGUID == aura_env.playerGUID)) then
      WeakAuras.ScanEvents(aura_env.eventName);
    end
  elseif (event == "ENCOUNTER_START") then
    aura_env.playerGUID = UnitGUID("player");
    aura_env.mark = nil;
    aura_env.expires = nil;
    print("Auro: Mark of the Legion - Loaded");
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
  return aura_env.markString();
end

-- Init
aura_env.eventName = "AuroBM_MarkOfTheLegion";
aura_env.playerGUID = UnitGUID("player");
aura_env.markOfTheLegionSpellID = 187050;
aura_env.markerLocation = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_"
aura_env.mark = nil;
aura_env.expires = nil;
aura_env.mark_text = {};
aura_env.mark_text[1] = "MELEE LEFT";
aura_env.mark_text[2] = "MELEE RIGHT";
aura_env.mark_text[3] = "RANGED LEFT";
aura_env.mark_text[4] = "RANGED RIGHT";
aura_env.markString = function()
  local up;
  local currentTime = GetTime();
  up, _, _, _, _, _, aura_env.expires = UnitDebuff("player", "Mark of the Legion")
  aura_env.mark = GetRaidTargetIndex("player");
  if (up and aura_env.expires and aura_env.mark and currentTime) then
    if (aura_env.mark_text[aura_env.mark]) then
      return string.format("|T%s%d:0|t%s|T%s%d:0|t\n%.1f", aura_env.markerLocation, aura_env.mark, aura_env.mark_text[aura_env.mark], aura_env.markerLocation, aura_env.mark, aura_env.expires - currentTime);
    end
  end
  if WeakAuras.IsOptionsOpen() then
        return string.format("|T%s%d:0|t%s|T%s%d:0|t\n%.1f", aura_env.markerLocation, 1, aura_env.mark_text[1], aura_env.markerLocation, 1, 6.9);
    end
  return "";
end
