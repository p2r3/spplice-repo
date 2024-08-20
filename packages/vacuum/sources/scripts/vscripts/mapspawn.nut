if (!("Entities" in this)) return;
IncludeScript("ppmod4");

::portalPullPosition <- null;

ppmod.onauto(async(function () {

  yield ppmod.player(GetPlayer());
  local pplayer = yielded;

  ppmod.interval(function () {

    if (!portalPullPosition) return;

    local dir = portalPullPosition - GetPlayer().GetOrigin();
    dir.Norm();
    GetPlayer().SetVelocity(GetPlayer().GetVelocity() + dir * 80.0);

  });

  ppmod.onportal(async(function (shot):(pplayer) {

    if (!shot.portal) return;

    local pportal = ppmod.portal(shot.portal);
    yield pportal.GetActivatedState();
    local open = yielded;

    if (!open) return;

    if (pplayer.grounded()) {
      pplayer.ent.SetAbsOrigin(pplayer.ent.GetOrigin() + Vector(0, 0, 32));
    }

    ::portalPullPosition = shot.portal.GetOrigin() - shot.portal.GetForwardVector() * 16 - Vector(0, 0, 36);
    pplayer.gravity(0);

    if (!shot.portal.ValidateScriptScope()) return;
    local scope = shot.portal.GetScriptScope();

    if ("pusherLogic" in scope) return;
    scope.pusherLogic <- true;

    shot.portal.AddScript("OnPlayerTeleportFromMe", function ():(push, pplayer) {

      ::portalPullPosition = null;
      pplayer.gravity(1.0);

    });

  }));

}));
