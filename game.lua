local Card = require('card')
local CardStack = require('card_stack')
local fisherYates = require('lib.fisher_yates')

local Game = { }

Game.__index = Game

function Game:new()
  local cards = {}
  local tmp_zones = {}
  local suit_zones = {}
  local card_stacks = {}

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

  -- CREATE STACKS
  for i = 0, 7, 1 do
    local stack = CardStack:new({
      x = x_offset * i + gap,
      y = y_offset,
      invisible = true,
      ondrop = function ()
        return true
      end
    })
    table.insert(card_stacks, stack)
  end

  -- ADD CARTS TO STACKS
  for k, card in pairs(cards) do
    local i = k % 8
    card_stacks[i+1]:push({card})
  end

  -- CREATE PLACEMENTS
  for i = 0, 2, 1 do
    local placement = CardStack:new({
      x = card_width * i + gap + gap * i,
      y = gap,
      offset = 0,
      ondrop = function (ctx)
        print("ctx cards = " .. #ctx.cards)
        return #ctx.cards < 1
      end
    })
    table.insert(tmp_zones, placement)
    table.insert(card_stacks, placement)
  end

  for i = 0, 2, 1 do
    local margin = card_width * i
    local incremental_gap = gap * i

    local placement = CardStack:new({
      x = love.graphics.getWidth() - (card_width + margin + gap + incremental_gap),
      y = gap,
      offset = 0,
      ondrop = function ()
        return true
      end
    })

    table.insert(suit_zones, placement)
    table.insert(card_stacks, placement)
  end

  local disabled = true
  local joker_zone = CardStack:new({
    x = love.graphics.getWidth()/2 - (card_width / 2),
    y = gap,
    disabled = disabled,
    ondrop = function ()
      return true
    end
  })
  table.insert(card_stacks, joker_zone)


  return setmetatable({
    cards = cards,
    active_card = nil,
    tmp_zones = tmp_zones,
    suit_zones = suit_zones,
    joker_zone = joker_zone,
    card_stacks = card_stacks
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

  for _, stack in pairs(self.card_stacks) do
    stack:draw()
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

    for _, stack in pairs(self.card_stacks) do
      if stack:card_colide(self.active_card) then
        validMove = stack:push({self.active_card})
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
