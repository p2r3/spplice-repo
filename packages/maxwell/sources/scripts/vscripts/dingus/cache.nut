::cache <- function () {
    SendToConsole("fadeout 0")
    ppmod.create("prop_physics_create dingus_phys.mdl",function (cache) {
        this.cache <- cache
        ppmod.fire(cache,"disablemotion")
        ppmod.wait(function () {
            ppmod.fire(cache,"kill")
            SendToConsole("fadein 1")
        },0.1)
    })
}