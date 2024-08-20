local end = ppmod.trigger(Vector(2213, 1696, 433), Vector(59, 304, 192));
ppmod.addscript(end, "OnStartTouch", function() {
    ppmod.get("chase_interval").Destroy();
});