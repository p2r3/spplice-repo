if(!("Entities" in this)) return;
if("rocket" in this) return;
IncludeScript("ppmod3");

::rocket <- {};

local auto = Entities.CreateByClassname("logic_auto");
ppmod.addscript(auto, "OnMapSpawn", "rocket.setup()");

rocket.setup <- function() {
  if (GetMapName()=="death_map"){
    ppmod.fire("weapon_portalgun", "Kill");
    ppmod.fire("viewmodel", "Kill");
    SendToConsole("crosshair 0");
    local txt = ppmod.text("Unfortunately Chell didn't survive the explosion \n Thanks for playing");
    txt.SetFade(0.05, 0.5, true);
    txt.Display(1);
    ppmod.wait(function(){
      SendToConsole("crosshair 1");
      SendToConsole("changelevel sp_a5_credits");
    }, 6.5);
    return;
  }
  if (GetMapName()=="sp_a5_credits") {
    ppmod.fire("weapon_portalgun", "Kill");
    ppmod.fire("viewmodel", "Kill");
    return; 
  }
  
  ppmod.once(function() {
    rocket.mapload();

    ppmod.fire("weapon_portalgun", "Kill");
    ppmod.fire("viewmodel", "Kill");

    ppmod.player.enable(function() {
      ppmod.wait(function() {

        ppmod.player.input("+attack", function() {
          SendToConsole("fire_rocket_projectile");
          SendToConsole("script rocket.fire()");
        });

      }, 0.1);
    });

    local txt = ppmod.text("", -1, 0.925);
    ppmod.interval(function(txt = txt) {
      
      txt.SetText("Health: " + max(0, GetPlayer().GetHealth()));
      txt.Display();

    });

    ppmod.interval(function() {

      if (ppmod.get("weapon_portalgun")) {
        ppmod.fire("weapon_portalgun", "Kill");
      }

    }, 2);

  }, "rocket_setup_once");

}

