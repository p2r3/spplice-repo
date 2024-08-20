if(!("Entities" in this)) return;

// If the point_pushes aren't set up already, we do that here.
if(!Entities.FindByName(null,"magnet-player")){
	// Two point_push entities are created.
	// One acts as a magnet for the player and the other for props.
	plymag <- Entities.CreateByClassname("point_push");
	prpmag <- Entities.CreateByClassname("point_push");
	// Setting keyvalues. Magnitude gets set in the main script.
	plymag.__KeyValueFromString("targetname","magnet-player");
	prpmag.__KeyValueFromString("targetname","magnet-prop");
	plymag.__KeyValueFromFloat("radius",128);
	prpmag.__KeyValueFromFloat("radius",128);
	// Flag 8 is for player only, and 16 is for physics props only.
	plymag.__KeyValueFromInt("spawnflags",8);
	prpmag.__KeyValueFromInt("spawnflags",16);
	EntFire("magnet-player", "Enable");
	EntFire("magnet-prop", "Enable");
}

// Looping function for repositioning magnets
::magnets_func <- function(){
	plymag <- Entities.FindByName(null,"magnet-player");
	prpmag <- Entities.FindByName(null,"magnet-prop");
	player <- GetPlayer();

	// Gets the distance of the closest physics prop from the portal
	function propDist(ptl){
		// The "magnetic" props. This is to make sure we don't check static entities.
		names <- ["prop_weighted_cube", "prop_monster_box", "prop_paint_bomb", "npc_portal_turret_floor"];
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
				plymag.__KeyValueFromFloat("Magnitude",100);
			}
			if(bluepropdist < redpropdist && bluepropdist == propdist){
				prpmag.SetOrigin(portal.GetOrigin());
				prpmag.__KeyValueFromFloat("Magnitude",100);
			}
		}
		if(model == "models/portals/portal2.mdl"){
			if(bluedist > reddist && reddist == playerdist){
				plymag.SetOrigin(portal.GetOrigin());
				plymag.__KeyValueFromFloat("Magnitude",-100);
			}
			if(bluepropdist > redpropdist && redpropdist == propdist){
				prpmag.SetOrigin(portal.GetOrigin());
				prpmag.__KeyValueFromFloat("Magnitude",-100);
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

// Create timer entity for running function every 0.1 seconds
if(!Entities.FindByName(null,"magnet-timer")){
	timer <- Entities.CreateByClassname("logic_timer");
	EntFireByHandle(timer,"RefireTime","0.1",0,timer,timer);
	EntFireByHandle(timer,"AddOutput","OnTimer !self:CallScriptFunction:magnets_func:0:-1",0,timer,timer);
	EntFireByHandle(timer,"Enable","",0,timer,timer);
	timer.__KeyValueFromString("targetname","magnet-timer");
}
