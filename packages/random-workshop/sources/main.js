// Address of the server we're querying maps from (Epochtal deployment)
const HTTP_ADDRESS = "https://epochtal.p2r3.com";

/**
 * Utility funtion, checks if the given file path exists
 * @param {string} path Path to the file or directory, relative to tempcontent
 * @returns {boolean} True if the path exists, false otherwise
 */
function pathExists (path) {
  try { fs.rename(path, path) }
  catch (e) {
    return e.toString() == "Error: fs.rename: New path already occupied";
  }
  return true;
}

do { // Attempt connection with the game's console
  var gameSocket = game.connect();
  sleep(200);
} while (gameSocket === -1);

console.log("Connected to Portal 2 console.");

/**
 * Utility function, cleans up any open sockets and throws an error.
 * This is useful for when the game has closed or when an otherwise
 * critical issue requires us to stop the script.
 */
function doCleanup () {
  // Disconnect from the game's console
  if (gameSocket !== -1) game.disconnect(gameSocket);
  // Throw an error to terminate the script
  throw new Error("Cleanup finished, terminating script.");
}

/**
 * Utility funtion, attempts to read a command from the console. On failure,
 * attempts to reconnect to the socket.
 * @param {number} socket Game socket file descriptor (index)
 * @param {number} bytes How many bytes to request from the socket
 */
function readFromConsole (socket, bytes) {
  try {
    return game.read(socket, bytes);
  } catch (e) {
    console.error(e);
    // Attempt to reconnect to the game's console
    do {
      if (!game.status()) doCleanup();
      var gameSocket = game.connect();
      sleep(200);
    } while (gameSocket === -1);
    return readFromConsole(gameSocket, bytes);
  }
}

/**
 * Utility funtion, attempts to write a command to the console. On failure,
 * attempts to reconnect to the socket.
 * @param {number} socket Game socket file descriptor (index)
 * @param {number} command Command to send to the console
 */
function sendToConsole (socket, command) {
  try {
    return game.send(socket, command);
  } catch (e) {
    console.error(e);
    // Attempt to reconnect to the game's console
    do {
      if (!game.status()) doCleanup();
      var gameSocket = game.connect();
      sleep(200);
    } while (gameSocket === -1);
    return sendToConsole(gameSocket, command);
  }
}

/**
 * Checks whether the player has the right spplice-cpp version and throws
 * a warning if not.
 */
function processVersionCheck () {
  // Use existence of game.status as a heuristic for spplice-cpp version
  if (!("status" in game)) {
    sendToConsole(gameSocket, 'disconnect "Epochtal Live requires the latest version of SppliceCPP. Update here: github.com/p2r3/spplice-cpp/releases"');
    doCleanup();
  }
}

// User's SteamID as returned by loading a save
var steamid = "";
// URL for the last played map
var currentMapURL = "";
// Next precached map in form { path, url }
var nextMap = null;
// Counter for calls of processConsoleOutput
var consoleTick = 0;
// Store the last partially received line until it can be processed
var lastLine = "";
// Whether to permit making saves at the start of the next load
var makeStartSaves = false;
// Co-op partner's SteamID, set only if playing co-op
var steamidPartner = "";
// Whether I and/or my partner have fetched the next map
var meReadyForNextMap = false, partnerReadyForNextMap = false;
// If true, disables additional requests to prevent concurrent queries
var fetchingCoopMap = false;
var startingCoopSession = false;

/**
 * Processes output from the Portal 2 console
 */
