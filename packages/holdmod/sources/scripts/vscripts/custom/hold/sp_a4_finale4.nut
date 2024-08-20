/* ppmod.create("prop_physics_create props_bts/bts_chair.mdl", function(ent){
  ent.SetOrigin(Vector(-1682, -563, -2642));
  ent.SetAngles(0, 90, 0);
  ppmod.fire(ent, "Use", "", 0, GetPlayer());
}); */

ppmod.addscript("stalemate_ending_relay", "OnTrigger", "hold.mech.end()");

SendToConsole("alias +mouse_menu \"script hold.level.drop()\"");

hold.level.strip <- Entities.CreateByClassname("player_weaponstrip");

ppmod.player.enable();

hold.level.drop <- function() {

  if(ppmod.get("hold_portalgun_prop")) return;

  ppmod.fire(hold.level.strip, "Strip");
  ppmod.fire("viewmodel", "DisableDraw", "", 0.3);

  ppmod.create("prop_physics_create props/water_bottle/water_bottle.mdl", function(ent) {

    local pos = GetPlayer().EyePosition() + ppmod.player.eyes_vec() * 64;
    ent.SetOrigin(pos);
    ent.SetAngles(-90, 0, 0);
    ppmod.keyval(ent, "Targetname", "hold_portalgun_prop");
    ppmod.fire(ent, "DisableDraw");

    local equip = ppmod.trigger(pos, Vector(4, 4, 4));
    ppmod.fire(equip, "SetParent", "hold_portalgun_prop");
    ppmod.addscript(equip, "OnStartTouch", function() {
      ppmod.fire("hold_portalgun_prop", "KillHierarchy");
      GivePlayerPortalgun();
      UpgradePlayerPortalgun();
    }, 0, -1, true);

    ppmod.create("weapons/w_portalgun.mdl", function(gun, ent = ent) {

      gun.SetOrigin(ent.GetOrigin() - Vector(16));
      gun.SetAngles(0, 0, 0);
      ppmod.fire(gun, "SetParent", "hold_portalgun_prop");
      ppmod.keyval(gun, "CollisionGroup", 1);

    });

  });

}