-- Auro: Early Pull
-- Version: 1.4.2

-- Trigger [COMBAT_LOG_EVENT_UNFILTERED, CHAT_MSG_ADDON]
function(event, encounterID, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName, flag1, flag2)
  if (event == "CHAT_MSG_ADDON" and aura_env.addonMsgs[encounterID]) then
    if (aura_env.addonMsgs[encounterID]) then
      local subEvent = string.sub(msg, 1, aura_env.addonMsgs[encounterID]["stringLen"]);
      -- print(subEvent);
      if (subEvent ~= aura_env.addonMsgs[encounterID]["subEvent"]) then
        return false;
      end
      if (aura_env.debug == true) then
        print(encounterID .. " Pull Detected");
      end
    end
    if (IsInRaid() == false) then return false; end
    aura_env.pulled = false;
    aura_env.wipeTable(aura_env.raidRoster);
    aura_env.fillRaid(aura_env.raidRoster);
  end
  if (aura_env.pulled == false) then
    if (event == "COMBAT_LOG_EVENT_UNFILTERED" and aura_env.combatMsgs[msg] and srcName ~= destName and destName and srcName and spellName and not aura_env.spellExclusion[spellName]) then
      if (aura_env.isBoss(srcName) == true) then return false; end
      if (aura_env.isRaidToRaid(srcName, destName, aura_env.raidRoster) == true) then return false; end
      if (msg == "SPELL_AURA_APPLIED" and flag2 == "BUFF") then return false; end
      if (spellName == -1) then
        spellName = "Melee Swing";
      end
      if (aura_env.debug == true) then
        print(spellName);
      end
      local pull = string.format("%s pulled with %s", srcName or "?", spellName or "?");
      if (aura_env.reporter == true) then
        SendChatMessage(pull, "RAID");
      else
        print(pull);
      end
      aura_env.pulled = true;
    end
  end
end


-- Init
aura_env.pulled = true;
aura_env.reporter = false;
aura_env.debug = false;
aura_env.lastPull = nil;
aura_env.lastPullSafeZone = 15;
aura_env.raidRoster = {};
aura_env.bosses = {};
aura_env.combatMsgs = {};
aura_env.combatMsgs["SPELL_DAMAGE"] = true;
aura_env.combatMsgs["SPELL_PERIODIC_DAMAGE"] = true;
aura_env.combatMsgs["SPELL_MISSED"] = true;
aura_env.combatMsgs["RANGE_DAMAGE"] = true;
aura_env.combatMsgs["SWING_DAMAGE"] = true;
aura_env.combatMsgs["SWING_DAMAGE_LANDED"] = true;
aura_env.combatMsgs["SWING_MISSED"] = true;
aura_env.combatMsgs["SPELL_AURA_APPLIED"] = true;
aura_env.addonMsgs = {};
aura_env.addonMsgs["BigWigs"] = {};
aura_env.addonMsgs["BigWigs"]["subEvent"] = "T:BWPull";
aura_env.addonMsgs["BigWigs"]["stringLen"] = 8;
aura_env.addonMsgs["D4"] = {};
aura_env.addonMsgs["D4"]["subEvent"] = "PT";
aura_env.addonMsgs["D4"]["stringLen"] = 2;
aura_env.spellExclusion = {};
aura_env.spellExclusion["Weakened Soul"] = true;

aura_env.isBoss = function(name)
  for i = 1, 10 do
    local bossName = UnitName("boss" .. i);
    if bossName then
      aura_env.bosses[bossName] = true;
      if (bossName == name) then
        return true;
      end
    else
      break;
    end
  end
  return false;
end

aura_env.fillRaid = function(table)
  local rosterSize = GetNumGroupMembers();
  if rosterSize == 1 then return false; end
  for i = 1, rosterSize do
    local name = UnitName("raid" .. i);
    table[name] = true;
  end
end

aura_env.isRaidToRaid = function(srcName, destName, table)
  if (table[srcName] and table[destName]) then
    return true;
  else
    return false;
  end
end

aura_env.wipeTable = function(table)
  -- Clear Table
  for guid in pairs(table) do
      table[guid] = nil;
  end
end
