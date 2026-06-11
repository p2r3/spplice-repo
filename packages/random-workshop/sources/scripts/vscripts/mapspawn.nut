// This print statement is found in the original mapspawn.nut file
// There's no reason to keep it, other than to maintain normal console output
printl("==== calling mapspawn.nut");

// Ensure we're running on the server's script scope
if (!("Entities" in this)) return;

// The entrypoint function - called once entity I/O has initialized
::__elInit <- function () {
  if ("__elInitFlag" in this) return;
  ::__elFirstInit();
};

// Called only once on the initial map load
::__elFirstInit <- function () {
  ::__elInitFlag <- true;

  // Wait for the player to become available by recursing with a delay
  if (!GetPlayer()) {
    EntFireByHandle(Entities.First(), "RunScriptCode", "::__elFirstInit()", FrameTime(), null, null);
    return;
  }

  // The uppercase credits map is used as a way to return to a functioning menu
  if (GetMapName() == "SP_A5_CREDITS") {
    EntFire("credits", "Kill");
    EntFire("credits_music", "Kill");
    EntFire("logic_script", "Kill");
    EntFireByHandle(Entities.First(), "RunScriptCode", "SendToConsole(\"fadeout 0\")", FrameTime(), null, null);
    EntFireByHandle(Entities.First(), "RunScriptCode", "SendToConsole(\"disconnect\")", 1.0, null, null);
    return;
  }

  // Connect outputs to run finish events
  EntFire("@relay_pti_level_end", "AddOutput", "OnTrigger !self:RunScriptCode:__elFinish():0.1:1");
  EntFire("@changelevel", "AddOutput", "OnChangeLevel !self:RunScriptCode:__elFinish():0.2:1");
  ::RequestMapRating <- ::__elFinish;

  // Fix BEEmod maps with pellet dependency
  local pelletWarning = Entities.FindByName(null, "@stop_for_pellets");
  if (pelletWarning) pelletWarning.Destroy();

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
    newRelay.__KeyValueFromString("Targetname", "doorexit1-relay_leaving_level");
    if (newRelay.ValidateScriptScope()) {
      local scope = newRelay.GetScriptScope();
      scope["InputEnable"] <- function ():(existingRelayName) {
        EntFire(existingRelayName, "Enable");
      };
      scope["Inputenable"] <- scope["InputEnable"];
    }
  }

  // End run on PeTI restart trigger
  local restartTrigger = Entities.FindByName(null, "@preview_restart_trigger");
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
  local restartText = Entities.FindByName(null, "@preview_complete_message");
  if (!restartText) restartText = Entities.FindByName(null, "preview_complete_message");
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
  local playtestText = Entities.FindByName(null, "@end_of_playtest_text");
  if (!playtestText) playtestText = Entities.FindByName(null, "end_of_playtest_text");
  if (playtestText) if (playtestText.ValidateScriptScope()) {
    local scope = playtestText.GetScriptScope();
    scope["InputDisplay"] <- function () {
      ::__elFinish();
      return false;
    };
    scope["Inputdisplay"] <- scope["InputDisplay"];
  }

};

::__elFinishLock <- false;
// Called when the map end condition is reached
::__elFinish <- function () {
  // Overwrite this function with a no-op to prevent repeat calls
  ::__elFinish <- function () { };
  if (__elFinishLock) return;
  ::__elFinishLock <- true;
  // Print this message as a signal to JS API that we need the next map
  printl("\n\nFetching a random map...");
  // Silently pause the game while the map is loaded
  SendToConsole("setpause nomsg");
};

// Run the entrypoint function as soon as entity I/O kicks in
EntFireByHandle(Entities.First(), "RunScriptCode", "::__elInit()", 0.0, null, null);
