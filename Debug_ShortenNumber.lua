-- Auro: Shorten Number
-- Version 1.0.2

-- Trigger [Status -> Conditions -> Always active trigger]

-- Custom Text [Every Frame]
function()
  local number, marker = aura_env.shortenNumber(18232);
  return string.format("%.1f%s", number, marker);
end

-- Init
aura_env.shortenNumber = function(number)
  number = tonumber(number);
  local marker = "";
  if (number > 999 and number < 1000000) then
      marker = "k";
      number = number / 1000;
  elseif (number > 999999) then
      marker = "m";
      number = number / 1000000;
  end
  return number, marker;
end
