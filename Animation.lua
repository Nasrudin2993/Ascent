Animation_mt = {__index = Animation, __call = function(o, ...)
            o:init(...)
            return setmetatable(o, Map_mt)  end}
Animation = setmetatable({}, Animation_mt)

function Animation:init(params)

    self.texture = params.texture
    self.frames = params.frames or {}
    self.interval = params.interval or 0.05
    self.timer = 0

    self.currentFrame = 1
end

function Animation:getCurrentFrame()
    return self.frames[self.currentFrame]
end

function Animation:restart()
    self.timer = 0
    self.currentFrame = 1
end

function Animation:update(dt)
    self.timer = self.timer + dt
    while self.timer > self.interval do
        self.timer = self.timer - self.interval
        if self.currentFrame ~= #self.frames then
            self.currentFrame = self.currentFrame + 1
        else
            self.currentFrame = 1
        end
    end
end
