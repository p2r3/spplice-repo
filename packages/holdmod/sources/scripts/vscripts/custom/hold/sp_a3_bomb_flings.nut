/* ppmod.create("prop_physics_create npcs/potatos/world_model/potatos_wmodel.mdl", function(cube) {
  cube.SetOrigin(Vector(-267, 389, -1336));
  cube.SetAngles(0, 0, 0);
  ppmod.keyval(cube, "Targetname", "hold_water_cube");
  ppmod.keyval(cube, "SpawnFlags", 5);
  ppmod.keyval(cube, "CollisionGroup", 1);

  ppmod.create("ent_create_paint_bomb_erase", function(bomb) {
    bomb.SetOrigin(Vector(-267, 389, -1336));
    bomb.SetAngles(0, 0, 0);
    ppmod.keyval(bomb, "Targetname", "hold_water_bomb");
    ppmod.keyval(bomb, "CollisionGroup", 1);

    local mirror = Entities.CreateByClassname("logic_measure_movement");
    ppmod.keyval(mirror, "MeasureType", 0);
    ppmod.keyval(mirror, "Targetname", "hold_water_mirror");
    ppmod.keyval(mirror, "TargetReference", "hold_water_mirror");
    ppmod.fire(mirror, "SetMeasureReference", "hold_water_mirror");
    ppmod.fire(mirror, "SetMeasureTarget", "hold_water_cube");
    ppmod.keyval(mirror, "Target", "hold_water_bomb");
    ppmod.fire(mirror, "Enable");
  });
}); */

ppmod.create("prop_physics_create props_bts/bts_chair.mdl", function(ent){
  ent.SetOrigin(Vector(-404, -690, 278));
  ent.SetAngles(0, 134, 0);
});

ppmod.keyval("trigger_portal_cleanser", "SpawnFlags", 73);