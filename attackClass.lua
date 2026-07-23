local attackClass = {}
attackClass.__index = attackClass

function attackClass.new(damage, anim)
    local instance = setmetatable({}, attackClass)
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

return attackClass