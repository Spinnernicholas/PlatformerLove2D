function round(x)
  if x >= 0 then
    return math.floor (x + 0.5)
  end  -- if positive

  return math.ceil (x - 0.5)
end -- function round

require 'projectiles'
require 'enemies'
require 'tools'
require 'music'
require 'sfx'

function love.load()
  --Debug Flags
  cameraControls = false
  debugDisplay = false
  debugDisplays = {false, false, false, false, false, false, false, false, false, false, false, false}
  
  --Game Constants
  playerMaxSpeed = 800
  
  --Game Status
  gameover = false
  startTime = love.timer.getTime()
  
  love.physics.setMeter(64) --the height of a meter our worlds will be 64px

  level = require 'level' -- table to hold all our physical level
  projectiles:init(level)
  
  level.world:setCallbacks(beginContact, endContact)
  
  --initial graphics setup
  love.graphics.setBackgroundColor(104, 136, 248) --set the background color to a nice blue
  love.graphics.setMode(650, 650, false, true, 0) --set the window dimensions to 650 by 650
  
   --let's create a player
  player = {}
  player.direction = -1
  local px,py = level:getPlayerSpawn()
  player.health = 100
  player.body = love.physics.newBody(level.world, px, py, "dynamic")
  player.shape = love.physics.newCircleShape(20)
  player.fixture = love.physics.newFixture(player.body, player.shape, 1)
  player.grounded = false --Is Player on the ground
  
  player.collision = function(coll)
    local x,y = coll:getNormal()
    if y < 0 then
      player.grounded = true
    end
  end
  
  --Music
  love.audio.play(music)
end

function love.update(dt)
  level:update(dt)
  projectiles:update(dt)
  
  if not cameraControls then
    level:lookAt(player.body:getX(), player.body:getY())
  end
  
  --here we are going to create some keyboard events
  local pxv, pyv = player.body:getLinearVelocity()
  if love.keyboard.isDown("right") and pxv < playerMaxSpeed then --press the right arrow key to push the player to the right
    player.direction = 1
    player.body:applyForce(400, 0)
  elseif love.keyboard.isDown("left") and pxv > -playerMaxSpeed then --press the left arrow key to push the player to the left
    player.direction = -1
    player.body:applyForce(-400, 0)
  elseif pxv * pxv < 6400 then
    player.body:setLinearVelocity(0, pyv)
  elseif player.grounded then
    player.body:applyForce(-pxv*3/5, 0)
  end
  
  if player.health <= 0 then
    gameover = true
  end
  
  --cameraControls
  local cameraSpeed = 100
  
  if love.keyboard.isDown("lshift") then
    cameraSpeed = 500
  end
  
  if cameraControls then
    if love.keyboard.isDown("a") then
      level.position.x = level.position.x + cameraSpeed * dt
    elseif love.keyboard.isDown("d") then
      level.position.x = level.position.x - cameraSpeed * dt
    end
    
    if love.keyboard.isDown("w") then
      level.position.y = level.position.y + cameraSpeed * dt
    elseif love.keyboard.isDown("s") then
      level.position.y = level.position.y - cameraSpeed * dt
    end
  end
end

function love.draw(dt)
  --Draw Player
  love.graphics.setColor(193, 47, 14) --set the drawing color to red for the player
  local px, py = level:calcOffsetPoints(player.body:getX(), player.body:getY())
  love.graphics.circle("fill", px, py, player.shape:getRadius())
  
  level:draw(dt)
  projectiles:draw(dt)
  
  DisplayHUD()
  --Debug Display
  if debugDisplay then
    DisplayDebugInfo()
  end
end

function beginContact(a, b, coll)
  if a == player.fixture then
    player.collision(coll)
    for key, enemy in pairs(level.enemies) do
      if enemy.fixture == b then
        enemy:playerCollision()
      end
    end
  elseif b == player.fixture then
    player.collision(coll)
    for key, enemy in pairs(level.enemies) do
      if enemy.fixture == a then
        enemy:playerCollision()
      end
    end
  end
  
  for key, p in pairs(projectiles.list) do
    if p.fixture == b then
      if player.fixture == a then
        p:playerCollision()
      else
        for key2, enemy in pairs(level.enemies) do
          if enemy.fixture == a then
            p:enemyCollision(enemy)
          end
        end
      end
    elseif p.fixture == a then
      if player.fixture == b then
        p:playerCollision()
      else
        for key2, enemy in pairs(level.enemies) do
          if enemy.fixture == b then
            p:enemyCollision(enemy)
          end
        end
      end
    end
  end
end

function endContact(a, b, coll)
end

