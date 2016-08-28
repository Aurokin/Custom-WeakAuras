aura_env.prefix = nil;
aura_env.members = nil;
aura_env.lastUpdate = nil;
aura_env.interval = 1;
aura_env.string = "";
aura_env.raid = {};

aura_env.wipeTable = function(t)
  for k,v in pairs(t) do
    t[k] = nil;
  end
  return {};
end

aura_env.setPrefix = function()
  if IsInRaid() then
    aura_env.prefix = "raid";
  else
    aura_env.prefix = "party";
  end
end

aura_env.initPlayer = function(unit)
  local name = GetUnitName(unit, false);
  local class = "ffffffff";
  local classColorObj = RAID_CLASS_COLORS[select(2, UnitClass(unit))];
  if (classColorObj ~= nil) then
    class = classColorObj.colorStr;
  end
  local corruption = select(14, UnitAlternatePowerInfo(unit));
  return aura_env.playerObj.new(corruption, class, name, unit);
end

aura_env.initRaid = function()
  aura_env.raid = aura_env.wipeTable(aura_env.raid);
  aura_env.members = GetNumGroupMembers();
  aura_env.setPrefix();
  for i = 1, aura_env.members - 1 do
    table.insert(aura_env.raid, aura_env.initPlayer(aura_env.prefix .. i));
  end
  table.insert(aura_env.raid, aura_env.initPlayer('player'));
end

aura_env.processCorruption = function()
  if (next(aura_env.raid) == nil) then
    aura_env.debug = WeakAuras.IsOptionsOpen();
    aura_env.initRaid();
  end
  local currentTime = GetTime();
  if (aura_env.lastUpdate == nil) then
    aura_env.lastUpdate = currentTime - 2;
  end
  local timeSinceUpdate =  currentTime - aura_env.lastUpdate;
  if (timeSinceUpdate > aura_env.interval) then
    aura_env.debug = WeakAuras.IsOptionsOpen();
    aura_env.string = "";
    for k, p in pairs(aura_env.raid) do
      p:updateCorruption();
    end
    table.sort(aura_env.raid, function(a,b) return a:getCorruption() > b:getCorruption() end);
    for k, p in pairs(aura_env.raid) do
      aura_env.string = aura_env.string .. p:getString();
    end
    aura_env.lastUpdate = currentTime;
  end
  return aura_env.string;
end

-- Define Players
aura_env.playerObj = {};
aura_env.playerObj.__index = aura_env.playerObj;

setmetatable(aura_env.playerObj, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
});

function aura_env.playerObj.new(corruption, class, name, unit)
  local self = setmetatable({}, aura_env.playerObj);
  self.corruption = corruption;
  self.class = class;
  self.name = name;
  self.unit = unit;
  return self;
end

function aura_env.playerObj:setCorruption(corruption)
  self.corruption = corruption;
end

function aura_env.playerObj:getCorruption()
  if (self.corruption ~= nil) then
    return self.corruption;
  else
    return -1;
  end
end

function aura_env.playerObj:setClass(class)
  self.class = class;
end

function aura_env.playerObj:getClass()
  return self.class;
end

function aura_env.playerObj:setName(name)
  self.name = name;
end

function aura_env.playerObj:getName()
  return self.name;
end

function aura_env.playerObj:setUnit(unit)
  self.unit = unit;
end

function aura_env.playerObj:getUnit()
  return self.unit;
end

function aura_env.playerObj:getString()
  if (self:getCorruption() > 0 and self:getClass() ~= nil and self:getName() ~= nil) then
    return string.format("|c%s%s|r - %d\n", self:getClass(), self:getName(), self:getCorruption());
  else
    return "";
  end
end

function aura_env.playerObj:updateCorruption()
  if (debug == false) then
    self:setCorruption(select(14, UnitAlternatePowerInfo(self:getUnit())));
  else
    self:setCorruption(math.random(100));
  end
end
