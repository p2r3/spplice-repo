ppmod.create("prop_weighted_cube", function(ent) {
  local door = ppmod.get("models/props/vert_door/vert_door_lower.mdl");
  ent.SetOrigin(Vector(-360, 2438, -94));
  ent.SetAngles(0, 0, 0);
  ppmod.keyval(ent, "Targetname", "hold_door_phys");
  ppmod.keyval(ent, "CollisionGroup", 2);
  ppmod.keyval(door, "CollisionGroup", 0);
  ppmod.fire(door, "SetParent", "hold_door_phys");
  ppmod.fire(ent, "DisableDraw");
  ppmod.fire(ent, "Sleep");
});