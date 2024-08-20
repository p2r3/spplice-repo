ppmod.create("props_underground/chair_lobby.mdl", function(chair) {
  chair.SetOrigin(Vector(-3957, -39, -6101));
  chair.SetAngles(0, 0, 0);
  ppmod.create("prop_weighted_cube", function(cube, chair = chair) {
    cube.SetOrigin(Vector(-3957, -39, -6082));
    cube.SetAngles(0, 0, 0);
    ppmod.keyval(cube, "Targetname", "hold_chair_phys");
    ppmod.keyval(cube, "CollisionGroup", 2);
    ppmod.keyval(chair, "CollisionGroup", 0);
    ppmod.fire(chair, "SetParent", "hold_chair_phys");
    ppmod.fire(cube, "DisableDraw");
  });
});