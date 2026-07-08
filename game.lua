local Card = require('card')
local CardPlacement = require('card_placement')
local fisherYates = require('lib.fisher_yates')

local Game = {
}

Game.__index = Game

function Game:new()
  local cards = {}
  local placements = {}
  local tmp_zones = {}
  local suit_zones = {}
  local card_columns = {}

  -- CREATE CARDS
  for i = 0, Config.deck_size - 1, 1 do
    table.insert(cards, Card:new(i))
  end

  fisherYates(cards)

  local card_columns_gap = 26
  local card_width = (Config.card.width*Config.scale) + card_columns_gap
  local card_height = (Config.card.height*Config.scale)
  local gap = 20

  local x_offset = card_width + gap
  local y_offset = card_height + 80 -- hard coded value

  for k, card in pairs(cards) do
    local i = k % 8

    if not card_columns[i+1] then
      card_columns[i+1] = {}
    end

    card.x = x_offset * i + gap -- hardcoded gap
    card.y = y_offset
    
    table.insert(card_columns[i+1], card)

    if i == 0 then
      y_offset = y_offset + 70
    end
  end

  -- CREATE PLACEMENTS
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

  for i = 1, 8, 1 do
    local last_card = card_columns[i][#card_columns[i]]
    local placement = CardPlacement:new(last_card.x, last_card.y + 70, false, false)

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

  if DEBUG then
    local px = love.graphics.getWidth()/2 - 200
    if self.active_card then
      love.graphics.print("value: " .. self.active_card.value, px, 10)
      love.graphics.print("suit: " .. self.active_card.suit, px, 30)
      love.graphics.print("x: " .. self.active_card.x, px, 50)
      love.graphics.print("y: " .. self.active_card.y, px, 70)
    end

    local mx, my = love.mouse.getPosition()
    love.graphics.print("mx: " .. mx, px, 90)
    love.graphics.print("my: " .. my, px, 110)
    
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
          self.active_card.previous_position.x = self.active_card.x
          self.active_card.previous_position.y = self.active_card.y

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
    local validMove = false

    for _, placement in pairs(self.placements) do
      if placement:card_colide(self.active_card) then
        self.active_card:move(placement.x, placement.y)
        validMove = true
        break
      end
    end

    self.active_card.dragging = false
    self.active_card.drag_offset.x = nil
    self.active_card.drag_offset.y = nil

    if not validMove then
      self.active_card.x = self.active_card.previous_position.x
      self.active_card.y = self.active_card.previous_position.y

      self.active_card.previous_position.x = nil
      self.active_card.previous_position.y = nil
    end
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
