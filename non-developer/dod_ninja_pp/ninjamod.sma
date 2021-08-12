/*
AMX Mod (X)

	Developed by:
	The Amxmodx DoD Community
	Hell Phoenix (Hell_Phoenix@frenchys-pit.com)
	http://www.dodplugins.net

	This program is free software; you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation; either version 2 of the License, or (at
	your option) any later version.

	This program is distributed in the hope that it will be useful, but
	WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
	General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software Foundation,
	Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

	In addition, as a special exception, the author gives permission to
	link the code of this program with the Half-Life Game Engine ("HL
	Engine") and Modified Game Libraries ("MODs") developed by Valve,
	L.L.C ("Valve"). You must obey the GNU General Public License in all
	respects for all of the code used other than the HL Engine and MODs
	from Valve. If you modify this file, you may extend this exception
	to your version of the file, but you are not obligated to do so. If
	you do not wish to do so, delete this exception statement from your
	version.


	Description:	This plugin allows admins to turn players into ninjas.  Players then
			have low grav, no footsteps, unlimited stamina, and a LOT more health
			until they die.


This is a rerelease of Hell Pheonix's DoD Ninja Plugin

The ADMIN Commands for this Plugin are:

ninja_mode:	0 Turns off all ninja's and everyone respawns
		1 Turns Everyone into ninja's with a whole server respawn
		2 Starts Randomly Chosen Ninjas mode, new ninjas are chosen at a defined interval
		3 This is a mode soon to come, This will Surely be enjoyed by all
		  [HINT] similar to zombie mod
		4 If I get enough people who want this i will have a new mode that we play sometimes
		  on one of the servers i play

amx_ninja	Type in all or part of a users name to assign them ninja
		Only enabled if ninja_mode is 0

		
CLIENT Commands

		
CVARS

"ninja_health", "600"
"ninja_visibility", "50"
"mintime", "35.0"
"maxtime", "85.0"
		
Soon To come:
-allow players to ninja themselves
-Top Secret Mode 3
-minor changes to make this more user friendly
-get rid of the warnings
-maybe a menu in the future

CREDITS
--Hell Pheonix 		for the Original Plugin
---People Hell Pheonix Credits
---Thanks to Rabid Baboon for the cs_onehitkills plugin and Firestorm for the block suicide code.
--pRED* | NZ 		from the AMXX Forums for helping me with the random mode
--Nican 		from the AMXX Forums for helping me with the random mode
--[RST] FireStorm 	for his Close Combat PLugin which i used to come up with some of the code
--[BOW] and {KOS} 	for motivating me to do this

*/
#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>
#include <dodfun>
#include <dodx>
#include <fakemeta>

#define PLUGIN "DoD Ninja ++"
#define VERSION "1.0"
#define AUTHOR "AMXX DoD Community AND BY Rebel"

new s_mode[2]
new g_status[33]
new g_knifekill = 0
new g_newplayer[33]
new admin[32]

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_concmd("ninja_mode","admin_ninja",ADMIN_RCON,"[Ninja Modes] 0 = OFF || 1 = All || 2 = Random")
	register_concmd("amx_ninja", "cmd_ninja", ADMIN_RCON, "<authid, nick or #userid> - Turn player into a Ninja")
	register_event("ResetHUD","respawn","be")
	register_event("CurWeapon","check_weapon","b","1=1")
	register_cvar("ninja_health", "600")
	register_cvar("ninja_visibility", "50")
	register_forward(FM_AlertMessage,"blocksuicide")
	register_cvar("mode","0")
	set_cvar_num("mode", 0 )
	register_cvar("mintime", "Float:35.0")
	register_cvar("maxtime", "Float:85.0")
	new Float:randtime = random_float(get_cvar_float("mintime"),get_cvar_float("maxtime"))
	set_cvar_float("mintime", Float:35.0)
	set_cvar_float("maxtime", Float:85.0)
	set_task(randtime,"random_event",5132,"",0,"b")
}

