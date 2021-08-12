//////////////////////////////////////////////////////////////////////////////////
//
//	DoD Gore Custom
//		- Version 1.7
//		- 01.03.2006
//		- edited: diamond-optic
//		- port: firestorm
//		- original: mike_cao
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
// 	- Adds more gore & such to day of defeat...
//	- Works with both win32 & linux servers....
//
// Credits:
//
//   	- Original plugin by mike_cao (plugin_gore)
//  	- Ported to DoD by FireStorm
// 	- Modified by diamond-optic
//
// CVARs: 
//
//	dod_gore "abcdef" 		//Gore Flags
//
//	//needs "c" flag
//	dod_gore_bleed_hp "5"		//Bleed when hp gets to this or lower
//	dod_gore_bleed_sound "1"	//play sound when player bleeds
//	dod_gore_bleed_sound_when "2"	//when to play sound after they start bleeding:
//						1 = everytime they bleed during that life
//						2 = only the 1st time during that life
//
//	//needs "f" flag
//	dod_gore_heartbeat_hp "1"	//Start heartbeat when hp gets to this or lower
//
// Gore Flags:
//
//	a - Headshot blood 
//	b - More blood for non-headshots
//	c - Bleeding on low health
//	d - Even More Blood
//	e - Brain gibs for headshots
//	f - Heartbeat sound that nearby players can hear
//
// Changelog:
//
//	- 06.11.2006 Version 1.0
//		Released modified version of FireStorms gore plugin
//
//	- 06.25.2006 Version 1.1
//		Added CVAR for bleeding effect hp
//
//	- 06.30.2006 Version 1.2
//		Made a few adjustments to the fx & such
//
//	- 07.09.2006 Version 1.3
//		Removed FUN module
//
//	- 07.16.2006 Version 1.4
//		Removed redundant defines
//		Added 'e' flag for brain gibs on headshots
//
//	- 08.31.2006 Version 1.5
//		Renamed CVARS, so be sure to make note of that..
//		More adjustments to fx
//		Removed code that didnt work & gave an error (sorry forgot it was there)
//		Removed more pointless unused code
//		Added bleeding sound
//		Added "f" flag for heartbeat sound
//		Added BLEED_TIME define to allow easier changing of how often client bleeds
//		Added check in dmg func to start bleeding/heartbeat quicker
//
//	- 11.02.2006 Version 1.6
//		Added public cvar for stats tracking
//		Blood now comes from approximate area of damage (not really noticable i suppose lol)
//		Fixed a mistake in the heartbeat section
//
//	- 01.03.2007 Version 1.7
//		fixed cvar typo in comments (thanks Drek)
//		made tasks use a unique id (thanks santa_sh0t_tupac)
//		replaced ResetHud with dod_client_spawn
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx> 
#include <dodx> 

#define BLEED_TIME 15.0	    //how often clients will bleed (in seconds)

#define MAX_PLAYERS 32 

#define GORE_HEADSHOT       (1<<0) // "a" 
#define GORE_BLOOD          (1<<1) // "b" 
#define GORE_BLEEDING       (1<<2) // "c"
#define GORE_EXTRA          (1<<3) // "d"
#define GORE_BRAINS         (1<<4) // "e"
#define GORE_HEARTBEAT      (1<<5) // "f"

#define HEARTBEAT_TASK 206321

//pcvars
new p_dod_gore, p_bleeding_hp, p_bleeding_sound, p_bleeding_sound_when, p_heartbeat_hp
//sprites
new spr_blood_drop, spr_blood_spray
//headshot gib model
new gore_braingibs
//bleeding & heartbeat
new bleedHitplace[33]
new bool: is_bleeding[33]
new bool: is_beating[33]
new bleeding_sound[]  = "player/stopbleed.wav"
new heart_sound[]  = "player/heartbeat1.wav"
// Blood decals
static const ground_decal[9] = {204,205,217,206,207,208,218,209,210} 

/************************************************************ 
* PLUGIN FUNCTIONS 
************************************************************/ 

