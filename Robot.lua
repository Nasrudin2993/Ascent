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
self.direction = 'left'

self.xOffset = 16
self.yOffset = 32
self.health = math.floor(100 * self.map.difficulty)
self.isDead = false

self.attackTimer = 0
self.actionStates = {
    ['walking'] = function(dt)
        local playerCheck = nil
        playerCheck = self:checkForPlayer(dt)
        if playerCheck ~= nil then
            self.direction = playerCheck
            self.animations['attack']:restart()
            self.state = 'attacking'
            self.attackTimer = self.attackTimer + 1*dt
        else
            self.animation = self.animations['walking']
            self.attackTimer = 0.5
        end
        self:checkEdge()
        if self.direction == 'right' then
            self.x = self.x + self.moveSpeed * dt
        else self.x = self.x - self.moveSpeed * dt
        end

    end,
    ['attacking'] = function(dt)
        if self.attackTimer >= 1 then
            self.animation = self.animations['attack']
            self:attackPlayer()
            self.attackTimer = 0
        else self.attackTimer = self.attackTimer + 1*dt
        end
        if not self:checkForPlayer(dt) then
        self.state = 'walking'
        end
    end,
    ['dead'] = function(dt)
        self.animation = self.animations['death']
        if self.currentFrame == self.animations['death'].frames[3] then
            self.isDead = true
        end
    end
}

self.texture = love.graphics.newImage('graphics/Robots.png')
self.frames = {}
self.currentFrame = nil

self.animations = {
    ['walking'] = Animation({
        texture = self.texture,
        frames = {
            love.graphics.newQuad(0, 0, 32, 64, self.texture:getDimensions()),
            love.graphics.newQuad(32, 0, 32, 64, self.texture:getDimensions()),
        },
        interval = 0.5,
        noRepeat = false
    }),
    ['attack'] = Animation({
        texture = self.texture,
        frames = {
            love.graphics.newQuad(64, 0, 32, 64, self.texture:getDimensions()),
            love.graphics.newQuad(96, 0, 32, 64, self.texture:getDimensions()),
        },
        interval = 0.2,
        noRepeat = false
    }),
    ['death'] = Animation({
        texture = self.texture,
        frames = {
            love.graphics.newQuad(0, 64, 32, 64, self.texture:getDimensions()),
            love.graphics.newQuad(32, 64, 32, 64, self.texture:getDimensions()),
            love.graphics.newQuad(64, 64, 32, 64, self.texture:getDimensions()),
        },
        interval = 0.2,
        noRepeat = true
    })
}

self.state = 'walking'
self.animation = self.animations['walking']

end

function Robot:update(dt)

    self.actionStates[self.state](dt)
    self.currentFrame = self.animation:getCurrentFrame()
    self.animation:update(dt)
    if self.health < 0 then
        self.state = 'dead'
        love.audio.play(robotDie)
    end
end

function Robot:checkEdge()

    if self.direction == 'right' and not self.map:collisionCheck(self.map:getTile(self.y + self.height, self.x + self.width)) then
        self.direction = 'left'
    elseif self.direction == 'left'and not self.map:collisionCheck(self.map:getTile(self.y + self.height, self.x)) then
        self.direction = 'right'
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
    if not self.map.player.isDead then
        self.map.player.health = self.map.player.health - math.floor(10*map.difficulty)
        love.audio.play(damageTaken)
    end
end

function Robot:render()

    if self.direction == 'right' then
        scaleX = -1
    else
        scaleX = 1
    end
    love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x + self.xOffset),
        math.floor(self.y + self.yOffset), 0, scaleX, 1, self.xOffset, self.yOffset)

end
