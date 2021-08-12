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
//  USAGE:
//  =====
//
//  cvars:
//  ------
//
//  dod_afkmanager_afkkick <1/0>         =  enable/disable AFK Manager (kicker)
//
//  dod_afkmanager_afkkicktime <time>    =  sets time in seconds a player can be AFK
//                                          before he's kicked off the server.
//
//  dod_afkmanager_speckick <1/0>        =  enable/disable SpectatorKicker
//
//  dod_afkmanager_speckicktime <time>   =  sets time in seconds a player can be a
//                                          spectator before he's kicked off the server
//
//  dod_afkmanager_minplayers <amount>   =  minimum number of players that have to be on the
//                                          server to get rid of afks and spectators
//
//
//  DESCRIPTION:
//  ============
//
//  This is a real simple, but powerful AFK/Spectator Kicker!
//  It's absolutely independent from the players position on
//  the map as the counter until he's kicked starts to run down
//  as soon as he joins the server and is only reset and starts
//  from the beginning in the following cases:
//   - player damages/kills another player
//   - player gets score for taking a flag
//   - player types in global-/teamchat
//   - player throws a grenade
//   - player changes team / switches class
//  The SpectatorKicker is completely independent from the AFKKicker,
//  as the action of the AFKKicker stops as soon as a player joins
//  Spectators and the SpecktatorKicker takes over. Same applies
//  vice versa, so you can safely only use one (or both for sure) parts
//  of the plugin.
//
//  * admins with a reserved slot who are afk aren't kicked
//  * spectating admins aren't kicked
//  * fakeclients, bots, hltvs aren't kicked either
//
//
//
// Requires AMX Mod X 1.76 & DoDx module!
//
//
//
// CHANGELOG:
// ==========
//
// - 13.07.2005 Version 0.5beta
//   Initial Release
//
// - 17.07.2005 Version 0.6beta
//   bugfixes:
//   - fixed errors that resulted from missing
//     checks whether the player was already connected
//     or still connecting.
//
// - 12.08.2005 Version 0.7beta
//   tweaks:
//   - added afktimer reset for shooting, switching weapons
//     and bringing up the scope (snipers)
//   bugfix:
//   - resetting afktimer for capping flags is working now
//
// - 26.06.2007 Version 0.8
//   - removed unneeded code
//   - removed unreliable afk-timer reset-functions
//   - added reset for throwing grenades
//   - added reset for changing class
//   - updated "team change function" to use dod_client_changeteam
//     forward
//   - changed to pcvar system
//   - optimized the code
//
// - 27.06.2007 Version 0.85
//   - replaced only catching Global-/TeamChat of a player
//     with catching all of his commands.
//   - commands like "sprone, weapon_* , say, say_team" are cought
//     now
//
// - 02.07.2007 Version 0.9
//   - added global tracking cvar
//
// - 20.07.2007 Version 1.0
//   - replaced "client_death" with hooking the
//     "DeathMsg"-Event for better reliability
//   - added "German" language definitions to the
//     language file
//

#include <amxmodx>
#include <dodx>

#define SPECS 3

new g_dod_afkmanager_afkkick, g_dod_afkmanager_afkkicktime, g_dod_afkmanager_speckick, g_dod_afkmanager_speckicktime, g_dod_afkmanager_minplayers

public plugin_init()
{
	register_plugin("DoD AFK Manager","1.0","AMXX DoD Team")
	register_cvar("dod_afkmanager_plugin", "Version 1.0 by FeuerSturm | www.dodplugins.net", FCVAR_SERVER|FCVAR_SPONLY)
	register_statsfwd(XMF_SCORE)
	register_statsfwd(XMF_DAMAGE)
	register_event("DeathMsg","player_killed", "a")
	g_dod_afkmanager_afkkick = register_cvar("dod_afkmanager_afkkick","1")
	g_dod_afkmanager_afkkicktime = register_cvar("dod_afkmanager_afkkicktime","180")
	g_dod_afkmanager_speckick = register_cvar("dod_afkmanager_speckick","1")
	g_dod_afkmanager_speckicktime = register_cvar("dod_afkmanager_speckicktime","300")
	g_dod_afkmanager_minplayers = register_cvar("dod_afkmanager_minplayers","6")
	register_dictionary("dod_afkmanager.txt")
}

