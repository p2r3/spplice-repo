if (!("Entities" in this)) return

::holdingDingus <- false

::main <- function () {
    printl("===========[MAXWELL MOD]===========")
    ppmod.create("ent_create_portal_weighted_cube",function(dingus) {
        ::dingus <- dingus

        ppmod.keyval(dingus,"CubeType",6)
        ppmod.keyval(dingus,"targetname","dingus")
        dingus.SetModel("models/dingus_phys.mdl")
        dingus.SetSize(Vector(-18,-18,-18),Vector(18,18,18))
        dingus.SetOrigin(GetPlayer().EyePosition())
        SendToConsole("snd_playsounds dingus.meow")
        SendToConsole("ent_fire dingus use")

        ppmod.addscript(dingus,"OnPlayerPickup",function(){SendToConsole("snd_playsounds dingus.meow");::holdingDingus <- true})
        ppmod.addscript(dingus,"OnPhysGunDrop", function(){::holdingDingus <- false})

        this.fizzlerLoop <- ppmod.interval(function () {
            if (!(dingus)) return
            local fizzler = ppmod.get(dingus.GetOrigin(),"trigger_portal_cleanser",128)
            if (!(fizzler)) {
                local Group = 24
                if (::holdingDingus) Group = 23
                ppmod.keyval(dingus,"CollisionGroup",Group)
                return
            }
            ppmod.keyval(dingus,"CollisionGroup",1)
        })

        local Killed = function () {
            SendToConsole("snd_playsounds dingus.meow2")
            SendToConsole("fadeout 0")
            ppmod.text("Subject [MAXWELL] Destroyed. Reloading").Display(5)

            ppmod.fire(fizzlerLoop,"kill")

            local hurt = ppmod.trigger(GetPlayer().GetOrigin(),Vector(64,64,64),"hurt")
            ppmod.keyval(hurt,"damage",100000) //kill player to reload save
        }

        local door = null; while(door = ppmod.get("prop_testchamber_door",door)){
            ppmod.fire(Entities.FindByClassnameNearest("func_clip_vphysics",door.GetOrigin(),128),"kill")
        }

        ppmod.addscript(dingus,"OnFizzled",Killed)

        local void_dists = [
            {map="sp_a2_bts2",value=-50},
            {map="sp_a2_bts4",value=6500},
            {map="sp_a2_bts5",value=3345},

            {map="sp_a3_03",value=-5300},
            {map="sp_a3_transition01",value=-6400},
            {map="sp_a3_portal_intro",value=-3100},
            {map="sp_a3_end",value=-5080},

            {map="sp_a4_intro",value=-800},
            {map="sp_a4_tb_trust_drop",value=-200},
            {map="sp_a4_tb_wall_button",value=-650},
            {map="sp_a4_tb_polarity",value=-700},
            {map="sp_a4_tb_laser_platform",value=-2500},
            {map="sp_a4_speed_tb_catch",value=-630},
            {map="sp_a4_jump_polarity",value=-550},
            {map="sp_a4_tb_catch",value=-1000},
            {map="sp_a4_finale1",value=-1640},
            {map="sp_a4_finale2",value=-1220},
            {map="sp_a4_finale3",value=-550}
        ]

        foreach (i,dist in void_dists) {
            if (GetMapName() == dist.map) {
                this.yDist <- dist.value
                ppmod.interval(function () {
                    if (dingus.GetOrigin().z < yDist){
                        ppmod.fire(dingus,"dissolve")
                    }
                },0.5)
            }
        }

        IncludeScript("dingus/maps/"+GetMapName())
    })
}