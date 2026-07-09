local M = {}

M.__index = M

local IMAGE_WIDTH = 1248
local IMAGE_HEIGHT = 512

local atlas = love.graphics.newImage("assets/cards.png")
local card_back = love.graphics.newImage("assets/card_back.png")

local sounds = {
  place = love.audio.newSource("assets/sounds/card-place.mp3", "static"),
  take = love.audio.newSource("assets/sounds/card-take.mp3", "static"),
  flip = love.audio.newSource("assets/sounds/card-flip.mp3", "static"),
}

for _, sound in pairs(sounds) do
  sound:setVolume(0.4)
end

function M:new(cardIndex)
  local width = Config.card.width
  local height = Config.card.height

  local col = (cardIndex * IMAGE_WIDTH) / IMAGE_WIDTH % 9
  local row = math.floor((cardIndex * IMAGE_WIDTH) / IMAGE_WIDTH / 9)

  local quad

  if cardIndex == 36 then
    quad = love.graphics.newQuad(width * 10, height * 3, width, height, IMAGE_WIDTH, IMAGE_HEIGHT)
  elseif cardIndex == 37 then
    quad = love.graphics.newQuad(width * 11, height * 3, width, height, IMAGE_WIDTH, IMAGE_HEIGHT)
  elseif cardIndex == 38 then
    quad = love.graphics.newQuad(width * 12, height * 3, width, height, IMAGE_WIDTH, IMAGE_HEIGHT)
  else
    quad = love.graphics.newQuad(width * col, row * height, width, height, IMAGE_WIDTH, IMAGE_HEIGHT)
  end

  local scaled_width = width * Config.scale
  local scaled_height = height * Config.scale

  return setmetatable({
    x = love.graphics.getWidth() - width*2 - 20,
    y = 20,
    previous_position = {
      x = nil,
      y = nil,
    },
    quad = quad,
    width = scaled_width,
    height = scaled_height,
    clicked = false,
    locked = false,
    dragging = false,
    back = false,
    value = col + 1,
    suit = row + 1,
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
  love.graphics.setLineWidth(2)
  local r,g,b, a = love.graphics.getColor()

  if not self.back then
    love.graphics.draw(atlas, self.quad, self.x, self.y, 0, Config.scale, Config.scale)
  else
    love.graphics.draw(card_back, self.x, self.y, 0, Config.scale, Config.scale)
  end

  -- DEBUG
  if DEBUG then
    love.graphics.setColor(0, 0, 0.8, 1)

    if self.locked then
      love.graphics.setColor(0.8, 0, 0, 1)
    end

    if self.clicked then
      love.graphics.setColor(0, 0.8, 0, 1)
    end

    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 10, 10)
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
  sounds.flip:clone():play()
  self.back = not self.back
end

function M:move(x ,y)
  sounds.place:clone():play()
  self.x = x
  self.y = y
end

function M:hold(x, y)
  local sound = sounds.place:clone()
  sound:setPitch(2)
  sound:play()
  self.dragging = true
  self.drag_offset.x = x - self.x
  self.drag_offset.y = y - self.y
end

return M
