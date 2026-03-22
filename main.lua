local push = require("vendor.push")
local lip = require("vendor.lip")
local loader = require("src.loader")
local player = require("src.models.player")
local enemy = require("src.models.enemy")
local physics = require("src.models.physics")
local sti = require("vendor.sti")

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

	push.setupScreen(GAME_WIDTH, GAME_HEIGHT)
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.graphics.setNewFont(36)

	Gamemap = sti("assets/tield/frø.lua")
	Gamemap:resize(GAME_WIDTH, GAME_HEIGHT)
	WORLD_WIDTH  = Gamemap.width * Gamemap.tilewidth
	WORLD_HEIGHT = Gamemap.height * Gamemap.tileheight

	-- Reading environment variable DEBUG and load the dbg tool
	DEBUG        = os.getenv("DEBUG")
	if DEBUG then
		dbg = require("tools.debugger")
	end

	--- A set of named values that represent the possible game states
	---@enum Gamestate
	GameState = {
		menu = 1,
		playing = 2,
		paused = 3,
		gameOver = 4,
	}

	-- Read settings
	local data
	if love.filesystem.getInfo(SETTINGS_FILENAME) then
		data = lip.load(SETTINGS_FILENAME)
	end
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
	Game.camera = { x = 0, y = 0 }
	Game.player = player.new(100, 100)
	-- The latest objects gets drawn on top
	--- @type Object[]
	Game.objects = {
		-- Static game objects
		{ x = 300, y = 300, sprite = Game.assets.images.test },
		{ x = 350, y = 400, sprite = Game.assets.images.test },

		-- Enemies
		enemy.new(400, 100),
		enemy.new(500, 250),
		enemy.new(600, 600),
	}
end

---@param dt number
function love.update(dt)
	local p = Game.player

	p:update(dt)

	for _, obj in ipairs(Game.objects) do
		if physics.CheckCollosion(p, obj) then
			print("col " .. p.body.x .. " " .. p.body.y)
		end

		if obj.update then
			obj:update(dt)
		end
	end

	-- Camera
	local cam = Game.camera
	local targetX = p.body.x - GAME_WIDTH / 2
	local targetY = p.body.y - GAME_HEIGHT / 2
	local smoothing = 1 - math.exp(-5 * dt)
	cam.x = cam.x + (targetX - cam.x) * smoothing
	cam.y = cam.y + (targetY - cam.y) * smoothing
	cam.x = math.max(0, math.min(WORLD_WIDTH - GAME_WIDTH, cam.x))
	cam.y = math.max(0, math.min(WORLD_HEIGHT - GAME_HEIGHT, cam.y))
end

function love.draw()
	if DEBUG then
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(("FPS: %d"):format(love.timer.getFPS()), 8, 8)
		print(dbg.pp(Game))
		print(dbg.pp(Game.objects[1]))
	end

	push.start()
	local cx = -math.floor(Game.camera.x)
	local cy = -math.floor(Game.camera.y)

	-- Fix push working with sti
	local sx, sy, sw, sh = love.graphics.getScissor()
	love.graphics.setScissor()
	Gamemap:draw(cx, cy)
	love.graphics.setScissor(sx, sy, sw, sh)

	love.graphics.push()
	love.graphics.translate(cx, cy)

	local p = Game.player
	love.graphics.draw(p.sprite, p.body.x, p.body.y)

	for _, obj in ipairs(Game.objects) do
		love.graphics.draw(obj.sprite, obj.x, obj.y)
	end

	love.graphics.pop()
	push.finish()
end

function love.resize()
	Gamemap:resize(GAME_WIDTH, GAME_HEIGHT)
	return push.resize()
end
