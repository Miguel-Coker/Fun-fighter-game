local anim = require("libs.anim8")
local attackClass = require("attackClass")
local audio = require("audio")
local sone = require("libs.sone")

---@class Player
---@field name string
---@field anims table
---@field spriteSheet table
---@field speed number
---@field health number
---@field maxHealth number
---@field baseAttackCooldown number
---@field attackCooldown number
---@field jumpPower number
---@field blocking boolean
---@field attacking boolean
---@field canJump boolean
---@field dashing boolean
---@field dashTime number
---@field baseDashCooldown number
---@field dashCooldown number
---@field isAI boolean
---@field attack table
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
    punch = 2
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
    player.anims = {}
    player.spriteSheet = spriteSheet
    player.speed = 120
    player.health = 100
    player.maxHealth = 100
    player.baseAttackCooldown = 0.8
    player.attackCooldown = 0
    player.jumpPower = -200 * JUMP_POWER_SCALE
    player.blocking = false
    player.attacking = false
    player.dashing = false
    player.dashTime = 0.2
    player.baseDashCooldown = 1
    player.dashCooldown = 0
    player.colour = colour
    player.reactionTime = 0
    player.mood = playerClass.AIMood.AGGRESIVE

    -- For AI only
    player.wantsToAttack = false

    player.isAI = isAI

    player.canJump = true

    local grid = anim.newGrid(64, 105, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    local fireballGrid = anim.newGrid(64, 64, fireball:getWidth(), fireball:getHeight())

    player.anims.idleAnim = anim.newAnimation(grid('5-5', '1-1'), 0.15)
    player.anims.kickAnim = anim.newAnimation(grid('1-4', '3-3'), 0.15)
    player.anims.blockAnim = anim.newAnimation(grid('7-7', '1-1'), 0.15)
    player.anims.punchAnim = anim.newAnimation(grid('4-8', '2-2'), 0.15)
    player.anims.fireball = anim.newAnimation(fireballGrid('1-2', '1-2'), 0.15)

    ---@type Ranged
    player.rangedAttack = attackClass.rangedAttack.new({x = 0, y = 0}, 10, player.anims.fireball, 600, fireball, name.."fireballbase", cat, love.audio.newSource(audio.data.fireball))
    player.rangedAttackCooldown = 5
    player.baseRangedAttackCooldown = 5

    player.attacks = {
        attackClass.meleeAttack.new(20, player.anims.kickAnim),
        attackClass.meleeAttack.new(20, player.anims.punchAnim)
    }

    ---@type Melee
    player.attack = player.attacks[playerClass.attacksEnum.kick]

    player.anim = player.anims.idleAnim

    player.hurtBox = {}
    player.hurtBox.body = love.physics.newBody(World, pos.x, pos.y, "dynamic")
    player.hurtBox.shape = love.physics.newRectangleShape(128, 240)
    player.hurtBox.fixture = love.physics.newFixture(player.hurtBox.body, player.hurtBox.shape)
    player.hurtBox.fixture:setUserData(name.."_hurtbox")
    player.hurtBox.body:setFixedRotation(true)
    player.hurtBox.body:setMass(5)
    player.vx = 0
    player.vy = 0

    player.hitBox = {}
    player.hitBox.body = love.physics.newBody(World, pos.x, pos.y, "dynamic")
    player.hitBox.shape = love.physics.newRectangleShape(160, 240)
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
    self.dashTime = 0.2
    self.moving = true
    self.dashCooldown = self.baseDashCooldown
    if self.vx < 0 then
        self.vx = -500
    elseif self.vx > 0 then
        self.vx = 500
    end
end

local function toPositive(x)
    if x < 0 then
        x = x * -1
    end

    return x
end

---@param self Player
---@param plr Player
---@param dt number
local function processDefensiveMood(self, plr, dt)
    if plr.attacking == false then
        return
    end
    
    if self.reactionTime <= 0 then
        self.attack = self.attacks[playerClass.attacksEnum.kick]
        self.wantsToAttack = true
        self.reactionTime = 0.08
    else
        self.reactionTime = self.reactionTime - dt
        self.blocking = true
    end
end

---@param self Player
---@param plr Player
---@param dt number
local function processAggresiveMood(self, plr, dt)
    self.moving = true
    self.attack = self.attacks[playerClass.attacksEnum.kick]
    self.wantsToAttack = true
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
        processAggresiveMood(self, plr, dt)

    elseif self.mood == playerClass.AIMood.NORMAL then
        processNormalMood(self, plr, dt)
    end

    if not self.dashing then
        self.vx = vx
    end
end

function playerClass:startAttack(category)
    self.hitBox.fixture:setCategory(category)
    self.attackCooldown = self.baseAttackCooldown
    self.attacking = true
    
    if self.attack then
        self.anim = self.attack.anim
    end
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

function playerClass:update(dt)
    self.dashCooldown = self.dashCooldown - dt
    self.rangedAttackCooldown = self.rangedAttackCooldown - dt

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
    self.anim:draw(self.spriteSheet, self.hurtBox.body:getX() - 96, self.hurtBox.body:getY() - 120, 0, 2.5, 2.5)
    love.graphics.setColor(1, 1, 1)
end

return playerClass