local Card = require('card')
local CardPlacement = require('card_placement')

local Game = {
}

Game.__index = Game

function Game:new()
  local cards = {}
  local placements = {}
  local tmp_zones = {}
  local suit_zones = {}

  for i = 0, Config.deck_size - 1, 1 do
    table.insert(cards, Card:new(i))
  end

  local gap = 20
  local card_width = (Config.card.width*Config.scale)
  for i = 0, 2, 1 do
    local placement = CardPlacement:new(card_width * i + gap + gap * i, gap)
    table.insert(tmp_zones, placement)
    table.insert(placements, placement)
  end

  for i = 0, 2, 1 do
    local margin = card_width * i
    local incremental_gap = gap * i

    local placement = CardPlacement:new(love.graphics.getWidth() - (card_width + margin + gap + incremental_gap), gap)

    table.insert(suit_zones, placement)
    table.insert(placements, placement)
  end

  local disabled = true
  local joker_zone = CardPlacement:new(love.graphics.getWidth()/2 - (card_width / 2), gap, disabled)
  table.insert(placements, joker_zone)

  return setmetatable({
    cards = cards,
    active_card = nil,
    tmp_zones = tmp_zones,
    suit_zones = suit_zones,
    placements = placements,
    joker_zone = joker_zone
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

  for _, placement in pairs(self.placements) do
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
          self.active_card:hold(x,y)

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

    for _, placement in pairs(self.placements) do
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
