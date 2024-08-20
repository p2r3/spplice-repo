local end = ppmod.trigger(Vector(6136, 4927, -1665), Vector(263, 63, 127));
ppmod.addscript(end, "OnStartTouch", function() {
    ppmod.get("chase_interval").Destroy();
});