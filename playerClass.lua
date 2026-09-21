local anim = require("libs.anim8")
local attackClass = require("attackClass")
local audio = require("audio")

local BASE_BLOCK_COOLDOWN = 0.6
local BASE_DASH_TIME = 0.3
local DASH_SPEED = 600
local BASE_REACTION_TIME = 0.08

---@class Player
---@field name string
---@field anims { [string]: Animation }
---@field anim Animation
---@field spriteSheet love.Image
---@field speed number
---@field health number
---@field maxHealth number
---@field baseAttackCooldown number
---@field attackCooldown number
---@field blockCooldown number
---@field jumpPower number
---@field blocking boolean
---@field blockTime number
---@field baseBlockTime number
---@field attacking boolean
---@field canJump boolean
---@field attackCategory integer
---@field dashing boolean
---@field dashTime number
---@field baseDashCooldown number
---@field dashCooldown number
---@field attack Melee
---@field attacks table
---@field rangedAttacks table
---@field hurtBox table
---@field rangedAttack Ranged
---@field hitBox table
---@field vx number
---@field vy number
---@field showCollisionBoxes boolean
---@field baseRangedAttackCooldown number
---@field rangedAttackCooldown number
---@field rangedWeapons Ranged[]
---@field colour[number, number, number, number?]
---@field wantsToAttack boolean
---@field reactionTime number
---@field mood AIMood
local playerClass = {}
playerClass.__index = playerClass

---@enum playerClass.attacksEnum
playerClass.attacksEnum = {
    kick = 1,
    spinKick = 2,
    punch = 3
}

---@enum AIMood
playerClass.AIMood = {
    AGGRESIVE = 1,
    DEFENSIVE = 2,
    NORMAL = 3
}

local JUMP_POWER_SCALE = 10

local fireball = love.graphics.newImage("sprites/fireball2.png")

