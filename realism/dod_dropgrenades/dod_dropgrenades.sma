//
// AMX Mod X Script
//
// Developed by The AMX Mod X DoD Community
// http://www.dodplugins.net
//
// Author: FeuerSturm
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
// 
// USAGE:
// ======
//
// CVARS:
//
// dod_dropgrenades_enabled <1/0>    =  enable/disable DoD DropGrenades
//                                      1 = enabled
//                                      0 = disabled
//
// dod_dropgrenades_removeold <1/0>  =  enable/disable removing player's
//                                      previously dropped grenade(s) before
//                                      dropping new ones
//                                      1 = enabled
//                                      0 = all grenades stay until roundend
//
// dod_dropgrenades_ignorebots <1/0> =  enable/disable ignoring bots
//                                      1 = ignore bots (bots don't drop or pickup grenades)
//                                      0 = don't ignore bots (bots drop and pickup grenades)
//
//
// ADMIN COMMAND:
//
// amx_dropgrenades <1/0>  =  enable/disable DoD DropGrenades
//                            1 = enable
//                            0 = disable and remove all dropped grenades
//
//
//
// DESCRIPTION:
// ============
//
//  - players drop exactly the grenades they have left on
//    death and alive players can pickup those
//    (example: Axis player dies and drops a stickgrenade
//           -> Allied player picked it up while still having a handgrenade
//           -> Allies player dies and drops 1x Stick- and 1x Handgrenade
//           -> A player that has no grenades picks up both and will drop
//              both on death as well)
// - grenades will be removed once a round is finished
// - additionally each player's previously dropped grenade(s) can be removed
//   before dropping new ones.
//
//
//
// AMX Mod X, DoDx & FakeMeta modules needed!
//
//
// CHANGELOG:
// ==========
//
// - 26.07.2005 Version 0.5beta
//   Initial Public Release
//
// - 21.08.2005 Version 0.5beta2
//   workaround:
//   - added a fix for strange behavior on AMXX 1.50beta
//
// - 27.08.2005 Version 0.6beta
//   changes:
//   - removed workaround for AMXX 1.50beta as the bug is
//     fixed in AMXX 1.55 which everyone should rather use
//     than 1.50beta!
//
// - 12.01.2007 Version 0.6
//   changes:
//   - made it so that whatever side you are it will pickup your type of nades
//     this is to make it compatiable with zors smoke nades plugin
//   - added cvar to change amount of grenades allowed to have
//
// - 30.06.2007 Version 0.7
//   - discarded changes from v0.6
//   - changed Engine- to Fakemeta-Module for better performance
//   - removed need for DoDFun module
//   - changed to using pcvars
//   - added full Linux compatibility with removing dod_get_user_ammo
//     and counting players' grendades depending on their class after spawning
//   - using grenade_throw forward to decrease amount of dropable grenades
//     when a player throws a grenade.
//   - players now drop exactly the grenades they have left on
//     death and alive players can pickup those
//     (example: Axis player dies and drops a stickgrenade
//               -> Allied player picked it up while still having a handgrenade
//               -> Allies player dies and drops 1x Stick- and 1x Handgrenade
//               -> A player that has no grenades picks up both and will drop
//                  both on death as well)
//   - removed all effects and ability to use an AmmoBox-Model instead of the
//     grenade models for dropped grenades for more realism
//   - added cvar dod_dropgrenades_ignorebots with that bots can be prevented
//     from dropping and picking up grenades
//
// - 30.06.2007 Version 0.75
//   - added ability to adjust the amount of grenades a player has by default
//     NOTE: if you are not using any plugins that mess with the
//           amount of grenades per player, keep the default value!
//   - added ability to adjust the amount of grenades a player can pickup
//     from the ground
//     NOTE: if you are not using any plugins that mess with the
//           amount of grenades per player, keep the default value!
//   - added ability to adjust the amount of grenades that will be dropped
//     when a player dies
//     NOTE: if you are not using any plugins that mess with the
//           amount of grenades per player, keep the default value!
//
// - 02.07.2007 Version 0.8
//   - added roundstate "Draw" to clean up of dropped grenades
//   - added global tracking cvar
//
//
// PLEASE NOTE: This Plugin is considered a realism Plugin, if you
//              wish to have a fun plugin please use "DoD DropGrenades 2" modded
//              by "Wilson [29th ID]" --> http://dodplugins.net/forums/showthread.php?t=739
//

