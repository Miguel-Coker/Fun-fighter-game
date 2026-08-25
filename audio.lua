local sone = require("libs.sone")
local audio = {}

audio.data = {}

audio.bank = {}

function audio.load()
    audio.data.fireball = love.sound.newSoundData("audio/sounds/fireball.mp3")

    sone.fadeOut(audio.data.fireball, 1, "outSine")

    audio.bank = {
        fireball = love.audio.newSource(audio.data.fireball)
    }
end

return audio