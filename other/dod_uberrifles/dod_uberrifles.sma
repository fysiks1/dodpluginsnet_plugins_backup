//
// AMX Mod X Script
//
// Developed by The AMX Mod X DoD Community
// http://www.dodplugins.net
//
// Author: -[HHB]- -=Fritz Schroeder=-
//
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
//
//
// Credits:
//
// Big thanks to Zor, SidLuke and Damaged Soul for help!
//
// Super big thanks to XxAvalanchexX for showing how to
// port the damage done by a bullet impact to another part
// of the victim's body!
//
//
// USAGE:
// ======
//
// amx_uberrifles <1/0>              =  enable/disable UberGarand Mode
//                                      (admin command)
//
// dod_uberrifles_enabled <1/0>      =  enable UberGarand Mode by default
//                                      (cvar for amxx.cfg)
//
// dod_uberrifles_announce <amount>  =  set how often a player is informed
//                                      about UberGarand. he will only be
//                                      informed after he got killed with
//                                      an UberGarand shot.
//                                      set to 0 to disable the announcement.
//                                      (cvar for amxx.cfg)
//
//
//
// DESCRIPTION:
// ============
//
// This plugin makes the Garand & the K43 a one-shot-kill weapon like
// the Karabiner98 and the Enfield.
// The Victim dies, where ever you hit him.
//
//
// AMX Mod X 1.0, DoDx & FakeMeta modules needed!
//
//
// To do:
//
// - nothing anymore :D
//
//
// CHANGELOG:
// ==========
//
// - 29.09.2004 Version 0.6alpha
//   Initial Alpha
//
// - 29.09.2004 Version 0.9alpha
//   * blocked "suicide" message
//   * added propper death message
//
// - 30.09.2004 Version 0.95alpha
//   * fixed oversight that even TKs
//     added a kill to the player's score
//
// - 16.10.2004 Version 0.96alpha
//   * added logmessage of ubergarand kill
//
// - 17.10.2004 Version 0.99beta
//   * blocked logging of suicides on ubergarand kills
//     so this plugin is fully stats prove now :D
//
// - 25.10.2004 Version 0.99beta2
//   * after a player got killed with an "UberGarand" shot.
//     he will get a red hud-message telling him that
//     UberGarand is enabled and every shot is deadly.
//     you can specify the amout of times each player is
//     informed about that with the cvar "ubergarand_maxannounce".
//     idea of announcing the plugin by Zor.
//
// - 05.02.2005 Version 0.99beta3
//   * changed the way this plugin works:
//     the damage is changed now, so it definately
//     is handled like a normal kill, no need to
//     block and replace the log-/deathmessages
//     anymore.
//     Hopefully this will fix the strange
//     "overhead icons disappear"-bug.
//   * Engine & DoDFun modules are not required
//     anymore.
//   * big thanks to XxAvalanchexX for showing how
//     to port the damage of the bullet impact to
//     another part of the body!
//
// - 09.02.2005 Version 0.99beta4
//   * feature upgrade:
//     if a victim has 90 or less health left,
//     the plugin won't do anything, so you
//     don't have your stats full of
//     "chest hits".
//     so basically the plugin is off for
//     hits that go to the chest, to the head and
//     for players that already have less than 90hp.
//   * to mention this again:
//     the cvar names have changed since beta2, so
//     please review them!
//


#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <dodx>

new uberriflekill[33]
new ur_announced[33]

public plugin_init() {
   register_plugin("DoD UberRifles","0.8beta","AMXX DoD Team")
   register_forward(FM_TraceLine,"check_uberrifles",1)
   register_statsfwd(XMF_DEATH)
   register_cvar("dod_uberrifles_enabled","0")
   register_cvar("dod_uberrifles_announce","3")
   register_concmd("amx_uberrifles_enabled","admin_setubergarand",ADMIN_BAN,"<enable/disable UberRifle Mode>")
}

public plugin_modules(){
   require_module("dodx")
   require_module("fakemeta")
}

public client_authorized(id){
   ur_announced[id] = 0
}

public check_uberrifles(Float:v1[3],Float:v2[3],noMonsters,id){
	if(get_cvar_num("dod_uberrifles_enabled") == 0){
		return PLUGIN_HANDLED
	}
	if(is_user_connected(id) == 0 || is_user_alive(id) == 0){
		return PLUGIN_HANDLED
	}
	new victim = get_tr(TR_pHit)
	if(is_user_connected(victim) == 0 || is_user_alive(victim) == 0){
		return PLUGIN_HANDLED
	}
	new ammo, clip, zGun = dod_get_user_weapon(id,clip,ammo)
	if(zGun != DODW_GARAND && zGun != DODW_K43){
		return PLUGIN_HANDLED
	}
	new victimhealth = get_user_health(get_tr(TR_pHit))
	if(victimhealth <= 90){
		return PLUGIN_HANDLED
	}
	new hitplace = get_tr(TR_iHitgroup)
	if(hitplace != HIT_HEAD && hitplace != HIT_CHEST){
		set_tr(TR_iHitgroup,HIT_CHEST)
		uberriflekill[get_tr(TR_pHit)] = 1
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED	
}

public client_death(killer,victim,wpnindex,hitplace,TK){
	if((wpnindex == DODW_GARAND || wpnindex == DODW_K43) && uberriflekill[victim] == 1){
		uberriflekill[victim] = 0
		announce_ur(victim)
	}
}

public announce_ur(victim){
        new zMaxAnnounces = get_cvar_num("dod_uberrifles_announce")
        if(ur_announced[victim] < zMaxAnnounces){
                set_hudmessage(255, 0, 0, 0.03, 0.35, 1, 6.0, 5.0, 0.1, 0.2, 4)
                show_hudmessage(victim,"DoD UberRifles is enabled!^n^nThe Garand/K43 is a powerful^none-shot kill weapon!")
                ur_announced[victim]++
                }
}

public admin_setubergarand(id,level,cid){
	if (!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED
	new urm_s[2]
	read_argv(1,urm_s,2)
	new urm = str_to_num(urm_s)

	if(urm == 1) {
	           if (get_cvar_num("dod_uberrifles_enabled") == 1){
	                 client_print(id,print_chat,"[AMXX] UberRifle Mode is already running.....")
	                 }
	           else if (get_cvar_num("dod_uberrifles_enabled") == 0){
	                set_cvar_num("dod_uberrifles_enabled",1)
	                client_print(id,print_chat,"[AMXX] UberRifle Mode ACTIVATED.....")
	                }
	           }

	else if(urm == 0) {
	           if (get_cvar_num("dod_uberrifles_enabled") == 0){
	                 client_print(id,print_chat,"[AMXX] UberRifle Mode is already disabled.....")
	                 }
	           else if (get_cvar_num("dod_uberrifles_enabled") == 1){
	                set_cvar_num("dod_uberrifles_enabled",0)
	                client_print(id,print_chat,"[AMXX] UberRifle Mode DEACTIVATED.....")
                        }
	}
	return PLUGIN_HANDLED
}