WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

require 'push'
Class = require 'class'

require 'Animation'
require 'Map'
require 'Player'
require 'Robot'

math.randomseed(os.time())

function love.load()

love.window.setMode(1280, 720, {fullscreen = false, vsync = true})

love.graphics.setDefaultFilter('nearest', 'nearest')

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
        map.camY = map.camY - 60
    end
    if love.keyboard.isDown('s') then
        map.camY = map.camY + 60
    end
    if love.keyboard.isDown('d') then
        map.camX = map.camX + 60
    end
    if love.keyboard.isDown('a') then
        map.camX = map.camX - 60
    end

end

function love.draw()
    love.graphics.translate(math.floor(-map.camX + 0.5), math.floor(-map.camY + 0.5))
    love.graphics.clear(70/255, 70/255, 70/255, 255/255)
    map:render()
end

function newMap(level)
    map = Map()
    map.difficulty = level / level * 1.1

end
