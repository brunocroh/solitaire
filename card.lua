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
    x = (width+10) * cardIndex + 10,
    y = 0+10,
    quad = quad,
    width = width,
    height = height,
    clicked = false,
    locked = false,
    dragging = false,
    drag_offset = {
      x = nil,
      y = nil,
    }
  }, M)
end

function M:update(_)
  local mx,my = love.mouse.getPosition()

  if not self.locked then
    if love.mouse.isDown(1) and self.dragging then
      self.clicked = true
      self.x = mx - self.drag_offset.x
      self.y = my - self.drag_offset.y
    else
      self.clicked = false
    end
  end


end

function M:draw()
  love.graphics.setLineWidth(4)
  local r,g,b, a = love.graphics.getColor()
  love.graphics.draw(atlas, self.quad, self.x, self.y, 0, CARD_SCALE, CARD_SCALE)

  love.graphics.setColor(0, 0, 0.8, 1)

  if self.locked then
    love.graphics.setColor(0.8, 0, 0, 1)
  end

  if self.clicked then
    love.graphics.setColor(0, 0.8, 0, 1)
  end

  love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 5, 5)
  love.graphics.setColor(r,g,b, a)
end

function M:contains_point(x, y)
  return x > self.x and
    x < self.x+self.width and
    y > self.y and
    y < self.y+self.height
end

return M
