local push = require("vendor.push")
local lip = require("vendor.lip")
local loader = require("src.loader")
local player = require("src.models.player")
local enemy = require("src.models.enemy")

-- TODO:
-- Target lua 5.1(in .luarc.json) for web compatibility(fix errors)
-- Fix debuge stuff(find the best approach)
-- Handle the gamestate in update and draw:
-- Add a menu screen + settings(maybe also ui components?)

---@class Object
---@field x integer
---@field y integer
---@field sprite love.Image
---@field update? fun(self, dt:number)

function love.load()
	--[[ Constants(not supposed to change): denoted with CAPITALIZED snake_case ]]
	TILE_SIZE = 32
	GAME_WIDTH, GAME_HEIGHT = 1024, 768
	SETTINGS_FILENAME = "settings.ini"

	-- Reading environment variable DEBUG and load the dbg tool
	DEBUG = os.getenv("DEBUG")
	if DEBUG then
		dbg = require("tools.debugger")
	end

	push.setupScreen(GAME_WIDTH, GAME_HEIGHT)
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.graphics.setNewFont(36)

	--- A set of named values that represent the possible game states
	---@enum Gamestate
	GameState = {
		menu = 1,
		playing = 2,
		paused = 3,
		gameOver = 4,
	}

	-- local path = love.filesystem.getAppdataDirectory()

	-- local path = love.filesystem.getIdentity()
	-- local isFile = love.filesystem.exists("settings.ini")
	-- assert(isFile, "does not exist")

	-- Read settings
	local data = lip.load(SETTINGS_FILENAME)
	if not data then
		-- Default settings
		-- TODO: replace with actual settings
		data =
		{
			sound =
			{
				left = 70,
				right = 80,
			},
			screen =
			{
				width = 960,
				height = 544,
				caption = "Window\'s caption",
				focused = true,
			},
		}
		lip.save(SETTINGS_FILENAME, data)
	end

	-- Global `game` object
	Game = {
		--- @type Gamestate
		currentGameState = GameState.menu,
		assets = loader.load(),
		settings = data,
	}
	-- The latest objects gets drawn on top
	--- @type Object[]
	Game.objects = {
		-- Static game objects
		{ x = 300, y = 300, sprite = Game.assets.images.test },
		{ x = 350, y = 400, sprite = Game.assets.images.test },

		-- Enemies
		enemy.new(400, 100),
		enemy.new(500, 150),
		enemy.new(600, 120),

		-- Player
		player.new(100, 100),
	}
end

---@param dt number
function love.update(dt)
	for _, obj in ipairs(Game.objects) do
		if obj.update then obj:update(dt) end
	end
end

function love.draw()
	if DEBUG then
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(("FPS: %d"):format(love.timer.getFPS()), 8, 8)
		print(dbg.pp(Game))
		print(dbg.pp(Game.objects[1]))
	end

	push.start()
	love.graphics.clear(0, 0, 0.3) -- background

	for _, obj in ipairs(Game.objects) do
		-- if DEBUG then
		-- print(Debug.pp(obj.sprite), type(obj.__index))
		-- print(Debug.pp(obj.sprite))
		-- end
		love.graphics.draw(obj.sprite, obj.x, obj.y)
	end

	push.finish()
end

function love.resize()
	return push.resize()
end
