local M = {}

M.__index = M

function M:new(options)
  local first_frame = options.files[1]
  return setmetatable({
    frames = options.files,
    x = options.x,
    y = options.y,
    width = first_frame:getWidth() * Config.scale,
    height = first_frame:getHeight() * Config.scale,
    animation = {
      is_playing = false,
      frame = 1,
      duration = 0.04,
      elapsed_time = 0
    }
  }, M)
end

function M:update(dt)
  local ani = self.animation
  if ani.is_playing then
    if ani.elapsed_time <= 0 then
      ani.frame = ani.frame+1
      ani.elapsed_time = ani.duration

      if ani.frame > #self.frames then
        ani.is_playing = false
        ani.frame = 1
      end
    else
      ani.elapsed_time = ani.elapsed_time - dt
    end
  end
end

function M:draw()
  love.graphics.draw(self.frames[self.animation.frame], self.x, self.y, 0, Config.scale)
end

function M:play()
  self.animation.is_playing = true
end

return M
