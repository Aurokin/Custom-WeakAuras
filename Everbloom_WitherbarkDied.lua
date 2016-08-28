-- Trigger [COMBAT_LOG_EVENT_UNFILTERED]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
    if (msg == "UNIT_DIED" and destName == "Witherbark") then
      return true;
    end
end
