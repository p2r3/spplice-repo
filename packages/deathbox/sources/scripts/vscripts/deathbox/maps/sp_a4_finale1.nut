local end = ppmod.trigger(Vector(-12832, -2591, -89), Vector(40, 184, 87));
ppmod.addscript(end, "OnStartTouch", function() {
    ppmod.get("chase_interval").Destroy();
});