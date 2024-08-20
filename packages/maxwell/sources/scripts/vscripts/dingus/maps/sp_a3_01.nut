local mapCode = function () {
    SendToConsole("+use")
    SendToConsole("-use")
    ppmod.wait(function () {
        dingus.SetOrigin(Vector(-655, -1566, 8041))
        ppmod.wait(function () {
            SendToConsole("snd_playsounds dingus.meow2") //poor kitty
        },4)
        ppmod.wait(function () {
            SendToConsole("snd_playsounds dingus.meow")
        },12)
    },1)
}

ppmod.wait(mapCode,0.2)