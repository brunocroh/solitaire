require('enum')
local Card = require('card')
local CardStack = require('card_stack')
local fisherYates = require('lib.fisher_yates')
local Gui = require('lib.gui')

local Game = {
  auto_fetch_delay = 0.2
}

Game.__index = Game

local bg_suit_stacks = {"ace_diamonds", "ace_heart", "ace_spades"}

function Game:new()
  local cards = {}
  local tmp_zones = {}
  local suit_zones = {}
  local card_stacks = {}

  -- CREATE CARDS
  for i = 0, Config.deck_size - 1, 1 do
    table.insert(cards, Card:new(i))
  end

  local joker = Card:new(27)

  -- Joker card
  table.insert(cards, Card:new(27))

  for _ = 1, 4, 1 do
    table.insert(cards, Card:new(36))
    table.insert(cards, Card:new(37))
    table.insert(cards, Card:new(38))
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
      id = "card_stack_" .. i,
      x = x_offset * i + gap,
      y = y_offset,
      invisible = not DEBUG,
      ondrop = function (ctx, card)
        local top = ctx.cards[#ctx.cards]

        if top then
          if top.suit == card.suit or top.value-1 ~= card.value  then
            return false
          end
        end

        return true
      end
    })
    table.insert(card_stacks, stack)
  end

  -- ADD CARTS TO STACKS
  for k, card in pairs(cards) do
    local i = k % 8
    local disable = true
    card_stacks[i+1]:push({card}, disable)
  end

  -- CREATE PLACEMENTS
  for i = 0, 2, 1 do
    local placement = CardStack:new({
      id = "tmp_stack_" .. i,
      x = card_width * i + gap + gap * i,
      y = gap,
      offset = 0,
      ondrop = function (ctx, _, n)
        return #ctx.cards < 1 and n == 1
      end
    })
    table.insert(tmp_zones, placement)
    table.insert(card_stacks, placement)
  end

  for i = 0, 2, 1 do
    local margin = card_width * i
    local incremental_gap = gap * i

    local placement = CardStack:new({
      id = "suit_stack_" .. i,
      x = love.graphics.getWidth() - (card_width + margin + gap + incremental_gap),
      y = gap,
      invisible = false,
      offset = 0,
      bg = bg_suit_stacks[i+1],
      auto_fetch = function(ctx)
        if not ctx.ready then
          return
        end

        local top = ctx.cards[#ctx.cards]
        local value = top and top.value or 0

        local tmp_card
        for _, c in pairs(cards) do
          if c.value == value+1 and c.suit == i+1 then
            if not c.locked then
              tmp_card = c
              ctx:push({c})
              c.locked = true
            end
            break
          end
        end

        if tmp_card then
          for j, cc in pairs(cards) do
            if tmp_card == cc then
              table.remove(cards, j)
              table.insert(cards, cc)
              break
            end
          end
        end
      end,
      ondrop = function (ctx, cc)
        local top = ctx.cards[#ctx.cards]

        if cc.suit ~= i+1 then
          return false
        end

        if top and top.value + 1 ~= cc.value then
          return false
        end

        return true
      end
    })

    table.insert(suit_zones, placement)
    table.insert(card_stacks, placement)
  end

  local disabled = true

  local joker_zone = CardStack:new({
    id = "joker_stack",
    x = love.graphics.getWidth()/2 - (card_width / 2),
    y = gap,
    disabled = disabled,
    offset = 0,
    bg = "joker",
    auto_fetch = function(ctx)
      if not ctx.ready then
        return
      end

      for _, c in pairs(cards) do
        if c.value == joker.value and c.suit == joker.suit then
          if not c.locked then
            ctx:push({c})
            c.locked = true
          end
          break
        end
      end
    end,
    ondrop = function (ctx, card, n)
      if n > 1 then
        return false
      end
      
      if #ctx.cards ~= 0 then
        return false
      end

      if card.value == 1 and card.suit == 4 then
        return true
      end

      return false
    end
  })
  table.insert(card_stacks, joker_zone)

  -- Define GUI elements
  Gui.Button:new({
    x = 760,
    y = 40,
    label = "Test button",
    onclick = function()
      print"hello1"
    end
  })
  Gui.Button:new({
    x = 760,
    y = 70,
    label = "Test button",
    onclick = function()
      print"hello2"
    end
  })
  Gui.Button:new({
    x = 760,
    y = 100,
    label = "Test button",
    onclick = function()
      print"hello3"
    end
  })


  return setmetatable({
    cards = cards,
    active_card = {},
    tmp_zones = tmp_zones,
    suit_zones = suit_zones,
    joker_zone = joker_zone,
    card_stacks = card_stacks
  }, Game)
end

function Game:load()
  for _, stack in pairs(self.card_stacks) do
    stack.ready = true
  end
end

function Game:update(dt)
  for _, card in pairs(self.cards) do
    card:update(dt)
  end

  if self.auto_fetch_delay <= 0 then
    for _, stack in pairs(self.card_stacks) do
      if stack.auto_fetch then
        stack:auto_fetch()
      end
    end
    self.auto_fetch_delay = 0.2
  else
    self.auto_fetch_delay = self.auto_fetch_delay - dt
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

  Gui:draw()
end

function Game:quit()
end

function Game:mousepressed(x, y, btn)
  for index = #self.cards, 1, -1 do
    local card = self.cards[index]
    if card:contains_point(x, y) then
      if btn == 1 then
        if not card.locked then
          local stack = card.stack
          local found = false

          for _, c in pairs(stack.cards) do
            if c == card then
              found = true
            end

            if found then
              c.previous_position.x = c.x
              c.previous_position.y = c.y

              c:hold(x,y)

              table.insert(self.active_card, c)

            end
          end

          for _, c in pairs(self.active_card) do
            for j, cc in pairs(self.cards) do
              if c == cc then
                table.remove(self.cards, j)
                table.insert(self.cards, c)
                break
              end
            end
          end
        end
        break
      end

      if btn == 2 then
        card.locked = not card.locked
      end
      break
    end
  end
end

function Game:mousereleased(_, _, btn)
  if btn == 1 and #self.active_card > 0 then
    local validMove = false

    for _, stack in pairs(self.card_stacks) do
      if stack:card_colide(self.active_card[1]) then
        validMove = stack:push(self.active_card)
        break
      end
    end

    for _, c in pairs(self.active_card) do
      c.dragging = false
      c.drag_offset.x = nil
      c.drag_offset.y = nil

      if not validMove then
        c.x = c.previous_position.x
        c.y = c.previous_position.y

        c.previous_position.x = nil
        c.previous_position.y = nil
      end
    end
    self.active_card = {}

  end
end

function Game:keypressed(key)
  print("pressed: "..key)

  if not key == "f" or not key == "space" then
    return
  end

  if key == "space" then
    local mx, my = love.mouse.getPosition()
    print(string.format("mx:%d my:%d", mx,my))
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
