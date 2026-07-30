local button = {}
button.__index = button

---@param text string
---@param x number
---@param y number
---@param width number
---@param height number
---@param func function
function button.new(text, x, y, width, height, func)
    local instance = setmetatable({}, button)
    instance.x = x
    instance.y = y
    instance.text = text
    instance.width = width
    instance.height = height
    instance.baseWidth = width
    instance.baseHeight = height
    instance.colour = {0.7, 0.7, 0.7}
    instance.func = func or function () end
    instance.hide = false
    return instance
end

---@return boolean
function button:checkPressed()
    if love.mouse.getX() >= self.x and love.mouse.getX() <= self.x + self.baseWidth then
        if love.mouse.getY() >= self.y and love.mouse.getY() <= self.y + self.baseHeight then
            self.width = self.baseWidth * 0.9
            self.height = self.baseHeight * 0.9
            return true
        end
    end

    self.width = self.baseWidth
    self.height = self.baseHeight
    return false
end

function button:draw()
    love.graphics.setColor(unpack(self.colour))
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.text, self.x, self.y)
    love.graphics.setColor(1, 1, 1)
end

return button