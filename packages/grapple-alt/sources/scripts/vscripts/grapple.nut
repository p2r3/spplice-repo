// P2CE VERSION

IncludeScript("pcapture-lib")
printl("=== P2 Grapple Gun Mod (By Rip Rip Rip) ===")

::defmax_dist <- 1500
::defgrapple_speed <- 1
::sparkfx_enable <- 0

::player_pickup_disable <- 0

::MAPS_BOMBS <- arrayLib.new(
    "sp_a4_finale3"
    "sp_a4_finale4"
)

function Init()
{
    // Enable cheats to allow code functionality:
    SendToConsole("sv_cheats 1")

    // Create broadcast clientcmd for handling certain actions:
    local clientcmd = Entities.CreateByClassname("point_broadcastclientcommand")
    clientcmd.__KeyValueFromString("targetname", "grapple_broadcastclientcommand")

    // Create game_ui entity for controlling player inputs:
    local gameui = Entities.CreateByClassname("game_ui")
    gameui.__KeyValueFromString("targetname", "grapple_gameui")
    gameui.__KeyValueFromFloat("FieldOfView", -1.0)
    gameui.__KeyValueFromString("PressedAttack", "grapple_broadcastclientcommand,Command,script gunFireSetpoint()")
    gameui.__KeyValueFromString("PressedAttack2", "grapple_playermovetimer,Enable")
    gameui.__KeyValueFromString("UnpressedAttack", "grapple_broadcastclientcommand,Command,script gunFireStop(1)")
    gameui.__KeyValueFromString("UnpressedAttack2", "grapple_playermovetimer,Disable")

    // Add small fire delay to fix issues with picking up objects:
    local pickupdelay = Entities.CreateByClassname("logic_relay")
    pickupdelay.__KeyValueFromString("targetname", "grapple_pickupobjectrelay")
    pickupdelay.__KeyValueFromString("OnTrigger", "grapple_broadcastclientcommand,Command,ent_fire !picker use")
    pickupdelay.__KeyValueFromString("OnTrigger", "!self,a,,0.1")

    // Create game_ui entity for when a player is holding prop:
    local gameuipartial = Entities.CreateByClassname("game_ui")
    gameuipartial.__KeyValueFromString("targetname", "grapple_gameui_partial")
    gameuipartial.__KeyValueFromFloat("FieldOfView", -1.0)
    gameuipartial.__KeyValueFromString("PressedAttack2", "grapple_playermovetimer,Enable")
    gameuipartial.__KeyValueFromString("UnpressedAttack2", "grapple_playermovetimer,Disable")

    // Create timers to handle player movement check looping:
    local playermovetimer = Entities.CreateByClassname("logic_timer")
    playermovetimer.__KeyValueFromString("targetname", "grapple_playermovetimer")
    playermovetimer.__KeyValueFromFloat("RefireTime", 0.01)
    playermovetimer.__KeyValueFromInt("StartDisabled", 1)
    playermovetimer.__KeyValueFromString("OnTimer", "grapple_playermovetimerrelay,Trigger")

    local playermovetimerrelay = Entities.CreateByClassname("logic_relay")
    playermovetimerrelay.__KeyValueFromString("targetname", "grapple_playermovetimerrelay")
    playermovetimerrelay.__KeyValueFromInt("StartDisabled", 1)
    playermovetimerrelay.__KeyValueFromString("OnTrigger", "grapple_broadcastclientcommand,Command,script gunMovePlayer()")

    // Create entities to handle crosshair:
    local crosshairtimer = Entities.CreateByClassname("logic_timer")
    crosshairtimer.__KeyValueFromString("targetname", "grapple_crosshaircontroltimer")
    crosshairtimer.__KeyValueFromFloat("RefireTime", 0.01)
    crosshairtimer.__KeyValueFromString("OnTimer", "grapple_broadcastclientcommand,Command,script playerCrosshairControl()")
    crosshairtimer.__KeyValueFromInt("StartDisabled", 1)

    EntFire("grapple_crosshaircontroltimer", "Enable", "", 0.01)

    local speedmod = Entities.CreateByClassname("player_speedmod")
    speedmod.__KeyValueFromString("targetname", "grapple_speedmod")
    speedmod.__KeyValueFromInt("spawnflags", 2)
    EntFireByHandle(speedmod, "ModifySpeed", "0.999", 0.01, null, null)

    // Spawn a text entity to display disabled pickup text (if required):
    //textEntCreator("grapple_map_pickupdisabledtext", "null", -1.0, -1.0, "255 0 0", 2)

    // Create env_spark entity to handle the display of sparks where the player shoots:
    ::sparkfx <- Entities.CreateByClassname("env_spark")
    sparkfx.__KeyValueFromString("targetname", "grapple_sparkfx")
    sparkfx.__KeyValueFromInt("Magnitude", 1)
    sparkfx.__KeyValueFromInt("TrailLength", 1)
    sparkfx.__KeyValueFromInt("spawnflags", 128)

    // Create entities to handle shooting of bombs (if required):
    //if(GetMapName() == "sp_a4_finale4") {
    //    printl("[Grapple Gun] Finale4 detected! Initialising bomb code...")
    //    bombshoot <- Entities.CreateByClassname("point_futbol_shooter")
    //    bombshoot.__KeyValueFromString("targetname", "grapple_bombshooter")
    //    bombshoot.__KeyValueFromFloat("launchspeed", 600.0)
    //    EntFire("grapple_bombshooter", "SetTarget", "grapple_shoottarget")
//
    //    local bombtimer = Entities.CreateByClassname("logic_timer")
    //    bombtimer.__KeyValueFromString("targetname", "grapple_bombtimer")
    //    bombtimer.__KeyValueFromFloat("RefireTime", 0.01)
    //    bombtimer.__KeyValueFromString("OnTimer", "grapple_broadcastclientcommand,Command,script bombSetToPlayer()")
    //    bombtimer.__KeyValueFromInt("StartDisabled", 1)
//
    //    local bombgameui = Entities.CreateByClassname("game_ui")
    //    bombgameui.__KeyValueFromString("targetname", "grapple_bombgameui")
    //    bombgameui.__KeyValueFromFloat("FieldOfView", -1.0)
    //    bombgameui.__KeyValueFromString("PressedAttack", "point_broadcastclientcommand,Command,script bombFire()")
//
    //    local bombtarget = entLib.CreateByClassname("info_target")
    //    bombtarget.SetKeyValue("targetname", "grapple_bombtarget")
//
    //    local shoottarget = entLib.CreateByClassname("info_teleport_destination")
    //    bombtarget.SetKeyValue("targetname", "grapple_shoottarget")
//
    //    local wheatley = null
    //    wheatley = Entities.FindByName(wheatley, "@sphere")
    //    bombtarget.SetOrigin(Vector((wheatley.GetCenter()).x, (wheatley.GetCenter()).y, ((wheatley.GetCenter()).z - 300)))
    //    bombtarget.SetBBox(Vector(-35, -35, -256), Vector(35, 35, 256))
//
    //    shoottarget.SetOrigin(Vector((wheatley.GetCenter()).x - 64, (wheatley.GetCenter()).y, ((wheatley.GetCenter()).z - 100)))
    //    shoottarget.SetBBox(Vector(-70, -70, -256), Vector(70, 70, 256))
    //    //dev.DrawEntityBBox(shoottarget, 999999.0)
//
    //    // Bomb Crosshair:
    //    local bombcrosshairtimer = Entities.CreateByClassname("logic_timer")
    //    bombcrosshairtimer.__KeyValueFromString("targetname", "grapple_bombcrosshaircontroltimer")
    //    bombcrosshairtimer.__KeyValueFromFloat("RefireTime", 0.01)
    //    bombcrosshairtimer.__KeyValueFromString("OnTimer", "grapple_broadcastclientcommand,Command,script playerBombCrosshairControl()")
    //    bombcrosshairtimer.__KeyValueFromInt("StartDisabled", 1)
//
    //    printl("[Grapple Gun] Bomb code initialised!")
    //}

    SendToConsole("r_drawscreenoverlay 1")

    gunEnable()
    
    if(GetMapName() == "sp_a4_finale4") {
        SendToConsole("ent_fire viewmodel disabledraw")
    }
    else {
        SendToConsole("ent_fire viewmodel kill")
    }

    //InitMapSpecific()

    printl("[Grapple Gun] Grapple gun mod successfully initialised!")
}

