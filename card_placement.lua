local M = {}

M.__index = M

function M:new(x, y, disabled)
  local width = Config.card.width * Config.scale
  local height = Config.card.height * Config.scale

  return setmetatable({
    x = x,
    y = y,
    width = width,
    height = height,
    disabled = disabled,
  }, M)
end

function M:draw()
  local r,g,b, a = love.graphics.getColor()
  love.graphics.setColor(r,r,r, 0.5)
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5, 5)

  love.graphics.setColor(r,g,b, a)
end

function M:card_colide(card)
  if self.disabled then
    return false
  end
  return card.x < self.x+self.width and
    card.x + card.width > self.x and
    card.y  < self.y+self.height and
    card.y + card.height > self.y
end

return M
