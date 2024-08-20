local end = ppmod.trigger(Vector(2283, 580, 4475), Vector(203, 132, 123));
ppmod.addscript(end, "OnStartTouch", function() {
    ppmod.get("chase_interval").Destroy();
});