function InitMapSpecific()
{
    if(GetMapName() == "sp_a1_intro1") {
        EntFire("@camera_proxy_enable_rl", "AddOutput", "OnTrigger grapple_broadcastclientcommand,Command,script gunDisable()")
        EntFire("@camera_proxy_enable_rl", "AddOutput", "OnTrigger grapple_broadcastclientcommand,Command,r_screenoverlay .,0.05")
        EntFire("transition_out_of_container_rl", "AddOutput", "OnTrigger grapple_broadcastclientcommand,Command,script gunEnable()")
    }
    if(GetMapName() == "sp_a1_intro3") {
        EntFire("pickup_portalgun_rl", "Kill")
        EntFire("portalgun_button", "Kill")
    }
    if(GetMapName() == "sp_a1_intro4") {
        EntFire("glass_pane_1_door_1", "Open")
        EntFire("aud_ramp_break_glass", "Kill")
        EntFire("glass_pane_fractured_model", "Enable")
        EntFire("glass_pane_intact_model", "Kill")
        EntFire("glass_pane_1_door_1_blocker", "Kill", "", 0.2)
        EntFire("glass_shard", "Break")
    }
    if(GetMapName() == "sp_a1_intro5") {
        SendToConsole("portal_place 0 0 0 -418 128 270 270 0")
    }
    if(GetMapName() == "sp_a1_intro6") {
        local cube = null
        cube = Entities.FindByClassnameWithin(cube, "prop_weighted_cube", (Vector(256, 192, 18)), 500)
        EntFireByHandle(cube, "Wake", "", 0.0, null, null)
        cube.SetOrigin(Vector(256, 192, 200))
        EntFireByHandle(cube, "Wake", "", 0.01, null, null)
    }
    if(GetMapName() == "sp_a1_intro7") {
        playerPickupDisable(1)
        SendToConsole("portal_place 0 0 -577 -904 1476 0 90 0")
    }
    if(GetMapName() == "sp_a1_wakeup") {
        playerPickupDisable(1)
        EntFire("grapple_broadcastclientcommand", "Command", "script gunDisable()", 0.01)
        EntFire("socket_powered_rl", "AddOutput", "OnTrigger grapple_broadcastclientcommand,Command,script gunEnable()")
    }
    if(GetMapName() == "sp_a2_intro") {
        SendToConsole("ent_fire pickup_portalgun_relay kill")
    }
    if(GetMapName() == "sp_a2_dual_lasers") {
        EntFire("platform_door", "AddOutput", "OnFullyClosed grapple_broadcastclientcommand,Command,portal_place 0 1 -32 -288 1214 0 90 0,1")
        EntFire("platform_door", "AddOutput", "OnFullyClosed grapple_broadcastclientcommand,Command,portal_place 0 0 -223 223 1088 270 270 0,1")
    }
    if(GetMapName() == "sp_a2_fizzler_intro") {
        SendToConsole("ent_fire trigger_portal_cleanser disable")
    }
    if(GetMapName() == "sp_a2_sphere_peek") {
        SendToConsole("portal_place 0 0 -1089.5 1600 122 0 90 0")
        SendToConsole("portal_place 0 1 -1088.5 1536 122 0 270 0")
    }
    if(GetMapName() == "sp_a2_laser_relays") {
        SendToConsole("ent_fire laser_cube_spawner forcespawn")
    }
    if(GetMapName() == "sp_a2_triple_laser") {
        SendToConsole("ent_fire box1_spawner forcespawn")
        SendToConsole("ent_fire box1_spawner forcespawn")
        SendToConsole("ent_fire box1_spawner forcespawn")
        SendToConsole("ent_fire box1_spawner forcespawn")
    }
    if(GetMapName() == "sp_a2_bts1") {
        local button = null
        button = Entities.FindByName(button, "jailbreak_chamber_lit-jailbreak_chamber_cube_button")
        button.__KeyValueFromString("OnPressed", "@jailbreak_begin_logic,Trigger")
        button.__KeyValueFromString("OnPressed", "jailbreak_chamber_lit-power_loss_teleport,Enable")
        button.__KeyValueFromString("OnPressed", "jailbreak_chamber_lit-power_loss_portal_fizzle,Enable")
        button.__KeyValueFromString("OnPressed", "jailbreak_chamber_lit-power_loss_portal_fizzle,Disable,,0.5")
    }
    if(GetMapName() == "sp_a2_bts2") {
        EntFire("door_script", "RunScriptCode", "Setup()")
        EntFire("door_script", "Kill", "", 0.01)
        SendToConsole("ent_fire player_clip kill")
        SendToConsole("ent_fire fun_saver kill")
    }
    if(GetMapName() == "sp_a2_bts3") {
        EntFire("entry_airlock_door-open_door", "Trigger", "", 3)
        local trigger = Entities.CreateByClassname("trigger_multiple")
        trigger.SetAbsOrigin(Vector(9280, 5392, -256))
        trigger.SetAngles(0, 0, 0)
        trigger.SetSize(Vector(0, 0, 0), Vector(128, 2, 128))
        trigger.__KeyValueFromInt("Solid", 3)
        trigger.__KeyValueFromInt("CollisionGroup", 1)
        trigger.__KeyValueFromInt("Spawnflags", 1)
        trigger.__KeyValueFromString("targetname", "grapple_map_trigger")
        trigger.__KeyValueFromString("OnStartTouch", "grapple_broadcastclientcommand,Command,setpos_exact 9344.307617 5437.688965 -235.685913")
        trigger.__KeyValueFromString("OnStartTouch", "grapple_broadcastclientcommand,Command,portal_place 0 0 9335 5656 -320 0 270 0")
        trigger.__KeyValueFromString("OnStartTouch", "grapple_broadcastclientcommand,Command,portal_place 0 1 8992 6752 -193 0 270 0")
        EntFireByHandle(trigger, "Enable", "", 0, null, null)
    }
    if(GetMapName() == "sp_a2_bts4") {
        EntFire("fizzler_approach_trigger", "AddOutput", "OnStartTouch grapple_broadcastclientcommand,Command,portal_place 0 0 2511 -4864 6720 0 270 0,0.0,1")
        EntFire("fizzler_approach_trigger", "AddOutput", "OnStartTouch grapple_broadcastclientcommand,Command,portal_place 0 1 2064 -5154 6719 0 0 0,0.0,1")
        EntFire("fizzler_approach_trigger", "AddOutput", "OnStartTouch grapple_broadcastclientcommand,Command,script playerPickupDisable(1)")
        EntFire("control_room_blocking_doors", "TurnOn", "", 1)
        EntFire("control_room_blocking_doors", "EnableCollision", "", 1)
    }
    if(GetMapName() == "sp_a2_bts5") {
        SendToConsole("ent_fire control_room_door_clip kill")
        SendToConsole("ent_fire control_room_door kill")
    }
    if(GetMapName() == "sp_a2_core") {
        EntFire("socket_powered_rl", "AddOutput", "OnTrigger grapple_broadcastclientcommand,Command,script gunJustRetractDisable(0.0)")
    }
    if(GetMapName() == "sp_a3_01") {
        SendToConsole("ent_fire knockout-portalgun-spawn kill")
    }
    if(GetMapName() == "sp_a3_end") {
        local brush = null
        while(brush = Entities.FindByClassnameWithin(brush, "func_brush", Vector(-1728, 256, 638), 15)) {
            brush.Destroy()
        }
    }
    if(GetMapName() == "sp_a4_intro") {
        local trigger = null
        while(trigger = Entities.FindByClassnameWithin(trigger, "trigger_once", Vector(-816, 64, 320), 20)) {
            trigger.__KeyValueFromString("OnTrigger", "grapple_broadcastclientcommand,Command,portal_place 0 0 -656 -15 321 0 0 0")
            trigger.__KeyValueFromString("OnTrigger", "grapple_broadcastclientcommand,Command,portal_place 0 1 -860 -192 161 0 0 0")
        }
    }
    if(GetMapName() == "sp_a4_tb_intro") {
        SendToConsole("portal_place 0 0 1664 512 544 90 0 0")
        SendToConsole("portal_place 0 1 1664 895 -512 270 180 0")
    }
    if(GetMapName() == "sp_a4_tb_trust_drop") {
        SendToConsole("portal_place 0 0 351 1024 161 0 270 0")
        SendToConsole("portal_place 0 1 -192 450 930 270 90 0")
    }
    if(GetMapName() == "sp_a4_tb_wall_button") {
        SendToConsole("portal_place 0 0 32 1536 320 0 270 0")
        SendToConsole("portal_place 0 1 -472 959 448 0 0 0")
    }
    if(GetMapName() == "sp_a4_laser_platform") {
        //SendToConsole("ent_fire exit_door open")
        //SendToConsole("ent_fire door_areaportal open")
        //SendToConsole("ent_fire door_clip disable")
        //SendToConsole("ent_fire player_in_exit_door_chamber_side setvalue 0")
        SendToConsole("ent_fire puzzle_complete_trigger enable")
        SendToConsole("ent_fire exit_relay_powered setvalue 1")
    }
    if(GetMapName() == "sp_a4_finale3") {
        SendToConsole("portal_place 0 0 -384 -2495 414 0 0 0")
        SendToConsole("portal_place 0 1 -480 -1536 0 0 270 0")
        local trigger = Entities.CreateByClassname("trigger_once")
        trigger.SetAbsOrigin(Vector(-624, 5379, 272))
        trigger.SetAngles(0, 0, 0)
        trigger.SetSize(Vector(-64, -128, -128), Vector(64, 128, 128))
        trigger.__KeyValueFromInt("Solid", 3)
        trigger.__KeyValueFromInt("CollisionGroup", 1)
        trigger.__KeyValueFromInt("Spawnflags", 1)
        trigger.__KeyValueFromString("targetname", "grapple_map_transtrigger")
        trigger.__KeyValueFromString("OnStartTouch", "@transition_script,RunScriptCode,TransitionFromMap()")
        trigger.__KeyValueFromString("OnStartTouch", "grapple_broadcastclientcommand,Command,script gunDisable()")
        trigger = entLib.FindByName("grapple_map_transtrigger")
        //dev.DrawEntityBBox(trigger, 999999)
        EntFire("grapple_map_transtrigger", "Enable")
    }
    if(GetMapName() == "sp_a4_finale4") {
        ::canhitbombs <- 0
        EntFire("paint_white_event_relay", "AddOutput", "OnTrigger core_hit_trigger,Disable")
        EntFire("paint_white_event_relay", "AddOutput", "OnTrigger core_hit_trigger,Disable,,0.01")
        EntFire("paint_white_event_relay", "AddOutput", "OnTrigger core_hit_trigger,Enable,,14.0")
        EntFire("stalemate_relay", "AddOutput", "OnTrigger grapple_broadcastclientcommand,Command,portal_place 0 0 0 1504 256 90 90 0,3")
        EntFire("stalemate_relay", "AddOutput", "OnTrigger grapple_broadcastclientcommand,Command,portal_place 0 1 0 236 0 270 90 0,3")
        EntFire("stalemate_ending_relay", "AddOutput", "OnTrigger grapple_broadcastclientcommand,Command,script gunDisable()")
        EntFire("stalemate_ending_relay", "AddOutput", "OnTrigger grapple_crosshairtimer,Disable")
        EntFire("stalemate_ending_relay", "AddOutput", "OnTrigger grapple_broadcastclientcommand,Command,r_screenoverlay .,0.05")
        EntFire("stalemate_ending_relay", "AddOutput", "OnTrigger grapple_broadcastclientcommand,Command,r_screenoverlay .,0.05")
        EntFire("stalemate_ending_relay", "AddOutput", "OnTrigger grapple_broadcastclientcommand,Command,r_screenoverlay .,0.05")
        EntFire("vehicle_shoot_relay", "AddOutput", "OnTrigger grapple_broadcastclientcommand,Command,give_portalgun")
        EntFire("vehicle_shoot_relay", "AddOutput", "OnTrigger grapple_broadcastclientcommand,Command,upgrade_portalgun,0.1")
        EntFire("vehicle_shoot_relay", "AddOutput", "OnTrigger grapple_broadcastclientcommand,Command,ent_fire viewmodel enabledraw")
        EntFire("vehicle_shoot_relay", "AddOutput", "OnTrigger grapple_speedmod,ModifySpeed,1.0")
    }
}

