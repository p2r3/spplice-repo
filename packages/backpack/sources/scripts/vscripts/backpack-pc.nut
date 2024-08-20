if (!("Entities" in this)) return
IncludeScript("ppmod3")
IncludeScript("util")

//this code makes me sick, cry, and vomit

::backpack <- {}
backpack.ui_open <- false
backpack.hovering <- 0
backpack.last_down_down <- 0
backpack.last_up_down <- 0
backpack.ui <- ppmod.text("", -1, -0.1)
backpack.ui.SetChannel(2)

backpack.unique_voider <- 0
backpack.void_index <- {}
backpack.void_ents <- {}
backpack.summoned_ents <- []

backpack.prop_names <- {}
IncludeScript("backpack_names")

ppmod.interval(function () {
    if (backpack.last_down_down > 0.35) {
        backpack.down()
    } else if (backpack.last_up_down > 0.35) {
        backpack.up()
    }
},FrameTime() * 6)

backpack.get_display_name <- function(prop_name) {
    if (prop_name in backpack.prop_names) return backpack.prop_names[prop_name].display_name
    if (prop_name.find("map_") != null) {
        return "Map "+backpack.prop_names[util.string.split(util.string.split(prop_name, "map_")[1], "#")[0]].display_name + " #" + util.string.split(prop_name, "#")[1]
    }
    return prop_name
}

backpack.get_create_command <- function (prop_name) {
    if (prop_name in backpack.prop_names && "command" in backpack.prop_names[prop_name]) return backpack.prop_names[prop_name].command
    return "prop_physics_create " + util.string.replace(prop_name, "models/", "") //temp
}

backpack.generate_relays <- function () {
    SendToConsole("alias +mouse_menu \"backpack_grab\"")
    SendToConsole("alias +mouse_menu_taunt \"backpack_toggle\"")
    if (GetMapName() == "sp_a1_intro1") SendToConsole("alias +mouse_menu_taunt ")

    local relays = ["up_up", "up_down", "down_up", "down_down", "toggle", "enter", "grab", "maxwell"]
    foreach (relay in relays) {
        if (relay.find("_") == null) SendToConsole("alias backpack_"+relay+" \"ent_fire backpack_"+relay+" trigger\"")
        local ent = Entities.CreateByClassname("logic_relay")
        ent.__KeyValueFromString("targetname", "backpack_"+relay)
        switch (relay) {
            case "up_up": ppmod.addscript(ent, "OnTrigger", backpack.up_up_relay); break
            case "up_down": ppmod.addscript(ent, "OnTrigger", backpack.up_down_relay); break
            case "down_up": ppmod.addscript(ent, "OnTrigger", backpack.down_up_relay); break
            case "down_down": ppmod.addscript(ent, "OnTrigger", backpack.down_down_relay); break
            case "toggle": ppmod.addscript(ent, "OnTrigger", backpack.toggle_relay); break
            case "enter": ppmod.addscript(ent, "OnTrigger", backpack.enter_relay); break
            case "grab": ppmod.addscript(ent, "OnTrigger", backpack.grab_relay); break
            case "maxwell": ppmod.addscript(ent, "OnTrigger", backpack.maxwell_relay)
        }
    }

    SendToConsole("alias -backpack_up \"ent_fire backpack_up_up trigger\"")
    SendToConsole("alias +backpack_up \"ent_fire backpack_up_down trigger\"")
    SendToConsole("alias -backpack_down \"ent_fire backpack_down_up trigger\"")
    SendToConsole("alias +backpack_down \"ent_fire backpack_down_down trigger\"")
}

backpack.update_ui <- function () {
    if (!backpack.ui_open) {backpack.ui.Display(); return}

    local text = "BACKPACK"

    local line = 2
    while (true) {
        local slot = util.save.read_slot(backpack.hovering + line)
        if (slot) {
            slot = util.string.split(slot, ":")
            text += "\n"+(line == 0 ? "> "  : "- ") + backpack.get_display_name(slot[0]) + " ("+slot[1]+")"
        } else {
            text += "\n- "
        }
        line --
        if (line == -3) break
    }

    backpack.ui.SetFade(0.1, 0, false)
    backpack.ui.SetText(text)
    backpack.ui.Display(99999999)
}