public reset_afk(id)
{
	if(task_exists(id))
	{
		remove_task(id)
	}
	if(get_pcvar_num(g_dod_afkmanager_afkkick) == 1 && !is_user_bot(id) && !is_user_hltv(id) && (!(get_user_flags(id) & ADMIN_RESERVATION)) && is_user_connected(id))
	{
		new Float:afkkicktime = get_pcvar_float(g_dod_afkmanager_afkkicktime)
		set_task(afkkicktime,"kick_afker",id)
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public client_putinserver(id)
{
	reset_afk(id)
	return PLUGIN_CONTINUE
}

public client_disconnect(id)
{
	if(task_exists(id))
	{
		remove_task(id)
	}
	return PLUGIN_CONTINUE
}

public client_damage(attacker,victim,damage,wpnindex,hitplace,TA)
{
	new id = attacker
	reset_afk(id)
	return PLUGIN_CONTINUE
}

public player_killed()
{
	new id = read_data(1)
	reset_afk(id)
	return PLUGIN_CONTINUE
}	

public client_score(index,score,total)
{
	new id = index
	reset_afk(id)
	return PLUGIN_CONTINUE
}

public grenade_throw(index,greindex,wId)
{
	new id = index
	reset_afk(id)
	return PLUGIN_CONTINUE
}

public dod_client_changeclass(id,class,oldclass)
{
	reset_afk(id)
	return PLUGIN_CONTINUE
}

public dod_client_changeteam(id,team,oldteam)
{
	if(team == SPECS)
	{
		if(task_exists(id))
		{
			remove_task(id)
		}
		if(get_pcvar_num(g_dod_afkmanager_speckick) == 1 && !is_user_bot(id) && !is_user_hltv(id) && (!(get_user_flags(id)&ADMIN_RESERVATION)))
		{
			new Float:speckicktime = get_pcvar_float(g_dod_afkmanager_speckicktime)
			set_task(speckicktime,"kick_spec",id)
			return PLUGIN_CONTINUE
		}
		return PLUGIN_CONTINUE
	}
	else if(team == AXIS || team == ALLIES)
	{
		reset_afk(id)
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public client_command(id)
{
	new command[32]
	read_argv(0,command,31)
	if (equal(command,"jointeam") || contain(command,"cls_") != -1)
	{
		return PLUGIN_CONTINUE
	}
	reset_afk(id)
	return PLUGIN_CONTINUE
}

public kick_afker(id)
{
	new afkminpl = get_pcvar_num(g_dod_afkmanager_minplayers)
	if((get_playersnum(1)) >= afkminpl)
	{
		new afkname[32]
		get_user_name(id,afkname,31)
		new afkuserid = get_user_userid(id)
		client_print(0,print_chat,"[DoD AFK Manager] %L",LANG_PLAYER,"KICKAFK",afkname)
		server_cmd("kick #%d %L",afkuserid,afkuserid,"KICKAFKREASON")
		return PLUGIN_HANDLED
	}
	else if((get_playersnum(1)) < afkminpl)
	{
		new Float:afkkicktime = get_pcvar_float(g_dod_afkmanager_afkkicktime)
		set_task(afkkicktime,"kick_afker",id)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public kick_spec(id)
{
	new afkminpl = get_pcvar_num(g_dod_afkmanager_minplayers)
	if((get_playersnum(1)) >= afkminpl)
	{
		new specname[32]
		get_user_name(id,specname,31)
		new specuserid = get_user_userid(id)
		client_print(0,print_chat,"[DoD AFK Manager] %L",LANG_PLAYER,"KICKSPEC",specname)
		server_cmd("kick #%d %L",specuserid,specuserid,"KICKSPECREASON")
		return PLUGIN_HANDLED
	}
	else if((get_playersnum(1)) < afkminpl)
	{
		new Float:speckicktime = get_pcvar_float(g_dod_afkmanager_speckicktime)
		set_task(speckicktime,"kick_spec",id)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1031\\ f0\\ fs16 \n\\ par }
*/
