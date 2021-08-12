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
//  (all cvars for your amxx.cfg)
//  -----------------------------
//
//  dod_hpk_enabled <1/0>            = enabled/disable DoD HPK by default
//
//  dod_hpk_kickping <ping>          = kick players with a ping that
//                                     exceeds this value
//
//  dod_hpk_pingchecks <checks>      = how often a player should be checked
//                                     positive for high ping before kick
//
//  dod_hpk_checkdelay <delay>       = how many seconds should be waited
//                                     between the checks
//
//  dod_hpk_stopchecking <checks>    = how often a player should be checked
//                                     negative in a row for high ping
//                                     before disabling ping checks on him.
//                                     (set to 0 to disable this feature)
//
//
//  Sample Config (those are the min values!):
//  ------------------------------------------
//
//  dod_hpk_enabled 1
//  dod_hpk_kickping 50
//  dod_hpk_pingchecks 5
//  dod_hpk_checkdelay 12
//  dod_hpk_stopchecking 10
//
//
//
// DESCRIPTION:
// ============
//
// This Plugin is for Day of Defeat!
//
// Simple, but working HighPingKicker for DoD.
// Checking starts as soon as a player joins a team,
// so you don't get your screen spammed with kick messages
// of players that aren't in game yet. (DoD specific problem!)
// All can be set up by using cvars.
// Admins with a reserved slot aren't checked at all.
//
//
// TO DO:
// ======
//
// - nothing so far :P
//
//
// CHANGELOG:
// ==========
//
// - 24.10.2004 Version 0.9beta
//   Initial Release
//
// - 26.10.2004 Version 0.95beta
//   i forgot to remove the task to check
//   the ping on a player when he leaves
//   the server, should be fixed now
//
// - 07.11.2004 Version 0.96beta
//   added feature:
//   you can define how often a player
//   has to have a lower ping in a row
//   before DoD HPK stops to check him.
//   if there is a high ping between the
//   low ping checks, the LowPing counter
//   is reset.
//   that way cpu usage can be saved for
//   players with a constant low ping.
//
// - 21.11.2004 Version 0.99beta
//   fixed oversight that name of kicked
//   highpinger wasn't displayed and added
//   message to kicked highpinger.
//
// - 01.05.2004 Version 0.99beta2
//   * optimized the code
//   * removed hudmessages
//   * added max allowed ping to
//     public kick-message
//
// - 02.04.2006 Version 1.0
//   added multilingual ability
//      Thanks to cadav0r
//
// - 09.02.2006 Version 1.1
//   fixed mistake in lang file (diamond-optic)
//
// - 02.07.2007 Version 1.2
//   - using pcvar system now
//   - renamed cvars from "dodhpk_*" to "dod_hpk_*"
//   - renamed dictionary file to "dod_hpk.txt"
//   - added global tracking cvar
//

#include <amxmodx>

#define ADMIN_FLAG ADMIN_RESERVATION

new g_dod_hpk_enabled, g_dod_hpk_kickping, g_dod_hpk_pingchecks, g_dod_hpk_checkdelay, g_dod_hpk_stopchecking
new Checking[33], HighPing[33], LowPing[33], kick_ping

public plugin_init()
{
	register_plugin("DoD HighPingKicker","1.2","AMXX DoD Team")
	register_cvar("dod_hpk_plugin", "Version 1.2 by FeuerSturm | www.dodplugins.net", FCVAR_SERVER|FCVAR_SPONLY)
	g_dod_hpk_enabled = register_cvar("dod_hpk_enabled","1")
	g_dod_hpk_kickping = register_cvar("dod_hpk_kickping","200")
	g_dod_hpk_pingchecks = register_cvar("dod_hpk_pingchecks","6")
	g_dod_hpk_checkdelay = register_cvar("dod_hpk_checkdelay","15")
	g_dod_hpk_stopchecking = register_cvar("dod_hpk_stopchecking","15")
	register_dictionary("dod_hpk.txt")
}	

public client_disconnect(id)
{
	if(get_pcvar_num(g_dod_hpk_enabled) == 1 && Checking[id] == 1)
	{
		remove_task(id)
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public client_authorized(id)
{
	Checking[id] = 0
	HighPing[id] = 0
	LowPing[id] = 0
}

public client_putinserver(id)
{
	if(get_pcvar_num(g_dod_hpk_enabled) == 1 && Checking[id] == 0 && is_user_connected(id) == 1 && (!(get_user_flags(id) & ADMIN_FLAG)))
	{
		set_task(15.0,"announce_hpk",id)
		Checking[id] = 1
		new Float:check_delay = get_pcvar_float(g_dod_hpk_checkdelay)
		set_task(check_delay,"analyze_ping",id,"",0,"b")
	}
	return PLUGIN_CONTINUE
}

public announce_hpk(id)
{
	kick_ping = get_pcvar_num(g_dod_hpk_kickping)
	client_print(id, print_chat, "[DoD HPK] %L", id, "ANNOUNCE", kick_ping)
}

public analyze_ping(id)
{
	new ping, loss
	get_user_ping(id,ping,loss)
	if(ping > kick_ping){
		HighPing[id] += 1
		LowPing[id] = 0
		check_highpings(id)
	}
	else if(ping < kick_ping){
		LowPing[id] += 1
		check_lowpings(id)
	}
	return PLUGIN_CONTINUE
}

public check_highpings(id)
{
	new ping_checks = get_pcvar_num(g_dod_hpk_pingchecks)
	if(HighPing[id] == ping_checks){
		client_print(id, print_chat, "[DoD HPK] %L", id, "PING_TOO_HIGH")
		remove_task(id)
		set_task(5.0,"kick_highpinger",id)
	}
	return PLUGIN_CONTINUE
}

public check_lowpings(id)
{
	new ping_low = get_pcvar_num(g_dod_hpk_stopchecking)
	if(ping_low == 0){
		return PLUGIN_CONTINUE
	}
	else if(ping_low == LowPing[id]){
		client_print(id, print_chat, "[DoD HPK] %L", id, "CONSTANT_LOW_PING")
		remove_task(id)
	}
	return PLUGIN_CONTINUE
}

public kick_highpinger(id)
{
	new hp_name[32]
	kick_ping = get_pcvar_num(g_dod_hpk_kickping)
	get_user_name(id,hp_name,31)
	client_print(0, print_chat, "[DoD HPK] %L", LANG_PLAYER, "KICKED", hp_name, kick_ping)
	new hp_userid = get_user_userid(id)
	server_cmd("kick #%d %L", hp_userid, id, "KICK")
	return PLUGIN_HANDLED
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
