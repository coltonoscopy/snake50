TILE_SIZE = 32
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

MAX_TILES_X = WINDOW_WIDTH / TILE_SIZE
MAX_TILES_Y = math.floor(WINDOW_HEIGHT / TILE_SIZE) - 1

TILE_EMPTY = 0
TILE_SNAKE_HEAD = 1
TILE_SNAKE_BODY = 2
TILE_APPLE = 3

SNAKE_SPEED = 100

local tileGrid = {}

local snakeX, snakeY = 0, 0
local snakeMoving = 'right'

function love.load()
    love.window.setTitle('Snake50')

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false
    })

    math.randomseed(os.time())

    initializeGrid()
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if key == 'left' then
        snakeMoving = 'left'
    elseif key == 'right' then
        snakeMoving = 'right'
    elseif key == 'up' then
        snakeMoving = 'up'
    elseif key == 'down' then
        snakeMoving = 'down'
    end
end

function love.update(dt)
    if snakeMoving == 'left' then
        snakeX = snakeX - SNAKE_SPEED * dt
    elseif snakeMoving == 'right' then
        snakeX = snakeX + SNAKE_SPEED * dt
    elseif snakeMoving == 'up' then
        snakeY = snakeY - SNAKE_SPEED * dt
    elseif snakeMoving == 'down' then
        snakeY = snakeY + SNAKE_SPEED * dt
    end
end

function love.draw()
    drawGrid()
    drawSnake()
end

function drawGrid()
    for y = 1, MAX_TILES_Y do
        for x = 1, MAX_TILES_X do
            if tileGrid[y][x] == TILE_EMPTY then

                -- change the color to white for the grid
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.rectangle('line', (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE,
                    TILE_SIZE, TILE_SIZE)

            elseif tileGrid[y][x] == TILE_APPLE then

                -- change the color to red for an apple
                love.graphics.setColor(1, 0, 0, 1)
                love.graphics.rectangle('fill', (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE,
                    TILE_SIZE, TILE_SIZE)
            end
        end
    end
end

function drawSnake()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.rectangle('fill', snakeX, snakeY, TILE_SIZE, TILE_SIZE)
end

function initializeGrid()
    for y = 1, MAX_TILES_Y do

        table.insert(tileGrid, {})

        for x = 1, MAX_TILES_X do
            table.insert(tileGrid[y], TILE_EMPTY)
        end
    end

    local appleX, appleY = math.random(MAX_TILES_X), math.random(MAX_TILES_Y)

    tileGrid[appleY][appleX] = TILE_APPLE
end