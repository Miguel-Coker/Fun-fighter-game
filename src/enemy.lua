local playerClass = require "src.playerClass"
local systems     = require "src.systems"
local enemyFile = {}

---@type Player
local player = nil

function enemyFile.startRound()
    enemy.health = 100

    enemy.hurtBox.body:setX(700)
    enemy.hurtBox.body:setY(350)
    enemy.mood = playerClass.AIMood.aggresive
end

---@param plr Player
function enemyFile.load(plr)
    local spritesheet = love.graphics.newImage("sprites/player2.png")
    local colour = {1, 0.6, 0.6}
    enemy = playerClass.new("enemy", spritesheet, true, {x = 700, y = 400}, Categories.PLAYER_HURT_BOX, colour)
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

function enemyFile.update(dt)
    if GameStates.pause or RoundFinished then
        return
    end
    if enemy.wantsToAttack and enemy:canAttack() then
        enemy:startAttack()
    end

    if enemy.health < 50 then
        enemy.mood = playerClass.AIMood.defensive
    end

    enemy:AIMoveSys(player, dt)
    enemy:update(dt)
    enemy:lookTowards(player.hurtBox.body:getX())
    enemy.anim:update(dt)
end

function enemyFile.draw()
    enemy:draw()
end

return enemyFile