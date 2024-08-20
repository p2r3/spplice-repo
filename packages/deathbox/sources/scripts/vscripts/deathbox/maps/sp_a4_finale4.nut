local end = ppmod.trigger(Vector(21, 1499, 249), Vector(10, 10, 0));
ppmod.addscript(end, "OnStartTouch", function() {
    ppmod.get("chase_interval").Destroy();
});