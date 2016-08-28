-- Auro: Debug - Event Print
-- Version: 1.0.0

-- Trigger [CHAT_MSG_ADDON]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
  if (event == "CHAT_MSG_ADDON") then
    print(encounterID .. " - " .. msg);
  end
end
