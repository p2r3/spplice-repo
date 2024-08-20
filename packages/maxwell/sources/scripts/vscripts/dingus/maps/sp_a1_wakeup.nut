local mapCode = function () {
    SendToConsole("ent_fire @sphere use")
    ppmod.fire(dingus,"disablemotion")
    dingus.SetOrigin(Vector(0,0,0))
    ppmod.get("@sphere").SetModel("models/dingus_phys.mdl")
}

ppmod.wait(mapCode,0.2)