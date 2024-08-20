local mapCode = function () {
    dingus.SetOrigin(GetPlayer().GetOrigin() + Vector(16,64,64))
    dingus.SetAngles(0,180,0)
    ppmod.fire(dingus,"disablemotion")
}

ppmod.wait(mapCode,0.2)