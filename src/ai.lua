AI = {}
AI.__index = AI

function AI:init()
  --currentState = nil
end

function AI:new()
  local ai = setmetatable({},AI)
  ai:init()
  return ai
end

function AI:changeState(newState)
  if self.currentState ~= nil then
    self.currentState:endState()
  end
  self.currentState = newState
  if newState ~= nil then
    newState:startState()
  end
end

function AI:update(dt)
  if self.currentState ~= nil then
    self.currentState:update(dt)
  end
end

AIState = {}
AIState.__index = AIState

function AIState:init(AI, Enemy)
  self.AI = AI
  self.enemy = Enemy
end

function AIState:new(AI, Enemy)
  state = setmetatable({}, AIState)
  state.__index = state
  state:init(AI, Enemy)
  return state
end

function AIState:update(dt)
end

function AIState:startState()
end

function AIState:endState()
end

--------------------------------------------------------------------------------
