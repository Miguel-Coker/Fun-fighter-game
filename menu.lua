local menu = {}

local button = require("button")

function menu.load()
    menu.sprites = {
        play = love.graphics.newImage("sprites/buttons/play.png"),
        settings = love.graphics.newImage("sprites/buttons/settings.png"),
        --pause = love.graphics.newImage("sprites/buttons/pause.png"),
        exit = love.graphics.newImage("sprites/buttons/exit.png"),
        fullscreen = love.graphics.newImage("sprites/buttons/fullscreen.png")

    }

    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    menu.main = {
        start = button.new(windowWidth / 2 - 60, windowHeight / 4, menu.sprites.play, function(self) GameStates.play = true self.hide = true end),
        settings = button.new(60, 10, menu.sprites.settings, function() 
                GameStates.settings = not GameStates.settings 
                GameStates.pause = not GameStates.pause 
                
                if menu.selectedMenu == menu.settings then
                    menu.selectedMenu = menu.main
                else
                    menu.selectedMenu = menu.settings
                end
            end)
    }
    menu.settings = {
        exit = button.new(windowWidth / 2, windowHeight / 2, menu.sprites.exit, love.event.quit),
        toggleFullscreen = button.new(windowWidth / 2, windowHeight / 2 - 94, menu.sprites.fullscreen, function()love.window.setFullscreen(not love.window.getFullscreen()) end)
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
        menu.main.settings.func(menu.main.settings)
    end
end

function menu.draw()
    menu.main.settings:draw()
    for _, b in pairs(menu.selectedMenu) do
        b:draw()
    end
end

return menu