IncludeScript("ppmod3.nut");
if(!("smo" in this)) {
  ::smo <- {};
  smo.level <- {};
  smo.debug <- false;
  smo.auto <- Entities.CreateByClassname("logic_auto");
  ppmod.addscript(smo.auto, "OnMapTransition", "smo.spawn()");
  ppmod.addscript(smo.auto, "OnNewGame", "smo.spawn()");
}

smo.spawn <- function() {

  SendToConsole("sv_cheats 1");
  SendToConsole("r_maxdlights 128");

  IncludeScript("odyssey/movement");
  IncludeScript("odyssey/captures");
  IncludeScript("odyssey/moonlist");
  IncludeScript("odyssey/collectibles");

  smo.move.setup();
  smo.cap.setup();
  smo.moon.setup();

  try {
    IncludeScript("odyssey/maps/" + GetMapName());
    smo.setup();
    if("con" in smo) SendToConsole("script smo.con()");
  } catch (e) {
    printl(e);
  }

  switch (GetMapName().tolower()) {

    case "sp_a1_intro1" : EntFire("viewmodel", "DisableDraw"); break;
    case "sp_a1_intro2" : EntFire("viewmodel", "DisableDraw"); break;
    case "sp_a1_intro3" : EntFire("viewmodel", "DisableDraw"); break;
    case "sp_a2_intro"  : EntFire("viewmodel", "DisableDraw"); break;
    default : EntFire("viewmodel", "EnableDraw");

  } 

  ppmod.addoutput("weapon_portalgun", "OnPlayerPickup", "viewmodel", "EnableDraw");

}