backpack.enter_relay <- function () {
    if (!backpack.ui_open) return
    local data = util.save.read_slot(backpack.hovering)
    if (!data) return
    data = util.string.split(data, ":")
    local prop_name = data[0]
    local amount = data[1]


    if (amount == "1") {
        util.save.write_slot("", backpack.hovering)
        local i = backpack.hovering
        while (true) {
            i++
            local data = util.save.read_slot(i)
            if (data != null) {
                util.save.write_slot("",i)
                util.save.write_slot(data,i - 1)
            } else break
        }
    } else {
        util.save.write_slot(prop_name+":"+(""+(amount.tointeger() - 1)),backpack.hovering)
    }

    if (util.array.find(backpack.overrides, prop_name) != null) {
        if (prop_name == "models/props_office/coffee_mug_01.mdl") {
            local random = RandomInt(1, 17)
            if (random == 13 || random == 15 || random == 16 || random == 14) random = 1
            prop_name = "models/props_office/coffee_mug_"+random+".mdl"
            if (random < 10) prop_name = "models/props_office/coffee_mug_0"+random+".mdl"
        }

        ppmod.create(prop_name.slice(7,prop_name.len()), function (dummy, prop_name = prop_name) {
            dummy.Destroy();
            ppmod.create("prop_physics_create props_bts/bts_clipboard.mdl", function (prop, prop_name = prop_name) {
                prop.SetModel(prop_name);
                ppmod.keyval(prop, "Classname", "prop_physics_override");
                prop.SetOrigin(GetPlayer().EyePosition())

                ppmod.player.holding(function (bool, prop=prop) {
                    if (!bool) ppmod.fire(prop, "Use", "", 0, GetPlayer(), GetPlayer())
                })
            });
        });
    } else if (prop_name.find("map_") != null) {
        local cube = backpack.void_ents[prop_name]
        if (cube != null) {
            ppmod.fire(cube, "enablemotion")
            cube.SetOrigin(GetPlayer().EyePosition())
            ppmod.player.holding(function (bool, cube=cube) {
                if (!bool) ppmod.fire(cube, "Use", "", 0, GetPlayer(), GetPlayer())
            })
        }

    } else {
        ppmod.create(backpack.get_create_command(prop_name), function (prop, prop_name = prop_name) {
            backpack.summoned_ents.append(prop)
            prop.SetOrigin(GetPlayer().EyePosition())
            if (prop_name == "turretfalse") {
                ppmod.fire(prop, "disable")
                backpack.turret_mortem[prop] <- false
            } else if (prop_name == "models/dingus_phys.mdl") SendToConsole("snd_playsounds dingus.meow")

            ppmod.player.holding(function (bool, prop=prop) {
                if (!bool) ppmod.fire(prop, "Use", "", 0, GetPlayer(), GetPlayer())
            })

            ppmod.addscript(prop, "OnFizzle", function (prop = prop) {
                backpack.summoned_ents.remove(util.array.find(backpack.summoned_ents, prop))
            })
        })
    }

    SendToConsole("snd_playsounds P2Editor.ConfigPseudoHandleChanged")
    if (util.save.read_slot(backpack.hovering) == null && backpack.hovering > 0) backpack.hovering --
    if (GetPlayer().GetName() == "") backpack.ui_open = false
    backpack.update_ui()

    if (GetMapName() == "sp_a1_intro1") {
        SendToConsole("gameinstructor_enable 0")
    }

}

backpack.up <- function () {
    if (!backpack.ui_open) return
    if (util.save.read_slot(backpack.hovering + 1) == null) return
    backpack.hovering ++
    backpack.update_ui()

    SendToConsole("snd_playsounds P2Editor.MenuIncrement")
}

backpack.down <- function () {
    if (!backpack.ui_open) return
    if (util.save.read_slot(backpack.hovering -1) == null) return
    backpack.hovering --
    backpack.update_ui()

    SendToConsole("snd_playsounds P2Editor.MenuDecrement")
}

backpack.toggle_relay <- function () {
    backpack.ui_open <- !backpack.ui_open
    backpack.update_ui()

    if (backpack.ui_open) {
        SendToConsole("exec backpack_binds")
    } else {
        SendToConsole("exec backpack_backup")
    }

    if (GetMapName() == "sp_a1_intro1") {
        local hint = ppmod.get("inv_hint")
        if (hint != null) {
            ppmod.keyval(hint, "hint_caption", "Use up and down arrows to scroll through your inventory, Press ENTER to select a prop")
            ppmod.keyval(hint, "hint_binding", "backpack_enter")
            ppmod.fire(hint, "showhint")
        }
    }

    SendToConsole("snd_playsounds P2Editor.MenuSelect")
}


backpack.maxwell_relay <- function () {
    backpack.add_item_relay("models/dingus_phys.mdl")
    backpack.update_ui()
    SendToConsole("snd_playsounds dingus.meow")
}

backpack.up_down_relay <- function () {
    backpack.up()
    backpack.last_up_down <- Time()
    backpack.last_down_down <- 0
}

backpack.up_up_relay <- function () {
    backpack.last_up_down <- 0
}

backpack.down_down_relay <- function () {
    backpack.down()
    backpack.last_down_down <- Time()
    backpack.last_up_down <- 0
}

backpack.down_up_relay <- function () {
    backpack.last_down_down <- 0
}

