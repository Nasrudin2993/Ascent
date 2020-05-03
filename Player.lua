Player = Class{}

local WALK_SPEED = 15
local JUMP_VELOCITY = 400

function player:init()

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
self.y = map.tileHeight * ((map.mapHeight - 2) / 2) - self.height
self.x = map.tileWidth * 5

end

function player:update()

end

function player:render()

end
