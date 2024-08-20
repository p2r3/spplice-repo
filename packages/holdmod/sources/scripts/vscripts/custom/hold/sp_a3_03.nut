ppmod.create("prop_physics_create npcs/potatos/world_model/potatos_wmodel.mdl", function(ent) {
  ent.SetOrigin(Vector(-6185, -2889, -5210));
  ent.SetAngles(0, 0, 0);
  ppmod.fire(ent, "Use", "", 0, GetPlayer());
});