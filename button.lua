---@class Button
---@field x number
---@field y number
---@field text string
---@field sprite userdata
---@field baseWidth number
---@field baseHeight number
---@field colour table
---@field func function
---@field hide boolean
local button = {}
button.__index = button

---@param text string
---@param x number
---@param y number
---@param width number
---@param height number
---@param func function
---@return Button
function button.new(x, y, sprite, func)
    local instance = setmetatable({}, button)
    instance.x = x
    instance.y = y
    instance.sprite = sprite
    instance.baseWidth = sprite:getWidth()
    instance.baseHeight = sprite:getHeight()
    instance.hide = false
    instance.colour = {1, 1, 1}
    instance.func = func or function () end
    instance.hide = false
    return instance
end

---@return boolean
function button:checkPressed()
    if love.mouse.getX() >= self.x and love.mouse.getX() <= self.x + self.baseWidth then
        if love.mouse.getY() >= self.y and love.mouse.getY() <= self.y + self.baseHeight then
            --[[self.width = self.baseWidth * 0.9
            self.height = self.baseHeight * 0.9]]
            self.colour = {0.7, 0.7, 0.7}
            return true
        end
    end

    --[[self.width = self.baseWidth
    self.height = self.baseHeight]]
    self.colour = {1, 1, 1}
    return false
end

function button:draw()
    if self.hide then
        return
    end

    love.graphics.setColor(unpack(self.colour))
    love.graphics.draw(self.sprite, self.x, self.y)
    love.graphics.setColor(1, 1, 1)
end

return button