local mod = {}

---@class Melee
---@field anim userdata
---@field damae number
---@field damage number
mod.meleeAttack = {}
mod.meleeAttack.__index = mod.meleeAttack

function mod.meleeAttack.new(damage, anim)
    local instance = setmetatable({}, mod.meleeAttack)
    if type(damage) ~= "table" then
        instance.anim = anim
        instance.damage = damage
    else
        local data = damage
        instance.damage = data.damage
        instance.anim = data.anim
    end
    return instance
end

---@class Ranged
---@field damage number
---@field speed number
---@field anim userdata
---@field position table
mod.rangedAttack = {}
mod.rangedAttack.__index = mod.rangedAttack

---@param damage number
---@param anim userdata
---@param speed number
---@return Ranged
function mod.rangedAttack.new(damage, anim, speed)
    ---@type Ranged
    local instance = setmetatable({}, mod.rangedAttack)
    instance.damage = damage
    instance.anim = anim
    instance.speed = speed
    instance.position = {x = 0, y = 0}
    return instance
end

return mod