if (!("Entities" in this)) return;
if ("setupFunc" in this) return;
IncludeScript("ppmod3");

positionArray <- [];
portalsArray <- [];
noDeathTimer <- 150;

setupFunc <- function () {
    local i;
    for (i = 0; i < 35; i++) {
        positionArray.push(GetPlayer().GetOrigin());
    }

    try {
        IncludeScript("deathbox/maps/" + GetMapName());
    } catch (e) {
        printl(e);
    }

    local ele = null,
        trigger = null;
    if ((ele = ppmod.get("departure_elevator-elevator_1"))) {
        trigger = ppmod.trigger(ele.GetOrigin(), Vector(640, 640, 320));
    } else if ((ele = ppmod.prev("models/props_underground/elevator_a.mdl"))) {
        trigger = ppmod.trigger(ele.GetOrigin(), Vector(180, 180, 180));
    }
    if (trigger != null && GetMapName() != "sp_a4_stop_the_box") {
        ppmod.keyval(trigger, "Targetname", "hold_exit");
        ppmod.addscript("hold_exit", "OnStartTouch", function (i=i,ele=ele,trigger=trigger) {
            ppmod.get("chase_interval").Destroy();
        });
    }
    if (GetMapName() == "sp_a2_bts6") {
        ppmod.get("chase_interval").Destroy();
    }
    if (GetMapName() == "sp_a3_01") {
        noDeathTimer = 500;
    }
    if (
        GetMapName() == "sp_a3_jump_intro" ||
        GetMapName() == "sp_a2_column_blocker"
    ) {
        noDeathTimer = 350;
    }
    if (GetMapName() == "sp_a2_intro") {
        noDeathTimer = 600;
    }

    if (GetMapName() == "sp_a1_intro1") {
        ppmod.wait(function (i=i,ele=ele,trigger=trigger) {
            local starttxt = ppmod.text("Welcome to DeathBox.", -1, 0.8);
            local subtitlestarttxt = ppmod.text(
                "The game will start in Intro 2.",
                -1,
                0.85
            );

            starttxt.SetChannel(5);
            subtitlestarttxt.SetChannel(4);

            ppmod.interval(function (i=i,ele=ele,trigger=trigger,starttxt=starttxt,subtitlestarttxt=subtitlestarttxt) {
                starttxt.Display();
                subtitlestarttxt.Display();
            });
        }, 8);
        ppmod.interval(function (i=i,ele=ele,trigger=trigger) {
            if (ppmod.get("chase_interval")) {
                ppmod.get("chase_interval").Destroy();
                return;
            }
        });
    }

    ppmod.create("ent_create_portal_companion_cube", function (cube,i=i,ele=ele,trigger=trigger) {
        ppmod.keyval(cube, "CollisionGroup", 2);
        ppmod.keyval(cube, "Solid", 0);
        ppmod.fire(cube, "DisablePickup");
        ppmod.keyval(cube, "RenderMode", 1);
        ppmod.keyval(cube, "RenderAmt", 100);
        ppmod.fire(cube, "Color", "255 70 70");

        local text = ppmod.text("", -1, 0.9);
        local subtitle = ppmod.text("", -1, 0.95);
        subtitle.SetChannel(2);

        ppmod.interval(
            function (i=i,ele=ele,trigger=trigger,cube=cube,text=text,subtitle=subtitle) {
                local dist = (
                    positionArray[0] - GetPlayer().GetOrigin()
                ).Length();

                local speed = (positionArray[0] - positionArray[1]).Length();
                local ups = speed * 30;

                local angles = cube.GetAngles();
                cube.SetAngles(angles.x, angles.y + 4, angles.z + 4);

                text.SetText(
                    "The Death Box is "+(floor(dist))+"u away from you..."
                );
                text.Display();

                subtitle.SetText(
                    "... and rapidly approaching at "+(floor(ups))+"ups..."
                );
                subtitle.Display();

                local curr = null;
                while ((curr = ppmod.get("prop_portal", curr))) {
                    local found = false;
                    for (local i = 0; i < portalsArray.len(); i++) {
                        if (portalsArray[i] == curr) {
                            found = true;
                            break;
                        }
                    }

                    if (found) continue;

                    portalsArray.push(curr);
                    ppmod.addscript(
                        curr,
                        "OnPlayerTeleportFromMe",
                        function (i=i,ele=ele,trigger=trigger,cube=cube,text=text,subtitle=subtitle,dist=dist,speed=speed,ups=ups,angles=angles,curr=curr,found=found,i=i) {
                            if (positionArray.len() <= 4) return;
                            for (local j = 0; j < 2; j++) positionArray.remove(j);
                        }
                    );
                }

                if (noDeathTimer > 0) {
                    noDeathTimer--;
                    return;
                }
                ppmod.keyval(cube, "RenderAmt", 255);

                if (dist < 32 && noDeathTimer == 0) {
                    SendToConsole("kill");
                    ppmod.get("chase_interval").Destroy();
                }

                local pos = positionArray[0];
                ppmod.keyval(cube, "Origin", ""+(pos.x)+" "+(pos.y)+" "+(pos.z + 36)+"");

                positionArray.push(GetPlayer().GetOrigin());
                positionArray.remove(0);
            },
            0,
            "chase_interval"
        );
    });
};

local auto = Entities.CreateByClassname("logic_auto");
ppmod.addscript(auto, "OnNewGame", setupFunc);
ppmod.addscript(auto, "OnMapTransition", setupFunc);
