local anim = require("anim8")

local playerClass = {}

playerClass.__index = playerClass

local JUMP_POWER_SCALE = 10

---@param name string
---@param spriteSheet table
---@param isAI boolean
---@return table
function playerClass.new(name, spriteSheet, isAI)
    local player = setmetatable({}, playerClass)
    player.name = name
    player.spriteSheet = spriteSheet
    player.speed = 90
    player.health = 100
    player.maxHealth = 100
    player.baseAttackCooldown = 0.8
    player.attackCooldown = 0
    player.jumpPower = -100 * JUMP_POWER_SCALE
    player.blocking = false
    player.attacking = false

    player.isAI = isAI

    player.canJump = true

    local grid = anim.newGrid(64, 105, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

    player.idleAnim = anim.newAnimation(grid('5-5', '1-1'), 0.15)
    player.kickAnim = anim.newAnimation(grid('1-4', '3-3'), 0.15)
    player.blockAnim = anim.newAnimation(grid('7-7', '1-1'), 0.15)

    player.anim = player.idleAnim

    player.hurtBox = {}
    player.hurtBox.body = love.physics.newBody(World, 400, 400, "dynamic")
    player.hurtBox.shape = love.physics.newRectangleShape(64, 120)
    player.hurtBox.fixture = love.physics.newFixture(player.hurtBox.body, player.hurtBox.shape)
    player.hurtBox.fixture:setUserData(name.."_hurtbox")
    player.hurtBox.body:setFixedRotation(true)

    player.hitBox = {}
    player.hitBox.body = love.physics.newBody(World, 400, 400, "dynamic")
    player.hitBox.shape = love.physics.newRectangleShape(80, 120)
    player.hitBox.fixture = love.physics.newFixture(player.hitBox.body, player.hitBox.shape)
    player.hitBox.body:setFixedRotation(true)
    player.hitBox.fixture:setUserData(name.."_hitbox")
    return player
end

function playerClass:update(dt)
    self.hitBox.body:setLinearVelocity(0, 0)
    self.hitBox.body:setY(self.hurtBox.body:getY())
    self.hitBox.body:setX(self.hurtBox.body:getX())
end

function playerClass:AIMoveSys(x)
    local dx = x - self.hurtBox.body:getX()
    local len = math.sqrt(dx*dx)
    local vx = dx / len * self.speed

    if len <= 100 and not (self.attackCooldown <= 0.4) then
        self.blocking = true
        vx = 0
    else
        self.blocking = false
    end

    self.hurtBox.body:setLinearVelocity(vx, 0)
end

function playerClass:startAttack(category)
    self.hitBox.fixture:setCategory(category)

    self.attackCooldown = self.baseAttackCooldown
    self.attacking = true
end

function playerClass:endAttack()
    self.hitBox.fixture:setCategory(Categories.NONE)

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

function  playerClass:draw()
    self.anim:draw(self.spriteSheet, self.hurtBox.body:getX() - 60, self.hurtBox.body:getY() - 90, 0, 1.5, 1.5)
end

return playerClass