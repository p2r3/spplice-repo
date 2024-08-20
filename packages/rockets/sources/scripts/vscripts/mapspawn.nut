if(!("Entities" in this)) return;
if("rocket" in this) return;
IncludeScript("ppmod3");

::rocket <- {};

local auto = Entities.CreateByClassname("logic_auto");
ppmod.addscript(auto, "OnMapSpawn", "rocket.setup()");

rocket.setup <- function() {   

  ppmod.once(function() {

    ppmod.fire("weapon_portalgun", "Kill");
    ppmod.fire("viewmodel", "Kill");

    ppmod.player.enable(function() {
      ppmod.wait(function() {

        ppmod.player.input("+attack", function() {
          SendToConsole("fire_rocket_projectile");
          SendToConsole("script rocket.fire()");
        });

      }, 0.1);
    });

    local txt = ppmod.text("", -1, 0.925);
    ppmod.interval(function(txt = txt) {
      
      txt.SetText("Health: " + max(0, GetPlayer().GetHealth()));
      txt.Display();

    });

    ppmod.interval(function() {

      if (ppmod.get("weapon_portalgun")) {
        ppmod.fire("weapon_portalgun", "Kill");
      }

    }, 2);

  }, "rocket_setup_once");

}

rocket.positions <- {};
rocket.fire <- function() {

  local ent = ppmod.prev("rocket_turret_projectile");

  local str = UniqueString("rocket");
  rocket.positions[str] <- Vector();

  ppmod.interval(function(str = str, ent = ent) {

    local vel = GetPlayer().GetVelocity();
    local vec = rocket.positions[str] - GetPlayer().GetCenter();
    local mag = max(0, 400 - vec.Norm());

    if (!ent || !ent.IsValid()) {

      GetPlayer().SetVelocity(vel - vec * mag);
      ppmod.get("interval_" + str).Destroy();
      delete rocket.positions[str];

    } else {

      rocket.positions[str] <- ent.GetOrigin();

    }

  }, 0, "interval_" + str);

}