function playerPickupDisable(action)
{
    if(action == 0) {
        dev.log("Enabling grapple pickup!")
        player_pickup_disable = 0
        //EntFire("grapple_map_pickupdisabledtext", "SetText", "")
        //EntFire("grapple_map_pickupdisabledtext", "Display", "", 0.01)
    }
    if(action == 1) {
        dev.log("Disabling grapple pickup!")
        player_pickup_disable = 1
        //EntFire("grapple_map_pickupdisabledtext", "SetText", "Grapple pickup disabled.")
        //EntFire("grapple_map_pickupdisabledtext", "Display", "", 0.01)
    }
}

::basemax_dist <- defmax_dist
::max_dist <- defmax_dist
function gunFireSetpoint()
{
    dev.log("Firing gun!")

    max_dist = basemax_dist

    ::ray <- bboxcast.TracePlayerEyes(max_dist, null, defaultSettings)
    if(ray.DidHit() == false) {
        SendToConsole("playvol ui/p2_store_ui_add_to_cart_01.wav 1")
        return
    }

    ::hitpos <- ray.GetHitpos()
    dev.log(hitpos)

    if(sparkfx_enable == 1) {
        sparkfx.SetOrigin(hitpos)
        EntFire("grapple_sparkfx", "SparkOnce")
    }

    if(GetDeveloperLevel() > 0) {
        dev.drawbox(hitpos, Vector(255,0,0), 5)
        dev.drawbox(ray.GetStartPos(), Vector(0,0,255), 5)
    }

    local timer = Entities.CreateByClassname("logic_timer")
    timer.__KeyValueFromString("targetname", "grapple_devline")
    timer.__KeyValueFromString("OnTimer", "grapple_broadcastclientcommand,Command,script devGrappleLine()")
    timer.__KeyValueFromString("OnTimer", "grapple_broadcastclientcommand,Command,script gunCheckPlayerPos()")
    timer.__KeyValueFromFloat("RefireTime", 0.01)
    timer.__KeyValueFromInt("StartDisabled", 0)
    EntFire("grapple_devline", "Enable")

    gunPickupObject()

    EntFire("grapple_playermovetimerrelay", "Enable")

    SendToConsole("playvol ui/ui_coop_hud_activate_01.wav 1")

    local offset = hitpos - (GetPlayer().GetCenter())
}

