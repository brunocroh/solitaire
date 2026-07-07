local d = require("dev-tools")
local Game = require("game")

local game

function love.load()
  love.window.setMode(1920, 1080)
  game = Game:new()

  d.load()
end

function love.update(dt)
  game:update(dt)
end

function love.draw()
  game:draw()
end

function love.quit()
  game:quit()
  d.quit()
end


function love.keypressed(key)
  if key == 'r' then love.event.quit('restart') end
end

function love.keyreleased()
end

function love.mousepressed()
end

function love.mousereleased()
end
