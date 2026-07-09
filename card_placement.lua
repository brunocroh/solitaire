local M = {}

M.__index = M

local card_atlas = love.graphics.newImage("assets/cards.png")


function M:new(options)
  local backgrounds = {
    joker = love.graphics.newQuad(Config.card.width * 0, Config.card.height * 3, Config.card.width, Config.card.height, Config.IMAGE_WIDTH, Config.IMAGE_HEIGHT),
    ace_diamonds = love.graphics.newQuad(Config.card.width * 0, Config.card.height * 0, Config.card.width, Config.card.height, Config.IMAGE_WIDTH, Config.IMAGE_HEIGHT),
    ace_heart = love.graphics.newQuad(Config.card.width * 0, Config.card.height * 1, Config.card.width, Config.card.height, Config.IMAGE_WIDTH, Config.IMAGE_HEIGHT),
    ace_spades = love.graphics.newQuad(Config.card.width * 0, Config.card.height * 2, Config.card.width, Config.card.height, Config.IMAGE_WIDTH, Config.IMAGE_HEIGHT),
  }

  local width = Config.card.width * Config.scale
  local height = Config.card.height * Config.scale

  local bg

  if options.bg then
    bg = backgrounds[options.bg]
  end

  return setmetatable({
    x = options.x,
    y = options.y,
    width = width,
    height = height,
    disabled = options.disabled,
    invisible = options.invisible,
    ondrop = options.ondrop,
    bg = bg
  }, M)
end

function M:draw()
  local r,g,b, a = love.graphics.getColor()
  love.graphics.setColor(r,r,r, 0.5)

  if not self.invisible then
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 5, 5)
    if self.bg then
      love.graphics.setColor(r,r,r, 0.5)
      love.graphics.draw(card_atlas, self.bg, self.x, self.y, 0, Config.scale)
    end
  end



  love.graphics.setColor(r,g,b, a)
end

function M:card_colide(card)
  return card.x < self.x+self.width and
    card.x + card.width > self.x and
    card.y  < self.y+self.height and
    card.y + card.height > self.y
end

function M:ondrop(cards)
  for _, card in pairs(cards) do
    card:move(self.x, self.y)
  end
end

return M
