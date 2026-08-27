local player = require("player")
local enemyFile = require("enemy")
local menu = require("menu")
local game = require("game")
local systems = require("systems")

World = love.physics.newWorld(0, 400)

---@enum Collision_categories
Categories = {
    PLAYER_HURT_BOX = 1,
    PLAYER_HIT_BOX = 2,
    FLOOR = 4,
    NONE = 16
}

local attackCooldown = 0

local function beginContact(bodyA, bodyB)
    local userA = bodyA:getUserData()
    local userB = bodyB:getUserData()

    if userA == "player_hurtbox" and userB == "floor" or userA == "floor" and userB == "player_hurtbox" then
        player.player.canJump = true
    end

    if (userA == "enemy_hurtbox" and userB == "floor" or userA == "floor" and userB == "enemy_hurtbox") then
        enemy.canJump = true
    end

    if attackCooldown > 0 then
        return
    end

    if (userA == "player_fireball" and userB == "enemy_hurtbox" or userB == "player_fireball" and userA == "enemy_hurtbox") then
        enemy.health = enemy.health - player.player.rangedAttack.damage
        attackCooldown = 0.1
    end

    if (userA == "player_hurtbox" and userB == "enemy_fireball" or userA == "enemy_fireball" and userB == "player_hurtbox") then
        player.player.health = player.player.health - enemy.rangedAttack.damage
        attackCooldown = 0.1
    end

    if (userA == "player_hitbox" and userB == "enemy_hurtbox" or userA == "enemy_hurtbox" and userB == "player_hitbox") then
        enemy:takeDamage(player.player.attack.damage)
        attackCooldown = 0.1
    end

    if (userA == "enemy_hitbox" and userB == "player_hurtbox" or userA == "player_hurtbox" and userB == "enemy_hitbox") then
        player.player:takeDamage(enemy.attack.damage)
        attackCooldown = 0.1
    end
end

local function endContact(bodyA, bodyB)
    local userA = bodyA:getUserData()
    local userB = bodyB:getUserData()

    if userA == "player_hurtbox" and userB == "floor" or userA == "floor" and userB == "player_hurtbox" then
        player.player.canJump = false
    end

    if (userA == "enemy_hurtbox" and userB == "floor" or userA == "floor" and userB == "enemy_hurtbox") then
        enemy.canJump = false
    end
end

GameStates = {
    play = false,
    pause = false,
    settings = false
}

function love.load()
    love.window.setFullscreen(true)
    love.graphics.setDefaultFilter("nearest", "nearest")

    Rng = love.math.newRandomGenerator()

    World:setCallbacks(beginContact, endContact)

    Joysticks = love.joystick.getJoysticks()

    game.load()

    Floor = {}
    Floor.body = love.physics.newBody(World, 1000, love.graphics.getHeight() / 1.4, "static")
    Floor.shape = love.physics.newRectangleShape(2000, 100)
    Floor.fixture = love.physics.newFixture(Floor.body, Floor.shape)
    Floor.fixture:setUserData("floor")
    Floor.fixture:setCategory(Categories.FLOOR)

    LeftWall = {}
    LeftWall.body = love.physics.newBody(World, 0, 400, "static")
    LeftWall.shape = love.physics.newRectangleShape(50, 600)
    LeftWall.fixture = love.physics.newFixture(LeftWall.body, LeftWall.shape)
    LeftWall.fixture:setUserData("left_wall")
    LeftWall.fixture:setCategory(Categories.FLOOR)

    RightWall = {}
    RightWall.body = love.physics.newBody(World, love.graphics.getWidth(), 400, "static")
    RightWall.shape = love.physics.newRectangleShape(50, 600)
    RightWall.fixture = love.physics.newFixture(RightWall.body, RightWall.shape)
    RightWall.fixture:setUserData("right_wall")
    RightWall.fixture:setCategory(Categories.FLOOR)

    menu.load()
    player.load()
    enemyFile.load(player.player)
end

function love.keypressed(key)
    menu.keypressed(key)

    if key == "p" then
        GameStates.pause = not GameStates.pause
    end

    if key == "h" then
        player.player.showCollisionBoxes = not player.player.showCollisionBoxes
        enemy.showCollisionBoxes = not enemy.showCollisionBoxes
    end 

    player.keypressed(key)

    if key == "i" and player.player.rangedAttackCooldown == 5 then
        enemy:dash()
        enemy:jump()
    end
end

function love.mousepressed(x, y, button)
    menu.mousepressed(x, y, button)
end

function love.update(dt)
    attackCooldown = attackCooldown - dt
    menu.update(dt)
    if GameStates.play and not GameStates.pause then
        game.update(dt)
        player.update(dt)
        enemyFile.update(dt)

        World:update(dt)
    end
end

function love.draw()
    if GameStates.play then
        game.draw()
        if GameStates.pause then
            love.graphics.setColor(0, 1, 0)
            love.graphics.print("PAUSED", love.graphics.getWidth() / 2 - 20, love.graphics.getHeight() / 2)
            love.graphics.setColor(1, 1, 1)
        end
    end
    menu.draw()
end