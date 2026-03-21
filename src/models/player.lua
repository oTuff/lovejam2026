local physics = require("src.models.physics")

---@class Player: Object
---@field body Body
local Player = {}
Player.__index = Player

---@param x integer
---@param y integer
---@param spriteOverwrite? love.Image
---@return Player
function Player.new(x, y, spriteOverwrite)
	local self = setmetatable({}, Player)
 	self.body = physics.Body.new(x, y, 5)
	self.sprite = spriteOverwrite or Game.assets.images.test
	return self
end

function Player:update(dt)
	local dirx = 0.0
	local diry = 0.0

	-- keyboard handling --
	if love.keyboard.isDown("w") then
		diry = diry - 1.0
	end
	if love.keyboard.isDown("s") then
		diry = diry + 1.0
	end
	if love.keyboard.isDown("d") then
		dirx = dirx + 1.0
	end
	if love.keyboard.isDown("a") then
		dirx = dirx - 1.0
	end

	self.body:integrate(dt, dirx, diry)

	-- TODO: should use the sprite w and h instead of the TILE_SIZE
	-- clamp
	self.body.x = math.max(0, math.min(GAME_WIDTH - TILE_SIZE, self.body.x))
	self.body.y = math.max(0, math.min(GAME_HEIGHT - TILE_SIZE, self.body.y))
end

return Player