rocket.positions <- {};
rocket.fire <- function() {

  local ent = ppmod.prev("rocket_turret_projectile");

  local str = UniqueString("rocket");
  rocket.positions[str] <- Vector();

  ppmod.interval(function(str = str, ent = ent) {

    //mapupdates
    if (GetMapName()=="sp_a2_dual_lasers"){
      //vals
      local catcher = ppmod.get("laser_02");
      local catcherpos=catcher.GetOrigin();
      local entpos=rocket.positions[str];
      //impact?
      if (abs((catcherpos-entpos).Length())<60){
        local cubevalid=ppmod.get("catcheranchor");
        if(!cubevalid){
          //make anchor
          ppmod.create("ent_create_portal_reflector_cube", function(ent, catcher=catcher){
          ent.SetOrigin(Vector(-32, 367, 1216));
          ent.SetAngles(-90, 90, 0)
          ppmod.keyval(ent, "targetname", "catcheranchor");
          ppmod.keyval(ent, "RenderMode", 10);
          ppmod.keyval(ent, "CollisionGroup", 1);
          ppmod.keyval(catcher, "CollisionGroup", 1);
          ppmod.fire(catcher, "SetParent", "catcheranchor");
          ent.SetVelocity(Vector(0, -1000, 0));
          });
        }
      }
    }
    else if (GetMapName()=="sp_a1_intro4"){
      local glass=ppmod.get("glass_pane_fractured_model");
      local rocketpos=rocket.positions[str].z;
      if (abs((Vector(880, -520, 64)-rocket.positions[str]).Length())<100 && glass && rocketpos>110){
        //we hit the glass
        ppmod.fire(glass, "enable");
        ppmod.fire("glass_pane_intact_model", "break");
        ppmod.fire("glass_shard", "break")
        ppmod.fire("glass_pane_intact", "kill");
        ppmod.fire("glass_pane_1_door_1_blocker", "kill");
        ppmod.fire("glass_pane_1_door_1", "open");
      }
    }
    else if (GetMapName()=="sp_a1_intro6"){}
    else if (GetMapName()=="sp_a2_bts4"){
      if (abs((Vector(1443, -7088, 6695)-rocket.positions[str]).Length())<30){
        ppmod.fire("block_turret_trigger", "Enable");
        ppmod.fire("grab_turret_hint_trigger", "Enable");
        ppmod.fire("initial_turret_const", "Break");
        ppmod.fire("scanner_socket_new_turret_trigger", "Enable", 1.0);
        ppmod.fire("scanner_insert_new_turret_nag_1_trigger", "Enable", 10.0);
        ppmod.fire("initial_template_turret", "break");
      }
    }
    else if (GetMapName()=="sp_a3_end"){
        local offset= Vector(-1727, 255, 639)-rocket.positions[str];
        if (abs(offset.x)<=200 && abs(offset.y)<=200 && abs(offset.z)<=15){
          local brush = ppmod.get(Vector(-1728, 256, 638));
          if (brush){
            ppmod.fire(brush, "Kill");
          }
        }
    }
    else if (GetMapName()=="sp_a4_finale3"){
      if (abs((Vector(-128, -2750, 174)-rocket.positions[str]).Length())<100){
        ppmod.once(function(){
          ppmod.fire("practice_tube_broken", "SetAnimation", "pipe_explode_fin3_a_anim");
          ppmod.fire("fx_blob_3", "Stop");
          ppmod.fire("fx_blob_2", "Stop");
          ppmod.fire("fx_blob_1", "Stop");
          ppmod.fire("aud_paint_flow", "StopSound");
          ppmod.fire("practice_tube_broken", "Enable");
          ppmod.fire("practice_tube_intact", "Kill");
          ppmod.fire("practice_paint_sprayer", "Stop", "", 2);
          ppmod.fire("!activator", "Explode");
          ppmod.fire("practice_paint_sprayer", "Start");}, "do_once");
          ppmod.wait(function(){
            SendToConsole("portal_place 0 0 -483.480 -1536.031 -23.971 -0.000 -90.000 -0.000;");
            SendToConsole("portal_place 0 1 -111.311 -2481.439 128.031 -90.000 -87.692 0.000;");
          }, 3);
      }
    }
    else if (GetMapName()=="sp_a4_finale4"){

      local brush=ppmod.get("stalemate_clip_brush");
        if (brush){
          ppmod.fire(brush, "kill");
        }

      local offset1 = Vector(9, 319, 300)-rocket.positions[str];
      local offset2 = Vector(0, 1285, 87.5)-rocket.positions[str];
      local offset3 = Vector(0, 1800, 10)-rocket.positions[str];
      if (abs(offset1.x)<=50 && abs(offset1.y)<=125 && abs(offset1.z)<=160){
        local do_once = ppmod.once(function(){
          ppmod.fire("!activator", "Explode");
          ppmod.fire("wheatley_hit_effects_relay", "Trigger");
          ppmod.fire("wheatley_hit_count", "Add", "1");
          ppmod.wait(function(){
            ppmod.fire("hit_once", "Kill");
          },5);
        }, "hit_once");
        
      }
      else if ((abs(offset3.x)<=90 && abs(offset3.y)<=100 && abs(offset3.z)<=30)){
          ppmod.once(function(){
            ppmod.fire("stalemate_light_timer", "Disable");
            ppmod.fire("light_dynamic_stalemate", "TurnOff", "", 2);
            ppmod.fire("boss_music10", "PlaySound");
            ppmod.fire("@glados", "RunScriptCode", "BBButtonPressed()", 0.1);
            ppmod.fire("stalemate_shield_reset_relay", "Trigger");
            ppmod.fire("wheatley_stalemate_nag_relay", "Disable");
            ppmod.fire("stalemate_button_relay", "Trigger", "", 0.5);
            ppmod.wait(function(){
              SendToConsole("changelevel  death_map");
            }, 2.5);
            
          }, "end_thing")
        }
    }
    

    local vel = GetPlayer().GetVelocity();
    local vec = rocket.positions[str] - GetPlayer().GetCenter();
    local mag = max(0, 400 - vec.Norm());

    if (!ent || !ent.IsValid()) {

      GetPlayer().SetVelocity(vel - vec * mag);
      ppmod.get("interval_" + str).Destroy();
      delete rocket.positions[str];

    } else {

      rocket.positions[str] <- ent.GetOrigin();

    }

  }, 0, "interval_" + str);

}




