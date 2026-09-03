local anim = require("libs.anim8")
local playerClass = require("playerClass")

local playerFile = {}

---@type Player
playerFile.player = nil

---@type Player
local player = nil

function playerFile.load()
    player = playerClass.new("player", love.graphics.newImage("player.png"), false, {x = 100, y = 400}, Categories.PLAYER_HIT_BOX, {0.6, 0.6, 1})

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
    player.attackCooldown = player.attackCooldown - dt

    if not player.dashing then
        player.moving = false
    end

    local vx, vy = player.hurtBox.body:getLinearVelocity()

    if not player.dashing then
        if love.keyboard.isDown("d", "right") then
            player.moving = true
            player.vx = player.speed
        elseif love.keyboard.isDown("a", "left") then
            player.vx = -player.speed
            player.moving = true
        end
    end

    if not player.attacking and not player.blocking then
        player.anim = player.anims.idleAnim
    end

    if player.anim.position == 4 and player.attacking then
        player.anim:gotoFrame(1)
        player:endAttack()
    end

    if player.attacking then
        player.hitBox.fixture:setSensor(false)
    else
        player.hitBox.fixture:setSensor(true)
    end

    player:update(dt)
    player:lookTowards(enemy.hurtBox.body:getX())
    player.anim:update(dt)
end

---@param attack playerClass.attacksEnum
local function tryAttack(attack)
    if player.blocking or player.attackCooldown > 0 then
        return
    end

    player.attack = player.attacks[attack]
    player:startAttack(Categories.PLAYER_HIT_BOX)
end

function playerFile.keypressed(key)
    if key == "l" then
        tryAttack(playerClass.attacksEnum.kick)
    end

    if key == "i" and not player.blocking and player.rangedAttackCooldown <= 0 then
        player:startRangedAttack()
    end

    --[[if key == "j" then
        tryAttack(playerClass.attacksEnum.punch)
    end]]

    if key == "space" and player.attacking == false then
        player:block()
    end

    --[[if key == "j" and not player.blocking then
        player.attack = player.attacks[playerClass.attacksEnum.punch]
    end]]

    if (key == "w" or key == "up") then
        player:jump()
    end

    if (key == "q" or key == "lshift") then
        player:dash()
    end
end

function playerFile.keyreleased(key)

end

function playerFile.draw()
    player:draw()
end

return playerFile