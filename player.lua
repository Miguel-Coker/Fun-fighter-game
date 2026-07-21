local anim = require("anim8")
local enemyFile = require("enemy")

local player = {}

function player.load()
    local imageData = love.image.newImageData("player.png")

    player.spriteSheet = love.graphics.newImage(imageData)

    local grid = anim.newGrid(64, 105, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

    player.kickAnim = anim.newAnimation(grid('1-4', '3-3'), 0.15)
    player.punchAnim = anim.newAnimation(grid('5-8', '2-2'), 0.15)
    player.idleAnim = anim.newAnimation(grid('5-5', '1-1'), 0.15)
    player.blockAnim = anim.newAnimation(grid('7-7', '1-1'), 0.15)
    player.anim = player.idleAnim

    player.canJump = true
    player.isKicking = false
    player.speed = 100
    player.health = 100
    player.baseAttackCooldown = 0.8
    player.attackCooldown = 0
    player.blocking = false

    player.hurtBox = {}
    player.hurtBox.body = love.physics.newBody(World, 200, 400, "dynamic")
    player.hurtBox.shape = love.physics.newRectangleShape(64, 120)
    player.hurtBox.fixture = love.physics.newFixture(player.hurtBox.body, player.hurtBox.shape)
    player.hurtBox.fixture:setUserData("player_hurtbox")
    player.hurtBox.body:setFixedRotation(true)
    player.hurtBox.fixture:setCategory(Categories.PLAYER_HURT_BOX)
    player.hurtBox.fixture:setMask(Categories.PLAYER_HIT_BOX, Categories.NONE)

    player.hitBox = {}
    player.hitBox.body = love.physics.newBody(World, 200, 400, "dynamic")
    player.hitBox.shape = love.physics.newRectangleShape(75, 120)
    player.hitBox.fixture = love.physics.newFixture(player.hitBox.body, player.hitBox.shape)
    player.hitBox.body:setFixedRotation(true)
    player.hitBox.fixture:setUserData("player_hitbox")
    player.hitBox.fixture:setCategory(Categories.NONE)
    player.hitBox.fixture:setMask(Categories.PLAYER_HURT_BOX)
end

function player:lookTowards(x)
    if player.hurtBox.body:getX() < x then
        player.anim.direction = "right"
    elseif player.hurtBox.body:getX() > x then
        player.anim.direction = "left"
    end
end

function player:startAttack()
    player.hitBox.fixture:setCategory(Categories.PLAYER_HIT_BOX)

    player.attackCooldown = player.baseAttackCooldown
end

function player:endAttack()
    player.hitBox.fixture:setCategory(Categories.NONE)
end

function player.update(dt)
    player.anim = player.idleAnim

    local vx, vy = player.hurtBox.body:getLinearVelocity()

    player.attackCooldown = player.attackCooldown - dt

    if love.keyboard.isDown("d", "right") then
        player.hurtBox.body:setLinearVelocity(player.speed, vy)
    elseif love.keyboard.isDown("a", "left") then
        player.hurtBox.body:setLinearVelocity(-player.speed, vy)
    else
        player.hurtBox.body:setLinearVelocity(0, vy)
    end

    if love.keyboard.isDown("f") then
        player.anim = player.blockAnim
        player.blocking = true
    else
        player.blocking = false
    end
    
    if player.isKicking then
        player.anim = player.kickAnim
        player.hitBox.fixture:setSensor(false)
    else
        player.hitBox.fixture:setSensor(true)
        player:endAttack()
    end

    if player.anim == player.kickAnim and player.anim.position == 4 then
        player.isKicking = false
        player.kickAnim:gotoFrame(1)
    end

    player.hitBox.body:setLinearVelocity(0, 0)
    player.hitBox.body:setY(player.hurtBox.body:getY())
    player.hitBox.body:setX(player.hurtBox.body:getX())

    player:lookTowards(enemy.hurtBox.body:getX())
    player.anim:update(dt)
end

function player.keypressed(key)
    if key == "l" and player.attackCooldown <= 0 and not player.blocking then
        player.isKicking = true
        player:startAttack()
    end

    if (key == "w" or key == "up") and player.canJump then
        player.hurtBox.body:applyLinearImpulse(0, -1000)
    end
end

function player.draw()
    local percent = player.health / 100

    love.graphics.setColor(1 - percent, percent, 0)
    love.graphics.rectangle("fill", 0, 0, percent * 100, 20)

    love.graphics.setColor(1, 1, 1)
    --love.graphics.polygon("fill", player.body:getWorldPoints(player.shape:getPoints()))
    player.anim:draw(player.spriteSheet, player.hurtBox.body:getX() - 60, player.hurtBox.body:getY() - 90, 0, 1.5, 1.5)
end

return player