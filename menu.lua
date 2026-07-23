local menu = {}

local button = require("button")

function menu.load()
    menu.buttons = {
        start = button.new("Start", 10, 10, 40, 20, function() GameStates.play = true end)
    }
end

local selectedButton = nil
function menu.update(dt)
    for _, b in pairs(menu.buttons) do
        if b:checkPressed() then
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
    for _, b in pairs(menu.buttons) do
        b:draw()
    end
end

return menu