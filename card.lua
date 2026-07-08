local M = {}

M.__index = M

local IMAGE_WIDTH = 1248
local IMAGE_HEIGHT = 512

local atlas = love.graphics.newImage("assets/cards.png")
local card_back = love.graphics.newImage("assets/card_back.png")

function M:new(cardIndex)
  local width = Config.card.width
  local height = Config.card.height

  local col = (cardIndex * IMAGE_WIDTH) / IMAGE_WIDTH % 13
  local row = math.floor((cardIndex * IMAGE_WIDTH) / IMAGE_WIDTH / 13)

  local quad = love.graphics.newQuad(width * col, row * height, width, height, IMAGE_WIDTH, IMAGE_HEIGHT)

  local scaled_width = width * Config.scale
  local scaled_height = height * Config.scale

  local gap = 10

  return setmetatable({
    x = col * width + gap,
    y = row * height + gap,
    quad = quad,
    width = scaled_width,
    height = scaled_height,
    clicked = false,
    locked = false,
    dragging = false,
    back = false,
    animation = {
      flip = 1
    },
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

  if not self.back then
    love.graphics.draw(atlas, self.quad, self.x, self.y, 0, Config.scale, Config.scale)
  else
    love.graphics.draw(card_back, self.x, self.y, 0, Config.scale, Config.scale)
  end



  -- DEBUG
  --
  if DEBUG then
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

end

function M:contains_point(x, y)
  return x > self.x and
    x < self.x+self.width and
    y > self.y and
    y < self.y+self.height
end

function M:flip()
  self.back = not self.back
end

function M:move(x ,y)
  self.x = x
  self.y = y
end

return M