backpack.add_item_relay <- function(model) {
    if (model.find("models/props_office/coffee_mug_") != null) {
        model = "models/props_office/coffee_mug_01.mdl"
    } else if (model == "models/props_bts/bts_chair_static.mdl") model = "models/props_bts/bts_chair.mdl"

    local slot_iterator = 0
    while(slot_iterator < 2) {

        if (slot_iterator == 0) {
            local slot = 0
            while (true) {
                local slot_data = util.save.read_slot(slot)
                if (slot_data != null) {
                    local split = util.string.split(slot_data, ":")
                    if (split[0] == model) {
                        util.save.write_slot(model+":"+((split[1].tointeger()) + 1), slot)
                        return
                    }
                } else break

                slot ++
            }
        } else {
            local slot = 0
            while (true) {
                local slot_data = util.save.read_slot(slot)
                if (slot_data == null) {
                    util.save.write_slot(model+":1",slot)
                    return
                }

                slot ++
            }
        }

        slot_iterator ++
    }
}

::transition <- function () {
    local i = 0
    while(true) {
        local data = util.save.read_slot(i)
        if (data == null) break
        if (data.find("map_") != null) {
            local model = util.string.split(util.string.replace(data,"map_",""),"#")[0]
            util.save.write_slot("",i)
            backpack.add_item_relay(model)

            local above =i
            while (true) {
                above++
                local data = util.save.read_slot(above)
                if (data != null) {
                    util.save.write_slot("",above)
                    util.save.write_slot(data,above - 1)
                } else break
            }
        }
        i++
    }

}

