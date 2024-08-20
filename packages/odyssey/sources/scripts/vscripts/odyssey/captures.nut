smo.cap <- {
  ent = null,
  offset = Vector(0, 0, 5),
  scale = 3,
  captured = null,
  leavefunc = function(e) {},
  to = null,
  currcore = 1
};

smo.cap.setup <- function() {

  smo.cap.create();

  // Prevents SLA bugs from captures
  SendToConsole("crosshair 1");
  ppmod.addscript(smo.auto, "OnLoadGame", function() {
    if (!smo.cap.captured) SendToConsole("crosshair 1");
    if (ppmod.get("smo_cam_pos") && ppmod.get("smo_cam_pos").IsValid()) {
      smo.cap.cam(smo.cap.captured);
      ppmod.wait(function() {
        SendToConsole("thirdperson");
      }, FrameTime() * 3);
    }
  });

  ppmod.give("filter_damage_type", function(ent) {
    ppmod.keyval(ent, "Targetname", "smo_godfilter");
    ppmod.keyval(ent, "filter_damage_type", 32);
    smo.cap.dmgfilter <- ent;
  });

}

smo.cap.create <- function(func = function(){}) {
  ppmod.create("nintendo/marios_cap.mdl", function(ent, func = func) {
    ent.SetOrigin(GetPlayer().GetOrigin());
    ent.SetAngles(0, 90, 0);
    ppmod.keyval(ent, "Targetname", "smo_cap");
    ppmod.keyval(ent, "CollisionGroup", 1);
    ppmod.keyval(ent, "ModelScale", smo.cap.scale);
    ppmod.fire(ent, "DisableDraw");
    smo.cap.ent = ent;
    func();
  });
}

smo.cap.spectate <- function(enable) {
  if (enable) {
    ppmod.keyval("weapon_portalgun", "CanFirePortal1", 0);
    ppmod.keyval("weapon_portalgun", "CanFirePortal2", 0);
    ppmod.fire("viewmodel", "DisableDraw");
    ppmod.fire(GetPlayer(), "SetDamageFilter", "smo_godfilter");
    SendToConsole("crosshair 0");
  } else {
    if (GetMapName().slice(4, 5) == "1") {
      ppmod.keyval("weapon_portalgun", "CanFirePortal2", 0);
    } else ppmod.keyval("weapon_portalgun", "CanFirePortal2", 1);
    ppmod.keyval("weapon_portalgun", "CanFirePortal1", 1);
    ppmod.fire("viewmodel", "EnableDraw");
    ppmod.fire(GetPlayer(), "SetDamageFilter", "");
    SendToConsole("crosshair 1");
  }
}

smo.cap.use <- function() {
  if (smo.cap.to) return;
  local pos = GetPlayer().EyePosition() + Vector(0, 0, 3) + smo.cap.offset;
  local vec = ppmod.player.eyes_vec() * 256;
  local frac = TraceLine(pos, pos + vec, GetPlayer());
  if (frac <= 0.25) return;
  smo.cap.to = pos + vec * frac + smo.cap.offset;
  if (smo.debug) DebugDrawLine(pos, to, 255, 0, 0, false, 5);
  smo.move.ljump = false;

  smo.cap.ent.SetOrigin(pos);
  ppmod.fire(smo.cap.ent, "EnableDraw");
  ppmod.interval("smo.cap.fly()", 0, "smo_capfly");
}

smo.cap.unuse <- function() {

}

