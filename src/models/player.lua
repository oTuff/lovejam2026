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
 	self.body = physics.Body.new(x, y)
	self.sprite = spriteOverwrite or Game.assets.images.playerImg
	return self
end

function Player:update(dt)
	self.body:clearForce()

	--gravity
	if (self.body.y <= GAME_HEIGHT - TILE_SIZE) then
		self.body:addForce(0, 9.8)
	end

	if (self.body.y >= GAME_HEIGHT - TILE_SIZE or self.body.y <=  0) then
		self.body.vely = 0
	end

	-- keyboard handling --
	if love.keyboard.isDown("w") then
		self.body:addForce(0, -50);
	end
	if love.keyboard.isDown("s") then
		self.body:addForce(0, 5);
	end
	if love.keyboard.isDown("d") then
		self.body:addForce(5, 0);
	end
	if love.keyboard.isDown("a") then
		self.body:addForce(-5, 0);
	end

	self.body:integrate(dt)

	-- TODO: should use the sprite w and h instead of the TILE_SIZE
	-- clamp
	self.body.x = math.max(0, math.min(GAME_WIDTH - TILE_SIZE, self.body.x))
	self.body.y = math.max(0, math.min(GAME_HEIGHT - TILE_SIZE, self.body.y))
end

return Player
