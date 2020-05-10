require 'Map'

-- Sets metaatable and call functions for Player class, returning instance of class upon call
Player_mt = {__index = Player, __call = function (p, ...)
            local o = setmetatable({}, Player_mt)
            Player_mt.__index = p
            o:init(...)
            return o end}
Player = setmetatable({}, Player_mt)

-- global static values for Player attributes
local WALK_SPEED = 300
local JUMP_HEIGHT = 550
local GRAVITY = 15
local ATTACK_RANGE = 50

-- Initialises an instance of the player class and returns it when Player is called as a function
function Player:init(map)

-- stores instance of map in player and sets attributes
self.map = map


self.width = 32
self.height = 64
self.xOffset = 16
self.yOffset = 32

-- sets texture for player spritesheet and creates table to store frames for animations

self.texture = love.graphics.newImage('graphics/Alice 64.png')
self.frames = {}
self.currentFrame = nil

self.direction = 'right'
self.doubleJump = true
self.dx = 0
self.dy = 0
self.y = map.tileHeight * (map.mapHeight - 2) - self.height -2
self.x = math.floor(self.map.mapWidthPixels / 2 - self.map.tileWidth)
self.health = 100
self.isDead = false
self.weaponDamage = math.floor(40 / self.map.difficulty)
self.attackTimer = 1

self.currentFrame = nil

self.gameOverPlayed = false