smo.cap.fly <- function() {
  local pos = smo.cap.ent.GetOrigin();
  local ang = smo.cap.ent.GetAngles();
  local vec = smo.cap.to - pos;
  local speed = 20;
  vec.Norm();
  smo.cap.ent.SetAngles(0, (ang.y - 30) % 360, 0);
  if (smo.cap.find(pos, speed)) {
    local loop = ppmod.get("smo_capfly");
    if (loop && loop.IsValid()) loop.Destroy();
    return;
  }
  if ((smo.cap.to - pos).Length() < speed * 2) {
    smo.cap.flystall();
    local loop = ppmod.get("smo_capfly");
    if (loop && loop.IsValid()) loop.Destroy();
    return;
  }
  smo.cap.ent.SetAbsOrigin(pos + vec * speed);
}
smo.cap.flystall <- function() {
  //ppmod.keyval(smo.cap.ent, "ModelScale", smo.cap.scale + 0.5);
  local stallcd = Entities.CreateByClassname("logic_relay");
  ppmod.fire(stallcd, "Kill", "", 0.5);

  ppmod.interval(function(cd = stallcd) {
    if (!smo.move.using && (!cd || !cd.IsValid())) {
      local loop = ppmod.get("smo_capfly_stall");
      if (loop && loop.IsValid()) loop.Destroy();
      ppmod.fire("smo_capfly_stall_timeout", "Kill");
      smo.cap.back();
    } else {
      local pos = smo.cap.ent.GetOrigin();
      local ang = smo.cap.ent.GetAngles();
      smo.cap.ent.SetAngles(0, (ang.y - 30) % 360, 0);
      if (smo.cap.find(pos, 0)) {
        local loop = ppmod.get("smo_capfly_stall");
        if (loop && loop.IsValid()) loop.Destroy();
        ppmod.fire("smo_capfly_stall_timeout", "Kill");
      }
    }
  }, 0, "smo_capfly_stall");

  local timeout = ppmod.wait(function() {
    local loop = ppmod.get("smo_capfly_stall");
    if (loop && loop.IsValid()) {
      local loop = ppmod.get("smo_capfly_stall");
      if (loop && loop.IsValid()) loop.Destroy();
      smo.cap.back();
    }
  }, 1.5);
  ppmod.keyval(timeout, "Targetname", "smo_capfly_stall_timeout");

}
smo.cap.flyrev <- function() {
  local pos = smo.cap.ent.GetOrigin();
  local ang = smo.cap.ent.GetAngles();
  local vec = smo.cap.to - pos;
  local speed = 20;
  vec.Norm();
  smo.cap.ent.SetAbsOrigin(pos + vec * speed);
  smo.cap.ent.SetAngles(0, (ang.y - 30) % 360, 0);
  /* if (smo.cap.find(pos, speed)) {
    if (ppmod.get("smo_capfly_rev")) {
      ppmod.get("smo_capfly_rev").Destroy();
    }
    return;
  } */
  if ((smo.cap.to - (pos + vec * speed)).Length() < speed) {
    ppmod.fire(smo.cap.ent, "DisableDraw");
    if (ppmod.get("smo_capfly_rev")) {
      ppmod.get("smo_capfly_rev").Destroy();
    }
    smo.cap.to = null;
  }
}

smo.cap.back <- function() {
  ppmod.keyval(smo.cap.ent, "ModelScale", smo.cap.scale);
  ppmod.fire(smo.cap.ent, "EnableDraw");
  smo.cap.to = GetPlayer().GetOrigin() + Vector(0, 0, 72) + smo.cap.offset;
  /* EntFire("smo_capjump_trigger", "Kill"); */
  ppmod.interval("smo.cap.flyrev()", 0, "smo_capfly_rev");
}

smo.cap.find <- function(pos, speed) {
  pos -= smo.cap.offset;
  local offset = Vector();
  local radius = 32 + speed / 2;
  local ent = null;
  local func = null;

  if (ent = ppmod.get(pos, "prop_weighted_cube", radius)) func = smo.cap.physprop;
  else if (ent = ppmod.get(pos, "prop_physics", radius)) func = smo.cap.physprop;
  else if (ent = ppmod.get(pos, "prop_physics_override", radius)) func = smo.cap.physprop;
  else if (ent = ppmod.get(pos, "prop_exploding_futbol", radius)) func = smo.cap.physprop;
  else if (ent = ppmod.get(pos, "prop_monster_box", radius)) func = smo.cap.monster;
  else if (ent = ppmod.get(pos, "npc_security_camera", radius)) func = smo.cap.wallcam;
  else if (ent = ppmod.get(pos, "npc_personality_core", radius)) func = smo.cap.core;
  else if (ent = ppmod.get(pos, "npc_portal_turret_floor", radius)) func = smo.cap.turret;
  else if (ent = ppmod.get(pos, "func_button", radius)) func = smo.cap.button;
  else if (ent = ppmod.get(pos - Vector(0, 0, 22), "prop_button", radius)) func = smo.cap.button, offset = Vector(0, 0, 22);
  else if (ent = ppmod.get(pos - Vector(0, 0, 22), "prop_under_button", radius)) func = smo.cap.button, offset = Vector(0, 0, 22);
  else if (ent = ppmod.get(pos + Vector(0, 0, 15), "prop_floor_button", radius)) func = smo.cap.floorbutton, offset = Vector(0, 0, 15);
  else if (ent = ppmod.get(pos + Vector(0, 0, 15), "prop_under_floor_button", radius)) func = smo.cap.underfloorbutton, offset = Vector(0, 0, 15);
  else if (ent = ppmod.get(pos, "trigger_catapult", radius)) func = smo.cap.catapult;
  else if (speed == 0 && (ent = ppmod.get(pos - Vector(0, 0, 28), "player", 40))) func = smo.move.capjump, offset = Vector(0, 0, 28);

  if (func /*&& TraceLine(pos, ent.GetOrigin() + offset, GetPlayer()) == 1*/) {
    if (func == smo.cap.catapult) {
      local plate = null;
      while (plate = Entities.FindInSphere(plate, ent.GetOrigin(), 128)) {
        if (plate.GetModelName() == "models/props/faith_plate.mdl") {
          func(ent);
          break;
        }
      }
      if (!plate) return false;
    } else func(ent);
    ppmod.keyval(smo.cap.ent, "ModelScale", smo.cap.scale);
    return ent;
  } else return false;

}

