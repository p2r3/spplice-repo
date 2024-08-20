if (!("Entities" in this)) return;
IncludeScript("ppmod4");

::ppanfBlockingEntities <- [
  "prop_testchamber_door",
  "trigger_portal_cleanser"
];

::forcePlacePortal <- function (id, pplayer) {

  local start = GetPlayer().EyePosition();
  local end = start + pplayer.eyes.GetForwardVector() * 128;

  local ray = ppmod.ray(start, end, ::ppanfBlockingEntities);

  if (ray.fraction != 1.0) {

    local portal = null;
    while (portal = ppmod.get("prop_portal", portal)) {
      if (portal.GetModelName()[21] - 49 == id) {
        portal.Fire("SetActivatedState", 0);
      }
    }

    return;

  }

  local bpos = end + pplayer.eyes.GetForwardVector() * 2;
  local ang = pplayer.eyes.GetAngles();

  local portal = null;
  while (portal = ppmod.get("prop_portal", portal)) {
    if (portal.GetModelName()[21] - 49 == id) {
      portal.SetOrigin(end);
      portal.SetForwardVector(Vector() - pplayer.eyes.GetForwardVector());
    }
  }

  ppmod.wait(function ():(id, end, bpos, ang) {
    SendToConsole("portal_place 0 "+id+" "+end.x+" "+end.y+" "+end.z+" "+(-ang.x)+" "+(ang.y + 180)+" 0");
    SendToConsole("portal_place 1 "+id+" "+bpos.x+" "+bpos.y+" "+bpos.z+" "+ang.x+" "+ang.y+" 0");
  }, FrameTime());

}

::ppanfSetupDone <- false;
ppmod.onauto(async(function () {

  if (GetMapName().tolower() == "sp_a2_pull_the_rug") {
    ::ppanfBlockingEntities <- ["prop_testchamber_door"];
  }

  yield ppmod.player(GetPlayer());
  local pplayer = ::syncnext;

  ppmod.interval(function ():(pplayer) {

    if (::ppanfSetupDone) return;

    local pgun = ppmod.get("weapon_portalgun");
    if (!pgun) return;

    pgun.AddScript("OnFiredPortal1", function ():(pplayer) {
      ::forcePlacePortal(0, pplayer);
    });
    pgun.AddScript("OnFiredPortal2", function ():(pplayer) {
      ::forcePlacePortal(1, pplayer);
    });

    ppmod.get("find_portalgun_interval").Destroy();
    ::ppanfSetupDone <- true;

  }, 0, "find_portalgun_interval");

  ppmod.addoutput("trigger_portal_cleanser", "OnFizzle", "prop_portal", "Fizzle");

}));

ppmod.onauto(function () {

  SendToConsole("sv_player_collide_with_laser 0");
  SendToConsole("sv_portal_placement_never_fail 1");
  SendToConsole("portal_draw_ghosting 0");

}, true);
