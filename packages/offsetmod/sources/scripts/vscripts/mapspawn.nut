if (!("Entities" in this)) return;
IncludeScript("ppmod4");

::ghostOffset <- Vector();
::ghostMode <- 0;

::ghostSolidEnts <- ["phys_bone_follower", "func_brush", "prop_weighted_cube"];
::checkPlayerPosition <- function (pos) {

  local ray1 = ppmod.ray(pos + Vector(-16, -16, 0), pos + Vector(16, 16, 72), ::ghostSolidEnts);
  local ray2 = ppmod.ray(pos + Vector(16, 16, 0), pos + Vector(-16, -16, 72), ::ghostSolidEnts);
  local ray3 = ppmod.ray(pos + Vector(16, -16, 0), pos + Vector(-16, 16, 72), ::ghostSolidEnts);
  local ray4 = ppmod.ray(pos + Vector(-16, 16, 0), pos + Vector(16, -16, 72), ::ghostSolidEnts);

  return ray1.fraction == 1.0 && ray2.fraction == 1.0 && ray3.fraction == 1.0 && ray4.fraction == 1.0;

};

::playSoundLoud <- function (sound) {

  SendToConsole("snd_playsounds " + sound);
  SendToConsole("snd_playsounds " + sound);

};

::ghostSwap <- function () {

  ::ghostMode ++;

  if (::ghostMode == 1) {

    ::ghostOffset <- GetPlayer().GetOrigin();

    ::playSoundLoud("P2Editor.ExpandButton");

  } else if (::ghostMode == 2) {
    
    ::ghostOffset = GetPlayer().GetOrigin() - ::ghostOffset;
    GetPlayer().SetAbsOrigin(GetPlayer().GetOrigin() - ::ghostOffset);
    
    ::playSoundLoud("P2Editor.ConnectItems");

  } else {

    local newpos = GetPlayer().GetOrigin() + ::ghostOffset;
    if (!::checkPlayerPosition(newpos)) {
      ::ghostMode --;
      ::playSoundLoud("P2Editor.Correction");
      return;
    }

    GetPlayer().SetAbsOrigin(newpos);
    SendToConsole("debug_fixmyposition");
    ::ghostMode = 0;

    ::playSoundLoud("P2Editor.CollapseButton");

  }

  GetPlayer().targetname = "::ghostMode<-" + ::ghostMode + ";::ghostOffset<-" + ::ghostOffset;

};

ppmod.onauto(function () {

  SendToConsole("alias +mouse_menu \"script ::ghostSwap()\"");

  compilestring(GetPlayer().GetName())();

  local mapname = GetMapName().tolower();

  if (mapname == "sp_a1_intro3") {

    ppmod.get(Vector(25.23, 1958.72, -299.0), 32, "trigger_once").Destroy();
    ppmod.fire("portalgun*", "Kill");
    ppmod.fire("snd_gun_zap", "Kill");

  } else if (mapname == "sp_a2_intro") {

    ppmod.fire("portalgun*", "Kill");
    ppmod.fire("snd_gun_zap", "Kill");
    ppmod.fire("player_near_portalgun", "Kill");

  }

  ppmod.interval(function () {

    if (::ghostMode == 1) {

      DebugDrawBox(::ghostOffset, Vector(-16, -16, 0), Vector(16, 16, 72), 255, 110, 0, 60, -1);
    } else if (::ghostMode == 2) {

      local newpos = GetPlayer().GetOrigin() + ::ghostOffset;
      
      if (::checkPlayerPosition(newpos)) {
        DebugDrawBox(newpos, Vector(-16, -16, 0), Vector(16, 16, 72), 80, 255, 80, 60, -1);
      } else {
        DebugDrawBox(newpos, Vector(-16, -16, 0), Vector(16, 16, 72), 255, 30, 0, 60, -1);
      }

    }

    ppmod.fire("prop_portal", "SetActivatedState", 0);
    ppmod.fire("viewmodel", "DisableDraw");
    ppmod.fire("weapon_portalgun", "Kill");

  });

});

ppmod.onauto(function () {

  SendToConsole("player_held_object_use_view_model 1");

}, true);
