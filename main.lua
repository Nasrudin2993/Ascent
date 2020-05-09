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

map = Map(1, 0)

love.window.setTitle("Ascent")
love.mouse.setVisible(false)
love.mouse.setGrabbed(true)
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
    end
    if key == 'space' then
        map.player:checkJumps()
    end
    if key == 'lshift' then
        map.player:attack()
    end
    if map.victory == true and (key == 'enter' or key == 'return') then
        map = Map(map.difficulty*1.1, map.score)
    end
end

function love.update(dt)

if not map.victory then
    if love.keyboard.isDown('w') then
        map.camY = math.max(0, map.camY - 30)
    end
    if love.keyboard.isDown('s') then
        map.camY = math.min(map.mapHeightPixels - WINDOW_HEIGHT/2, map.camY + 30)
    end
    map:update(dt)

end

end

function love.draw()
    --push:apply('start')
    love.graphics.translate(math.floor(-map.camX + 0.5), math.floor(-map.camY + 0.5))
    love.graphics.clear(35/255, 35/255, 35/255, 255/255)
    map:render()
    --push:apply('end')
end
