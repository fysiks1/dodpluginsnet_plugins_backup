///////////////////////////////////////////////////////////////////////////////////////
//
//	AMX Mod (X)
//
//	Developed by:
//	The Amxmodx DoD Community
//	Hell Phoenix (Hell_Phoenix@frenchys-pit.com)
//	http://www.dodplugins.net
//
//	This program is free software; you can redistribute it and/or modify it
//	under the terms of the GNU General Public License as published by the
//	Free Software Foundation; either version 2 of the License, or (at
//	your option) any later version.
//
//	This program is distributed in the hope that it will be useful, but
//	WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//	General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with this program; if not, write to the Free Software Foundation,
//	Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
//	In addition, as a special exception, the author gives permission to
//	link the code of this program with the Half-Life Game Engine ("HL
//	Engine") and Modified Game Libraries ("MODs") developed by Valve,
//	L.L.C ("Valve"). You must obey the GNU General Public License in all
//	respects for all of the code used other than the HL Engine and MODs
//	from Valve. If you modify this file, you may extend this exception
//	to your version of the file, but you are not obligated to do so. If
//	you do not wish to do so, delete this exception statement from your
//	version.
//
//	Name:		DoD Ninja
//	Author:		Hell Phoenix
//
//	Description:	This plugin allows admins to turn players into ninjas.  Players then
//			have low grav, no footsteps, unlimited stamina, and a LOT more health
//			until they die.
//
//	Thanks to Rabid Baboon for the cs_onehitkills plugin, Firestorm for the block suicide code,
//           and TatsuSaisei for the sword weapon model.
//
//	Plugin:		http://www.dodplugins.net/viewtopic.php?p=6763
//
//  Commands:  amx_ninja < player >
//	       /ninja in public chat (if self ninja is enabled)
//             dod_ninjamenu
//
//  Cvars:  dod_ninja_health (Amount of health the ninja gets, default is 600)
//	    dod_ninja_visibility (How invisible is the ninja, default is 100, range is 0 (completely invisible) to 256 (normal))
//          dod_ninja_self (Allow users to ninja themselves by typing /ninja into chat, 0 is off(default), 1 is on)
//          dod_ninja_random (Turn on the random Ninja mode, 1 person is selected to be a ninja, 0 is off(default), 1 is on)
//          dod_ninja_everyone (Turn on ninja madness mode, everyone is a ninja all the time, 0 is off(default), 1 is on)
//
//  NOTES:  Make sure you put the two models in your dod/models directory!
//
//
//  v1.0    - Created
//  v1.1    Added Invisibility
//  v1.2    Added Instant Kill
//  v1.3    Added Sword model so everyone sees a sword and not just you 
//	    Added ability to self-ninja by saying /ninja
//          Added random ninja mode
//          Optimized some code
//  v1.4    Added everyones a ninja mode
//          Blocked possible exploits
//          Added menu so its more "User Friendly"
//	    
//  
// 
//
///////////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>
#include <dodfun>
#include <dodx>
#include <fakemeta>

#define PLUGIN "DoD Ninja"
#define VERSION "1.4"
#define AUTHOR "AMXX DoD Community"

new g_ninja_health
new g_ninja_visibility
new g_ninja_self
new g_ninja_random
new g_ninja_everyone
new g_random
new g_status[33]
new g_knifekill = 0

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_concmd("amx_ninja", "cmd_ninja", ADMIN_SLAY, "<authid, nick or #userid> - Turn player into a Ninja")
	g_ninja_health = register_cvar("dod_ninja_health", "600")
	g_ninja_visibility = register_cvar("dod_ninja_visibility", "100")
	g_ninja_self = register_cvar("dod_ninja_self", "0")
	g_ninja_random = register_cvar("dod_ninja_random", "0")
	g_ninja_everyone = register_cvar("dod_ninja_everyone", "0")
	register_event("ResetHUD", "set_normal", "be")
	register_clcmd("fullupdate", "clcmd_fullupdate")
	register_event("CurWeapon", "check_weapon","be")
	register_clcmd("say /ninja", "cmd_ninjasay", 0, "- Ninja yourself")
	register_clcmd("dod_ninjamenu", "Ninja_Menu", ADMIN_SLAY, "- DoD Ninja Options Menu")
	register_forward(FM_AlertMessage,"blocksuicide") 
	set_task(30.0,"random_ninja",8675309,"",0,"b")
	
}

public plugin_precache() { 
	precache_model("models/Katana.mdl") 
	precache_model("models/p_katana.mdl")
	return PLUGIN_CONTINUE 
} 

public clcmd_fullupdate() {
	return PLUGIN_HANDLED_MAIN
}

public Ninja_Menu(id,level,cid) {
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	
	new NinjaMenu = menu_create("\rDoD Ninja Menu", "NinjaHandler")
	if (get_pcvar_num(g_ninja_self)==0)
		menu_additem(NinjaMenu, "Enable Ninja Self Mode", "1", 0)
	else
		menu_additem(NinjaMenu, "Disable Ninja Self Mode", "2", 0)
	if (get_pcvar_num(g_ninja_random)==0)
		menu_additem(NinjaMenu, "Enable Random Ninja Mode", "3", 0)
	else
		menu_additem(NinjaMenu, "Disable Random Ninja Mode", "4", 0)
	if (get_pcvar_num(g_ninja_everyone)==0)
		menu_additem(NinjaMenu, "Enable Everyones a Ninja Mode", "5", 0)
	else
		menu_additem(NinjaMenu, "Disable Everyones a Ninja Mode", "6", 0)
	menu_display(id, NinjaMenu, 0)
	return PLUGIN_HANDLED
}

