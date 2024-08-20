// return;
if (!("Entities" in this)) return;
IncludeScript("ppmod4");

const SQRT2 = 1.41421356237;

const MOVE_MAGNITUDE = 15;
const MOVE_MAXVEL = 175;
const FRICTION_MAGNITUDE = 15;
const IDLE_FRICTION_MAGNITUDE = 5;
const GROUNDED_DISTANCE = 4;
const GRAVITY_MAGNITUDE = 6;
const JUMP_MAGNITUDE = 70;
const JUMP_TIMER_LENGTH = 2;
const MAX_CAM_KEYFRAMES = 6;
const MAX_GRAV_KEYFRAMES = 15;
const ENFORCE_ROTATION_TIME_START = 0.2;
const ENFORCE_ROTATION_TIME_END = 0.5;
const THROW_TIMER_LENGTH = 2;
const THROW_STRENGTH = 2.5;

::solidEnts <- [
  "func_brush",
  "phys_bone_follower"
];

::physProps <- [
  "prop_weighted_cube",
  "prop_monster_box",
  "npc_security_camera",
  "npc_portal_turret_floor",
  "prop_physics",
  "prop_physics_override",
  "prop_physics_paintable",
  "npc_personality_core"
];

::useProps <- [
  "prop_button",
  "prop_under_button",
  "func_button"
];

::holdableProps <- pparray([
  "prop_weighted_cube",
  "prop_monster_box",
  // "prop_physics",
  "prop_physics_override",
  "prop_physics_paintable",
  "npc_personality_core",
  "npc_portal_turret_floor",
  "npc_security_camera",
  "prop_glass_futbol"
]);
for (local i = 0; i < holdableProps.len(); i ++) {
  useProps.push(holdableProps[i]);
}
holdableProps.push("prop_physics");

::camSolids <- [
  "prop_testchamber_door"
];

::allFiredPortals <- pparray();
::lastPortalColor <- 0;

::cameraKeyframes <- [];
::gravityKeyframes <- [];

::enforcedRotation <- Vector(0, 0, 0);

::projectToPlane <- function (vec, normal) {

  // Calculate the projection of vector onto the normal
  local projectionLength = vec.Dot(normal);
  local projection = normal * projectionLength;

  // Subtract the projection from the original vector to get the 2D vector on the plane
  local projectedVector = vec - projection;

  // Return the result
  return projectedVector;

}

