local player = require("player")
local enemyFile = require("enemy")

local game = {}

---@class Camera
---@field x number
---@field y number
---@field speed number
---@field zoom number
Camera = {}

---@enum CameraModes
CameraModes = {
    FIXED = 0,
    FOLLOW = 1
}
local cameraOffsetX
local cameraOffsetY
local background
local healthbar
function game.load()
    Camera.x = 0
    Camera.y = 0
    Camera.speed = 8
    Camera.zoom = 1

    background = love.graphics.newImage("sprites/background.png")
    healthbar = love.graphics.newImage("sprites/healthbar.png")
end

---@param mode CameraModes
function Camera:attach(x, y, mode, dt)
    if mode == CameraModes.FIXED then
        self.x = x
        self.y = y
    elseif mode == CameraModes.FOLLOW then
        local dx = x - self.x
        local dy = y - self.y

        self.x = self.x + dx * self.speed * dt
        self.y = self.y + dy * self.speed * dt
    end
end

function Camera:screenX(x)
    return (x + self.x) / self.zoom
end

function Camera:screenY(y)
    return (y + self.y) / self.zoom
end

function Camera:zoomLerp(x, dt)
    local dx = x - self.zoom
    self.zoom = self.zoom + dx * dt
end

function Camera:worldX(x)
    return (x - self.x) * self.zoom
end

function Camera:worldY(y)
    return (y - self.y) * self.zoom
end

function Camera:clamp(minX, maxX, minY, maxY)
    self.x = math.max(minX, math.min(maxX, self.x))
    self.y = math.max(minY, math.min(maxY, self.y))
end

function game.update(dt)
    if player.player.dashing then
        Camera:zoomLerp(0.8, dt)
    else
        Camera:zoomLerp(1, dt)
    end
    cameraOffsetX = (love.graphics.getWidth() / 2 - 20)
    cameraOffsetY = 0

    Camera:attach(player.player.hurtBox.body:getX() - cameraOffsetX, cameraOffsetY, CameraModes.FOLLOW, dt)
end

function game.draw()
    love.graphics.push()
    love.graphics.translate(-Camera.x * Camera.zoom, -Camera.y * Camera.zoom)
    love.graphics.scale(Camera.zoom, Camera.zoom)
    --love.graphics.setColor(0, 1, 0)
    --love.graphics.polygon("fill", Floor.body:getWorldPoints(Floor.shape:getPoints()))
    --love.graphics.polygon("fill", LeftWall.body:getWorldPoints(LeftWall.shape:getPoints()))
    --love.graphics.polygon("fill", RightWall.body:getWorldPoints(RightWall.shape:getPoints()))
    --love.graphics.setColor(1, 1, 1)
    love.graphics.draw(background, 0, 0, 0, love.graphics.getWidth() / background:getWidth(), love.graphics.getHeight() / background:getHeight())

    player.draw(Camera)
    enemyFile.draw(Camera)
    love.graphics.pop()

    -- Draw player health bar
    local percentPlayer = player.player.health / player.player.maxHealth
    love.graphics.draw(healthbar, 60, 65)
    love.graphics.setColor(1 - percentPlayer, percentPlayer, 0)
    love.graphics.rectangle("fill", 62, 66, percentPlayer * 120, 29)

    -- draw enemy health bar
    local percent = enemy.health / enemy.maxHealth
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(healthbar, love.graphics.getWidth() - 140, 65)
    love.graphics.setColor(1 - percent, percent, 0)
    love.graphics.rectangle("fill", love.graphics.getWidth() - 138, 65, percent * 120, 29)
end

return game