backpack.main <- function () {
    ppmod.player.enable(function () {
        backpack.grab_relay <- function () {
            local start = ppmod.player.eyes.GetOrigin()
            local vec = ppmod.player.eyes_vec() * 100
            local end = start + vec

            local dir = end - start
            local len = dir.Norm()
            local div = [1.0 / dir.x, 1.0 / dir.y, 1.0 / dir.z]
            local precalc = [len, div]

            local world_frac = ppmod.ray(start, end, null, true, precalc)
            local dropper_frac1 = ppmod.ray(start, end, "models/props_backstage/item_dropper_wrecked.mdl", false, precalc)
            local dropper_frac2 = ppmod.ray(start, end, "models/props_backstage/item_dropper.mdl", false, precalc)
            local dropper_frac3 = ppmod.ray(start, end, "models/props_underground/underground_boxdropper.mdl", false, precalc)

            local fracs = {}

            foreach (model, x in backpack.prop_names) {
                local frac = ppmod.ray(start, end, model, false, precalc)
                if( (frac < world_frac) && (frac < dropper_frac1) && (frac < dropper_frac2) && (frac < dropper_frac3) ) {
                    local ent = null; while(ent = ppmod.get(model, ent)) {
                        if (ent.GetClassname() == "simple_physics_prop" || ent.GetName() == "slimeroom_box_1_template" || ent.GetClassname() == "prop_dynamic") return
                        fracs[ent] <- ppmod.ray(start, end, ent, false, precalc)
                    }
                }
            }
            if (fracs.len() == 0) return

            local ent = util.array.get_smallest_value(fracs)
            local model = ent.GetModelName()

            if (model == "models/dingus_phys.mdl") SendToConsole("snd_playsounds dingus.meow")

            SendToConsole("snd_playsounds P2Editor.ExtrudeGeo")
            local boxes = ["models/props/metal_box.mdl", "models/props/reflection_cube.mdl", "models/props_underground/underground_weighted_cube.mdl"]

            if (util.array.find(boxes, model) == null || (util.array.find(boxes, model) != null && (util.array.find(backpack.summoned_ents, ent) != null || !(ent in backpack.void_index)) )) {
                if (model == "models/npcs/turret/turret.mdl") {
                    model = "turret" + backpack.turret_mortem[ent]
                    delete backpack.turret_mortem[ent]
                }

                backpack.add_item_relay(model)
                backpack.update_ui()
                ent.Destroy()
            } else if (util.array.find(backpack.summoned_ents, ent) == null) {
                local slot_iterator = 0
                while (true) {
                    if (util.save.read_slot(slot_iterator) == null) break
                    slot_iterator ++
                }

                local string = "map_"+model+"#"+backpack.void_index[ent]
                util.save.write_slot(string+":1",slot_iterator)
                backpack.update_ui()
                backpack.void_ents[string] <- ent
                ent.SetOrigin(Vector(99999,99999,99999))
                ppmod.fire(ent,"disablemotion")
                ppmod.addscript(ent, "OnFizzled", function (slot = slot_iterator) {
                    util.save.write_slot("",slot)
                    backpack.update_ui()
                })
            }
        }
        backpack.generate_relays()
    })

    //util.save.write_slot("map_models/props/metal_box.mdl#1:1",0)

    backpack.turret_mortem <- {}
    ppmod.interval(function () {
        local turret = null; while(turret = ppmod.get("npc_portal_turret_floor", turret)) {
            if (!(turret in backpack.turret_mortem)) {
                backpack.turret_mortem[turret] <- true
                ppmod.addscript(turret, "OnTipped", function (turret=turret) {
                    backpack.turret_mortem[turret] <- false
                })
            }
        }
    },0.25)

    local point_template = null; while(point_template = ppmod.get("env_entity_maker", point_template)) {
        ppmod.addscript(point_template, "OnEntitySpawned", function (point_template = point_template) {
            local cube = ppmod.get(point_template.GetOrigin(), "prop_weighted_cube", 128)
            if (cube != null) {
                backpack.unique_voider ++
                backpack.void_index[cube] <- backpack.unique_voider
            }
        })
    }

    if (GetMapName() == "sp_a1_intro1") {
        SendToConsole("fadein 1")
        local Camera = ppmod.get("ghostAnim")
        Camera.SetOrigin(Vector(-1213.786621 4446.816895 2727.031250))
        Camera.SetAngles(0,180,0)
        GetPlayer().SetOrigin(Vector(-1213.786621 4446.816895 2769.031250))

        SendToConsole("map_wants_save_disable 0")

        ppmod.fire("@rl_poststasis_exposure_reload", "Enable")
        ppmod.fire("@rl_poststasis_exposure_reload", "Trigger")
        ppmod.fire("good_morning_vcd", "Kill")
        ppmod.fire("@glados", "RunScriptCode", "GladosPlayVcd(\"PreHub01RelaxationVaultIntro01\")")
        ppmod.fire("glass_break","kill")

        ppmod.get(Vector(-1232, 4400, 2856.5),"trigger_once",16).Destroy()

        SendToConsole("gameinstructor_enable 1")

        ppmod.wait(function () {
            delete backpack.prop_names["models/props_bts/bts_clipboard.mdl"]


            local instructor = Entities.CreateByClassname("env_instructor_hint")
            ppmod.keyval(instructor, "targetname", "grab_hint")
            ppmod.keyval(instructor, "hint_target", "radio")
            ppmod.keyval(instructor, "hint_caption", "Use your coop ping button to stash props")
            ppmod.keyval(instructor, "hint_static", "0")
            ppmod.keyval(instructor, "hint_nooffscreen", "0")
            ppmod.keyval(instructor, "hint_binding", "mouse_menu")
            ppmod.keyval(instructor, "hint_timeout", 0)
            ppmod.keyval(instructor, "hint_color", "255 255 255")
            ppmod.keyval(instructor, "hint_icon_onscreen", "use_binding")
            ppmod.fire(instructor, "ShowHint")

            local clipboard = Entities.FindByModel(null, "models/props_bts/bts_clipboard.mdl")
            ppmod.keyval(clipboard, "targetname", "clipboard")


            ::grabbed <- false
            local inv_loop = null; inv_loop = ppmod.interval(function (inv_loop = inv_loop, instructor = instructor) {
                if (ppmod.get("radio") == null && ppmod.get("clipboard") != null) {
                    backpack.prop_names["models/props_bts/bts_clipboard.mdl"] <- {display_name = "Clipboard"}
                    ppmod.keyval(instructor, "hint_target", "clipboard")
                    ppmod.fire(instructor, "ShowHint")
                } else if (ppmod.get("radio") == null && ppmod.get("clipboard") == null) {
                    if (!grabbed) {
                        ::grabbed <- true
                        ppmod.fire(inv_loop, "disable")
                        ppmod.fire(instructor, "endhint")
                        SendToConsole("alias +mouse_menu_taunt \"backpack_toggle\"")

                        local instructor2 = Entities.CreateByClassname("env_instructor_hint")
                        ppmod.keyval(instructor2, "targetname", "inv_hint")
                        ppmod.keyval(instructor2, "hint_target", "")
                        ppmod.keyval(instructor2, "hint_static", 1)
                        ppmod.keyval(instructor2, "hint_caption", "Use your coop gesture menu button to view your backpack")
                        ppmod.keyval(instructor2, "hint_binding", "mouse_menu_taunt")
                        ppmod.keyval(instructor2, "hint_color", "255 255 255")
                        ppmod.keyval(instructor2, "hint_icon_onscreen", "use_binding")
                        ppmod.fire(instructor2, "ShowHint")
                    }
                }

            },0.1)
        },11)
    } else SendToConsole("gameinstructor_enable 0")

    ppmod.fire("@transition_script", "RunScriptCode", "TransitionFromMap<-function(){::transition();RealTransitionFromMap()}")
}


local auto = Entities.CreateByClassname("logic_auto")
ppmod.addscript(auto, "OnNewGame", backpack.main)
ppmod.addscript(auto, "OnMapTransition", backpack.main)
