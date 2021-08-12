///////////////////////////////////////////////////////////////////////////////////////
//
//	DoD Weapon Jam
//		- Version 3.0
//		- 07.22.2009
//		- diamond-optic
//
//////////////////////////////////////////////////////////////////////////////////
//
// Credits:
//
//	- Wilson [29th ID] (pdata offsets as well as a ton of other help)
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
//	- Weapons will randomly jam and the client will have to press
//	  their use key to clear the chamber (or reload depending on setting)
//
//	- Sometimes clearing the chamber fails, requiring multiple attempts
//	- Chance of weapon jamming permanently
//	- Specific weapon stays jammed even after dropping it
//	- Enable/Disable losing 1 round in the clip when clearing the chamber
//	- Weapons will not jam on a full clip (so you dont spawn with a jammed weapon)
//
//	- Server List: http://www.game-monitor.com/search.php?rulename=dod_weaponjam_stats
//
//////////////////////////////////////////////////////////////////////////////////
//
// Commands:
//
//	dod_weaponjam_force <nick/steam> <perm>		//Force a clients weapon to jam
//							//Enter a trailing 1 for perm jam
//
//////////////////////////////////////////////////////////////////////////////////
//
// Compiler Defines:
//
//	SETTING_MSGSTYLE 3	//Message Style Setting
//					//1 = HUD Messages
//					//2 = Chat Messages
//					//3 = Both HUD & Chat Messages
//
//	SETTING_CHANCE 1200	//Chance of weapon jamming for each shot (1 in ### chance)
//
//	SETTING_RELOAD 1	//Reloading clears jammed weapons (on(1)/off(0))
//	SETTING_AMMO 1		//Clearing chamber subtracts 1 round of ammo (on(1)/off(0))
//	
//	SETTING_PERM "100"	//Chance of weapon jam to be permanent (0 = no perm jam)
//	SETTING_FAIL "4"	//Chance of clearing chamber failing (0 = always clears 1st time, 1 in ### chance)
//
//////////////////////////////////////////////////////////////////////////////////
//
// Change Log:
//
//	- 07.23.07 - Version 1.0
//		Initial Release
//
//	- 09.12.07 - Version 1.1
//		Adjusted default jam chances just slightly
//		Stopped 'jammed' sounds from playing after round end
//		Added CVAR to control message style
//		Fixed jam sound from overlapping itself
//
//	- 01.29.08 - Version 2.0
//		Huge Rewrite, too many changes to list
//
//	- 07.22.09 - Version 3.0
//		Added command to force someones weapon to jam
//		Changed prethink forward over to HamSandwich
//		Removed CVAR to enable/disable jamming, just dont load the plugin instead
//		Changed CVARs to compiler defines
//		Bots will now get jams
//		Changed some default values
//		Decreased weapon ent search radius to stop affecting of guns on the ground
//		Improved some if statements
//		Removed 'Full Precache' ability as it doesnt seem to be an issue
//		Various other code improvements
//
///////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////
// Module Include
//
#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <dodfun>
#include <dodx>
#include <hamsandwich>

/////////////////////////////////////////////////
// Settings
//
#define SETTING_CHANCE		1200
#define SETTING_PERM		100	//0 to disable
#define SETTING_FAIL		4
#define SETTING_RELOAD		1
#define SETTING_AMMO		1
#define SETTING_MSGSTYLE	3

#define SETTING_MAXPLAYERS	32
//
/////////////////////////////////////////////////

/////////////////////////////////////////////////
// Version Variable
//
#define VERSION "3.0"
#define SVERSION "v3.0 - by diamond-optic (www.AvaMods.com)"

/////////////////////////////////////////////////
// PData Offsets
//
#define OFFSET_WPN_PROF 103	//Weapon Primary Attack ROF
#define OFFSET_WPN_CLIP 108	//Weapon Clip Ammo
#define OFFSET_WPN_ID 91	//Weapon ID
#define OFFSET_LINUX 4		//Linux Offset

#define JAMMED 100.0
#define UNJAMMED 0.0

