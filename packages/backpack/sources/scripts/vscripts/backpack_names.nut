backpack.prop_names["models/props/metal_box.mdl"]                               <- {display_name = "Cube", command = "ent_create_portal_weighted_cube"}
backpack.prop_names["models/props/reflection_cube.mdl"]                         <- {display_name = "Reflector Cube", command = "ent_create_portal_reflector_cube"}
backpack.prop_names["models/props_gameplay/mp_ball.mdl"]                        <- {display_name = "Ball", command = "ent_create_portal_weighted_sphere"}
backpack.prop_names["models/props_underground/underground_weighted_cube.mdl"]   <- {display_name = "Antique Cube", command = "ent_create_portal_weighted_antique"}

backpack.prop_names["models/npcs/monsters/monster_a.mdl"]       <- {display_name = "Frankenturret", command = "ent_create prop_monster_box"}
backpack.prop_names["models/npcs/monsters/monster_A_box.mdl"]   <- backpack.prop_names["models/npcs/monsters/monster_a.mdl"]                    //frankenturret tucked?

//junk
backpack.prop_names["models/props/radio_reference.mdl"]                 <- {display_name = "Radio"}
backpack.prop_names["models/props_bts/bts_clipboard.mdl"]               <- {display_name = "Clipboard"}
backpack.prop_names["models/props/security_camera.mdl"]                 <- {display_name = "Wall Camera"}
backpack.prop_names["models/props/lab_chair/lab_chair.mdl"]             <- {display_name = "Lab Chair"}
backpack.prop_names["models/props/water_bottle/water_bottle.mdl"]       <- {display_name = "Water Bottle"}
backpack.prop_names["models/props/food_can/food_can_open.mdl"]          <- {display_name = "Beans"}
backpack.prop_names["models/props_debris/concrete_chunk02a.mdl"]        <- {display_name = "Rock"}
backpack.prop_names["models/gladdysdestruction/glados_junk_05_.mdl"]    <- {display_name = "Hoopy"}
backpack.prop_names["models/props/pc_case_open/pc_case_open.mdl"]       <- {display_name = "PC Case"}
backpack.prop_names["models/props/pc_case02/pc_case02.mdl"]             <- {display_name = "PC Case 2"}
backpack.prop_names["models/props_gameplay/laser_disc.mdl"]             <- {display_name = "Disc"}
backpack.prop_names["models/props_bts/bts_chair.mdl"]                   <- {display_name = "Chair"}
backpack.prop_names["models/props_debris/concrete_chunk07a.mdl"]        <- {display_name = "Large Rock"}
backpack.prop_names["models/props_debris/concrete_chunk08a.mdl"]        <- {display_name = "Medium Rock"}
backpack.prop_names["models/props_debris/concrete_chunk03a.mdl"]        <- {display_name = "Small Rock"}
backpack.prop_names["models/props_office/coffee_mug_01.mdl"]            <- {display_name = "Mug"}

backpack.prop_names["models/dingus_phys.mdl"]                           <- {display_name = "Maxwell"}


//npcs
backpack.prop_names["turrettrue"]                           <- {display_name = "Turret", command = "npc_portal_turret_floor"}
backpack.prop_names["turretfalse"]                          <- {display_name = "Dead Turret", command = "npc_portal_turret_floor"}
backpack.prop_names["models/npcs/turret/turret_boxed.mdl"]  <- {display_name = "Turret Box"}

backpack.prop_names["models/npcs/turret/turret.mdl"] <- {}

backpack.overrides <- [
    "models/props/radio_reference.mdl",
    "models/props_office/coffee_mug_01.mdl",
    "models/gladdysdestruction/glados_junk_05_.mdl"
]

local i = 1
while(i < 18) {
    i++
    local x = i
    if (i < 10) x = "0"+i
    backpack.prop_names["models/props_office/coffee_mug_"+x+".mdl"] <- {display_name = ""}
}

//ent_text prop_physics; ent_text prop_physics_override; ent_text prop_weighted_cube; ent_text npc_security_camera; ent_text npc_portal_turret_floor; ent_text prop_monster_box