public blocksuicide(at_type, message[])
	{
	if(containi(message,"suicide") > -1 && containi(message,"world") > -1 && g_knifekill == 1)
		{
		g_knifekill = 0
		return FMRES_SUPERCEDE
	}
	return PLUGIN_CONTINUE
} 

public client_damage(attacker, victim, damage, wpnindex, hitplace, TA){	
	if (g_status[attacker]){
		if(is_user_alive(victim))
			{
			if((attacker != victim)) //prevents killing self with knife from fall damage.
				{
				if(wpnindex == DODW_SPADE || DODW_AMERKNIFE && TA != 1)
					{
					if(damage != DMG_FALL)
						{
						new wpnid[32]; 
						get_weaponname(attacker, wpnid, 32);
						g_knifekill = 1
						if(hitplace == HIT_HEAD)
							{
							make_deathmsg(attacker, victim, 1, wpnid)
						}
						else
							{
							make_deathmsg(attacker, victim, 0, wpnid)
						}
						user_silentkill(victim)
						set_user_frags(attacker, get_user_frags(attacker)+1)
					}			
				}
			}
		}
		return PLUGIN_HANDLED
	}	
	return PLUGIN_HANDLED
}

public check_weapon(id){
	if (get_cvar_num("mode") == 1){
		new clip, ammo, wpnid = dod_get_user_weapon(id,clip,ammo) 
		if (wpnid == DODW_SPADE || wpnid == DODW_AMERKNIFE) { 
			entity_set_string(id, EV_SZ_viewmodel, "models/katana.mdl")
			entity_set_string(id, EV_SZ_weaponmodel, "models/p_katana.mdl")
		}
		return PLUGIN_CONTINUE
	}
	else if( g_status[id] == 1){
		new clip, ammo, wpnid = dod_get_user_weapon(id,clip,ammo) 
		if (wpnid == DODW_SPADE || wpnid == DODW_AMERKNIFE) { 
			entity_set_string(id, EV_SZ_viewmodel, "models/katana.mdl")
			entity_set_string(id, EV_SZ_weaponmodel, "models/p_katana.mdl")
		}
		return PLUGIN_CONTINUE
	}
	else if( g_status[id] == 0){
		set_normal(id)
	}
	return PLUGIN_CONTINUE
}

public plugin_precache() { 
	precache_model("models/katana.mdl") 
	precache_model("models/p_katana.mdl")
	return PLUGIN_CONTINUE 
} 


public client_authorized(id){
	if( get_cvar_num("mode") == 1 ){
		g_status[id] = 1
	}
	else if( get_cvar_num("mode") != 1 ){
		g_status[id] = 0
	}
}

public respawn(id){
	if (get_cvar_num("mode") == 1){
		set_task(0.1,"ninja_me",id)
	}
	else if (get_cvar_num("mode") == 2){
		set_task(0.1,"set_normal",id)
	}
	/*else if (get_cvar_num("mode") == 3){
		set_task(0.1,"top_secret",id)
	}*/
	else if (get_cvar_num("mode") == 0 ){
		set_task(0.1,"set_normal",id)
	}
	set_normal(id)
      
	return PLUGIN_HANDLED
}

public set_normal(id) {
	if (g_status[id]){
		g_status[id] = 0
		set_user_health(id,100)
		set_user_maxspeed(id,320.0)
		set_user_footsteps(id,0)
		set_user_gravity(id,1.0)
		dod_set_stamina(id,STAMINA_SET,0,100)
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 255)
		set_entity_visibility(id, 1)
	}
	return PLUGIN_HANDLED
}

