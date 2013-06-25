require 'ai'

baseEnemy = {}
baseEnemy.__index = baseEnemy

function baseEnemy:init(level)
  self.status = "none"
  self.destroyed = false
  self.level = level
  self.talk = ""
  self.meleeDamage = 0
  self.health = 100
end

function baseEnemy:update(dt)
end

function baseEnemy:draw(dt)
end

function baseEnemy:playerCollision()
  if self.meleeDamage > 0 then
    painSFX:stop()
    love.audio.play(painSFX)
    player.health = player.health - self.meleeDamage
    if player.health < 0 then
      player.health = 0
    end
  end
end

RockEnemy = {}
RockEnemy.__index = RockEnemy
setmetatable(RockEnemy, baseEnemy)

function RockEnemy:init(level, x, y)
  baseEnemy.init(self, level)
  self.meleeDamage = 15
  self.body = love.physics.newBody(level.world, x, y, "dynamic")
  self.shape = love.physics.newCircleShape(20)
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)
end

function RockEnemy:new(level, x, y)
  e = setmetatable({}, RockEnemy)
  e:init(level, x, y)
  return e
end

function RockEnemy:update(dt)
  if self.health <= 0 then
    self:destroy()
    return
  end
  local fx = player.body:getX() - self.body:getX()
  if fx * fx < 150 * 150 then
    self.status = "attacking"
    self.body:applyForce(fx, 0)
  else
    self.status = "waiting"
    local vx, vy = self.body:getLinearVelocity()
    self.body:applyForce(-vx/2, vy)
  end
end

function RockEnemy:draw(dt)
  if not self.destroyed then
    love.graphics.setColor(100, 100, 100)
    local x, y = level:calcOffsetPoints(self.body:getX(), self.body:getY())
    love.graphics.circle("fill", x, y, self.shape:getRadius())
    if debugDisplay and debugDisplays[5] then
      love.graphics.setColor(0, 0, 0)
      love.graphics.printf( self.status, x, y - 35, 0, "center")
      love.graphics.setColor(255, 0, 0)
      love.graphics.line(x - 150, y - 50, x - 150, y + 50)
      love.graphics.line(x + 150, y - 50, x + 150, y + 50)
    end
  end
end

function RockEnemy:destroy()
  if not self.destroyed then
    self.fixture:destroy()
    self.body:destroy()
    self.destroyed = true
  end
end

-------------------------------------------------------------------------------
--Smart Enemy
-------------------------------------------------------------------------------
SmartEnemy = {}
SmartEnemy.__index = SmartEnemy
setmetatable(SmartEnemy, RockEnemy)

function SmartEnemy:init(level, x, y)
  RockEnemy.init(self, level, x, y)
  self.meleeDamage = 0
  self.AI = AI:new()
  self.AI.attackState = AIState:new(self.AI, self)
  function self.AI.attackState:startState()
    self.enemy.status = "attacking"
    self.timer = .5
    local vx, vy = self.enemy.body:getLinearVelocity()
    self.enemy.body:applyForce(-vx/10,0)
  end
  function self.AI.attackState:update(dt)
    local fx = player.body:getX() - self.enemy.body:getX()
    if fx * fx < 200 * 200 then
      if fx > 0 then
        self.enemy.direction = 1
        self.enemy.body:applyForce((fx - 100)/10 * 100 - fx, 0)
      else
        self.enemy.direction = -1
        self.enemy.body:applyForce((fx + 100)/10 * 100 - fx, 0)
      end
      self.timer = self.timer - dt
      if self.timer <= 0 then
        shoot(self.enemy)
        self.timer = self.timer + 2
      end
    else
      self.AI:changeState(self.AI.waitState)
    end
  end
  self.AI.attackState:startState()
  self.AI.currentState = self.AI.attackState
  self.AI.waitState = AIState:new(self.AI, self)
  function self.AI.waitState:startState()
    self.enemy.status = "waiting"
    self.timer = 3
  end
  function self.AI.waitState:update(dt)
    local fx = player.body:getX() - self.enemy.body:getX()
    if fx * fx < 200 * 200 then
      self.AI:changeState(self.AI.attackState)
    else
      self.timer = self.timer - dt
      if self.timer <= 0 then
        self.AI:changeState(self.AI.wonderState)
      end
    end
  end
  self.AI.wonderState = AIState:new(self.AI, self)
  function self.AI.wonderState:startState()
    self.enemy.status = "wondering"
  end
  function self.AI.wonderState:update(dt)
    local fx = player.body:getX() - self.enemy.body:getX()
    if fx * fx < 200 * 200 then
      self.AI:changeState(self.AI.attackState)
    else
      self.enemy.body:applyForce((math.random()*2 - 1) * 800, 0)
      local vx, vy = self.enemy.body:getLinearVelocity()
      if vx > 400 then
        self.enemy.body:setLinearVelocity(400, vx)
      elseif vx < -400 then
        self.enemy.body:setLinearVelocity(-400, vx)
      end
    end
  end
end

function SmartEnemy:new(level, x, y)
  e = setmetatable({}, SmartEnemy)
  e:init(level, x, y)
  return e
end

function SmartEnemy:update(dt)
  if self.health <= 0 then
    self:destroy()
    return
  end
  self.AI:update(dt)
end

function SmartEnemy:draw(dt)
  if not self.destroyed then
    love.graphics.setColor(0, 255, 0)
    local x, y = level:calcOffsetPoints(self.body:getX(), self.body:getY())
    love.graphics.circle("fill", x, y, self.shape:getRadius())
    if debugDisplay and debugDisplays[5] then
      love.graphics.setColor(0, 0, 0)
      love.graphics.printf( self.status, x, y - 35, 0, "center")
      love.graphics.setColor(255, 0, 0)
      love.graphics.line(x - 200, y - 50, x - 200, y + 50)
      love.graphics.line(x + 200, y - 50, x + 200, y + 50)
    end
  end
end
