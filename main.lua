WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

push = require 'push'

require 'Animation'
require 'Map'
require 'Player'
require 'Robot'

math.randomseed(os.time())

love.graphics.setDefaultFilter('nearest', 'nearest')

function love.load()

level = 1

map = Map()

    love.window.setTitle("Ascent")
    love.window.setMode(map.mapWidthPixels, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    --[[push:setupScreen(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = true,
        resizable = true
    })--]]



end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'space' then
        map.player:checkJumps()
    end
end

function love.update(dt)

    if love.keyboard.isDown('w') then
        map.camY = math.max(0, map.camY - 30)
    end
    if love.keyboard.isDown('s') then
        map.camY = math.min(map.mapHeightPixels - WINDOW_HEIGHT/2, map.camY + 30)
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
