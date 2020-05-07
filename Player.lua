require 'Map'

Player_mt = {__index = Player, __call = function (p, ...)
            local o = setmetatable({}, Player_mt)
            Player_mt.__index = p
            o:init(...)
            return o end}
Player = setmetatable({}, Player_mt)

local WALK_SPEED = 300
local JUMP_HEIGHT = 550
local GRAVITY = 15
local ATTACK_RANGE = 50

function Player:init(map)

self.map = map

self.x = 0
self.y = 0

self.width = 32
self.height = 64
self.xOffset = 16
self.yOffset = 32

self.texture = love.graphics.newImage('graphics/Alice_64_Idle.png')
self.frames = {}
self.currentFrame = nil
self.state = 'idle'
self.direction = 'right'
self.doubleJump = true
self.dx = 0
self.dy = 0
self.y = map.tileHeight * (map.mapHeight - 2) - self.height -2
self.x = map.tileWidth * 5
self.health = 100
self.weaponDamage = math.floor(40 / self.map.difficulty)
self.attackTimer = 1

self.currentFrame = nil

self.animations = {
    ['idle'] = Animation({
        texture = self.texture,
         frames = {
             love.graphics.newQuad(0, 0, 32, 64, self.texture:getDimensions()),
             love.graphics.newQuad(32, 0, 32, 64, self.texture:getDimensions()),
             love.graphics.newQuad(64, 0, 32, 64, self.texture:getDimensions()),
             love.graphics.newQuad(96, 0, 32, 64, self.texture:getDimensions()),
         },
         interval = 0.3
    })
}
self.actionStates = {
    ['idle'] = function (dt)

        if love.keyboard.isDown('a') then
            self.dx = -WALK_SPEED
            self.direction = 'left'
            self.state = 'walking'
        elseif love.keyboard.isDown('d') then
            self.dx = WALK_SPEED
            self.direction = 'right'
            self.state = 'walking'
        elseif love.keyboard.isDown('s') then
            self.state = 'jumping'
        else
            self.dx = 0
        end
    end,
        ['walking'] = function (dt)

            if love.keyboard.isDown('a') then
                self.dx = -WALK_SPEED
                self.direction = 'left'
                self.state = 'walking'
            elseif love.keyboard.isDown('d') then
                self.dx = WALK_SPEED
                self.direction = 'right'
                self.state = 'walking'
            else
                self.dx = 0
                self.state = 'idle'
            end
            if not self.map:collisionCheck(self.map:getTile(self.y + self.height, self.x)) or
            self.map:collisionCheck(self.map:getTile(self.y + self.height, self.x + self.width - 1)) then
                self.state = 'jumping'
            end
    end,
        ['jumping'] = function(dt)
            if love.keyboard.isDown('a') then
                self.dx = -WALK_SPEED
                self.direction = 'left'
            elseif love.keyboard.isDown('d') then
                self.dx = WALK_SPEED
                self.direction = 'right'
            else
                self.dx = 0
            end

            self.dy = self.dy + GRAVITY

            if self.dy >= 0 and not love.keyboard.isDown('s') then
                    if self.map:collisionCheck(self.map:getTile(self.y + self.height, self.x)) or
                    self.map:collisionCheck(self.map:getTile(self.y + self.height, self.x + self.width - 1)) then
                        if self.y % self.map.tileHeight <= map.tileHeight/2 then
                            self.dy = 0
                            self.y = self.y-self.y % self.map.tileHeight
                            self.state = 'idle'
                            self.doubleJump = true
                        end
                    end
                end
            self:checkCoinCollision()
        end
}

self.animation = self.animations['idle']
self.currentFrame = self.animation:getCurrentFrame()

end

function Player:update(dt)

    self.actionStates[self.state](dt)
    self.currentFrame = self.animation:getCurrentFrame()
    self.animation:update(dt)
    self.x = math.max(0, math.min(self.map.mapWidthPixels - self.width, self.x + self.dx * dt))
    self.y = math.max(0, math.min(map.tileHeight * (map.mapHeight - 2) - self.height, self.y + self.dy * dt))
    self.attackTimer = self.attackTimer + 1*dt
    if math.abs(self.x - self.map.victoryPortal.x) < 10 and math.abs(self.y + self.height/2 - self.map.victoryPortal.y) < 10 then
        self.map.victory = true
    end
end

function Player:checkJumps()

        if self.state ~= 'jumping' then
            self.dy = -JUMP_HEIGHT
            self.state = 'jumping'
        elseif self.state == 'jumping' and self.doubleJump == true then
            self.dy = -JUMP_HEIGHT*1.5
            self.doubleJump = false
        end
end

function Player:attack()
    if self.attackTimer >= 0.2 then
        for k, v in pairs(self.map.robots) do
            if self.direction == 'left' and math.abs(self.x - v.x - v.width)  < ATTACK_RANGE and math.abs(self.y - v.y) < ATTACK_RANGE/2 then
                v.health = v.health - self.weaponDamage
                self.attackTimer = 0
            elseif self.direction == 'right' and math.abs(self.x + self.width - v.x) < ATTACK_RANGE and math.abs(self.y - v.y) < ATTACK_RANGE/2 then
                v.health = v.health - self.weaponDamage
                self.attackTimer = 0
            end
        end
    end
end

function Player:checkCoinCollision()
    if self.map:getTile(self.y + self.height/2, self.x + self.width/2) == TILE_COIN_1 then
        self.map.tiles[math.floor((self.y + self.height/2) / self.map.tileHeight) + 1][math.floor((self.x + self.width/2) / self.map.tileWidth) + 1] = TILE_EMPTY
        self.map.score = math.floor(self.map.score + 20*self.map.difficulty)
    elseif  self.map:getTile(self.y + self.height, self.x + self.width) == TILE_COIN_1 then
        self.map.tiles[math.floor((self.y + self.height) / self.map.tileHeight) + 1][math.floor((self.x + self.width) / self.map.tileWidth) + 1] = TILE_EMPTY
        self.map.score = math.floor(self.map.score + 20*self.map.difficulty)
    elseif  self.map:getTile(self.y, self.x) == TILE_COIN_1 then
        self.map.tiles[math.floor(self.y / self.map.tileHeight) + 1][math.floor(self.x / self.map.tileWidth) + 1] = TILE_EMPTY
        self.map.score = math.floor(self.map.score + 20*self.map.difficulty)
    end
end

function Player:render()

    local scaleX

    if self.direction == 'right' then
        scaleX = 1
    else
        scaleX = -1
    end
    love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x + self.xOffset),
        math.floor(self.y + self.yOffset), 0, scaleX, 1, self.xOffset, self.yOffset)
    love.graphics.print("Health: " .. self.health, self.map.camX + 10, self.map.camY + WINDOW_HEIGHT - 40)

end