/////////////////////////////////////////////////
// iuser Usage
//
// This plugin uses two seperate
// iuser slots on weapon entities
//
// iuser3 >> 1=reloading
// iuser4 >> 1=jammed 2=permanently jammed
//

//////////////////////////////////////////////////
// File Variables
//
new fileNames[3][] =
{
	"weapons/weaponempty.wav",
	"weapons/mgbolt.wav",
	"weapons/clampdown.wav"
}

enum
{
	empty,
	clear,
	failed
}

/////////////////////////////////////////////////
// Global Variables
//
new bool:g_round_restart = false
new Float:jamTime[SETTING_MAXPLAYERS+1]
new set_MsgStyle = SETTING_MSGSTYLE

/////////////////////////////////////////////////
// Plugin Initialization
//
public plugin_init()
{
	register_plugin("DoD Weapon Jam",VERSION,"AMXX DoD Team")
	register_cvar("dod_weaponjam_stats",SVERSION,FCVAR_SERVER|FCVAR_SPONLY)

	//Forwards
	RegisterHam(Ham_Player_PreThink,"player","jam_prethink")

	//Events
	register_event("ReloadDone","reload_done","be") 
	register_event("CurWeapon","cur_weapon","be","1=1","2!=0","2!=1","2!=2","2!=13","2!=14","2!=15","2!=16","2!=19","2!=29","2!=30","2!=31","2!=34","3>0")	
	register_event("RoundState","round_message","a","1=1","1=3","1=4","1=5")
	
	//Force Jam CMD
	register_concmd("dod_weaponjam_force","cmd_forcejam",ADMIN_IMMUNITY,"<nick/steam> <perm> - Force a clients weapon to jam (enter trailing 1 for perm)")
}

/////////////////////////////////////////////////
// CurWeapon Hook - Sets Jammed
//
public cur_weapon(id)
{
	if(is_user_alive(id) && is_user_connected(id))
		{
		new wpnent = dod_get_weapon_ent(id)
		
		if(pev_valid(wpnent))
			{
			set_pev(wpnent,pev_iuser3,0)
			
			if(pev(wpnent,pev_iuser4))
				set_pdata_float(wpnent,OFFSET_WPN_PROF,JAMMED,OFFSET_LINUX)	
			
			else if(is_clip_notfull(id))
				{
				if(random_num(1,SETTING_CHANCE) == 1)
					{

#if SETTING_PERM
					
					if(random_num(1,SETTING_PERM) == 1)
						set_pev(wpnent,pev_iuser4,2)
					else
						set_pev(wpnent,pev_iuser4,1)
#else

					set_pev(wpnent,pev_iuser4,1)

#endif

					}
				}
			}	
		}
}


/////////////////////////////////////////////////
// Reload Complete - unjam
//
public reload_done(id)
{ 
	if(is_user_alive(id))
		{
		new wpnid = dod_get_weapon_ent(id)
			
		if(wpnid && pev_valid(wpnid))
			{
			new is_jammed = pev(wpnid,pev_iuser4)
			
			set_pev(wpnid,pev_iuser3,0)
			
#if SETTING_RELOAD
			
			if(is_jammed == 1)
				{
				set_pdata_float(wpnid,OFFSET_WPN_PROF,UNJAMMED,OFFSET_LINUX)
				set_pev(wpnid,pev_iuser4,0)
				jamTime[id] = 0.0
				}
			else if(is_jammed)
				set_pdata_float(wpnid,OFFSET_WPN_PROF,JAMMED,OFFSET_LINUX)

#else

			if(is_jammed)
				set_pdata_float(wpnid,OFFSET_WPN_PROF,JAMMED,OFFSET_LINUX)

#endif
				
			}
		}
}

