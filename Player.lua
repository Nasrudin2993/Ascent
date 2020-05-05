require 'Map'

Player_mt = {__index = Player, __call = function (o, ...)
            o:init(...)
            return setmetatable(o, Player_mt) end}
Player = setmetatable({}, Player_mt)

local WALK_SPEED = 15
local JUMP_VELOCITY = 400

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
self.dx = 0
self.dy = 0
self.y = map.tileHeight * (map.mapHeight - 2) - self.height
self.x = map.tileWidth * 5

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

self.animation = self.animations['idle']
self.currentFrame = self.animation:getCurrentFrame()

end

function Player:update(dt)

    self.currentFrame = self.animation:getCurrentFrame()
    self.animation:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
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

end
