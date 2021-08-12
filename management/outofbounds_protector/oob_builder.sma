/***************************************************************************
 *   oob_builder.sma              Version 1.1           Date: AUGUST/02/2006
 *
 *   [OOB] Out-Of-Bounds Protector + Punishment (Zone Builder Plugin)
 *
 *   Builds Specified Zones in any map through console commands for use with
 *   associated "Zone Protector Plugin".
 *   Note:
 *      You only need this plugin installed to Build new Zones for maps!
 *      You may Remove this plugin afterwards, when running the server!
 *
 *   Original by:      Rob Secord, AKA xeroblood, AKA sufferer
 *   CS Updates by:    Dan Weeks, AKA Suicid3
 *   Ported to DoD by: Hell Phoenix              Hell_Phoenix@frenchys-pit.com
 *                     http://www.frenchys-pit.com
 *
 ***************************************************************************
 *   Changelog: 1.0  - Initial Release
 *              1.01 - Updated for AMX Mod X 1.01
 *                   - Added Team Support
 *              1.02 - Updated with Default OOB files
 *              1.1  - Ported to DoD
 ***************************************************************************
 *  Admin Commands: (None of them take any parameters, just the command only)
 *
 *    oob_start_zone    - First: Starts a new OOB-Zone from your current origin.
 *    oob_adjust_height - Second (Optional): Adjusts the height of the current
 *                         OOB-Zone with a +/- value (Raise/Lower).
 *    oob_save_zone     - Third: Saves current origins and shows Punishment Menu
 *                         and Delay Menu to Complete Zone.
 *    oob_cancel_zone   - Optional: Cancels The Current OOB-Zone at any time.
 *
 *    Note: After saving new zones in a map, you must reload the map before
 *          any of the newly added zones will be protected!
 *
 ***************************************************************************
 *  Admin CVARs:
 *
 *    oob_delay_seconds - Used for Delay Menu to set the number of seconds
 *                        of Delay for each punishment before action is taken.
 *
 ***************************************************************************/

#include <amxmodx>
#include <amxmisc>

// Change This to Your Desired Admin Access Level (From amxconst.inc)
#define REQD_LEVEL      ADMIN_LEVEL_A

// The Number of Available Punishments
#define MAX_PUNISHMENTS 6

// No need to change these..
#define TASK_DRAW       33450
#define TE_BEAMPOINTS   0
#define MAX_DELAY_TIMES 9

#define PLUGIN "OOB Zone Builder"
#define VERSION "1.1"
#define AUTHOR "AMXX DoD Community"

new bool:g_bZoneStarted = false
new bool:g_bMenuStarted = false

new g_sprBeam
new g_nOrigin[4][3]
new g_nRoofAdjust = 0
new g_nDelay = 0
new g_nPunishment = 0
new g_nTeam = 0

new g_szDelaySecs[MAX_DELAY_TIMES][4]
new g_szPunishment[MAX_PUNISHMENTS][] =
{
    "Kick",
    "Slay",
    "Slap Once",
    "Fire",
    "No Weapons",
    "Poison"
}

/*****************************************************************************************/
/**   Plugin Fowards Section                                                            **/
/*****************************************************************************************/

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)

    register_concmd( "oob_start_zone",    "StartOOBZone" )
    register_concmd( "oob_save_zone",     "SaveOOBZone" )
    register_concmd( "oob_cancel_zone",   "StopOOBZone" )
    register_concmd( "oob_adjust_height", "AdjustHeight" )

    register_cvar( "oob_delay_seconds", "0 1 2 3 4 5 10 15 20" )

    register_menucmd( register_menuid("\rOOB Punishment Menu:"), 1023, "SelectPunishment" )
    register_menucmd( register_menuid("\rOOB Delay Menu:"), 1023, "SelectDelay" )
    register_menucmd( register_menuid("\rOOB Team Menu:"), 1023, "SelectTeam" )
}

public plugin_precache()
{
    g_sprBeam = precache_model("sprites/zbeam4.spr")
}

/*****************************************************************************************/
/**   Client Commands Section                                                           **/
/*****************************************************************************************/

public StartOOBZone( id )
{
    if( !access( id, REQD_LEVEL ) )
        return PLUGIN_HANDLED

    if( g_bZoneStarted || g_bMenuStarted )
    {
        client_print( id, print_chat, "[OOB] You Must Complete the Current OOB-Zone First!" )
        client_print( id, print_console, "[OOB] You Must Complete the Current OOB-Zone First!^n" )
        return PLUGIN_HANDLED
    }
    g_bZoneStarted = true
    g_bMenuStarted = false

    get_user_origin( id, g_nOrigin[0] )
    client_print( id, print_chat, "[OOB] New OOB-Zone Started!" )
    client_print( id, print_console, "[OOB] New OOB-Zone Started!^n" )

    new pID[2]
    pID[0] = id
    set_task( 0.5, "DrawZone", (TASK_DRAW+id), pID, 1 )

    return PLUGIN_HANDLED
}

