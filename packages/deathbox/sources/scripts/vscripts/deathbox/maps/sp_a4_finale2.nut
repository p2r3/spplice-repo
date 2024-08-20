local end = ppmod.trigger(Vector(-3151, -1425, -262), Vector(39, 212, 58));
ppmod.addscript(end, "OnStartTouch", function() {
    ppmod.get("chase_interval").Destroy();
});