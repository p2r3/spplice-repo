smo.setup <- function() {
  
  local eleTrig = ppmod.trigger(Vector(-981, -128, -960), Vector(16, 16, 4));
  ppmod.addscript(eleTrig, "OnStartTouch", function() {

    local push = Entities.CreateByClassname("point_push");
    ppmod.keyval(push, "Targetname", "smo_elevator_push");
    ppmod.keyval(push, "Magnitude", 200);
    ppmod.keyval(push, "SpawnFlags", 12);
    ppmod.keyval(push, "Radius", 32);
    ppmod.fire(push, "Enable");
    push.SetOrigin(Vector(-982, -129, -960));

    local elevator = ppmod.get("arrival_elevator-elevator_1");

    ppmod.interval(function(elevator = elevator) {

      local pos = elevator.GetOrigin();
      elevator.SetAbsOrigin(pos + Vector(0, 0, -15));

      if (pos.z < -855) {

        ppmod.get("smo_elevator_down_interval").Destroy();

        ppmod.fire("smo_elevator_push", "Kill");

        local trig = ppmod.trigger(Vector(-1016, -128, -893), Vector(17, 16, 38));
        ppmod.addscript(trig, "OnStartTouch", function(elevator = elevator) {

          ppmod.fire(smo.move.speedmod, "ModifySpeed", 0);
          ppmod.keyval("!player", "MoveType", 8);

          ppmod.interval(function(elevator = elevator) {

            local epos = elevator.GetOrigin();
            local ppos = GetPlayer().GetOrigin();

            elevator.SetAbsOrigin(epos + Vector(0, 0, 15));
            GetPlayer().SetAbsOrigin(ppos + Vector(0, 0, 15));

            if (epos.z > -162) {
              
              ppmod.get("smo_elevator_up_interval").Destroy();

              ppmod.fire(smo.move.speedmod, "ModifySpeed", 1);
              ppmod.keyval("!player", "MoveType", 2);
            
            }

          }, 0, "smo_elevator_up_interval");

        })

      }

    }, 0, "smo_elevator_down_interval");

  });

}
