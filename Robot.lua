-- Sets robot metatable. Indexes functions to Robot table.
Robot_mt =  {__index = Robot, __call = function(r, ...)
                                    local o = setmetatable({}, Robot_mt)
                                    Robot_mt.__index = r
                                    o:init(...)
                                    return o end}
Robot = setmetatable({}, Robot_mt)

function Robot:init(y, x)

self.width = 32
self.height = 64

self.y = y - self.height or 0
self.x = x or 0
self.dy = 0
self.dx = 0
self.direction = 'left'

self.xOffset = 16
self.yOffset = 32

end

function Robot:update()


end

function Robot:render()

love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

end
