projectiles = {}
projectiles.__index = projectiles

function projectiles:init(level)
  self.level = level
  self.list = {}
end

function projectiles:create(x, y, vx, vy, radius, damage)
  self.list[#self.list + 1] = projectile:new(self.level, #self.list + 1, x, y, vx, vy, radius, damage)
end

function projectiles:update(dt)
  for key, p in pairs(self.list) do
    p:update(dt)
  end
end

function projectiles:draw(dt)
  love.graphics.setColor(0, 0, 0)
  for key, p in pairs(self.list) do
    p:draw(dt)
  end
end

projectile = {}
projectile.__index = projectile

function projectile:new(level, index, x, y, vx, vy, radius, damage)
  p = setmetatable({}, projectile)
  p.destroyed = false
  p.timer = 1
  p.level = level
  p.damage = damage
  p.index = index
  p.body = love.physics.newBody(level.world, x, y, "dynamic")
  p.shape = love.physics.newCircleShape(radius)
  p.fixture = love.physics.newFixture(p.body, p.shape, 1)
  p.body:setBullet(true)
  p.body:setGravityScale(0)
  p.body:setLinearVelocity(vx, vy)
  return p
end

function projectile:update(dt)
  self.timer = self.timer - dt
  if self.timer <= 0 then
    self:destroy()
  end
end

function projectile:draw(dt)
  if not self.destroyed then
    local x, y = self.level:calcOffsetPoints(self.body:getX(), self.body:getY())
    love.graphics.circle("fill", x, y, self.shape:getRadius())
  end
end

function projectile:destroy()
  if self.index ~= #projectiles.list then
    projectiles.list[#projectiles.list].index = self.index
    projectiles.list[self.index] = projectiles.list[#projectiles.list]
    projectiles.list[#projectiles.list] = nil
  end
  if not self.destroyed then
    self.fixture:destroy()
    self.body:destroy()
    self.destroyed = true
  end
end

function projectile:playerCollision()
  player.health = player.health - self.damage
  if player.health < 0 then
    player.health = 0
  end
  damageSFX:stop()
  love.audio.play(damageSFX)
  self:destroy()
end

function projectile:enemyCollision(enemy)
  enemy.health = enemy.health - self.damage
  if enemy.health < 0 then
    enemy.health = 0
  end
  damageSFX:stop()
  love.audio.play(damageSFX)
  self:destroy()
end

function projectile:Collision(other, coll)
  self:destroy()
end