/////// DON'T EDIT ///////
#include <amxmodx>	//
#include <amxmisc>	//
#include <fakemeta>	//
#include <dodx>		//
#include <fun>		//
/////// DON'T EDIT ///////



// PLEASE ONLY CHANGE THE FOLLOWING NUMBERS THAT DECLARE THE
// NUMBER OF GRENADES EACH GROUP OF CLASSES HAVE IF YOU ARE
// USING A PLUGIN THAT CHANGES THE STANDARD AMOUNT OF GRENADES!

#define DOD_RIFLE_CLASSES	2	// GARAND, CARBINE, ENFIELD, K98, K43
#define DOD_MP_CLASSES		1	// THOMPSON, BAR, GREASEGUN, BREN, STEN, MP40, STG44, FG42, SCOPED FG42
#define DOD_SNIPER_CLASSES	0	// SPRINGFIELD, SCOPED ENFIELD, SCOPED K98
#define DOD_MG_CLASSES		0	// 30CAL, MG34, MG42
#define DOD_ROCKET_CLASSES	0	// BAZOOKA, PIAT, PANZERSCHRECK


// THE FOLLOWING IS THE MAX AMOUNT OF GRENADES A PLAYER CAN
// PICKUP! ADJUST THIS VALUE CAREFULLY!

#define DOD_GRENADES_PICKUP	2


// THE FOLLOWING IS THE MAX AMOUNT OF GRENADES THAT WILL BE DROPPED
// WHEN A PLAYER DIES THAT HAD MORE THAN THE DOD STANDARD LIMIT!
// TO PREVENT GRENADE-SPAMMING DEFAULT VALUE IS HIGHLY RECOMMENDED!

#define DOD_DROPGRENADES_MAX	2


//////////////////////////////////////////////////////////////////
//								//
// PLEASE DO NOT EDIT ANYTHING FROM HERE ON UNLESS YOU REALLY	//
// KNOW WHAT YOU ARE DOING!					//
//								//
//////////////////////////////////////////////////////////////////



new g_dod_dropgrenades_enabled, g_dod_dropgrenades_removeold, g_dod_dropgrenades_ignorebots
new g_pl_axisnades[33], g_pl_alliesnades[33]

new handgrenade_mdl[] = "models/w_grenade.mdl"
new stickgrenade_mdl[] = "models/w_stick.mdl"
new millsbomb_mdl[] = "models/w_mills.mdl"

public plugin_init()
{
	register_plugin("DoD DropGrenades","0.8","AMXX DoD Team")
	register_cvar("dod_dropgrenades_plugin", "Version 0.8 by FeuerSturm | www.dodplugins.net", FCVAR_SERVER|FCVAR_SPONLY)
	register_statsfwd(XMF_DEATH)
	register_event("RoundState","remove_grenades","a","1=3","1=4","1=5")
	register_event("ResetHUD","count_grenades","be")
	register_concmd("amx_dropgrenades","cmd_dropgrenades",ADMIN_CVAR,"<1/0> = enable/disable DoD DropGrenades")	
	g_dod_dropgrenades_enabled = register_cvar("dod_dropgrenades_enabled","1")
	g_dod_dropgrenades_removeold = register_cvar("dod_dropgrenades_removeold","1")
	g_dod_dropgrenades_ignorebots = register_cvar("dod_dropgrenades_ignorebots","1")
}

public plugin_precache()
{
	precache_model(handgrenade_mdl)
	precache_model(stickgrenade_mdl)
	precache_model(millsbomb_mdl)
}

public client_putinserver(id)
{
	message_begin(MSG_ONE, get_user_msgid("WeaponList"), {0,0,0}, id)
	write_byte(9)
	write_byte(DOD_GRENADES_PICKUP)
	write_byte(-1)
	write_byte(-1)
	write_byte(4)
	write_byte(1)
	write_short(DODW_HANDGRENADE)
	write_byte(24)
	write_byte(-1)
	message_end()
	
	message_begin(MSG_ONE, get_user_msgid("WeaponList"), {0,0,0}, id)
	write_byte(11)
	write_byte(DOD_GRENADES_PICKUP)
	write_byte(-1)
	write_byte(-1)
	write_byte(4)
	write_byte(1)
	write_short(DODW_STICKGRENADE)
	write_byte(24)
	write_byte(-1)
	message_end()
	
	message_begin(MSG_ONE, get_user_msgid("WeaponList"), {0,0,0}, id)
	write_byte(9)
	write_byte(DOD_GRENADES_PICKUP)
	write_byte(-1)
	write_byte(-1)
	write_byte(4)
	write_byte(1)
	write_short(DODW_MILLS_BOMB)
	write_byte(24)
	write_byte(-1)
	message_end()
}

