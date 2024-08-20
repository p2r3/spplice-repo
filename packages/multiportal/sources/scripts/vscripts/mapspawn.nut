if (!("Entities" in this)) return;
if ("multiportal" in this) return;
IncludeScript("ppmod3");

local auto = Entities.CreateByClassname("logic_auto");
ppmod.addscript(auto, "OnNewGame", "multiportal.start()");
ppmod.addscript(auto, "OnMapTransition", "multiportal.start()");

::multiportal <- {

  prev = -1,
  linkage = 0,
  act = GetMapName().slice(3, 5),

  start = function() {

    local curr = null;
    while (curr = ppmod.get("prop_portal", curr)) {
      if (curr.GetName().len() == 0) curr.Destroy();
    }

    SendToConsole("sv_cheats 1");
    SendToConsole("r_portal_fastpath 0");
    SendToConsole("change_portalgun_linkage_id 0");

    ppmod.give("prop_portal", function(ent) {
      ppmod.keyval(ent, "PortalTwo", 0);
      ppmod.addscript(ent, "OnPlacedSuccessfully", "multiportal.place(0)");
    });

    ppmod.give("prop_portal", function(ent) {
      ppmod.keyval(ent, "PortalTwo", 1);
      ppmod.addscript(ent, "OnPlacedSuccessfully", "multiportal.place(1)");
    });

  },

  place = function(id) {

    if (multiportal.act != "a1") {

      if (prev == -1) prev = id;
      if (prev == id) return;
      prev = -1;
      
    }

    multiportal.linkage ++;
    SendToConsole("change_portalgun_linkage_id " + multiportal.linkage);

    ppmod.wait(function() {

      local p1 = ppmod.prev("prop_portal");
      local p2 = ppmod.prev("prop_portal", p1);

      ppmod.addscript(p1, "OnPlacedSuccessfully", "multiportal.place(0)");
      ppmod.addscript(p2, "OnPlacedSuccessfully", "multiportal.place(1)");

    }, FrameTime() * 2);

  }

};