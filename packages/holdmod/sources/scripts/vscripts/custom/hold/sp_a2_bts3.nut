ppmod.create("npc_portal_turret_floor", function(ent){
  ent.SetOrigin(Vector(4222, 955, 157));
  ent.SetAngles(0, 90, 0);
  ppmod.keyval(ent, "Targetname", "hold_turret");
  ppmod.fire(ent, "Use", "", 0, GetPlayer());
});

local end = ppmod.trigger(Vector(6136, 4927, -1665), Vector(263, 63, 127));
ppmod.keyval(end, "SpawnFlags", 8);
ppmod.addscript(end, "OnStartTouch", "hold.mech.end()");
ppmod.addoutput(end, "OnStartTouch", "!activator", "Ignite");