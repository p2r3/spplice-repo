IncludeScript("custom/ppmod3.nut");
if(!("hold" in this)) {
  ::hold <- {};
  hold.level <- {};
  hold.auto <- Entities.CreateByClassname("logic_auto");
  ppmod.addscript(hold.auto, "OnMapTransition", "hold.spawn()");
  ppmod.addscript(hold.auto, "OnNewGame", "hold.spawn()");
}

hold.spawn <- function() {
  hold.start <- false;
  hold.damage <- true;
  hold.supress <- false;
  IncludeScript("custom/hold/mechanics");
  hold.mech.setup();
  try {
    IncludeScript("custom/hold/" + GetMapName());
    if("con" in hold) SendToConsole("script hold.con()");
  } catch (e) {
    printl(e);
  }
}