function gunPickupObject()
{
    if(player_pickup_disable == 1) {
        printl("Pickup is currently disabled!")
        gunFireStop(1)
        return
    }

    ::entwashit <- false
    if(ray.GetEntity() != null) {
        printl(ray.GetEntity())
        local ent = null
        while(ent = Entities.FindByClassnameWithin(ent, "prop_physics", hitpos, 10)) {
            ent.__KeyValueFromString("OnPlayerPickup", "grapple_broadcastclientcommand,Command,script gunJustRetractEnable(0.0)")
            //ent.__KeyValueFromString("OnPlayerPickup", "grapple_broadcastclientcommand,Command,playvol grapple_gun/gun_powerup.wav 0.5")
            ent.__KeyValueFromString("OnPhysGunDrop", "grapple_broadcastclientcommand,Command,script gunJustRetractDisable(0.0)")
            EntFire("grapple_pickupobjectrelay", "Trigger")
            printl("HIT PICKUPABLE ENTITY: " + ray.GetEntity())
        }
        while(ent = Entities.FindByClassnameWithin(ent, "prop_physics_override", hitpos, 10)) {
            ent.__KeyValueFromString("OnPlayerPickup", "grapple_broadcastclientcommand,Command,script gunJustRetractEnable(0.0)")
            //ent.__KeyValueFromString("OnPlayerPickup", "grapple_broadcastclientcommand,Command,playvol grapple_gun/gun_powerup.wav 0.5")
            ent.__KeyValueFromString("OnPhysGunDrop", "grapple_broadcastclientcommand,Command,script gunJustRetractDisable(0.0)")
            EntFire("grapple_pickupobjectrelay", "Trigger")
            printl("HIT PICKUPABLE ENTITY: " + ray.GetEntity())
        }
        while(ent = Entities.FindByClassnameWithin(ent, "prop_weighted_cube", hitpos, 10)) {
            ent.__KeyValueFromString("OnPlayerPickup", "grapple_broadcastclientcommand,Command,script gunJustRetractEnable(0.0)")
            //ent.__KeyValueFromString("OnPlayerPickup", "grapple_broadcastclientcommand,Command,playvol grapple_gun/gun_powerup.wav 0.5")
            ent.__KeyValueFromString("OnPhysGunDrop", "grapple_broadcastclientcommand,Command,script gunJustRetractDisable(0.0)")
            EntFire("grapple_pickupobjectrelay", "Trigger")
            printl("HIT PICKUPABLE ENTITY: " + ray.GetEntity())
        }
        while(ent = Entities.FindByClassnameWithin(ent, "prop_monster_box", hitpos, 10)) {
            ent.__KeyValueFromString("OnPlayerPickup", "grapple_broadcastclientcommand,Command,script gunJustRetractEnable(0.0)")
            //ent.__KeyValueFromString("OnPlayerPickup", "grapple_broadcastclientcommand,Command,playvol grapple_gun/gun_powerup.wav 0.5")
            ent.__KeyValueFromString("OnPhysGunDrop", "grapple_broadcastclientcommand,Command,script gunJustRetractDisable(0.0)")
            EntFire("grapple_pickupobjectrelay", "Trigger")
            printl("HIT PICKUPABLE ENTITY: " + ray.GetEntity())
        }
        while(ent = Entities.FindByClassnameWithin(ent, "npc_portal_turret_floor", hitpos, 10)) {
            ent.__KeyValueFromString("OnPhysGunPickup", "grapple_broadcastclientcommand,Command,script gunJustRetractEnable(0.0)")
            //ent.__KeyValueFromString("OnPlayerPickup", "grapple_broadcastclientcommand,Command,playvol grapple_gun/gun_powerup.wav 0.5")
            ent.__KeyValueFromString("OnPhysGunDrop", "grapple_broadcastclientcommand,Command,script gunJustRetractDisable(0.0)")
            EntFire("grapple_pickupobjectrelay", "Trigger")
            printl("HIT PICKUPABLE ENTITY: " + ray.GetEntity())
        }
        while(ent = Entities.FindByClassnameWithin(ent, "npc_personality_core", hitpos, 10)) {
            if(GetMapName() == "sp_a4_finale4") {
                SendToConsole("ent_fire !picker use")
                printl("HIT PICKUPABLE ENTITY: " + ray.GetEntity())
                gunFireStop(1)
                return
            }
            ent.__KeyValueFromString("OnPlayerPickup", "grapple_broadcastclientcommand,Command,script gunJustRetractEnable(0.0)")
            //ent.__KeyValueFromString("OnPlayerPickup", "grapple_broadcastclientcommand,Command,playvol grapple_gun/gun_powerup.wav 0.5")
            ent.__KeyValueFromString("OnPlayerDrop", "grapple_broadcastclientcommand,Command,script gunJustRetractDisable(0.0)")
            EntFire("grapple_pickupobjectrelay", "Trigger")
            printl("HIT PICKUPABLE ENTITY: " + ray.GetEntity())
        }
        while(ent = Entities.FindByClassnameWithin(ent, "prop_exploding_futbol", hitpos, 10)) {
            if(GetMapName() == "sp_a4_finale4") {
                EntFireByHandle(ent, "Dissolve", "", 0.0, null, null)
                ent.__KeyValueFromString("classname", "prop_physics")
                playerCollectBomb()
            }
            printl("HIT BOMB ENTITY: " + ray.GetEntity())
            EntFire("grapple_devline", "Kill")
            return
        }
        while(ent = Entities.FindByClassnameWithin(ent, "npc_security_camera", hitpos, 10)) {
            if(GetMapName() != "sp_a1_intro7") SendToConsole("ent_fire !picker ragdoll")
            printl("HIT BREAKABLE ENTITY: " + ray.GetEntity())
        }
        gunFireStop(1)
    }
}