public client_death(killer, victim, wpnindex, hitplace, TK)
{
	if((get_pcvar_num(g_dod_dropgrenades_ignorebots) == 1 && is_user_bot(victim)) || get_pcvar_num(g_dod_dropgrenades_enabled) == 0)
	{
		return PLUGIN_CONTINUE
	}
	new param[1]
	param[0] = victim
	if(get_pcvar_num(g_dod_dropgrenades_removeold) == 1)
	{
		remove_playernades(param[0])
	}
	if ((g_pl_alliesnades[param[0]] + g_pl_axisnades[param[0]]) > DOD_DROPGRENADES_MAX)
	{
		if (get_user_team(param[0]) == AXIS)
		{
			g_pl_axisnades[param[0]] = DOD_DROPGRENADES_MAX
			g_pl_alliesnades[param[0]] = 0
		}
		else if (get_user_team(param[0]) == ALLIES)
		{
			g_pl_alliesnades[param[0]] = DOD_DROPGRENADES_MAX
			g_pl_axisnades[param[0]] = 0
		}
	}
	if (g_pl_alliesnades[param[0]] > 0)
	{
		if (g_pl_alliesnades[param[0]] > DOD_DROPGRENADES_MAX)
		{
			g_pl_alliesnades[param[0]] = DOD_DROPGRENADES_MAX
		}
		if (dod_get_map_info(MI_ALLIES_TEAM) == 0)
		{
			set_task(0.0,"create_handgrenade", 0, param, 1, "a", g_pl_alliesnades[param[0]])
		}
		else if (dod_get_map_info(MI_ALLIES_TEAM) == 1)
		{
			set_task(0.0,"create_millsbomb", 0, param, 1, "a", g_pl_alliesnades[param[0]])
		}
	}
	if (g_pl_axisnades[param[0]] > 0)
	{
		set_task(0.0, "create_stickgrenade", 0, param, 1, "a", g_pl_axisnades[param[0]])
	}
	return PLUGIN_CONTINUE
}

public grenade_throw(index,greindex,wId)
{
	if((get_pcvar_num(g_dod_dropgrenades_ignorebots) == 1 && is_user_bot(index)) || get_pcvar_num(g_dod_dropgrenades_enabled) == 0)
	{
		return PLUGIN_CONTINUE
	}
	if (wId == DODW_STICKGRENADE_EX || wId == DODW_HANDGRENADE_EX)
	{
		return PLUGIN_CONTINUE
	}
	else if(wId == DODW_HANDGRENADE || wId == DODW_MILLS_BOMB)
	{
		g_pl_alliesnades[index]--
	}
	else if(wId == DODW_STICKGRENADE)
	{
		g_pl_axisnades[index]--
	}
	return PLUGIN_CONTINUE
}

public count_grenades(id)
{
	if((get_pcvar_num(g_dod_dropgrenades_ignorebots) == 1 && is_user_bot(id)) || get_pcvar_num(g_dod_dropgrenades_enabled) == 0)
	{
		return PLUGIN_CONTINUE
	}
	set_task(0.1,"set_currentnades",id)
	return PLUGIN_CONTINUE
}

