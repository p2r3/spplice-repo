if (!("Entities" in this)) return;
if ("Qbalance" in this) return;
IncludeScript("ppmod3");

::Qportals <- [];
::Qbalance <- 0;
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

//copied (and edited) from magnets
// If the point_pushes aren't set up already, we do that here.
if(!Entities.FindByName(null,"magnet-player")){
	// Two point_push entities are created.
	// One acts as a magnet for the player and the other for props.
	plymag <- Entities.CreateByClassname("point_push");
	prpmag <- Entities.CreateByClassname("point_push");
	// Setting keyvalues. Magnitude gets set in the main script.
	plymag.__KeyValueFromString("targetname","magnet-player");
	prpmag.__KeyValueFromString("targetname","magnet-prop");
	plymag.__KeyValueFromFloat("radius",256);
	prpmag.__KeyValueFromFloat("radius",256);
	// Flag 8 is for player only, and 16 is for physics props only.
	plymag.__KeyValueFromInt("spawnflags",8);
	prpmag.__KeyValueFromInt("spawnflags",16);
	EntFire("magnet-player", "Enable");
	EntFire("magnet-prop", "Enable");
}
//end copy

local weaponstrip = Entities.CreateByClassname("player_weaponstrip");

local balanceCheck = function ():(weaponstrip) {

  local map = GetMapName().tolower();
  if (map == "sp_a1_intro1" || map == "sp_a1_intro2") return;

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
    // balanceCheck();
  }
    
  local text = ppmod.text("", -1, 0.9);

  //local text2 = ppmod.text("Handheld Portal Device disabled", -1, 0.95);
  //text2.SetColor("255 100 100");
  
  //edit
  local text2 = ppmod.text("Mass Offset Warning: Dangerously High", -1, 0.95);
  text2.SetColor("255 152 100");
  //end edit
  
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

    //if (::Qbalance < -10 || ::Qbalance > 10 || ::QportalCount > 0) {
	
	//edit
	if (::Qbalance < -300 || ::Qbalance > 300) {
	//end edit
	
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
            // balanceCheck();

          });

        }

      }

    }

  });

};

//copied from magnets
// Looping function for repositioning magnets
::magnets_func <- function(){
	plymag <- Entities.FindByName(null,"magnet-player");
	prpmag <- Entities.FindByName(null,"magnet-prop");
	player <- GetPlayer();

	// Gets the distance of the closest physics prop from the portal
	function propDist(ptl){
		// The "magnetic" props. This is to make sure we don't check static entities.
		names <- ["prop_weighted_cube", "prop_monster_box", "prop_paint_bomb", "npc_portal_turret_floor", "prop_physics"];
		lowest <- 9999999;
		for(i <- 0; i < names.len(); i++){
			curr <- Entities.FindByClassnameNearest(names[i], ptl, 128);
			if(curr != null){
				diff <- (ptl - curr.GetOrigin()).LengthSqr();
				if(diff < lowest) lowest = diff;
			}
		}
		return lowest;
	}

	// Setting distance comparison values to (hopefully) impossibly high values
	bluedist <- 9999999;
	reddist <- 9999999;
	bluepropdist <- 9999999;
	redpropdist <- 9999999;
	// Calculates player and prop distance from the portals
	portal <- null;
	while(portal = Entities.FindByClassname(portal, "prop_portal")){
		// Length square is supposedly faster and works for this anyway
		playerdist <- (player.GetOrigin() - portal.GetOrigin()).LengthSqr();
		propdist <- propDist(portal.GetOrigin());
		// Differentiates blue/orange portals by the model name
		model <- portal.GetModelName();
		if(model == "models/portals/portal1.mdl"){
			if(playerdist < bluedist) bluedist <- playerdist;
			if(propdist < bluepropdist) bluepropdist <- propdist;
		} else {
			if(playerdist < reddist) reddist <- playerdist;
			if(propdist < redpropdist) redpropdist <- propdist;
		}
	}

	portal <- null;
	while(portal = Entities.FindByClassname(portal, "prop_portal")){
		// We compare distance again to fix maps with more than 2 portals.
		playerdist <- (player.GetOrigin() - portal.GetOrigin()).LengthSqr();
		propdist <- propDist(portal.GetOrigin());
		// All of this basically teleports the magnet to the closest portal.
		// Same thing for props, but only the props closest to the portals are checked.
		// After that, the magnitude is set according to the magnet's polarity.
		model <- portal.GetModelName();
		if(model == "models/portals/portal1.mdl"){
			if(bluedist < reddist && bluedist == playerdist){
				plymag.SetOrigin(portal.GetOrigin());
				plymag.__KeyValueFromFloat("Magnitude",::Qbalance*-0.5);
			}
			if(bluepropdist < redpropdist && bluepropdist == propdist){
				prpmag.SetOrigin(portal.GetOrigin());
				prpmag.__KeyValueFromFloat("Magnitude",::Qbalance*-0.5);
			}
		}
		if(model == "models/portals/portal2.mdl"){
			if(bluedist > reddist && reddist == playerdist){
				plymag.SetOrigin(portal.GetOrigin());
				plymag.__KeyValueFromFloat("Magnitude",::Qbalance*0.5);
			}
			if(bluepropdist > redpropdist && redpropdist == propdist){
				prpmag.SetOrigin(portal.GetOrigin());
				prpmag.__KeyValueFromFloat("Magnitude",::Qbalance*0.5);
			}
		}
		// In the case that no props are near a portal, both values will be 9999999.
		if(bluepropdist == redpropdist) prpmag.__KeyValueFromFloat("Magnitude",0);
	}
}

// Edge case for Container Ride, as the first portals don't open right away.
/* People have reported issues with this, so I'm commenting it out.
if(GetMapName() == "sp_a1_intro1"){
	EntFire("enter_chamber_trigger", "AddOutput", "OnTrigger !self:CallScriptFunction:magnets_func:34.3:-1");
	return 0;
}*/
//copy note - i copied the above stuff just to be safe. i dont understand this code well ;-;

// Create timer entity for running function every 0.1 seconds
if(!Entities.FindByName(null,"magnet-timer")){
	timer <- Entities.CreateByClassname("logic_timer");
	EntFireByHandle(timer,"RefireTime","0.1",0,timer,timer);
	EntFireByHandle(timer,"AddOutput","OnTimer !self:CallScriptFunction:magnets_func:0:-1",0,timer,timer);
	EntFireByHandle(timer,"Enable","",0,timer,timer);
	timer.__KeyValueFromString("targetname","magnet-timer");
}
//end copy

local auto = Entities.CreateByClassname("logic_auto");
ppmod.addscript(auto, "OnNewGame", main);
ppmod.addscript(auto, "OnMapTransition", main);
