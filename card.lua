local M = {}

M.__index = M

local CARD_SCALE = 2
local CARD_WIDTH = 96
local CARD_HEIGHT = 128


local atlas = love.graphics.newImage("assets/cards.png")

function M:new(cardIndex)
  local quad = love.graphics.newQuad(CARD_WIDTH * cardIndex, 0, CARD_WIDTH, CARD_HEIGHT, 1248, 512)

  local width = CARD_WIDTH * CARD_SCALE
  local height = CARD_HEIGHT * CARD_SCALE

  return setmetatable({
    x = (width+10) * cardIndex ,
    y = 0,
    quad = quad,
    width = width,
    height = height,
    clicked = false,
    locked = true,
  }, M)
end

function M:update(_dt)
  local x,y = love.mouse.getPosition()

  if
    love.mouse.isDown(1) and
    x > self.x and
    x < self.x+self.width and
    y > self.y and
    y < self.y+self.height
  then
    self.clicked = true
  else
    self.clicked = false
  end

  if
    love.mouse.isDown(1) and
    x > self.x and
    x < self.x+self.width and
    y > self.y and
    y < self.y+self.height
  then
    self.locked = not self.locked
  end

end

function M:draw()
  local r,g,b, a = love.graphics.getColor()
  love.graphics.draw(atlas, self.quad, self.x, self.y, 0, CARD_SCALE, CARD_SCALE)

  if self.clicked then
    love.graphics.setColor(0, 0.8, 0, 1)
  else
    love.graphics.setColor(0.8, 0, 0, 1)
  end
  love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
  love.graphics.setColor(r,g,b, a)
end

return M