function devGrappleLine()
{
    DebugDrawLine(GetPlayer().GetCenter(), hitpos, 0, 230, 255, false, -1.0)
}

function gunCheckPlayerPos()
{
    local offset = hitpos - (GetPlayer().GetCenter())
    if(offset.x > max_dist || offset.y > max_dist || offset.z > max_dist) gunMovePlayer()
    if(offset.x < (max_dist * -1) || offset.y < (max_dist * -1) || offset.z < (max_dist * -1)) gunMovePlayer()
}

::grapple_speed <- defgrapple_speed
function gunMovePlayer()
{
    local offset = hitpos - (GetPlayer().GetCenter())
    //printl("Offset: " + offset)
    offset = offset * grapple_speed
    GetPlayer().SetVelocity((GetPlayer().GetVelocity() * 0.25) + offset)
    DebugDrawLine(GetPlayer().GetCenter(), hitpos, 0, 230, 255, false, -1.0)
    SendToConsole("playvol ui/clickback_02_01.wav 0.1")
}

function gunFireStop(playsound)
{
    dev.log("Retracting gun!")
    EntFire("grapple_playermovetimerrelay", "Disable")
    EntFire("grapple_devline", "Kill")
    if(playsound == 0) return
    if(ray.DidHit() == false) return
    SendToConsole("playvol ui/p2_editor_konnektshun_destroyed_01.wav 1")
    max_dist = basemax_dist
}