function processConsoleOutput () {

  // Increment this function's call counter
  consoleTick ++;

  /**
   * Every 5th console tick, check if the game is still running, and if
   * not, terminate the script. In most cases, this would've already been
   * caught earlier, but we run it here too just to be safe.
   */
  if (consoleTick % 5 === 0 && !game.status()) doCleanup();

  // Receive 1024 bytes from the game console socket
  const buffer = readFromConsole(gameSocket, 1024);
  // If we received nothing, don't proceed
  if (buffer.length === 0) return;

  try {
    // Add the latest buffer to any partial data we had before
    lastLine += buffer;
  } catch (_) {
    // Sometimes, the buffer can't be string-coerced for some reason
    return;
  }

  // Parse output line-by-line
  const lines = lastLine.split("\n");
  lines.forEach(function (line) {

    // Process request for a new random map
    if (line.indexOf("Fetching a random map...") !== -1) {
      // This is a singleplayer request - clear co-op partner
      steamidPartner = "";
      // Print the URL for the last map played (fall back to server query if not stored here)
      const finishedMapURL = currentMapURL || getLastPlayedMapURL();
      if (finishedMapURL) sendToConsole(gameSocket, 'echo "Previous map\'s URL: ' + finishedMapURL + '";echo;echo');
      // Start a cached map if available, download a new one otherwise
      makeStartSaves = true;
      startMap(nextMap ? nextMap : forceRandomMap(false), false);
      // Precache the next random map
      sleep(200);
      nextMap = forceRandomMap(false);
      return;
    }

    // Process request to load next co-op map as host
    if (line.indexOf("You are the host. Initiating map request...") === 0) {
      // The host loads the next map, but *does not start it*.
      // Both players then start the "previous" map once they're ready.
      forceRandomMap(false);
      sendToConsole(gameSocket, "say Fetching a random co-op map...");
      return;
    }

    // Process request for a new random co-op map
    if (line.indexOf("Fetching a random co-op map...") !== -1) {
      // Exit early if we're already fetching a map
      if (fetchingCoopMap) return;
      fetchingCoopMap = true;
      // Pause the speedrun timer during the load
      // Normally, we'd pause the game, but that doesn't work in co-op
      sendToConsole(gameSocket, "sar_speedrun_pause");
      // Clear player ready states from last map
      meReadyForNextMap = false, partnerReadyForNextMap = false;
      // Print the URL for the last map played (fall back to server query if not stored here)
      const finishedMapURL = currentMapURL || getLastPlayedMapURL();
      if (finishedMapURL) sendToConsole(gameSocket, 'echo "Previous map\'s URL: ' + finishedMapURL + '";echo;echo');
      // Fetch the "previous" map - the host will have updated it
      nextMap = forceRandomMap(true)[0];
      startMap(nextMap, true);
      return;
    }

    // Process request for continuing from last map
    if (line.indexOf("Fetching last played map...") !== -1) {
      // This is a singleplayer request - clear co-op partner
      steamidPartner = "";
      // Get player's previously fetched maps
      const paths = forceRandomMap(true);
      // If the primary map is not available, display error and exit early
      if (!paths[0]) return sendToConsole(gameSocket, 'disconnect "No previous map queries found."');
      // Start primary map, store next map
      makeStartSaves = false;
      startMap(paths[0], false);
      nextMap = paths[1];
      return;
    }

    // Extract user's SteamID from save file path
    if (line.indexOf("Loading game from ") === 0) {
      try {
        const extracted = line.indexOf("SAVE/") === -1 ? line.split("\\")[1] : line.split("/")[1];
        if (extracted) {
          // If this is our first time getting the SteamID, load special map
          // The VScript will drop the player out to the menu
          const prevSteamID = steamid;
          steamid = extracted.trim();
          sleep(200);
          if (!prevSteamID) return sendToConsole(gameSocket, 'map SP_A5_CREDITS');
        }
      } catch (e) { }
      return;
    }

    // Process request for creating save files on map start to prevent users
    // from accidentally loading into a different map, and to help them load
    // back into the current map if they do.
    if (makeStartSaves && line.indexOf("elMakeSaves") === 0) {
      makeStartSaves = false;
      sendToConsole(gameSocket, "save quick");
      sendToConsole(gameSocket, "save autosave");
      return;
    }

    // Handle flushing soundemitter in co-op
    if (line.indexOf("Running sv_soundemitter_flush...") !== -1) {
      sendToConsole(gameSocket, "sv_soundemitter_flush");
      return;
    }

    /**
     * Handle handshake of co-op session:
     *
     * Both players send each other their SteamIDs. Once a player receives
     * an ID that isn't theirs (so, their partner's), they save it and run
     * a command that will only execute if they're the host. This command
     * then fetches a random map and begins gameplay.
     */
    if (line.indexOf(": Starting co-op RTI session...") !== -1) {
      if (startingCoopSession) return;
      startingCoopSession = true;
      if (!steamid) {
        sendToConsole(gameSocket, 'disconnect "Failed to obtain your SteamID. Try loading a save in singleplayer, then try again."');
        return;
      }
      sendToConsole(gameSocket, "say My SteamID is " + steamid);
      return;
    }
    if (line.indexOf(": My SteamID is ") !== -1) {
      startingCoopSession = false;
      const extracted = line.slice(line.indexOf(": My SteamID is ") + 16).trim();
      // Ignore our own SteamID
      if (extracted === steamid) return;
      if (!extracted) {
        sendToConsole(gameSocket, 'disconnect "Failed to parse partner\'s SteamID."');
        return;
      }
      steamidPartner = extracted;
      // Since this is a `script` command, it'll only run on the host's end
      // This will finish the "handshake" and start loading a map
      sendToConsole(gameSocket, 'script ::__elFinish()');
      return;
    }

    // Handle acknowledgement from partner to start the next map
    if (steamidPartner && line.indexOf(": Ready for next map (" + steamidPartner + ")") !== -1) {
      partnerReadyForNextMap = true;
      if (meReadyForNextMap) startMap(nextMap, true);
      return;
    }

    if (line.indexOf("Redownloading all lightmaps") !== -1) {
      startingCoopSession = false;
      fetchingCoopMap = false;
      return;
    }

  });

  // Store the last entry of the array as a partially received line
  lastLine = lines[lines.length - 1];

}

