local end = ppmod.trigger(Vector(-12832, -2591, -89), Vector(40, 184, 87));
ppmod.addscript(end, "OnStartTouch", "hold.mech.end()");

ppmod.create("prop_monster_box", function(ent) {
  ent.SetOrigin(Vector(-10969, -1380, -770));
  ent.SetAngles(0, 0, 0);
  ppmod.fire(ent, "BecomeBox");
});

EntFire("catwalk_box", "Kill");