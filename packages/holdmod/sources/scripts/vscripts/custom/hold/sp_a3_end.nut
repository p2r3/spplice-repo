ppmod.create("prop_physics_create props_bts/bts_chair.mdl", function(ent){
  ent.SetOrigin(Vector(-322, -926, -5040));
  ent.SetAngles(0, 90, 0);
  ppmod.keyval(ent, "Targetname", "hold_chair");
  ppmod.fire(ent, "Use", "", 0, GetPlayer());
});