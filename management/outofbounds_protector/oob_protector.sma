/***************************************************************************
*   oob_protector.sma            Version 1.1            Date: AUGUST/02/2006
*
*   [OOB] Out-Of-Bounds Protector + Punishment (Zone Protector Plugin)
*
*   Protects Specified Zones in any DoD map from exploitation by defining
*   seperate punishments for each Zone!
*
*   Note: Use associated oob_builder to Build Custom Zones!
*
*   Original by:      Rob Secord, AKA xeroblood, AKA sufferer
*   CS Updates by:    Dan Weeks, AKA Suicid3
*   Ported to DoD by: Hell Phoenix              Hell_Phoenix@frenchys-pit.com
*                     http://www.frenchys-pit.com
*
*
***************************************************************************
*   Changelog: 1.0  - Initial Release
*              1.01 - Updated for AMX Mod X 1.01
*                   - Added Team Support
*              1.02 - Updated with Default OOB files
*	       1.1  - Ported to DoD
*                   - Updated to use cvar pointers (which means it requires amxx 1.70 or above)
*
***************************************************************************
*   Todo: - Nothing
*         
***************************************************************************
*  Admin Commands: 
*
*    oob_mode - Enables/Disables OOB-Protector Plugin
*               (Toggle Switch, no Parameters).
*
***************************************************************************
*  Admin CVARs:
*
*   oob_obey_immunity   <0|1> - If 1 plugin must obey immunity rights.
*   oob_delay_between    <#>  - Sets the number of seconds between punishments if inflicted.
*   oob_slap_damage      <#>  - The Amount of Damage Taken on Slap Punishment.
*   oob_fire_damage      <#>  - The Amount of Damage Taken on Fire Punishment.
*   oob_poison_damage    <#>  - The Amount of Damage Taken on Poison Punishment.
*
***************************************************************************/


#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <dodfun>


// Admin Access Level Required for Turning Plugin On/Off
#define REQD_LVL ADMIN_LEVEL_B

// Maximum OOB Zones Per Map to Protect (Change if more required)
#define MAX_OOB_ZONES 16

// No need to change these..
#define MAX_PLAYERS     32
#define MAX_LINE_LEN    256
#define MAX_PUNISHMENTS 6
#define TASK_PROTECT    34450
#define TE_BEAMPOINTS   0
#define TE_SPRITE       17
#define TE_SMOKE        5

// Looped Punishments
#define OOB_FIRE   1
#define OOB_NOGUNS 3
#define OOB_POISON 4

#define PLUGIN "OOB Zone Protector"
#define VERSION "1.1"
#define AUTHOR "AMXX DoD Community"

// For Cvar use
new g_immunity
new g_delay
new g_slap_damage
new g_fire_damage
new g_poison_damage

// Have any OOB-Zones been found for current map?
new bool:g_bProtectOOB = false

// Keeps Track of Players' Punishments
new g_nUserPunished[MAX_PLAYERS] = 0

// 2 sets of XYZ Coords for Each Zone (mins/maxs)
new g_nZonePoints[MAX_OOB_ZONES*2][3]

// [0] = Delay, [1] = Punishment, [2] = Team
new g_nZoneSettings[MAX_OOB_ZONES][3]

// Holds time in seconds user has been in OOB-Zone
new g_nUserZoneTime[MAX_PLAYERS] = 0

// Keeps track of the number of currently loaded zones..
new g_nNumLoadedZones = 0

// Sprite used to outline Active OOB-Zones
new g_sprBeam

// Sprites used for Fire Effects
new g_sprSmoke
new g_sprMFlash

// Sound Effects..
new g_szSndFlames[] = "ambience/flameburst1.wav"
new g_szSndScream[] = "scientist/scream21.wav"
new g_szSndPoison[] = "player/damage10.wav"

// Default Guns for T/CT
new g_szDefaultGuns[2][] = { DODW_LUGER, DODW_COLT }

// Punishment warning strings..
new g_szPunishment[MAX_PUNISHMENTS][] =
{
	"Be Kicked",
	"Be Slain",
	"Be Slapped",
	"Be Torched",
	"Lose Weapons",
	"Be Poisoned"
}
/*
Restricted Zone: Leave In %d Seconds Or %s You Will
Restricted Zone: Now %s For Not Leaving!
Restricted Zone: %s Immediately!
*/

