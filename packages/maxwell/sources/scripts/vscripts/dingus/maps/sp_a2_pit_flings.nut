local mapCode = function () {
    ppmod.wait(function () {
        local evilTrigger = ppmod.get("smuggled_cube_fizzle_trigger")
        local evilClip = ppmod.get("physobject_floor_clip")
        ppmod.fire(evilTrigger,"kill")
        ppmod.fire(evilClip,"kill")
    },3)
}

ppmod.wait(mapCode,0.2)