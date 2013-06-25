----------------------------------------------------------------
--Level
----------------------------------------------------------------
--A Level is an object that contains all elements of a game level
Level = {}
Level.__index = Level

--Constructor
function Level:new()
  local level = setmetatable({}, self)
  level.elements = {}
  level.enemies = {}
  level.player = {spawn = {x=0, y=0}}
  level.world = love.physics.newWorld(0, 9.81*64, true)
  level.position = {x=0,y=0}
  return level
end

function Level:lookAt(x, y)
  self.position.x = 325 - x
  self.position.y = -y + 325
end

--Positional Offset for basic scrolling
function Level:calcOffsetPoint(x, y)
  return x + self.position.x, y + self.position.y
end

function Level:calcOffsetPoints(...)
  points = {}
  for i = 1, #arg - 1, 2 do
    points[#points + 1], points[#points + 2] = self:calcOffsetPoint(arg[i], arg[i+1])
  end
  return unpack(points)
end

--Where the player will spawn
function Level:setPlayerSpawn(x, y)
  self.player.spawn.x = x
  self.player.spawn.y = y
end

function Level:getPlayerSpawn()
  return self.player.spawn.x, self.player.spawn.y
end

--Add Element
function Level:addElement(element)
  self.elements[#self.elements + 1] = element
end

--Add Enemy
function Level:addEnemy(enemy)
  self.enemies[#self.enemies + 1] = enemy
end

--Update the Level
function Level:update(dt)
  self.world:update(dt)
  for key, enemy in pairs(self.enemies) do 
    enemy:update(dt)
  end
end

--Draw the Level
function Level:draw(dt)
  for key, element in pairs(self.elements) do 
    element:draw(dt)
  end
  for key, enemy in pairs(self.enemies) do 
    enemy:draw(dt)
  end
end

-----------------------------------------------------------------------
--Level Element
-----------------------------------------------------------------------
--Level Element - Base Metatable for all Level Elements
LevelElement = {}
LevelElement.__index = LevelElement

--Initializer for subclassing(No Metatables)
function LevelElement:init(level)
  self.level = level
  self.color = {}
  self:setColor(0,0,0,255)
end

--Constructor
function LevelElement:new(level)
  local e = setmetatable({}, self)
  e:init(Level)
end

--Set Element Color
function LevelElement:setColor(red, green, blue, alpha)
  self.color.red = red
  self.color.green = green
  self.color.blue = blue
  self.color.alpha = alpha
end

--Get Element Color
function LevelElement:getColor()
  return self.color.red, self.color.green, self.color.blue, self.color.alpha
end

---------------------------------------------------------------------------
--Edge Element
---------------------------------------------------------------------------
EdgeElement = {}
EdgeElement.__index = EdgeElement
setmetatable(EdgeElement, LevelElement)

function EdgeElement:build(x1, y1, x2, y2)
  local center = {}
  center.x = (x1 + x2)/2
  center.y = (y1 + y2)/2
  self.body = love.physics.newBody(self.level.world, center.x, center.y)
  self.shape = love.physics.newEdgeShape(x1 - center.x, y1 - center.y, x2 - center.x, y2 - center.y)
  self.fixture = love.physics.newFixture(self.body, self.shape)
end

function EdgeElement:new(level, x1, y1, x2, y2, red, green, blue, alpha)
  local edge = setmetatable({}, self)
  edge:init(level)
  edge:build(x1, y1, x2, y2)
  edge:setColor(red, green, blue, alpha)
  return edge
end

function EdgeElement:draw(dt)
  love.graphics.setColor(self:getColor())
  love.graphics.line(self.level:calcOffsetPoints(self.body:getWorldPoints(self.shape:getPoints())))
end

---------------------------------------------------------------------
--Block Element
---------------------------------------------------------------------
BlockElement = {}
BlockElement.__index = BlockElement
setmetatable(BlockElement, LevelElement)

function BlockElement:build(x1, y1, width, height, static)
  local center = {}
  center.x = x1 + width/2
  center.y = y1 + height/2
  if static then
    bodyType = "static"
  else
    bodyType = "dynamic"
  end
  self.body = love.physics.newBody(self.level.world, center.x, center.y, bodyType)
  self.shape = love.physics.newRectangleShape(0, 0, width, height)
  self.fixture = love.physics.newFixture(self.body, self.shape)
end

function BlockElement:new(level, x1, y1, width, height, red, green, blue, alpha, static)
  local block = setmetatable({}, self)
  block:init(level)
  block:build(x1, y1, width, height, static)
  block:setColor(red, green, blue, alpha)
  return block
end

function BlockElement:draw(dt)
  love.graphics.setColor(self:getColor())
  love.graphics.polygon("fill", self.level:calcOffsetPoints(self.body:getWorldPoints(self.shape:getPoints())))
end