---@param name string
---@param spriteSheet table
---@param isAI boolean
---@return Player
function playerClass.new(name, spriteSheet, isAI, pos, cat, colour)
    local player = setmetatable({}, playerClass)
    player.name = name
    player.spriteSheet = spriteSheet
    player.speed = 120
    player.health = 100
    player.maxHealth = 100
    player.baseAttackCooldown = 0.8
    player.attackCooldown = 0
    player.jumpPower = -200 * JUMP_POWER_SCALE
    player.attacking = false
    player.dashing = false
    player.dashTime = BASE_DASH_TIME
    player.baseDashCooldown = 1
    player.dashCooldown = 0
    player.attackCategory = cat

    player.blocking = false
    player.blockTime = 0
    player.baseBlockTime = 0.3
    player.blockCooldown = 0

    player.colour = colour
    player.reactionTime = 0
    player.mood = playerClass.AIMood.AGGRESIVE

    -- For AI only
    player.wantsToAttack = false

    player.canJump = true

    local grid = anim.newGrid(98, 106, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    local fireballGrid = anim.newGrid(64, 64, fireball:getWidth(), fireball:getHeight())

    player.anims = {}
    player.anims.idleAnim = anim.newAnimation(grid('1-14', 1), 0.1)
    player.anims.kickAnim = anim.newAnimation(grid('2-13', 2), 0.07)
    player.anims.blockAnim = anim.newAnimation(grid('4-14', 4), 0.08)
    player.anims.spinKickAnim = anim.newAnimation(grid('1-14', 3), 0.08)
    player.anims.fireball = anim.newAnimation(fireballGrid('1-2', '1-2'), 0.15)
    player.anims.punch = anim.newAnimation(grid('5-10', 5), 0.07)

    ---@type Ranged
    player.rangedAttack = attackClass.rangedAttack.new({x = 0, y = 0}, 10, player.anims.fireball, 600, fireball, name.."fireballbase", cat, love.audio.newSource(audio.data.fireball))
    player.rangedAttackCooldown = 5
    player.baseRangedAttackCooldown = 5

    player.attacks = {
        attackClass.meleeAttack.new(10, player.anims.kickAnim),
        attackClass.meleeAttack.new(15, player.anims.spinKickAnim),
        attackClass.meleeAttack.new(5, player.anims.punch)
    }

    ---@type Melee
    player.attack = nil

    player.anim = player.anims.idleAnim

    player.hurtBox = {}
    player.hurtBox.body = love.physics.newBody(World, pos.x, pos.y, "dynamic")
    player.hurtBox.shape = love.physics.newRectangleShape(128, 220)
    player.hurtBox.fixture = love.physics.newFixture(player.hurtBox.body, player.hurtBox.shape)
    player.hurtBox.fixture:setUserData(name.."_hurtbox")
    player.hurtBox.body:setFixedRotation(true)
    player.hurtBox.body:setMass(5)
    player.vx = 0
    player.vy = 0

    player.hitBox = {}
    player.hitBox.body = love.physics.newBody(World, pos.x, pos.y, "dynamic")
    player.hitBox.shape = love.physics.newRectangleShape(128, 220)
    player.hitBox.fixture = love.physics.newFixture(player.hitBox.body, player.hitBox.shape)
    player.hitBox.body:setFixedRotation(true)
    player.hitBox.fixture:setUserData(name.."_hitbox")
    player.hitBox.fixture:setCategory(Categories.NONE)

    player.showCollisionBoxes = false
    return player
end

---@param damage  number
function playerClass:takeDamage(damage)
    if self.blocking then
        self.health = self.health - damage / 3
        
    else
        self.health = self.health - damage
    end
end

function playerClass:jump()
    if self.canJump == false then
        return
    end

    self.hurtBox.body:applyLinearImpulse(0, self.jumpPower)
end

function playerClass:dash()
    if self.dashCooldown > 0 or self.dashing then
        return
    end

    self.dashing = true
    self.dashTime = BASE_DASH_TIME
    self.moving = true
    self.dashCooldown = self.baseDashCooldown
    if self.vx < 0 then
        self.vx = -DASH_SPEED
    elseif self.vx > 0 then
        self.vx = DASH_SPEED
    end
end

local function toPositive(x)
    if x < 0 then
        x = x * -1
    end

    return x
end

function playerClass:block()
    if self.blocking or self.blockCooldown > 0 then
        return
    end

    self.blocking = true
    self.anim = self.anims.blockAnim
    self.blockTime = self.baseBlockTime
    self.blockCooldown = BASE_BLOCK_COOLDOWN
end

function playerClass:getRandomAttack()
    return self.attacks[Rng:random(1, #self.attacks)]
end

---@param self Player
---@param plr Player
---@param dt number
local function processDefensiveMood(self, plr, dt)
    if plr.attacking == false then
        return
    end

    self.reactionTime = self.reactionTime - dt

    if self.reactionTime <= 0 then
        self:block()

        if self:canAttack() then
            self:setupAttack(playerClass.attacksEnum.punch)
        end

        self.reactionTime = BASE_REACTION_TIME
    end
end

function playerClass:canAttack()
    return (self.attackCooldown <= 0 and self.blocking == false)
end

---@param attack playerClass.attacksEnum
function playerClass:setupAttack(attack)
    self.attack = self.attacks[attack]
    self.anim = self.attack.anim
    self.wantsToAttack = true
end

---@param self Player
---@param plr Player
---@param dt number
local function processAggresiveMood(self, plr, dist, dt)
    if dist < 100 then
        self.moving = false
    else
        self.moving = true
    end

    if self:canAttack() then
        self:setupAttack(playerClass.attacksEnum.kick)
    end
end

local function processNormalMood(self, plr, dt)
    if plr.attacking then
        self.vx = -self.vx
        self.moving = true
    end
end

---@param plr Player
---@param dt number
function playerClass:AIMoveSys(plr, dt)
    local dx = plr.hurtBox.body:getX() - self.hurtBox.body:getX()
    local dist = toPositive(dx)
    local vx = dx / dist * self.speed

    if self.rangedAttackCooldown <= 0 then
        vx = -vx

        self:dash()
        if dist > 325 then
            self:startRangedAttack()
        end
    else
        if dist > 300 then
            self:dash()
        end
    end

    if dist <= 240 and not (self.attackCooldown <= 0.4) then
        self.moving = false
    else
        self.moving = true
    end

    if self.mood == playerClass.AIMood.DEFENSIVE then
        processDefensiveMood(self, plr, dt)

    elseif self.mood == playerClass.AIMood.AGGRESIVE then
        processAggresiveMood(self, plr, dist, dt)

    elseif self.mood == playerClass.AIMood.NORMAL then
        processNormalMood(self, plr, dt)
    end

    if not self.dashing then
        self.vx = vx
    end
end

function playerClass:startAttack()
    self.attackCooldown = self.baseAttackCooldown
    self.attacking = true
end

function playerClass:startRangedAttack()
    self.rangedAttackCooldown = self.baseRangedAttackCooldown
    self.rangedAttack.sound:play()

    local speed = 0
    if self.anim.direction == "left" then
        speed = -self.rangedAttack.speed
    else
        speed = self.rangedAttack.speed
    end

    local weapon = attackClass.rangedAttack.new(
        {x = self.hurtBox.body:getX(), y = self.hurtBox.body:getY() - 20}, 
        self.rangedAttack.damage, 
        self.rangedAttack.anim,
        speed,
        self.rangedAttack.sprite,
        self.name.."_fireball",
        self.rangedAttack.fixture:getCategory()
    )
    weapon.anim.direction = self.anim.direction
    table.insert(Fireballs, weapon)
end

function playerClass:endRangedAttack()
    self.attacking = false
end

function playerClass:endAttack()
    self.hitBox.fixture:setCategory(Categories.NONE)

    self.attack = nil
    self.attacking = false
    self.anim = self.anims.idleAnim
    self.wantsToAttack = false
end

function playerClass:lookTowards(x)
    local playerX = self.hurtBox.body:getX()

    if playerX < x then
        self.anim.direction = "right"
    elseif playerX > x then
        self.anim.direction = "left"
    end
end

---@param self Player
local function processBlock(self, dt)
    self.blockTime = self.blockTime - dt

    if self.blockTime <= 0 then
        self.blocking = false
        self.anim:gotoFrame(1)
        self.anim = self.anims.idleAnim
    end
end

local function processAttack(self)
    if self.anim.position == self.attack.attackFrame then
        self.hitBox.fixture:setCategory(self.attackCategory)
    end
end

function playerClass:update(dt)
    self.dashCooldown = self.dashCooldown - dt
    self.rangedAttackCooldown = self.rangedAttackCooldown - dt
    self.blockCooldown = self.blockCooldown - dt

    if self.attack then
        processAttack(self)
    end

    if self.attacking and self.anim.position == #self.anim.frames then
        self.anim:gotoFrame(1)
        self:endAttack()
    end

    if self.blocking then
        processBlock(self, dt)
    end

    local _, vy = self.hurtBox.body:getLinearVelocity()

    if not self.moving then
        self.vx = 0
    end

    if self.dashing then
        self.dashTime = self.dashTime - dt
    end

    if self.dashTime <= 0 then
        self.dashing = false
        self.moving = false
    end

    self.hurtBox.body:setLinearVelocity(self.vx, vy)
    self.hitBox.body:setLinearVelocity(0, 0)
    self.hitBox.body:setY(self.hurtBox.body:getY())
    self.hitBox.body:setX(self.hurtBox.body:getX())
end

function playerClass:draw()
    if self.showCollisionBoxes then
        love.graphics.polygon("line", self.hitBox.body:getWorldPoints(self.hitBox.shape:getPoints()))
    end

    love.graphics.setColor(unpack(self.colour))
    self.anim:draw(self.spriteSheet, self.hurtBox.body:getX(), self.hurtBox.body:getY(), 0, 2.5, 2.5, 49, 53)
    love.graphics.setColor(1, 1, 1)
end

return playerClass