rocket.mapload <- function () {
  printl("Successfully Loaded Mod");
  if (GetMapName()=="sp_a1_intro3"){
    ppmod.fire("portalgun", "kill");
    ppmod.fire("portalgun_button", "kill");
    local gun = ppmod.get(Vector(25.230, 1958.720, -299), "trigger_once");
    ppmod.fire(gun, "kill");
  }
  else if (GetMapName()=="sp_a1_intro4"){
    local trigger=ppmod.get(Vector(878, -528, 137), "trigger_once");
    ppmod.fire(trigger, "kill");
  }
  else if (GetMapName()=="sp_a1_intro5"){
    local portaltrigger=ppmod.trigger(Vector(0, -832, 128), Vector(45, 45, 45), "once");
    ppmod.addscript(portaltrigger, "OnStartTouch", function(){
      SendToConsole("portal_place 0 0 -2.762 -422.008 128.031 -90.000 -89.977 0.000;");
    });
  }
  else if (GetMapName()=="sp_a1_intro6"){
    local cube = ppmod.get(Vector(256, 192, 18.156), "prop_weighted_cube", 10);
    ppmod.fire(cube, "kill");
    ppmod.create("ent_create_portal_weighted_cube", function(cube){
      cube.SetOrigin(Vector(0, -32, -384));
    });
  }
  else if (GetMapName()=="sp_a2_intro"){
    ppmod.fire("portalgun", "kill");
    ppmod.fire("portalgun_button", "kill");
    local gun = ppmod.get(Vector(-1027, 449, -11062), "player_near_portalgun");
    ppmod.fire(gun, "kill");
  }
  else if (GetMapName()=="sp_a2_dual_lasers"){
    local trigger = ppmod.trigger(Vector(-224, -360, 900), Vector(30, 20, 100), "once");
    ppmod.addscript(trigger, "OnStartTouch", function(){
      local text = ppmod.text("Warning, DO NOT shoot testing elements \n as it can cause them to detach from walls", -1, 0.7);
      text.SetColor("255 0 0", "160 0 0");
      text.SetFade(1, 0.5);
      text.SetChannel(1);
      text.Display(3);

    })
  }
  else if (GetMapName()=="sp_a2_fizzler_intro"){
    local catcher=ppmod.get("env_portal_laser");
    ppmod.create("env_portal_laser", function(laser){
      laser.SetOrigin(Vector(-10, -1033, 20));
      laser.SetAngles(0, 90, 0);
    });
    ppmod.fire(catcher, "TurnOff");
    local end=ppmod.get("prop_laser_catcher");
    end.SetOrigin(Vector(96, 111, 10));
    
  }
  else if (GetMapName()=="sp_a2_sphere_peek"){
    local catcher=ppmod.get("prop_laser_catcher");
    catcher.SetOrigin(Vector(-1000, 1235, 96));
  }
  else if (GetMapName()=="sp_a2_bridge_intro"){
    SendToConsole("portal_place 0 0 767.969 54.404 -438.221 -0.000 180.000 0.000;");
    SendToConsole("portal_place 0 1 302.969 -768.000 56.029 -0.000 180.000 0.000;")
  }
  else if (GetMapName()=="sp_a2_laser_relays"){
    local cube=ppmod.get("extracube");
    if (cube) return;
    ppmod.create("ent_create_portal_reflector_cube", function(cube){
      cube.SetOrigin(Vector(-550, -394, 19));
      ppmod.keyval(cube, "targetname", "extracube");
    });
  }
  else if (GetMapName()=="sp_a2_bts1"){
    SendToConsole("portal_place 0 0 -9032.031 -1664.000 56.029 -0.000 180.000 0.000;");
    SendToConsole("portal_place 0 1 -9728.000 -416.031 448.000 -0.000 -90.000 -0.000;")
  }
  else if (GetMapName()=="sp_a2_bts3"){
    ppmod.fire("entry_airlock_door-door_1", "kill");
    ppmod.fire("entry_airlock_door-door_1_clip", "kill");
    local trigger =ppmod.trigger(Vector(9530, 5216, -447), Vector(200, 100, 50), "once");
    ppmod.addscript(trigger, "OnStartTouch",function(){
      SendToConsole("portal_place 0 0 9502.996 5391.969 -391.969 -0.000 -90.000 -0.000;");
      SendToConsole("portal_place 0 1 8653.994 6304.031 -195.600 -0.000 90.000 0.000;");
    });
  }
  else if (GetMapName()=="sp_a2_bts4"){
    local trigger = ppmod.trigger(Vector(2896, -4926, 6656), Vector(30, 35, 30), "once");
    ppmod.addscript(trigger, "OnStartTouch",function(){
      SendToConsole("portal_place 0 0 2815.969 -5110.049 6679.852 -0.000 180.000 0.000;");
      SendToConsole("portal_place 0 1 2064.031 -5209.664 6715.947 -0.000 0.000 0.000;");
    });
  }
  else if (GetMapName()=="sp_a3_01"){
    local portal_trigger = ppmod.trigger(Vector(4560, 3750, -380), Vector(240, 1710, 130), "once");
    ppmod.addscript(portal_trigger, "OnStartTouch", function(){
      SendToConsole("portal_place 0 0 4700 3752 -320 -0.000 90.000 0.000;");
      SendToConsole("portal_place 0 1 4568 5325 -320 -0.000 0.000 0.000;");
    })
  }
  else if (GetMapName()=="sp_a4_intro"){
    local portal_trigger=ppmod.trigger(Vector(-600, 0, 256), Vector(25,25,25), "once");
    ppmod.addscript(portal_trigger,"OnStartTouch", function(){
      SendToConsole("portal_place 0 0 -656 -19 316 -0.000 0 0.000;");
      SendToConsole("portal_place 0 1 -864 -190 160 -0.000 0.000 0.000;");
    })
  }
  else if (GetMapName()=="sp_a4_tb_intro"){
    local trigger=ppmod.trigger(Vector(1660, 100, 290), Vector(200, 80, 10), "once");
    ppmod.addscript(trigger,"OnStartTouch", function(){
      SendToConsole("portal_place 0 0 1664 895 -512 -90.000 0.000 0.000;");
      SendToConsole("portal_place 0 1 1664 512 544 90 0.000 0.000;");
    })
  }
  else if (GetMapName()=="sp_a4_laser_platform"){
    local trigger = ppmod.trigger(Vector(575, -2430, 400), Vector(50, 200, 400), "once");
    ppmod.addscript(trigger, "OnStartTouch", function(){
      SendToConsole("portal_place 0 0 895.969 -1472.000 192.000 0.000 180.000 0.000; ");
      SendToConsole("portal_place 0 1 -92.646 -1152.031 328.031 0.000 -90.000 0.000; ");
      
    })
  }
  else if (GetMapName()=="sp_a4_finale3"){
    local brush=ppmod.brush(Vector(-128, -2750, 174), Vector(100, 50, 100));
    local trigger=ppmod.trigger(Vector(-607, 5377, 250), Vector(80, 150, 100), "once");
    ppmod.addscript(trigger, "OnStartTouch", function(){
      SendToConsole("portal_place 0 0 -703.969 5373.992 247.074 -0.000 0.000 0.000; ");
      SendToConsole("portal_place 0 1 -703.969 5377.064 715.152 0.000 0.000 0.000; ");
    })
  }
}