ppmod.onauto(async(function () {

  SendToConsole("sv_alternateticks 0");
  SendToConsole("sv_cheats 1");
  SendToConsole("sv_gravity 0");
  SendToConsole("portal_pointpush_think_rate " + (1.0 / 60));

  SendToConsole("con_filter_enable 1");
  SendToConsole("con_filter_text_out \"View entity set to\"");

  SendToConsole("crosshair 0");
  SendToConsole("r_portal_use_pvs_optimization 0");
  SendToConsole("gl_clear 1");

  // SendToConsole("cl_skip_player_render_in_main_view 0");
  // SendToConsole("player_held_object_use_view_model 1");

  ::firstRotation <- true;

  ppmod.onportal(function (shot) {

    if (shot.color != null) {
      ::lastPortalColor <- shot.color;
    }

    if (allFiredPortals.find(shot.portal) != -1) return;
    allFiredPortals.push(shot.portal);

    local pportal = ppmod.portal(shot.portal);

    pportal.OnTeleport(function (ent):(pportal) {

      if (ent.GetName() != "propPlayer") return;

      pportal.GetPartnerInstance().then(function (partner):(ent) {

        local ang = partner.GetAngles();
        ang.x -= 90;
        if (!::firstRotation) ent.SetAngles(ang.x, ang.y, ang.z);

        ::enforcedRotation = ang;

        if (!::firstRotation) {
          local enforceInterval = ppmod.interval(function ():(ang, ent) {
            ent.SetAngles(ang.x, ang.y, ang.z);
          });
          ppmod.fire(enforceInterval, "Kill", "", ENFORCE_ROTATION_TIME_START);
        }

        ::firstRotation = false;

        for (local i = 0; i < MAX_GRAV_KEYFRAMES; i ++) {
          gravityKeyframes[i] = ent.GetUpVector();
        }

      });

    });

  });

  local player = GetPlayer();
  yield ppmod.player(player);
  local pplayer = yielded;

  ::fakeHoldEntity <- null;
  ::fakeHoldAngles <- Vector();
  ppmod.interval(function ():(pplayer) {

    if (!fakeHoldEntity) return;
    if (!fakeHoldEntity.IsValid()) return;

    local start = pplayer.eyes.GetOrigin();
    local end = start + pplayer.eyes.GetForwardVector() * 160;
    local ray = ppmod.ray(start, end, ::solidEnts);

    local bbox = fakeHoldEntity.GetBoundingMaxs() - fakeHoldEntity.GetBoundingMins();
    local bboxMax = max(bbox.x, max(bbox.y, bbox.z));

    local dest = ray.point - pplayer.eyes.GetForwardVector() * bboxMax * SQRT2;
    local ang = fakeHoldAngles + pplayer.eyes.GetAngles();

    if (fakeHoldEntity.GetModelName() == "models/props/reflection_cube.mdl") {
      ang.y = pplayer.eyes.GetAngles().y;
    }

    fakeHoldEntity.SetAbsOrigin(dest);
    fakeHoldEntity.SetAngles(0, ang.y, ang.z);

  });

  ::fakeUse <- function ():(pplayer, player) {

    local start = pplayer.eyes.GetOrigin();
    local end = start + pplayer.eyes.GetForwardVector() * 128;

    local tmpUseProps = ::useProps.slice(0);

    local ent = null;
    while (ent = Entities.FindByClassname(ent, "prop_physics")) {
      if (ent.GetName() == "propPlayer") continue;
      tmpUseProps.push(ent);
    }

    local wray = ppmod.ray(start, end, ::solidEnts, true);
    local ray = ppmod.ray(start, end, tmpUseProps, false);

    if (wray.fraction < ray.fraction) return;
    if (!ray.entity) return;

    if (fakeHoldEntity) {
      fakeHoldEntity = null;
      return;
    }

    if (holdableProps.find(ray.entity.GetClassname()) != -1) {
      fakeHoldEntity = ray.entity;
      fakeHoldAngles = ray.entity.GetAngles() - pplayer.eyes.GetAngles();
      fakeHoldEntity.EnableMotion();
      fakeHoldEntity.SetMoveParent(null);
      fakeHoldEntity.Wake();
      fakeHoldEntity.Ragdoll();
    } else {
      ray.entity.Use("", 0.0, player, player);
    }

  };
  SendToConsole("alias +use \"script ::fakeUse()\"");
  SendToConsole("alias +duck");

  local speedmod = Entities.CreateByClassname("player_speedmod");
  speedmod.ModifySpeed(0.0);

  yield ppmod.create("prop_physics_create propPlayer.mdl");
  local propPlayer = yielded;
  propPlayer.targetname = "propPlayer";
  propPlayer.massScale = 2.0;

  player.moveType = 8;
  player.DisableDraw();

  propPlayer.SetOrigin(GetPlayer().GetOrigin() + Vector(0, 0, 36));
  propPlayer.SetAngles(0, 0, 0);

  propPlayer.renderMode = 1;
  propPlayer.renderAmt = 50;

  // if (GetDeveloperLevel()) {
    // propPlayer.renderMode = 1;
    // propPlayer.renderAmt = 50;
  // } else {
    // propPlayer.DisableDraw();
  // }

  player.SetMoveParent(propPlayer);

  propPlayer.ValidateScriptScope();
  local scope = propPlayer.GetScriptScope();
  scope.position <- propPlayer.GetOrigin();
  scope.velocity <- Vector();
  scope.grounded <- true;

  local inputList = {
    forward = false,
    back = false,
    moveleft = false,
    moveright = false,
    jump = false
  };

  foreach (input, val in inputList) {
    pplayer.input("+" + input, function ():(inputList, input) { inputList[input] = true });
    pplayer.input("-" + input, function ():(inputList, input) { inputList[input] = false });
  }

  pplayer.jump(function ():(inputList) {
    inputList.jump = true;
  });

  local pusher = Entities.CreateByClassname("point_push");
  pusher.radius = 8;
  pusher.magnitude = MOVE_MAGNITUDE;
  pusher.spawnflags = 22;
  pusher.Enable();

  local puller = Entities.CreateByClassname("point_push");
  puller.radius = 8;
  puller.magnitude = 0;
  puller.spawnflags = 22;
  puller.Enable();

  local jumppush = Entities.CreateByClassname("point_push");
  jumppush.radius = 8;
  jumppush.magnitude = 0;
  jumppush.spawnflags = 22;
  jumppush.Enable();

  // i just need an entity with eye angles
  local cameraDummy = Entities.CreateByClassname("info_placement_helper");
  cameraDummy.Disable();

  ppmod.interval(function ():(propPlayer, inputList, pusher, puller, jumppush, player, pplayer, cameraDummy) {

    local upvec = propPlayer.GetUpVector();
    local leftvec = propPlayer.GetLeftVector();
    local forwardvec = propPlayer.GetForwardVector();

    pusher.SetOrigin(propPlayer.GetOrigin());
    puller.SetOrigin(propPlayer.GetOrigin());
    jumppush.SetOrigin(propPlayer.GetOrigin());

    local scope = propPlayer.GetScriptScope();
    local newpos = propPlayer.GetOrigin();
    scope.velocity = (newpos - scope.position) / FrameTime();
    scope.position = newpos;

    local corners = [
      newpos + leftvec * 16 + forwardvec * 16 - upvec * 36,
      newpos - leftvec * 16 + forwardvec * 16 - upvec * 36,
      newpos - leftvec * 16 - forwardvec * 16 - upvec * 36,
      newpos + leftvec * 16 - forwardvec * 16 - upvec * 36
    ];

    if (GetDeveloperLevel()) {
      for (local i = 0; i < corners.len(); i ++) {
        DebugDrawBox(corners[i], Vector(-2, -2, -2), Vector(2, 2, 2), 0, 0, 255, 100, -1);
      }
    }

    ::gravityKeyframes.push(upvec);
    local upvecInterp = Vector();
    local gravityKeyframeCount = gravityKeyframes.len();

    for (local i = 0; i < gravityKeyframeCount; i ++) {
      upvecInterp += gravityKeyframes[i];
    }
    if (gravityKeyframeCount > MAX_GRAV_KEYFRAMES) {
      gravityKeyframes.remove(0);
    }
    upvecInterp /= gravityKeyframeCount;
    upvecInterp.Norm();

    if (GetDeveloperLevel()) {
      DebugDrawLine(propPlayer.GetOrigin(), propPlayer.GetOrigin() + upvecInterp * 32, 255, 0, 255, false, -1);
    }

    local prevGrounded = scope.grounded;
    scope.grounded = (
      ppmod.ray(corners[0], corners[0] - upvec * GROUNDED_DISTANCE, ::solidEnts).fraction != 1.0 ||
      ppmod.ray(corners[1], corners[1] - upvec * GROUNDED_DISTANCE, ::solidEnts).fraction != 1.0 ||
      ppmod.ray(corners[2], corners[2] - upvec * GROUNDED_DISTANCE, ::solidEnts).fraction != 1.0 ||
      ppmod.ray(corners[3], corners[3] - upvec * GROUNDED_DISTANCE, ::solidEnts).fraction != 1.0
    );

    if (!prevGrounded && scope.grounded && enforcedRotation) {

      local tang = enforcedRotation;
      enforcedRotation = null;

      local enforceInterval = ppmod.interval(function ():(tang, propPlayer) {
        propPlayer.SetAngles(tang.x, tang.y, tang.z);
      });
      ppmod.fire(enforceInterval, "Kill", "", ENFORCE_ROTATION_TIME_END);

    }

    if (!scope.grounded) inputList.jump = false;

    if (inputList.jump) {
      scope.grounded = false;
      inputList.jump = false;
      jumppush.magnitude = JUMP_MAGNITUDE;
      ppmod.wait(function ():(jumppush) {
        jumppush.magnitude = 0;
      }, FrameTime() * JUMP_TIMER_LENGTH);
    }

    jumppush.SetForwardVector(upvec);

    local speed = scope.velocity.Length2D();

    if (speed > 20.0) {
      local fricdir = projectToPlane(Vector() - scope.velocity, upvec).Normalize();
      puller.SetForwardVector(fricdir);
      if (speed > MOVE_MAXVEL) {
        puller.magnitude = FRICTION_MAGNITUDE;
      } else {
        puller.magnitude = IDLE_FRICTION_MAGNITUDE;
      }
    } else {
      puller.magnitude = 0;
    }

    local wishdir = Vector();

    if (inputList.forward) wishdir += projectToPlane(pplayer.eyes.GetForwardVector(), upvec).Normalize();
    if (inputList.back) wishdir -= projectToPlane(pplayer.eyes.GetForwardVector(), upvec).Normalize();
    if (inputList.moveleft) wishdir -= projectToPlane(pplayer.eyes.GetLeftVector(), upvec).Normalize();
    if (inputList.moveright) wishdir += projectToPlane(pplayer.eyes.GetLeftVector(), upvec).Normalize();

    local wishspeed = wishdir.Norm();
    if (wishspeed != 0.0) {
      pusher.SetForwardVector(wishdir);
      pusher.magnitude = MOVE_MAGNITUDE;
    } else {
      pusher.magnitude = 0;
    }

    player.SetAbsOrigin(propPlayer.GetOrigin() + upvec * 28 - Vector(0, 0, 64));

    if (GetDeveloperLevel()) {
      DebugDrawLine(pplayer.eyes.GetOrigin(), pplayer.eyes.GetOrigin() + pplayer.eyes.GetForwardVector() * 32, 255, 0, 0, false, -1);
      DebugDrawLine(pplayer.eyes.GetOrigin(), pplayer.eyes.GetOrigin() + pplayer.eyes.GetLeftVector() * 32, 0, 255, 0, false, -1);
      DebugDrawLine(pplayer.eyes.GetOrigin(), pplayer.eyes.GetOrigin() + pplayer.eyes.GetUpVector() * 32, 0, 0, 255, false, -1);
    }

    for (local i = 0; i < physProps.len(); i ++) {
      local type = physProps[i], ent = null;
      while (ent = ppmod.get(type, ent)) {

        if (!ent.IsValid()) continue;
        if (!ent.ValidateScriptScope()) continue;

        local scope = ent.GetScriptScope();
        if ("pusher" in scope) continue;

        scope.pusher <- Entities.CreateByClassname("point_push");
        scope.pusher.targetname = "gravitySimulationPusher";
        scope.pusher.radius = 8;
        scope.pusher.magnitude = GRAVITY_MAGNITUDE;
        scope.pusher.spawnflags = 22;
        scope.pusher.SetForwardVector(Vector() - upvecInterp);
        scope.pusher.SetOrigin(ent.GetOrigin());
        scope.pusher.Enable();

        if (!scope.pusher.ValidateScriptScope()) continue;
        local pusherScope = scope.pusher.GetScriptScope();

        pusherScope.pushChild <- ent;
        pusherScope.pos <- Vector();
        pusherScope.vel <- Vector();
        pusherScope.held <- Time();

      }
    }

    local ent = null;
    while (ent = ppmod.get("gravitySimulationPusher", ent)) {

      if (!ent.ValidateScriptScope()) continue;
      local pusherScope = ent.GetScriptScope();

      if (!pusherScope.pushChild.IsValid()) {
        ent.Destroy();
        continue;
      }

      if (pusherScope.pushChild == fakeHoldEntity) {
        ent.magnitude = 0;
        pusherScope.vel = pusherScope.pushChild.GetOrigin() - pusherScope.pos;
        pusherScope.pos = pusherScope.pushChild.GetOrigin();
        pusherScope.held = Time();
      } else {
        if (pusherScope.held + FrameTime() * THROW_TIMER_LENGTH > Time()) {
          ent.SetForwardVector(pusherScope.vel);
          ent.magnitude = pusherScope.vel.Length() * THROW_STRENGTH;
        } else {
          ent.SetForwardVector(Vector() - upvecInterp);
          ent.magnitude = GRAVITY_MAGNITUDE;
        }
      }

      ent.SetOrigin(pusherScope.pushChild.GetOrigin());

      if (pusherScope.pushChild == propPlayer) continue;

      if ((ent.GetOrigin() - propPlayer.GetOrigin()).LengthSqr() < 256) {
        ent.magnitude = 0;
      }

    }

    local cameraAngles = pplayer.eyes.GetAngles();
    local headPosition = ppmod.ray(propPlayer.GetOrigin(), propPlayer.GetOrigin() + upvec * 28).point;
    local cameraPosition = ppmod.ray(headPosition, headPosition - pplayer.eyes.GetForwardVector() * 128, camSolids).point + pplayer.eyes.GetForwardVector() * 8;

    cameraKeyframes.push({
      pos = cameraPosition,
      ang = cameraAngles
    });

    local deltaCameraPos = Vector();
    local deltaCameraAng = Vector();
    local keyframeCount = cameraKeyframes.len();

    for (local i = 0; i < keyframeCount; i ++) {

      local cpos = cameraKeyframes[i].pos;
      local cang = cameraKeyframes[i].ang - cameraAngles;

      if (cang.x < -180) cang.x += 360;
      if (cang.x > 180) cang.x -= 360;
      if (cang.y < -180) cang.y += 360;
      if (cang.y > 180) cang.y -= 360;
      if (cang.z < -180) cang.z += 360;
      if (cang.z > 180) cang.z -= 360;

      deltaCameraPos += cpos;
      deltaCameraAng += cang;

    }
    deltaCameraPos /= keyframeCount;
    deltaCameraAng /= keyframeCount;

    if (keyframeCount > MAX_CAM_KEYFRAMES) {
      cameraKeyframes.remove(0);
    }

    local finalCameraAng = deltaCameraAng + cameraAngles;

    cameraDummy.SetOrigin(deltaCameraPos);
    cameraDummy.SetAngles(finalCameraAng.x, finalCameraAng.y, finalCameraAng.z);

    SendToConsole("cl_view " + cameraDummy.entindex());

    local aimRay = ppmod.ray(pplayer.eyes.GetOrigin(), pplayer.eyes.GetOrigin() + pplayer.eyes.GetForwardVector() * 4096, solidEnts);
    local aimRayUse = ppmod.ray(pplayer.eyes.GetOrigin(), pplayer.eyes.GetOrigin() + pplayer.eyes.GetForwardVector() * 4096, useProps, false);

    local aimingAtUsable = aimRayUse.fraction < aimRay.fraction;
    local aimPoint = aimingAtUsable ? aimRayUse.point : aimRay.point;

    if (!fakeHoldEntity) {
      if (aimingAtUsable) {
        DebugDrawBox(aimPoint, Vector(-2.5, -2.5, -2.5), Vector(2.5, 2.5, 2.5), 255, 255, 255, 25, -1);
      } else if (lastPortalColor == 0) {
        DebugDrawBox(aimPoint, Vector(-2.5, -2.5, -2.5), Vector(2.5, 2.5, 2.5), 120, 120, 120, 255, -1);
      } else if (lastPortalColor == 1) {
        DebugDrawBox(aimPoint, Vector(-2.5, -2.5, -2.5), Vector(2.5, 2.5, 2.5), 80, 120, 255, 255, -1);
      } else if (lastPortalColor == 2) {
        DebugDrawBox(aimPoint, Vector(-2.5, -2.5, -2.5), Vector(2.5, 2.5, 2.5), 255, 120, 80, 255, -1);
      }
    }

  });

  yield ppmod.create("filter_activator_name");
  local filter = yielded;
  filter.targetname = "propPlayer_filter";
  filter.filtername = "propPlayer";
  filter.negated = true;

  ppmod.keyval("trigger_portal_cleanser", "filtername", "propPlayer_filter");

  ppmod.wait(function () {
    SendToConsole("map_wants_save_disable 0");
    SendToConsole("save sla; load sla");
  }, 0.5);

  ppmod.hook("@transition_from_map", "Trigger", function () {

    local currmap = GetMapName().tolower();
    local scriptent = null;

    while (scriptent = ppmod.get("logic_script", scriptent)) {

      if (!scriptent.ValidateScriptScope()) continue;
      local scope = scriptent.GetScriptScope();
      if (!("MapPlayOrder" in scope)) continue;

      local found = false;
      for (local i = 0; i < scope.MapPlayOrder.len(); i ++) {
        if (!found && scope.MapPlayOrder[i] != currmap) continue;
        if (!found) { found = true; continue; }

        if (scope.MapPlayOrder[i][0] == 64) continue;
        SendToConsole("map " + scope.MapPlayOrder[i]);
        return;
      }

    }

    return false;

  });

}));
