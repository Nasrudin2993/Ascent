WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

require 'Animation'
require 'Map'
require 'Player'
require 'Robot'

math.randomseed(os.time())

love.graphics.setDefaultFilter('nearest', 'nearest')

-- Font courtesy of dafont.com. Source: https://www.dafont.com/pixeled.font
smallFont = love.graphics.newFont('fonts/Pixeled.ttf', 18)
bigFont = love.graphics.newFont('fonts/Pixeled.ttf', 36)

-- Load sound effects as audio sources
coinPickup = love.audio.newSource('sounds/CoinPickup.wav', 'static')
damageTaken = love.audio.newSource('sounds/DamageTaken.wav', 'static')
playerAttack = love.audio.newSource('sounds/PlayerAttack.wav', 'static')
playerDie = love.audio.newSource('sounds/PlayerDie.wav', 'static')
playerHitRobot = love.audio.newSource('sounds/PlayerHitRobot.wav', 'static')
playerJump = love.audio.newSource('sounds/PlayerJump.wav', 'static')
robotAttack = love.audio.newSource('sounds/RobotAttack.wav', 'static')
robotDie = love.audio.newSource('sounds/RobotDie.wav', 'static')
mainMusic = love.audio.newSource('sounds/Ascent.wav', 'static')
levelComplete = love.audio.newSource('sounds/LevelComplete.wav', 'static')

function love.load()

mainMusic:setLooping(true)
mainMusic:play()

level = 1

map = Map(1, 0, level)

love.window.setTitle("Ascent")
love.mouse.setVisible(false)
love.mouse.setGrabbed(true)
love.window.setMode(map.mapWidthPixels, WINDOW_HEIGHT, {
    fullscreen = false,
    resizable = false,
    vsync = true
    })

end

function love.keypressed(key)

    if map.victory == false and key == 'escape' then
        love.event.quit()
    end
    if key == 'space' then
        map.player:checkJumps()
    end
    if key == 'lshift' then
        map.player:attack()
    end
    if map.victory == true and (key == 'enter' or key == 'return') then
        level = level + 1
        map = Map(map.difficulty*1.1, map.score, level)
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
    love.graphics.translate(math.floor(-map.camX + 0.5), math.floor(-map.camY + 0.5))
    love.graphics.clear(35/255, 35/255, 35/255, 255/255)
    love.graphics.setFont(smallFont)
    map:render()
end