// Starts a map from the given path
function startMap (data, coop) {
  // Reset persistent cvars
  sendToConsole(gameSocket, "sv_allow_mobile_portals 0");
  sendToConsole(gameSocket, "map_wants_save_disable 0");
  sendToConsole(gameSocket, "r_portal_use_pvs_optimization 1");
  sendToConsole(gameSocket, "sv_cheats 0");
  // Set and load next map
  currentMapURL = data.url;
  // In single-player, just launch the map right away
  // In co-op, first verify that our partner also has the map
  if (coop) {
    if (!meReadyForNextMap) {
      sendToConsole(gameSocket, "say Ready for next map (" + steamid + ")");
      meReadyForNextMap = true;
    }
    if (partnerReadyForNextMap) {
      // This will only go through if we're the host
      sendToConsole(gameSocket, 'script SendToConsole("select_map \\"' + data.path + '\\"")');
    }
  } else {
    return sendToConsole(gameSocket, 'disconnect;map "' + data.path + '"');
  }
}

/**
 * Fetches map data from server and parses it as JSON.
 * @param {boolean} previous Whether to get the previously downloaded maps
 */
function getWorkshopperJson (previous) {
  const endpoint = previous ? "randomsource" : "random";
  // For SP games, just use the client's SteamID.
  // For co-op, use string "<smallest ID>+<biggest ID>".
  const steamidString = steamidPartner ?
    (steamid < steamidPartner ?
      (steamid + "+" + steamidPartner) : (steamidPartner + "+" + steamid)
    ) : steamid;
  console.log(HTTP_ADDRESS + "/api/workshopper/" + endpoint + '/"' + steamidString + '"');
  const json = download.string(HTTP_ADDRESS + "/api/workshopper/" + endpoint + '/"' + steamidString + '"');
  return JSON.parse(json);
}

/**
 * Gets the workshop URL for the last map the user played.
 * Does not download map files.
 * @returns {string} URL or "" if unavailable
 */
function getLastPlayedMapURL () {
  try {
    const data = getWorkshopperJson(true);
    return "https://steamcommunity.com/sharedfiles/filedetails/?id=" + data[0].publishedfileid;
  } catch (e) {
    return "";
  }
}

// Wrapper for getRandomMap - retries until the procedure succeeds
function forceRandomMap (previous) {
  try {
    return getRandomMap(previous);
  } catch (e) {
    sendToConsole(gameSocket, 'echo "Download error: ' + e.toString() + '"');
    sendToConsole(gameSocket, 'echo "Retrying..."');
    sleep(1000);
    return forceRandomMap(previous);
  }
}

/**
 * Fetches and downloads random maps from the server. Optionally, can be
 * used to retrieve the last two queried entries.
 *
 * @param {boolean} previous Whether to get the previously downloaded maps
 * @returns {object|object[]} Downloaded map URL(s) and path(s) for use with "map" command
 */
function getRandomMap (previous) {

  const data = getWorkshopperJson(previous);

  // Depending on the type of query, download either one or two maps
  if (previous) {
    return [downloadMap(data[0]), downloadMap(data[1])];
  } else return downloadMap(data);

}

/**
 * Downloads a workshop map from the given data object.
 *
 * @param {object} data Map data from the Steam API
 * @returns {object} Downloaded map URL and path for use with "map" command
 */
function downloadMap (data) {

  // Construct workshop page URL
  const pageURL = "https://steamcommunity.com/sharedfiles/filedetails/?id=" + data.publishedfileid;

  // Extract the workshop folder and BSP name from map data
  const pathWorkshop = data.file_url.split("/ugc/").pop().split("/")[0];
  const pathBSP = data.filename.split("/").pop().slice(0, -4);

  // Construct all of the path types we'll need
  const workshopDir = "maps/workshop/" + pathWorkshop;
  const fullPath = workshopDir + "/" + pathBSP + ".bsp";
  const outputPath = "workshop/" + pathWorkshop + "/" + pathBSP;

  // Check if we already have the map
  if (pathExists(fullPath)) return { path: outputPath, url: pageURL };

  // Ensure the parent path exists
  if (!pathExists(workshopDir)) fs.mkdir(workshopDir);

  try {
    // Perform the download
    download.file(fullPath, data.file_url);
    // Return the map path for use with the "map" command
    return { path: outputPath, url: pageURL };
  } catch (err) {
    // On error, remove the partially downloaded file
    if (pathExists(fullPath)) fs.unlink(fullPath);
    // Re-throw the error
    throw err;
  }

}

// Attempts to retrieve the SteamID by loading an invalid save
function processSteamID () {
  if (steamid) return;
  sendToConsole(gameSocket, "load .");
}

// Run each processing function on an interval
while (true) {
  processVersionCheck();
  processSteamID();
  processConsoleOutput();
  sleep(20);
}
