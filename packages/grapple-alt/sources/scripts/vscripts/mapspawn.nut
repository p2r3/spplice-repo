if (!("Entities" in this)) {
	return
}

printl("[Grapple Gun] Attempting to start grapple gun...")

function grappleInit()
{
    local clientcmd = Entities.CreateByClassname("point_clientcommand")
    EntFireByHandle(clientcmd, "Command", "script_execute grapple.nut", 1.5, null, null)
}

Entities.First().ConnectOutput("OnUser1", "grappleInit")
DoEntFire("worldspawn", "FireUser1", "", 0.0, null, null)