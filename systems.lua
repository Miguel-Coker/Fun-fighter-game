local mod = {}

---@class Vector2
---@field x number
---@field y number
mod.vector2 = {}
mod.vector2.__index = mod.vector2

---@param _x number
---@param _y number
---@return Vector2
function mod.vector2.new(_x, _y)
    ---@type Vector2
    local vec2 = {x = _x, y = _y}
    return vec2
end

---@param pos1 Vector2
---@param w1 number
---@param h1 number
---@param pos2 Vector2
---@param w2 number
---@param h2 number
---@return boolean
function mod.AABB(pos1, w1, h1, pos2, w2, h2)
    if pos1.x <= pos2.x + w2 and pos2.x <= pos1.x + w1 then
        if pos1.y <= pos2.y + h2 and pos2.y <= pos1.y + h1 then
            return true
        end
    end

    return false
end

---@param min number
---@param max number
---@param value number
function mod.clamp(min, max, value)
    return math.max(min, math.min(max, value))
end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@return number
function mod.distance(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2

    return dx*dx + dy*dy
end

mod.tween = {}

---@param value number
---@param target number
---@param speed number
---@return number
function mod.tween.lerp(value, target, speed)
    local dist = target - value
    
    return value + dist * speed
end

---@param start number
---@param amplitude number
---@param angle number
---@return number
function mod.tween.sine(start, amplitude, angle)
    return start + amplitude * math.sin(angle)
end

---@param min number
---@param max number
---@param value number
---@return boolean
function mod.between(min, max, value)
    if value <= max and value >= min then
        return true
    end

    return false
end

return mod