local CardPlacement = require("card_placement")

local M = {}

M.__index = M


function M:new(options)
  local placement = CardPlacement:new({
    x = options.x,
    y = options.y,
    invisible = options.invisible,
    bg = options.bg
  })

  if not options.ondrop then
    error("options.ondrop is mandatory")
  end

  local offset = 70

  if options.offset then
    offset = options.offset
  end


  return setmetatable({
    id = options.id,
    x = options.x,
    y = options.y,
    cards = {},
    placement = placement,
    offset = offset,
    ondrop = options.ondrop,
    auto_fetch = options.auto_fetch,
    ready = false
  }, M)
end

function M:draw()
  self.placement:draw()
end

function M:push(cards, disable, animated)
  if not disable then
    if not self.ondrop(self, cards[1], #cards) then
      return false
    end
  end

  for _, card in pairs(cards) do
    if card.stack then
      card.stack:pop()
    end

    card:move(self.placement.x,self.placement.y, animated)

    card.stack = self

    table.insert(self.cards, card)
    self.placement.y = self.y + #self.cards * self.offset
    self:manage_lock_state()
  end
  return true
end

function M:pop()
  table.remove(self.cards, #self.cards)
  self.placement.y = self.placement.y - self.offset
  self:manage_lock_state()
end

function M:manage_lock_state()
  local locked = false

  local top = self.cards[#self.cards]

  if not top then
    return
  end
  top.locked = locked
  for i = #self.cards, 1, -1 do
    local hi = self.cards[i]
    if i == 1 then
      hi.locked = locked
      break
    end

    local lo = self.cards[i-1]
    if lo.value-1 == hi.value and lo.suit ~= hi.suit then
      locked = hi.locked
    else
      locked = true
    end

    lo.locked = locked
  end


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