/////////////////////////////////////////////////
// Prethink
//
public jam_prethink(id)
{
	if(is_user_alive(id) && !g_round_restart && is_user_connected(id))
		{
		new buttons = pev(id,pev_button)
			
		if(buttons & IN_ATTACK)
			{
			new wpnent = dod_get_weapon_ent(id)
			
			if(pev_valid(wpnent))
				{
				new is_jammed = pev(wpnent,pev_iuser4)
				new is_reload = pev(wpnent,pev_iuser3)
				
				new Float:gametime = get_gametime()
	
				if(is_jammed && !is_reload && jamTime[id]+0.3 < gametime)
					{
					set_pdata_float(wpnent,OFFSET_WPN_PROF,JAMMED,OFFSET_LINUX)
									
					if(!jamTime[id])
						jamTime[id] = gametime-0.2
					else
						{
						set_pev(id,pev_button,buttons & ~IN_ATTACK)
						client_cmd(id,"-attack")
						
						jamTime[id] = gametime
						}
						
					emit_sound(wpnent,CHAN_WEAPON,fileNames[empty],1.0,ATTN_NORM,0,PITCH_NORM)
					
					if(is_jammed == 2)
						{
						if(set_MsgStyle != 2)
							{
							set_hudmessage(192, 25, 25, 0.1, 0.15, 1, 0.4, 2.0, 0.5, 2.0, 3)
							show_hudmessage(id, "Your Weapon Is Permanently Jammed!!^nYou Can NOT Fix This Weapon..")
							}
						if(set_MsgStyle > 1 )
							client_print(id,print_chat,"*** Your Weapon Is Permanently Jammed!! You Can NOT Fix This Weapon..")
						}
					else
						{
						
#if SETTING_RELOAD
	
						if(is_clip_notfull(id) == 1)
							{
							if(set_MsgStyle != 2)
								{
								set_hudmessage(192, 25, 25, 0.1, 0.15, 1, 0.4, 2.0, 0.5, 2.0, 3)
								show_hudmessage(id, "Your Weapon Is Jammed!!^nPress Your +USE Key To Clear The Chamber^nor Reload Your Weapon...")
								}
							if(set_MsgStyle > 1 )
								client_print(id,print_chat,"*** Your Weapon Is Jammed!! Press Your +USE Key To Clear The Chamber or Reload Your Weapon..")
							}
						else
							{
							if(set_MsgStyle != 2)
								{
								set_hudmessage(192, 25, 25, 0.1, 0.15, 1, 0.4, 2.0, 0.5, 2.0, 3)
								show_hudmessage(id, "Your Weapon Is Jammed!!^nPress Your +USE Key To Clear The Chamber")
								}
							if(set_MsgStyle > 1 )
								client_print(id,print_chat,"*** Your Weapon Is Jammed!! Press Your +USE Key To Clear The Chamber..")
							}
							
#else
	
						if(set_MsgStyle != 2)
							{
							set_hudmessage(192, 25, 25, 0.1, 0.15, 1, 0.4, 2.0, 0.5, 2.0, 3)
							show_hudmessage(id, "Your Weapon Is Jammed!!^nPress Your +USE Key To Clear The Chamber")
							}
						if(set_MsgStyle > 1 )
							client_print(id,print_chat,"*** Your Weapon Is Jammed!! Press Your +USE Key To Clear The Chamber..")
	
#endif
	
						}				
					}
				}
			}
		else if(buttons & IN_USE)
			{
			new wpnent = dod_get_weapon_ent(id)
			
			if(pev_valid(wpnent))
				{
				new is_jammed = pev(wpnent,pev_iuser4)
				new is_reload = pev(wpnent,pev_iuser3)
				
				new Float:gametime = get_gametime()
			
				if(is_jammed && !is_reload && jamTime[id]+0.3 < gametime)
					{
					set_pev(id,pev_button,buttons & ~IN_USE)
					client_cmd(id,"-use")
					
					jamTime[id] = gametime
							
					if(is_jammed == 1)
						{
						
#if SETTING_FAIL
						
						if(random_num(1,SETTING_FAIL) == 1)
							{
							emit_sound(wpnent,CHAN_WEAPON,fileNames[failed],1.0,ATTN_NORM,0,PITCH_NORM)
							
							if(set_MsgStyle != 2)
								{
								set_hudmessage(192, 25, 25, 0.1, 0.25, 0, 0.4, 1.5, 0.5, 2.0, 3)
								show_hudmessage(id,"Chamber NOT Cleared!^nTry To Clear It Again..")
								}
							if(set_MsgStyle > 1 )
								client_print(id,print_chat,"*** Chamber NOT Cleared! Try To Clear It Again..")
							}
						else
							{
							set_pev(wpnent,pev_iuser4,0)
							set_pdata_float(wpnent,OFFSET_WPN_PROF,UNJAMMED,OFFSET_LINUX)
							
							jamTime[id] = 0.0
	
#if SETTING_AMMO				
	
							new clip = get_pdata_int(wpnent,OFFSET_WPN_CLIP,OFFSET_LINUX)
							
							if(clip)				
								set_pdata_int(wpnent,OFFSET_WPN_CLIP,clip - 1,OFFSET_LINUX)
	
#endif
								
							emit_sound(wpnent,CHAN_WEAPON,fileNames[clear],1.0,ATTN_NORM,0,PITCH_NORM)
					
							if(set_MsgStyle != 2)
								{
								set_hudmessage(25, 25, 192, 0.1, 0.25, 0, 0.4, 1.5, 0.5, 2.0, 3)
								show_hudmessage(id,"Chamber Cleared!^nYour Weapon Is Now Unjammed..")
								}
							if(set_MsgStyle > 1 )
								client_print(id,print_chat,"*** Chamber Cleared! Your Weapon Is Now Unjammed..")
							}
							
#else
	
						set_pev(wpnent,pev_iuser4,0)
						set_pdata_float(wpnent,OFFSET_WPN_PROF,UNJAMMED,OFFSET_LINUX)
						
						jamTime[id] = 0.0
	
						if(set_Ammo)
							{
							new clip = get_pdata_int(wpnent,OFFSET_WPN_CLIP,OFFSET_LINUX)
						
							if(clip)				
								set_pdata_int(wpnent,OFFSET_WPN_CLIP,clip - 1,OFFSET_LINUX)
							}
							
						emit_sound(wpnent,CHAN_WEAPON,fileNames[clear],1.0,ATTN_NORM,0,PITCH_NORM)
				
						if(set_MsgStyle != 2)
							{
							set_hudmessage(25, 25, 192, 0.1, 0.25, 0, 0.4, 1.5, 0.5, 2.0, 3)
							show_hudmessage(id,"Chamber Cleared!^nYour Weapon Is Now Unjammed..")
							}
						if(set_MsgStyle > 1 )
							client_print(id,print_chat,"*** Chamber Cleared! Your Weapon Is Now Unjammed..")
	
#endif
							
						}
					else
						{
						emit_sound(wpnent,CHAN_WEAPON,fileNames[failed],1.0,ATTN_NORM,0,PITCH_NORM)
							
						if(set_MsgStyle != 2)
							{
							set_hudmessage(25, 192, 25, 0.1, 0.15, 1, 0.4, 2.0, 0.5, 2.0, 3)
							show_hudmessage(id, "Your Weapon Is Permanently Jammed!!^nYou Can NOT Fix This Weapon..")
							}
						if(set_MsgStyle > 1 )
							client_print(id,print_chat,"*** Your Weapon Is Permanently Jammed!! You Can NOT Fix This Weapon..")
						}
					}
				}
			}
		else if(buttons & IN_RELOAD)
			{
			new wpnent = dod_get_weapon_ent(id)
			
			if(pev_valid(wpnent) && pev(wpnent,pev_iuser4))
				if(is_clip_notfull(id) == 1)
					set_pev(wpnent,pev_iuser3,1)
			}
		else if(buttons & IN_ATTACK2)
			{
			new wpnent = dod_get_weapon_ent(id)
			
			if(pev_valid(wpnent) && pev(wpnent,pev_iuser4))
				set_pdata_float(wpnent,OFFSET_WPN_PROF,JAMMED,OFFSET_LINUX)
			}
		}
}