/*****************************************************************************************/
/**   Plugin Fowards Section                                                            **/
/*****************************************************************************************/

public plugin_init()
	{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_concmd( "oob_mode", "ToggleOOB", REQD_LVL, "<on|off> Enables/Disables OOB Zones." )
	
	g_immunity = register_cvar( "oob_obey_immunity", "0" )
	g_delay = register_cvar( "oob_delay_between", "3" )
	g_slap_damage = register_cvar( "oob_slap_damage",   "5" )
	g_fire_damage = register_cvar( "oob_fire_damage",   "5" )
	g_poison_damage = register_cvar( "oob_poison_damage", "5" )
}

public plugin_cfg()
	{
	g_bProtectOOB = ReadPointsFile()
	if( g_bProtectOOB )
		set_task( 10.0, "CheckZones", TASK_PROTECT )
}

public plugin_precache()
	{
	g_sprBeam   = precache_model("sprites/zbeam4.spr")
	g_sprSmoke  = precache_model( "sprites/steam1.spr" )
	g_sprMFlash = precache_model( "sprites/muzzleflash.spr" )
	precache_sound( g_szSndFlames )
	precache_sound( g_szSndScream )
	precache_sound( g_szSndPoison )
}

/*****************************************************************************************/
/**   Client Commands Section                                                           **/
/*****************************************************************************************/

public ToggleOOB( id, lvl, cid )
	{
	if( !cmd_access( id, lvl, cid, 2 ) )
		return PLUGIN_HANDLED
	
	new szArg[32]
	read_argv( 1, szArg, 31 )
	g_bProtectOOB = ( equali( szArg, "on" ) || equali( szArg, "1" ) ) ? true : false
	
	console_print( id, "OOB Protector: Zones %s", g_bProtectOOB?"Enabled":"Disabled" )
	
	if( g_bProtectOOB && !task_exists( TASK_PROTECT ) )
		set_task( 1.0, "CheckZones", TASK_PROTECT )
	
	return PLUGIN_HANDLED
}

/*****************************************************************************************/
/**   Looped CheckZones Function                                                        **/
/*****************************************************************************************/

public CheckZones()
	{
	if( !g_bProtectOOB ) return PLUGIN_HANDLED
	
	new i, nNum, nIdx, nTime
	new nPlayers[32], nUserOrigin[3]
	
	new team[25]
	
	set_hudmessage( 30, 30, 255, _, -1.0, _, 1.0, 3.0, _, _, _ )
	get_players( nPlayers, nNum, "ac" )
	for( i = 0; i < nNum; i++ )
		{
		if( PlayerHasImmunity( nPlayers[i] ) ) continue
		get_user_origin( nPlayers[i], nUserOrigin )
		nIdx = InsideZone( nUserOrigin )
		
		get_user_team(nPlayers[i],team,24)
		
		if( nIdx > (-1) )
			{
			if( (g_nZoneSettings[nIdx][2] == 0) || (g_nZoneSettings[nIdx][2] == 1 && equal(team,"Allies")) || (g_nZoneSettings[nIdx][2] == 2 && equal(team,"Axis")))
				{
				DrawSprites( nIdx, 10, 255, 0, 0 )
				
				if( g_nUserPunished[nPlayers[i]-1] > 0 )
					{
					IssuePun( nPlayers[i], g_nZoneSettings[nIdx][1] )
					continue
				}
				if( g_nZoneSettings[nIdx][0] > 0 )
					{
					if( g_nUserZoneTime[nPlayers[i]-1] < 0 )
						{
						g_nUserZoneTime[nPlayers[i]-1]++
						continue
					}
					
					nTime = (g_nZoneSettings[nIdx][0]-g_nUserZoneTime[nPlayers[i]-1]++)
					if( nTime > 0 )
						{
						show_hudmessage( nPlayers[i], "Restricted Zone: Leave In %d Seconds Or You Will %s!", nTime, g_szPunishment[g_nZoneSettings[nIdx][1]] )
					}else
					{
						IssuePun( nPlayers[i], g_nZoneSettings[nIdx][1] )
						show_hudmessage( nPlayers[i], "Restricted Zone: Now You Will %s For Not Leaving!", g_szPunishment[g_nZoneSettings[nIdx][1]] )
						g_nUserZoneTime[nPlayers[i]-1] = (get_pcvar_num(g_delay) * (-1))
					}
				}else
				{
					IssuePun( nPlayers[i], g_nZoneSettings[nIdx][1] )
					show_hudmessage( nPlayers[i], "Restricted Zone: You Will %s Immediately!", g_szPunishment[g_nZoneSettings[nIdx][1]] )
				}
			}
		}else
		{
			if( g_nUserPunished[nPlayers[i]-1] > 0 )
				RemovePun( nPlayers[i] )
			g_nUserZoneTime[nPlayers[i]-1] = 0
		}
	}
	
	set_task( 1.0, "CheckZones", TASK_PROTECT )
	return PLUGIN_CONTINUE
}

