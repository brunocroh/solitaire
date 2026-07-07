local Card = require('card')

local Game = {
  controller = {}
}

Game.__index = Game

function Game:new()
  local cards = {}

  for i = 0, 12, 1 do
    table.insert(cards, Card:new(i))
  end
  return setmetatable({
    cards = cards,

  }, Game)
end

function Game:load()
end

function Game:update(dt)

  for _, card in pairs(self.cards) do
    card:update(dt)
  end
end

function Game:draw()
  local r,g,b = love.math.colorFromBytes(53,101, 77)
  love.graphics.setBackgroundColor(r, g, b, 1)

  for _, card in pairs(self.cards) do
    card:draw()
  end
end

function Game:quit()
end

return Game
