-- Load Only In M+
-- Trigger [ENCOUNTER_START, ENCOUNTER_END]
function(event, ...)
  if (event == "ENCOUNTER_START") then
    aura_env.text = aura_env.eStart;
    return true;
  elseif (event == "ENCOUNTER_END") then
    aura_env.text = aura_env.eEnd;
    return true;
  end
end

-- Untrigger [3s]

-- Custom Text [Every Frame]
function()
  if (WeakAuras.IsOptionsOpen()) then
    return aura_env.eStart;
  elseif (aura_env.text ~= nil) then
    return aura_env.text;
  end
  return "";
end

-- Init
aura_env.text = "";
aura_env.eStart = "Single Target Trinket Reminder!!!";
aura_env.eEnd = "Swap To AOE Trinkets!!!";

-- OnHide
aura_env.text = "";
