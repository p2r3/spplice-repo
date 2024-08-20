local end = ppmod.trigger(Vector(395, 1147, 100), Vector(174, 169, 100));
ppmod.addscript(end, "OnStartTouch", function() {
    ppmod.get("chase_interval").Destroy();
});