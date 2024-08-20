local end = ppmod.trigger(Vector(-189, 5056, 134), Vector(323, 360, 194));
ppmod.addscript(end, "OnStartTouch", function() {
    ppmod.get("chase_interval").Destroy();
});