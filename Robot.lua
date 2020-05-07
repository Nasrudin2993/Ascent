-- Sets robot metatable. Indexes functions to Robot table.
Robot_mt =  {__index = Robot, __call = function(r, ...)
                                    local o = setmetatable({}, Robot_mt)
                                    Robot_mt.__index = r
                                    o:init(...)
                                    return o end}
Robot = setmetatable({}, Robot_mt)

function Robot:init(map, y, x)

self.map = map
self.width = 32
self.height = 64
self.moveSpeed = 100

self.y = y - self.height or 0
self.x = x or 0
self.direction = 'right'

self.xOffset = 16
self.yOffset = 32
self.health = math.floor(100 * self.map.difficulty)
self.isDead = false

self.state = 'walking'
self.attackTimer = 0
self.attackCheck = false
self.actionStates = {
    ['walking'] = function(dt) end,
    ['attacking'] = function(dt) end
}

end

function Robot:update(dt)

    if self.isDead == false then

        if self.health < 0 then
            self.map.score = math.floor(self.map.score + 20*self.map.difficulty )
            self.isDead = true
        end
        local playerCheck = nil
        playerCheck = self:checkForPlayer(dt)
        if playerCheck ~= nil then
            self.direction = playerCheck
            self.state = 'attacking'
            self.attackTimer = self.attackTimer + 1*dt
        else self.state = 'walking'
            self.attackCheck = false
            self.attackTimer = 0.5
        end
        if self.state == 'walking' then
            if self:atEdge() == true then
                if self.direction == 'right' then self.direction = 'left'
                else self.direction = 'right'
                end
            end
            if self.direction == 'right' then
                self.x = self.x + self.moveSpeed * dt
            else self.x = self.x - self.moveSpeed * dt
            end
        elseif self.state == 'attacking' then
            if self.attackTimer >= 1 then
                self:attackPlayer()
                self.attackTimer = 0
            end
        end
    end
end

function Robot:atEdge()

    if self.map:getTile(self.y + self.height, self.x) ~= TILE_LEDGE or self.map:getTile(self.y + self.height, self.x + self.width) ~= TILE_LEDGE then
        return true
    else return false
    end
end

function Robot:checkForPlayer(dt)
    if math.abs(self.x - self.map.player.x - self.map.player.width) < self.width/2 and math.abs(self.y - self.map.player.y) < self.height/2 then
        return 'left'
    elseif math.abs(self.x + self.width - self.map.player.x) < self.width/2 and math.abs(self.y - self.map.player.y) < self.height/2 then
        return 'right'
    else return nil
    end
end

function Robot:attackPlayer()
    self.attackCheck = true
    self.map.player.health = self.map.player.health - math.floor(10*map.difficulty)
end

function Robot:render()

if self.attackCheck == true then
    love.graphics.print("Attack!", self.x + 50, self.y)
end
love.graphics.print(self.health, self.x - 50, self.y)

love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

end
