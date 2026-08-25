local sone = require("libs.sone")
local audio = {}

audio.data = {}

function audio.load()
    audio.data.fireball = love.sound.newSoundData("audio/sounds/fireball.mp3")

    sone.fadeOut(audio.data.fireball, 1, "outSine")
end

return audio