public NinjaHandler(id, NinjaMenu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(NinjaMenu)
		return PLUGIN_HANDLED
	}
	new data[6], iName[64]
	new access, callback
	menu_item_getinfo(NinjaMenu, item, access, data,5, iName, 63, callback)
	new key = str_to_num(data)
	
	switch(key)
	{
		case 1: {
			server_cmd("dod_ninja_self 1")
			client_print(id, print_chat, "Self Ninja Mode Enabled!")
			menu_destroy(NinjaMenu)
			return PLUGIN_HANDLED
		}
		case 2: {
			server_cmd("dod_ninja_self 0")
			client_print(id, print_chat, "Self Ninja Mode Disabled!")
			menu_destroy(NinjaMenu)
			return PLUGIN_HANDLED
		}
		case 3: {
			server_cmd("dod_ninja_random 1")
			client_print(id, print_chat, "Random Ninja Mode Enabled!")
			menu_destroy(NinjaMenu)
			return PLUGIN_HANDLED
		}
		case 4:	{
			server_cmd("dod_ninja_random 0")
			client_print(id, print_chat, "Random Ninja Mode Disabled!")
			menu_destroy(NinjaMenu)
			return PLUGIN_HANDLED
		}
		case 5:{
			server_cmd("dod_ninja_everyone 1")
			client_print(id, print_chat, "Everyones a Ninja Mode Enabled!")
			new players[32],num
			get_players(players,num,"a")
			for(new i=0;i<num;i++){
				dod_user_kill(players[i])
			}
			menu_destroy(NinjaMenu)
			return PLUGIN_HANDLED	
		}
		case 6:	{
			server_cmd("dod_ninja_everyone 0")
			client_print(id, print_chat, "Everyones a Ninja Mode Disabled!")
			menu_destroy(NinjaMenu)
			return PLUGIN_HANDLED
		}			
	}
	
	menu_destroy(NinjaMenu)
	return PLUGIN_HANDLED
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

public set_normal(id) {
	if (get_pcvar_num(g_ninja_everyone)){
		g_status[id] = true
		set_task(0.1, "cmd_blade", id)
		return PLUGIN_HANDLED
		}else{
		if (g_status[id]){
			g_status[id] = false
			g_random = false
			set_user_health(id,100)
			set_user_maxspeed(id,320.0)
			set_user_footsteps(id,0)
			set_user_gravity(id,1.0)
			dod_set_stamina(id,STAMINA_SET,0,100)
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 255)
			set_entity_visibility(id, 1)
		}
	}
	return PLUGIN_HANDLED
}



public check_weapon(id){
	if (g_status[id]){
		if ( read_data(1) !=19){
			client_cmd(id,"drop")
		}
		new clip, ammo, wpnid = dod_get_user_weapon(id,clip,ammo) 
		if (wpnid == DODW_SPADE || wpnid == DODW_AMERKNIFE) { 
			entity_set_string(id, EV_SZ_viewmodel, "models/Katana.mdl") 
			entity_set_string(id, EV_SZ_weaponmodel, "models/p_katana.mdl")
		} 
	}
	return PLUGIN_CONTINUE
}

public random_ninja()
{
	if(!get_pcvar_num(g_ninja_random))
		return PLUGIN_HANDLED
	
	if (!g_random){
		new players[32],num
		get_players(players,num,"a")
		
		new rid = random_num(0, num-1)
		new id = players[rid]
		
		g_random = true
		g_status[id] = true
		
		cmd_blade(id)
	}
	
	return PLUGIN_HANDLED
}

public cmd_ninja(id, level, cid) {
	if (!cmd_access(id,level,cid,2)) {
		return PLUGIN_HANDLED
	}
	
	new arg[32]
	read_argv(1,arg,31)
	
	new Player = cmd_target(id, arg, 2) 
	if (!Player || g_status[Player]) return PLUGIN_HANDLED
	g_status[Player] = true
	
	cmd_blade(Player)
	
	return PLUGIN_HANDLED
}

public cmd_ninjasay(id) {
	
	if(is_user_bot(id)) {
		return PLUGIN_CONTINUE
	}
	
	new words[32]
	read_args(words, 31)
	if (get_pcvar_num(g_ninja_self)) {
		if(!g_status[id]){
			if(equali(words, "^"/ninja^"")) {
				if(!is_user_alive(id)) {
					client_print(id, print_chat, "Wait until you are alive!")
					return PLUGIN_HANDLED
					} else {
					g_status[id] = true
					cmd_blade(id)
					return PLUGIN_HANDLED
				}
			} 
		}
		else {
			client_print(id, print_chat, "You are already a ninja!!!")
			return PLUGIN_HANDLED
		}
	}
	else {
		client_print(id, print_chat, "Sorry, self ninja is not enabled")
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}


public cmd_blade (Player) {
	set_user_health(Player,get_pcvar_num(g_ninja_health))
	set_user_maxspeed(Player,999.0) 
	set_user_footsteps(Player,1) 
	set_user_gravity(Player,0.2) 
	dod_set_stamina(Player,STAMINA_SET,100,100)
	set_user_rendering(Player, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, get_pcvar_num(g_ninja_visibility))
	
	strip_user_weapons(Player) 
	if(get_user_team(Player) == 2){ 
		give_item(Player,"weapon_spade")
	} 
	else if(get_user_team(Player) == 1){ 
		give_item(Player,"weapon_amerknife")
	} 
	
	if (!get_pcvar_num(g_ninja_everyone)){
		new name[32] 
		get_user_name(Player,name,31) 
		client_print(0,print_chat,"[AMXX] %s is now a Ninja",name)			
	}
	
	
	return PLUGIN_HANDLED
}