/*****************************************************************************************/
/**   Punishment Functions                                                              **/
/*****************************************************************************************/

IssuePun( id, idx )
{
	switch( idx )
	{
		case 0: server_cmd( "kick #%d", get_user_userid( id ) )
		case 1: user_kill( id )
		case 2: user_slap( id, clamp(get_pcvar_num(g_slap_damage), 1, 99) )
		case 3:
		{
			if( !g_nUserPunished[id-1] )
				{
				g_nUserPunished[id-1] = OOB_FIRE
				new pID[2]
				pID[0] = id
				IgnitePlayer( pID )
				IgniteEffects( pID )
			}
		}
		case 4:
		{
			if( !g_nUserPunished[id-1] )
				{
				g_nUserPunished[id-1] = OOB_NOGUNS
				StripWeapons( id )
			}else
			if(get_user_team(id) == 2){ 
				engclient_cmd(id,"weapon_spade")
			} 
			else if(get_user_team(id) == 1){ 
				engclient_cmd(id,"weapon_amerknife")
			}
		}
		case 5:
		{
			if( !g_nUserPunished[id-1] )
				{
				g_nUserPunished[id-1] = OOB_POISON
				new pID[2]
				pID[0] = id
				PoisonEffects( pID )
			}
		}
	}
	return
}

RemovePun( id )
{
	console_print( 0, "[OOB-DEBUG] RemovePun Called: pun=%d", g_nUserPunished[id-1] )
	
	if( g_nUserPunished[id-1] == OOB_NOGUNS )
		{
		console_print( 0, "[OOB-DEBUG] RemovePun Called: GiveGun: %s", g_szDefaultGuns[get_user_team(id)-1] )
		give_item( id, g_szDefaultGuns[get_user_team(id)-1] )
	}
	g_nUserPunished[id-1] = 0
	
	return
}

StripWeapons( id )
{
	new nOrigin[3]
	
	get_user_origin( id, nOrigin )
	nOrigin[2] -= 1024
	set_user_origin( id, nOrigin )
	
	strip_user_weapons(id)
	if(get_user_team(id) == 2){ 
		give_item(id,"weapon_spade")
	} 
	else if(get_user_team(id) == 1){ 
		give_item(id,"weapon_amerknife")
	}
	
	nOrigin[2] += 1028
	set_user_origin( id, nOrigin )
	
	return
}

/*****************************************************************************************/
/**   Plugin Specific Functions                                                         **/
/*****************************************************************************************/

