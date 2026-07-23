local anim = require("anim8")
local playerClass = require("playerClass")

local playerFile = {}

--- @class player
playerFile.player = nil

local player = nil

function playerFile.load()
    player = playerClass.new("player", love.graphics.newImage("player.png"), false, {x = 100, y = 400})

    if player == nil then
        error("Failed to create player")
    end


    local grid = anim.newGrid(64, 105, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    player.anims.kickAnim = anim.newAnimation(grid('1-4', '3-3'), 0.15)
    player.anims.punchAnim = anim.newAnimation(grid('5-8', '2-2'), 0.15)
    player.anims.idleAnim = anim.newAnimation(grid('5-5', '1-1'), 0.1)

    player.hurtBox.fixture:setCategory(Categories.PLAYER_HURT_BOX)
    player.hurtBox.fixture:setMask(Categories.PLAYER_HIT_BOX, Categories.NONE)

    player.hitBox.fixture:setCategory(Categories.NONE)
    player.hitBox.fixture:setMask(Categories.PLAYER_HURT_BOX)

    playerFile.player = player
end

function playerFile.update(dt)
    player.anim = player.anims.idleAnim

    local vx, vy = player.hurtBox.body:getLinearVelocity()

    player.attackCooldown = player.attackCooldown - dt

    if love.keyboard.isDown("d", "right") then
        player.hurtBox.body:setLinearVelocity(player.speed, vy)
    elseif love.keyboard.isDown("a", "left") then
        player.hurtBox.body:setLinearVelocity(-player.speed, vy)
    else
        player.hurtBox.body:setLinearVelocity(0, vy)
    end

    if love.keyboard.isDown("f") then
        player.anim = player.anims.blockAnim
        player.blocking = true
    else
        player.blocking = false
    end
    
    if player.isKicking then
        player.anim = player.anims.kickAnim
        player.hitBox.fixture:setSensor(false)
    else
        player.hitBox.fixture:setSensor(true)
        player:endAttack()
    end

    if player.anim == player.anims.kickAnim and player.anim.position == 4 then
        player.isKicking = false
        player.anims.kickAnim:gotoFrame(1)
    end

    player.hitBox.body:setLinearVelocity(0, 0)
    player.hitBox.body:setY(player.hurtBox.body:getY())
    player.hitBox.body:setX(player.hurtBox.body:getX())

    player:lookTowards(enemy.hurtBox.body:getX())
    player.anim:update(dt)
end

function playerFile.keypressed(key)
    if key == "l" and player.attackCooldown <= 0 and not player.blocking then
        player.isKicking = true
        player:startAttack(Categories.PLAYER_HIT_BOX)
    end

    if (key == "w" or key == "up") and player.canJump then
        player.hurtBox.body:applyLinearImpulse(0, -1000)
    end
end

function playerFile.draw()
    local percent = player.health / 100

    love.graphics.setColor(1 - percent, percent, 0)
    love.graphics.rectangle("fill", 0, 0, percent * 100, 20)

    love.graphics.setColor(1, 1, 1)
    --love.graphics.polygon("fill", player.body:getWorldPoints(player.shape:getPoints()))
    player.anim:draw(player.spriteSheet, player.hurtBox.body:getX() - 60, player.hurtBox.body:getY() - 90, 0, 1.5, 1.5)
end

return playerFile