local SpriteAnimation = require("lib.sprite")

local M = {
  elements = {},
  font = love.graphics.getFont()
}

function M:load()

end


function M:update(dt)
  for _, el in pairs(self.elements) do
    el:update(dt)
  end
end

function M:draw()
  for _, el in pairs(self.elements) do
    el:draw()
  end
end

function M:mousepressed(mx, my, btn)
  for _, el in pairs(self.elements) do
    if el:contains_point(mx, my) then
      el:onclick(btn)
    end
  end
end

local Button = {}

Button.__index = Button

function Button:new(options)
  local sprite_files = {}
  for i = 1, 4, 1 do
    table.insert(sprite_files, love.graphics.newImage(string.format("assets/button_%d.png", i)))
  end

  local sprite = SpriteAnimation:new({
    files = sprite_files,
    x = options.x,
    y = options.y,
  })

  local text_width = M.font:getWidth(options.label)
  local text_height = M.font:getHeight()

  local mid_w = sprite.width/2 - text_width/2
  local mid_h = sprite.height/2 - text_height/2
  local mid_h_offset = 5

  local btn = setmetatable({
    x = options.x,
    y = options.y,
    sprite = sprite,
    text = {
      color = {0,0,0,1},
      x = options.x + mid_w,
      y = options.y + mid_h - mid_h_offset,
    },
    bgcolor = {1,0,0,0.1},
    label = options.label,
    width = sprite.width,
    height = sprite.height,
    onclick = function()
      if sprite then
        sprite:play()
      end
      options.onclick()
    end
  }, Button)

  table.insert(M.elements, btn)

  return btn
end

function Button:update(dt)
  self.sprite:update(dt)
end

function Button:draw()
  local r,g,b,a = love.graphics.getColor()

  self.sprite:draw()

  -- text
  print(self.x, self.text.x)
  love.graphics.setColor(unpack(self.text.color))
  love.graphics.print(self.label, self.text.x, self.text.y)

  love.graphics.setColor(r,g,b,a)
end

function Button:contains_point(x,y)
  if x > self.x and
    x < self.x + self.width and
    y > self.y and
    y < self.y + self.height then
      return true
    end

  return false
end

M.Button = Button


return M
