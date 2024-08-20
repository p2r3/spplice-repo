local mapCode = function () {
    ppmod.fire(dingus,"disablemotion")
    dingus.SetOrigin(Vector(-1285.813, 4415.625, 2747.531))
    dingus.SetAngles(0, 0, 0)
    SendToConsole("snd_playsounds dingus.meow")

    local spin = ppmod.interval(function () {
        dingus.SetAngles(0,dingus.GetAngles().y+8,0)
    })
    ppmod.keyval(spin,"targetname","maxwell_spinner")

    ppmod.wait(function () {
        ppmod.fire("maxwell_spinner","kill")
        ppmod.fire(dingus,"enablemotion")
        dingus.SetAngles(0, 0, 0)
        SendToConsole("snd_playsounds dingus.meow2")
    },12.2)

    ppmod.addscript(ppmod.get("door_open_relay"),"OnTrigger",function() {
         ppmod.fire("exit_door_cube_clip","kill")
    })

    local Camera = ppmod.get("ghostAnim")
    Camera.SetOrigin(Vector(-1213.786621 4446.816895 2727.031250))
    Camera.SetAngles(0,180,0)
    GetPlayer().SetOrigin(Vector(-1213.786621 4446.816895 2769.031250))

    SendToConsole("map_wants_save_disable 0")

    ppmod.fire("good_morning_vcd", "Kill")
    ppmod.fire("@glados", "RunScriptCode", "GladosPlayVcd(\"PreHub01RelaxationVaultIntro01\")")
    ppmod.fire(ppmod.get(Vector(-1232, 4400, 2856.5),"trigger_once",16),"kill")
    ppmod.fire("glass_break","kill")
}

ppmod.wait(mapCode,0.2)