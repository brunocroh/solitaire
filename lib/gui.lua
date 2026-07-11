local M = {
  elements = {},
  font = love.graphics.getFont()
}

function M:load()

end

function M:draw()
  local r,g,b,a = love.graphics.getColor()

  for _, el in pairs(self.elements) do
    el:draw({font = self.font, name="meu"})
  end

   love.graphics.setColor(r,g,b,a)
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
  local btn = setmetatable({
    x = options.x,
    y = options.y,
    bgcolor = {1,1,1,1},
    color = {0,0,0,1},
    label = options.label,
    width = M.font:getWidth(options.label),
    height = 20,
    onclick = options.onclick
  }, Button)

  table.insert(M.elements, btn)

  return btn
end

function Button:draw()
  -- background
  love.graphics.setColor(unpack(self.bgcolor))
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

  -- text

  love.graphics.setColor(unpack(self.color))
  love.graphics.print(self.label, self.x, self.y)
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