-- sets player animations by creating new instances of Animation class with chosen frames and interval for looping animations
self.animations = {
    ['idle'] = Animation({
        texture = self.texture,
         frames = {
             love.graphics.newQuad(0, 0, 32, 64, self.texture:getDimensions()),
             love.graphics.newQuad(32, 0, 32, 64, self.texture:getDimensions()),
             love.graphics.newQuad(64, 0, 32, 64, self.texture:getDimensions()),
             love.graphics.newQuad(96, 0, 32, 64, self.texture:getDimensions()),
         },
         interval = 0.3,
         noRepeat = false
    }),
    ['walking'] = Animation({
        texture = self.texture,
        frames = {
            love.graphics.newQuad(0, 64, 32, 64, self.texture:getDimensions()),
            love.graphics.newQuad(32, 64, 32, 64, self.texture:getDimensions()),
            love.graphics.newQuad(64, 64, 32, 64, self.texture:getDimensions()),
            love.graphics.newQuad(96, 64, 32, 64, self.texture:getDimensions()),
        },
        interval = 0.15,
        noRepeat = false
    }),
    ['jumping'] = Animation({
        texture = self.texture,
        frames = {
            love.graphics.newQuad(0, 128, 32, 64, self.texture:getDimensions()),
            love.graphics.newQuad(32, 128, 32, 64, self.texture:getDimensions()),
            love.graphics.newQuad(64, 128, 32, 64, self.texture:getDimensions()),
        },
        interval = 0.15,
        noRepeat = true
    }),
    ['attack'] = Animation({
        texture = self.texture,
        frames = {
            love.graphics.newQuad(96, 128, 32, 64, self.texture:getDimensions()),
            love.graphics.newQuad(0, 192, 32, 64, self.texture:getDimensions()),
            love.graphics.newQuad(32, 192, 32, 64, self.texture:getDimensions()),
            love.graphics.newQuad(32, 192, 32, 64, self.texture:getDimensions()),
        },
        interval = 0.10,
        noRepeat = true
    }),
    ['death'] = Animation({
        texture = self.texture,
        frames = {
            love.graphics.newQuad(64, 192, 32, 64, self.texture:getDimensions()),
            love.graphics.newQuad(96, 192, 32, 64, self.texture:getDimensions()),
            love.graphics.newQuad(0, 256, 32, 64, self.texture:getDimensions()),
        },
        interval = 0.3,
        noRepeat = true
    })
}
-- creates table actionStates with functions for each state of player behaviour. Functions are called during each update
self.actionStates = {
    -- idle state: checks for keyboard input and moves player left or right - setting the state to walking and the animation to walking. If down is pressed, the player enters the jumping state and animation instead.
    ['idle'] = function (dt)

        if love.keyboard.isDown('a') then
            self.dx = -WALK_SPEED
            self.direction = 'left'
            self.state = 'walking'
            self.animations['walking']:restart()
            self.animation = self.animations['walking']
        elseif love.keyboard.isDown('d') then
            self.dx = WALK_SPEED
            self.direction = 'right'
            self.state = 'walking'
            self.animations['walking']:restart()
            self.animation = self.animations['walking']
        elseif love.keyboard.isDown('s') then
            self.state = 'jumping'
            self.animation = self.animations['jumping']
        else
            self.dx = 0
        end
        self:checkCoinCollision()
    end,
        -- Walking state: moves plyer left or right based on direction each update. If no button is pressed, player stops and enters idle state.
        ['walking'] = function (dt)

            if love.keyboard.isDown('a') then
                self.dx = -WALK_SPEED
                self.direction = 'left'
            elseif love.keyboard.isDown('d') then
                self.dx = WALK_SPEED
                self.direction = 'right'
            else
                self.dx = 0
                self.state = 'idle'
                self.animation = self.animations['idle']
            end
            -- collision check: Checks if there are tiles directly underneath the player. If there are no tiles, the player falls and enters the jumping state.
            if not self.map:collisionCheck(self.map:getTile(self.y + self.height+1, self.x)) and not
            self.map:collisionCheck(self.map:getTile(self.y + self.height+1, self.x + self.width - 1)) then
                self.animation = self.animations['jumping']
                self.state = 'jumping'
            end
            self:checkCoinCollision()
    end,
        -- Jumping state: Moves player downwards every frame according to gravity, and sideways according to input. Stops if collission with ground is detected.
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
            -- Apply gravity every update
            self.dy = self.dy + GRAVITY
            -- checks if player is moving downwards and s is not pressed on the keyboard (This allows for jumping up through ledges at all times and optionally falling through them on 's' input)
            if self.dy > 0 and not love.keyboard.isDown('s') then
                    -- Checks if there is a ledge below the player.
                    if self.map:collisionCheck(self.map:getTile(self.y + self.height + 1, self.x)) or
                    self.map:collisionCheck(self.map:getTile(self.y + self.height + 1, self.x + self.width - 1)) then
                        -- If there is a ledge at the tile below the player, check if the player's y position is in contact with the ledge or below it (ledges occupy half a tile, this prevents collission with empty bottom half)
                        if self.y % self.map.tileHeight <= map.tileHeight/2 then
                            -- If so, set the player's downwards velocity to 0 and their state to idle. Also reset doubleJump check and change y position to tile above ledge.
                            self.dy = 0
                            self.state = 'idle'
                            self.animation = self.animations['idle']
                            self.doubleJump = true
                            self.y = self.y-(self.y % self.map.tileHeight)
                        end
                    end
                end
            self:checkCoinCollision()
        end,
        -- Death state - Nothing happens for now
        ['dead'] = function(dt)
            self.animation = self.animations['death']
        end
}
-- initialises the player state and animation to idle at the start of the game
self.state = 'idle'
self.animation = self.animations['idle']

end

-- These actions are performed every logic update, meaning timer operations must be normalised due to deltaTime.
function Player:update(dt)

    -- run function in Player's actionState and get their currentFrame of Animation for their animationState. Also update their current animation with timer.
    if self.health <= 0 then
        self.state = 'dead'
        self.isDead = true
        if self.gameOverPlayed == false then
            love.audio.play(playerDie)
            self.gameOverPlayed = true
        end
    end
    self.actionStates[self.state](dt)
    self.currentFrame = self.animation:getCurrentFrame()
    self.animation:update(dt)
    -- Move the player's x and y position based on their delta x and y, limiting movement to within the bounds of the map.
    self.x = math.max(0, math.min(self.map.mapWidthPixels - self.width, self.x + self.dx * dt))
    self.y = math.max(0, math.min(map.tileHeight * (map.mapHeight - 2) - self.height, self.y + self.dy * dt))
    -- update attackTimer
    self.attackTimer = self.attackTimer + 1*dt
    self:stopAttackAnimation()
    -- Check if the player is in contact with the victory portal. If true, this will result in the victory state being initialised.
    if math.abs(self.x - self.map.victoryPortal.x) < 10 and math.abs(self.y + self.height/2 - self.map.victoryPortal.y) < 10 then
        self.map.victory = true
    end