smo.cap.cam <- function(ent) {
  SendToConsole("thirdperson");
  /* SendToConsole("cam_ideallag 20");
  ppmod.wait("SendToConsole(\"cam_ideallag 0\")", 0.5); */
  EntFire("!player", "DisableDraw");
  GetPlayer().SetVelocity(Vector());
  ppmod.fire(smo.move.speedmod, "ModifySpeed", 0);
  ppmod.keyval("!player", "MoveType", 8);

  ppmod.fire(ent, "AddOutput", "Targetname " + ent.GetName(), FrameTime());
  local tmpname = UniqueString("smo_cam_ent");
  ppmod.keyval(ent, "Targetname", tmpname);

  local mirror = Entities.CreateByClassname("logic_measure_movement");
  ppmod.keyval(mirror, "MeasureType", 0);
  ppmod.keyval(mirror, "Targetname", "smo_cam_pos");
  ppmod.keyval(mirror, "TargetReference", "smo_cam_pos");
  ppmod.fire(mirror, "SetMeasureReference", "smo_cam_pos");
  ppmod.fire(mirror, "SetMeasureTarget", tmpname);
  ppmod.keyval(mirror, "Target", "!player");
  ppmod.fire(mirror, "Enable");
  smo.cap.captured = ent;

  smo.cap.spectate(true);
  smo.move.canstuck = false;
}
smo.cap.cam_leave <- function() {
  SendToConsole("firstperson");
  EntFire("!player", "EnableDraw");
  ppmod.fire(smo.move.speedmod, "ModifySpeed", 1);
  ppmod.keyval("!player", "MoveType", 2);
  EntFire("smo_cam_pos", "Kill");
  ppmod.fire(smo.cap.ent, "DisableDraw");
  smo.cap.captured = null;
  smo.cap.back();

  smo.cap.spectate(false);
  ppmod.wait("smo.move.canstuck = true", FrameTime() * 2);
}

// ********************************
//         Capture behavior
// ********************************

