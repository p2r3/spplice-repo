smo.move <- {
  pound = false,
  air = false,
  prev = 0,
  jumps = 0,
  ducking = false,
  using = false,
  rmjump = null,
  rmpound = null,
  ljump = false,
  diving = false,
  walldir = null,
  rolltime = 0,
  rollvel = 0,
  safepos1 = Vector(),
  safepos2 = Vector(),
  canstuck = true,
  stucki = 0,
  capjumped = false,
  bonk = false
};

smo.move.setup <- function() {
  ppmod.player.enable();
  local auto = Entities.CreateByClassname("logic_auto");
  ppmod.addscript(smo.auto, "OnMapSpawn", "SendToConsole(\"prevent_crouch_jump 0\")");
  SendToConsole("prevent_crouch_jump 0");
  local pos = GetPlayer().GetOrigin();

  ppmod.player.jump("smo.move.jump()");
  ppmod.player.duck("smo.move.duck()");

  // Ground detection
  ppmod.wait(function() {
    ppmod.interval(function() {
      local vel = GetPlayer().GetVelocity();
      if (smo.move.prev <= 0 && vel.z == 0 && smo.move.air) smo.move.land();
      else if (smo.move.prev != 0 && vel.z != 0) smo.move.float();
      smo.move.prev = vel.z;
    });
  }, FrameTime() * 2);

  ppmod.player.duck("if (!smo.cap.captured) smo.move.ducking = true");
  ppmod.player.unduck("smo.move.ducking = false");

  smo.move.gameui <- {
    moveleft = false,
    moveright = false,
    forward = false,
    back = false,
    attack = false,
    attack2 = false
  };
  foreach (key, val in smo.move.gameui) {
    ppmod.player.input("+" + key, "smo.move.gameui." + key + " = true");
    ppmod.player.input("-" + key, "smo.move.gameui." + key + " = false");
  }

  smo.move.speedmod <- Entities.CreateByClassname("player_speedmod");
  ppmod.keyval(smo.move.speedmod, "SpawnFlags", 0);

  // Horrible way of doing this. Will replace as soon as I can.
  SendToConsole("alias +use \"script smo.move.use()\"");
  SendToConsole("alias -use \"script smo.move.unuse()\"");

  // SLA softlock prevention
  SendToConsole("-jump");
  smo.move.speed(175);
  ppmod.addscript(smo.auto, "OnLoadGame", function() {
    SendToConsole("-jump");
    smo.move.speed(175);
  });

  // SendToConsole("sv_noclipspeed 0");
  // ppmod.interval("smo.move.stuck()", FrameTime() * 2);
  // SendToConsole("alias smo_noclip \"script smo.move.noclip()\"");

  if (smo.debug) ppmod.interval("smo.move.debug()");
}

smo.move.debug <- function() {
  local dbg = "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
  dbg += "jumps: " + smo.move.jumps + "\n";
  dbg += "pound: " + smo.move.pound + "\n";
  local wall = false;
  if (smo.move.walldir) wall = true;
  dbg += "wall: " + wall + "\n";
  local wallcheck = false;
  if (ppmod.get("smo_wallcheck")) wallcheck = true;
  dbg += "wallcheck: " + wallcheck + "\n";
  dbg += "capent: " + smo.cap.ent.GetOrigin().ToKVString().slice(0, -2);
  ScriptShowHudMessageAll(dbg, FrameTime());
}

smo.move.speed <- function(speed) {
  SendToConsole("cl_forwardspeed " + speed);
  SendToConsole("cl_sidespeed " + speed);
  SendToConsole("cl_backspeed " + speed);
  if (speed == 175) {
    SendToConsole("-duck");
    smo.move.ducking = false;
  } else {
    SendToConsole("+duck");
  }
}

