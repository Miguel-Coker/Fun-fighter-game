local audio = {}

audio.__index = audio

---@enum audio.types
audio.types = {
    SIN = 0
}

function audio.new()
    local instance = setmetatable({}, audio)

    return instance
end

return audio