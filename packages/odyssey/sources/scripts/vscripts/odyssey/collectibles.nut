smo.moon <- {
  mdl = "moon.mdl",
  size = 0.5,
  ang = 0,
  table = [],
  char = "•",
  bgstr = " Moons: ",
  str = "",
  chapternum = 0
};

smo.moon.setup <- function() {

  local storage = GetPlayer().GetName();

  if (storage.len() != 0) {

    smo.moon.odyssey.enabled = storage[0] == 'T' ? 1 : 0;

    for (local i = 1; i < storage.len(); i ++) {
      if (storage[i] == '1') smo.moon.table.push(i-1);
    }

  }
  
  foreach (curr in smo.moon.table) {
    if (smo.moonlist[curr].map == GetMapName().tolower()) {
      smo.moon.str += smo.moon.char;
    }
  }

  foreach (index, curr in smo.moonlist) {
    if (curr.map == GetMapName().tolower()) {
      smo.moon.create(index);
    }
  }

  foreach (index, chapter in smo.moon.chapters) {
    foreach (map in chapter) {

      if (map == GetMapName().tolower()) {
        smo.moon.chapternum = index;
      }

    }
  }

  local txt_bg = ppmod.text("", 0, 1);
  txt_bg.SetColor("70 70 70");
  txt_bg.SetChannel(5);

  local txt_fg = ppmod.text("", 0, 1);
  txt_fg.SetColor("100 150 200");

  ppmod.interval(function(txt = [txt_fg, txt_bg]) {

    if (smo.moon.bgstr.len() <= 8) return;

    txt[0].SetText(" Moons: " + smo.moon.str);
    txt[0].Display();
    txt[1].SetText(smo.moon.bgstr);
    txt[1].Display();

    smo.moon.ang = (smo.moon.ang + 7) % 360;
    
  }, 0, "smo_moon_interval");

  ppmod.wait(function() {

    local endtrig = null;

    switch (GetMapName().tolower()) {

      case "sp_a1_intro7" : endtrig = ppmod.trigger(Vector(-2208, 244, 1279), Vector(96, 29, 63)); break;
      case "sp_a1_wakeup" : endtrig = ppmod.trigger(Vector(10381, 1212, 313), Vector(110, 127, 42)); break;
      case "sp_a2_bts1" : endtrig = ppmod.trigger(Vector(831, -1206, 151), Vector(65, 54, 215)); break;
      case "sp_a2_bts2" : endtrig = ppmod.trigger(Vector(2208, 1725, 728), Vector(64, 50, 103)); break;
      case "sp_a2_bts3" : endtrig = ppmod.trigger(Vector(5954, 4792, -1662), Vector(62, 54, 130)); break;
      case "sp_a2_bts4" : endtrig = ppmod.trigger(Vector(-3911, -7233, 6432), Vector(51, 63, 160)); break;
      case "sp_a2_bts5" : endtrig = ppmod.trigger(Vector(2472, 672, 4417), Vector(17, 32, 65)); break;
      case "sp_a2_core" : endtrig = ppmod.trigger(Vector(1, 304, -9752), Vector(81, 81, 233)); break;
      case "sp_a3_01"   : endtrig = ppmod.trigger(Vector(5860, 4524, -419), Vector(84, 76, 85)); break;
      case "sp_a3_portal_intro"   : endtrig = ppmod.trigger(Vector(3839, 239, 5694), Vector(64, 31, 62)); break;
      case "sp_a4_laser_platform" : endtrig = ppmod.trigger(Vector(3472, -1055, -2437), Vector(110, 127, 42)); break;

    }

    if (!endtrig) {

      local ent = null, elevatordist = 0, lastelevator = null, trigz = 1024;
      while (ent = ppmod.get("models/elevator/elevator_b.mdl", ent)) {

        local dist = (GetPlayer().GetOrigin() - ent.GetOrigin()).LengthSqr();
        if (dist >= elevatordist) {
          elevatordist = dist;
          lastelevator = ent;
        } 

      }

      while (ent = ppmod.get("models/props_underground/elevator_a.mdl", ent)) {

        local dist = (GetPlayer().GetOrigin() - ent.GetOrigin()).LengthSqr();
        if (dist >= elevatordist) {
          elevatordist = dist;
          lastelevator = ent;
          trigz = 128;
        }

      }

      if (lastelevator) {
        endtrig = ppmod.trigger(lastelevator.GetCenter(), Vector(128, 128, trigz));
        ppmod.fire(endtrig, "SetParent", lastelevator.GetName());
      }

    }

    if (endtrig && endtrig.IsValid()) {
      ppmod.addscript(endtrig, "OnStartTouch", "smo.moon.odyssey.check()");
    }

  }, 1);


}

