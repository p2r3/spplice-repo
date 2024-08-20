EntFire("Knockout-ViewController", "TeleportToView", "", 2);
EntFire("Knockout-ViewController", "Kill", "", 2);
EntFire("Knockout-Portalgun-Spawn", "ForceSpawn");
EntFire("Knockout-Portalgun-Spawn", "Kill");
EntFire("Knockout-Bird", "Kill");
EntFire("PotatOS_Prop", "Kill");

ppmod.create("prop_physics_create npcs/potatos/world_model/potatos_wmodel.mdl", function(ent) {
  ent.SetOrigin(Vector(-626.4, -1907.2, 141));
  ent.SetAngles(0, 20, -35);
  ppmod.fire(ent, "Sleep");
});