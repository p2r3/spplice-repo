local mapCode = function () {
    local door = ppmod.get("exit_door_to_elevator")
    ppmod.addscript(door,"OnOpen",function () {
        dingus.SetOrigin(GetPlayer().EyePosition())
        SendToConsole("ent_fire dingus use")
    })
}

ppmod.wait(mapCode,0.2)