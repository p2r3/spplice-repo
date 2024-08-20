local end = ppmod.trigger(Vector(-3653, -7298, 6413), Vector(187, 193, 141));
ppmod.addscript(end, "OnStartTouch", function() {
    ppmod.get("chase_interval").Destroy();
});