///////////////////////////////////////////////////////////////////////////////////////
// hook the round message and handle
//
public round_message() 
{
	if(read_data(1) == 1)
		g_round_restart = false
	else
		g_round_restart = true
}


////////////////////////////////////////////////////////////////
//	force jam command
//
public cmd_forcejam(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED

	new player[32]
	read_argv(1,player,31)
	
	client_print(id,print_console,"name: %s",player)
		
	// Search for the Player
	new player_id = cmd_target(id,player,14)

	if(!player_id)
		return PLUGIN_HANDLED

	//jam the weapon
	new wpnid = dod_get_weapon_ent(player_id)
	
	new perm=0
	
	if(read_argc()== 3)
		{
		new arg_perm[1]
		read_argv(2,arg_perm,1)
	
		if(strlen(arg_perm))
			perm = str_to_num(arg_perm)
		}
	
	if(perm)
		set_pev(wpnid,pev_iuser4,2)
	else
		set_pev(wpnid,pev_iuser4,1)
		
	if(id)
		{
		new nameCalled[32],nameAgainst[32]
		new steamCalled[32],steamAgainst[32]
		get_user_name(id,nameCalled,31)
		get_user_authid(id,steamCalled,31)
		get_user_name(player_id,nameAgainst,31)
		get_user_authid(player_id,steamAgainst,31)
	
		// Tell them it succeded
		client_print(id,print_console,"successfully executed force %sjam on %s",(perm) ? "perm " : "",nameAgainst)

		// Now Log it
		log_amx("%s<%s> force jammed (perm: %d) %s<%s>",nameCalled,steamCalled,perm,nameAgainst,steamAgainst)
		}

	return PLUGIN_HANDLED
}


