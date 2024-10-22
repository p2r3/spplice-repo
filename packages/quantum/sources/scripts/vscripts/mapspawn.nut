if (!("Entities" in this)) return;
if ("Qbalance" in this) return;
IncludeScript("ppmod3");

::Qportals <- [];
::Qbalance <- 0;
::QportalCount <- 0;
::QtutorialDone <- true;

::QportalEnts <- {};
::Qweights <- {};

::Qweights["models/player/chell/player.mdl"] <- 85;
::Qweights["models/props/metal_box.mdl"] <- 40;
::Qweights["models/npcs/monsters/monster_A_box.mdl"] <- 40;
::Qweights["models/npcs/monsters/monster_a.mdl"] <- 40;
::Qweights["models/props_underground/underground_weighted_cube.mdl"] <- 40;
::Qweights["models/props/reflection_cube.mdl"] <- 40;
::Qweights["models/props/security_camera.mdl"] <- 20;
::Qweights["models/props/food_can/food_can_open.mdl"] <- 1;
::Qweights["models/props/water_bottle/water_bottle.mdl"] <- 1;
::Qweights["models/props_office/cardboardbox_b_1970.mdl"] <- 1;
::Qweights["models/npcs/personality_sphere/personality_sphere.mdl"] <- 75;
::Qweights["models/props/lab_chair/lab_chair.mdl"] <- 20;
::Qweights["models/props_bts/bts_chair_static.mdl"] <- 20;
::Qweights["models/props_gameplay/mp_ball.mdl"] <- 40;
::Qweights["models/props/radio_reference.mdl"] <- 20;
::Qweights["models/props_bts/bts_clipboard.mdl"] <- 1;
::Qweights["models/props_gameplay/laser_disc.mdl"] <- 1;
::Qweights["models/npcs/turret/turret.mdl"] <- 100;
::Qweights["models/npcs/turret/turret_skeleton.mdl"] <- 80;
::Qweights["models/npcs/turret/turret_skeleton.mdl"] <- 80;
::Qweights["models/props/futbol.mdl"] <- 20;

for (local i = 1; i <= 17; i ++) {
  if (i < 10) ::Qweights["models/props_office/coffee_mug_0"+(i)+".mdl"] <- 1;
  else ::Qweights["models/props_office/coffee_mug_"+(i)+".mdl"] <- 1;
}

local weaponstrip = Entities.CreateByClassname("player_weaponstrip");

local balanceCheck = function ():(weaponstrip) {

  local map = GetMapName().tolower();
  if (map == "sp_a1_intro1" || map == "sp_a1_intro2") return;

  if (::Qbalance < -10 || ::Qbalance > 10 || ::QportalCount > 0 || ppmod.get("hold_portalgun_prop") || ppmod.get("hold_portalgun_wait")) {

    ppmod.fire(weaponstrip, "Strip");

    ppmod.wait(function ():(weaponstrip,map) {
      ppmod.fire("viewmodel", "DisableDraw");
    }, 1, "disableVMTimer");

  } else {

    if (Entities.FindByClassnameWithin(null, "weapon_portalgun", GetPlayer().GetOrigin(), 32)) return;

    ppmod.give("weapon_portalgun", function (ent):(weaponstrip,map) {

      ppmod.fire(ent, "DisableDraw");
      ent.SetOrigin(GetPlayer().GetCenter());

      ppmod.fire("disableVMTimer", "Kill");
      ppmod.fire("viewmodel", "EnableDraw", "", FrameTime());

      if (map != "sp_a1_intro3" && map != "sp_a1_intro4" && map != "sp_a1_intro5" && map != "sp_a1_intro6" && map != "sp_a1_intro7" && map != "sp_a1_wakeup") {
        SendToConsole("upgrade_portalgun");
        ppmod.wait(function ():(weaponstrip,map,ent) {
          SendToConsole("upgrade_portalgun");
        }, 0.1);
      }

    });
    
  }

}

