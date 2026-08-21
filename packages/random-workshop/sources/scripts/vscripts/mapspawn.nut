// Ensure we're running on the server's script scope
if (!("Entities" in this)) return;
IncludeScript("ppmod");

// This print statement is found in the original mapspawn.nut file
// There's no reason to keep it, other than to maintain normal console output
printl("==== calling mapspawn.nut");

// Called only once on the initial map load
ppmod.onauto(function () {

  // The uppercase credits map is used as a way to return to a functioning menu
  if (GetMapName() == "SP_A5_CREDITS") {
    ppmod.fire("credits", "Kill");
    ppmod.fire("credits_music", "Kill");
    ppmod.fire("logic_script", "Kill");
    ppmod.wait(function () {
      SendToConsole("fadeout 0");
    }, FrameTime());
    ppmod.wait(function () {
      SendToConsole("disconnect");
    }, 1.0);
    return;
  }

  // Detect co-op start, set up co-op session
  if (
    GetMapName().tolower() == "mp_coop_lobby_2" ||
    GetMapName().tolower() == "mp_coop_lobby_3" ||
    GetMapName().tolower() == "mp_coop_start"
  ) {
    SendToConsole("say \" Starting co-op RTI session...\"");
    return;
  }

  // Connect outputs to run finish events
  ppmod.addscript("@relay_pti_level_end", "OnTrigger", "::__elFinish()", 0.1, 1);
  ppmod.addscript("@changelevel", "OnChangeLevel", "::__elFinish()", 0.2, 1);
  ::RequestMapRating <- ::__elFinish;

  // Fix BEEmod maps with pellet dependency
  ppmod.forent("@stop_for_pellets", function (pelletWarning) {
    if (!ppmod.validate(pelletWarning)) return;
    pelletWarning.Destroy();
  });

  // Fix broken PeTI exit airlock door in maps last updated in June 2012
  IncludeScript("june_2012_airlock_fixup");
  local mapName = GetMapName();
  local mapKey = mapName.slice(9); // 9 is the length of "workshop/"
  local indexOfBackslash = mapKey.find("\\");
  if (indexOfBackslash != null) {
    mapKey = mapKey.slice(0, indexOfBackslash) + "/" + mapKey.slice(indexOfBackslash + 1);
  }
  if (mapKey in ::__elAirlockFixupTable) {
    local existingRelayIdx = ::__elAirlockFixupTable[mapKey];
    local existingRelayName = "InstanceAuto" + existingRelayIdx + "-relay_leaving_level";
    local newRelay = Entities.CreateByClassname("logic_relay");
    local hookFunction = function ():(existingRelayName) {
      ppmod.fire(existingRelayName, "Enable");
    };
    newRelay.targetname = "doorexit1-relay_leaving_level";
    ppmod.hook(newRelay, "Enable", hookFunction);
    ppmod.hook(newRelay, "enable", hookFunction);
  }

  // End run on PeTI restart trigger
  local restartTrigger = ppmod.get("@preview_restart_trigger");
  if (restartTrigger) {
    local hookFunction = function ():(restartTrigger) {
      if (activator == restartTrigger || caller == restartTrigger) {
        ::__elFinish();
        return false;
      }
      return true;
    };
    for (local i = 0; i < 3; i ++) {
      local commandClass = ["point_clientcommand", "point_servercommand", "point_broadcastclientcommand"][i];
      local ent = null;
      while (ent = Entities.FindByClassname(ent, commandClass)) {
        if (!ent.IsValid()) continue;
        if (!ent.ValidateScriptScope()) continue;
        ent.GetScriptScope()["InputCommand"] <- hookFunction;
        ent.GetScriptScope()["Inputcommand"] <- hookFunction;
      }
    }
  }
  // Slightly more rigorous check for PeTI restart text
  local restartText = ppmod.get("@preview_complete_message");
  if (!restartText) restartText = ppmod.get("preview_complete_message");
  if (restartText) if (restartText.ValidateScriptScope()) {
    local scope = restartText.GetScriptScope();
    scope["InputDisplay"] <- function () {
      ::__elFinish();
      EntFire("point_clientcommand", "Kill");
      EntFire("point_servercommand", "Kill");
      EntFire("point_broadcastclientcommand", "Kill");
      return false;
    };
    scope["Inputdisplay"] <- scope["InputDisplay"];
  }

  // End run on "End of playtest" text
  local playtestText = ppmod.get("@end_of_playtest_text");
  if (!playtestText) playtestText = ppmod.get("end_of_playtest_text");
  if (playtestText) if (playtestText.ValidateScriptScope()) {
    local scope = playtestText.GetScriptScope();
    scope["InputDisplay"] <- function () {
      ::__elFinish();
      return false;
    };
    scope["Inputdisplay"] <- scope["InputDisplay"];
  }

  // Create saves one second after the run starts
  if (!IsMultiplayer()) {
    ppmod.wait(function () {
      printl("elMakeSaves");
    }, 1.0);
  }

  // Fix any residual custom sounds
  if (IsMultiplayer()) {
    // This command isn't permitted to run from scripts in co-op,
    // so we signal to Spplice to run it for both clients.
    SendToConsole("say \" Starting map...\"");
  } else {
    SendToConsole("sv_soundemitter_flush");
  }

  // Prevent restarting the map after finishing the level in co-op
  if (IsMultiplayer()) {
    local levelEndRelay = ppmod.get("@relay_pti_level_end");
    if (levelEndRelay) if (levelEndRelay.ValidateScriptScope()) {
      local scope = levelEndRelay.GetScriptScope();
      printl("balalala");
      scope["InputTrigger"] <- function () {
        ::__elFinish();
        ppmod.forent("point_clientcommand", function (ent) { ent.Destroy() });
        ppmod.forent("point_servercommand", function (ent) { ent.Destroy() });
        ppmod.forent("point_broadcastclientcommand", function (ent) { ent.Destroy() });
        ppmod.forent("point_changelevel", function (ent) { ent.Destroy() });
        ppmod.forent("trigger_changelevel", function (ent) { ent.Destroy() });
        ppmod.forent("trigger_transition", function (ent) { ent.Destroy() });
        return false;
      };
      scope["Inputtrigger"] <- scope["InputTrigger"];
    }
  }

});

::__elFinishLock <- false;
// Called when the map end condition is reached
::__elFinish <- function () {
  // Overwrite this function with a no-op to prevent repeat calls
  ::__elFinish <- function () { };
  if (__elFinishLock) return;
  ::__elFinishLock <- true;
  if (!IsMultiplayer()) {
    // Print this message as a signal to JS API that we need the next map
    printl("\n\nFetching a random map...");
    // Silently pause the game while the map is loaded
    SendToConsole("setpause nomsg");
  } else {
    printl("\n\nYou are the host. Initiating map request...");
  }
};
