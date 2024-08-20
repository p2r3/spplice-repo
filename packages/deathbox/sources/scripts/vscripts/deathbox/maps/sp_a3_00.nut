local end = ppmod.trigger(Vector(0, -4096, 64), Vector(10, 10, 10)); // shit solution but idk any other
ppmod.addscript(end, "OnStartTouch", function() {
    ppmod.interval(function() {
        if (ppmod.get("chase_interval")) {
            ppmod.get("chase_interval").Destroy();
            return;
        }
    })

});