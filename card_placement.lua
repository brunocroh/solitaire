local M = {}

M.__index = M

function M:new(options)
  local width = Config.card.width * Config.scale
  local height = Config.card.height * Config.scale

  return setmetatable({
    x = options.x,
    y = options.y,
    width = width,
    height = height,
    disabled = options.disabled,
    invisible = options.invisible,
    ondrop = options.ondrop
  }, M)
end

function M:draw()
  local r,g,b, a = love.graphics.getColor()
  love.graphics.setColor(r,r,r, 0.5)

  if not self.invisible then
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 5, 5)
  end


  love.graphics.setColor(r,g,b, a)
end

function M:card_colide(card)
  return card.x < self.x+self.width and
    card.x + card.width > self.x and
    card.y  < self.y+self.height and
    card.y + card.height > self.y
end

function M:ondrop(cards)
  for _, card in pairs(cards) do
    card:move(self.x, self.y)
  end
  print("custom ondrop: not implemented")
end

return M
