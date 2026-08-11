local menu = {}

local button = require("button")

function menu.load()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    menu.main = {
        start = button.new("Play", windowWidth / 2 - 60, windowHeight / 4, 110, 50, function(self) GameStates.play = true self.hide = true end),
        pause = button.new("Pause", 10, 10, 40, 20, function() GameStates.pause = not GameStates.pause end),
        settings = button.new("Settings", 60, 10, 50, 20, function() 
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
        exit = button.new("Exit", 10, 10, 40, 20, love.event.quit),
        toggleFullscreen = button.new("Toggle Fullscreen", 10, 40, 100, 20, function()love.window.setFullscreen(not love.window.getFullscreen()) end)
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

function menu.draw()
    menu.main.settings:draw()
    for _, b in pairs(menu.selectedMenu) do
        b:draw()
    end
end

return menu