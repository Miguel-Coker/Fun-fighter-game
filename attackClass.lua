local attackClass = {}

attackClass.__index = attackClass

function attackClass.new()
    local instance = setmetatable({}, attackClass)

    return instance
end

return attackClass