public StopOOBZone( id )
{
    if( !access( id, REQD_LEVEL ) )
        return PLUGIN_HANDLED

    if( !g_bZoneStarted && !g_bMenuStarted )
    {
        client_print( id, print_chat, "[OOB] You Have Not Started A New OOB-Zone to Stop!" )
        client_print( id, print_console, "[OOB] You Have Not Started A New OOB-Zone to Stop!^n" )
        return PLUGIN_HANDLED
    }
    g_bZoneStarted = false
    g_bMenuStarted = false
    g_nRoofAdjust = 0

    client_print( id, print_chat, "[OOB] Current OOB-Zone Discarded!" )
    client_print( id, print_console, "[OOB] Current OOB-Zone Discarded!^n" )

    return PLUGIN_HANDLED
}

public SaveOOBZone( id )
{
    if( !access( id, REQD_LEVEL ) )
        return PLUGIN_HANDLED

    if( g_bMenuStarted )
    {
        client_print( id, print_chat, "[OOB] You Must Complete The Current OOB-Zone First!" )
        client_print( id, print_console, "[OOB] You Must Complete The Current OOB-Zone First!^n" )
        return PLUGIN_HANDLED
    }
    if( !g_bZoneStarted )
    {
        client_print( id, print_chat, "[OOB] You Must Start A New OOB-Zone First!" )
        client_print( id, print_console, "[OOB] You Must Start A New OOB-Zone First!^n" )
        return PLUGIN_HANDLED
    }
    g_bZoneStarted = false
    g_bMenuStarted = true

    get_user_origin( id, g_nOrigin[2] )
    DrawSprites( 200, 0, 255, 0  )

    PunishmentMenu( id )

    return PLUGIN_HANDLED
}

public AdjustHeight( id )
{
    if( !access( id, REQD_LEVEL ) )
        return PLUGIN_HANDLED

    if( !g_bZoneStarted && g_bMenuStarted )
    {
        client_print( id, print_chat, "[OOB] You Must Finish Current OOB-Zone First!" )
        client_print( id, print_console, "[OOB] You Must Finish Current OOB-Zone First!^n" )
        return PLUGIN_HANDLED
    }else if( !g_bZoneStarted && !g_bMenuStarted )
    {
        client_print( id, print_chat, "[OOB] You Must Start A New OOB-Zone First!" )
        client_print( id, print_console, "[OOB] You Must Start A New OOB-Zone First!^n" )
        return PLUGIN_HANDLED
    }

    new argv[5]
    read_argv( 1, argv, 4 )

    if( !argv[0] )
    {
        client_print( id, print_console, "Usage: oob_adjust_height <[+/-]#>^n" )
        client_print( id, print_console, "Example: oob_adjust_height -10^n" )
        client_print( id, print_console, "Current Height (0=Head Level): %d^n", g_nRoofAdjust )
        return PLUGIN_HANDLED
    }

    g_nRoofAdjust += str_to_num( argv )
    client_print( id, print_chat, "[OOB] New Top Level: %d", g_nRoofAdjust )
    client_print( id, print_console, "[OOB] New Top Level: %d^n", g_nRoofAdjust )

    return PLUGIN_HANDLED
}

/*****************************************************************************************/
/**   Punishment Menu Section                                                           **/
/*****************************************************************************************/

public PunishmentMenu( id )
{
    new szMenuBody[512]
    new i, nKeys = (1<<9), nLen = 0

    nLen = format( szMenuBody, 511, "\rOOB Punishment Menu:^n\w" )
    for( i = 0; i < MAX_PUNISHMENTS; i++ )
    {
        nKeys |= (1<<i)
        nLen += format( szMenuBody[nLen], (511-nLen), "\w%d. %s^n", (i+1), g_szPunishment[i] )
    }
    format( szMenuBody[nLen], (511-nLen), "^n\w0. Cancel OOB Zone!" )

    show_menu( id, nKeys, szMenuBody )

    return PLUGIN_HANDLED
}

public DelayMenu( id )
{
    new szMenuBody[512], szDelayCvar[64]
    new i, nKeys = (1<<9), nLen = 0

    get_cvar_string( "oob_delay_seconds", szDelayCvar, 63 )
    if( szDelayCvar[0] )
        ExplodeStr( g_szDelaySecs, 3, szDelayCvar, ' ' )
    else
        ExplodeStr( g_szDelaySecs, 3, "0 1 2 3 4 5 10 15 20", ' ' )

    nLen = format( szMenuBody, 511, "\rOOB Delay Menu:^n\w" )
    for( i = 0; i < MAX_DELAY_TIMES; i++ )
    {
        if( !g_szDelaySecs[i][0] ) break
        nKeys |= (1<<i)
        nLen += format( szMenuBody[nLen], (511-nLen), "\w%d. %s Second Delay^n", (i+1), g_szDelaySecs[i] )
    }
    format( szMenuBody[nLen], (511-nLen), "^n\w0. Cancel OOB Zone!" )

    show_menu( id, nKeys, szMenuBody )

    return PLUGIN_HANDLED
}

