local Physics = {}

Physics.newBody = function(x,y,a)
    local Body = {
        x = x,
        y = y,
        acc = a,
        velx = 0,
        vely = 0,
        maxSpeed = 3.716
    }

    function Body:integrate(dt, dirx, diry)
        local pixelPerSecScale = 100
        local frictionCoeff = 0.0514

        -- normalize directions
        local len = math.sqrt(dirx * dirx + diry * diry)
        if len > 1 then
            dirx = dirx / len
            diry = diry / len
        end

        self.velx = self.velx + self.acc * dt * dirx
        self.vely = self.vely + self.acc * dt * diry

        local vellen = math.sqrt(self.velx * self.velx + self.vely * self.vely)
        if vellen > self.maxSpeed then
            self.velx = self.velx / (vellen / self.maxSpeed)
            self.vely = self.vely / (vellen / self.maxSpeed)
        end

        self.x = self.x + self.velx * dt * pixelPerSecScale
        self.y = self.y + self.vely * dt * pixelPerSecScale

        if math.abs(dirx) == 0 then -- add friction when not moving
            if math.abs(self.velx) > frictionCoeff * self.acc * dt then
                self.velx = self.velx - self.velx * dt * self.acc / 9
            else
                self.velx = 0
            end
        end
        if math.abs(diry) == 0 then -- same for y-axis
            if math.abs(self.vely) > frictionCoeff * self.acc * dt then
                self.vely = self.vely - self.vely * dt * self.acc / 9
            else
                self.vely = 0
            end
        end
    end
    return Body
end

Physics.newSphereCollider = function(x, y, r)
    local Collider = {
        x = x,
        y = y,
        r = r
    }

    function Collider:updatePos(_x, _y)
        self.x = _x
        self.y = _y
    end

    function Collider:CheckCollision(other) -- sphere only
        local dx = other.x - self.x
        local dy = other.y - self.y
        local distanceSq = dx * dx + dy * dy
        local radiusSum = self.r + other.r
        if distanceSq <= radiusSum * radiusSum then
            return true
        end
        return false
    end
    return Collider
end

return Physics;