// reads OOB file from: addons/amxmodx/configs/oob/<mapname>.oob
bool:ReadPointsFile()
{
	new szMap[32], szDir[64], szFile[96]
	get_mapname( szMap, 31 )
	get_configsdir( szDir, 63 )
	
	format( szFile, 95, "%s/oob/%s.oob", szDir, szMap )
	if( !file_exists( szFile ) )
		{
		server_print( "OOB Protector: File Not Found '%s'", szFile )
		server_print( "OOB Protector: Will Remain Idle For Current Map!" )
		log_amx( "OOB Protector: File Not Found '%s'", szFile )
		return false
	}
	
	new i, j, nIdx = 0, nPos = 0, nLen = 0, nCnt = 0
	new szLine[MAX_LINE_LEN], szPoints[9][8]
	
	log_amx( "OOB Protector: Reading OOB File '%s'", szFile )
	while( read_file( szFile, nPos++, szLine, MAX_LINE_LEN-1, nLen ) )
		{
		if( !nLen || szLine[0] == ';' ) continue
		ExplodeStr( szPoints, 7, szLine, ' ' )
		
		if( nIdx < MAX_OOB_ZONES*2 )
			{
			for( i = 0; i < 3; i++ )
				{
				if(i < 2)
					{
					for( j = 0; j < 3; j++ )
						g_nZonePoints[nIdx+i][j] = str_to_num( szPoints[(i*3)+j] )
				}
				g_nZoneSettings[nCnt][i] = str_to_num( szPoints[6+i] )
			}
			nIdx += 2
			nCnt++
		}else break
	}
	
	g_nNumLoadedZones = (nIdx/2)
	if( g_nNumLoadedZones <= 0 )
		{
		g_nNumLoadedZones = 0
		server_print( "OOB Protector: No OOB Zones Found in File '%s'", szFile )
		server_print( "OOB Protector: Will Remain Idle For Current Map!" )
		log_amx( "OOB Protector: NO OOB Zones Found in File '%s'", szFile )
		return false
	}
	
	log_amx( "OOB Protector: Loaded %d OOB Zones from '%s'", g_nNumLoadedZones, szFile )
	return true
}

// Explodes a String into 2D Array seperated by 'delimiter'
ExplodeStr( output[][], max_len, input[], delimiter )
{
	new nIdx = 0, nLen = (1 + copyc( output[nIdx], max_len, input, delimiter ))
	while( nLen < strlen(input) )
		nLen += (1 + copyc( output[++nIdx], max_len, input[nLen], delimiter ))
	return
}

// Checks if a players origin is inside any OOB-Zones.
InsideZone( origin[] )
{
	new i, j, nInsideIdx = (-1)
	new bool:bInsidePoint[3] = false
	
	for( i = 0; i < g_nNumLoadedZones*2; i+=2 )
		{
		for( j = 0; j < 3; j++ )
			{
			if( g_nZonePoints[i][j] < g_nZonePoints[i+1][j] )
				{
				if( (g_nZonePoints[i][j]-1) <= origin[j] <= (g_nZonePoints[i+1][j]+1) )
					bInsidePoint[j] = true
			}else
			{
				if( (g_nZonePoints[i+1][j]-1) <= origin[j] <= (g_nZonePoints[i][j]+1) )
					bInsidePoint[j] = true
			}
		}
		
		if( bInsidePoint[0] && bInsidePoint[1] && bInsidePoint[2] )
			{
			nInsideIdx = (i / 2)
			break
		}else bInsidePoint[0] = bInsidePoint[1] = bInsidePoint[2] = false
	}
	
	return nInsideIdx
}

bool:PlayerHasImmunity( id )
{
	if( get_pcvar_num(g_immunity) )
		return (get_user_flags( id ) & ADMIN_IMMUNITY) ? true : false
	
	return false
}

// Sprites Last on Screen (life/10) Seconds..
DrawSprites( idx, life, r, g, b )
{
	new i, j, k, l
	new nOrigins[8][3]
	new nIncrement[4][3] = { {0,0,0}, {0,1,0}, {1,1,0}, {1,0,0} }
	
	idx *= 2
	for( i = 0; i < 2; i++ )
		for( j = 0; j < 4; j++ )
		for( k = 0; k < 3; k++ )
		{
		l = (k==2) ? idx+i+nIncrement[j][k] : idx+nIncrement[j][k]
		nOrigins[(i*4)+j][k] = g_nZonePoints[l][k]
	}
	
	for( i = 0; i < 2; i++ )
		{
		for( j = 0; j < 4; j++ )
			{
			k = (j==3) ? (i*4) : ((i*4)+j)+1
			message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
			write_byte( TE_BEAMPOINTS )
			write_coord( nOrigins[((i*4)+j)][0] )
			write_coord( nOrigins[((i*4)+j)][1] )
			write_coord( nOrigins[((i*4)+j)][2] )
			write_coord( nOrigins[k][0] )
			write_coord( nOrigins[k][1] )
			write_coord( nOrigins[k][2] )
			write_short( g_sprBeam )        // model
			write_byte( 0 )                 // start frame
			write_byte( 0 )                 // framerate
			write_byte( life )              // life
			write_byte( 15 )                // width
			write_byte( 0 )                 // noise
			write_byte( r )                 // red
			write_byte( g )                 // green
			write_byte( b )                 // blue
			write_byte( 64 )                // brightness
			write_byte( 0 )                 // speed
			message_end()
		}
	}
	
	return
}