public ninja_me(id){
	g_status[id] = 1
	set_user_health(id,get_cvar_num("ninja_health"))
	set_user_maxspeed(id,999.0) 
	set_user_footsteps(id,1) 
	set_user_gravity(id,0.2) 
	dod_set_stamina(id,STAMINA_SET,100,100)
	set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, get_cvar_num("ninja_visibility"))
	
	{ 
		strip_user_weapons(id) 
		if(get_user_team(id) == 2){ 
			give_item(id,"weapon_spade")
		} 
		else if(get_user_team(id) == 1){ 
			give_item(id,"weapon_spade")
		} 
		
		new name[32] 
		get_user_name(id,name,31)
		if( get_cvar_num("mode") == 1){
			return PLUGIN_HANDLED
		}
		else if(get_cvar_num("mode") != 1 && get_cvar_num("client_allow") == 0 ){
			client_print(0,print_chat,"[NINJA] %s is now a Ninja",name)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public admin_ninja(id, level, cid) {
	if (!cmd_access(id,level,cid,2)) {
		return PLUGIN_HANDLED
	}
	get_user_name ( id, admin, 31 )
	new r = random(256) 
	new g = random(256) 
	new b = random(256)
	
	read_argv(1,s_mode,31)
	set_cvar_num("mode", str_to_num(s_mode))
	if (get_cvar_num("mode") == 0){
		set_hudmessage ( r ,g ,b ,0.03, 0.62, 2, 0.02, 5.0, 0.01, 0.1, 1 )
		show_hudmessage ( 0, "Ninja Mode has been Turned off by %s", admin )
		new plist[32],pnum
		get_players(plist, pnum)
		for(new i=0; i<pnum; i++){
			g_newplayer[plist[i]] = 1
			if(is_user_alive(plist[i]) == 1){
                                        dod_user_kill(plist[i])
			}
		}
	}
	else if( get_cvar_num("mode") == 1 ){
		set_cvar_num("allow_client",0)
		set_hudmessage ( r ,g ,b ,0.03, 0.62, 2, 0.02, 5.0, 0.01, 0.1, 1 )
		show_hudmessage ( 0, "%s has made everbody Ninjas", admin )
		new plist[32],pnum
		get_players(plist, pnum)
		for(new i=0; i<pnum; i++){
			g_newplayer[plist[i]] = 1
			if(is_user_alive(plist[i]) == 1){
                                        dod_user_kill(plist[i])
			}
		}
		set_cvar_num("allow_client",0)
		return PLUGIN_HANDLED
	}
	else if( get_cvar_num("mode") == 2 ){
		set_cvar_num("allow_client",0)
		set_hudmessage ( r ,g ,b ,0.03, 0.62, 2, 0.02, 5.0, 0.01, 0.1, 1 )
		show_hudmessage ( 0, "Random Ninja Mode has been turned on by^n %s", admin )
		return PLUGIN_HANDLED
	}
	else if( get_cvar_num("mode") != 0 || get_cvar_num("mode") != 1 || get_cvar_num("mode") != 2 ){
		console_print ( id, "[Ninja Modes] 0 = Admin Chosen || 1 = All || 2 = Random")
	}
	return PLUGIN_HANDLED
}

public random_event(){
	if( get_cvar_num("mode") !=2 ){
		return PLUGIN_HANDLED;
	}
	new players[32],num
	get_players(players, num,"a" )
	new randm = random_num( 0, num-1 )
	new id = players[randm]
	if( g_status[id] == 1){
		random_event()
	}
	else if(g_status[id] == 0){
		ninja_me(id)
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public cmd_ninja(id, level, cid) {
	if (!cmd_access(id,level,cid,2)) {
		return PLUGIN_HANDLED
	}
	if( get_cvar_num("mode") == 0){
		new arg[32]
		read_argv(1,arg,31)
	
		new Player = cmd_target(id, arg, 2) 
		if (!Player || g_status[Player]) return PLUGIN_HANDLED
		g_status[Player] = 1
		new id = Player
		ninja_me(id)
	
		return PLUGIN_HANDLED
	}
	else if( get_cvar_num("mode") != 0 ){
		console_print ( id, "This is only allowed when ninja_mode is 0")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