public plugin_init() 
{ 
	register_plugin("DoD Gore Custom","1.7","AMXX DoD Team")
	
	//plugin stats public cvar
	register_cvar("dod_gore_custom_stats", "1.7", FCVAR_SERVER|FCVAR_SPONLY)
	
	register_statsfwd(XMF_DAMAGE)
	register_statsfwd(XMF_DEATH)
	
	p_dod_gore = register_cvar("dod_gore","abcdef")
	
	p_bleeding_hp = register_cvar("dod_gore_bleed_hp", "5")
	p_bleeding_sound = register_cvar("dod_gore_bleed_sound", "1")
	p_bleeding_sound_when= register_cvar("dod_gore_bleed_sound_when", "2")
	
	p_heartbeat_hp = register_cvar("dod_gore_heartbeat_hp", "1")
	
	set_task(BLEED_TIME,"event_blood",0,"",0,"b") 
}

public plugin_precache() 
{ 
	spr_blood_drop = precache_model("sprites/blood.spr") 
	spr_blood_spray = precache_model("sprites/bloodspray.spr")
	gore_braingibs = precache_model("models/stickygibpink.mdl")
	precache_sound(bleeding_sound)
	precache_sound(heart_sound)
} 

/************************************************************ 
* MAIN 
************************************************************/ 

public get_gore_flags() 
{ 
	new sFlags[24]
	get_pcvar_string(p_dod_gore,sFlags,24) 
	return read_flags(sFlags) 
}

public dod_client_spawn(id) 
{
	if(is_user_connected(id) && is_user_alive(id))
		{
		is_bleeding[id] = false
		is_beating[id] = false
		
		if(task_exists(HEARTBEAT_TASK+id))
			remove_task(HEARTBEAT_TASK+id)
		}
} 

public client_damage(attacker,victim,damage,wpnindex,hitplace,TA)
{
	new iFlags = get_gore_flags()
	new iOrigin2[3], iOrigin[3] 
	
	if(iFlags&GORE_BLOOD)
		{ 
		get_user_origin(victim,iOrigin2)
		
		iOrigin[0] = iOrigin2[0]
		iOrigin[1] = iOrigin2[1]
		iOrigin[2] = iOrigin2[2]
		
		if(hitplace == HIT_CHEST)
			iOrigin[2] += 25
		else if(hitplace == HIT_LEFTARM || hitplace == HIT_RIGHTARM)
			iOrigin[2] += 20
		else if(hitplace == HIT_STOMACH)
			iOrigin[2] += 15
		else if(hitplace == HIT_GENERIC)
			iOrigin[2] += 5
		else if(hitplace == HIT_LEFTLEG || hitplace == HIT_RIGHTLEG)
			iOrigin[2] += -25		
		
		if(iFlags&GORE_EXTRA)
			{
			fx_blood(iOrigin)
			fx_blood(iOrigin) 
			fx_bleed(iOrigin)
			fx_bleed(iOrigin)
			fx_ground_decal(iOrigin2,2)
			fx_body_decal(iOrigin,5)
			}
		else
			{		
			fx_blood(iOrigin)
			fx_bleed(iOrigin)
			fx_ground_decal(iOrigin2,1)
			fx_body_decal(iOrigin,2)
			}
	}
	
	if((iFlags&GORE_BLEEDING) && get_user_health(victim) <= get_pcvar_num(p_bleeding_hp))
		{
		bleedHitplace[victim] = hitplace
		event_blood()
		}
	
	else if((iFlags&GORE_HEARTBEAT) && get_user_health(victim) <= get_pcvar_num(p_heartbeat_hp))
		event_blood()
} 

public client_death(killer,victim,wpnindex,hitplace,TK)
{
	new iFlags = get_gore_flags()
	new iOrigin[3], iOrigin2[3]
		
	if(iFlags&GORE_HEADSHOT && hitplace == HIT_HEAD)
		{
		get_user_origin(victim,iOrigin2)
		
		iOrigin[0] = iOrigin2[0]
		iOrigin[1] = iOrigin2[1]
		iOrigin[2] = iOrigin2[2] + 40
		
		if(iFlags&GORE_EXTRA)
			{
			if(random_num(1,2) == 1)
				{
				fx_headshot(iOrigin2)
				fx_headshot(iOrigin2)
				}
			else
				{
				fx_headshot(iOrigin2)
				fx_headshot(iOrigin2)
				fx_headshot(iOrigin2)
				}
			fx_ground_decal(iOrigin2,4)
			fx_body_decal(iOrigin,2)
			}
		else
			{ 
			fx_headshot(iOrigin2)
			fx_ground_decal(iOrigin2,2)
			}
						
		if(iFlags&GORE_BRAINS)
			fx_braingibs(iOrigin2)
		}
		
	if(is_beating[victim] == true)
		{
		emit_sound(victim, CHAN_STREAM, heart_sound, 1.0, ATTN_NORM, SND_STOP, PITCH_NORM)
		is_beating[victim] = false
		
		if(task_exists(HEARTBEAT_TASK+victim))
			remove_task(HEARTBEAT_TASK+victim)
		}
}

