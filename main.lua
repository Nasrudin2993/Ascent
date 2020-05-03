WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 1280
VIRTUAL_HEIGHT = 720

push = require 'push'
Class = require 'class'

require 'Animation'
require 'Map'
require 'Player'
require 'Robot'

math.randomseed(os.time())

love.graphics.setDefaultFilter('nearest', 'nearest')

function love.load()

    love.window.setTitle("Ascent")
    love.window.setMode(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    --[[push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = true,
        resizable = true
    })--]]

level = 1

map = Map()

end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

function love.update(dt)

    if love.keyboard.isDown('w') then
        map.camY = math.max(0, map.camY - 30)
    end
    if love.keyboard.isDown('s') then
        map.camY = math.min(map.mapHeightPixels - VIRTUAL_HEIGHT/2, map.camY + 30)
    end
    map:update(dt)
end

function love.draw()
    --push:apply('start')
    love.graphics.translate(math.floor(-map.camX + 0.5), math.floor(-map.camY + 0.5))
    love.graphics.clear(70/255, 70/255, 70/255, 255/255)
    map:render()
    --push:apply('end')
end

function newMap(level)
    map = Map()
    map.difficulty = level / level * 1.1

end
