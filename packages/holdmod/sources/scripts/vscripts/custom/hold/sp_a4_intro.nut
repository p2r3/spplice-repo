ppmod.create("props_underground/filecabinet_lobby.mdl", function(cab) {
  cab.SetOrigin(Vector(-528, -112, 256));
  cab.SetAngles(0, 0, 0);
  ppmod.create("prop_weighted_cube", function(cube, cab = cab) {
    cube.SetOrigin(Vector(-544, -96, 274));
    cube.SetAngles(0, 0, 0);
    ppmod.keyval(cube, "Targetname", "hold_cab_phys");
    ppmod.keyval(cube, "CollisionGroup", 2);
    ppmod.keyval(cab, "CollisionGroup", 0);
    ppmod.fire(cab, "SetParent", "hold_cab_phys");
    ppmod.fire(cube, "DisableDraw");
  });
});

ppmod.get(123).Destroy();
ppmod.get(105).Destroy();