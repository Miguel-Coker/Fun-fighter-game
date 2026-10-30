local playerClass = require "src.playerClass"
local menu        = require "src.menu"
local enemyFile = {}

---@type Player
local player = nil

function enemyFile.startRound()
    enemy.health = 100

    enemy.hurtBox.body:setX(700)
    enemy.hurtBox.body:setY(GameHeight / 2)
    enemy.mood = playerClass.AIMood.aggresive
    enemy.rangedAttackCooldown = enemy.baseRangedAttackCooldown
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

local function player2MoveSys()
     local neededAxisValue = 0.9

    if enemy.vy < -2 or enemy.vy > 2 then
        neededAxisValue = 0.5
    end

    if enemy.dashing then
        return
    end
    enemy.moving = false
    if Joysticks[1]:isGamepadDown("dpright") or Joysticks[1]:getGamepadAxis("leftx") >= neededAxisValue then
        enemy.moving = true
        enemy.vx = enemy.speed
    elseif Joysticks[1]:isGamepadDown("dpleft") or Joysticks[1]:getGamepadAxis("leftx") <= -neededAxisValue then
        enemy.vx = -enemy.speed
        enemy.moving = true
    end
end

function enemyFile.update(dt)
    if RoundFinished then
        return
    end

    if enemy.wantsToAttack and enemy:canAttack() then
        enemy:startAttack()
    end

    if enemy.health < 50 then
        enemy.mood = playerClass.AIMood.defensive
    end

    if GameStates.player2 == false then
        enemy:AIMoveSys(player, dt)
    else
        player2MoveSys()
    end

    enemy:update(dt)
    enemy:lookTowards(player.hurtBox.body:getX())
    enemy.anim:update(dt)
end

---@param attack playerClass.attacksEnum
local function tryAttack(attack)
    if enemy:canAttack() then
        enemy:setupAttack(attack)
        enemy:startAttack()
    end
end

---@param joystick love.Joystick
---@param button integer
function enemyFile.gamepadpressed(joystick, button)
    if button == "start" then
        menu.main.settings:activate()

    elseif button == "a" and menu.selectedButton:checkPressed() then
        menu.selectedButton:activate()
    end

    if RoundFinished or GameStates.pause then
        return
    end

    if button == SelectedJoyStickMap.kick then
        tryAttack(playerClass.attacksEnum.kick)

    elseif button == SelectedJoyStickMap.punch then
        tryAttack(playerClass.attacksEnum.punch)

    elseif button == SelectedJoyStickMap.spinKick then
        tryAttack(playerClass.attacksEnum.spinKick)

    elseif button == "rightshoulder" and not enemy.blocking and enemy.rangedAttackCooldown <= 0 then
        enemy:setupRangedAttack()

    elseif button == "leftshoulder" and enemy.attacking == false then
        enemy:block()

    elseif button == "dpup" or Joysticks[1]:isGamepadDown(SelectedJoyStickMap.jump) then
        enemy:jump()
    end
end

---@param joystick love.Joystick
---@param axis number
---@param value number
function enemyFile.gamepadaxis(joystick, axis, value)
    if axis == "triggerright" and value == 1 then
        enemy:dash()
    end
end

function enemyFile.draw()
    enemy:draw()
end

return enemyFile