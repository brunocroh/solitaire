local d = require("dev-tools")
local Game = require("game")

local game

DEBUG = true

Config = {
  scale = 2,
  deck_size = 2,
  card = {
    width = 96,
    height = 128,
  }
}

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
  game:keypressed(key)
end

function love.keyreleased(key)
  game:keyreleased(key)
end


function love.mousepressed(x, y, btn)
  game:mousepressed(x, y, btn)
end

function love.mousereleased(x, y, btn)
  game:mousereleased(x, y, btn)
end


