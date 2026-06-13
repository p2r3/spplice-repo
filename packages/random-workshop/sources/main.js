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
// File path for the next precached map
var nextMap = "";
// Counter for calls of processConsoleOutput
var consoleTick = 0;
// Store the last partially received line until it can be processed
var lastLine = "";
// Whether to permit making saves at the start of the next load
var makeStartSaves = false;

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
      // Print the URL for the last map played (fall back to server query if not stored here)
      const finishedMapURL = currentMapURL || getLastPlayedMapURL();
      if (finishedMapURL) sendToConsole(gameSocket, 'echo "Previous map\'s URL: ' + finishedMapURL + '";echo;echo');
      // Start a cached map if available, download a new one otherwise
      makeStartSaves = true;
      startMap(nextMap ? nextMap : forceRandomMap(false));
      // Precache the next random map
      sleep(200);
      nextMap = forceRandomMap(false);
      return;
    }

    // Process request for continuing from last map
    if (line.indexOf("Fetching last played map...") !== -1) {
      // Get player's previously fetched maps
      const paths = forceRandomMap(true);
      // If the primary map is not available, display error and exit early
      if (!paths[0]) return sendToConsole(gameSocket, 'disconnect "No previous map queries found."');
      // Start primary map, store next map
      makeStartSaves = false;
      startMap(paths[0]);
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
          steamid = extracted;
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
      // Make second batch (e.g., quick01) after 1 second
      sleep(1000);
      sendToConsole(gameSocket, "save quick");
      sendToConsole(gameSocket, "save autosave");
      return;
    }

  });

  // Store the last entry of the array as a partially received line
  lastLine = lines[lines.length - 1];

}

// Starts a map from the given path
function startMap (data) {
  // Reset persistent cvars
  sendToConsole(gameSocket, "sv_allow_mobile_portals 0");
  sendToConsole(gameSocket, "map_wants_save_disable 0");
  sendToConsole(gameSocket, "r_portal_use_pvs_optimisation 1");
  sendToConsole(gameSocket, "sv_soundemitter_flush");
  sendToConsole(gameSocket, "sv_cheats 0");
  // Set and load next map
  currentMapURL = data.url;
  return sendToConsole(gameSocket, 'disconnect;map "' + data.path + '"');
}

/**
 * Fetches map data from server and parses it as JSON.
 * @param {boolean} previous Whether to get the previously downloaded maps
 */
function getWorkshopperJson (previous) {
  const endpoint = previous ? "randomsource" : "random";
  const json = download.string(HTTP_ADDRESS + "/api/workshopper/" + endpoint + '/"' + steamid + '"');
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