public TeamMenu( id )
{
    new szMenuBody[512]
    new nKeys, nLen = 0

    nKeys = (1<<0) | (1<<1) | (1<<2) | (1<<9)

    nLen = format( szMenuBody, 511, "\rOOB Team Menu:^n\w" )
    nLen += format( szMenuBody[nLen], (511-nLen), "\w1. Both Teams^n" )
    nLen += format( szMenuBody[nLen], (511-nLen), "\w2. Allies Only^n" )
    nLen += format( szMenuBody[nLen], (511-nLen), "\w3. Axis Only^n" )
    nLen += format( szMenuBody[nLen], (511-nLen), "^n\w0. Cancel OOB Zone!" )

    show_menu( id, nKeys, szMenuBody )

    return PLUGIN_HANDLED
}

public SelectPunishment( id, key )
{
    if( key == 9 )
    {
        StopOOBZone( id )
        return PLUGIN_HANDLED
    }

    g_nPunishment = key
    DelayMenu( id )

    return PLUGIN_HANDLED
}

public SelectDelay( id, key )
{
    if( key == 9 )
    {
        StopOOBZone( id )
        return PLUGIN_HANDLED
    }

    g_nDelay = str_to_num( g_szDelaySecs[key] )
    TeamMenu( id )
    
    return PLUGIN_HANDLED
}

public SelectTeam( id, key )
{
    if( key == 9 )
    {
        StopOOBZone( id )
        return PLUGIN_HANDLED
    }

    g_nTeam = key
    WritePointsFile()

    g_bMenuStarted = false
    g_nRoofAdjust = 0
    client_print( id, print_chat, "[OOB] Current Zone Saved Successfully!" )

    return PLUGIN_HANDLED
}

/*****************************************************************************************/
/**   Looped SpriteDraw Function                                                        **/
/*****************************************************************************************/

public DrawZone( p_aCmdArgs[] )
{
    get_user_origin( p_aCmdArgs[0], g_nOrigin[2] )
    DrawSprites( 1, 0, 0, 255 )

    if( g_bZoneStarted )
        set_task( 0.1, "DrawZone", (TASK_DRAW+p_aCmdArgs[0]), p_aCmdArgs, 1 )

    return PLUGIN_CONTINUE
}

/*****************************************************************************************/
/**   Plugin Specific Functions                                                         **/
/*****************************************************************************************/

// Draws a Box Around Current Zone with Beam Sprites..
// Sprites Last on Screen (life/10) Seconds..
DrawSprites( life, r, g, b )
{
    new i, j, h

    g_nOrigin[1][0] = g_nOrigin[0][0]
    g_nOrigin[1][1] = g_nOrigin[2][1]
    g_nOrigin[3][0] = g_nOrigin[2][0]
    g_nOrigin[3][1] = g_nOrigin[0][1]

    for( i = 0; i < 2; i++ )
    {
        h = (i>0)?(35+g_nRoofAdjust):(-30)
        for( j = 0; j < 4; j++ )
        {
            message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
            write_byte( TE_BEAMPOINTS )
            write_coord( g_nOrigin[j][0] )
            write_coord( g_nOrigin[j][1] )
            write_coord( g_nOrigin[0][2]+h )
            write_coord( g_nOrigin[((j<3)?(j+1):0)][0] )
            write_coord( g_nOrigin[((j<3)?(j+1):0)][1] )
            write_coord( g_nOrigin[0][2]+h )
            write_short( g_sprBeam )        // model
            write_byte( 0 )                 // start frame
            write_byte( 0 )                 // framerate
            write_byte( life )              // life
            write_byte( 15 )                // width
            write_byte( 0 )                 // noise
            write_byte( r )                 // red
            write_byte( g )                 // green
            write_byte( b )                 // blue
            write_byte( 100 )               // brightness
            write_byte( 0 )                 // speed
            message_end()
        }
    }

    return
}

// Writes OOB File to: addons/amxmodx/configs/oob/<mapname>.oob
WritePointsFile()
{
    new szMap[32], szDir[32], szFile[64]
    get_mapname( szMap, 31 )
    get_configsdir( szDir, 31 )

    format( szFile, 63, "%s/oob/%s.oob", szDir, szMap )
    log_amx( "OOB Builder: Writing to OOB File '%s'", szFile )

    new szFilePoints[64]
    format( szFilePoints, 63, "%d %d %d %d %d %d %d %d %d",
        g_nOrigin[0][0],  g_nOrigin[0][1],  g_nOrigin[0][2] - 30,
        g_nOrigin[2][0],  g_nOrigin[2][1],  g_nOrigin[0][2] + 35 + g_nRoofAdjust,
        g_nDelay, g_nPunishment, g_nTeam )

    write_file( szFile, szFilePoints )

    return
}

// Explodes a String into 2D Array seperated by 'delimiter'
ExplodeStr( output[][], max_len, input[], delimiter )
{
    new nIdx = 0, nLen = (1 + copyc( output[nIdx], max_len, input, delimiter ))
    while( nLen < strlen(input) )
        nLen += (1 + copyc( output[++nIdx], max_len, input[nLen], delimiter ))
    return
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
