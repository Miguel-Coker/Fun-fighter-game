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
---@field sprite love.Image
---@field body love.Body
---@field fixture love.Fixture
---@field shape love.PolygonShape
---@field sound love.Source
---@field lifeTime number
mod.rangedAttack = {}
mod.rangedAttack.__index = mod.rangedAttack

---@param damage number
---@param anim userdata
---@param speed number
---@return Ranged
function mod.rangedAttack.new(pos, damage, anim, speed, sprite, name, cat, sound)
    local instance = setmetatable({}, mod.rangedAttack)
    instance.damage = damage
    instance.anim = anim
    instance.speed = speed
    instance.sprite = sprite
    instance.sound = sound
    instance.body = love.physics.newBody(World, pos.x, pos.y, "dynamic")
    instance.shape = love.physics.newRectangleShape(instance.sprite:getWidth(), instance.sprite:getHeight())
    instance.fixture = love.physics.newFixture(instance.body, instance.shape)
    instance.fixture:setUserData(name)
    instance.fixture:setCategory(cat)
    instance.lifeTime = 5
    instance.fixture:setSensor(true)
    return instance
end

function mod.rangedAttack:draw()
    self.anim:draw(self.sprite, self.body:getX() - 32, self.body:getY() - 32)
end

return mod