smo.cap.physprop <- function(ent) {
  local pos = ent.GetOrigin();
  local ang = ent.GetAngles();
  local maxz = ent.GetBoundingMaxs().z;
  smo.cap.ent.SetOrigin(pos + smo.cap.offset + Vector(0, 0, maxz));
  ang.x %= 90;
  if (ang.x > 45) ang.x -= 90;
  if (ang.x < -45) ang.x += 90;
  ppmod.keyval(ent, "CollisionGroup", 23);
  smo.cap.cam(ent);
  smo.cap.ent.SetAngles(ang.x, ang.y, 0);
  ppmod.fire(smo.cap.ent, "SetParent", ent.GetName());
  smo.move.speed(175);

  local push = Entities.CreateByClassname("point_push");
  ppmod.keyval(push, "Targetname", "smo_cube_push");
  ppmod.keyval(push, "SpawnFlags", 22);
  ppmod.keyval(push, "Radius", 1);
  ppmod.fire(push, "Enable");

  ppmod.interval(function(push = push) {
    if (!smo.cap.captured) return;
    if (!smo.cap.captured.IsValid()) {
      smo.cap.create(function() {
        smo.move.duck();
      });
      return;
    }

    local ang = ppmod.player.eyes.GetAngles();
    local pos = smo.cap.captured.GetOrigin();
    local input = smo.move.gameui;
    local offset = 0;

    local enable = false;
    foreach(val in input) if (val) enable = true;
    if (input.moveleft) offset += 90;
    if (input.moveright) offset -= 90;
    if (input.back) {
      if (input.moveleft) offset += 45;
      if (input.moveright) offset -= 45;
      if (!offset && !input.forward) offset = 180;
    }
    if (input.forward) {
      if (input.moveleft) offset -= 45;
      if (input.moveright) offset += 45;
    }

    if (enable) ppmod.keyval(push, "Magnitude", 13);
    else ppmod.keyval(push, "Magnitude", 0);
    push.SetAngles(0, ang.y + offset, 0);
    push.SetOrigin(pos);

    ppmod.fire(smo.cap.captured, "Wake");
    ppmod.fire(smo.cap.captured, "EnableMotion");

    if (smo.cap.captured.GetModelName() == "models/props/reflection_cube.mdl") {
      local cang = smo.cap.captured.GetAngles();
      ppmod.keyval(smo.cap.captured, "Angles", cang.x+" "+ang.y+" "+cang.z);
    }
  }, 0, "smo_cube_update");

  smo.cap.leavefunc = function(ent) {
    EntFire("smo_cube_update", "Kill");
    EntFire("smo_cube_push", "Kill");
    ppmod.fire(smo.cap.ent, "ClearParent");

    if (!ent.IsValid()) {
      smo.move.safetp(GetPlayer().GetOrigin());
      return;
    }

    ppmod.keyval(ent, "CollisionGroup", 24);
    local pos = ent.GetOrigin();
    local maxz = ent.GetBoundingMaxs().z;
    smo.move.safetp(pos + Vector(0, 0, maxz + 5));

    if (ent.GetModelName() == "models/props/reflection_cube.mdl") {
      local ang = ppmod.player.eyes.GetAngles();
      local cang = ent.GetAngles();
      ent.SetAngles(cang.x, ang.y, cang.z);
    }
  }
}

smo.cap.button <- function(ent) {
  ppmod.fire(ent, "Press");
  smo.cap.back();
}
smo.cap.floorbutton <- function(ent) {
  ppmod.fire(ent, "SetAnimation", "down");
  ppmod.fire(ent, "SetAnimation", "up", FrameTime() * 2);
  ppmod.addoutput(ent, "OnPressed", "!self", "SetAnimation", "down");
  ppmod.addoutput(ent, "OnUnpressed", "!self", "SetAnimation", "up");
  smo.cap.back();
}
smo.cap.underfloorbutton <- function(ent) {
  ppmod.fire(ent, "SetAnimation", "press");
  ppmod.fire(ent, "SetAnimation", "release", FrameTime() * 2);
  ppmod.addoutput(ent, "OnPressed", "!self", "SetAnimation", "press");
  ppmod.addoutput(ent, "OnUnpressed", "!self", "SetAnimation", "release");
  smo.cap.back();
}

smo.cap.catapult <- function(ent) {
  if (!ent || !ent.IsValid()) return;
  smo.cap.back();
  ppmod.create("prop_physics_create gibs/glass_break_b1_gib25.mdl", function(prop, ent = ent) {
    ppmod.fire(prop, "Kill");
    prop.SetOrigin(ent.GetOrigin());
  });
}

smo.cap.wallcam <- function(ent) {
  local pos = ent.GetOrigin();
  pos.x = round(pos.x, 3);
  pos.y = round(pos.y, 3);
  pos.z = round(pos.z, 3);
  local ang = ent.GetAngles();

  if ( pos.z % 1 != 0 && (pos.x % 1 != 0 || pos.y % 1 != 0) ) {
    ppmod.fire(ent, "Ragdoll");
    smo.cap.physprop(ent);
    return;
  }

  local offset = Vector(cos(ang.y) * 20, sin(ang.y) * 20, -100);
  GetPlayer().SetOrigin(pos + offset);
  GetPlayer().SetAngles(ang.x, ang.y, 0);

  ppmod.fire(ent, "Enable");
  ppmod.fire(ent, "DisableDraw");
  ppmod.fire(smo.cap.ent, "DisableDraw");
  ppmod.fire(smo.move.speedmod, "ModifySpeed", 0);
  ppmod.keyval("!player", "MoveType", 8);
  smo.cap.captured = ent;
  smo.cap.spectate(true);
  smo.move.canstuck = false;

  smo.cap.leavefunc = function(ent) {
    ppmod.fire(ent, "EnableDraw");
    ppmod.fire(smo.move.speedmod, "ModifySpeed", 1);
    ppmod.keyval("!player", "MoveType", 2);
    local pos = ent.GetOrigin();
    local ang = ent.GetAngles();
    local offset = Vector(cos(ang.y) * 32, sin(ang.y) * 32, -136);
    smo.move.safetp(pos + offset);
    smo.cap.spectate(false);
    ppmod.wait("smo.move.canstuck = true", FrameTime() * 2);
  }
}

