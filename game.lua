local Card = require('card')
local CardPlacement = require('card_placement')

local Game = {
}

Game.__index = Game

function Game:new()
  local cards = {}
  local card_placements = {}

  for i = 0, Config.deck_size - 1, 1 do
    table.insert(cards, Card:new(i))
  end

  local placement = CardPlacement:new()

  table.insert(card_placements, placement)

  return setmetatable({
    cards = cards,
    active_card = nil,
    card_placements = card_placements
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

  for _, placement in pairs(self.card_placements) do
    placement:draw()
  end

  for _, card in pairs(self.cards) do
    card:draw()
  end

end

function Game:quit()
end

function Game:mousepressed(x, y, btn)
  for index = #self.cards, 1, -1 do
    local card = self.cards[index]
    if card:contains_point(x, y) then
      if btn == 1 then
        if not card.locked then
          self.active_card = card
          self.active_card.dragging = true
          self.active_card.drag_offset.x = x - card.x
          self.active_card.drag_offset.y = y - card.y

          table.remove(self.cards, index)
          table.insert(self.cards, card)
        end
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

    for _, placement in pairs(self.card_placements) do
      if placement:card_colide(self.active_card) then
        self.active_card:move(placement.x, placement.y)
        break
      end
    end

    self.active_card.dragging = false
    self.active_card.drag_offset.x = nil
    self.active_card.drag_offset.y = nil
    self.active_card = nil
  end
end

function Game:keypressed(key)
  print("pressed: "..key)

  if not key == "f" then
    return
  end

  local mx, my = love.mouse.getPosition()

  for index = #self.cards, 1, -1 do
    local card = self.cards[index]

    if card:contains_point(mx, my) then
      if key == "f" then
        card:flip()
      end

      break
    end
  end
end

function Game:keyreleased(_)
end

return Game
