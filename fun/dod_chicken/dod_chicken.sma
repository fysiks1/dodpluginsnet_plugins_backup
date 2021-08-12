/*
AMX Mod X Script
Chickenmod: Rebirth by T(+)rget
http://djeyl.net/forum/index.php?showtopic=39888

Ported to AMX Mod X by syphilis
Added ML by KWo based on ML existing in AMX' version of this plugin
Changes from T(+)rget's AMX Version:
* Removed translation information
* Boolean cstrike_running renamed to cs_running
* Used get_configsdir() instead of hardcoded path
* Changed AMX natives to AMX Mod X natives
* Included the comment block that you are reading
* Changed some client_print() messages to console_print()
* Added FakeMeta forwards for emitsound, traceline, and setmodel
* Added plugin_modules()

Ported to DoD by Hell Phoenix

CHANGELOG:
Changes from AMXX Port by syphilis to DoD Port V1.1
* Removed Boolean cs_running (dont need to detect if VIP or not)
* Changed all CS specific code to DoD Specific code
* Removed gibs function on chicken death (gibs crash DoD servers more often then not for some reason)
* Added death upon un/chickening someone as the model doesnt set or unset until respawn
* Changed cvar pointers to new pcvar system (more efficient code)
V1.2
* Fixed User glowing even if cvar was set to off
* Added green glow for allies and red glow for axis
* Fix grenade velocity being zero after being unchickened
V1.3
* Fixed things up for amxx 1.75 
  - Changed model settings that changed from beta dodx module
* Removed some code that wasnt needed
* Added saving config from the menu
v1.3.5
* Fixed being invisible after first death
v1.4
* Fixed players sinking into map when crouched
* Blocked fullupdate command to stop crashing of servers
* Added freezetime back in so that if you get chickened during beginning of round you cant spawn
* Removed chicken slash sounds...seemed out of place and didnt work correctly

Todo:
* Allow players to be chickened at any time not just when alive (so when you chicken everyone/team they dont all have to be alive)
* Fix chicken getting hit sound

Requirements:
* Requires AMXX 1.75 or above

Installation:
1) Compile the plugin and place it in your plugins folder
2) Download the "extras" zip file, an extract that file to your dod folder
3) Open the config file (chicken.cfg) and edit the settings you would like
4) Add an entry for amx_chicken.amxx to plugins.ini

Usage:
console commands:
* amx_chicken <@|1|2|Player> (turns everyone, team, or a single player into a chicken)
* amx_unchicken <@|1|2|Player> (turns everyone, team, or a single player back into a human)
* amx_chicken_menu (displays a menu for admins, can change config although not save at the moment, and un/chicken people/teams/everyone)
say commands:
* /chickenme   (this only works if you have chicken self ability enabled)
* /unchickenme   (this only works if you have chicken self ability enabled)
* /chickenmenu  (same as using amx_chicken_menu)
server commands
* c_chicken (works the same as amx_chicken, but other plugins can call it)
* c_unchicken (works the same as amx_unchicken)

*/

#include <amxmodx>
#include <amxmisc>
#include <dodx>
#include <dodfun>
#include <engine>
#include <fakemeta>
#include <fun>

//----------------------------------------------------------------------------------------------
/* ACCESS LEVELS */
new ACCESS_MENU
new ACCESS_SETTINGS

/* MENU FLAGS */
new MenuFlags[33]
new MenuPFlags[33]
new g_menuPlayers[33][32]
new g_menuPlayersNum[33]
new MenuGrv = 5
new MenuHP = 50
new MenuSpd = 40

/* CONFIG SETUP */
new bool:ChickenTeam1
new bool:ChickenTeam2
new bool:ChickenAll
new bool:HealthProtect
new bool:ChickenTalk
new bool:ChickenTeamTalk
new bool:ChickenSelf
new bool:ChickenGlow
new bool:ChickenGrenades
new ChickenHealth
new ChickenGravity
new ChickenSpeed
new ChickenHP = 35

/* OTHER */
new config[64]
new g_chicken_sfx
new bool:UserFlags[33]
new bool:FreezeTime = true
new ChickName[33][32]
new UserOldName[33][32]
new bool:ChickenName
new gmsgSetFOV
new ChickenVision = 135
new Float:cView[3] = {0.0, 0.0, -30.0}
new Float:nView[3] = {0.0, 0.0, 37.0}


//----------------------------------------------------------------------------------------------
/* PRECACHE CODE */
public plugin_precache()
	{
	// Models
	precache_model("models/player/chicken/chicken.mdl")
	precache_model("models/w_easterEgg.mdl")
	// Sounds
	precache_sound("misc/chicken0.wav")
	precache_sound("misc/chicken1.wav")
	precache_sound("misc/chicken2.wav")
	precache_sound("misc/chicken3.wav")
	precache_sound("misc/chicken4.wav")
	precache_sound("misc/cow.wav")
	precache_sound("misc/killChicken.wav")
	precache_sound("misc/knife_hit1.wav")
	precache_sound("misc/knife_hit3.wav")
}
//----------------------------------------------------------------------------------------------
/* INITIATION CODE */
public plugin_init()
	{
	register_plugin("ChickenMod: Rebirth", "1.4", "AMXX DoD Community/T(+)rget")
	register_dictionary("chicken.txt")
	
	get_configsdir(config, 63)
	format(config, 63, "%s/chicken.cfg", config)
	loadcfg(config)
	
	register_cvar("chicken_version", "1.4", FCVAR_SERVER|FCVAR_SPONLY)
	register_menucmd(register_menuid("[ChickenMod]"), 1023, "action_chickenmenu")
	gmsgSetFOV = get_user_msgid("SetFOV")
	register_event("TextMsg","round_start","bc"," 1=3","2=#game_roundstart_axis1")
	register_event("TextMsg","round_start","bc"," 1=3","2=#game_roundstart_axis2") 
	register_event("RoundState", "round_end", "a", "1=3", "1=4", "1=5") 
	register_event("SetFOV", "check_fov", "be", "1=90")
	register_event("DeathMsg", "death_event", "a")
	register_event("ResetHUD", "chicken_update", "b")	
	register_event("CurWeapon","get_weapon","b")
	register_srvcmd("c_chicken", "c_chicken", ACCESS_MENU, "<authid, nick, #userid, @1/2 (1 = Allies, 2 = Axis) or * (all)>")
	register_srvcmd("c_unchicken", "c_unchicken", ACCESS_MENU, "<authid, nick, #userid, @1/2 (1 = Allies, 2 = Axis) or * (all)>")
	register_clcmd("amx_chicken", "c_chicken", ACCESS_MENU, "<authid, nick, #userid, @1/2 (1 = Allies, 2 = Axis) or * (all)>")
	register_clcmd("amx_unchicken", "c_unchicken", ACCESS_MENU, "<authid, nick, #userid, @1/2 (1 = Allies, 2 = Axis) or * (all)>")
	register_clcmd("say /chickenmenu", "amx_chicken_menu", ACCESS_MENU, "- [ChickenMod]: User Interface")
	register_clcmd("amx_chicken_menu", "amx_chicken_menu", ACCESS_MENU, "- [ChickenMod]: User Interface")
	register_clcmd("say", "chickensay")
	register_clcmd("say_team", "chickenteamsay")
	register_clcmd("say /chickenme", "chickensay", 0, "- chicken yourself")
	register_clcmd("say /unchickenme", "chickensay", 0, "- unchicken yourself")
	register_clcmd("fullupdate","fullupdate")
	g_chicken_sfx = register_cvar("amx_chicken_sfx", "1")
	
	register_forward(FM_SetModel, "set_model")
	register_forward(FM_EmitSound, "emitsound")
	register_forward(FM_TraceLine, "forward_traceline", 1)
	register_forward(FM_PlayerPreThink,"PreThink")
	
	
}

