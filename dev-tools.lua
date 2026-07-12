local M = {}

local SETTINGS_FILE = "settings.txt"

function M.save_window_position()
  local x, y = love.window.getPosition()
  love.filesystem.write(SETTINGS_FILE, x .. "," .. y)
end

function M.load()
  local file = love.filesystem.getInfo(SETTINGS_FILE)

  if not file then
    return
  end

  local data = love.filesystem.read(SETTINGS_FILE)
  if not data then
    return
  end
  local x, y = data:match("(%d+),(%d+)")
  if x and y then
    love.window.setPosition(x, y)
  end

end

function M.quit()
  M.save_window_position()
end


return M
