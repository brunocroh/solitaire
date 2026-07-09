local CardPlacement = require("card_placement")

local M = {}

M.__index = M

function M:new(options)
  local placement = CardPlacement:new({
    x = options.x,
    y = options.y,
    invisible = options.invisible
  })

  if not options.ondrop then
    error("options.ondrop is mandatory")
  end

  local offset = 70

  if options.offset then
    offset = options.offset
  end

  return setmetatable({
    x = options.x,
    y = options.y,
    cards = {},
    placement = placement,
    offset = offset,
    ondrop = options.ondrop
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

    if not self:ondrop(self, cards) then
      return false
    end

    card.x = self.placement.x
    card.y = self.placement.y
    self.placement.y = self.placement.y + self.offset


    card.stack = self

    table.insert(self.cards, card)
    return true
  end
end

function M:pop()
  table.remove(self.cards, #self.cards)
  self.placement.y = self.placement.y - self.offset
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
