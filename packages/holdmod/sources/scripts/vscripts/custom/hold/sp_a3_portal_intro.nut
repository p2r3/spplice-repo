ppmod.create("prop_physics_create props_bts/bts_chair.mdl", function(ent){
  ent.SetOrigin(Vector(3178, -245, -2907));
  ent.SetAngles(0, 90, 0);
  ppmod.keyval(ent, "Targetname", "hold_chair");
});
ppmod.create("prop_physics_create props_bts/bts_chair.mdl", function(ent){
  ent.SetOrigin(Vector(3422, -127, 586));
  ent.SetAngles(0, 180, 0);
  ppmod.keyval(ent, "Targetname", "hold_chair");
});

ppmod.keyval(ppmod.get(513), "Targetname", "hold_door_fizzler");
ppmod.addoutput(ppmod.get(164), "OnStartTouch", "hold_door_fizzler", "Disable");