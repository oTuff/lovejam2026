---@class Player: Object
---@field speed number
local Player = {}
Player.__index = Player

---@param x integer
---@param y integer
---@param spriteOverwrite? love.Image
---@return Player
function Player.new(x, y, spriteOverwrite)
	local self = setmetatable({}, Player)
	self.x = x or 100
	self.y = y or 100
	self.speed = 200
	self.sprite = spriteOverwrite or Game.assets.images.test
	return self
end

function Player:update(dt)
	local vx, vy = 0, 0

	if love.keyboard.isDown("left") then vx = -self.speed end
	if love.keyboard.isDown("right") then vx = self.speed end
	if love.keyboard.isDown("up") then vy = -self.speed end
	if love.keyboard.isDown("down") then vy = self.speed end

	self.x = self.x + vx * dt
	self.y = self.y + vy * dt

	-- TODO: should use the sprite w and h instead of the TILE_SIZE
	-- clamp
	self.x = math.max(0, math.min(GAME_WIDTH - TILE_SIZE, self.x))
	self.y = math.max(0, math.min(GAME_HEIGHT - TILE_SIZE, self.y))
end

return Player
