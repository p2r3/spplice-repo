local end = ppmod.trigger(Vector(-2, 306, -4), Vector(80, 20, 80)); // shit solution but idk any other
ppmod.addscript(end, "OnStartTouch", function() {
    ppmod.get("chase_interval").Destroy();
});