/***************************************************************************
********  Fire Effects By f117bomb (Slightly Modified)  *******************
**************************************************************************/

public IgniteEffects( p_aCmdArgs[] )
	{
	new id = p_aCmdArgs[0]
	
	if( is_user_alive(id) && (g_nUserPunished[id-1] == OOB_FIRE) )
		{
		new nOrigin[3]
		get_user_origin( id, nOrigin )
		
		message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
		write_byte( TE_SPRITE )
		write_coord( nOrigin[0] )  // coord, coord, coord (position)
		write_coord( nOrigin[1] )
		write_coord( nOrigin[2] )
		write_short( g_sprMFlash ) // short (sprite index)
		write_byte( 20 )           // byte (scale in 0.1's)
		write_byte( 200 )          // byte (brightness)
		message_end()
		
		message_begin( MSG_BROADCAST, SVC_TEMPENTITY, nOrigin )
		write_byte( TE_SMOKE )
		write_coord( nOrigin[0] )  // coord coord coord (position)
		write_coord( nOrigin[1] )
		write_coord( nOrigin[2] )
		write_short( g_sprSmoke )  // short (sprite index)
		write_byte( 20 )           // byte (scale in 0.1's)
		write_byte( 15 )           // byte (framerate)
		message_end()
		
		set_task( 0.2, "IgniteEffects", 0, p_aCmdArgs, 1 )
	}
	else
		{
		if( g_nUserPunished[id-1] == OOB_FIRE )
			{
			emit_sound( id, CHAN_AUTO, g_szSndScream, 0.6, ATTN_NORM, 0, PITCH_HIGH )
			g_nUserPunished[id-1] = 0
		}
	}
	return PLUGIN_CONTINUE
}

public IgnitePlayer( p_aCmdArgs[] )
	{
	new id = p_aCmdArgs[0]
	
	if( is_user_alive(id) && (g_nUserPunished[id-1] == OOB_FIRE) )
		{
		new nOrigin[3]
		new nHP = get_user_health( id )
		new nDmg = clamp( get_pcvar_num(g_fire_damage), 1, 20 )
		get_user_origin( id, nOrigin )
		
		set_user_health( id, (nHP-nDmg) )
		
		//create some sound
		emit_sound( id, CHAN_ITEM, g_szSndFlames, 0.6, ATTN_NORM, 0, PITCH_NORM )
		
		//Call Again in 2 seconds
		set_task( 2.0, "IgnitePlayer", 0, p_aCmdArgs, 1 )
	}
	
	return PLUGIN_CONTINUE
}

/***************************************************************************
********  Poison Effects By AssKicR (Slightly Modified)  ******************
**************************************************************************/

public PoisonEffects( p_aCmdArgs[] )
	{
	new id = p_aCmdArgs[0]
	
	if( is_user_alive(id) && (g_nUserPunished[id-1] == OOB_POISON) )
		{
		new nNewHP = (get_user_health( id ) - get_pcvar_num(g_poison_damage))
		set_user_health( id, nNewHP )
		
		emit_sound( id, CHAN_AUTO, g_szSndPoison, 0.6, ATTN_NORM, 0, PITCH_HIGH )
		
		set_task( 1.0, "PoisonEffects", 0, p_aCmdArgs, 1 )
	}
	else
		{
		if( g_nUserPunished[id-1] == OOB_POISON )
			{
			emit_sound( id, CHAN_AUTO, g_szSndScream, 0.6, ATTN_NORM, 0, PITCH_HIGH )
			g_nUserPunished[id-1] = 0
		}
	}
	return PLUGIN_CONTINUE
}
