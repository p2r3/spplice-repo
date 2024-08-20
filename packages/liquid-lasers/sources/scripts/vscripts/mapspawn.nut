if (!("Entities" in this)) return;
IncludeScript("ppmod3");

cubeArr <- [];

local main = function () {

  SendToConsole("bounce_paint_color 255 0 0 255");
  SendToConsole("con_filter_enable 1");
  SendToConsole("con_filter_text_out \"StartParticleEffect:\"");

  local ent = null;
  while (ent = ppmod.get("env_portal_laser", ent)) {

    local emitterName = UniqueString("existing_emitter");

    ppmod.keyval(ent, "Targetname", emitterName);
    ppmod.fire(ent, "TurnOff");

    ppmod.create("info_paint_sprayer", function (sprayer,ent=ent,emitterName=emitterName) {

      sprayer.SetOrigin(ent.GetOrigin() + ent.GetForwardVector() * 16);
      sprayer.SetForwardVector(ent.GetForwardVector());

      ppmod.keyval(sprayer, "blobs_per_second", 20);
      ppmod.keyval(sprayer, "min_speed", 1000);
      ppmod.keyval(sprayer, "max_speed", 1000);
      ppmod.keyval(sprayer, "blob_spread_radius", 0);
      ppmod.keyval(sprayer, "blob_streak_percentage", 0);

      ppmod.fire(sprayer, "ChangePaintType", 2);
      ppmod.fire(sprayer, "Start");
      ppmod.fire(sprayer, "SetParent", emitterName);

    });

  }

  while (ent = ppmod.get("prop_laser_catcher", ent)) {

    local emitterName = UniqueString("emitter");
    local cleanserName = UniqueString("cleanser");

    ppmod.create("env_portal_laser", function (emitter,ent=ent,emitterName=emitterName,cleanserName=cleanserName) {

      emitter.SetOrigin(ent.GetOrigin() - ent.GetForwardVector() * 16);
      emitter.SetForwardVector(ent.GetForwardVector());

      ppmod.keyval(emitter, "Targetname", emitterName);
      ppmod.keyval(emitter, "CollisionGroup", 1);
      ppmod.fire(emitter, "DisableDraw");
      ppmod.fire(emitter, "TurnOff");

      ppmod.fire(emitter, "SetParent", ent.GetName());

    });

    ppmod.create("ent_create_portal_reflector_cube", function (cube,ent=ent,emitterName=emitterName,cleanserName=cleanserName) {

      cube.SetOrigin(ent.GetOrigin() + ent.GetForwardVector() * 42);
      cube.SetForwardVector(Vector() - ent.GetForwardVector());

      local cleanser = ppmod.trigger(cube.GetOrigin(), Vector(1, 1, 1), "paint_cleanser");
      ppmod.keyval(cleanser, "SpawnFlags", 8);
      ppmod.keyval(cleanser, "Targetname", cleanserName);

      ppmod.interval(function (ent=ent,emitterName=emitterName,cleanserName=cleanserName,cube=cube,cleanser=cleanser) {
        cleanser.SetAbsOrigin(cube.GetOrigin());
      });

      ppmod.fire(cube, "DisableMotion");
      ppmod.fire(cube, "DisableDraw");
      ppmod.fire(cube, "SetParent", ent.GetName());
      ppmod.keyval(cube, "Targetname", "gel_receptor_cube");
      ppmod.keyval(cube, "CollisionGroup", 2);

      ppmod.addscript(cube, "OnPainted", function (ent=ent,emitterName=emitterName,cleanserName=cleanserName,cube=cube,cleanser=cleanser) {

        ppmod.fire(emitterName, "TurnOn");
        ppmod.fire(cleanser, "Disable");
        ppmod.fire(cleanser, "Enable", "", FrameTime());

        local prevEmitterStop = ppmod.get(emitterName + "stop");
        if (prevEmitterStop) prevEmitterStop.Destroy();

        ppmod.wait("ppmod.fire(\""+(emitterName)+"\", \"TurnOff\")", FrameTime() * 4, emitterName + "stop");

      });

    });

  }

  while (ent = ppmod.get("prop_laser_relay", ent)) {

    local emitterName = UniqueString("emitter");
    local cleanserName = UniqueString("cleanser");

    ppmod.create("env_portal_laser", function (emitter,ent=ent,emitterName=emitterName,cleanserName=cleanserName) {

      emitter.SetOrigin(ent.GetOrigin() - ent.GetUpVector() * 16);
      emitter.SetForwardVector(ent.GetUpVector());

      ppmod.keyval(emitter, "Targetname", emitterName);
      ppmod.keyval(emitter, "CollisionGroup", 1);
      ppmod.fire(emitter, "DisableDraw");
      ppmod.fire(emitter, "TurnOff");

      ppmod.fire(emitter, "SetParent", ent.GetName());

    });

    ppmod.create("ent_create_portal_reflector_cube", function (cube,ent=ent,emitterName=emitterName,cleanserName=cleanserName) {

      cube.SetOrigin(ent.GetOrigin() + ent.GetUpVector() * 42);
      cube.SetForwardVector(Vector() - ent.GetUpVector());

      local cleanser = ppmod.trigger(cube.GetOrigin(), Vector(1, 1, 1), "paint_cleanser");
      ppmod.keyval(cleanser, "SpawnFlags", 8);
      ppmod.keyval(cleanser, "Targetname", cleanserName);

      ppmod.interval(function (ent=ent,emitterName=emitterName,cleanserName=cleanserName,cube=cube,cleanser=cleanser) {
        cleanser.SetAbsOrigin(cube.GetOrigin());
      });

      ppmod.fire(cube, "DisableMotion");
      ppmod.fire(cube, "DisableDraw");
      ppmod.fire(cube, "SetParent", ent.GetName());
      ppmod.keyval(cube, "Targetname", "gel_receptor_cube");
      ppmod.keyval(cube, "CollisionGroup", 2);

      ppmod.addscript(cube, "OnPainted", function (ent=ent,emitterName=emitterName,cleanserName=cleanserName,cube=cube,cleanser=cleanser) {

        ppmod.fire(emitterName, "TurnOn");
        ppmod.fire(cleanser, "Disable");
        ppmod.fire(cleanser, "Enable", "", FrameTime());

        local prevEmitterStop = ppmod.get(emitterName + "stop");
        if (prevEmitterStop) prevEmitterStop.Destroy();

        ppmod.wait("ppmod.fire(\""+(emitterName)+"\", \"TurnOff\")", FrameTime() * 4, emitterName + "stop");

      });

    });

  }

  ppmod.interval(function (ent=ent) {

    local ent = null;
    while (ent = ppmod.get("prop_weighted_cube", ent)) {

      if (ent.GetModelName() != "models/props/reflection_cube.mdl") continue;
      if (ent.GetName() == "gel_receptor_cube") continue;

      local i, found = false;
      for (i = 0; i < cubeArr.len(); i ++) {
        if (cubeArr[i] == ent) {
          found = true;
          break;
        }
      }

      if (found) continue;
      cubeArr.push(ent);

      ppmod.fire(ent, "Color", "0 0 0");
      
      local sprayerName = UniqueString("sprayer");

      ppmod.create("info_paint_sprayer", function (sprayer,ent=ent,ent=ent,i=i,found=found,sprayerName=sprayerName) {

        sprayer.SetOrigin(ent.GetOrigin() + ent.GetForwardVector() * 32);
        sprayer.SetForwardVector(ent.GetForwardVector());

        ppmod.keyval(sprayer, "Targetname", sprayerName);
        ppmod.keyval(sprayer, "blobs_per_second", 20);
        ppmod.keyval(sprayer, "min_speed", 1000);
        ppmod.keyval(sprayer, "max_speed", 1000);
        ppmod.keyval(sprayer, "blob_spread_radius", 0);
        ppmod.keyval(sprayer, "blob_streak_percentage", 0);

        ppmod.fire(sprayer, "ChangePaintType", 2);
        ppmod.fire(sprayer, "Stop");

        local cleanser = ppmod.trigger(ent.GetOrigin(), Vector(1, 1, 1), "paint_cleanser");
        ppmod.keyval(cleanser, "SpawnFlags", 8);

        ppmod.interval(function (ent=ent,ent=ent,i=i,found=found,sprayerName=sprayerName,sprayer=sprayer,cleanser=cleanser) {
          cleanser.SetAbsOrigin(ent.GetOrigin());
        });

        local oldName = ent.GetName();
        local newName = UniqueString("tmpname");
        
        ppmod.keyval(ent, "Targetname", newName);
        ppmod.fire(sprayer, "SetParent", newName);
        ppmod.fire(ent, "AddOutput", "Targetname " + oldName, FrameTime());

      });

      ppmod.addscript(ent, "OnPainted", function (ent=ent,ent=ent,i=i,found=found,sprayerName=sprayerName) {

        ppmod.fire(sprayerName, "Start");

        local prevSprayerStop = ppmod.get(sprayerName + "stop");
        if (prevSprayerStop) prevSprayerStop.Destroy();

        ppmod.wait("ppmod.fire(\""+(sprayerName)+"\", \"Stop\")", FrameTime() * 4, sprayerName + "stop");

      });

    }

  });

}

local auto = Entities.CreateByClassname("logic_auto");
ppmod.addscript(auto, "OnNewGame", main)
ppmod.addscript(auto, "OnMapTransition", main);