smo.cap.core <- function(ent) {
  if (!ent.GetMoveParent()) {
    ppmod.fire(ent, "ForcePickup");
    smo.cap.back();
    return;
  }

  if (GetMapName() == "sp_a4_finale4") {

    if (ent.GetName().slice(6).tointeger() >= smo.cap.currcore) {
      
      ppmod.fire(ent, "ClearParent");
      ppmod.fire(ent, "EnableMotion");
      ppmod.fire(ent, "Wake");
      smo.cap.currcore ++;

    }

    smo.cap.back();
    return;

  }

  local ang = ent.GetAngles();
  GetPlayer().SetAngles(ang.x, ang.y + 90, 0);

  ppmod.interval(function(ent = ent) {
    local pos = ent.GetOrigin();
    local offset = Vector(0, 0, -36);
    GetPlayer().SetAbsOrigin(pos + offset);
  }, 0, "smo_cap_core_pos");

  ppmod.fire(ent, "DisableDraw");
  ppmod.fire(smo.cap.ent, "DisableDraw");
  ppmod.keyval(ent, "CollisionGroup", 2);
  ppmod.fire(smo.move.speedmod, "ModifySpeed", 0);
  ppmod.keyval("!player", "MoveType", 8);
  smo.cap.captured = ent;
  smo.cap.spectate(true);
  smo.move.canstuck = false;

  smo.cap.leavefunc = function(ent) {
    ppmod.fire(ent, "EnableDraw");
    ppmod.keyval(ent, "CollisionGroup", 0);
    ppmod.fire(smo.move.speedmod, "ModifySpeed", 1);
    ppmod.keyval("!player", "MoveType", 2);
    local pos = ent.GetOrigin();
    local ang = ent.GetAngles();
    local offset = Vector(0, 0, 32);
    smo.move.safetp(pos + offset);
    smo.cap.spectate(false);
    ppmod.wait("smo.move.canstuck = true", FrameTime() * 2);
    ppmod.get("smo_cap_core_pos").Destroy();
    if (!ent.GetMoveParent()) {
      local pang = GetPlayer().GetAngles();
      ent.SetAngles(pang.x, pang.y - 90, 0);
    }
  }
}

smo.cap.turret <- function(ent) {

  if (ent.GetName() == "initial_template_turret") {

    ppmod.fire(ent, "Use", "", 0, GetPlayer());
    ppmod.fire(ent, "SelfDestructImmediately");

    EntFire("@BringDefectiveTurret_trigger", "Kill");
    EntFire("player_in_scanner_trigger", "Kill");
    EntFire("scanner_screen_script", "RunScriptCode", "TemplateTurretBroken()");
    EntFire("control_room_blocking_doors", "TurnOn");
    EntFire("control_room_blocking_doors", "EnableCollision");
    EntFire("catch_turret_nag_timer", "Kill");
    EntFire("template_scanner_1_relay", "Enable");
    EntFire("switch_turret_acceptance_relay", "Trigger");
    EntFire("turrets_offline_relay", "Trigger");

    smo.cap.back();
    return;

  }

  local ang = ent.GetAngles();
  GetPlayer().SetAngles(0, ang.y, 0);

  local target = Entities.CreateByClassname("info_target");
  ppmod.keyval(target, "Targetname", "smo_turret_target");

  if (ent.GetModelName() != "models/npcs/turret/turret_skeleton.mdl") {
    ppmod.interval(function(ent = ent, target = target) {

      if (!ent) return;
      if (!ent.IsValid()) {
        smo.cap.create(function() {
          smo.move.duck();
        });
        return;
      }

      local pos = ent.GetOrigin();
      local offset = Vector(0, 0, -26);
      GetPlayer().SetAbsOrigin(pos + offset);

      local eyepos = GetPlayer().EyePosition();
      local vec = ppmod.player.eyes_vec();
      target.SetOrigin(eyepos + vec * 256);

      if (smo.move.gameui.attack) {
        ppmod.fire(ent, "FireBullet", "smo_turret_target");
      }

    }, 0, "smo_turret_loop");
  }

  ppmod.fire(ent, "DisableDraw");
  ppmod.fire(smo.cap.ent, "DisableDraw");
  ppmod.keyval(ent, "CollisionGroup", 2);
  ppmod.fire(smo.move.speedmod, "ModifySpeed", 0);
  ppmod.keyval(GetPlayer(), "MoveType", 8);
  ppmod.fire(ent, "EnableGagging");
  smo.cap.captured = ent;
  smo.cap.spectate(true);

  smo.cap.leavefunc = function(ent) {
    if (ent && ent.IsValid()) {
      ppmod.fire(ent, "EnableDraw");
      ppmod.fire(ent, "DisableGagging");
      ppmod.keyval(ent, "CollisionGroup", 0);
    }
    ppmod.fire(smo.move.speedmod, "ModifySpeed", 1);
    ppmod.keyval(GetPlayer(), "MoveType", 2);
    ppmod.fire("smo_turret_loop", "Kill");
    ppmod.fire("smo_turret_target", "Kill");
    local pos = ent.GetOrigin();
    local ang = ent.GetAngles();
    local offset = Vector(0, 0, 60);
    smo.move.safetp(pos + offset);
    smo.cap.spectate(false);
  }
}