smo.moon.create <- function(id) {

  smo.moon.bgstr += smo.moon.char;

  foreach (curr in smo.moon.table) {
    if (curr == id) return;
  }

  local pos = smo.moonlist[id].pos;
  local title = smo.moonlist[id].name;
  local name = "smo_moon_" + id + "_";

  ppmod.create(smo.moon.mdl, function(prop, id = id, name = name) {

    local pos = smo.moonlist[id].pos;
    local title = smo.moonlist[id].name;

    prop.SetOrigin(pos + Vector(0, 0, 32));
    prop.SetAngles(0, 0, 0);

    ppmod.keyval(prop, "Targetname", name + "prop");
    ppmod.keyval(prop, "CollisionGroup", 1);
    ppmod.keyval(prop, "ModelScale", smo.moon.size);
    ppmod.fire(prop, "Color", "100 150 200");

    ppmod.interval(function(prop = prop) {
      prop.SetAngles(0, smo.moon.ang, 0);
    }, 0, name + "rotate");

    local trigger = ppmod.trigger(pos + Vector(0, 0, 20), Vector(20, 20, 20));
    ppmod.keyval(trigger, "Targetname", name + "trigger");
    ppmod.addscript(trigger, "OnStartTouch", "smo.moon.collect(" + id + ")");

    local txt = ppmod.text("YOU GOT A MOON!", -1, 0.6);
    txt.SetFade(0.3, 0.3);
    txt.SetChannel(3);
    ppmod.keyval(txt.GetEntity(), "Targetname", name + "text");
    ppmod.keyval(txt.GetEntity(), "HoldTime", 5);

    txt = ppmod.text(" ______________________\n" + title, -1, 0.627);
    txt.SetFade(0.3, 0.3);
    txt.SetChannel(1);
    ppmod.keyval(txt.GetEntity(), "Targetname", name + "text");
    ppmod.keyval(txt.GetEntity(), "HoldTime", 5);

    txt = ppmod.text("______________________", -1, 0.627);
    txt.SetFade(0.3, 0.3);
    txt.SetChannel(4);
    ppmod.keyval(txt.GetEntity(), "Targetname", name + "text");
    ppmod.keyval(txt.GetEntity(), "HoldTime", 5);

    ppmod.give("light_dynamic", function (ent, id = id, name = name) {

      local pos = smo.moonlist[id].pos;
      local title = smo.moonlist[id].name;

      ent.SetOrigin(pos + Vector(24, 0, 32));
      ent.SetAngles(0, 0, 0);

      ppmod.keyval(ent, "Targetname", name + "smo_dlight");
      ppmod.keyval(ent, "SpawnFlags", 1);
      ppmod.keyval(ent, "_light", "100 150 200");
      ppmod.keyval(ent, "brightness", 2);
      ppmod.keyval(ent, "distance", 128);

      ppmod.fire(ent, "SetParent", name + "prop");
      ppmod.fire(ent, "TurnOn");

    });

    ppmod.give("light_dynamic", function (ent, id = id, name = name) {

      local pos = smo.moonlist[id].pos;
      local title = smo.moonlist[id].name;

      ent.SetOrigin(pos + Vector(-24, 0, 32));
      ent.SetAngles(0, 0, 0);

      ppmod.keyval(ent, "Targetname", name + "smo_dlight");
      ppmod.keyval(ent, "SpawnFlags", 1);
      ppmod.keyval(ent, "_light", "100 150 200");
      ppmod.keyval(ent, "brightness", 2);
      ppmod.keyval(ent, "distance", 128);

      ppmod.fire(ent, "SetParent", name + "prop");
      ppmod.fire(ent, "TurnOn");

    });

    ppmod.interval(function(name = name) {
      EntFire(name + "smo_dlight", "TurnOn");
    }, 0, name + "smo_dlight_interval");

  });

}