public event_blood()
{ 
	new iFlags = get_gore_flags()
	
	if(iFlags&GORE_BLEEDING)
		{
		new iPlayer, iPlayers[MAX_PLAYERS], iNumPlayers, iOrigin[3], iOrigin2[3]
		get_players(iPlayers,iNumPlayers,"a") 
		for(new i = 0; i < iNumPlayers; i++)
			{
			iPlayer = iPlayers[i]
			
			if(is_user_connected(iPlayer) && is_user_alive(iPlayer) && get_user_health(iPlayer) <= get_pcvar_num(p_bleeding_hp))
				{						
				get_user_origin(iPlayer,iOrigin2) 
				
				iOrigin[0] = iOrigin2[0]
				iOrigin[1] = iOrigin2[1]
				iOrigin[2] = iOrigin2[2]
				
				if(bleedHitplace[iPlayer] == HIT_CHEST)
					iOrigin[2] += 15
				else if(bleedHitplace[iPlayer] == HIT_LEFTARM || bleedHitplace[iPlayer] == HIT_RIGHTARM)
					iOrigin[2] += 10
				else if(bleedHitplace[iPlayer] == HIT_STOMACH)
					iOrigin[2] += 5
				else if(bleedHitplace[iPlayer] == HIT_GENERIC)
					iOrigin[2] += 0
				else if(bleedHitplace[iPlayer] == HIT_LEFTLEG || bleedHitplace[iPlayer] == HIT_RIGHTLEG)
					iOrigin[2] += -25
				
				if(iFlags&GORE_EXTRA)
					{
					fx_blood(iOrigin)
					fx_bleed(iOrigin) 
					fx_bleed(iOrigin) 
					fx_ground_decal(iOrigin2,2)
					fx_body_decal(iOrigin,2)
					}
				else
					{
					fx_bleed(iOrigin) 
					fx_ground_decal(iOrigin2,1)
					fx_body_decal(iOrigin,1)
					}
									
				if(is_user_connected(iPlayer) && is_user_alive(iPlayer) && get_pcvar_num(p_bleeding_sound) == 1)
					{
					if(get_pcvar_num(p_bleeding_sound_when) == 1)
						emit_sound(iPlayer, CHAN_VOICE, bleeding_sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
					else if(get_pcvar_num(p_bleeding_sound_when) == 2 && is_bleeding[iPlayer] == false)
						{
						emit_sound(iPlayer, CHAN_VOICE, bleeding_sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
						is_bleeding[iPlayer] = true
						}
					}
				}
			} 
		} 
		
	if(iFlags&GORE_HEARTBEAT)
		{
		new iPlayer, iPlayers[MAX_PLAYERS], iNumPlayers
		get_players(iPlayers,iNumPlayers,"a") 
		for(new i = 0; i < iNumPlayers; i++)
			{
			iPlayer = iPlayers[i]
			
			if(is_user_connected(iPlayer) && is_user_alive(iPlayer) && is_beating[iPlayer] == false && get_user_health(iPlayer) <= get_pcvar_num(p_heartbeat_hp))
				{
				is_beating[iPlayer] = true
				
				new param[1]
				param[0] = iPlayer
				
				fx_heartbeat(param[0])		
				}
			}
		}
}

/************************************************************ 
* FX FUNCTIONS 
************************************************************/ 

public fx_blood(origin[3]) 
{ 
	//blood sprite
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
	write_byte(TE_BLOODSPRITE) 
	write_coord(origin[0]+random_num(-5,5)) 
	write_coord(origin[1]+random_num(-5,5)) 
	write_coord(origin[2]+random_num(-5,5)) 
	write_short(spr_blood_spray)
	write_short(spr_blood_drop) 
	write_byte(72) // color index (was 248)
	write_byte(random_num(5,8)) // size 
	message_end() 
} 

public fx_bleed(origin[3]) 
{ 
	// Blood spray 
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
	write_byte(TE_BLOODSTREAM) 
	write_coord(origin[0]) 
	write_coord(origin[1]) 
	write_coord(origin[2]) 
	write_coord(random_num(-25,25)) // x 
	write_coord(random_num(-25,25)) // y 
	write_coord(random_num(-10,10)) // z 
	write_byte(70) // color
	write_byte(random_num(20,40)) // speed 
	message_end() 
} 

static fx_ground_decal(origin[3],num) 
{ 
	//blood decal on ground
	for(new j = 0; j < num; j++) { 
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
		write_byte(TE_WORLDDECAL) 
		write_coord(origin[0]+random_num(-50,50)) 
		write_coord(origin[1]+random_num(-50,50)) 
		write_coord(origin[2]-36)
		write_byte(ground_decal[random_num(0,8)]) // index 
		message_end() 
	} 
} 

static fx_body_decal(origin[3],num) 
{ 
	//blood decal from body (walls)
	for(new j = 0; j < num; j++) { 
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
		write_byte(TE_WORLDDECAL) 
		write_coord(origin[0]+random_num(-30,30)) 
		write_coord(origin[1]+random_num(-30,30)) 
		write_coord(origin[2]) 
		write_byte(ground_decal[random_num(0,8)]) // index 
		message_end() 
	} 
} 

public fx_headshot(origin[3]) 
{ 
	//head decal 1
	for(new i = 0; i < 2; i++) 
		{
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
		write_byte(TE_WORLDDECAL) 
		write_coord(origin[0]+random_num(-50,50)) 
		write_coord(origin[1]+random_num(-50,50)) 
		write_coord(origin[2]+random_num(25,35))
		write_byte(ground_decal[random_num(0,8)]) // index 
		message_end() 
		}
		
	//head decal 2
	for(new i = 0; i < 2; i++) 
		{
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
		write_byte(TE_WORLDDECAL) 
		write_coord(origin[0]+random_num(-25,25)) 
		write_coord(origin[1]+random_num(-25,25)) 
		write_coord(origin[2]+random_num(25,35))
		write_byte(ground_decal[random_num(0,8)]) // index 
		message_end() 		
		}
		
	//blood stream
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
	write_byte(TE_BLOODSTREAM)  //101
	write_coord(origin[0]) 
	write_coord(origin[1]) 
	write_coord(origin[2]+45) 
	write_coord(random_num(-15,15)) // x 
	write_coord(random_num(-15,15)) // y 
	write_coord(random_num(20,40)) // z (25,50)
	write_byte(70) // color
	write_byte(random_num(25,50)) // speed  (25,75)
	message_end() 
	
	//blood sprite
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BLOODSPRITE)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+random_num(28,34))
	write_short(spr_blood_spray)
	write_short(spr_blood_drop)
	write_byte(74) // color index (was 248)
	write_byte(random_num(6,9)) // size
	message_end()
	
	//sparks
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(9)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+32)
	message_end()
	
	//dynamic light
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_DLIGHT)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+30)
	write_byte(20)			// radius
	write_byte(100)			// red
	write_byte(0) 			// green
	write_byte(0) 			// blue
	write_byte(4) 			// life
	write_byte(20)			// decay rate
	message_end()
}