smo.cap.monster <- function(ent) {
  ent.SetVelocity(Vector());
  ppmod.keyval(ent, "MoveType", 8);
  ppmod.keyval(ent, "CollisionGroup", 1);
  ppmod.fire(ent, "BecomeBox");
  ppmod.give("prop_weighted_cube", function(cube, ent = ent) {
    ppmod.keyval(cube, "Targetname", "smo_monster_ghostbox");
    local pos = ent.GetOrigin();
    ent.SetAngles(0, 0, 0);
    cube.SetOrigin(pos);
    cube.SetAngles(0, 0, 0);

    local push = Entities.CreateByClassname("point_push");
    ppmod.keyval(push, "Targetname", "smo_monster_push");
    ppmod.keyval(push, "SpawnFlags", 22);
    ppmod.keyval(push, "Radius", 1);
    ppmod.fire(push, "Enable");

    ppmod.fire(ent, "DisableMotion");
    ppmod.fire(cube, "DisableDraw");
    ppmod.keyval(cube, "CollisionGroup", 23);
    smo.cap.cam(cube);
    // ppmod.fire(ent, "SetParent", "smo_monster_ghostbox");
    // ppmod.fire(smo.cap.ent, "SetParent", ent.GetName());
    smo.move.speed(175);

    ppmod.interval(function(cube = cube, ent = ent, push = push) {
      if (!smo.cap.captured) return;
      if (!smo.cap.captured.IsValid()) {
        smo.cap.create(function() {
          smo.move.duck();
        });
        return;
      }

      local pos = cube.GetOrigin();
      local ang = ppmod.player.eyes.GetAngles();
      ppmod.keyval(ent, "Angles", "0 "+ang.y+" 0");
      ppmod.keyval(cube, "Angles", "0 "+ang.y+" 0");
      ppmod.fire(ent, "BecomeMonster");
      smo.cap.ent.SetAbsOrigin(pos + smo.cap.offset + Vector(0, 0, 36));
      smo.cap.ent.SetAngles(0, ang.y, 0);
      ent.SetOrigin(pos);
      push.SetOrigin(pos);
      push.SetAngles(-45, ang.y, 0);
    }, 0, "smo_monster_update");

    ppmod.interval(function(push = push) {
      ppmod.fire(push, "AddOutput", "Magnitude 20");
      ppmod.fire(push, "AddOutput", "Magnitude 0", 0.2);
    }, 1, "smo_monster_push_loop");

    smo.cap.leavefunc = function(cube, ent = ent) {
      ppmod.fire(ent, "EnableMotion");
      ppmod.keyval(ent, "MoveType", 6);
      ppmod.keyval(ent, "CollisionGroup", 24);
      ppmod.fire(cube, "Kill", FrameTime());
      ppmod.fire("smo_monster_update", "Kill");
      ppmod.fire("smo_monster_push", "Kill");
      ppmod.fire("smo_monster_push_loop", "Kill");
      local pos = cube.GetOrigin();
      local ang = cube.GetAngles();
      ent.SetVelocity(Vector());
      smo.move.safetp(pos + Vector(0, 0, 41));
      GetPlayer().SetOrigin(pos + Vector(0, 0, 45));
      ppmod.fire(ent, "BecomeBox");
      ppmod.fire(ent, "SetLocalOrigin", pos.x+" "+pos.y+" "+pos.z);
      ppmod.fire(ent, "SetLocalAngles", "0 "+ang.y+" 0");
    }
  });
}