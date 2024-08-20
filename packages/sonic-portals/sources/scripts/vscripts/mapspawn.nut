if(!("Entities" in this)) return;
foreach (x in ["sp_a1_intro1", "sp_a1_intro2", "sp_a1_intro3", "sp_a1_intro4", "sp_a1_intro5", "sp_a1_intro6", "sp_a1_intro7", "sp_a1_wakeup"]) {
  if(x == GetMapName()) return;
}

IncludeScript("custom/ppmod.nut");
printl("\n=== Loading Sonic Portals mod...");

local auto = Entities.CreateByClassname("logic_auto");
ppmod.addscript(auto, "OnNewGame", "mod.start()");
ppmod.addscript(auto, "OnMapTransition", "mod.start()");

// movesim
::mod <- {};
mod.start <- function() {
  ppmod.player.enable(function() {
    foreach (key, val in mod.movement) {
      ppmod.player.input("+" + key, "mod.movement." + key + " = true");
      ppmod.player.input("-" + key, "mod.movement." + key + " = false");
    }
    ppmod.interval(mod.movesim ,FrameTime());
  });
  ppmod.interval(function() {
    // find all new portals, except the first 2 placed
    local ent = null;
    while(ent = Entities.FindByClassname(ent, "prop_portal")) {
      if (ent.GetName() == "sonicportals_mark") continue;
      ent.__KeyValueFromString("Targetname", "sonicportals_mark")
      // attach function on place
      ppmod.addscript(ent, "OnPlacedSuccessfully", mod.increaseSpeedLevel_fun);
    }
  });
  // add speed text
  mod.speedmodText_ent <- ppmod.text("Speed: loading...", 0.005, 0.995);
  mod.speedmodText_ent.SetChannel(2);
  ppmod.interval(function() {
    mod.speedmodText_ent.SetText("Speed: " + mod.speedmod_float);
    mod.speedmodText_ent.Display();
  });
};

mod.movement <- {
  moveleft = false,
  moveright = false,
  forward = false,
  back = false,
};
mod.speedmod_float <- 1.0;
mod.movesim <- function() {
  local TOTALMOVEMENT_FLOAT = 175.0;
  local movement = Vector(0, 0);
  if(mod.movement.moveright) {
    movement.y += TOTALMOVEMENT_FLOAT/2;
    if (!(mod.movement.forward || mod.movement.back)) {
      movement.y += TOTALMOVEMENT_FLOAT/2;
    }
  }
  if(mod.movement.moveleft) {
    movement.y -= TOTALMOVEMENT_FLOAT/2;
    if (!(mod.movement.forward || mod.movement.back)) {
      movement.y -= TOTALMOVEMENT_FLOAT/2;
    }
  }
  if(mod.movement.forward) {
    movement.x += TOTALMOVEMENT_FLOAT/2;
    if (!(mod.movement.moveleft || mod.movement.moveright)) {
      movement.x += TOTALMOVEMENT_FLOAT/2;
    }
  }
  if(mod.movement.back) {
    movement.x -= TOTALMOVEMENT_FLOAT/2;
    if (!(mod.movement.moveleft || mod.movement.moveright)) {
      movement.x -= TOTALMOVEMENT_FLOAT/2;
    }
  }
  movement.x *= mod.speedmod_float;
  movement.y *= mod.speedmod_float;
  ppmod.player.movesim(movement);
}

// speed modification
mod.portalcount_int <- 0
mod.setSpeed_fun <- function(value=1) {
  mod.speedmod_float = value;
}

mod.increaseSpeedLevel_fun <- function() {
  mod.portalcount_int += 1;
  mod.speedmod_float = (1.0/3)*(54.0-(50/mod.portalcount_int));
}
