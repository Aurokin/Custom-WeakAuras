-- Trigger [COMBAT_LOG_EVENT_UNFILTERED, ENCOUNTER_START, AuroBM_ImpBlinkTimer]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
  if (event == "ENCOUNTER_START" and aura_env.encounterIDs[encounterID] == true and aura_env.imps) then
    for guid in pairs(aura_env.imps) do
        aura_env.imps[guid] = nil;
    end
    print("Auro Imp Blink Timer - Loaded");
  end
  if (msg == "SPELL_CAST_START" and spellID == aura_env.spellID and aura_env.imps[srcGUID] ~= true) then
      local currentTime = GetTime();
      if (aura_env.impWipe == nil or aura_env.impWipe < currentTime) then
          aura_env.impWipe = currentTime + aura_env.impBlink;
          WeakAuras.ScanEvents(aura_env.gripReminderEvent);
      end
      -- Error occurs here due to issue with ScanEvents and the current nature of aura_env
      -- Fix should occur soon but if not, save aura_env pointer or ScanEvents after saving aura_env.imps
      aura_env.imps[srcGUID] = true;
      return true;
  elseif (msg == "UNIT_DIED" and destName == aura_env.impName) then
      aura_env.imps[destGUID] = nil;
      if not next(aura_env.imps) then
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
    local impBlinkString = "";
    if (aura_env.impWipe) then
        local currentTime = GetTime();
        local impBlinkTimer = aura_env.impWipe - currentTime;
        if (impBlinkTimer <= 0) then
            WeakAuras.ScanEvents(aura_env.eventName)
        end
        impBlinkString = string.format("%s - %.1f", "Imps", impBlinkTimer);
    end
    return impBlinkString;
end

-- Init
aura_env.impWipe = nil;
aura_env.impBlink = 12;
aura_env.impName = "Fel Imp";
aura_env.spellID = 181132;
aura_env.eventName = "AuroBM_ImpBlinkTimer";
aura_env.gripReminderEvent = "Auro_MannorothGripReminder";
aura_env.imps = {};
aura_env.encounterIDs = {};
aura_env.encounterIDs[1795] = true;
for guid in pairs(aura_env.imps) do
    aura_env.imps[guid] = nil;
end
