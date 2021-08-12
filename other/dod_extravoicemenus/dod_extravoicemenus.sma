//////////////////////////////////////////////////////////////////////////////////
//
//	DoD Extra Voice Menus
//		- Version 1.2
//		- 04.06.2008
//		- diamond-optic (original code: Jed)
//
//////////////////////////////////////////////////////////////////////////////////
//
// Credit:
//
//   - Original Code by Neil 'Jed' Jedrzejewski (DoD Missing Sounds v1.0)
//
// Information:
//
//   - Adds 2 new voice menus to the game
//   - You can also bind keys to play individual voice cmds
//   - British have a few more new voice cmds then the other teams
//   - Uses AMXX anti-flood setting to prevent spam
//
// CVARS:
//
//   dod_extravoicemenus "1" //Turn on(1)/off(0)
//
// Commands:
//
//   - Use "voice_menu4" & "voice_menu5" to access the new menus
//
//   - You can also bind keys to the individual voice commands:
//		"voice_coverflanks"
//		"voice_defendobjective"
//		"voice_defendposition"
//		"voice_dropweapon"
//		"voice_left"
//		"voice_right"
//		"voice_medic"
//		"voice_bringuppiat"
//		"voice_prepare"
//		"voice_spreadout"
//		"voice_tankahead"
//		"voice_takecover"
//		"voice_takeflank"
//		"voice_takeobjective"
//
// Changelog:
//
//   - 07.14.2006 Version 1.0
//  	  Initial Release
//
//   - 09.02.2006 Version 1.1
//  	  Changed print out: 'drop your weapons' to 'drop your weapon'
//	  Changed command: 'voice_dropweapons' to 'voice_dropweapon'
//
//   - 04.06.2008 Version 1.2
//	  Minor code reduction
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <dodx>

#define VERSION "1.2"
#define SVERSION "v1.2 - by diamond-optic (www.AvaMods.com)"

new Float:g_Flooding[33]	// used to stop people spamming the commands
new Float:maxChat = 1.00		// floodtime (int loads amx flood time setting)
new is_brit[33] = 0		// holds if player is british or not
new p_voicemenus		// on/off pcvar
new g_MenuPos[33]		// which menu...

public plugin_init() 
{ 
	register_plugin("DoD Extra Voice Menus",VERSION,"AMXX DoD Team")
	register_cvar("dod_extravoicemenus_stats",SVERSION,FCVAR_SERVER|FCVAR_SPONLY)
   
	p_voicemenus = register_cvar("dod_extravoicemenus","1")
   
	register_clcmd("voice_menu4","dodvoice_menu4")
	register_concmd("voice_menu5","dodvoice_menu5")
   
	register_menucmd(register_menuid("dod_extra_voice_menu"),1023,"MenuChoice")
   
	register_clcmd("voice_coverflanks","dodvoice_cflanks")
	register_clcmd("voice_defendobjective","dodvoice_defobj")
	register_clcmd("voice_defendposition","dodvoice_defpos")
	register_clcmd("voice_dropweapon","dodvoice_dropguns")
	register_clcmd("voice_left","dodvoice_firmleft")
	register_clcmd("voice_right","dodvoice_firmright")
	register_clcmd("voice_medic","dodvoice_medic")
	register_clcmd("voice_bringuppiat","dodvoice_moveuppiat")
	register_clcmd("voice_prepare","dodvoice_prepare")
	register_clcmd("voice_spreadout","dodvoice_spreadout")
	register_clcmd("voice_tankahead","dodvoice_tankahead")
	register_clcmd("voice_takecover","dodvoice_takecover")
	register_clcmd("voice_takeflank","dodvoice_takeflank")
	register_clcmd("voice_takeobjective","dodvoice_takeobj")
   
	register_dictionary("antiflood.txt")
	maxChat = get_cvar_float("amx_flood_time")
}  

