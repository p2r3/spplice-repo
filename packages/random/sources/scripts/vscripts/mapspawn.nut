if(!("Entities" in this)) return;
IncludeScript("ppmod3");

if(!("randm" in this)) {

  ::randm <- {};

  randm.auto <- Entities.CreateByClassname("logic_auto");

  ppmod.addscript(randm.auto, "OnNewGame", "randm.setup()");
  ppmod.addscript(randm.auto, "OnMapTransition", "randm.setup()");

  randm.map_names <- [
    "sp_a1_intro1"
    "sp_a1_intro2",
    "sp_a1_intro3",
    "sp_a1_intro4",
    "sp_a1_intro5",
    "sp_a1_intro6",
    "sp_a1_intro7",
    "sp_a1_wakeup",
    "sp_a2_intro",
    "sp_a2_laser_intro",
    "sp_a2_laser_stairs",
    "sp_a2_dual_lasers",
    "sp_a2_laser_over_goo",
    "sp_a2_catapult_intro",
    "sp_a2_trust_fling",
    "sp_a2_pit_flings",
    "sp_a2_fizzler_intro",
    "sp_a2_sphere_peek",
    "sp_a2_ricochet",
    "sp_a2_bridge_intro",
    "sp_a2_bridge_the_gap",
    "sp_a2_turret_intro",
    "sp_a2_laser_relays",
    "sp_a2_turret_blocker",
    "sp_a2_laser_vs_turret",
    "sp_a2_pull_the_rug",
    "sp_a2_column_blocker",
    "sp_a2_laser_chaining",
    "sp_a2_triple_laser",
    "sp_a2_bts1",
    "sp_a2_bts2",
    "sp_a2_bts3",
    "sp_a2_bts4",
    "sp_a2_bts5",
    "sp_a2_bts6",
    "sp_a2_core",
    "sp_a3_00",
    "sp_a3_01",
    "sp_a3_03",
    "sp_a3_jump_intro",
    "sp_a3_bomb_flings",
    "sp_a3_crazy_box",
    "sp_a3_transition01",
    "sp_a3_speed_ramp",
    "sp_a3_speed_flings",
    "sp_a3_portal_intro",
    "sp_a3_end",
    "sp_a4_intro",
    "sp_a4_tb_intro",
    "sp_a4_tb_trust_drop",
    "sp_a4_tb_wall_button",
    "sp_a4_tb_polarity",
    "sp_a4_tb_catch",
    "sp_a4_stop_the_box",
    "sp_a4_laser_catapult",
    "sp_a4_laser_platform",
    "sp_a4_speed_tb_catch",
    "sp_a4_jump_polarity",
    "sp_a4_finale1",
    "sp_a4_finale2",
    "sp_a4_finale3",
    "sp_a4_finale4"
  ]

}

randm.setup <- function() {
  local speedmod = ppmod.get("player_speedmod")
  ppmod.fire(speedmod, "ModifySpeed", 1)

  // printl("");
  // printl(GetPlayer().GetName());
  // printl("");
  compilestring(GetPlayer().GetName())();
  if ("count" in randm) {
    local txt = ppmod.text("", 0.005, 1)
    txt.SetChannel(5)
    ppmod.interval(function(txt = txt) {
        // txt.SetText(round(randm.count / 61.0 * 100) + "%");
        txt.SetText("Maps Done: " + randm.count + "/61")
		    txt.Display();
		});
  }
  if (GetMapName() == "sp_a2_intro" && randm.change) {
    EntFire("camera_ghostanim", "Disable");
    EntFire("camera_ghostanim", "Kill", "", FrameTime());
    EntFire("ghostanim", "Kill", "", FrameTime());
    SendToConsole("crosshair 1")
  }
  if (GetMapName() == "sp_a3_jump_intro") {
    GetPlayer().SetOrigin(Vector(-432.0, 2066.0, -63.0))
  }
  if (GetMapName() == "sp_a2_bts5") {
    GetPlayer().SetOrigin(Vector(3744.0, -1729, 3448.58))
  }
  if (GetMapName() == "sp_a4_finale2") {
    GetPlayer().SetOrigin(Vector(3907.0, 993.5, -128))
  }
  if (GetMapName() == "sp_a2_core") {
    GetPlayer().SetOrigin(Vector(150.0, 3094.2, -328))
  }
  if (GetMapName() == "sp_a2_fizzler_intro") {
    GetPlayer().SetOrigin(Vector(-992.0, -128.0, 540.53))
  }

  if(!("maps" in randm)) {
    //replace 2 with 61
    randm.maps <- array(61);

    for(local i = 0; i < 61; i ++) {

      randm.maps[i] = false;
      if(randm.map_names[i] == GetMapName()) randm.maps[i] = true;
    }
  }

  if(!("change" in randm)) randm.change <- false;
  if(!("count" in randm)) randm.count <- 0;




    if(randm.change) {
      randm.count ++;
      printl(randm.maps.len())
      if(randm.count < 61) {
        local r;
        //replace 1 with 60
        while(randm.maps[r = RandomInt(0, 60)]);

        randm.maps[r] = true;
        randm.changeto <- r;
    } else {
      printl("yay you did it");
      randm.change = false;
      SendToConsole("map sp_a5_credits")


    }
  }

  local scr = "randm.change <- " + (!randm.change).tostring() + "; randm.count <- " + randm.count + "; randm.maps <- [";
  //replace 2 with 61
  for(local i = 0; i < 61; i ++) {
    scr += randm.maps[i].tostring() + ",";
  }
  scr += "0]";
  ppmod.keyval(GetPlayer(), "Targetname", scr);

  if(("changeto" in randm)) {
    if (randm.map_names[randm.changeto] != GetMapName) {
      local changelevel = Entities.CreateByClassname("point_changelevel");
      if(ppmod.get("info_landmark_exit")) GetPlayer().SetOrigin(ppmod.get("info_landmark_exit").GetOrigin());
      ppmod.fire(changelevel, "ChangeLevel", randm.map_names[randm.changeto]);
    }
  }

  SendToConsole("save random_restart");
  SendToConsole("alias restart_level \"load random_restart\"");
  SendToConsole("alias restart \"load random_restart\"");
}