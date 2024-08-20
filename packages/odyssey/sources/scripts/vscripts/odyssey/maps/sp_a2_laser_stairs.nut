smo.setup <- function() {

  local panelTrig = ppmod.trigger(Vector(-148, 693, -31), Vector(36, 27, 65));
  ppmod.addscript(panelTrig, "OnStartTouch", function() {
    ppmod.fire("robot_eyepeek_07", "SetAnimation", "eyepeek_07open");
    ppmod.fire("robot_eyepeek_08", "SetAnimation", "eyepeek_08open");
    ppmod.fire("robot_eyepeek_07", "SetDefaultAnimation", "eyepeek_07open_idle", 1);
    ppmod.fire("robot_eyepeek_08", "SetDefaultAnimation", "eyepeek_08open_idle", 1);
  });

}
