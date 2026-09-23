local playerClass = require "playerClass"
local systems     = require "systems"
local enemyFile = {}

---@type Player
local player = nil

---@type love.Thread
local enemyThread

---@type love.Channel
local enemyChannel

---@param plr Player
function enemyFile.load(plr)
    local spritesheet = love.graphics.newImage("sprites/player2.png")
    enemy = playerClass.new("enemy", spritesheet, true, {x = 700, y = 400}, Categories.PLAYER_HURT_BOX, {1, 0.6, 0.6})
    player = plr
    if player == nil then
        error("Failed to load player")
    end

    enemy.hurtBox.fixture:setCategory(Categories.PLAYER_HIT_BOX)
    enemy.hurtBox.fixture:setMask(Categories.PLAYER_HURT_BOX, Categories.NONE)

    enemy.hitBox.fixture:setMask(Categories.PLAYER_HIT_BOX)
    enemy.hitBox.fixture:setCategory(Categories.NONE)

    enemy.baseAttackCooldown = 2
end

function enemyFile.update()
    while GameStates.pause == false do
        local dt = love.timer.getDelta()

        print(dt)

        enemy.attackCooldown = enemy.attackCooldown - dt

        if enemy.wantsToAttack and enemy.attackCooldown <= 0 and enemy.attack then
            enemy:startAttack()
        end

        if enemy.attacking and enemy.attack ~= nil then
            enemy.anim = enemy.attack.anim
        end

        if enemy.health < 50 then
            enemy.mood = playerClass.AIMood.DEFENSIVE
        end

        enemy:AIMoveSys(player, dt)
        enemy:update(dt)
        enemy:lookTowards(player.hurtBox.body:getX())
        enemy.anim:update(dt)

        systems.coroutine.wait(dt / 10)
    end
end

function enemyFile.draw()
    enemy:draw()
end

return enemyFile