smo.setup <- function() {
  
  ppmod.give("npc_security_camera", function (ent) {

    ent.SetOrigin(Vector(640.5, 638.5, 102.5));
    ent.SetAngles(0, 0, 0);

    ppmod.fire(ent, "Wake");

  });

}