public set_currentnades(id)
{
	g_pl_alliesnades[id] = 0
	g_pl_axisnades[id] = 0
	new classid = dod_get_user_class(id)
	if (get_user_team(id) == ALLIES)
	{
		if (classid == DODC_GARAND || classid == DODC_CARBINE || classid == DODC_ENFIELD)
		{
			g_pl_alliesnades[id] = DOD_RIFLE_CLASSES
			return PLUGIN_CONTINUE
		}
		else if (classid == DODC_SNIPER || classid == DODC_MARKSMAN)
		{
			g_pl_alliesnades[id] = DOD_SNIPER_CLASSES
			return PLUGIN_CONTINUE
		}
		else if (classid == DODC_30CAL)
		{
			g_pl_alliesnades[id] = DOD_MG_CLASSES
			return PLUGIN_CONTINUE
		}
		else if (classid == DODC_BAZOOKA || classid == DODC_PIAT)
		{
			g_pl_alliesnades[id] = DOD_ROCKET_CLASSES
			return PLUGIN_CONTINUE
		}
		else
		{
			g_pl_alliesnades[id] = DOD_MP_CLASSES
			return PLUGIN_CONTINUE
		}
		return PLUGIN_CONTINUE
	}
	else if (get_user_team(id) == AXIS)
	{
		if (classid == DODC_KAR || classid == DODC_K43)
		{
			g_pl_axisnades[id] = DOD_RIFLE_CLASSES
			return PLUGIN_CONTINUE
		}
		else if (classid == DODC_SCHARFSCHUTZE)
		{
			g_pl_axisnades[id] = DOD_SNIPER_CLASSES
			return PLUGIN_CONTINUE
		}
		else if (classid == DODC_MG34 || classid == DODC_MG42)
		{
			g_pl_axisnades[id] = DOD_MG_CLASSES
			return PLUGIN_CONTINUE
		}
		else if (classid == DODC_PANZERJAGER)
		{
			g_pl_axisnades[id] = DOD_ROCKET_CLASSES
			return PLUGIN_CONTINUE
		}
		else
		{
			g_pl_axisnades[id] = DOD_MP_CLASSES
			return PLUGIN_CONTINUE
		}
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public cmd_dropgrenades(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
	{
		return PLUGIN_HANDLED
	}	
	new dropgrenades_s[2]
	read_argv(1,dropgrenades_s,2)
	new dropgrenades = str_to_num(dropgrenades_s)
	if(dropgrenades == 1)
	{
		if(get_pcvar_num(g_dod_dropgrenades_enabled) == 1)
		{
			console_print(id,"[AMXX] DoD DropGrenades is already enabled.....")
			client_print(id,print_chat,"[AMXX] DoD DropGrenades is already enabled.....")
		}
		else if(get_pcvar_num(g_dod_dropgrenades_enabled) == 0)
		{
			set_pcvar_num(g_dod_dropgrenades_enabled,1)
			console_print(id,"[AMXX] DoD DropGrenades ENABLED!")
			client_print(id,print_chat,"[AMXX] DoD DropGrenades ENABLED!")
		}
		return PLUGIN_HANDLED
	}
	else if(dropgrenades == 0)
	{
		if(get_pcvar_num(g_dod_dropgrenades_enabled) == 0)
		{
			console_print(id,"[AMXX] DoD DropGrenades is already disabled.....")
			client_print(id,print_chat,"[AMXX] DoD DropGrenades is already disabled.....")
		}	
		else if(get_pcvar_num(g_dod_dropgrenades_enabled) == 1)
		{
			remove_grenades()
			set_pcvar_num(g_dod_dropgrenades_enabled,0)
			console_print(id,"[AMXX] DoD DropGrenades DISABLED!")
			client_print(id,print_chat,"[AMXX] DoD DropGrenades DISABLED!")
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public create_handgrenade(param[])
{
	new handgrenade = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString,"info_target"))
	set_pev(handgrenade, pev_classname,"dropped_handgrenade")
	set_pev(handgrenade,pev_owner,param[0])
	set_pev(handgrenade,pev_solid,SOLID_TRIGGER)
	set_pev(handgrenade,pev_movetype,MOVETYPE_TOSS)
	new Float:deathorigin[3]
	pev(param[0],pev_origin,deathorigin)
	engfunc(EngFunc_SetModel,handgrenade,handgrenade_mdl)
	set_pev(handgrenade,pev_origin,deathorigin)
	return PLUGIN_HANDLED
}

public create_stickgrenade(param[])
{
	new stickgrenade = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString,"info_target"))
	set_pev(stickgrenade, pev_classname,"dropped_stickgrenade")
	set_pev(stickgrenade,pev_owner,param[0])
	set_pev(stickgrenade,pev_solid,SOLID_TRIGGER)
	set_pev(stickgrenade,pev_movetype,MOVETYPE_TOSS)
	new Float:deathorigin[3]
	pev(param[0],pev_origin,deathorigin)
	engfunc(EngFunc_SetModel,stickgrenade,stickgrenade_mdl)
	set_pev(stickgrenade,pev_origin,deathorigin)
	return PLUGIN_HANDLED
}

public create_millsbomb(param[])
{
	new millsbomb = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString,"info_target"))
	set_pev(millsbomb, pev_classname,"dropped_millsbomb")
	set_pev(millsbomb,pev_owner,param[0])
	set_pev(millsbomb,pev_solid,SOLID_TRIGGER)
	set_pev(millsbomb,pev_movetype,MOVETYPE_TOSS)
	new Float:deathorigin[3]
	pev(param[0],pev_origin,deathorigin)
	engfunc(EngFunc_SetModel,millsbomb,millsbomb_mdl)
	set_pev(millsbomb,pev_origin,deathorigin)
	return PLUGIN_HANDLED
}