public plugin_modules()
	{
	require_module("dodx")
	require_module("engine")
	require_module("fakemeta")
}

//----------------------------------------------------------------------------------------------
/* BLOCK THE LAMERS WHO TRY TO CRASH THE SERVER */
public fullupdate(id) {
	return PLUGIN_HANDLED
}

//----------------------------------------------------------------------------------------------
public c_chicken(id, level, cid)
	{
	if(FreezeTime){
		console_print(id, "Please wait till the round starts")
		return PLUGIN_HANDLED
	}
	if(id != 0 && !FreezeTime)
		{
		if(!cmd_access(id, level, cid, 2))
			{
			return PLUGIN_HANDLED
		}
	}
	new arg[32]
	read_argv(1, arg, 31)
	
	if(arg[0] == '@')
		{
		new users[32], inum, team = str_to_num(arg[1])
		get_players(users, inum, "a")
		
		if(team == 1 && ChickenTeam1 == false)
			{
			ChickenTeam1 = true
			for(new i = 0; i < inum; ++i)
				{
				if(get_user_team(users[i]) == 1)
					{
					chicken_user(users[i])
				}
				set_hudmessage(255, 25, 255, 0.05, 0.65, 2, 0.1, 4.0, 0.02, 0.02, 10)
				show_hudmessage(0, "%L", LANG_PLAYER, "TEAM_AL_TRANSF_INTO_CHICKENS")
			}
			if(get_pcvar_num(g_chicken_sfx))
				{
				chicken_sound(0)
			}
			return PLUGIN_HANDLED
		}
		else if(team == 1 && ChickenTeam1)
			{
			console_print(id, "%L", id, "TEAM_AL_ALREADY_CHICKENS")
		}
		else if(team == 2 && ChickenTeam2 == false)
			{
			ChickenTeam2 = true
			for(new i = 0; i < inum; ++i)
				{
				if(get_user_team(users[i]) == 2)
					{
					chicken_user(users[i])
				}
				set_hudmessage(255, 25, 255, 0.05, 0.65, 2, 0.1, 4.0, 0.02, 0.02, 10)
				show_hudmessage(0, "%L", LANG_PLAYER, "TEAM_AX_TRANSF_INTO_CHICKENS")
			}
			if(get_pcvar_num(g_chicken_sfx))
				{
				chicken_sound(0)
			}
			return PLUGIN_HANDLED
		}
		else if(team == 2 && ChickenTeam2)
			{
			console_print(id, "%L", id, "TEAM_AX_ALREADY_CHICKENS")
		}
		else
			{
			console_print(id, "%L", id, "USAGE_CH")
		}
		return PLUGIN_HANDLED
	}
	else if(arg[0] == '*')
		{
		if(ChickenAll == false)
			{
			ChickenAll = true
			chicken_user(0)
			set_hudmessage(255, 25, 255, 0.05, 0.65, 2, 0.1, 4.0, 0.02, 0.02, 10)
			show_hudmessage(0, "%L", LANG_PLAYER, "EVERY1_TRANSF_INTO_CHICKENS")
			
			if(get_pcvar_num(g_chicken_sfx))
				{
				chicken_sound(0)
			}
		}
		else
			{
			console_print(id, "%L", id, "EVERY1_ALREADY_CHICKENS")
		}
		return PLUGIN_HANDLED
	}
	else
		{
		new user[32], player = cmd_target(id, arg, 7)
		get_user_name(player, user, 31)
		
		if(!player)
			{
			return PLUGIN_HANDLED
		}
		if(UserFlags[player] == false)
			{
			chicken_user(player)
			set_hudmessage(255, 25, 255, 0.05, 0.65, 2, 0.1, 4.0, 0.02, 0.02, 10)
			if(get_pcvar_num(g_chicken_sfx))
				{
				emit_sound(player, CHAN_ITEM, "misc/chicken0.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
			
			show_hudmessage(0, "%L", LANG_PLAYER, "PL_TRANSF_INTO_CHICKEN", user)
		}
		else
			{
			console_print(id, "%L", id, "PL_ALREADY_CHICKEN", user)
		}
	}
	return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
public c_unchicken(id, level, cid)
	{
	if(id != 0)
		{
		if(!cmd_access(id, level, cid, 2))
			{
			return PLUGIN_HANDLED
		}
	}
	
	new arg[32]
	read_argv(1, arg, 31)
	
	if(arg[0] == '@')
		{
		new users[32], inum, team = str_to_num(arg[1])
		get_players(users, inum, "a")
		
		if(team == 1 && ChickenTeam1)
			{
			ChickenTeam1 = false
			for(new i = 0; i < inum; ++i)
				{
				if(get_user_team(users[i]) == 1)
					{
					unchicken_user(users[i])
				}
				set_hudmessage(255, 25, 255, 0.05, 0.65, 2, 0.1, 4.0, 0.02, 0.02, 10)
				show_hudmessage(0, "%L", LANG_PLAYER, "TEAM_AL_REST_INTO_HUMANS")
			}
			if(get_pcvar_num(g_chicken_sfx))
				{
				chicken_sound(5)
			}
			return PLUGIN_HANDLED
		}
		else if(team == 1 && ChickenTeam1 == false)
			{
			console_print(id, "%L", id, "TEAM_AL_ALREADY_HUMANS")
		}
		else if(team == 2 && ChickenTeam2)
			{
			ChickenTeam2 = false
			for(new i = 0; i < inum; ++i)
				{
				if(get_user_team(users[i]) == 2)
					{
					unchicken_user(users[i])
				}
				set_hudmessage(255, 25, 255, 0.05, 0.65, 2, 0.1, 4.0, 0.02, 0.02, 10)
				show_hudmessage(0, "%L", LANG_PLAYER, "TEAM_AX_REST_INTO_HUMANS")
			}
			if(get_pcvar_num(g_chicken_sfx))
				{
				chicken_sound(5)
			}
			return PLUGIN_HANDLED
		}
		else if(team == 2 && ChickenTeam2 == false)
			{
			console_print(id, "%L", id, "TEAM_AX_ALREADY_HUMANS")
		}
		else
			{
			console_print(id, "%L", id, "USAGE_UNCH")
		}
		return PLUGIN_HANDLED
	}
	else if(arg[0] == '*')
		{
		if(ChickenAll == true)
			{
			ChickenAll = false
			unchicken_user(0)
			set_hudmessage(255, 25, 255, 0.05, 0.65, 2, 0.1, 4.0, 0.02, 0.02, 10)
			show_hudmessage(0, "%L", LANG_PLAYER, "EVERY1_REST_INTO_HUMANS")
			
			if(get_pcvar_num(g_chicken_sfx))
				{
				chicken_sound(5)
			}
		}
		else
			{
			console_print(id, "%L", id, "EVERY1_ALREADY_HUMANS")
		}
		return PLUGIN_HANDLED
	}
	else
		{
		new user[32], player = cmd_target(id, arg, 7)
		get_user_name(player, user, 31)
		
		if(!player)
			{
			return PLUGIN_HANDLED
		}
		if(UserFlags[player])
			{
			unchicken_user(player)
			set_hudmessage(255, 25, 255, 0.05, 0.65, 2, 0.1, 4.0, 0.02, 0.02, 10)
			
			if(get_pcvar_num(g_chicken_sfx))
				{
				emit_sound(player, CHAN_ITEM, "misc/cow.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
			show_hudmessage(0, "%L", LANG_PLAYER, "PL_RESTORED_INTO_HUMAN", user)
		}
		else
			{
			console_print(id, "%L", id, "PL_ALREADY_HUMAN", user)
		}
	}
	return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
/* SAY COMMAND CODE */
public chickensay(id)
	{
	if(is_user_bot(id))
		{
		return PLUGIN_CONTINUE
	}
	new words[32]
	read_args(words, 31)
	
	if(UserFlags[id])
		{
		if(ChickenSelf)
			{
			if(equali(words, "^"/unchickenme^""))
				{
				if(!is_user_alive(id))
					{
					client_print(id, 3, "%L", id, "CANT_TURN_BACK_INTO_HUMAN")
				}
				else
					{
					unchicken_user(id)
					emit_sound(id, CHAN_ITEM, "misc/cow.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					set_hudmessage(255, 25, 255, 0.05, 0.65, 2, 0.1, 4.0, 0.02, 0.02, 10)
					show_hudmessage(0, "%L", LANG_PLAYER, "REST_HUMAN_HIMSELF", UserOldName[id])
					dod_user_kill(id)
				}
				return PLUGIN_HANDLED
			}
		}
		if(ChickenTalk && is_user_alive(id) && !is_user_bot(id))
			{
			saying_match(id)
			return PLUGIN_HANDLED
		}
	}
	else if(equali(words, "^"/chickenme^""))
		{
		if(ChickenSelf)
			{
			if(get_user_health(id) <= ChickenHP)
				{
				client_print(id, 3, "%L", id, "CANT_TURN_CHICKEN_LOW_HEALTH")
				return PLUGIN_HANDLED
			}
			if(!is_user_alive(id))
				{
				client_print(id, 3, "%L", id, "CANT_TURN_CHICKEN_DEATH")
				return PLUGIN_HANDLED
			}
			else
				{
				chicken_user(id)
				emit_sound(id, CHAN_ITEM, "misc/chicken0.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				set_hudmessage(255, 25, 255, 0.05, 0.65, 2, 0.1, 4.0, 0.02, 0.02, 10)
				new user[33]
				get_user_name(id, user, 32)
				show_hudmessage(0, "%L", LANG_PLAYER, "TRANSF_HIMSELF_INTO_CHICKEN", user)
				return PLUGIN_HANDLED
			}
		}
	}
	return PLUGIN_CONTINUE
}
//----------------------------------------------------------------------------------------------
/* SAY_TEAM COMMAND CODE */
public chickenteamsay(id)
	{
	if(ChickenTeamTalk && UserFlags[id] && is_user_alive(id) && !is_user_bot(id))
		{
		saying_match(id)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}
//----------------------------------------------------------------------------------------------
/* SAY/SAY_TEAM CHICKEN CODE */
saying_match(id)
{
	new user[33], ChickenMsg = random(4)
	get_user_name(id, user, 32)
	
	if(ChickenMsg == 0)
		{
		client_print(0, 3, "%s: buk buk", user)
		chicken_sound(1)
	}
	else if(ChickenMsg == 1)
		{
		client_print(0, 3, "%s: buk buk", user)
		chicken_sound(2)
	}
	else if(ChickenMsg == 2)
		{
		client_print(0, 3, "%s: buk buk", user)
		chicken_sound(3)
	}
	else
		{
		client_print(0, 3, "%s: buGAWK", user)
		chicken_sound(4)
	}
	return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
/* SOUND SFX CODE */
chicken_sound(sndno)
{
	if(!get_pcvar_num(g_chicken_sfx))
		{
		return PLUGIN_HANDLED
	}
	new users[32], inum
	get_players(users, inum, "c")
	
	for(new i = 0; i < inum; ++i)
		{
		switch(sndno)
		{
			case 0: client_cmd(users[i], "speak sound/misc/chicken0")
			case 1: client_cmd(users[i], "speak sound/misc/chicken1")
			case 2: client_cmd(users[i], "speak sound/misc/chicken2")
			case 3: client_cmd(users[i], "speak sound/misc/chicken3")
			case 4: client_cmd(users[i], "speak sound/misc/chicken4")
			case 5: client_cmd(users[i], "speak sound/misc/cow")
		}
	}
	return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
/* SHOW MENU CODE */
public amx_chicken_menu(id, level, cid)
	{
	if(!cmd_access(id, level, cid, 1))
		{
		return PLUGIN_HANDLED
	}
	MenuFlags[id] = 1
	show_chickenmenu(id)
	return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
show_chickenmenu(id)
{
	new menuoption[10][64], smenu[64], menubody[512]
	new keys
	for(new z = 0; z < 10; ++z) menuoption[z][0] = 0 // clear string
	
	switch(MenuFlags[id])
	{
		case 1: /* Main Menu */
		{
			format(smenu, 63, "%L", id, "MAIN_MENU")
			format(menuoption[0], 63, "1. %L^n", id, "PLAYERS_MENU")
			format(menuoption[1], 63, "2. %L^n", id, "TEAM_MENU")
			
			if(id && get_user_flags(id) & ACCESS_SETTINGS != ACCESS_SETTINGS) {}
			else
				{
				format(menuoption[2], 63, "3. %L^n", id, "SETTINGS_MENU")
				keys |= (1<<2)
			}
			format(menuoption[9], 63, "^n0. %L", id, "EXIT")
			keys |= (1<<0)|(1<<1)|(1<<9)
			
			format(menubody, 511, "%L", id, "CHICKENMOD_OPTIONS",
			smenu, menuoption[0], menuoption[1], menuoption[2], menuoption[3], menuoption[4],
			menuoption[5], menuoption[6], menuoption[7], menuoption[8], menuoption[9])
			show_menu(id, keys, menubody, -1, "[ChickenMod]")
		}
		case 2: /* Players Menu */
		{
			switch(MenuPFlags[id])
			{
				default:
				{
					get_players(g_menuPlayers[id], g_menuPlayersNum[id])
					new b = 0, i, user[32], menu = MenuPFlags[id], start = menu * 7
					
					if(start >= g_menuPlayersNum[id])
						{
						start = MenuPFlags[id] = 0
					}
					format(smenu, 63, "%L", id, "PLAYERS_MENU")
					new len = format(menubody, 511, "%L", id, "CHICKENMOD_PLAYERS", smenu,
					++menu, (g_menuPlayersNum[id] / 7 + ((g_menuPlayersNum[id] % 7) ? 1 : 0)))
					/*
					new len = format(menubody, 511, "%L", id, "CHICKENMOD_PLAYERS",
					++menu, (g_menuPlayersNum[id] / 7 + ((g_menuPlayersNum[id] % 7) ? 1 : 0)))
					*/
					new pkeys = (1<<8)|(1<<9), end = start + 7
					
					if(end > g_menuPlayersNum[id])
						{
						end = g_menuPlayersNum[id]
					}
					for(new a = start; a < end; ++a)
						{
						i = g_menuPlayers[id][a]
						get_user_name(i, user, 31)
						if(!is_user_alive(i))
							{
							++b
							len += format(menubody[len], 511 - len, "\d%d. %s\R%L^n\w", b, user, id, "DEAD")
						}
						else
							{
							pkeys |= (1<<b)
							len += format(menubody[len], 511 - len, "%d. %s\R\y%L^n\w", ++b, user, id, UserFlags[i] ? "CHICKEN" : "HUMAN")
						}
					}
					if(end != g_menuPlayersNum[id])
						{
						len += format(menubody[len], 511 - len, "^n8. %L^n^n9. %L^n0. %L", id, "MORE", id, "BACK", id, "EXIT")
						pkeys |= (1<<7)
					}
					else
						{
						len += format(menubody[len], 511 - len, "^n9. %L^n0. %L", id, "BACK", id, "EXIT")
					}
					show_menu(id, pkeys, menubody, -1, "[ChickenMod]")
				}
			}
		}
		case 3:  /* Team Menu */
		{
			format(smenu, 63, "%L", id, "TEAM_MENU")
			format(menuoption[0], 63, "1. %L\R\y%L^n\w", id, "ALLIES", id, ChickenTeam1 ? "YES" : "NO")
			format(menuoption[1], 63, "2. %L\R\y%L^n\w", id, "AXIS", id, ChickenTeam2 ? "YES" : "NO")
			format(menuoption[2], 63, "3. %L\R\y%L^n\w", id, "EVERYONE", id, ChickenAll ? "YES" : "NO")
			format(menuoption[8], 63, "^n9. %L", id, "BACK")
			format(menuoption[9], 63, "^n0. %L", id, "EXIT")
			keys = (1<<0)|(1<<1)|(1<<2)|(1<<8)|(1<<9)
			
			format(menubody, 511, "%L", id, "CHICKENMOD_OPTIONS",
			smenu, menuoption[0], menuoption[1], menuoption[2], menuoption[3], menuoption[4],
			menuoption[5], menuoption[6], menuoption[7], menuoption[8], menuoption[9])
			show_menu(id, keys, menubody, -1, "[ChickenMod]")
		}
		case 4:  /* Setting Menu 1*/
		{
			format(smenu, 63, "%L", id, "SETTINGS_MENU")
			format(menuoption[0], 63, "1. %L\R\y%L^n\w", id, "CHICKEN_GRENADES", id, ChickenGrenades ? "ON" : "OFF")
			format(menuoption[1], 63, "2. %L\R\y%L^n\w", id, "CHICKEN_GLOWING", id, ChickenGlow ? "ON" : "OFF")
			format(menuoption[2], 63, "3. %L\R\y%L^n\w", id, "HEALTH_PROTECTION", id, HealthProtect ? "ON" : "OFF")
			format(menuoption[3], 63, "4. %L\R\y%L^n\w", id, "CHICKEN_NAMING", id, ChickenName ? "ON" : "OFF")
			format(menuoption[4], 63, "5. %L\R\y%L^n\w", id, "CHICKEN_SELF_ABILITY", id, ChickenSelf ? "ON" : "OFF")
			format(menuoption[5], 63, "6. %L\R\y%L^n^n\w", id, "CHICKEN_TALKING", id, ChickenTalk ? "ON" : "OFF")
			format(menuoption[6], 63, "7. %L^n^n", id, "SAVE")
			format(menuoption[7], 63, "8. %L^n", id, "MORE")
			format(menuoption[8], 63, "9. %L^n", id, "BACK")
			format(menuoption[9], 63, "0. %L", id, "EXIT")
			keys = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9)
			
			format(menubody, 511,  "%L", id, "CHICKENMOD_OPTIONS",
			smenu, menuoption[0], menuoption[1], menuoption[2], menuoption[3], menuoption[4],
			menuoption[5], menuoption[6], menuoption[7], menuoption[8], menuoption[9])
			show_menu(id, keys, menubody, -1, "[ChickenMod]")
		}
		case 5: /* Setting Menu 2*/
		{
			format(smenu, 63, "%L", id, "SETTINGS_MENU")
			format(menuoption[0], 63, "1. %L\R\y%L^n\w", id, "CHICKEN_TEAM_TALKING", id, ChickenTeamTalk ? "ON" : "OFF")
			format(menuoption[1], 63, ChickenSelf ? "2. %L\R\y%i^n\w" : "\d2. %L\R%i^n\w", id, "NOT_ALLOWED_CHICKEN", ChickenHP)
			format(menuoption[2], 63, "3. %L\R\y%i^n\w", id, "CHICKEN_HEALTH", ChickenHealth)
			format(menuoption[3], 63, "4. %L\R\y%i^n\w", id, "CHICKEN_GRAVITY", ChickenGravity)
			format(menuoption[4], 63, "5. %L\R\y%i^n\w", id, "CHICKEN_SPEED", ChickenSpeed)
			format(menuoption[5], 63, "6. %L\R\y%i^n\w", id, "CHICKEN_VISION", ChickenVision)
			format(menuoption[6], 63, "7. %L\R\y%L^n^n\w", id, "CHICKEN_SPEC_EFF", id, get_pcvar_num(g_chicken_sfx) ? "ON" : "OFF")
			format(menuoption[7], 63, "8. %L^n^n", id, "SAVE")
			format(menuoption[8], 63, "9. %L^n", id, "BACK")
			format(menuoption[9], 63, "0. %L", id, "EXIT")
			keys = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9)
			
			format(menubody, 511,  "%L", id, "CHICKENMOD_OPTIONS",
			smenu, menuoption[0], menuoption[1], menuoption[2], menuoption[3], menuoption[4],
			menuoption[5], menuoption[6], menuoption[7], menuoption[8], menuoption[9])
			show_menu(id, keys, menubody, -1, "[ChickenMod]")
		}
	}
	return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
/* ACTION MENU CODE */
public action_chickenmenu(id, key)
	{
	if(MenuFlags[id] == 1)
		{
		switch(key)
		{
			case 0: MenuFlags[id] = 2 // PLAYERS MENU BUTTON (1)
			case 1: MenuFlags[id] = 3 // TEAM MENU BUTTON (2)
			case 2: MenuFlags[id] = 4 // SETTINGS MENU BUTTON (3)
			case 9: // EXIT BUTTON (0)
			{
				// Menu Fix (Popup)
				MenuFlags[id] = 0
				return PLUGIN_HANDLED
			}
		}
		// Bypass Update System
		show_chickenmenu(id)
		return PLUGIN_HANDLED
	}
	else if(MenuFlags[id] == 2)
		{
		switch(key)
		{
			case 7: // MORE BUTTON (8)
			{
				++MenuPFlags[id]
				// Bypass Update System
				show_chickenmenu(id)
				return PLUGIN_HANDLED
			}
			case 8: // BACK BUTTON (9)
			{
				if(MenuPFlags[id] > 0)
					{
					// Bypass Update System
					--MenuPFlags[id]
					show_chickenmenu(id)
					return PLUGIN_HANDLED
				}
				else
					{
					// Bypass Update System
					MenuFlags[id] = 1
					show_chickenmenu(id)
					return PLUGIN_HANDLED
				}
			}
			case 9: // EXIT BUTTON (0)
			{
				// Menu Fix (Popup)
				MenuFlags[id] = 0
				return PLUGIN_HANDLED
			}
			default:
			{
				new player = g_menuPlayers[id][MenuPFlags[id] * 7 + key]
				new user[33]
				get_user_name(player, user, 32)
				
				if(UserFlags[player])
					{
					unchicken_user(player)
					set_hudmessage(255, 25, 255, 0.05, 0.65, 2, 0.1, 4.0, 0.02, 0.02, 10)
					
					if(get_pcvar_num(g_chicken_sfx))
						{
						emit_sound(player, CHAN_ITEM, "misc/cow.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					}
					show_hudmessage(0, "%L", LANG_PLAYER, "PL_RESTORED_INTO_HUMAN", user)
				}
				else
					{
					chicken_user(player)
					set_hudmessage(255, 25, 255, 0.05, 0.65, 2, 0.1, 4.0, 0.02, 0.02, 10)
					
					if(get_pcvar_num(g_chicken_sfx))
						{
						emit_sound(player, CHAN_ITEM, "misc/chicken0.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					}
					show_hudmessage(0, "%L", LANG_PLAYER, "PL_TRANSF_INTO_CHICKEN", user)
				}
			}
		}
	}
	else if(MenuFlags[id] == 3)
		{
		new users[32], inum
		get_players(users, inum, "a")
		switch(key)
		{
			case 0:
			{
				if(ChickenTeam1 == false)
					{
					ChickenTeam1 = true
					for(new i = 0; i < inum; ++i)
						{
						if(get_user_team(users[i]) == 1)
							{
							chicken_user(users[i])
						}
						if(get_pcvar_num(g_chicken_sfx))
							{
							chicken_sound(0)
						}
						set_hudmessage(255, 25, 255, 0.05, 0.65, 2, 0.1, 4.0, 0.02, 0.02, 10)
						show_hudmessage(0, "%L", LANG_PLAYER, "TEAM_AL_TRANSF_INTO_CHICKENS")
					}
				}
				else
					{
					ChickenTeam1 = false
					for(new i = 0; i < inum; ++i)
						{
						if(get_user_team(users[i]) == 1)
							{
							unchicken_user(users[i])
						}
						if(get_pcvar_num(g_chicken_sfx))
							{
							chicken_sound(5)
						}
						set_hudmessage(255, 25, 255, 0.05, 0.65, 2, 0.1, 4.0, 0.02, 0.02, 10)
						show_hudmessage(0, "%L", LANG_PLAYER, "TEAM_AL_REST_INTO_HUMANS")
					}
				}
			}
			case 1:
			{
				if(ChickenTeam2 == false)
					{
					ChickenTeam2 = true
					for(new i = 0; i < inum; ++i)
						{
						if(get_user_team(users[i]) == 2)
							{
							chicken_user(users[i])
						}
						if(get_pcvar_num(g_chicken_sfx))
							{
							chicken_sound(0)
						}
						set_hudmessage(255, 25, 255, 0.05, 0.65, 2, 0.1, 4.0, 0.02, 0.02, 10)
						show_hudmessage(0, "%L", LANG_PLAYER, "TEAM_AX_TRANSF_INTO_CHICKENS")
					}
				}
				else
					{
					ChickenTeam2 = false
					for(new i = 0; i < inum; ++i)
						{
						if(get_user_team(users[i]) == 2)
							{
							unchicken_user(users[i])
						}
						if(get_pcvar_num(g_chicken_sfx))
							{
							chicken_sound(5)
						}
						set_hudmessage(255, 25, 255, 0.05, 0.65, 2, 0.1, 4.0, 0.02, 0.02, 10)
						show_hudmessage(0, "%L", LANG_PLAYER, "TEAM_AX_REST_INTO_HUMANS")
					}
				}
			}
			case 2:
			{
				if(ChickenAll == false)
					{
					ChickenAll = true
					chicken_user(0)
					
					if(get_pcvar_num(g_chicken_sfx))
						{
						chicken_sound(0)
					}
					set_hudmessage(255, 25, 255, 0.05, 0.65, 2, 0.1, 4.0, 0.02, 0.02, 10)
					show_hudmessage(0, "%L", LANG_PLAYER, "EVERY1_TRANSF_INTO_CHICKENS")
				}
				else
					{
					ChickenAll = false
					unchicken_user(0)
					
					if(get_pcvar_num(g_chicken_sfx))
						{
						chicken_sound(5)
					}
					set_hudmessage(255, 25, 255, 0.05, 0.65, 2, 0.1, 4.0, 0.02, 0.02, 10)
					show_hudmessage(0, "%L", LANG_PLAYER, "EVERY1_REST_INTO_HUMANS")
				}
			}
			case 8: // BACK BUTTON (9)
			{
				// Bypass Update System
				MenuFlags[id] = 1
				show_chickenmenu(id)
				return PLUGIN_HANDLED
			}
			case 9: // EXIT BUTTON (0)
			{
				// Menu Fix (Popup)
				MenuFlags[id] = 0
				return PLUGIN_HANDLED
			}
		}
	}
	else if(MenuFlags[id] == 4)
		{
		switch(key)
		{
			case 0:
			{
				ChickenGrenades ? (ChickenGrenades = false) : (ChickenGrenades = true)
			}
			case 1:
			{
				ChickenGlow ? (ChickenGlow = false) : (ChickenGlow = true)
				call_glow(0)
			}
			case 2:
			{
				HealthProtect ? (HealthProtect = false) : (HealthProtect = true)
			}
			case 3:
			{
				ChickenName ? (ChickenName = false) : (ChickenName = true)
			}
			case 4:
			{
				ChickenSelf ? (ChickenSelf = false) : (ChickenSelf = true)
			}
			case 5:
			{
				ChickenTalk ? (ChickenTalk = false) : (ChickenTalk = true)
			}
			case 6:
			{
				savefile(config)
				client_print(id, print_chat, "* %L", id, "CHICK_CONF_SAVED")
			}
			case 7: // MORE BUTTON (8)
			{
				// Bypass Update System
				MenuFlags[id] = 5
				show_chickenmenu(id)
				return PLUGIN_HANDLED
			}
			case 8: // BACK BUTTON (9)
			{
				// Bypass Update System
				MenuFlags[id] = 1
				show_chickenmenu(id)
				return PLUGIN_HANDLED
			}
			case 9: // EXIT BUTTON (0)
			{
				// Menu Fix (Popup)
				MenuFlags[id] = 0
				return PLUGIN_HANDLED
			}
		}
	}
	else if(MenuFlags[id] == 5)
		{
		switch(key)
		{
			case 0:
			{
				ChickenTeamTalk ? (ChickenTeamTalk = false) : (ChickenTeamTalk = true)
			}
			case 1:
			{
				if(!ChickenSelf)
					{
					// Bypass Update System
					show_chickenmenu(id)
					return PLUGIN_HANDLED
				}
				else if(ChickenHP + MenuGrv > 100 || ChickenHP > 100)
					{
					ChickenHP = 0
				}
				else
					{
					ChickenHP += MenuGrv
				}
			}
			case 2:
			{
				new health = ChickenHealth
				
				if(HealthProtect)
					{
					if(health + MenuHP > 255 || health > 255)
						{
						ChickenHealth = 1
					}
					else
						{
						ChickenHealth = (health += MenuHP)
					}
				}
				else
					{
					ChickenHealth = (health += MenuHP)
				}
			}
			case 3:
			{
				new gravity = ChickenGravity
				
				if(gravity + MenuGrv > 100 || gravity > 100)
					{
					ChickenGravity = 0
				}
				else
					{
					ChickenGravity = (gravity += MenuGrv)
				}
				call_gravity(0) // Update all Chickens to new gravity setting
			}
			case 4:
			{
				new speed = ChickenSpeed
				
				if(speed + MenuSpd > 400 || speed > 400)
					{
					ChickenSpeed = 0
				}
				else
					{
					ChickenSpeed = (speed += MenuSpd)
				}
				call_speed(0) // Update all Chickens to new speed setting
			}
			case 5:
			{
				if(ChickenVision + MenuGrv > 255 || ChickenVision > 255)
					{
					ChickenVision = 0
				}
				else
					{
					ChickenVision += MenuGrv
				}
				call_vision(0) // Update all Chickens to new vision setting
			}
			case 6:
			{
				set_pcvar_num(g_chicken_sfx, get_pcvar_num(g_chicken_sfx) ? 0 : 1)
			}
			case 7:
			{
				savefile(config)
				client_print(id, print_chat, "* %L", id, "CHICK_CONF_SAVED")
			}
			case 8: // BACK BUTTON (9)
			{
				// Bypass Update System
				MenuFlags[id] = 4
				show_chickenmenu(id)
				return PLUGIN_HANDLED
			}
			case 9: // EXIT BUTTON (0)
			{
				// Menu Fix (Popup)
				MenuFlags[id] = 0
				return PLUGIN_HANDLED
			}
		}
	}
	update_menu()
	return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
/* MENU UPDATER */
update_menu()
{
	new admins[32], inum
	get_players(admins, inum)
	for(new i = 0; i < inum; ++i)
		{
		if(MenuFlags[admins[i]] > 1)
			{
			show_chickenmenu(admins[i])
		}
	}
}
//----------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------
/* FIELD OF VIEW EVENT CODE */
public check_fov(id)
	{
	if(UserFlags[id])
		{
		set_vision(id)
	}
}

//----------------------------------------------------------------------------------------------
/*CHECK WEAPONS CODE */
public get_weapon(id)
	{
	if(UserFlags[id])
		{
		new ammo, clip, wid
		wid = dod_get_user_weapon(id, clip, ammo)
		if(wid != DODW_AMERKNIFE || DODW_SPADE || DODW_BRITKNIFE && (!ChickenGrenades ) )
			{
			client_cmd(id,"drop")
		}
		else if(wid != DODW_AMERKNIFE || DODW_SPADE || DODW_BRITKNIFE  || DODW_STICKGRENADE || DODW_MILLS_BOMB || DODW_HANDGRENADE )
			{
			client_cmd(id,"drop")
		}
		entity_set_string(id, EV_SZ_weaponmodel, "")
		if(!FreezeTime)
			{
			call_speed(id)
		}
		
	}
	return PLUGIN_CONTINUE
}
//----------------------------------------------------------------------------------------------
/* STRIP WEAPONS */
public player_give(player[])
	{
	if ( player[1] ){
		strip_user_weapons(player[0])
		
		if(get_user_team(player[0]) == 2){ 
			give_item(player[0],"weapon_spade")
			if (ChickenGrenades){
				give_item(player[0],"weapon_stickgrenade")
				dod_set_user_ammo(player[0],DODW_STICKGRENADE, 2)
			}			
		} 
		else if(get_user_team(player[0]) == 1){
			if(dod_get_map_info(MI_ALLIES_TEAM) == 1){
				give_item(player[0],"weapon_britknife")
				if (ChickenGrenades){
					give_item(player[0], "weapon_mills_bomb")
					dod_set_user_ammo(player[0],DODW_MILLS_BOMB, 2)
				}
			}
			else if(dod_get_map_info(MI_ALLIES_TEAM) == 0){
				give_item(player[0],"weapon_amerknife")
				if (ChickenGrenades){
					give_item(player[0], "weapon_handgrenade")
					dod_set_user_ammo(player[0],DODW_HANDGRENADE,2)
				}
			}
		}
	}
}
//----------------------------------------------------------------------------------------------
/* RESETHUD EVENT CODE */
public chicken_update(id)
	{
	if(UserFlags[id])
		{
		call_glow(id)
		call_health(id)
		call_gravity(id)
		call_speed(id)
		call_vision(id)
		call_name(id)
		new player[2]
		player[0] = id
		player[1] = 1
		set_task(0.2,"player_give",id,player,2)
		
	}
	new team = get_user_team(id)
	
	if(ChickenTeam1)
		{
		if(1 == team && UserFlags[id] == false)
			{
			chicken_user(id)
		}
	}
	if(ChickenTeam2)
		{
		if(2 == team && UserFlags[id] == false)
			{
			chicken_user(id)
		}
	}
	if(ChickenAll)
		{
		if(0 > team && 5 < team)
			{
			if(UserFlags[id] == false)
				{
				chicken_user(id)
			}
		}
	}
	update_menu()
}

//----------------------------------------------------------------------------------------------
/* NEWROUND EVENT CODE */
public round_start()
	{
	FreezeTime = false
	set_task(0.01, "call_speed", 0)
}
//----------------------------------------------------------------------------------------------
/* ROUND END EVENT CODE */
public round_end()
	{
	FreezeTime = true
}

public game_start()
	{
	FreezeTime = true
}

//----------------------------------------------------------------------------------------------
/* CONNECTION CODE */
public client_putinserver(id)
	{
	update_menu()
}
//----------------------------------------------------------------------------------------------
/* INFO CHANGE CODE */
public client_infochanged(id)
	{
	if(ChickenName && UserFlags[id] && !is_user_bot(id))
		{
		new newname[33], oldname[33]
		get_user_info(id, "name", newname, 32)
		get_user_name(id, oldname, 32)
		
		if(!equal(oldname, newname))
			{
			set_user_info(id, "name", ChickName[id])
		}
	}
	update_menu()
}

//---------------------------------------------------------------------------------------------
/* DEATH EVENT CODE */
public death_event(id)
	{
	update_menu()
}
//----------------------------------------------------------------------------------------------
/* DISCONNECT CODE */
public client_disconnect(id)
	{
	if(UserFlags[id])
		{
		UserFlags[id] = false
	}
	if(MenuFlags[id] > 0)
		{
		MenuFlags[id] = 0
	}
	update_menu()
}
//----------------------------------------------------------------------------------------------
/* END CODE */
public plugin_end()
	{
	unchicken_user(0)
}
//----------------------------------------------------------------------------------------------
public PreThink(id)
	{
	new Float:pView[3]
	entity_get_vector(id, EV_VEC_view_ofs, pView)
	// Chicken View offset
	if(UserFlags[id] && is_user_alive(id))
		{
		if(pView[2] != cView[2])
			{
			entity_set_vector(id, EV_VEC_view_ofs, cView)
		}
	}
	// Block Crouch
	if (UserFlags[id] && is_user_alive(id))
		{
		new buttons = get_user_button(id)
		new oldbuttons = get_user_oldbutton(id)
		if(buttons&IN_DUCK && !(oldbuttons&IN_DUCK))
			client_cmd(id, "-DUCK")
	}
}
//----------------------------------------------------------------------------------------------
public emitsound(entity, channel, const sample[])
	{
	//client_print(0, 3, "Entity ID = %d Sound = %s", entity, sample)
	if(entity > 32 || entity < 1)
		return FMRES_IGNORED
	if(equal(sample, "common/wpn_denyselect.wav")) return FMRES_SUPERCEDE // Using sound is annoying ;)
	if(sample[0] == 'w' && sample[1] == 'e' && sample[8] == 'k' && sample[9] == 'n' && UserFlags[entity])
		{
		if(sample[14] == 'd')
			{
			return FMRES_SUPERCEDE
		}
		switch(sample[17])
		{
			case 'w':
			{
				return FMRES_SUPERCEDE //remove wallhit
			}
		}
	}
	// Remove death sounds and replace with killChicken
	if(sample[0] == 'p' && sample[3] == 'y' && sample[5] == 'r' && UserFlags[entity])
		{
		switch(sample[7])
		{
			case 'd':
			{
				emit_sound(entity, CHAN_VOICE, "misc/killChicken.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				return FMRES_SUPERCEDE
			}
		}
	}
	return FMRES_IGNORED
}

//----------------------------------------------------------------------------------------------
public set_model(edict, const model[])
	{
	if (!is_valid_ent(edict))
		return FMRES_IGNORED
	
	new id = entity_get_edict(edict, EV_ENT_owner)
	
	if(equal(model, "models/w_stick.mdl") && UserFlags[id])
		{
		new Float:orig[3]
		entity_get_vector(id, EV_VEC_origin, orig)
		entity_set_model(edict, "models/w_easterEgg.mdl")
		entity_set_vector(edict, EV_VEC_velocity, Float:{0.0, 0.0, 0.0})
		entity_set_origin(edict, orig)
		return FMRES_SUPERCEDE
	}
	if(equal(model, "models/w_mills.mdl") && UserFlags[id])
		{
		new Float:orig[3]
		entity_get_vector(id, EV_VEC_origin, orig)
		entity_set_model(edict, "models/w_easterEgg.mdl")
		entity_set_vector(edict, EV_VEC_velocity, Float:{0.0, 0.0, 0.0})
		entity_set_origin(edict, orig)
		return FMRES_SUPERCEDE
	}
	if(equal(model, "models/w_grenade.mdl") && UserFlags[id])
		{
		new Float:orig[3]
		entity_get_vector(id, EV_VEC_origin, orig)
		entity_set_model(edict, "models/w_easterEgg.mdl")
		entity_set_vector(edict, EV_VEC_velocity, Float:{0.0, 0.0, 0.0})
		entity_set_origin(edict, orig)
		return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}

//----------------------------------------------------------------------------------------------
/* SAVE CONFIG */

savefile(filename[])
{
	if (file_exists(filename))
		delete_file(filename)
	new readdata[201]
	
	format(readdata, 200, "%s %d^n", "// Set Chicken Vision (Default Vision = 90)^nChickenVision ", ChickenVision)
	write_file(filename,readdata)  
	
	format(readdata, 200, "%s %d^n", "// Set health protection OFF or ON^n// 0: health has no theorical limit but will not be printed correctly in game^n// 1: health can't be > 255^nHealthProtect ", HealthProtect)
	write_file(filename,readdata)  
	
	format(readdata, 200, "%s %d^n", "// Set Chicken Naming OFF or ON^n// 0: Users name stays as normal^n// 1: Users name changes to Chicken #(UserID)^nChickenName ", ChickenName)
	write_file(filename,readdata)  
	
	format(readdata, 200, "%s %d^n", "// Set ability for Players to turn themselves into a Chicken by typing^n// say /chickenme & say /unchickenme^nChickenSelf ", ChickenSelf)
	write_file(filename,readdata)  
	
	format(readdata, 200, "%s %d^n", "// Set how much health from which someone can't turn into a chicken^nChickenHP ", ChickenHP)
	write_file(filename,readdata) 
	
	format(readdata, 200, "%s %d^n", "// Set Chicken Talk OFF or ON^nChickenTalk ", ChickenTalk)
	write_file(filename,readdata) 
	
	format(readdata, 200, "%s %d^n", "// Set Chicken Team Talk OFF or ON^nChickenTeamTalk ", ChickenTeamTalk)
	write_file(filename,readdata) 
	
	format(readdata, 200, "%s %d^n", "// Set Chicken Grenades OFF or ON^nChickenGrenades ", ChickenGrenades)
	write_file(filename,readdata) 
	
	format(readdata, 200, "%s %d^n", "// Set Chicken Glowing OFF or ON^nChickenGlow ", ChickenGlow)
	write_file(filename,readdata)
	
	format(readdata, 200, "%s %d^n", "// Sets Chicken Health^nChickenHealth ", ChickenHealth)
	write_file(filename,readdata)
	
	format(readdata, 200, "%s %d^n", "// Set Chicken Gravity^nChickenGravity ", ChickenGravity)
	write_file(filename,readdata)
	
	format(readdata, 200, "%s %d^n", "// Set Chicken Speed^nChickenSpeed ", ChickenSpeed)
	write_file(filename,readdata)
	
	format(readdata, 200, "%s %d", "// Following 3, set increasing values for Menu^nMenuGrv ", MenuGrv)
	write_file(filename,readdata)
	
	format(readdata, 200, "%s %d", "MenuHP ", MenuHP)
	write_file(filename,readdata)
	
	format(readdata, 200, "%s %d^n", "MenuSpd ", MenuSpd)
	write_file(filename,readdata)
	
	format(readdata, 200, "%s %d", "// Following 2, set access levels in number format^nACCESS_MENU ", ACCESS_MENU)
	write_file(filename,readdata)
	
	format(readdata, 200, "%s %d^n", "ACCESS_SETTINGS ", ACCESS_SETTINGS)
	write_file(filename,readdata)
	
	
	return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
/* LOAD/READ CONFIG CODE */
loadcfg(filename[])
{
	if(file_exists(filename))
		{
		new readdata[128], set[30], val[30], len
		for(new i = 0; i < 100 && read_file(filename, i, readdata, 127, len); ++i)
			{
			parse(readdata, set, 29, val, 29)
			
			if(equal(set, "ChickenVision"))
				{
				ChickenVision = str_to_num(val)
			}
			if(equal(set, "HealthProtect"))
				{
				if(!equal(val, "0"))
					{
					HealthProtect = true
				}
			}
			if(equal(set, "ChickenName"))
				{
				if(!equal(val, "0"))
					{
					ChickenName = true
				}
			}
			if(equal(set, "ChickenSelf"))
				{
				if(!equal(val, "0"))
					{
					ChickenSelf = true
				}
			}
			if(equal(set, "ChickenHP"))
				{
				ChickenHP = str_to_num(val)
			}
			if(equal(set, "ChickenTalk"))
				{
				if(!equal(val, "0"))
					{
					ChickenTalk = true
				}
			}
			if(equal(set, "ChickenTeamTalk"))
				{
				if(!equal(val, "0"))
					{
					ChickenTeamTalk = true
				}
			}
			if(equal(set, "ChickenGrenades"))
				{
				if(!equal(val, "0"))
					{
					ChickenGrenades = true
				}
			}
			if(equal(set, "ChickenGlow"))
				{
				if(!equal(val, "0"))
					{
					ChickenGlow = true
				}
			}
			if(equal(set, "ChickenHealth"))
				{
				if(HealthProtect)
					{
					if(str_to_num(val) > 255)
						{
						ChickenHealth = 255
					}
					else
						{
						ChickenHealth = str_to_num(val)
					}
				}
				else
					{
					ChickenHealth = str_to_num(val)
				}
			}
			if(equal(set, "ChickenGravity"))
				{
				if(str_to_num(val) > 100)
					{
					ChickenGravity = 100
				}
				else
					{
					ChickenGravity = str_to_num(val)
				}
			}
			if(equal(set, "ChickenSpeed"))
				{
				if(str_to_num(val) > 400)
					{
					ChickenSpeed = 400
				}
				else
					{
					ChickenSpeed = str_to_num(val)
				}
			}
			if(equal(set, "MenuGrv"))
				{
				MenuGrv = str_to_num(val)
			}
			if(equal(set, "MenuHP"))
				{
				MenuHP = str_to_num(val)
			}
			if(equal(set, "MenuSpd"))
				{
				MenuSpd = str_to_num(val)
			}
			if(equal(set, "ACCESS_MENU"))
				{
				ACCESS_MENU = str_to_num(val)
			}
			if(equal(set, "ACCESS_SETTINGS"))
				{
				ACCESS_SETTINGS = str_to_num(val)
			}
		}
	}
	return PLUGIN_HANDLED
}

//----------------------------------------------------------------------------------------------
/* CHICKEN CODE */
public chicken_user(id)
	{
	if(id == 0)
		{
		call_func("chicken_user")
	}
	else if(UserFlags[id] == false && is_user_alive(id))
		{
		UserFlags[id] = true
		
		if(get_pcvar_num(g_chicken_sfx))
			{
			new origin[3]
			get_user_origin(id, origin)
			transform(origin)
		}
		if(!is_user_bot(id))
			{
			new user[33]
			get_user_name(id, user, 32)
			copy(UserOldName[id], 32, user)
			format(ChickName[id], 32, "Chicken #%i", id)
			
			if(ChickenName)
				{
				set_user_info(id, "name", ChickName[id])
			}
		}
		call_glow(id)
		call_health(id)
		call_gravity(id)
		call_speed(id)
		call_vision(id)
		dod_set_model(id, "chicken")
		dod_set_body_number(id, 0)
		dod_user_kill(id)
	}
	return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
/* UNCHICKEN CODE */
public unchicken_user(id)
	{
	if(id == 0)
		{
		call_func("unchicken_user")
	}
	else if(UserFlags[id] && is_user_alive(id))
		{
		UserFlags[id] = false
		
		if(get_pcvar_num(g_chicken_sfx))
			{
			new origin[3]
			get_user_origin(id, origin)
			transform(origin)
		}
		if(ChickenName && !is_user_bot(id))
			{
			set_user_info(id, "name", UserOldName[id])
		}
		if(entity_get_float(id, EV_FL_health) > 100.0)
			{
			entity_set_float(id, EV_FL_health, 100.0)
		}
		entity_set_float(id, EV_FL_gravity, 1.0)
		entity_set_float(id, EV_FL_maxspeed, 320.0)
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 255)
		set_vision(id)
		entity_set_vector(id, EV_VEC_view_ofs, nView)
		dod_clear_model(id)
		dod_user_kill(id)
	}
	return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
/* CALL CONTROLLER FOR ID 0 (All Players) */
public call_func(func[])
	{
	new users[32], inum
	get_players(users, inum, "a")
	for(new i = 0; i < inum; ++i)
		{
		if(users[i] > 0)
			{
			set_task(0.01, func, users[i])
		}
	}
}
//----------------------------------------------------------------------------------------------
public call_glow(id)
	{
	if(id == 0)
		{
		call_func("call_glow")
	}
	else if(UserFlags[id] && is_user_alive(id) && ChickenGlow)
		{
		if (get_user_team(id) == 1){
			set_user_rendering(id, kRenderFxGlowShell,  0, 205, 0, kRenderTransAlpha, 255)
		}
		if (get_user_team(id) == 2){
			set_user_rendering(id, kRenderFxGlowShell,  250, 0, 0, kRenderTransAlpha, 255)
		}
	}
}
//----------------------------------------------------------------------------------------------
public call_health(id)
	{
	if(UserFlags[id] && is_user_alive(id))
		{
		entity_set_float(id, EV_FL_health, float(ChickenHealth))
	}
}
//----------------------------------------------------------------------------------------------
public call_gravity(id)
	{
	if(id == 0)
		{
		call_func("call_gravity")
	}
	else if(UserFlags[id] && is_user_alive(id))
		{
		entity_set_float(id, EV_FL_gravity, float(ChickenGravity)  / 100.0)
	}
}
//----------------------------------------------------------------------------------------------
public call_speed(id)
	{
	if(id == 0)
		{
		call_func("call_speed")
	}
	else if(UserFlags[id] && is_user_alive(id))
		{
		entity_set_float(id, EV_FL_maxspeed, float(ChickenSpeed))
	}
}
//----------------------------------------------------------------------------------------------
public call_vision(id)
	{
	if(id == 0)
		{
		call_func("call_vision")
	}
	else if(UserFlags[id] && is_user_alive(id))
		{
		set_vision(id)
	}
}
//----------------------------------------------------------------------------------------------
public call_name(id)
	{
	if(id == 0)
		{
		call_func("call_name")
	}
	else if(ChickenName && UserFlags[id] && !is_user_bot(id))
		{
		set_user_info(id, "name", ChickName[id])
	}
	update_menu()
}
//----------------------------------------------------------------------------------------------
/* HITZONES DATA */
public forward_traceline(Float:v1[3], Float:v2[3], noMonsters, pentToSkip)
	{
	new entity1 = pentToSkip
	new entity2 = get_tr(TR_pHit) // victim
	new hitzone = (1<<get_tr(TR_iHitgroup))
	
	if (!is_valid_ent(entity1) || !is_valid_ent(entity2))
		{
		return FMRES_IGNORED
	}
	if (entity1 != entity2 && is_user_alive(entity1) && is_user_alive(entity2))
		{
		if(UserFlags[entity2])
			{
			if(hitzone != 64 && hitzone != 128)
				{
				set_tr(TR_flFraction,1.0)		// KWo 19.11.2005
				return FMRES_SUPERCEDE
			}
		}
		return FMRES_IGNORED
	}
	return FMRES_IGNORED
}

//----------------------------------------------------------------------------------------------
/* VISION DATA */
public set_vision(id)
	{
	if(UserFlags[id])
		{
		message_begin(MSG_ONE, gmsgSetFOV, {0,0,0}, id)
		write_byte(ChickenVision)
		message_end()
		entity_set_string(id, EV_SZ_viewmodel, "")
		entity_set_string(id, EV_SZ_weaponmodel, "")
	}
	else
		{
		message_begin(MSG_ONE, gmsgSetFOV, {0,0,0}, id)
		write_byte(90) // default_fov = 90
		message_end()
	}
}
//----------------------------------------------------------------------------------------------
/* CHICKEN SFX */
public transform(vec[3])
	{
	message_begin(MSG_PVS, SVC_TEMPENTITY, vec)
	write_byte(11) // TE_TELEPORT
	write_coord(vec[0])
	write_coord(vec[1])
	write_coord(vec[2])
	message_end()
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
