local mapCode = function () {
    ppmod.interval(function () {
        if (dingus.GetOrigin().x < 700 && dingus.GetOrigin().z < -140){
            ppmod.fire(dingus,"dissolve")
        }
    },0.5)
}

ppmod.wait(mapCode,0.2)