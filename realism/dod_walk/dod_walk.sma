//////////////////////////////////////////////////////////////////////////////////
//
//	DoD Walk
//		- Version 0.3
//		- 03.31.2007
//		- original: Zor
//		- bug fixes: Wilson [29th ID] & diamond-optic
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
// 	- Allows 'walking' in dod (slower movement but no footsteps)
//
// CVARs: 
//
//	dod_walk "1"		//Turn ON(1)/OFF(0)
//	dod_walk_speed "100"	//Speed at which players will walk
//
// Commands:
//
//	+dod_walk		//Bind a key to this, then hold it to walk
//
//	say /walk		//Brings up a MOTD window with bind information
//
// Extra:
//
//	- Place walk_motd.txt in your addons/amxmodx/configs directory
//
// Changelog:
//
//	- 09.14.2006 Version 0.1 (Wilson [29th ID])
//		Initial re-release with several bug fixes
//		Fixed running with deployed bazooka
//		Fixed running while scoped
//		Fixed Running while prone
//
//	- 01.08.2007 Version 0.2 (diamond-optic)
//		Added PCVARS
//		Roundstate fix
//		Stamina fix
//		Removed cur_weapon function as the stamina fix covered that as well
//		Remove engine module (not needed)
//		Fixed not being able to walk with undeployed rockets (added fakemeta)
//		Added public cvar (for tracking)
//		Fixed holding walk and zooming in
//		Fixed not being able to walk after spawning sometimes
//		Added some connected/alive/bot checks
//		Register'd fakemeta PlayerPreThink forward
//
//	- 03.31.2007 Version 0.3 (diamond-optic)
//		Round End fix (yes, TatsuSaisei was right...)
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx> 
#include <amxmisc> 
#include <fun> 
#include <dodx>                 //added for pronestate check 
#include <fakemeta>		//added for rockets

/////////////////////////////////////////////////////////////////////////////////////// 
// Version Control 
// 
new AUTH[] = "AMXX DoD Team" 
new PLUGIN_NAME[] = "DoD Walk" 
new VERSION[] = "0.3" 
// 
/////////////////////////////////////////////////////////////////////////////////////// 

/////////////////////////////////////////////////////////////////////////////////////// 
// Globals 
// 
new motd_file[64] = "walk_motd.txt" 
new g_client_in_walk[33] = { 0, ... } 
new zoom[33]          			//ADDED for scope check 
new bool:g_round_restart = true		//ADDED for roundstate check
new p_walk, p_walk_speed		//pcvars
// 
/////////////////////////////////////////////////////////////////////////////////////// 

/////////////////////////////////////////////////////////////////////////////////////// 
// 
// Initializations of the Plugin 
// 
public plugin_init() 
{ 
   // Register this plugin 
   register_plugin(PLUGIN_NAME, VERSION, AUTH)
   
   //plugin stats public cvar
   register_cvar("dod_walk_stats", VERSION, FCVAR_SERVER|FCVAR_SPONLY)

   // Register Console Commands 
   register_clcmd("+dod_walk", "start_walk", 0, "- Will start your walking") 
   register_clcmd("-dod_walk", "stop_walk") 

   register_clcmd("say /walk", "message_hook") 
   register_clcmd("say_team /walk", "message_hook") 
       
   p_walk = register_cvar("dod_walk", "1") 
   p_walk_speed = register_cvar("dod_walk_speed", "100") 
    
   //For When Scoped 
   register_event("SetFOV","zoom_out","be","1=0")     //Not Zoomed 
   register_event("SetFOV","zoom_in","be","1=20"  )   //Zoomed!!!!!!!!
   //For Rockets
   register_event("ReloadDone", "reload_done", "be")  //added for rockets
   //For RoundState duh!
   register_event("RoundState", "round_message", "a") //added for roundstate
   
   //Register PreThink
   register_forward(FM_PlayerPreThink, "walk_prethink")
} 

//////////////////////////////////////////////////////////////////////////////////////////////////////// 
// 
// Configs the MOTD - plugin_cfg 
// 
public plugin_cfg() 
{ 
	// Get the placement of the motd file 
	new folderName[32] 

	get_configsdir(folderName, 31) 

	format(motd_file, 63, "%s/%s", folderName, motd_file) 
    
	return PLUGIN_CONTINUE 
}

//////////////////////////////////////////////////////////////////////////////////////////////////////// 
// 
// Starts the Walking Sequence - start_walk 
// 
public start_walk(id) 
{ 
	if(!get_pcvar_num(p_walk) || !is_user_alive(id) || !is_user_connected(id) || is_user_bot(id) || g_client_in_walk[id] || dod_get_pronestate(id) != 0 || zoom[id] == 1 || g_round_restart)
		return PLUGIN_HANDLED
	
	new clip, ammo, myWeapon = dod_get_user_weapon(id,clip,ammo)
	
	if((myWeapon == DODW_BAZOOKA || myWeapon == DODW_PANZERSCHRECK || myWeapon == DODW_PIAT) && get_user_maxspeed(id) <= 50.0)
		return PLUGIN_HANDLED 

	set_user_maxspeed(id, get_pcvar_float(p_walk_speed)) 
	set_user_footsteps(id, 1) 
	g_client_in_walk[id] = 1 
    
	return PLUGIN_HANDLED 
} 

