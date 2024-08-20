//if ("util" in this) return
/*   CONSTS / GLOBALS   */
::util <- {}


/*   PRETTY ERRORS   */
util.error <- function (source, error) {
    printl(@"

    ==================
     !!!UTIL ERROR!!!
    ==================
    "+source+": "+error+@"

    ")
}

/*   NUMBERS  */
util.max <- function(a, b) return a < b ? b : a
util.min <- function(a, b) return a > b ? b : a

/*   ARRAYS   */
util.array <- {}
util.array.find <- function (array, search) {
    foreach (i,x in array) {
        if (x == search) return i
    }
}

util.array.get_smallest_value <- function(table) {
    local smallestValue = null
    local smallestKey = null
    foreach (key, value in table) {
      if (smallestValue == null || value < smallestValue) {
        smallestValue = value
        smallestKey = key
      }
    }
    return smallestKey
  }


/*   STRING   */
util.string <- {}
util.string.split <- function(string, delimiter) {
    local result = []; local start_index = 0; local delimiter_index = 0

    while ((delimiter_index = string.find(delimiter, start_index)) >= 0) {
        local substring = string.slice(start_index, delimiter_index)
        result.append(substring)
        start_index = delimiter_index + delimiter.len()
    }
    if (start_index < string.len()) {
        local remaining_substring = string.slice(start_index)
        result.append(remaining_substring)
    }
    return result
}

util.string.replace <- function(string, search, replacement) {
    local result = ""; local start_index = 0; local delimiter_index = 0

    while ((delimiter_index = string.find(search, start_index)) >= 0) {
        result += string.slice(start_index, delimiter_index) + replacement
        start_index = delimiter_index + search.len()
    }
    result += string.slice(start_index)
    return result
}


/*   SAVE   */
util.save <- {}
util.save.get_regex <- function (slot) {
    return regexp("<"+slot+">.*</"+slot+">")
}

util.save.write_slot <- function(data,slot) {
    local saves = GetPlayer().GetName()
    local formatted = data != "" && "<"+slot+">"+data+"</"+slot+">" || ""
    if (saves == "") {GetPlayer().__KeyValueFromString("targetname", formatted); return}
    local search = util.save.get_regex(slot).search(saves)
    GetPlayer().__KeyValueFromString("targetname", search != null
    ? util.string.replace(saves, saves.slice(search.begin, search.end), formatted)
    : saves + formatted)
}

util.save.read_slot <- function(slot) {
    local saves = GetPlayer().GetName()
    local search = util.save.get_regex(slot).search(saves)
    return search != null ? saves.slice(search.begin + 2 + (""+slot).len(),search.end - 3 - (""+slot).len()) : null
}

/*  UNIT TEST  */
util.unit_test <- function () {
    printl("-")
    printl("string.split")
    local split = util.string.split("hello, util, world",", ")
    foreach (y in split) {
        printl(y)
    }

    printl("-")
    printl("\nstring.replace")
    local replacement = util.string.replace("hello util world"," util", ",")
    printl("result: " + replacement)

    printl("-")
    printl("\nsaves")
    GetPlayer().__KeyValueFromString("targetname", "")
    util.save.write_slot("slot 0 test",0)
    util.save.write_slot("slot 5 test",5)
    printl(util.save.read_slot(0))
    printl(util.save.read_slot(5))
    util.save.write_slot("slot override test",0)
    printl(util.save.read_slot(0))
    util.save.write_slot("",0)
    util.save.write_slot("test test",5)
    printl(util.save.read_slot(0))
    printl(util.save.read_slot(5))
}