local cube = ppmod.get("juggled_cube");
cube.SetOrigin(Vector(1310, 450, -1246));
cube.SetAngles(0, 0, 0);
ppmod.fire(cube, "DisableMotion");

local trigger = ppmod.get(63);
ppmod.addoutput(trigger, "OnStartTouch", "cube_retrieved_relay", "Trigger");
ppmod.addoutput(trigger, "OnStartTouch", "juggled_cube", "EnableMotion", "", 0.1);
ppmod.addoutput(trigger, "OnStartTouch", "juggled_cube", "Sleep", "", 0.1 + FrameTime());