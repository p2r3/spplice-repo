if (!("Entities" in this)) return;
if ("mod" in this) return;
IncludeScript("ppmod3");

local auto = Entities.CreateByClassname("logic_auto");
ppmod.addscript(auto, "OnMapTransition", "mod.setup()");
ppmod.addscript(auto, "OnNewGame", "mod.setup()");

::mod <- {

  props = ["prop_weighted_cube", "prop_monster_box", "npc_security_camera", "npc_portal_turret_floor", "prop_physics", "prop_physics_override"],
  intro6 = false,

  setup = function() {

    ppmod.player.enable();

    SendToConsole("alias +mouse_menu \"script mod.swap()\"");

    if (GetMapName().tolower() == "sp_a1_intro1") {

      ppmod.addscript("gladosintro_rm1", "OnStartTouch", function (){

        SendToConsole("alias +mouse_menu \"script mod.swap()\"");

        this.text1 <- ppmod.text("Look at the cube and press F to swap", -1, 0.75);
        this.text2 <- ppmod.text("(or use whatever your co-op ping key is)", -1, 0.8);

        this.text1.SetChannel(1);
        this.text2.SetChannel(2);

        ppmod.interval(function() {
          this.text1.Display();
          this.text2.Display();
        }, 0, "propswap_tutorial");

      });

    }

    ppmod.interval(function() {

      local ents = [];

      for (local i = 0; i < mod.props.len(); i ++) {
        local curr = null;
        while (curr = ppmod.get(mod.props[i], curr)) {
          ents.push(curr);
        }
      }

      for (local i = 0; i < ents.len(); i ++) {

        local curr = ents[i];

        ppmod.keyval(curr, "CollisionGroup", 2);
        ppmod.fire(curr, "DisablePickup");

        local portal = null;
        while (portal = ppmod.get(curr.GetOrigin(), portal, 20)) {
          if (portal.GetClassname() == "prop_portal") {
            portal.Destroy();
          }
        }

      }

    }, 0.1);

  },

  swap = function() {

    local ents = [];
    local closest = { frac = 1.0, ent = null };

    if (GetMapName().tolower() == "sp_a1_intro6" && !mod.intro6) {

      mod.intro6 = true;

      local curr = ppmod.brush(Vector(256, 192, 124), Vector(16, 16, 6));
      ppmod.keyval(curr, "CollisionGroup", 1);
      ppmod.keyval(curr, "Targetname", "intro6_exception");
      ents.push(curr);

    }

    for (local i = 0; i < mod.props.len(); i ++) {
      local curr = null;
      while (curr = ppmod.get(mod.props[i], curr)) {
        ents.push(curr);
      }
    }

    for (local i = 0; i < ents.len(); i ++) {

      local curr = ents[i];

      local pos = GetPlayer().EyePosition();
      local vec = pos + ppmod.player.eyes_vec() * 8192;

      local wfrac = 1.0, pfrac = 0.0;

      if (curr.GetName() == "intro6_exception") {

        if (ppmod.player.eyes.GetAngles().x < 69) continue;
        
        curr.Destroy();
        curr = ppmod.get("prop_weighted_cube");
        i ++;

      } else {

        wfrac = ppmod.ray(pos, vec);
        pfrac = ppmod.ray(pos, vec, curr, false);

      }

      if (pfrac < wfrac && pfrac < closest.frac) {

        closest.frac = pfrac;
        closest.ent = curr;

      }

    }

    if (closest.frac < 1.0) {

      local pos = closest.ent.GetOrigin() + Vector(0, 0, closest.ent.GetBoundingMaxs().z / 2.0);
      local ang = ppmod.player.eyes.GetAngles();

      closest.ent.SetAbsOrigin(GetPlayer().GetCenter());
      closest.ent.SetAngles(0, ang.y, 0);

      GetPlayer().SetAbsOrigin(pos);

      ppmod.fire(closest.ent, "EnableMotion");  
      ppmod.fire(closest.ent, "Wake");
      ppmod.fire(closest.ent, "Ragdoll");

      SendToConsole("debug_fixmyposition");

      if (GetMapName().tolower() == "sp_a1_intro1" && closest.ent.GetName() == "box") {
      
        ppmod.fire("propswap_tutorial", "Kill");

      }

    }

  }

};
