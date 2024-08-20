hold.mech <- {};
hold.mech.last <- null;
hold.mech.filter <- null;
hold.mech.check <- false;
hold.hudnl <- "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
hold.portal <- null;

hold.mech.setup <- function() {
  hold.mech.filter = Entities.CreateByClassname("filter_player_held");
  ppmod.addscript(hold.mech.filter, "OnPass", "hold.mech.check = true");
  ppmod.interval("hold.mech.tick()", FrameTime()*2, "hold_tick");

  local ele = null, trigger = null;
  if(ele = ppmod.get("departure_elevator-elevator_1")) {
    trigger = ppmod.trigger(ele.GetOrigin(), Vector(640, 640, 320));
  } else if(ele = ppmod.prev("models/props_underground/elevator_a.mdl")) {
    trigger = ppmod.trigger(ele.GetOrigin(), Vector(180, 180, 180));
  } else return;
  ppmod.keyval(trigger, "Targetname", "hold_exit");
  ppmod.addscript("hold_exit", "OnStartTouch", "hold.mech.end()");
}

hold.mech.end <- function() {
  if(!hold.start) hold.start = true;
  else hold.supress = true;
}

hold.mech.match <- function(ent) {
  switch (ent.GetClassname()) {
    case "prop_weighted_cube":
    case "prop_monster_box":
    case "npc_security_camera":
    case "prop_physics":
    case "prop_physics_override":
    case "npc_personality_core":
    case "npc_portal_turret_floor":
      return true;
  }
  return false;
}

hold.mech.portal <- function(ent) {
  if(hold.start) return;
  local pos = ent.GetOrigin();
  local ang = ent.GetAngles();
  GetPlayer().SetOrigin(pos + Vector(0, 0, cos(ang.x) * -54 + min(sin(ang.x) * -72, 0)));
  GetPlayer().SetAngles(-ang.x, ang.y + 180, 0);
  GetPlayer().SetVelocity(Vector());
}

hold.mech.tick <- function() {

  while(ppmod.get("prop_portal", hold.portal)) {
    hold.portal = ppmod.get("prop_portal", hold.portal);
    ppmod.addscript(hold.portal, "OnPlayerTeleportFromMe", "hold.mech.portal(self)");
  }

  if(!hold.mech.check) hold.damage = true;
  else if(hold.damage) { hold.start = true; hold.damage = false }
  hold.mech.check = false;

  local ent = null;
  while(ent = Entities.Next(ent)) {
    if(!ent || !ent.IsValid() || !hold.mech.match(ent)) continue;
    ppmod.fire(hold.mech.filter, "TestActivator", "", 0, ent);
    if(ent.GetClassname() != "npc_personality_core") ppmod.keyval(ent, "CollisionGroup", 2);
  }

  if(!hold.start) {
    ScriptShowHudMessageAll(hold.hudnl + "Pick up an object to start", FrameTime()*2);
    return;
  }
  local hp = GetPlayer().GetHealth();
  if(hold.damage && !hold.supress) hp -= 4;
  ScriptShowHudMessageAll(hold.hudnl + "Health: " + hp, FrameTime()*2);
  EntFire("!player", "SetHealth", hp);
  if(hp <= 0) {
    EntFire("hold_solid", "Kill");
    EntFire("hold_tick", "Kill");
    SendToConsole("kill");
  }
}