public plugin_precache() 
{	
	//axis menu 1
	precache_sound("player/gerflank.wav")		//1
	precache_sound("player/gercoverflanks.wav")	//2
	precache_sound("player/gerdropguns.wav")	//3
	precache_sound("player/gertakecover.wav")	//4
	precache_sound("player/gerspreadout.wav")	//5
	precache_sound("player/germanleft.wav")		//6
	precache_sound("player/germanright.wav")	//7
	precache_sound("player/gertankahead.wav")	//8
	precache_sound("player/germedic.wav")		//9
	//axis menu 2
	precache_sound("player/gerprepare.wav")		//1

	//brit menu 1
	precache_sound("player/britflank.wav")		//1
	precache_sound("player/britcoverflanks.wav")	//2
	precache_sound("player/britdropguns.wav")	//3
	precache_sound("player/brittakecover.wav")	//4
	precache_sound("player/britspeadout.wav")	//5
	precache_sound("player/britleft.wav")		//6
	precache_sound("player/britright.wav")		//7
	precache_sound("player/britbringuppiat.wav")	//8
	precache_sound("player/brittigerahead.wav")	//9
	//brit menu 2
	precache_sound("player/britdefendobj.wav")	//1
	precache_sound("player/britdefendarea.wav")	//2
	precache_sound("player/brittakeobj.wav")	//3
	precache_sound("player/britprepare.wav")	//4
	precache_sound("player/britmedic.wav")		//5		

	//us menu 1
	precache_sound( "player/usflank.wav" )		//1
	precache_sound( "player/uscoverflanks.wav" )	//2
	precache_sound( "player/usdropguns.wav" )	//3
	precache_sound( "player/ustakecover.wav" )	//4
	precache_sound( "player/usspreadout.wav" )	//5
	precache_sound( "player/usleft.wav" )		//6
	precache_sound( "player/usright.wav" )		//7
	precache_sound( "player/ustigerahead.wav" )	//8
	precache_sound( "player/usmedic.wav" )		//9
	//us menu 2
	precache_sound( "player/usprepare.wav" )	//1	
}

