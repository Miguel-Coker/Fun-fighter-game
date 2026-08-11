local anim = require("libs.anim8")
local playerClass = require("playerClass")

local playerFile = {}

---@type Player
playerFile.player = nil

---@type Player
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

    player.healthbar = love.graphics.newImage("sprites/healthbar.png")
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

    if love.keyboard.isDown("f") or love.keyboard.isDown("space") and not player.attacking then
        player.anim = player.anims.blockAnim
        player.blocking = true
    else
        player.blocking = false
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

function playerFile.keypressed(key)
    if key == "l" and not player.blocking and player.attackCooldown <= 0 then
        player.attack = player.attacks[playerClass.attacksEnum.kick]
        player:startAttack(Categories.PLAYER_HIT_BOX)
    end

    --[[if key == "j" and not player.blocking then
        player.attack = player.attacks[playerClass.attacksEnum.punch]
    end]]

    if (key == "w" or key == "up") and player.canJump then
        player.hurtBox.body:applyLinearImpulse(0, -1000)
    end

    if (key == "q" or key == "lshift") then
        player:dash()
    end
end

---@param cam Camera
function playerFile.draw(cam)
    love.graphics.setColor(0.6, 0.6, 1)
    player:draw()
end

return playerFile