smo.move.jump <- function() {
  // Walljump
  if (smo.move.walldir) {
    local vel = smo.move.walldir * -200;
    vel.z = 200;
    GetPlayer().SetVelocity(vel);
    smo.move.walldir = null;
    smo.move.capjumped = true;
    smo.move.jumps = 0;
  }

  if (smo.move.air || smo.cap.captured || smo.move.bonk) return;
  smo.move.air = true;

  // Double and triple jump
  smo.move.jumps ++;
  if (smo.move.jumps > 0) {
    if (smo.move.rmjump && smo.move.rmjump.IsValid()) smo.move.rmjump.Destroy();
    smo.move.rmjump = null;
  }
  if (smo.move.jumps == 3) {
    local vel = GetPlayer().GetVelocity();
    if (abs(vel.x) + abs(vel.y) >= 174) {
      GetPlayer().SetVelocity(Vector(vel.x, vel.y, 450));
      smo.move.jumps = 0;
    } else smo.move.jumps = 1;
  }
  if (smo.move.jumps == 2) {
    local vel = GetPlayer().GetVelocity();
    GetPlayer().SetVelocity(Vector(vel.x, vel.y, 220));
  }

  // Ground pound jump
  if (smo.move.pound) {
    GetPlayer().SetVelocity(Vector(0, 0, 400));
    if (smo.move.rmpound && smo.move.rmpound.IsValid()) smo.move.rmpound.Destroy();
    smo.move.rmpound = null;
    smo.move.pound = false;
    smo.move.speed(175);
    if (smo.move.rmjump && smo.move.rmjump.IsValid()) smo.move.rmjump.Destroy();
    smo.move.rmjump = null;
    smo.move.jumps = 0;
  }

  // Backflip or longjump
  if (smo.move.ducking) {
    local pos = GetPlayer().GetOrigin();
    local vel = GetPlayer().GetVelocity();
    local vec = ppmod.player.eyes_vec();
    local len = -100;
    if (abs(vel.x) + abs(vel.y) < 100) { // Backflip
      vec.z = 0;
      vec.Norm();
      vec.z = 400.0 / len;
    } else { // Longjump
      vec.z = 0;
      vec.Norm();
      len = 400;
      vec.z = 200.0 / len;
      smo.move.jumps = 0;
      smo.move.ljump = true;
    }
    GetPlayer().SetVelocity(vec * len);
    if (smo.move.jumps == 2) smo.move.jumps = 1;
  }
}

smo.move.float <- function() {

  // Walljump check
  if (!ppmod.get("smo_wallcheck") && !ppmod.get("smo_wallcheck_cooldown")) {
    ppmod.wait(function() {
      ppmod.interval("smo.move.wallcheck()", 0, "smo_wallcheck");
    }, 0.2, "smo_wallcheck_cooldown");
    ppmod.wait(function(){}, 0.3, "smo_wallcheck_cooldown");
  }

  smo.move.air = true;

}

smo.move.land <- function() {
  if (smo.move.air && smo.move.jumps > 0) {
    if (smo.move.rmjump && smo.move.rmjump.IsValid()) smo.move.rmjump.Destroy();
    smo.move.rmjump = ppmod.wait("smo.move.jumps = 0; smo.move.rmjump = null", 0.2);
  }
  if (smo.move.pound || smo.move.bonk) {
    smo.move.rollvel = 300;
    if (smo.move.rmpound && smo.move.rmpound.IsValid()) smo.move.rmpound.Destroy();
    smo.move.rmpound = ppmod.wait(function() {
      smo.move.bonk = false;
      smo.move.pound = false;
      smo.move.speed(175);
    }, 0.7);
  }
  smo.move.air = false;
  smo.move.ljump = false;
  smo.move.diving = false;
  smo.move.capjumped = false;
  local wallcheck = ppmod.get("smo_wallcheck");
  if (wallcheck && wallcheck.IsValid()) wallcheck.Destroy();
  ppmod.wait("smo.move.walldir = null", FrameTime());
}

smo.move.duck <- function() {
  if (smo.move.air && !smo.move.ljump && !smo.move.diving) { // Ground pound
    smo.move.pound = true;
    ppmod.fire(smo.move.speedmod, "ModifySpeed", 0);
    ppmod.fire(smo.move.speedmod, "ModifySpeed", 1, 0.3);
    GetPlayer().SetVelocity(Vector(0, 0, -500));
    smo.move.speed(0);
    smo.move.jumps = 0;
    ppmod.wait(function() {
      if (GetPlayer().GetVelocity().z == 0) smo.move.land();
    }, 0.3);
  }
  // Leave capture
  if (smo.cap.captured) {
    local ent = smo.cap.captured;
    smo.cap.cam_leave();
    smo.cap.leavefunc(ent);
    smo.cap.leavefunc = function(e) {};
  }
}

