local player = require("player")
local enemyFile = require("enemy")
local menu = require("menu")

World = love.physics.newWorld(0, 200)

---@enum Collision_categories
Categories = {
    PLAYER_HURT_BOX = 1,
    PLAYER_HIT_BOX = 2,
    FLOOR = 4,
    NONE = 16
}

local function beginContact(bodyA, bodyB)
    local userA = bodyA:getUserData()
    local userB = bodyB:getUserData()

    if userA == "player_hurtbox" and userB == "floor" or userA == "floor" and userB == "player_hurtbox" then
        player.player.canJump = true
    end
    
    if (userA == "player_hitbox" and userB == "enemy_hurtbox" or userA == "enemy_hurtbox" and userB == "player_hitbox") then
        if enemy.blocking then
            enemy.health = enemy.health - 5
        else
            enemy.health = enemy.health - 20
        end
    end

    if (userA == "enemy_hitbox" and userB == "player_hurtbox" or userA == "player_hurtbox" and userB == "enemy_hitbox") then
        if player.blocking then
            player.player.health = player.player.health - enemy.attack.damage / 2
        else
            player.player.health = player.player.health - enemy.attack.damage
        end
    end
end

local function endContact(bodyA, bodyB)
    local userA = bodyA:getUserData()
    local userB = bodyB:getUserData()

    if userA == "player_hurtbox" and userB == "floor" or userA == "floor" and userB == "player_hurtbox" then
        player.player.canJump = false
    end
end

GameStates = {
    play = false,
    pause = false,
    settings = false
}

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    Rng = love.math.newRandomGenerator()

    World:setCallbacks(beginContact, endContact)

    Joysticks = love.joystick.getJoysticks()

    Floor = {}
    Floor.body = love.physics.newBody(World, 400, 500, "static")
    Floor.shape = love.physics.newRectangleShape(800, 100)
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
    RightWall.body = love.physics.newBody(World, 800, 400, "static")
    RightWall.shape = love.physics.newRectangleShape(50, 600)
    RightWall.fixture = love.physics.newFixture(RightWall.body, RightWall.shape)
    RightWall.fixture:setUserData("right_wall")
    RightWall.fixture:setCategory(Categories.FLOOR)

    menu.load()
    player.load()
    enemyFile.load(player.player)
end

function love.keypressed(key)
    if key == "p" then
        GameStates.pause = not GameStates.pause
    end

    if key == "escape" then
        menu.main.settings.func()
    end

    if key == "h" then
        player.player.showCollisionBoxes = not player.player.showCollisionBoxes
        enemy.showCollisionBoxes = not enemy.showCollisionBoxes
    end 

    player.keypressed(key)
end

function love.mousepressed(x, y, button)
    menu.mousepressed(x, y, button)
end

function love.update(dt)
    menu.update(dt)
    if GameStates.play and not GameStates.pause then
        player.update(dt)
        enemyFile.update(dt)

        World:update(dt)
    end
end

function love.draw()
    if GameStates.play then
        love.graphics.setColor(0, 1, 0)
        love.graphics.polygon("fill", Floor.body:getWorldPoints(Floor.shape:getPoints()))
        player.draw()
        enemyFile.draw()

        if GameStates.pause then
            love.graphics.setColor(0, 1, 0)
            love.graphics.print("PAUSED", love.graphics.getWidth() / 2 - 20, love.graphics.getHeight() / 2)
            love.graphics.setColor(1, 1, 1)
        end
    end
    menu.draw()
end