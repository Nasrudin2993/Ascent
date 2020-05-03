-- CLass file for map, including generation, collision detection, and non-player sprite animation

require 'Util'

Map = Class{}

TILE_EMPTY = -1
TILE_LEDGE = 1
TILE_BOX = 2
TILE_COIN_1 = 3
TILE_COIN_2 = 4
TILE_PORTAL_1 = 5
TILE_PORTAL_2 = 6
animTimer = 0

function Map:init()

    self.difficulty = 1 -- default value if not changed by main
    self.tileWidth = 32
    self.tileHeight = 32
    -- passes in spritesheet into generateQuads() function, which returns a table of quads we can assign to the sprites table
    self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
    self.sprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)
    -- Static variables defining the dimensions of each level and the gravity constant
    self.gravity = 15
    self.mapWidth = 30
    self.mapHeight = 200

    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.mapWidth

    self.camX = 0
    self.camY = self.mapHeight*32 - VIRTUAL_HEIGHT

    self.tiles = {}

    self.player = Player(self)
    -- fills the map with empty tiles, iterating through each line from the top downwards
    for y = 1, self.mapHeight do
        self.tiles[y] = {}
        for x = 1, self.mapWidth do
            self.tiles[y][x] = TILE_EMPTY
        end
    end

    -- randomly generates map
    local y = 4
    local startArea = 3
    local endArea = 14
    -- generates fixed end area
    local middle = math.floor(self.mapWidth / 2 + 0.5)
    self.tiles[y-1][middle] = TILE_PORTAL_1
    i = 2
    while y < endArea do
        for x = -i, i do
            if middle+x > 0 and middle+x < self.mapWidth then
                self.tiles[y][middle+x] = TILE_LEDGE
            end
        end
        i = i + 1
        y = y + 3
    end
    -- iterates through map tile matrix, generating random ledges
    while y < self.mapHeight - startArea do
        local x = 1
            while x < self.mapWidth do
                -- 20% chance to generate a ledge
                if math.random(1, 100) <= math.floor((20 / self.difficulty) + 0.5) then
                    self.tiles[y][x] = TILE_LEDGE
                    local length = math.random(1, 10)
                    local coinGenerated = false
                    for i = 1, length do
                        if x + i < self.mapWidth-1 then
                            self.tiles[y][x+i] = TILE_LEDGE
                            if math.random(10) == 1 and y - 1 > 1 and coinGenerated == false then
                                self.tiles[y-1][x+i] = TILE_COIN_1
                                coinGenerated = true
                            elseif math.random(10) == 1 and y - 1 > 1 then
                                self.tiles[y-1][x+i] = TILE_BOX
                            end
                        end
                    end
                    x = x + length
                end
                x = x + math.random(2, 8)
            end
            y = y + 2
    end
    for i = 1, self.mapWidth do
        self.tiles[self.mapHeight-1][i] = TILE_LEDGE
    end
    self.tiles[self.mapHeight-2][middle] = TILE_PORTAL_1
end

function Map:update(dt)

self.player:update(dt)

end

function Map:drawAnimatedTiles(tile, y, x, animTimer)
        if animTimer <= 1 then
            love.graphics.draw(self.spritesheet, self.sprites[tile], self.tileWidth * (x - 1), self.tileWidth * (y -1))
        elseif animTimer <= 2 then
            love.graphics.draw(self.spritesheet, self.sprites[tile+1], self.tileWidth * (x - 1), self.tileWidth * (y -1))
        else
            love.graphics.draw(self.spritesheet, self.sprites[tile], self.tileWidth * (x - 1), self.tileWidth * (y -1))
        end
end

function Map:render()
    if animTimer > 2 then animTimer = 0 end
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            local tile = self.tiles[y][x]
            if tile == TILE_COIN_1 or tile == TILE_PORTAL_1 then
                self:drawAnimatedTiles(tile, y, x, animTimer)
            elseif tile ~= TILE_EMPTY then
                love.graphics.draw(self.spritesheet, self.sprites[tile], self.tileWidth * (x - 1), self.tileWidth * (y -1))
            end
        end
    end
    animTimer = animTimer + 6 / 60
    self.player:render()
end
