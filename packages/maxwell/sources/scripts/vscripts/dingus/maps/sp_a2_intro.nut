local mapCode = function () {
    SendToConsole("+use")
    SendToConsole("-use")
    ppmod.wait(function () {
        SendToConsole("ent_fire dingus use")
    },20)
}

ppmod.wait(mapCode,0.2)