smo.moon.collect <- function(id) {

  local spawner = ppmod.get("info_player_start").GetOrigin();
  local lightpos = spawner.x+" "+spawner.y+" "+(spawner.z + 32);
  local name = "smo_moon_" + id + "_";

  EntFire(name + "text", "Display");
  EntFire(name + "smo_dlight", "ClearParent");
  EntFire(name + "smo_dlight", "SetLocalOrigin", lightpos);
  EntFire(name + "smo_dlight_interval", "Kill");
  EntFire(name + "prop", "FadeAndKill");
  EntFire(name + "rotate", "Kill");

  EntFire("smo_cap", "DisableDraw");

  smo.moon.str += smo.moon.char;

  smo.moon.table.push(id);

  local storage = smo.moon.odyssey.enabled == 1 ? "T" : "F";
  for (local i = 0; i < smo.moonlist.len(); i ++) storage += "0";

  for (local i = 0; i < smo.moon.table.len(); i ++) {
    storage = storage.slice(0, smo.moon.table[i] + 1) + "1" + storage.slice(smo.moon.table[i] + 2);
  }

  ppmod.keyval(GetPlayer(), "Targetname", storage);

}

smo.moon.chapters <- [
  [
    "sp_a1_intro1",
    "sp_a1_intro2",
    "sp_a1_intro3",
    "sp_a1_intro4",
    "sp_a1_intro5",
    "sp_a1_intro6",
    "sp_a1_intro7",
    "sp_a1_wakeup",
    "sp_a2_intro",
  ],
  [
    "sp_a2_laser_intro",
    "sp_a2_laser_stairs",
    "sp_a2_dual_lasers",
    "sp_a2_laser_over_goo",
    "sp_a2_catapult_intro",
    "sp_a2_trust_fling",
    "sp_a2_pit_flings",
    "sp_a2_fizzler_intro"
  ],
  [
    "sp_a2_sphere_peek",
    "sp_a2_ricochet",
    "sp_a2_bridge_intro",
    "sp_a2_bridge_the_gap",
    "sp_a2_turret_intro",
    "sp_a2_laser_relays",
    "sp_a2_turret_blocker",
    "sp_a2_laser_vs_turret",
    "sp_a2_pull_the_rug"
  ],
  [
    "sp_a2_column_blocker",
    "sp_a2_laser_chaining",
    "sp_a2_triple_laser",
    "sp_a2_bts1",
    "sp_a2_bts2"
  ],
  [
    "sp_a2_bts3",
    "sp_a2_bts4",
    "sp_a2_bts5",
    "sp_a2_bts6",
    "sp_a2_core"
  ],
  [
    "sp_a3_00",
    "sp_a3_01",
    "sp_a3_03",
    "sp_a3_jump_intro",
    "sp_a3_bomb_flings",
    "sp_a3_crazy_box",
    "sp_a3_transition01"
  ],
  [
    "sp_a3_speed_ramp",
    "sp_a3_speed_flings",
    "sp_a3_portal_intro",
    "sp_a3_end"
  ],
  [
    "sp_a4_intro",
    "sp_a4_tb_intro",
    "sp_a4_tb_trust_drop",
    "sp_a4_tb_wall_button",
    "sp_a4_tb_polarity",
    "sp_a4_tb_catch",
    "sp_a4_stop_the_box",
    "sp_a4_laser_catapult",
    "sp_a4_laser_platform",
    "sp_a4_speed_catch",
    "sp_a4_jump_polarity"
  ],
  [
    "sp_a4_finale1",
    "sp_a4_finale2",
    "sp_a4_finale3",
    "sp_a4_finale4"
  ]
];
smo.moon.levels <- [
  [
    "Container Ride",
    "Portal Carousel",
    "Portal Gun",
    "Smooth Jazz",
    "Cube Momentum",
    "Future Starter",
    "Secret Panel",
    "Wakeup",
    "Incinerator"
  ],
  [
    "Laser Intro",
    "Laser Stairs",
    "Dual Lasers",
    "Laser Over Goo",
    "Catapult Intro",
    "Trust Fling",
    "Pit Flings",
    "Fizzler Intro"
  ],
  [
    "Ceiling Catapult",
    "Ricochet",
    "Bridge Intro",
    "Bridge the Gap",
    "Turret Intro",
    "Laser Relays",
    "Turret Blocker",
    "Laser vs Turret",
    "Pull the Rug"
  ],
  [
    "Column Blocker",
    "Laser Chaining",
    "Triple Laser",
    "Jail Break",
    "Escape"
  ],
  [
    "Turret Factory",
    "Turret Sabotage",
    "Neurotoxin Sabotage",
    "Tube Ride",
    "Core"
  ],
  [
    "Long Fall",
    "Underground",
    "Cave Johnson",
    "Repulsion Intro",
    "Bomb Flings",
    "Crazy Box",
    "PotatOS"
  ],
  [
    "Propulsion Intro",
    "Propulsion Flings",
    "Conversion Intro",
    "Three Gels"
  ],
  [
    "Test",
    "Funnel Intro",
    "Ceiling Button",
    "Wall Button",
    "Polarity",
    "Funnel Catch",
    "Stop the Box",
    "Laser Catapult",
    "Laser Platform",
    "Propulsion Catch",
    "Repulsion Polarity"
  ],
  [
    "Finale 1",
    "Finale 2",
    "Finale 3",
    "Finale 4"
  ]
];