local enableDropPortalgun = function ():(weaponstrip,balanceCheck) {

  SendToConsole("alias +mouse_menu \"script ::QdropWeapon()\"");

  ppmod.player.enable();

  ::QdropWeapon <- function ():(weaponstrip,balanceCheck) {

    if (ppmod.get("hold_portalgun_prop") || ppmod.get("hold_portalgun_wait")) return;

    local eyepos = GetPlayer().EyePosition(), eyevec = ppmod.player.eyes_vec() * 64;
    if (ppmod.ray(eyepos, eyepos + eyevec) != 1.0) return;

    ::QtutorialDone <- true;
    SendToConsole("gameinstructor_enable 0");

    ppmod.fire(weaponstrip, "Strip");
    ppmod.fire("viewmodel", "DisableDraw", "", 0.3);

    ppmod.wait(function ():(weaponstrip,balanceCheck,eyepos,eyevec) {

      ::Qweights["models/player/chell/player.mdl"] <- 80;

      ppmod.create("prop_physics_create props/water_bottle/water_bottle.mdl", function (ent):(weaponstrip,balanceCheck,eyepos,eyevec) {

        local eyepos = GetPlayer().EyePosition(), eyevec = ppmod.player.eyes_vec() * 64;
        local pos = eyepos + eyevec;
        
        if (ppmod.ray(eyepos, eyepos + eyevec) != 1.0) pos = GetPlayer().GetOrigin() + Vector(0, 0, 104);

        ent.SetOrigin(pos);
        ent.SetAngles(-90, 0, 0);
        ppmod.keyval(ent, "Targetname", "hold_portalgun_prop");
        ppmod.keyval(ent, "CollisionGroup", 1);
        ppmod.fire(ent, "DisableDraw");
  
        local equip = ppmod.trigger(pos, Vector(4, 4, 4));
        ppmod.fire(equip, "SetParent", "hold_portalgun_prop");
        ppmod.addscript(equip, "OnStartTouch", function ():(weaponstrip,balanceCheck,eyepos,eyevec,ent,eyepos,eyevec,pos,equip) {
          ppmod.fire("hold_portalgun_prop", "KillHierarchy");
          ppmod.wait(balanceCheck, FrameTime());
          ::Qweights["models/player/chell/player.mdl"] <- 85;
        }, 0, -1, true);
  
        ppmod.create("weapons/w_portalgun.mdl", function (gun):(weaponstrip,balanceCheck,eyepos,eyevec,ent,eyepos,eyevec,pos,equip) {
  
          gun.SetOrigin(ent.GetOrigin() - Vector(16));
          gun.SetAngles(0, 0, 0);
          ppmod.fire(gun, "SetParent", "hold_portalgun_prop");
          ppmod.keyval(gun, "CollisionGroup", 1);
  
        });
  
      });

    }, 0.3, "hold_portalgun_wait");

  }

}

local adjustMaps = function (map):(weaponstrip,balanceCheck,enableDropPortalgun) {

  if (map == "sp_a1_intro3") {

    ppmod.addscript("pickup_portalgun_rl", "OnTrigger", function ():(weaponstrip,balanceCheck,enableDropPortalgun,map) {

      enableDropPortalgun();
      
      ::QtutorialDone <- false;
      ppmod.wait(function ():(weaponstrip,balanceCheck,enableDropPortalgun,map) {
        SendToConsole("gameinstructor_enable 1");
        SendToConsole("gameinstructor_reload_lessons");
      }, FrameTime());

      local hint = Entities.CreateByClassname("env_instructor_hint");
      ppmod.keyval(hint, "hint_target", "");
      ppmod.keyval(hint, "hint_static", true);
      ppmod.keyval(hint, "hint_caption", "Drop the portal gun");
      ppmod.keyval(hint, "hint_binding", "mouse_menu");
      ppmod.keyval(hint, "hint_color", "255 255 255");
      ppmod.keyval(hint, "hint_icon_onscreen", "use_binding");
      ppmod.keyval(hint, "hint_icon_offscreen", "use_binding");
      ppmod.fire(hint, "ShowHint", "", 1.0);

    });

    ppmod.addoutput("pickup_portalgun_rl", "OnTrigger", "!self", "Kill");
  
  } else if (map == "sp_a2_intro") {

    ppmod.addscript("pickup_portalgun_relay", "OnTrigger", enableDropPortalgun);

  }

}