end

-- This function is called when Space is pressed in main.
function Player:checkJumps()
        -- If the player is not already jumping, then jump.
        if self.state ~= 'jumping' then
            self.dy = -JUMP_HEIGHT
            self.state = 'jumping'
            self.animations['jumping']:restart()
            self.animation = self.animations['jumping']
            love.audio.play(playerJump)
        -- if the player is jumping but has not double-jumped, then jump more powerfully and set doubleJump to false. This is set to true again when the player collides with the ground.
        elseif self.state == 'jumping' and self.doubleJump == true then
            self.dy = -JUMP_HEIGHT*1.5
            self.doubleJump = false
            self.state = 'jumping'
            self.animations['jumping']:restart()
            love.audio.play(playerJump)
        end
end

-- The attack function is called by main when lShift is pressed. frequency of attacks is determined by attackTimer.
function Player:attack()
    -- Check if enough time has passed since last attack
    if self.attackTimer >= 0.35 and self.isDead == false then
        -- Set animation to attacking
        self.attackTimer = 0
        self.animations['attack']:restart()
        self.animation = self.animations['attack']
        love.audio.play(playerAttack)
        -- Check if any robots are in attack range based on the direction the player is facing.
        for k, v in pairs(self.map.robots) do
            if self.direction == 'left' and math.abs(self.x - v.x - v.width)  < ATTACK_RANGE and math.abs(self.y - v.y) < ATTACK_RANGE/2 then
                v.health = v.health - self.weaponDamage
                love.audio.play(playerHitRobot)
            elseif self.direction == 'right' and math.abs(self.x + self.width - v.x) < ATTACK_RANGE and math.abs(self.y - v.y) < ATTACK_RANGE/2 then
                v.health = v.health - self.weaponDamage
                love.audio.play(playerHitRobot)
            end
        end
    end
end

function Player:stopAttackAnimation()

    if self.animation == self.animations['attack'] and self.currentFrame == self.animations['attack'].frames[4] then
        self.animation = self.animations[self.state]
    end
end

-- Checks if the player is colliding with coins (pickups)
function Player:checkCoinCollision()
    -- If the player
    local y = math.floor((self.y + self.map.tileHeight) / self.map.tileHeight) + 1
    local x = math.floor(self.x / self.map.tileWidth) + 1
    if self.map.tiles[y][x] == TILE_COIN_1 then
        self.map.tiles[y][x] = TILE_EMPTY
        self.map.score = math.floor(self.map.score + 20*self.map.difficulty)
        love.audio.play(coinPickup)
    elseif self.map.tiles[y-1][x] == TILE_COIN_1 then
        self.map.tiles[y-1][x] = TILE_EMPTY
        self.map.score = math.floor(self.map.score + 20* self.map.difficulty)
        love.audio.play(coinPickup)
    elseif self.map.tiles[y][x+1] == TILE_COIN_1 then
        self.map.tiles[y][x+1] = TILE_EMPTY
        self.map.score = math.floor(self.map.score + 20* self.map.difficulty)
        love.audio.play(coinPickup)
    elseif self.map.tiles[y-1][x+1] == TILE_COIN_1 then
        self.map.tiles[y-1][x+1] = TILE_EMPTY
        self.map.score = math.floor(self.map.score + 20* self.map.difficulty)
        love.audio.play(coinPickup)
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
end