// voice_coverflanks (all teams)
public dodvoice_cflanks(id)
{
	if (can_play(id))
		{
		if(get_user_team(id) == 1) 
			{
			if(is_brit[id]) 
				emit_sound(id,CHAN_VOICE,"player/britcoverflanks.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			else
				emit_sound(id,CHAN_VOICE,"player/uscoverflanks.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			} 
		else 
			emit_sound(id,CHAN_VOICE,"player/gercoverflanks.wav",1.0,ATTN_NORM,0,PITCH_NORM)

		client_cmd(id,"say_team Cover the flanks!")
		}
	return PLUGIN_HANDLED 
}

// voice_defendobjective (british only)
public dodvoice_defobj(id)
{
	if(can_play(id))
		{
		if(get_user_team(id) == 1 && is_brit[id]) 
			{
			emit_sound(id,CHAN_VOICE,"player/britdefendobj.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			client_cmd(id,"say_team Defend this objective!")
			}
		}
	return PLUGIN_HANDLED 
}

// voice_defendposition (british only)
public dodvoice_defpos(id) 
{
	if(can_play(id))
		{
		if(get_user_team(id) == 1 && is_brit[id]) 
			{
			emit_sound(id,CHAN_VOICE,"player/britdefendarea.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			client_cmd(id,"say_team Defend this position!")
			}	
		}
	return PLUGIN_HANDLED 
}

// voice_dropweapon (all teams)
public dodvoice_dropguns(id)
{
	if(can_play(id))
		{
		if(get_user_team(id) == 1)
			{
			if(is_brit[id])
				emit_sound(id,CHAN_VOICE,"player/britdropguns.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			else
				emit_sound(id,CHAN_VOICE,"player/usdropguns.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			}
		else
			emit_sound(id,CHAN_VOICE,"player/gerdropguns.wav",1.0,ATTN_NORM,0,PITCH_NORM)

		client_cmd(id,"say_team Drop your weapon!")
		}
	return PLUGIN_HANDLED 
}

// voice_left (all teams)
public dodvoice_firmleft(id)
{	
	if(can_play(id))
		{
		if(get_user_team(id) == 1) 
			{
			if(is_brit[id])
				emit_sound(id,CHAN_VOICE,"player/britleft.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			else
				emit_sound(id,CHAN_VOICE,"player/usleft.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			}
		else
			emit_sound(id,CHAN_VOICE,"player/germanleft.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			
		client_cmd(id,"say_team Left!")
		}
	return PLUGIN_HANDLED 
}

// voice_right (all teams)
public dodvoice_firmright(id)
{	
	if(can_play(id))
		{
		if(get_user_team(id) == 1) 
			{
			if(is_brit[id])
				emit_sound(id,CHAN_VOICE,"player/britright.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			else
				emit_sound(id,CHAN_VOICE,"player/usright.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			}
		else
			emit_sound(id,CHAN_VOICE,"player/germanright.wav",1.0,ATTN_NORM,0,PITCH_NORM)
		
		client_cmd(id,"say_team Right!")
		}
	return PLUGIN_HANDLED 
}

// voice_medic (all teams)
public dodvoice_medic(id)
{	
	if(can_play(id))
		{
		if(get_user_team(id) == 1)
			{
			if(is_brit[id])
				emit_sound(id,CHAN_VOICE,"player/britmedic.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			else
				emit_sound(id,CHAN_VOICE,"player/usmedic.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			}
		else
			emit_sound(id,CHAN_VOICE,"player/germedic.wav",1.0,ATTN_NORM,0,PITCH_NORM)
		
		client_cmd(id,"say_team Medic!")
		}
	return PLUGIN_HANDLED 
}

// voice_bringuppiat (british only)
public dodvoice_moveuppiat(id)
{
	if(can_play(id))
		{
		if(get_user_team(id) == 1 && is_brit[id]) 
			{
			emit_sound(id,CHAN_VOICE,"player/britbringuppiat.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			client_cmd(id,"say_team Bring up the piat!")
			}
		}
	return PLUGIN_HANDLED 
}

// voice_prepare (all teams)
public dodvoice_prepare(id)
{
	if(can_play(id))
		{
		if(get_user_team(id) == 1)
			{
			if(is_brit[id])
				emit_sound(id,CHAN_VOICE,"player/britprepare.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			else
				emit_sound(id,CHAN_VOICE,"player/usprepare.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			}
		else
			emit_sound(id,CHAN_VOICE,"player/gerprepare.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			
		client_cmd(id,"say_team Prepare for assualt!")
		}
	return PLUGIN_HANDLED 
}

// voice_spreadout (all teams)
public dodvoice_spreadout(id)
{
	if(can_play(id))
		{
		if(get_user_team(id) == 1)
			{
			if(is_brit[id])
				emit_sound(id,CHAN_VOICE,"player/britspeadout.wav",1.0,ATTN_NORM,0,PITCH_NORM)	// yes the typo is intentional!!!
			else
				emit_sound(id,CHAN_VOICE,"player/usspreadout.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			}
		else
			emit_sound(id,CHAN_VOICE,"player/gerspreadout.wav",1.0,ATTN_NORM,0,PITCH_NORM)

		client_cmd(id,"say_team Spread out!")
		}
	return PLUGIN_HANDLED 
}

// voice_tankahead (all teams)
public dodvoice_tankahead(id)
{
	if(can_play(id))
		{
		if(get_user_team(id) == 1)
			{
			if(is_brit[id])
				emit_sound(id,CHAN_VOICE,"player/brittigerahead.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			else
				emit_sound(id,CHAN_VOICE,"player/ustigerahead.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			}
		else
			emit_sound(id,CHAN_VOICE,"player/gertankahead.wav",1.0,ATTN_NORM,0,PITCH_NORM)
	
		client_cmd(id,"say_team Enemy tank ahead!")
		}
	return PLUGIN_HANDLED 
}

// voice_takecover (all teams)
public dodvoice_takecover(id)
{
	if(can_play(id))
		{
		if(get_user_team(id) == 1) 
			{
			if (is_brit[id])
				emit_sound(id,CHAN_VOICE,"player/brittakecover.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			else
				emit_sound(id,CHAN_VOICE,"player/ustakecover.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			}
		else
			emit_sound(id,CHAN_VOICE,"player/gertakecover.wav",1.0,ATTN_NORM,0,PITCH_NORM)

		client_cmd(id,"say_team Take Cover!")
		}
	return PLUGIN_HANDLED 
}

// voice_takeflank (all teams)
public dodvoice_takeflank(id)
{
	if(can_play(id))
		{
		if(get_user_team(id) == 1)
			{
			if (is_brit[id])
				emit_sound(id,CHAN_VOICE,"player/britflank.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			else
				emit_sound(id,CHAN_VOICE,"player/usflank.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			}
		else
			emit_sound(id,CHAN_VOICE,"player/gerflank.wav",1.0,ATTN_NORM,0,PITCH_NORM)
	
		client_cmd(id,"say_team Take the flank!")
		}
	return PLUGIN_HANDLED 
}

// voice_takeobjective (british only)
public dodvoice_takeobj(id)
{
	if(can_play(id))
		{
		if(get_user_team(id) == 1 && is_brit[id]) 
			{
			emit_sound(id,CHAN_VOICE,"player/brittakeobj.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			client_cmd(id,"say_team Take that objective!")
			}	
		}
	return PLUGIN_HANDLED 
}

// -------------------------------------------------------
// check if we should play the sound or not
public can_play(id)
{
	new Float:nexTime = get_gametime()
	
	// check for exessive spamming
	if(g_Flooding[id] > nexTime)   
		{
		g_Flooding[id] = nexTime + maxChat + 3.0
		client_print(id,print_chat,"** %L **",id,"STOP_FLOOD")
		return 0
		}
	g_Flooding[id] = nexTime + maxChat

	//check for brits
	if(get_user_team(id) == 1 && dod_get_map_info(MI_ALLIES_TEAM) == 1)
		is_brit[id] = 1
	else
		is_brit[id] = 0	

	if(is_user_connected(id) && is_user_alive(id) && (get_user_team(id) == 1 || get_user_team(id) == 2) && get_pcvar_num(p_voicemenus))
		return 1

	return 0
}

public dodvoice_menu4(id)
{
	if(is_user_connected(id) && is_user_alive(id) && (get_user_team(id) == 1 || get_user_team(id) == 2) && get_pcvar_num(p_voicemenus))
		{
		g_MenuPos[id] = 0	
			
		new menuBody[1024],key
			
		format(menuBody,1023,"1. Take the flank ^n2. Cover the flanks ^n3. Drop your weapon ^n4. Take cover ^n5. Spread out ^n6. Left ^n7. Right ^n8. Tank ahead ^n9. Medic ^n0. Cancel^n",-1,"dod_extra_voice_menu") 

		key = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9)
		show_menu(id,key,menuBody,-1,"dod_extra_voice_menu") 
		}
	return PLUGIN_HANDLED
}

public dodvoice_menu5(id)
{
	if(is_user_connected(id) && is_user_alive(id) && (get_user_team(id) == 1 || get_user_team(id) == 2) && get_pcvar_num(p_voicemenus))
		{
		g_MenuPos[id] = 1	
			
		new menuBody[1024],key	
			
		if(get_user_team(id) == 2)
			{
			format(menuBody,1023,"1. Prepare for the assualt ^n0. Cancel^n^n^n^n^n^n^n^n^n", -1, "dod_extra_voice_menu") 
			key = (1<<0)|(1<<9)
			}
			
		else if(get_user_team(id) == 1 && dod_get_map_info(MI_ALLIES_TEAM) == 1)
			{
			format(menuBody,1023,"1. Prepare for the assualt ^n2. Defend this objective ^n3. Defend this position ^n4. Take that objective ^n5. Bring up the piat ^n0. Cancel^n^n^n^n^n",-1,"dod_extra_voice_menu")  
			key = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<9)
			}
		
		else if(get_user_team(id) == 1)
			{
			format(menuBody,1023,"1. Prepare for the assualt ^n0. Cancel^n^n^n^n^n^n^n^n^n", -1, "dod_extra_voice_menu") 
			key = (1<<0)|(1<<9)
			}
			
		show_menu(id,key,menuBody,-1,"dod_extra_voice_menu") 
		}
}

public MenuChoice(id,key)
{
	if(is_user_connected(id) && is_user_alive(id) && (get_user_team(id) == 1 || get_user_team(id) == 2) && get_pcvar_num(p_voicemenus))
		{	
		switch(key)
			{
			//1
			case 0: 
				{
				switch(g_MenuPos[id])
					{
					case 0: dodvoice_takeflank(id)
					case 1: dodvoice_prepare(id)
					}
				}
			//2
			case 1: 
				{
				switch(g_MenuPos[id])
					{
					case 0: dodvoice_cflanks(id)
					case 1:
						{
						if(get_user_team(id) == 1 && dod_get_map_info(MI_ALLIES_TEAM) == 1)
							dodvoice_defobj(id)
						}
					}
				}
			//3
			case 2: 
				{
				switch(g_MenuPos[id])
					{
					case 0: dodvoice_dropguns(id)
					case 1:
						{
						if(get_user_team(id) == 1 && dod_get_map_info(MI_ALLIES_TEAM) == 1)
							dodvoice_defpos(id)
						}
					}
				}
			//4
			case 3: 
				{
				switch(g_MenuPos[id])
					{
					case 0: dodvoice_takecover(id)
					case 1:
						{
						if(get_user_team(id) == 1 && dod_get_map_info(MI_ALLIES_TEAM) == 1)
							dodvoice_takeobj(id)
						}
					}
				}
			//5
			case 4: 
				{
				switch(g_MenuPos[id])
					{
					case 0: dodvoice_spreadout(id)
					case 1: 
						{
						if(get_user_team(id) == 1 && dod_get_map_info(MI_ALLIES_TEAM) == 1)
							dodvoice_moveuppiat(id)
						}
					}
				}
			//6
			case 5: 
				{
				switch(g_MenuPos[id])
					{ 
					case 0: dodvoice_firmleft(id)
					}
				}
			//7
			case 6: 
				{
				switch(g_MenuPos[id])
					{
					case 0: dodvoice_firmright(id)
					}
				}
			//8
			case 7: 
				{
				switch(g_MenuPos[id])
					{
					case 0: dodvoice_tankahead(id)
					}
				}
			//9
			case 8: 
				{
				switch(g_MenuPos[id])
					{
					case 0: dodvoice_medic(id)
					}
				}
			//0
			case 9: return PLUGIN_HANDLED
			}
		}
		
	return PLUGIN_HANDLED
}
