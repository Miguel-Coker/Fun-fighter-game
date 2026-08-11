local anim = require("libs.anim8")
local attackClass = require("attackClass")

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
---@field hurtBox table
---@field hitBox table
---@field vx number
---@field vy number
---@field showCollisionBoxes boolean
local playerClass = {}
playerClass.__index = playerClass

---@enum playerClass.attacksEnum
playerClass.attacksEnum = {
    kick = 1,
    punch = 2
}

local JUMP_POWER_SCALE = 10

---@param name string
---@param spriteSheet table
---@param isAI boolean
---@return Player
function playerClass.new(name, spriteSheet, isAI, pos)
    local player = setmetatable({}, playerClass)
    player.name = name
    player.anims = {}
    player.spriteSheet = spriteSheet
    player.speed = 90
    player.health = 100
    player.maxHealth = 100
    player.baseAttackCooldown = 0.8
    player.attackCooldown = 0
    player.jumpPower = -100 * JUMP_POWER_SCALE
    player.blocking = false
    player.attacking = false
    player.dashing = false
    player.dashTime = 0.2
    player.baseDashCooldown = 1
    player.dashCooldown = 0

    player.isAI = isAI

    player.canJump = true

    local grid = anim.newGrid(64, 105, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

    player.anims.idleAnim = anim.newAnimation(grid('5-5', '1-1'), 0.15)
    player.anims.kickAnim = anim.newAnimation(grid('1-4', '3-3'), 0.15)
    player.anims.blockAnim = anim.newAnimation(grid('7-7', '1-1'), 0.15)
    player.anims.punchAnim = anim.newAnimation(grid('4-8', '2-2'), 0.15)

    player.attack = nil
    player.attacks = {
        attackClass.meleeAttack.new(20, player.anims.kickAnim),
        attackClass.meleeAttack.new(20, player.anims.punchAnim)
    }

    player.anim = player.anims.idleAnim

    player.hurtBox = {}
    player.hurtBox.body = love.physics.newBody(World, pos.x, pos.y, "dynamic")
    player.hurtBox.shape = love.physics.newRectangleShape(64, 120)
    player.hurtBox.fixture = love.physics.newFixture(player.hurtBox.body, player.hurtBox.shape)
    player.hurtBox.fixture:setUserData(name.."_hurtbox")
    player.hurtBox.body:setFixedRotation(true)
    player.hurtBox.body:setMass(5)
    player.vx = 0
    player.vy = 0

    player.hitBox = {}
    player.hitBox.body = love.physics.newBody(World, pos.x, pos.y, "dynamic")
    player.hitBox.shape = love.physics.newRectangleShape(80, 120)
    player.hitBox.fixture = love.physics.newFixture(player.hitBox.body, player.hitBox.shape)
    player.hitBox.body:setFixedRotation(true)
    player.hitBox.fixture:setUserData(name.."_hitbox")

    player.showCollisionBoxes = false
    return player
end

function playerClass:update(dt)
    self.dashCooldown = self.dashCooldown - dt

    local _, vy = self.hurtBox.body:getLinearVelocity()

    if not self.moving then
        self.vx = 0
    end

    if self.dashing then
        self.dashTime = self.dashTime - dt
    end

    if self.dashTime <= 0 then
        self.dashing = false
    end

    self.hurtBox.body:setLinearVelocity(self.vx, vy)
    self.hitBox.body:setLinearVelocity(0, 0)
    self.hitBox.body:setY(self.hurtBox.body:getY())
    self.hitBox.body:setX(self.hurtBox.body:getX())
end

function playerClass:dash()
    if self.dashCooldown > 0 then
        return
    end

    local vx = self.hurtBox.body:getLinearVelocity()

    if vx < 0 then
        vx = -500
    elseif vx > 0 then
        vx = 500
    end
    self.dashing = true
    self.dashTime = 0.2
    self.moving = true
    self.dashCooldown = self.baseDashCooldown
    
    self.vx = vx
end

local function toPositive(x)
    if x < 0 then
        x = x * -1
    end

    return x
end

---@param x number
function playerClass:AIMoveSys(x)
    local dx = x - self.hurtBox.body:getX()
    local dist = toPositive(dx)
    local vx = dx / dist * self.speed

    if dist > 250 then
        self:dash()
    end

    if dist <= 100 and not (self.attackCooldown <= 0.4) then
        self.blocking = true
        self.moving = false
    else
        self.blocking = false
        self.moving = true
        if self.attack == nil then
            self.attack = self.attacks[Rng:random(1, #playerClass.attacksEnum)]
        end
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

function playerClass:endAttack()
    self.hitBox.fixture:setCategory(Categories.NONE)

    self.attack = nil
    self.attacking = false
end

function playerClass:lookTowards(x)
    local playerX = self.hurtBox.body:getX()

    if playerX < x then
        self.anim.direction = "right"
    elseif playerX > x then
        self.anim.direction = "left"
    end
end

function playerClass:draw()
    if self.showCollisionBoxes then
        love.graphics.polygon("line", self.hitBox.body:getWorldPoints(self.hitBox.shape:getPoints()))
    end

    self.anim:draw(self.spriteSheet, self.hurtBox.body:getX() - 60, self.hurtBox.body:getY() - 90, 0, 2.5, 2.5)
end

return playerClass