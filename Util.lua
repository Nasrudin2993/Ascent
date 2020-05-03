function generateQuads(spritesheet, tilewidth, tileheight)
    local sheetWidth = spritesheet:getWidth() / tilewidth
    local sheetHeight = spritesheet:getHeight() / tileheight

    local sheetCounter = 1
    local quads = {}

    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
            quads[sheetCounter] = love.graphics.newQuad(x * tilewidth, y * tileheight, tilewidth, tileheight, spritesheet:getDimensions())
                sheetCounter = sheetCounter + 1
        end
    end
    return quads
end
