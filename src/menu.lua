local menu = {}

local button = require("src.button")

local function adjustButtons()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    menu.settings.toggleFullscreen.x = windowWidth / 2 - menu.sprites.fullscreen:getHeight()
    menu.settings.toggleFullscreen.y = windowHeight / 2 - 94

    menu.settings.exit.x = windowWidth / 2 - menu.sprites.exit:getWidth() / 2
    menu.settings.exit.y = windowHeight / 2
end

local function player2(self)
    GameStates.play = true
    self.hide = true
    menu.main.start.hide = true
    GameStates.player2 = true

    if love.joystick.getJoystickCount() == 0 then
        error("Gamepad needed for 2 player mode")
    end

    ---@type love.Joystick[]
    Joysticks = love.joystick.getJoysticks()

    if Joysticks[1]:getName():find("joy") then
        SelectedJoyStickMap = JoystickMaps.joycon
    else
        SelectedJoyStickMap = JoystickMaps.xbox
    end
end

function menu.load()
    menu.sprites = {
        play = love.graphics.newImage("sprites/buttons/play.png"),
        settings = love.graphics.newImage("sprites/buttons/settings.png"),
        --pause = love.graphics.newImage("sprites/buttons/pause.png"),
        exit = love.graphics.newImage("sprites/buttons/exit.png"),
        fullscreen = love.graphics.newImage("sprites/buttons/fullscreen.png"),
        player2 = love.graphics.newImage("sprites/buttons/2player.png")

    }

    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    menu.main = {
        settings = button.new(40, 0, menu.sprites.settings, function() 
                GameStates.settings = not GameStates.settings 
                GameStates.pause = not GameStates.pause 
                
                if menu.selectedMenu == menu.settings then
                    menu.selectedMenu = menu.main
                else
                    menu.selectedMenu = menu.settings
                end
            end),
        start = button.new(windowWidth / 2 - 60, windowHeight / 4, menu.sprites.play, function(self) GameStates.play = true self.hide = true menu.main.player2.hide = true end),
        player2 = button.new(windowWidth / 2 - 60, windowHeight / 4 + 100,menu.sprites.player2, player2)
    }
    menu.settings = {
        exit = button.new(windowWidth / 2 - menu.sprites.exit:getWidth() / 2, windowHeight / 2, menu.sprites.exit, love.event.quit),
        toggleFullscreen = button.new(windowWidth / 2 - menu.sprites.fullscreen:getHeight(), windowHeight / 2 - 94, menu.sprites.fullscreen, function()love.window.setFullscreen(not love.window.getFullscreen()) adjustButtons() end)
    }

    menu.selectedMenu = menu.main
end

local selectedButton = nil
function menu.update(dt)
    for _, b in pairs(menu.selectedMenu) do
        if menu.main.settings:checkPressed() then
            selectedButton = menu.main.settings
        elseif b:checkPressed() and not b.hide then
            selectedButton = b
        end
    end
end

function menu.mousepressed(x, y, mButton)
    if selectedButton and mButton == 1 and selectedButton:checkPressed() then
        selectedButton.func(selectedButton)
    end
end

function menu.keypressed(key)
    if key == "escape" then
        menu.main.settings:activate()
    end
end

function menu.draw()
    menu.main.settings:draw()
    for _, b in pairs(menu.selectedMenu) do
        b:draw()
    end
end

return menu