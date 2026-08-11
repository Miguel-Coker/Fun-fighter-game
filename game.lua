local player = require("player")
local enemyFile = require("enemy")

local game = {}

---@class Camera
---@field x number
---@field y number
---@field speed number
---@field zoom number
game.camera = {}

---@enum game.cameraModes
game.cameraModes = {
    FIXED = 0,
    FOLLOW = 1
}
local cameraOffsetX
local cameraOffsetY
local background
function game.load()
    game.camera.x = 0
    game.camera.y = 0
    game.camera.speed = 8
    game.camera.zoom = 1

    background = love.graphics.newImage("sprites/background.png")
end

---@param mode game.cameraModes
function game.camera:attach(x, y, mode, dt)
    if mode == game.cameraModes.FIXED then
        self.x = x
        self.y = y
    elseif mode == game.cameraModes.FOLLOW then
        local dx = x - self.x
        local dy = y - self.y

        self.x = self.x + dx * self.speed * dt
        self.y = self.y + dy * self.speed * dt
    end
end

function game.camera:screenX(x)
    return (x + self.x) / self.zoom
end

function game.camera:screenY(y)
    return (y + self.y) / self.zoom
end

function game.camera:zoomLerp(x, dt)
    local dx = x - self.zoom
    self.zoom = self.zoom + dx * dt
end

function game.camera:clamp(minX, maxX, minY, maxY)
    self.x = math.max(minX, math.min(maxX, self.x))
    self.y = math.max(minY, math.min(maxY, self.y))
end

function game.update(dt)
    if player.player.dashing then
        game.camera:zoomLerp(0.8, dt)
    else
        game.camera:zoomLerp(1, dt)
    end
    cameraOffsetX = (love.graphics.getWidth() / 2 - 20)
    cameraOffsetY = 0

    game.camera:attach(player.player.hurtBox.body:getX() - cameraOffsetX, cameraOffsetY, game.cameraModes.FOLLOW, dt)
end

function game.draw()
    love.graphics.push()
    love.graphics.translate(-game.camera.x * game.camera.zoom, -game.camera.y * game.camera.zoom)
    love.graphics.scale(game.camera.zoom, game.camera.zoom)
    --love.graphics.setColor(0, 1, 0)
    --love.graphics.polygon("fill", Floor.body:getWorldPoints(Floor.shape:getPoints()))
    --love.graphics.polygon("fill", LeftWall.body:getWorldPoints(LeftWall.shape:getPoints()))
    --love.graphics.polygon("fill", RightWall.body:getWorldPoints(RightWall.shape:getPoints()))
    --love.graphics.setColor(1, 1, 1)
    love.graphics.draw(background, 0, 50, 0, love.graphics.getWidth() / background:getWidth(), love.graphics.getHeight() / background:getHeight())

    player.draw(game.camera)
    enemyFile.draw(game.camera)
    love.graphics.pop()

    -- Draw player health bar
    local percentPlayer = player.player.health / 100
    love.graphics.draw(player.player.healthbar, 60, 60)
    love.graphics.setColor(1 - percentPlayer, percentPlayer, 0)
    love.graphics.rectangle("fill", 62, 61, percentPlayer * 120, 29)

    -- draw enemy health bar
    local percent = enemy.health / enemy.maxHealth
    love.graphics.setColor(1 - percent, percent, 0)
    love.graphics.rectangle("fill", love.graphics.getWidth() - 160, 60, percent * 100, 20)
    love.graphics.setColor(1, 0.6, 0.6)
end

return game