/////////////////////////////////////////////////
// Get Current Weapon ID Stock
//
stock dod_get_weapon_ent(id)
{
	new ent = -1
	new wpnid = dod_get_user_weapon(id)

	// Get User Origin
	new Float:origin[3]
	pev(id,pev_origin,origin)
	
	switch(wpnid)
		{
		case 35: wpnid = 25
		case 32: wpnid = 23
		}
	
	// Find Weapon
	while((ent = engfunc(EngFunc_FindEntityInSphere,ent,origin,Float:0.5)) != 0)
		if(pev_valid(ent) && wpnid)
			if(wpnid == get_pdata_int(ent,OFFSET_WPN_ID,OFFSET_LINUX)) return ent
		
	return 0
}



/////////////////////////////////////////////////
// Is Clip NOT Full Stock
//
// returns: 0=clip is full, 1=clip is not full, 2=clip is not full, but its garand
stock is_clip_notfull(id)
{
	new clip,weapon = dod_get_user_weapon(id,clip)
			
	switch(weapon)
		{
		//axis
		case DODW_LUGER: { if(clip != 8) return 1; }
		case DODW_KAR: { if(clip != 5) return 1; }
		case DODW_K43: { if(clip != 10) return 1; }
		case DODW_MP40: { if(clip != 30) return 1; }
		case DODW_STG44: { if(clip != 30) return 1; }
		case DODW_FG42: { if(clip != 20) return 1; }
		case DODW_SCOPED_FG42: { if(clip != 20) return 1; }
		case DODW_SCOPED_KAR: { if(clip != 5) return 1; }
		case DODW_MG34: { if(clip != 75) return 1; }
		case DODW_MG42: { if(clip != 250) return 1; }
		//americans
		case DODW_COLT:	{ if(clip != 7) return 1; }
		case DODW_GARAND: { if(clip) return 2; }
		case DODW_FOLDING_CARBINE: { if(clip != 15) return 1; }
		
		case DODW_M1_CARBINE: { if(clip != 15) return 1; }
		case DODW_THOMPSON: { if(clip != 30) return 1; }
		case DODW_GREASEGUN: { if(clip != 30) return 1; }
		case DODW_SPRINGFIELD: { if(clip != 5) return 1; }
		case DODW_BAR: { if(clip != 20) return 1; }
		case DODW_30_CAL: { if(clip != 150) return 1; }
		//british
		case DODW_WEBLEY: { if(clip != 6) return 1; }
		case DODW_ENFIELD: { if(clip != 10) return 1; }
		case DODW_STEN: { if(clip != 30) return 1; }
		case DODW_SCOPED_ENFIELD: { if(clip != 10) return 1; }
		case DODW_BREN: { if(clip != 30) return 1; }
		}
	
	return 0	
}