local main = function ():(weaponstrip,balanceCheck,enableDropPortalgun,adjustMaps) {

  local map = GetMapName().tolower();
  
  if (map != "sp_a1_intro1" && map != "sp_a1_intro2" && map != "sp_a1_intro3" && map != "sp_a2_intro") {
    enableDropPortalgun();
  }
  
  adjustMaps(map);

  if (GetPlayer().GetName().len() > 0) {
    ::Qbalance = GetPlayer().GetName().tointeger();
    balanceCheck();
  }
    
  local text = ppmod.text("", -1, 0.9);

  local text2 = ppmod.text("Handheld Portal Device disabled", -1, 0.95);
  text2.SetColor("255 100 100");
  text2.SetChannel(2);

  ::QmainLoop <- ppmod.interval(function ():(weaponstrip,balanceCheck,enableDropPortalgun,adjustMaps,map,text,text2) {

    if (::Qbalance == 0) {
      text.SetColor("255 255 255");
      text.SetText("Wormhole balance is stable");
    } else if (::Qbalance < 0) {
      text.SetColor("35 173 239");
      text.SetText("Balance is offset by "+(-::Qbalance)+"kg");
    } else {
      text.SetColor("252 107 6");
      text.SetText("Balance is offset by "+(::Qbalance)+"kg");
    }

    if (::QtutorialDone) text.Display();

    if (::Qbalance < -10 || ::Qbalance > 10 || ::QportalCount > 0) {
      if (::QtutorialDone) text2.Display();
    }

    local portal = null;
    while (portal = ppmod.get("prop_portal", portal)) {

      local found = false;
      for (local i = 0; i < ::Qportals.len(); i ++) {
        if (::Qportals[i] == portal) {
          found = true;
          break;
        }
      }

      if (!found) {

        ::Qportals.push(portal);

        ppmod.interval(function ():(weaponstrip,balanceCheck,enableDropPortalgun,adjustMaps,map,text,text2,portal,found) {

          if (!portal || !portal.IsValid()) return;
          
          ppmod.wait(function ():(weaponstrip,balanceCheck,enableDropPortalgun,adjustMaps,map,text,text2,portal,found) {
            
            ::QportalEnts[portal] <- [];

            local ent = null;
            while (ent = Entities.FindInSphere(ent, portal.GetOrigin(), 54)) {
              ::QportalEnts[portal].push(ent);
            }

          }, FrameTime());

        });
        
        if (portal && portal.IsValid()) {

          ppmod.addscript(portal, "OnEntityTeleportToMe", function ():(weaponstrip,balanceCheck,enableDropPortalgun,adjustMaps,map,text,text2,portal,found) {

            if (!portal || !portal.IsValid()) return;

            local diff = 20, ent = null;
            while (ent = Entities.FindInSphere(ent, portal.GetOrigin(), 54)) {
              
              if (!(ent.GetModelName() in ::Qweights)) continue;

              local found = false;
              for (local i = 0; i < ::QportalEnts[portal].len(); i ++) {
                if (ent == ::QportalEnts[portal][i]) {
                  found = true;
                  break;
                }
              }

              if (!found) {
                if (ent.GetName() == "hold_portalgun_prop") {
                  diff = 5;
                  break;
                }
                diff = ::Qweights[ent.GetModelName()];
                break;
              }

            }

            if (portal.GetModelName() == "models/portals/portal1.mdl") ::Qbalance -= diff;
            else ::Qbalance += diff;

            ppmod.keyval(GetPlayer(), "Targetname", ::Qbalance);
            balanceCheck();

          });

          local detector = ppmod.trigger(portal.GetCenter() - portal.GetForwardVector() * 34.032, Vector(2, 32, 54), "multiple", portal.GetAngles());
          ppmod.keyval(detector, "CollisionGroup", 10);

          ppmod.addscript(detector, "OnStartTouch", function ():(weaponstrip,balanceCheck,enableDropPortalgun,adjustMaps,map,text,text2,portal,found,detector) {
            ::QportalCount ++;
            balanceCheck();
          });
          ppmod.addscript(detector, "OnEndTouch", function ():(weaponstrip,balanceCheck,enableDropPortalgun,adjustMaps,map,text,text2,portal,found,detector) {
            ::QportalCount --;
            balanceCheck();
          });
          ppmod.fire(detector, "SetParent", "!activator", 0, portal);

        }

      }

    }

  });

};

local auto = Entities.CreateByClassname("logic_auto");
ppmod.addscript(auto, "OnNewGame", main);
ppmod.addscript(auto, "OnMapTransition", main);
