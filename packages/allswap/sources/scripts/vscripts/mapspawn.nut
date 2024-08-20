if (!("Entities" in this)) return;
IncludeScript("ppmod4");

/* Flags list:
  1 - Remove forward vector Z component
  2 - Use downwards raycast for spawn position
  4 - Check overlaps with similar entities nearby
*/

local swaplist = [
  ["models/props/metal_box.mdl", "prop_floor_button", 1 + 2 + 4],
  ["env_portal_laser", "prop_laser_catcher", 0],
  ["models/props/reflection_cube.mdl", "prop_laser_relay", 1 + 2],
  ["models/props_underground/underground_weighted_cube.mdl", "prop_under_floor_button", 1 + 2 + 4],
  ["prop_monster_box", "prop_floor_button", 1 + 2 + 4]
];
local rayents = [
  "trigger_hurt",
  "models/props/faith_plate.mdl"
];

::getVertBounds <- function (ent) {
  switch (ent.GetClassname()) {
    case "prop_floor_button": return [0, 16];
    case "prop_under_floor_button": return [0, 16];
    case "prop_weighted_cube": return [-40, 0];
    case "prop_monster_box": return [-40, 0];
    case "prop_laser_relay": return [0, 47];
  }
  return [ent.GetBoundingMins().z, ent.GetBoundingMaxs().z];
};

::swapSetup <- function ():(swaplist, rayents) {

  foreach (pair in swaplist) {

    local first = pair[0], second = pair[1], flags = pair[2];

    local firstarr = [], secondarr = [];
    ppmod.getall(first, function (e):(firstarr) { firstarr.push(e) });
    ppmod.getall(second, function (e):(secondarr) { secondarr.push(e) });

    for (local i = 0; i < firstarr.len(); i ++) {
      if (firstarr[i].GetClassname() == "generic_actor") continue;

      local mindist = 99999999, index = null;
      local firstpos = firstarr[i].GetOrigin();
      local firstvec = firstarr[i].GetForwardVector();

      for (local j = 0; j < secondarr.len(); j ++) {
        if (secondarr[j].GetClassname() == "generic_actor") continue;

        local dist = (firstpos - secondarr[j].GetOrigin()).LengthSqr();
        if (dist > mindist) continue;

        mindist = dist;
        index = j;

      }

      if (index == null) break;

      local firstent = firstarr[i];
      local secondent = secondarr[index];

      local secondpos = secondarr[index].GetOrigin();
      local secondvec = secondarr[index].GetForwardVector();

      if (flags % 2 == 1) {
        firstvec.z = 0;
        secondvec.z = 0;
      }

      if (flags % 4 / 2 == 1) {
        local firstvert = getVertBounds(firstent);
        local secondvert = getVertBounds(secondent);

        local firstray = ppmod.ray(firstpos + firstent.GetUpVector() * firstvert[1], firstpos - Vector(0, 0, 4096), rayents);
        local secondray = ppmod.ray(secondpos + secondent.GetUpVector() * secondvert[1], secondpos - Vector(0, 0, 4096), rayents);

        firstpos = firstray.point;
        secondpos = secondray.point;
        if (firstray.entity) firstpos.z += 16;
        if (secondray.entity) secondpos.z += 16;

        firstpos.z -= secondvert[0];
        secondpos.z -= firstvert[0];
      }

      if (flags % 8 / 4 == 1) {
        if (ppmod.get(firstpos, 64, secondent.GetClassname())) continue;
        if (ppmod.get(secondpos, 64, firstent.GetClassname())) continue;
      }

      firstent.SetAbsOrigin(secondpos);
      firstent.SetForwardVector(secondvec);
      secondent.SetAbsOrigin(firstpos);
      secondent.SetForwardVector(firstvec);

      firstent.DisableMotion();
      secondent.DisableMotion();
      firstent.EnableMotion("", 0.2);
      secondent.EnableMotion("", 0.2);

      secondarr.remove(index);

    }

  }

  local funnels = [], bridges = [];
  ppmod.getall("prop_tractor_beam", function (e):(funnels) { funnels.push(e) });
  ppmod.getall("prop_wall_projector", function (e):(bridges) { bridges.push(e) });

  foreach (funnel in funnels) {
    local pos = funnel.GetOrigin();
    local fvec = funnel.GetForwardVector();
    funnel.Destroy();

    ppmod.create("prop_wall_projector").then(function (bridge):(pos, fvec) {
      bridge.SetOrigin(pos);
      bridge.SetForwardVector(fvec);
      bridge.Enable();
    });
  }

  foreach (bridge in bridges) {
    local pos = bridge.GetOrigin();
    local fvec = bridge.GetForwardVector();
    local uvec = bridge.GetUpVector();
    bridge.Destroy();

    ppmod.create("prop_tractor_beam").then(function (funnel):(pos, fvec, uvec) {
      funnel.SetOrigin(pos + uvec * 48);
      funnel.SetForwardVector(fvec);

      funnel.SetLinearForce(250);
      funnel.Enable();
    });
  }

};

::randomizePaint <- function (ent) {
  ent.paintType = [0, 0, 2, 2, 3][RandomInt(0, 4)];
};

ppmod.onauto(function () {

  ppmod.interval(function () {
    ppmod.getall("info_paint_sprayer", randomizePaint);
    ppmod.getall("paint_sphere", randomizePaint);
    ppmod.getall("prop_paint_bomb", randomizePaint);
  }, 0.1);

  ppmod.fire("prop_monster_box", "BecomeBox");
  ppmod.wait(swapSetup, 0.5);

});
