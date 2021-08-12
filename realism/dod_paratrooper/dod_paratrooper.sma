/*
   DOD PARATROOPER
   Created by the 29th Infantry Division
   www.29th.org
   www.dodrealism.branzone.com -- Revolutionizing Day of Defeat Realism
   
   DESCRIPTION
   This plugin allows a designated team to parachute down to the ground
   as they spawn in a random location on the map. The new spawn locations
   are determined in an .ini file for each map this is used on. You can
   set which team are the paratroopers and how fast they fall.
   
   This plugin has been modified from my realism version which allows set
   sectors each containing several spawn points that rotates sectors - 
   used for realism rather than public play.
   
   CREDITS
   nightscream (borrowed code & model from parachute plugin)
   =|[76AD]|= TatsuSaisei (reskinned model for WWII authenticity)
   
   Code has been commented in case you need to make changes.
*/

/*
   CVARS
   dod_paratrooper 0            - Enables or disables paratrooper mode
   dod_paratrooper_team 1       - Designates which team are paratroopers (Allies: 1 - Axis: 2)
   dod_paratrooper_gravity 0.09 - Sets falling gravity (Regular gravity is 1.0)
   
   CLIENT COMMANDS
   getorigin - Prints current user origin to console (for development)
*/

/*
   DEVELOPMENT
   Each map you'd like to have paratroopers enabled on must have its own
   .ini file, named whatever the map name is with _para.ini at the end.
   For instance, dod_forest_para.ini for the map dod_forest
   
   The ini file should contain several lines of coordinates for the map.
   The development is actually extremely easy and takes about 3 minutes
   for each map. Simply bind a key to the console command "getorigin" and
   walk around the map finding spawn points. I reccomend about 16 points
   because day of defeat picks the point from top to bottom and doesn't 
   use that many.
   
   Once you have selected all the points and pressed the getorigin bind for
   each one, copy and paste what was printed in your console to a text file.
   It should be about 16 lines of tri-coordinates (origins). These are your 
   spawn points. Note, steam's "copy" function sometimes cuts off the last
   few characters so make sure to check.
   
   To find the "sky" in your map, set sv_gravity to 0 and jump to the highest
   point on the map. Hit the getorigin bind and look at the third number in 
   your console. Roam around the map and make sure the sky is equal in all 
   areas. Some maps have them different, so make sure you choose the lowest
   one to be safe. Subtract about 5 from the lowest sky value to be safe and
   make the top line in your .ini file display it. For example if it were 417
   it would read: 
   sky 417
   at the top of your ini file (on its own line). This means all of the spawn
   points you find do not have to be in the sky. This also means that you can
   theoretically use this plugin without parachuting - just to modify spawns.
   
   If this confuses you, look at the example .ini file that comes with this 
   plugin for dod_forest
*/

#include <amxmodx>
#include <amxmisc>
#include <dodx>
#include <engine>
#include <fun>

#define PLUGIN "Dod Paratrooper"
#define VERSION "1.0"
#define AUTHOR "29th ID"

#define MAX_POINTS    48
#define MAX_LINE_LEN  28

// Defines spawn entity as "custom spawn"
// so it does not get deleted like a regular spawn.
// Doesn't matter what number it is.
#define ENTKEY 9696

new bool:paramap
new spawnEntity[24]
new paraTeam
new lineNum   =  0
new pointNum  = -1
new filename[66]
new mapname[50]
new configLine[MAX_LINE_LEN]
new Float:spawnpoints[MAX_POINTS][3]
new para_ent[33]

// Called after the map loads
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar("dod_paratrooper", "0")
	register_cvar("dod_paratrooper_team", "1") // Allies: 1 - Axis: 2
	register_cvar("dod_paratrooper_gravity", "0.09") // Regular gravity: 1.0
	register_concmd("getorigin", "get_origin") // For development
	
	register_event("ResetHUD","reset_hud","be")
	
	// Remove default map spawn points if plugin is enabled
	if( (get_cvar_num("dod_paratrooper")) && (paramap) )
		remove_spawns(spawnEntity,ENTKEY)
	
	return PLUGIN_CONTINUE
}

