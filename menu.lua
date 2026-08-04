local menu = {}

local button = require("button")

function menu.load()
    menu.main = {
        start = button.new("Play", 10, 10, 40, 20, function() GameStates.play = true end),
        pause = button.new("Pause", 120, 10, 40, 20, function() GameStates.pause = not GameStates.pause end),
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
        exit = button.new("Exit", 10, 10, 40, 20, love.event.quit)
    }

    menu.selectedMenu = menu.main
end

local selectedButton = nil
function menu.update(dt)
    for _, b in pairs(menu.selectedMenu) do
        if menu.main.settings:checkPressed() then
            selectedButton = menu.main.settings
        elseif b:checkPressed() then
            selectedButton = b
        end
    end
end

function menu.mousepressed(x, y, mButton)
    if selectedButton and mButton == 1 and selectedButton:checkPressed() then
        selectedButton.func()
    end
end

function menu.draw()
    menu.main.settings:draw()
    for _, b in pairs(menu.selectedMenu) do
        b:draw()
    end
end

return menu