  local level = Level:new()
  level:setPlayerSpawn(100, -5)
  
  local i, j
  
  --Floor
  level:addElement(BlockElement:new(level, 0, 0, 10000, 250, 72, 160, 14, 255, true))
  --Left Wall
  level:addElement(BlockElement:new(level, -125, -250, 125, 500, 72, 160, 14, 255, true))
  --Right Wall
  level:addElement(BlockElement:new(level, 10000, -250, 125, 500, 72, 160, 14, 255, true))
  --Blocks to Play With
  for i = 1, 100, 10 do
    for j = 1, 100, 20 do
      level:addElement(BlockElement:new(level, 3000 + j, -i - 1, 20, 10, 50, 0, 0, 255, false))
    end
  end
  --Dots
  for i = 1, 10000, 100 do
    level:addElement(BlockElement:new(level, i, 100, 10, 10, 255, 204, 51, 255, true))
  end
  
  --level:addEnemy(RockEnemy:new(level, 200, -5))
  --level:addEnemy(SmartEnemy:new(level, 300, -5))
  
  return level