function love.keypressed(key)   -- we do not need the unicode, so we can leave it out
  if key == "escape" then
    love.event.push("quit")   -- actually causes the app to quit
  elseif key == "up" and player.grounded then
    player.body:applyLinearImpulse(0, -150)
    player.grounded = false
  elseif key == " " then
    shoot(player)
  elseif key == "m" then
    if playMusic then
      music:stop()
      playMusic = false
    else
      music:play()
      playMusic = true
    end
  elseif key == "1" then
    level:addEnemy(RockEnemy:new(level, player.body:getX(), -350))
  elseif key == "2" then
    level:addEnemy(SmartEnemy:new(level, player.body:getX(), -350))
  elseif key == "c" then
    cameraControls = not cameraControls
  elseif key == "v" then
    debugDisplay = not debugDisplay
  elseif key == "f1" then
    debugDisplays[1] = not debugDisplays[1]
  elseif key == "f2" then
    debugDisplays[2] = not debugDisplays[2]
  elseif key == "f3" then
    debugDisplays[3] = not debugDisplays[3]
  elseif key == "f4" then
    debugDisplays[4] = not debugDisplays[4]
  elseif key == "f5" then
    debugDisplays[5] = not debugDisplays[5]
  elseif key == "f6" then
    debugDisplays[6] = not debugDisplays[6]
  elseif key == "f7" then
    debugDisplays[7] = not debugDisplays[7]
  elseif key == "f8" then
    debugDisplays[8] = not debugDisplays[8]
  elseif key == "f9" then
    debugDisplays[9] = not debugDisplays[9]
  elseif key == "f10" then
    debugDisplays[10] = not debugDisplays[10]
  elseif key == "f11" then
    debugDisplays[11] = not debugDisplays[11]
  elseif key == "f12" then
    debugDisplays[12] = not debugDisplays[12]
  end
end

function DisplayDebugInfo()
      local debugText = ""
    
    if debugDisplays[1] then
      debugText = debugText .. "Player Grounded: " .. tostring(player.grounded) .. "\n" ..
                               "Player Health: " .. player.health .. "\n"
    end
    if debugDisplays[2] then
      debugText = debugText .. "Player Position: (" .. round(player.body:getX()) .. "," .. round(player.body:getY()) .. ")\n" ..
                               "Level Position: (" .. round(level.position.x) .. "," .. round(level.position.y) .. ")\n" ..
                               "Sum: (" .. level.position.x + player.body:getX() .. "," .. level.position.y + player.body:getY() .. ")\n"
    end
    if debugDisplays[3] then
      local pxv, pyv = player.body:getLinearVelocity()
      debugText = debugText .. "Player Velocity: (" .. round(pxv) .. "," .. round(pyv) .. ")\n"
    end
    if debugDisplays[4] then
      debugText = debugText .. "Number of Enemies: " .. #level.enemies .. "\n" ..
                               "Number of Elements: " .. #level.elements .. "\n" ..
                               "Number of Projectiles: " .. #projectiles.list .. "\n"
    end
    if debugDisplays[5] then
      debugText = debugText .. "Displaying Enemy Indicators\n"
    end
    if debugDisplays[6] then
      debugText = debugText .. "Debug 6\n"
    end
    if debugDisplays[7] then
      debugText = debugText .. "Debug 7\n"
    end
    if debugDisplays[8] then
      debugText = debugText .. "Debug 8\n"
    end
    if debugDisplays[9] then
      debugText = debugText .. "Debug 9\n"
    end
    if debugDisplays[10] then
      debugText = debugText .. "Debug 10\n"
    end
    if debugDisplays[11] then
      debugText = debugText .. "Debug 11\n"
    end
    if debugDisplays[12] then
      debugText = debugText .. "Debug 12\n"
    end
    
    love.graphics.setColor(0,0,0)
    love.graphics.print(debugText, 10, 10)
end

function DisplayHealthBar(x, y, width, height)
  
  love.graphics.setColor(0, 0, 0)
  love.graphics.circle("fill", x, y + height/2, height)
  
  love.graphics.setColor(135, 135, 135)
  love.graphics.rectangle("fill", x, y, width, height)
  
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("line", x, y, width, height)
  
  love.graphics.setColor(255, 0, 0)
  love.graphics.circle("fill", x, y + height/2, height/2)
  love.graphics.rectangle("fill", x, y, width * player.health / 100, height)
end

function DisplayGameTime(x, y)
  local time = love.timer.getTime()
  love.graphics.setColor(0, 0, 0)
  love.graphics.printf("Time: " .. round(time - startTime), x, y, 0, "center")
end

function DisplayGameOver()
  love.graphics.setColor(0, 0, 0)
  love.graphics.printf("!GameOver!" , 325, 225, 0, "center")
end

function DisplayHUD()
  DisplayHealthBar(200, 600, 250, 25)
  DisplayGameTime(100, 600)
  if gameover then
    DisplayGameOver()
  end
end

function shoot(entity)
  local x, y = entity.body:getPosition()
  projectiles:create(x + 25 * entity.direction, y, 1000 * entity.direction, 0, 3, 10)
end