// Called before the map loads
public plugin_precache() {
	if(!get_cvar_num("dod_paratrooper"))
		return PLUGIN_HANDLED
	// Parachute Model
	precache_model("models/parachute_khaki.mdl")
	
	// Detect Team
	if(get_cvar_num("dod_paratrooper_team") == 2) {
		spawnEntity = "info_player_axis"
		paraTeam = AXIS
	} else {
		spawnEntity = "info_player_allies"
		paraTeam = ALLIES
	}
	
	// Get file for current map
	get_mapname(mapname, 49)
	get_configsdir(filename, 65)
	format(filename, 65, "%s/maps/%s_para.ini", filename, mapname)
	
	// If the file exists, add new spawn points
	if (file_exists(filename)) {
		paramap = true
		read_config(filename)
		add_spawns(spawnEntity,ENTKEY)
	}
	return PLUGIN_CONTINUE
}

// Reads ini file
public read_config(const configFile[]) {
	new iLen, coord1[28], coord2[28], coord3[28], strSky[4], maxSky[6]
	while(read_file(configFile,lineNum++,configLine,MAX_LINE_LEN,iLen)) {
		if (iLen > 0)
		{
			if(containi(configLine , "sky") > -1) {
				parse(configLine, strSky, 3, maxSky, 5)
			} else {
				pointNum++
				parse(configLine, coord1, 27, coord2, 27, coord3, 27)
				
				spawnpoints[pointNum][0] = str_to_float(coord1)
				spawnpoints[pointNum][1] = str_to_float(coord2)
				spawnpoints[pointNum][2] = str_to_float(coord3)
				
				// If there is a sky value set, change z axis to it
				if(maxSky[0])
					spawnpoints[pointNum][2] = str_to_float(maxSky)
			}
		}
	}
}

public remove_spawns(strEntity[],intKey) {
	// Search for spawns
	new ent = -1
	while((ent = find_ent_by_class(ent,strEntity)) != 0) {
		new entKey = entity_get_int(ent,EV_INT_iuser1)
		// If the spawn is a spawn we just made, skip it
		if(entKey == intKey) continue
		remove_entity(ent)
	}
	
	return PLUGIN_CONTINUE
}

public add_spawns(strEntity[],intKey) {
	// Get Spawn Point Count
	new pointCount = sizeof spawnpoints
	
	// For each Spawn Point
	for( new i = 0; i < pointCount; i++ ) {
		if(spawnpoints[i][0]) {
			// Create Point
			new ent = create_entity(strEntity)
			entity_set_string(ent,EV_SZ_classname,strEntity)
			entity_set_origin(ent,spawnpoints[i])
			entity_set_int(ent,EV_INT_iuser1,intKey) // Define it as custom
		}
	}
	 
	return PLUGIN_CONTINUE
}

// For development purposes
public get_origin(id) {
	new origin[3]
	get_user_origin(id, origin)
	client_print(id, print_console, "%i, %i, %i", origin[0], origin[1], origin[2])
	return PLUGIN_HANDLED
}

// Opens chute when player spawns
public reset_hud(id) {
	new myTeam = get_user_team(id)
	if( (!get_cvar_num("dod_paratrooper")) || (myTeam != paraTeam) || (!paramap) )
		return PLUGIN_HANDLED
	open_chute(id)

	return PLUGIN_HANDLED
}

public open_chute(id) {
	// Open Chute
	if( !( get_entity_flags(id) & FL_ONGROUND ) )
	{
		
		new Float:velocity[3]
		entity_get_vector(id, EV_VEC_velocity, velocity)
		if(velocity[2] < 0)
		{
			if (para_ent[id] == 0)
			{
				para_ent[id] = create_entity("info_target")
				if (para_ent[id] > 0)
				{
					entity_set_model(para_ent[id], "models/parachute_khaki.mdl")
					entity_set_int(para_ent[id], EV_INT_movetype, MOVETYPE_FOLLOW)
					entity_set_edict(para_ent[id], EV_ENT_aiment, id)
					entity_set_int(para_ent[id], EV_INT_sequence, 1)
					entity_set_float(para_ent[id],EV_FL_animtime,20.0)
					entity_set_float(para_ent[id],EV_FL_framerate,1.0)
				}
			}
			if (para_ent[id] > 0)
			{
				new Float:cvarGravity = get_cvar_float("dod_paratrooper_gravity")
				set_user_gravity(id, cvarGravity)
			}
		}
		else
		{
			if (para_ent[id] > 0)
			{
				remove_entity(para_ent[id])
				para_ent[id] = 0
			}
		}
	}
}

// Catches when client touches the ground (if they have a parachute)
// and gets rid of their parachute
public client_PreThink(id) {
	if( (para_ent[id] > 0) && (get_entity_flags(id) & FL_ONGROUND) )
	{
		remove_entity(para_ent[id])
		para_ent[id] = 0
		set_user_gravity(id, 1.0)
	}
}