public fx_braingibs(origin[3]) 
{ 
	//brain gibs
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BREAKMODEL)
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2] + 32) // z
	write_coord(10) // size x
	write_coord(10) // size y
	write_coord(10) // size z
	write_coord(random_num(-40,40)) // velocity x
	write_coord(random_num(-40,40)) // velocity y
	write_coord(random_num(25,100)) // velocity z
	write_byte(10) // random velocity
	write_short(gore_braingibs) // model
	write_byte(random_num(1,3)) // count
	write_byte(40) // life
	write_byte(0x04) // flags
	message_end()
}

public fx_heartbeat(param[])
{	
	new id = param[0]
	
	if(is_user_connected(id) && is_user_alive(id) && is_beating[id] == true)
		{
		if(get_user_health(id) <= get_pcvar_num(p_heartbeat_hp))
			{				
			emit_sound(id, CHAN_STREAM, heart_sound, 0.8, ATTN_NORM, 0, PITCH_NORM)
						
			set_task(1.0,"fx_heartbeat",HEARTBEAT_TASK+id, param, 1)
			}
		else
			{
			emit_sound(id, CHAN_STREAM, heart_sound, 0.8, ATTN_NORM, SND_STOP, PITCH_NORM)
			is_beating[id] = false
			
			if(task_exists(HEARTBEAT_TASK+id))
				remove_task(HEARTBEAT_TASK+id)
			}
		}
}
