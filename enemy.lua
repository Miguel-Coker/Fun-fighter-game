local playerClass = require "playerClass"
local player = nil
local enemyFile = {}

local CAT_enemy = 1
local CAT_HITBOX = 2
local CAT_HURTBOX = 2

function enemyFile.load(plr)
    local spritesheet = love.graphics.newImage("player.png")
    enemy = playerClass.new("enemy", spritesheet, true)

    player = plr

    if player == nil then
        error("Failed to load player")
    end

    enemy.hurtBox.fixture:setCategory(Categories.PLAYER_HIT_BOX)
    enemy.hurtBox.fixture:setMask(Categories.PLAYER_HURT_BOX, Categories.NONE)

    enemy.hitBox.fixture:setMask(Categories.PLAYER_HIT_BOX)

    enemy.baseAttackCooldown = 2

    --[[enemy.hitBox = {}
    enemy.hitBox.body = love.physics.newBody(World, 500, 400, "dynamic")
    enemy.hitBox.shape = love.physics.newRectangleShape(10, 10)
    enemy.hitBox.fixture = love.physics.newFixture(enemy.hitBox.body, enemy.hitBox.shape)
    enemy.hitBox.fixture:setUserData("enemy_hitbox")
    enemy.hitBox.fixture:setCategory(1)
    enemy.hitBox.fixture:setMask(2)]]
end

function enemyFile.update(dt)
    enemy.anim = enemy.idleAnim

    enemy:update(dt)

    enemy.attackCooldown = enemy.attackCooldown - dt

    if enemy.blocking then
        enemy.anim = enemy.blockAnim
    end

    if enemy.attackCooldown <= 0 then
        enemy:startAttack(Categories.PLAYER_HURT_BOX)
    end

    if enemy.attacking then
        enemy.anim = enemy.kickAnim
    end

    if enemy.anim == enemy.kickAnim and enemy.anim.position == 4 then
        enemy:endAttack()
        enemy.kickAnim:gotoFrame(1)
    end

    enemy:lookTowards(player.hurtBox.body:getX())
    enemy:AIMoveSys(player.hurtBox.body:getX())

    enemy.anim:update(dt)
end

function enemyFile.draw()
    local percent = enemy.health / enemy.maxHealth

    love.graphics.setColor(1 - percent, percent, 0)
    love.graphics.rectangle("fill", 700, 0, percent * 100, 20)

    love.graphics.setColor(1, 1, 1)
    enemy:draw()
end

return enemyFile