public pfn_touch(grenade,player)
{
	if(get_pcvar_num(g_dod_dropgrenades_enabled) == 0 || !pev_valid(grenade) || !pev_valid(player) || !is_user_connected(player) || !is_user_alive(player))
	{
		return PLUGIN_CONTINUE
	}
	if(get_pcvar_num(g_dod_dropgrenades_ignorebots) == 1 && is_user_bot(player))
	{
		return PLUGIN_CONTINUE
	}
	new Nademodel[32];
	pev(grenade,pev_classname,Nademodel,31 )
	if(equal(Nademodel,"dropped_handgrenade") || equal(Nademodel,"dropped_stickgrenade") || equal(Nademodel,"dropped_millsbomb"))
	{
		if ((g_pl_alliesnades[player] + g_pl_axisnades[player]) < DOD_GRENADES_PICKUP)
		{
			if(equal(Nademodel,"dropped_stickgrenade"))
			{
				give_item(player,"weapon_stickgrenade")
				g_pl_axisnades[player]++
				engfunc(EngFunc_RemoveEntity,grenade)
			}
			else if(equal(Nademodel,"dropped_handgrenade") || equal(Nademodel,"dropped_millsbomb"))
			{
				give_item(player,"weapon_handgrenade")
				g_pl_alliesnades[player]++
				engfunc(EngFunc_RemoveEntity,grenade)
			}
		}
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public remove_grenades()
{
	if(get_pcvar_num(g_dod_dropgrenades_enabled) == 0)
	{
		return PLUGIN_CONTINUE
	}	
	if(dod_get_map_info(MI_ALLIES_TEAM) == 0)
	{
		new handgrenade = -1
		while((handgrenade = engfunc(EngFunc_FindEntityByString, handgrenade,"classname","dropped_handgrenade")) > 0)
		{
			engfunc(EngFunc_RemoveEntity,handgrenade)
		}	
	}
	else if(dod_get_map_info(MI_ALLIES_TEAM) == 1)
	{
		new millsbomb = -1	
		while((millsbomb = engfunc(EngFunc_FindEntityByString, millsbomb,"classname","dropped_millsbomb")) > 0)
		{
			engfunc(EngFunc_RemoveEntity,millsbomb)
		}
	}
	new stickgrenade = -1
	while((stickgrenade = engfunc(EngFunc_FindEntityByString, stickgrenade,"classname","dropped_stickgrenade")) > 0)
	{
		engfunc(EngFunc_RemoveEntity,stickgrenade)
	}
	return PLUGIN_CONTINUE
}

public remove_playernades(param[])
{
	if(dod_get_map_info(MI_ALLIES_TEAM) == 0)
	{
		new handgrenade
		handgrenade = -1	
		while((handgrenade = engfunc(EngFunc_FindEntityByString, handgrenade,"classname","dropped_handgrenade")) > 0)
		{
			if(pev(handgrenade,pev_owner) == param[0])
			{
				engfunc(EngFunc_RemoveEntity,handgrenade)
			}
		}
	}
	else if(dod_get_map_info(MI_ALLIES_TEAM) == 1)
	{
		new millsbomb
		millsbomb = -1
		while((millsbomb = engfunc(EngFunc_FindEntityByString, millsbomb,"classname","dropped_millsbomb")) > 0)
		{
			if(pev(millsbomb,pev_owner) == param[0])
			{
				engfunc(EngFunc_RemoveEntity,millsbomb)
			}
		}
	}
	new stickgrenade = -1	
	while((stickgrenade = engfunc(EngFunc_FindEntityByString, stickgrenade,"classname","dropped_stickgrenade")) > 0)
	{
		if(pev(stickgrenade,pev_owner) == param[0])
		{
			engfunc(EngFunc_RemoveEntity,stickgrenade)
		}
	}
	return PLUGIN_HANDLED
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1031\\ f0\\ fs16 \n\\ par }
*/
