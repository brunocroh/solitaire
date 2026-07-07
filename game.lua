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
    active_card = nil,
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

function Game:mousepressed(x, y, btn)
  for index, card in pairs(self.cards) do
    if card:contains_point(x, y) then
      if btn == 1 then
        self.active_card = card
        self.active_card.dragging = true
        self.active_card.drag_offset.x = x - card.x
        self.active_card.drag_offset.y = y - card.y

        table.remove(self.cards, index)
        table.insert(self.cards, card)
      end

      if btn == 2 then
        card.locked = not card.locked
      end
      break
    end
  end
end

function Game:mousereleased(_, _, btn)
  if btn == 1 and self.active_card then
    self.active_card.dragging = false
    self.active_card.drag_offset.x = nil
    self.active_card.drag_offset.y = nil
    self.active_card = nil
  end
end

return Game
