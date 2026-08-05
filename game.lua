local player = require("player")
local enemyFile = require("enemy")

local game = {}

game.camera = {}

---@enum game.cameraModes
game.cameraModes = {
    FIXED = 0,
    FOLLOW = 1
}

function game.load()
    game.camera.x = 0
    game.camera.y = 0
    game.camera.speed = 10
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
    return x + self.x
end

function game.camera:screenY(y)
    return y + self.y
end

local cameraOffsetX = love.graphics.getWidth() / 2
local cameraOffsetY = love.graphics.getHeight() / 1.5

function game.update(dt)
    game.camera:attach(player.player.hurtBox.body:getX() - cameraOffsetX, player.player.hurtBox.body:getY() - cameraOffsetY, game.cameraModes.FOLLOW, dt)
end

function game.draw()
    love.graphics.push()
    love.graphics.translate(-game.camera.x, -game.camera.y)
    love.graphics.setColor(0, 1, 0)
    love.graphics.polygon("fill", Floor.body:getWorldPoints(Floor.shape:getPoints()))
    love.graphics.polygon("fill", LeftWall.body:getWorldPoints(LeftWall.shape:getPoints()))
    love.graphics.polygon("fill", RightWall.body:getWorldPoints(RightWall.shape:getPoints()))

    player.draw(game.camera)
    enemyFile.draw(game.camera)
    love.graphics.pop()
end

return game