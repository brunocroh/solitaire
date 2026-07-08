local CardPlacement = require("card_placement")

local M = {}

M.__index = M

local Y_OFFSET = 70

function M:new(options)
  local placement = CardPlacement:new({
    x = options.x,
    y = options.y
  })

  return setmetatable({
    x = options.x,
    y = options.y,
    cards = {},
    placement = placement
  }, M)
end

function M:draw()
  self.placement:draw()
end

function M:push(cards)
  for _, card in pairs(cards) do
    if card.stack then
      card.stack:pop()
    end

    card.x = self.placement.x
    card.y = self.placement.y
    self.placement.y = self.placement.y + Y_OFFSET


    card.stack = self

    table.insert(self.cards, card)
  end
end

function M:pop()
  table.remove(self.cards, #self.cards)
  self.placement.y = self.placement.y - Y_OFFSET
end

function M:card_colide(x,y)
  return self.placement:card_colide(x,y)
end

function M:contains_point(x, y)
  return x > self.x and
    x < (self.placement.x+self.placement.width) and
    y > self.y and
    y < (self.placement.y+self.placement.height)
end

return M
