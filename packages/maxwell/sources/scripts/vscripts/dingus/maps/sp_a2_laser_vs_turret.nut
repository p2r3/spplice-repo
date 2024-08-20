local mapCode = function () {
    ppmod.interval(function () {
       local clips = null; while(clips = ppmod.get("func_clip_vphysics",clips)){
        ppmod.fire(clips,"kill") //god awful solution but this map sucks so idc
       }
    },1)
}

ppmod.wait(mapCode,0.2)