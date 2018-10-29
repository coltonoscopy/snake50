TILE_SIZE = 32
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

MAX_TILES_X = WINDOW_WIDTH / TILE_SIZE
MAX_TILES_Y = math.floor(WINDOW_HEIGHT / TILE_SIZE) - 1

TILE_EMPTY = 0
TILE_SNAKE_HEAD = 1
TILE_SNAKE_BODY = 2
TILE_APPLE = 3
TILE_STONE = 4

local level = 1

-- time in seconds that the snake moves one tile
SNAKE_SPEED = math.max(0.01, 0.11 - (level * 0.01))

local largeFont = love.graphics.newFont(32)
local hugeFont = love.graphics.newFont(128)

local score = 0
local gameOver = false
local gameStart = true
local newLevel = true

local tileGrid = {}

local snakeX, snakeY = 1, 1
local snakeMoving = 'right'
local snakeTimer = 0

-- snake data structure
local snakeTiles = {
    {snakeX, snakeY} -- head
}

function love.load()
    love.window.setTitle('Snake50')

    love.graphics.setFont(largeFont)

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false
    })

    math.randomseed(os.time())

    initializeGrid()
    initializeSnake()

    tileGrid[snakeTiles[1][2]][snakeTiles[1][1]] = TILE_SNAKE_HEAD
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if not gameOver then
        if key == 'left' and snakeMoving ~= 'right' then
            snakeMoving = 'left'
        elseif key == 'right' and snakeMoving ~= 'left' then
            snakeMoving = 'right'
        elseif key == 'up' and snakeMoving ~= 'down' then
            snakeMoving = 'up'
        elseif key == 'down' and snakeMoving ~= 'up' then
            snakeMoving = 'down'
        end
    end

    if newLevel then
        if key == 'space' then
            newLevel = false
        end
    end

    if gameOver or gameStart then
        if key == 'enter' or key == 'return' then
            initializeGrid()
            initializeSnake()
            score = 0
            gameOver = false
            gameStart = false
        end
    end
end