// Wall proximity check
smo.move.wallcheck <- function() {
  if (smo.move.pound) return;
  local pos = GetPlayer().EyePosition();
  local vel = GetPlayer().GetVelocity();
  local vec = smo.move.walldir;
  if (!vec) vec = ppmod.player.eyes_vec();
  else {
    vel.z += 5;
    GetPlayer().SetVelocity(vel);
  }
  vec.z = 0;
  vec.Norm();
  local frac = TraceLine(pos, pos + vec * 23, GetPlayer());
  if (frac != 1){
    if (ppmod.get(pos + vec * frac * 23, "prop_portal", 54)) return;
    if (smo.move.ljump || smo.move.diving) { // Dive bonk
      GetPlayer().SetVelocity(vec * -50);
      smo.move.speed(0);
      smo.move.bonk = true;
      return;
    }
    if (!smo.move.walldir) {
      if (vel.z < 0) vel.z = 0;
      GetPlayer().SetVelocity(vel);
    }
    smo.move.walldir = vec;
  } else smo.move.walldir = null;
}

smo.move.use <- function() {

  if (smo.move.bonk) return;

  if ("moon" in smo) {
    if (smo.moon.odyssey.enabled > 1) {
      smo.moon.odyssey.list();
      return;
    }
  }

  smo.move.using = true;

  local rollinterval = ppmod.get("smo_roll");
  if (smo.move.ducking && (!smo.move.air || rollinterval)) { // Roll

    smo.move.rolltime = 0;
    smo.move.rollvel = min(300, smo.move.rollvel + 50);
    if (!rollinterval) {
      ppmod.interval("smo.move.roll()", 0, "smo_roll");
    }

  } else if (smo.move.pound && smo.move.air) { // Dive

    ppmod.fire(smo.move.speedmod, "ModifySpeed", 1);
    local vec = ppmod.player.eyes_vec();
    vec.z = 0;
    vec.Norm();
    vec = vec * 350 + Vector(0, 0, 150);
    GetPlayer().SetVelocity(vec);
    if (smo.move.rmpound && smo.move.rmpound.IsValid()) smo.move.rmpound.Destroy();
    smo.move.rmpound = null;
    smo.move.pound = false;
    smo.move.speed(175);
    smo.move.diving = true;

  } else smo.cap.use();

}
smo.move.unuse <- function() {
  smo.move.using = false;
  smo.cap.unuse();
}

smo.move.roll <- function() {
  /* if (smo.move.air) {
    SendToConsole("cl_forwardspeed 0");
    SendToConsole("cl_sidespeed 0");
    SendToConsole("cl_backspeed 0");
    ppmod.fire(smo.move.brick, "Enable");
    return;
  } */
  if (smo.move.ljump) return;
  local vel = GetPlayer().GetVelocity();
  local rvel = smo.move.rollvel;
  local vec = ppmod.player.eyes_vec();
  if (smo.move.rolltime != 0 && (vel.x == 0 || vel.y == 0) && vec.z != 0) smo.move.rolltime = 50;
  vec.z = 0;
  vec.Norm();
  vec *= rvel - smo.move.rolltime * rvel / 50;
  GetPlayer().SetVelocity(Vector(vec.x, vec.y, vel.z));
  if (++smo.move.rolltime >= 50 || !smo.move.ducking) {
    smo.move.rollvel = 0;
    ppmod.get("smo_roll").Destroy();
  }
}

smo.move.capjump <- function(ent) {
  ppmod.wait("smo.cap.back()", 0.4);
  if (smo.move.capjumped) return;
  if (smo.move.air) smo.move.capjumped = true;
  smo.move.ljump = false;
  smo.move.diving = false;

  SendToConsole("+jump");
  ppmod.wait("SendToConsole(\"-jump\")", FrameTime());
  local vel = GetPlayer().GetVelocity();
  if (smo.move.air) vel *= 0.5;
  vel.z = 200;
  GetPlayer().SetVelocity(vel);

  local loop = ppmod.get("smo_capfly_stall");
  if (loop && loop.IsValid()) loop.Destroy();
}

// ********************************
//         Stuck prevention
// ********************************

smo.move.safetp <- function(pos) {

  GetPlayer().SetOrigin(pos);

  SendToConsole("setpos_exact "+pos.x+" "+pos.y+" "+pos.z);
  SendToConsole("setang -90 0");
  SendToConsole("noclip 1");
  SendToConsole("noclip 0");
  SendToConsole("setang 90 0");
  SendToConsole("noclip 1");
  SendToConsole("noclip 0");
  SendToConsole("debug_fixmyposition");

  local ang = ppmod.player.eyes.GetAngles();
  SendToConsole("setang "+ang.x+" "+ang.y+" "+ang.z);

}
