// =====================================================================
//  photomode.nut  -  script side of photomode.cfg
//  Lives in tf_goldrush/scripts/vscripts/  (photomode.cfg loads it)
//
//  - Camera tilt: changes only the roll, keeps where you're looking.
//  - FOV 10..120: set on the player directly, because the "fov" command
//    is capped at 90 by the game.
//  - Noclip: set on/off directly instead of toggling, and re-applied
//    (with FOV) if you respawn while photo mode is on.
// =====================================================================

// ---- Settings -------------------------------------------------------
::PM_RollStep   <- 5.0;     // degrees per Alt+scroll notch
::PM_RollMax    <- 45.0;    // tilt limit in each direction
::PM_FovStep    <- 5;
::PM_FovMin     <- 10;
::PM_FovMax     <- 120;
::PM_FovDefault <- 90;

// ---- State ----------------------------------------------------------
::PM_Active <- false;
::PM_Roll   <- 0.0;
::PM_Fov    <- ::PM_FovDefault;

::PM_MOVETYPE_WALK   <- 2;   // MOVETYPE_WALK
::PM_MOVETYPE_NOCLIP <- 8;   // MOVETYPE_NOCLIP

// ---- Tilt -----------------------------------------------------------
::PM_ApplyRoll <- function()
{
    local player = GetListenServerHost();
    if (player == null)
        return;

    local ang = player.EyeAngles();
    player.SnapEyeAngles(QAngle(ang.x, ang.y, ::PM_Roll));
}

// direction: -1 = tilt left, 1 = tilt right
::PM_Tilt <- function(direction)
{
    ::PM_Roll += direction * ::PM_RollStep;
    if (::PM_Roll >  ::PM_RollMax) ::PM_Roll =  ::PM_RollMax;
    if (::PM_Roll < -::PM_RollMax) ::PM_Roll = -::PM_RollMax;
    ::PM_ApplyRoll();
}

::PM_TiltReset <- function()
{
    ::PM_Roll = 0.0;
    ::PM_ApplyRoll();
}

// ---- FOV ------------------------------------------------------------
// Sets the player's zoom FOV (m_iFOV) directly. Unlike the "fov" command
// this isn't capped at 90, and unlike env_zoom it works in multiplayer.
::PM_ApplyFov <- function()
{
    local player = GetListenServerHost();
    if (player == null)
        return;

    NetProps.SetPropInt(player, "m_iFOVStart", ::PM_Fov);   // no zoom animation
    NetProps.SetPropInt(player, "m_iFOV", ::PM_Fov);
}

// direction: -1 = narrower (zoom in), 1 = wider
::PM_FovChange <- function(direction)
{
    ::PM_Fov += direction * ::PM_FovStep;
    if (::PM_Fov > ::PM_FovMax) ::PM_Fov = ::PM_FovMax;
    if (::PM_Fov < ::PM_FovMin) ::PM_Fov = ::PM_FovMin;
    ::PM_ApplyFov();
}

::PM_FovReset <- function()
{
    ::PM_Fov = ::PM_FovDefault;
    ::PM_ApplyFov();
}

// Back to your normal FOV (fov_desired)
::PM_FovClear <- function()
{
    local player = GetListenServerHost();
    if (player == null)
        return;

    NetProps.SetPropInt(player, "m_iFOVStart", NetProps.GetPropInt(player, "m_iDefaultFOV"));
    NetProps.SetPropInt(player, "m_iFOV", 0);
}

// ---- Noclip ---------------------------------------------------------
::PM_SetNoclip <- function(on)
{
    local player = GetListenServerHost();
    if (player == null)
        return;

    local isOn = (player.GetMoveType() == ::PM_MOVETYPE_NOCLIP);
    if (on && !isOn)
        player.SetMoveType(::PM_MOVETYPE_NOCLIP, 0);
    else if (!on && isOn)
        player.SetMoveType(::PM_MOVETYPE_WALK, 0);   // exit somewhere open, not inside a wall
}

// ---- Enter / exit / reset ------------------------------------------
::PM_Enter <- function()
{
    ::PM_Active = true;
    ::PM_Roll = 0.0;
    ::PM_Fov = ::PM_FovDefault;
    ::PM_SetNoclip(true);
    ::PM_ApplyFov();
}

::PM_Exit <- function()
{
    ::PM_Active = false;
    ::PM_TiltReset();
    ::PM_FovClear();
    ::PM_SetNoclip(false);
}

::PM_Reset <- function()
{
    ::PM_TiltReset();
    ::PM_FovReset();
}

// ---- Re-apply after a respawn ---------------------------------------
::PM_Reapply <- function()
{
    if (!::PM_Active)
        return;
    ::PM_Roll = 0.0;            // a fresh spawn has no roll
    ::PM_SetNoclip(true);
    ::PM_ApplyFov();
}

::PM_OnSpawn <- function(params)
{
    if (!::PM_Active)
        return;
    local player = GetPlayerFromUserID(params.userid);
    if (player == null || player != GetListenServerHost())
        return;
    EntFireByHandle(player, "RunScriptCode", "::PM_Reapply()", 0.1, null, null);
}

// Replacing the table each time this file runs drops the old listener,
// so re-running photomode never registers it twice.
::PM_Events <- {
    OnGameEvent_player_spawn = function(params) { ::PM_OnSpawn(params); }
};
__CollectGameEventCallbacks(::PM_Events);