//////////////////////////////////////////////////////////////////////////////////////////////////////// 
// 
// Stops the Walking Sequence - stop_walk 
// 
public stop_walk(id) 
{ 
	if(!get_pcvar_num(p_walk) || !g_client_in_walk[id] || !is_user_connected(id) || !is_user_alive(id) || is_user_bot(id))  
		return PLUGIN_HANDLED 
	
	if(!dod_get_pronestate(id))
		{
		new Float:speed
		if(zoom[id]) 
			speed = 42.0
		else 
			speed = 600.0
		set_user_maxspeed(id, speed)
		}
	
	set_user_footsteps(id, 0) 
	g_client_in_walk[id] = 0
	
    
	return PLUGIN_HANDLED 
} 

//////////////////////////////////////////////////////////////////////////////////////////////////////// 
// 
// Shows MOTD for this plugin - message_hook 
// 
public message_hook(id) 
{ 
	if(!get_pcvar_num(p_walk) || !g_client_in_walk[id] || !is_user_connected(id) || !is_user_alive(id) || is_user_bot(id))  
		return PLUGIN_CONTINUE 
       
	new text[1300], counter = 0, len = 0, pos = 0 
    
	while(read_file(motd_file, counter++, text[pos], 1299 - pos, len) != 0) 
		{ 
		pos += len 
		} 
    
	replace(text, 1299, "<br>", "^n") 

	show_motd(id, text, "Walk Screen Help") 

	return PLUGIN_CONTINUE    
} 

//////////////////////////////////////////////////////////////////////////////////////////////////////// 
// 
// Checking if zoomed in.. 
// 
public zoom_in(id)
{ 
	if(get_pcvar_num(p_walk) && !is_user_bot(id) && is_user_alive(id))
		{
		zoom[id]=1 	
			
		if(g_client_in_walk[id] == 1)
			stop_walk(id)
		}
} 

public zoom_out(id)
{ 
	if(get_pcvar_num(p_walk) && !is_user_bot(id))
		zoom[id]=0 
} 

///////////////////////////////////////////////////////////////////////////////////////
//
// round state check
//
public round_message() 
{
	if(!get_pcvar_num(p_walk)) 
		return PLUGIN_CONTINUE 
		
	if(read_data(1) == 1)
		g_round_restart = false
	else if(read_data(1) == 3 || read_data(1) == 4)
		{
		g_round_restart = true
		    
		new counter, players[32], totalPlayers
		get_players(players, totalPlayers, "a")
		for(counter = 0; counter < totalPlayers; counter++)
			{
			if(g_client_in_walk[players[counter]] == 1)
				stop_walk(players[counter])
			if(zoom[players[counter]] == 1)
				zoom[players[counter]] = 0
			}
		}
	return PLUGIN_CONTINUE
}

//////////////////////////////////////////////////////////////////////////////////////////////////////// 
// 
// reloading done (for rockets). 
// 
public reload_done(id)
{ 
	if(get_pcvar_num(p_walk) && is_user_alive(id) && is_user_connected(id) && !is_user_bot(id) && g_client_in_walk[id])
		{
		new clip, ammo, myWeapon = dod_get_user_weapon(id,clip,ammo)
	
		if(myWeapon == DODW_BAZOOKA || myWeapon == DODW_PANZERSCHRECK || myWeapon == DODW_PIAT)
			{
			set_user_maxspeed(id, 50.0)
			set_user_footsteps(id, 0) 
			g_client_in_walk[id] = 0
			}
		}
} 

///////////////////////////////////////////////////////////////////////////////////////
//
// stamina fix & hook for shouldering rockets while walking
//
public walk_prethink(id)
{	
	if(get_pcvar_num(p_walk) && g_client_in_walk[id] && is_user_alive(id) && is_user_connected(id) && !is_user_bot(id))
		{
		new clip, ammo, myWeapon = dod_get_user_weapon(id,clip,ammo)
		
		if((myWeapon == DODW_BAZOOKA || myWeapon == DODW_PANZERSCHRECK || myWeapon == DODW_PIAT) && pev(id, pev_button) & IN_ATTACK2)
			stop_walk(id)
		else if(dod_get_pronestate(id) == 0 && zoom[id] == 0) 
			set_user_maxspeed(id, get_pcvar_float(p_walk_speed))
		}
}

///////////////////////////////////////////////////////////////////////////////////////
//
// reset variables on spawn
//
public dod_client_spawn(id)
{
	if(get_pcvar_num(p_walk) && is_user_alive(id) && is_user_connected(id) && !is_user_bot(id))
		{
		if(g_client_in_walk[id] == 1)
			stop_walk(id)
		if(zoom[id] == 1)
			zoom[id] = 0
		}
}
