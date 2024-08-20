local mapCode = function () {
    ppmod.interval(function () {
        if (dingus.GetOrigin().z < -1670 && dingus.GetOrigin().x > -1300){
            ppmod.fire(dingus,"dissolve")
        }
    },0.5)
}

ppmod.wait(mapCode,0.2)