local end = ppmod.trigger(Vector(8972, 1084, -423), Vector(30, 30, 30));
ppmod.addscript(end, "OnStartTouch", function() {
    ppmod.get("chase_interval").Destroy();
});