function gunEnable()
{
    EntFire("grapple_broadcastclientcommand", "Command", "ent_fire grapple_gameui activate", 0.01)
    EntFire("grapple_broadcastclientcommand", "Command", "ent_remove weapon_portalgun", 0.01)
    EntFire("grapple_crosshaircontroltimer", "Enable", "", 0.01)
    SendToConsole("ent_remove_all weapon_portalgun")
}

function gunDisable()
{
    EntFire("grapple_broadcastclientcommand", "Command", "ent_fire grapple_gameui deactivate")
    EntFire("grapple_crosshaircontroltimer", "Disable")
    SendToConsole("r_screenoverlay .")
}

function gunJustRetractEnable(delay)
{
    gunDisable()
    EntFire("grapple_broadcastclientcommand", "Command", "ent_fire grapple_gameui_partial activate", delay)
    EntFire("grapple_crosshaircontroltimer", "Enable", "", delay)
    SendToConsole("ent_remove_all weapon_portalgun")
}

function gunJustRetractDisable(delay)
{
    EntFire("grapple_broadcastclientcommand", "Command", "ent_fire grapple_gameui_partial deactivate", delay)
    EntFire("grapple_crosshaircontroltimer", "Disable", "", delay)
    SendToConsole("r_screenoverlay .")
    gunEnable()
    gunFireStop(0)
}

