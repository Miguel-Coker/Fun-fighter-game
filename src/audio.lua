local sone = require("libs.sone")
local audio = {}

audio.data = {}

function audio.load()
    audio.data.fireball = love.sound.newSoundData("audio/sounds/fireball.mp3")
    audio.bank = {}
    audio.bank.punch = love.audio.newSource("audio/sounds/punch.mp3", "static")
    audio.bank.hit = love.audio.newSource("audio/sounds/hit.mp3", "static")

    sone.fadeOut(audio.data.fireball, 1, "outSine")
end

return audio