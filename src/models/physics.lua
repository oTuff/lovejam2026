local physics = {}

---@class Body 
---@field velx number 
---@field vely number
---@field ax number
---@field ay number
---@field maxSpeed number
local Body = {}
Body.__index = Body;

function Body.new(x, y)
	local self = setmetatable({}, Body)
    self.x = x
    self.y = y
    self.ax = 0
    self.ay = 0
    self.velx = 0
    self.vely = 0
    self.maxSpeed = 2.716
    return self;
end

function Body:addForce(dirx, diry)
    self.ax = dirx;
    self.ay = diry;
end

function Body:clearForce()
    self.ax = 0
    self.ay = 0
end

function Body:integrate(dt)
    local pixelPerSecScale = 100
    local frictionCoeff = 0.514

    self.velx = self.velx + self.ax * dt
    self.vely = self.vely + self.ay * dt

    local vellen = math.sqrt(self.velx * self.velx + self.vely * self.vely)
    if vellen > self.maxSpeed then
        self.velx = self.velx / (vellen / self.maxSpeed)
        self.vely = self.vely / (vellen / self.maxSpeed)
    end

    self.x = self.x + self.velx * dt * pixelPerSecScale
    self.y = self.y + self.vely * dt * pixelPerSecScale

    if math.abs(self.ax) == 0 then -- add friction when not moving
        if math.abs(self.velx) > frictionCoeff * dt then
            self.velx = self.velx - self.velx * dt / 9
        else
            self.velx = 0
        end
    end
    if math.abs(self.ay) == 0 then -- same for y-axis
        if math.abs(self.vely) > frictionCoeff * dt then
            self.vely = self.vely - self.vely * dt / 9
        else
            self.vely = 0
        end
    end
end

physics.Body = Body
return physics;