function playerCrosshairControl()
{
    ::ray <- bboxcast.TracePlayerEyes(max_dist, null, defaultSettings)
    if(ray.DidHit() == false) {
        SendToConsole("r_screenoverlay crosshair/crosshair_invalid")
    }
    else {
        SendToConsole("r_screenoverlay crosshair/crosshair_valid")
    }
}

function playerBombCrosshairControl()
{
    ::ray <- bboxcast.TracePlayerEyes(max_dist, null, defaultSettings)
    local hitent = ray.GetEntity()
    local bombhitpos = ray.GetHitpos()
    if(hitent != null) {
        local ent = null
        while(ent = Entities.FindByNameWithin(ent, "grapple_shoottarget", bombhitpos, 300)) {
            SendToConsole("r_screenoverlay crosshair/crosshair_bomb_valid")
            return
        }
        SendToConsole("r_screenoverlay crosshair/crosshair_bomb_invalid")
    }
    else {
        SendToConsole("r_screenoverlay crosshair/crosshair_bomb_invalid")
    }
}

function bombFire()
{
    ::ray <- bboxcast.TracePlayerEyes(max_dist, null, defaultSettings)
    local hitent = ray.GetEntity()
    local bombhitpos = ray.GetHitpos()
    if(hitent != null) {
        local ent = null
        while(ent = Entities.FindByNameWithin(ent, "grapple_shoottarget", bombhitpos, 300)) {
            printl("Match detected!!")
            EntFire("grapple_bombshooter", "ShootFutbol")
            EntFire("grapple_broadcastclientcommand", "Command", "ent_fire grapple_bombgameui deactivate")
            gunEnable()
            SendToConsole("playvol ambient/alarms/klaxon1.wav 1")
            EntFire("grapple_bombtimer", "Disable")
            EntFire("grapple_bombcrosshaircontroltimer", "Disable")
            return
        }
        SendToConsole("playvol buttons/button_up.wav 1")
    }
    else {
        SendToConsole("playvol buttons/button_up.wav 1")
    }
}