function love.update(dt)
    if not gameOver and not newLevel then
        snakeTimer = snakeTimer + dt

        local priorHeadX, priorHeadY = snakeX, snakeY

        if snakeTimer >= SNAKE_SPEED then
            if snakeMoving == 'up' then
                if snakeY <= 1 then
                    snakeY = MAX_TILES_Y
                else
                    snakeY = snakeY - 1
                end
            elseif snakeMoving == 'down' then
                if snakeY >= MAX_TILES_Y then
                    snakeY = 1
                else
                    snakeY = snakeY + 1
                end
            elseif snakeMoving == 'left' then
                if snakeX <= 1 then
                    snakeX = MAX_TILES_X
                else
                    snakeX = snakeX - 1
                end
            else
                if snakeX >= MAX_TILES_X then
                    snakeX = 1
                else
                    snakeX = snakeX + 1
                end
            end

            -- push a new head element onto the snake data structure
            table.insert(snakeTiles, 1, {snakeX, snakeY})

            if tileGrid[snakeY][snakeX] == TILE_SNAKE_BODY or
                tileGrid[snakeY][snakeX] == TILE_STONE then

                gameOver = true

            -- if we are eating an apple
            elseif tileGrid[snakeY][snakeX] == TILE_APPLE then

                -- increase score and generate new apple
                score = score + 1

                if score > level * math.ceil(level / 2) * 3 then
                    level = level + 1
                    SNAKE_SPEED = math.max(0.01, 0.11 - (level * 0.01))
                    newLevel = true

                    initializeGrid()
                    initializeSnake()

                    return
                end

                generateObstacle(TILE_APPLE)
            
            -- otherwise, pop the tail and erase from the grid
            else

                local tail = snakeTiles[#snakeTiles]
                tileGrid[tail[2]][tail[1]] = TILE_EMPTY
                table.remove(snakeTiles)

            end

            if not gameOver then
                -- if our snake is greater than one tile long
                if #snakeTiles > 1 then

                    -- set the prior head value to a body value
                    tileGrid[priorHeadY][priorHeadX] = TILE_SNAKE_BODY
                end

                -- update the view with the next snake head location
                tileGrid[snakeY][snakeX] = TILE_SNAKE_HEAD
            end

            snakeTimer = 0
        end
    end
end

function love.draw()

    if gameStart then
        love.graphics.setFont(hugeFont)
        love.graphics.printf("SNAKE", 0, WINDOW_HEIGHT / 2 - 64, WINDOW_WIDTH, 'center')

        love.graphics.setFont(largeFont)
        love.graphics.printf('Press Enter to Start', 0, WINDOW_HEIGHT / 2 + 96, WINDOW_WIDTH, 'center')
    else
        drawGrid()
        
        -- print score
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print('Score: ' .. tostring(score), 10, 10)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf('Level: ' .. tostring(level), -10, 10, WINDOW_WIDTH, 'right')

        if newLevel then
            love.graphics.setFont(hugeFont)
            love.graphics.printf("LEVEL " .. tostring(level), 0, WINDOW_HEIGHT / 2 - 64, WINDOW_WIDTH, 'center')
    
            love.graphics.setFont(largeFont)
            love.graphics.printf('Press Space to Start', 0, WINDOW_HEIGHT / 2 + 96, WINDOW_WIDTH, 'center')

        elseif gameOver then
            drawGameOver()
        end
    end
end

function drawGameOver()
    love.graphics.setFont(hugeFont)
    love.graphics.printf('GAME OVER', 0, WINDOW_HEIGHT / 2 - 64, WINDOW_WIDTH, 'center')

    love.graphics.setFont(largeFont)
    love.graphics.printf('Press Enter to Restart', 0, WINDOW_HEIGHT / 2 + 96, WINDOW_WIDTH, 'center')
end

function drawGrid()
    for y = 1, MAX_TILES_Y do
        for x = 1, MAX_TILES_X do
            if tileGrid[y][x] == TILE_EMPTY then

                -- change the color to white for the grid
                -- love.graphics.setColor(1, 1, 1, 1)
                -- love.graphics.rectangle('line', (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE,
                --     TILE_SIZE, TILE_SIZE)

            elseif tileGrid[y][x] == TILE_APPLE then

                -- change the color to red for an apple
                love.graphics.setColor(1, 0, 0, 1)
                love.graphics.rectangle('fill', (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE,
                    TILE_SIZE, TILE_SIZE)

            elseif tileGrid[y][x] == TILE_STONE then

                love.graphics.setColor(0.8, 0.8, 0.8, 1)
                love.graphics.rectangle('fill', (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE,
                    TILE_SIZE, TILE_SIZE)

            elseif tileGrid[y][x] == TILE_SNAKE_HEAD then
                
                -- change the color to light green for snake head
                love.graphics.setColor(0, 1, 0.5, 1)
                love.graphics.rectangle('fill', (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE,
                    TILE_SIZE, TILE_SIZE)

            elseif tileGrid[y][x] == TILE_SNAKE_BODY then
                
                -- change the color to red for an apple
                love.graphics.setColor(0, 0.5, 0, 1)
                love.graphics.rectangle('fill', (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE,
                    TILE_SIZE, TILE_SIZE)
            end
        end
    end
end

function generateObstacle(obstacle)
    local obstacleX, obstacleY

    repeat
        obstacleX, obstacleY = math.random(MAX_TILES_X), math.random(MAX_TILES_Y)
    until tileGrid[obstacleY][obstacleX] == TILE_EMPTY

    tileGrid[obstacleY][obstacleX] = obstacle
end

function initializeSnake()
    snakeX, snakeY = 1, 1
    snakeMoving = 'right'
    snakeTiles = {
        {snakeX, snakeY}
    }
    tileGrid[snakeTiles[1][2]][snakeTiles[1][1]] = TILE_SNAKE_HEAD
end

function initializeGrid()
    tileGrid = {}

    for y = 1, MAX_TILES_Y do

        table.insert(tileGrid, {})

        for x = 1, MAX_TILES_X do
            table.insert(tileGrid[y], TILE_EMPTY)
        end
    end

    for i = 1, math.min(50, level * 2) do
        generateObstacle(TILE_STONE)
    end

    generateObstacle(TILE_APPLE)
end