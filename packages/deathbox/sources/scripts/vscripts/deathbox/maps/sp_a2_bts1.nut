local end = ppmod.trigger(Vector(1086, -1347, -292), Vector(286, 35, 156));
ppmod.addscript(end, "OnStartTouch", function() {
    ppmod.get("chase_interval").Destroy();
});