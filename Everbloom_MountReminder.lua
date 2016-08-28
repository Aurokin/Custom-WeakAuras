-- Trigger
function()
  aura_env.currentDistance = aura_env.distance(aura_env.zoneID, aura_env.unit, aura_env.x, aura_env.y);
  if (aura_env.currentDistance <= aura_env.radius) then
    aura_env.sent = true;
    return true;
  end
  return false;
end

-- Untrigger
function()
  aura_env.currentDistance = aura_env.distance(aura_env.zoneID, aura_env.unit, aura_env.x, aura_env.y);
  if (aura_env.currentDistance > aura_env.radius) then
    return true;
  end
  return false;
end

-- Text
"Hop In The Yak!"

-- Init
aura_env.falseValue = 99999;
aura_env.zoneID = 1279;
aura_env.lastZoneID = nil;
aura_env.sent = false;
aura_env.unit = "player";
aura_env.x = 503.3;
aura_env.y = 1426.2;
aura_env.radius = 10;
aura_env.lastCheck = GetTime();


aura_env.distance = function(mapID, unitName, startX, startY)
  local _, timeCheck = GetWorldElapsedTime(1);
  if (not timeCheck or timeCheck == 0) then
    aura_env.sent = false;
  end
  if (mapID and unitName) then
    local dx, dy, distance;
    local posX, posY, posZ, terrainMapID = UnitPosition(unitName);
    if (not aura_env.lastZoneID or aura_env.lastZoneID ~= terrainMapID or aura_env.lastCheck + 1 < GetTime()) then
      -- Last Zone Isn't Recorded = Player Just Logged In Or Reloaded
      -- Changed Zones
      aura_env.lastZoneID = terrainMapID;
      aura_env.sent = false;
    end
    aura_env.lastCheck = GetTime();
    if (terrainMapID ~= mapID or aura_env.sent == true) then
      return aura_env.falseValue;
    end
    dx = startX - posX;
    dy = startY - posY;
    distance = math.sqrt((dx * dx) + (dy * dy));
    return distance;
  end
  return aura_env.falseValue;
end