smo.moon.required <- [
  10,
  25,
  35,
  50,
  60,
  75,
  85,
  100,
  100
];

smo.moon.odyssey <- {

  currchapter = 0,
  enabled = 0,
  chaptertext = null,

  count = function () {

    local totalcount = 0, havecount = 0, found = false;

    foreach (map in smo.moon.chapters[smo.moon.odyssey.currchapter]) {

      foreach (id, moon in smo.moonlist) {
        if (moon.map == map) {

          totalcount ++;

          foreach (collected in smo.moon.table) {
            if (id == collected) {
              havecount ++;
              break;
            }
          }

        }
      }

    }

    return [totalcount, havecount];

  },

  textoffset = 1.1,
  textvelocity = -0.08,
  statstext = null,

  show = function() {

    smo.moon.odyssey.currchapter = smo.moon.chapternum;

    smo.moon.odyssey.enabled = 1;

    ppmod.fire(smo.move.speedmod, "ModifySpeed", 0);

    EntFire("smo_moon_interval", "Kill");
    SendToConsole("fadeout 0.5 30 30 30 0");

    ppmod.wait(function() {

      smo.moon.odyssey.chaptertext = ppmod.text("Chapter " + (smo.moon.chapternum + 1), -1, 0.1);
      smo.moon.odyssey.chaptertext.SetChannel(3);

      ppmod.interval(function() {
        smo.moon.odyssey.chaptertext.Display();
      }, 0, "smo_moon_chaptertext_interval");

      ppmod.interval(function() {
        
        smo.moon.odyssey.textvelocity *= 0.9;
        smo.moon.odyssey.textoffset += smo.moon.odyssey.textvelocity;
        smo.moon.odyssey.chaptertext.SetPosition(-1, smo.moon.odyssey.textoffset);

        if (smo.moon.odyssey.textoffset < 0.382) {

          ppmod.get("smo_moon_textanim_interval").Destroy();

          local count = smo.moon.odyssey.count();

          local dialogue;
          local remaining = smo.moon.required[smo.moon.chapternum] - smo.moon.table.len();

          if (GetMapName().tolower() == "sp_a4_finale4") {

            remaining = smo.moonlist.len() - smo.moon.table.len();
            if (remaining > 0) {
              dialogue = "You have collected " + smo.moon.table.len() + " out of the " + smo.moonlist.len() + " total moons" +
              "\nEvery chapter is now unlocked\nFeel free to go back to collect the remaining " + remaining + " moons";
            } else {
              dialogue = "Congratulations!\nYou have collected all " + smo.moonlist.len() + "moons\nThank you for playing!";
            }

          } else if (remaining > 0) {
            dialogue = "The Odyssey needs " + remaining + " more moons";
          } else {
            dialogue = "The Odyssey is ready to go";
          }

          smo.moon.odyssey.statstext = ppmod.text(
            "Odyssey: " + smo.moon.table.len() + " / " + smo.moon.required[smo.moon.chapternum] +
            "\nIn this chapter: " + count[1] + " / " + count[0] +
            "\n\n" + dialogue +
            "\nPress the use key to select a level",
            -1, 0.47
          );

          smo.moon.odyssey.statstext.SetChannel(2);
          smo.moon.odyssey.statstext.SetFade(0.5, 0);
          smo.moon.odyssey.statstext.Display(86400);
          
          smo.moon.odyssey.enabled = 2;

        }

      }, 0, "smo_moon_textanim_interval");

    }, 0.7);

  },

  selected = 0,
  listanim = 0,
  listmove = false,
  list = function() {

    if (smo.moon.odyssey.enabled == 3) {

      local required = 0;
      if (smo.moon.chapternum > 0) required = smo.moon.required[smo.moon.chapternum - 1];

      if (

        required <= smo.moon.table.len() &&
        GetMapName().tolower() != smo.moon.chapters[smo.moon.chapternum][smo.moon.odyssey.selected]
        
      ) {

        local storage = smo.moon.odyssey.currchapter == smo.moon.chapternum ? "T" : "F";
        for (local i = 0; i < smo.moonlist.len(); i ++) storage += "0";

        for (local i = 0; i < smo.moon.table.len(); i ++) {
          storage = storage.slice(0, smo.moon.table[i] + 1) + "1" + storage.slice(smo.moon.table[i] + 2);
        }

        ppmod.keyval(GetPlayer(), "Targetname", storage);

        local landmark = ppmod.get("info_landmark_exit");
        if (landmark) GetPlayer().SetOrigin(landmark.GetOrigin());
        
        ppmod.fire("weapon_portalgun", "Kill");

        ppmod.fire(smo.move.speedmod, "ModifySpeed", 1);

        local changelevel = Entities.CreateByClassname("point_changelevel");
        ppmod.fire(changelevel, "ChangeLevel", smo.moon.chapters[smo.moon.chapternum][smo.moon.odyssey.selected]);

      }

      return;

    }
    smo.moon.odyssey.enabled = 3;

    smo.moon.odyssey.statstext.SetFade(0, 0.25);
    smo.moon.odyssey.statstext.Display();

    ppmod.wait(function() {

      foreach (index, map in smo.moon.chapters[smo.moon.chapternum]) {
        if (map == GetMapName().tolower()) {
          smo.moon.odyssey.selected = index;
          break;
        }
      }

      smo.moon.odyssey.statstext.SetText("Use movement keys to select a level\nPress the use key to confirm selection");

      smo.moon.odyssey.statstext.SetFade(0.5, 0);
      smo.moon.odyssey.statstext.Display(86400);

      local required = 0;
      if (smo.moon.chapternum > 0) required = smo.moon.required[smo.moon.chapternum - 1];

      local text = ppmod.text(smo.moon.levels[smo.moon.chapternum][smo.moon.odyssey.selected], -1, 0.6);
      text.SetColor("75 75 75");
      text.SetFade(0.5, 0);
      text.Display();

      ppmod.wait(function(text = text) {

        text.SetFade(0, 0);

        ppmod.interval(function(text = text) {

          if (smo.moon.odyssey.listanim == 0 && !smo.moon.odyssey.listmove) {

            if (smo.move.gameui.moveleft) {

              smo.moon.odyssey.listanim = -15;
              smo.moon.odyssey.listmove = true;

            } else if (smo.move.gameui.moveright) {

              smo.moon.odyssey.listanim = 15;
              smo.moon.odyssey.listmove = true;

            }

          }

          local listanim = smo.moon.odyssey.listanim;

          local paddingL = "";
          local paddingR = "";

          if (listanim > 0) {

            if (smo.moon.odyssey.listmove) {

              for (local i = pow(15 - listanim, 1.6); i > 0; i --) paddingR += " ";

              if (listanim == 1) {

                smo.moon.odyssey.listanim = -15;
                smo.moon.odyssey.listmove = false;

                if (smo.moon.odyssey.selected == smo.moon.levels[smo.moon.chapternum].len() - 1) {
                  if (smo.moon.chapternum == 8) smo.moon.chapternum = 0;
                  else smo.moon.chapternum ++;
                  smo.moon.odyssey.selected = 0;
                } else smo.moon.odyssey.selected ++;

                smo.moon.odyssey.chaptertext.SetText("Chapter " + (smo.moon.chapternum + 1));

              } else smo.moon.odyssey.listanim --;

            } else {

              for (local i = pow(listanim, 1.6); i > 0; i --) paddingR += " ";
              smo.moon.odyssey.listanim --;

            }

          } else if (listanim < 0) {

            if (smo.moon.odyssey.listmove) {

              for (local i = pow(15 + listanim, 1.6); i > 0; i --) paddingL += " ";

              if (listanim == -1) {

                smo.moon.odyssey.listanim = 15;
                smo.moon.odyssey.listmove = false;

                if (smo.moon.odyssey.selected == 0) {
                  if (smo.moon.chapternum == 0) smo.moon.chapternum = 8;
                  else smo.moon.chapternum --;
                  smo.moon.odyssey.selected = smo.moon.levels[smo.moon.chapternum].len() - 1;
                } else smo.moon.odyssey.selected --;

                smo.moon.odyssey.chaptertext.SetText("Chapter " + (smo.moon.chapternum + 1));

              } else smo.moon.odyssey.listanim ++;

            } else {

              for (local i = pow(-listanim, 1.6); i > 0; i --) paddingL += " ";
              smo.moon.odyssey.listanim ++;

            }

          }

          local required = 0;
          if (smo.moon.chapternum > 0) required = smo.moon.required[smo.moon.chapternum - 1];

          local step = 17;
          if (
            required > smo.moon.table.len() ||
            GetMapName().tolower() == smo.moon.chapters[smo.moon.chapternum][smo.moon.odyssey.selected]
          ) {
            step = 5;
          }

          local brightness = step * (abs(smo.moon.odyssey.listanim));
          if (!smo.moon.odyssey.listmove) brightness = step * 15 - brightness;
          
          text.SetColor(brightness+" "+brightness+" "+brightness);

          text.SetText(paddingL + smo.moon.levels[smo.moon.chapternum][smo.moon.odyssey.selected] + paddingR);
          text.Display();

        });

      }, 0.5);

    }, 0.5);

  },
  
  check = function () {

    if (smo.moon.odyssey.enabled) {
      
      smo.moon.odyssey.show();

    } else {

      local chapter = smo.moon.chapters[smo.moon.chapternum];
      if (chapter[chapter.len() - 1] == GetMapName().tolower()) {
        smo.moon.odyssey.show();
      }

    }

  }

}

smo.moon.setcount <- function(amount) {

  local storage = smo.moon.odyssey.enabled == 1 ? "T" : "F";

  for (local i = 0; i < amount; i ++) {
    storage += "1";
    smo.moon.table.push(i);
  }

  ppmod.keyval(GetPlayer(), "Targetname", storage);

}