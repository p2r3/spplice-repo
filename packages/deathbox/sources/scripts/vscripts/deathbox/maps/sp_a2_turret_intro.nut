local end = ppmod.trigger(Vector(-100, 392, -194), Vector(17, 64, 60));
ppmod.addscript(end, "OnStartTouch", function() {
    ppmod.get("chase_interval").Destroy();
});