function bombSetToPlayer()
{
    bombshoot.SetAbsOrigin((GetPlayer().GetOrigin()))
    bombshoot.SetAngles((GetPlayer().GetAngles()).x, (GetPlayer().GetAngles()).y, (GetPlayer().GetAngles()).z)
}

function playerCollectBomb()
{
    gunDisable()
    EntFire("grapple_broadcastclientcommand", "Command", "ent_fire grapple_bombgameui activate")
    SendToConsole("playvol music/sp_a2_bts1_x1.wav 1")
    SendToConsole("r_screenoverlay .")
    EntFire("grapple_bombtimer", "Enable")
    EntFire("grapple_bombcrosshaircontroltimer", "Enable")
}

function textEntCreator(name, message, xpos, ypos, color, channel)
{
    local ent = Entities.CreateByClassname("game_text")
    ent.__KeyValueFromString("targetname", name)
    ent.__KeyValueFromString("message", message)
    ent.__KeyValueFromFloat("x", xpos)
    ent.__KeyValueFromFloat("y", ypos)
    ent.__KeyValueFromString("color1", color)
    ent.__KeyValueFromInt("channel", channel)

    ent.__KeyValueFromInt("effect", 0)
    ent.__KeyValueFromString("holdtime", "9999999")
    ent.__KeyValueFromString("color2", color)
    ent.__KeyValueFromString("fadein", "0.5")
    ent.__KeyValueFromString("fadeout", "0.5")
    ent.__KeyValueFromString("fxtime", "0.5")
    ent.__KeyValueFromInt("spawnflags", 1)

    EntFireByHandle(ent, "SetTextColor", color, 0.0, null, null)
    EntFireByHandle(ent, "SetTextColor2", color, 0.0, null, null)
}




// Grapple Gun Mod ""Cvars"" (Use the command "script [command]" ingame):

function SetMaxGrappleDistance(value)
{
    printl("[Grapple Gun] Setting max grapple distance to " + value + ". (Default: " + defmax_dist + ", previous distance was: " + basemax_dist + ")")
    basemax_dist = value
}

function SetGrappleSpeed(value)
{
    printl("[Grapple Gun] Setting max grapple speed to " + value + ". (Default: " + defgrapple_speed + ", previous speed was: " + grapple_speed + ")")
    grapple_speed = value
}

function EnableSparkFX(value)
{
    if(value > 1) value = 1
    if(value < 0) value = 0
    if(value == 1) printl("Enabling spark effects! (Default: Disabled)")
    if(value == 1) printl("Disabling spark effects! (Default: Disabled)")
    sparkfx_enable = value
}

Init()