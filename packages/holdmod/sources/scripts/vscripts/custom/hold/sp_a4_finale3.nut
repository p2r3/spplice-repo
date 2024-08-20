local end = ppmod.trigger(Vector(-189, 5056, 134), Vector(323, 360, 194));
ppmod.addscript(end, "OnStartTouch", "hold.mech.end()");

ppmod.create("prop_physics_create props_bts/bts_chair.mdl", function(ent){
  ent.SetOrigin(Vector(-318, -2374, 167));
  ent.SetAngles(0, 180, 0);
});

/* ppmod.addscript("practice_core_bomb_template", "OnEntitySpawned", function() {

  local bomb = ppmod.prev("practice_core_bomb");
  ppmod.keyval(bomb, "Targetname", UniqueString("hold_bomb"));
  ppmod.keyval(bomb, "CollisionGroup", 2);

  ppmod.create("npc_personality_core", function(ent, bomb = bomb) {

    ppmod.keyval(ent, "Targetname", UniqueString("hold_bomb"));
    ppmod.keyval(bomb, "CollisionGroup", 3);
    // ppmod.fire(ent, "DisableDraw");
    ent.SetOrigin(bomb.GetOrigin());

    // ppmod.fire(bomb, "SetParent", ent.GetName());

    local mirror = Entities.CreateByClassname("logic_measure_movement");
    ppmod.keyval(mirror, "Targetname", "mirror_" + ent.GetName());
    ppmod.keyval(mirror, "TargetReference", "mirror_" + ent.GetName());
    ppmod.fire(mirror, "SetMeasureReference", "mirror_" + ent.GetName());
    ppmod.fire(mirror, "SetMeasureTarget", ent.GetName());
    ppmod.keyval(mirror, "Target", bomb.GetName());
    ppmod.fire(mirror, "Enable");

    ppmod.addoutput(bomb, "OnBreak", ent.GetName(), "Kill");
    ppmod.addscript(bomb, "OnPlayerUse", function(ent = ent) {
      ppmod.fire(ent, "Use", "", 0, GetPlayer());
    });

    ppmod.addscript(ent, "OnPlayerPickup", function(bomb = bomb) {
      ppmod.keyval(bomb, "ExplodeOnTouch", false);
    });
    ppmod.addscript(ent, "OnPhysGunDrop", function(bomb = bomb) {
      ppmod.keyval(bomb, "ExplodeOnTouch", true);
    });
    ppmod.addscript(ent, "OnFizzled", function() {
      ppmod.fire(ent, "Kill");
    });

  });

}); */

ppmod.fire("AutoInstance1-@exit_elevator_cleanser", "Disable");
