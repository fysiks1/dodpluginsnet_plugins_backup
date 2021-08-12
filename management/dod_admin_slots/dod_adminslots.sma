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
// USAGE: (cvars for amxx.cfg)
// ===========================
//
// dod_adminslots_mode <1/2/3/0>         =  set mode for slot reservation
//                                          0 = disabled
//                                          1 = kick freshest player
//                                          2 = kick player with lowest score
//                                          3 = slots are static and always
//                                              available for admins only
//
// dod_adminslots_slotcount <#>          =  number of slots to reserve
//                                          (mode 1 & 2: only 1 slot needed!)
//
// dod_adminslots_redirectip <ip>        =  ip of server for redirection
//
// dod_adminslots_redirectport <port>    =  port of server for redirection
//
// dod_adminslots_redirectpw <password>  =  password of server for redirection
//                                          (set to "none" if no pw is needed!)
//
// dod_adminslots_redirectnew <1/0>      =  sets handling of people that connect
//                                          1 = redirect when the server is full
//                                          0 = just disconnect when full
//
// dod_adminslots_redirectingame <1/0>   =  sets handling of connected non-admins
//                                          when an admin connects to the server
//                                          (only mode 1 & 2)
//                                          1 = redirect the chosen non-admin
//                                          0 = just disconnect chosen non-admin
//
// dod_adminslots_hidereserved <1/0>     =  hide/show reserved slot(s)
//
//
//
//
//  DESCRIPTION:
//  ============
//
//  Slot Reservation with redirection.
//
//  Features:
//  - enable/disable reservation
//  - redirect/kick new players when they try
//    to join a full server (non admins)
//  - redirect/kick either
//    * the freshest player in game
//    OR
//    * the player with the lowest FlagScore
//    when and admin connects to the full server
//  - slots can be static, so they will only be
//    available for admins and can only fill up with
//    admins.
//  - ability to redirect to password protected servers
//  - hide/show the reserved slot(s)
//
//  Notes:
//  - "DoD AdminSlots" replaces the standard "adminslots" that come
//    with AMX Mod X by default, so be sure to disable it!
//
//
//
// CHANGELOG:
// ==========
//
// - 09.09.2005 Version 0.4beta
//   * Initial Release
//
// - 10.09.2005 Version 0.5beta
//   * added "mode 3" to the plugin which allows
//     you to have static slots that can be filled
//     with admins, so players don't have to be kicked
//     if an admin joins.
//
// - 31.03.2006 Version 0.6beta
//   * modded to use new pointer system of cvars
//   * changed the disconnect; connect to just a connect
//
// - 02.07.2007 Version 0.7
//   - fixed Multilanguage bug causing displaying
//     "An Admin needed this Slot! xyz did blahblah"
//     instead of
//     "ADMIN xyz did blahblah"
//     Please download the new dictionary file as well!
//   - added global tracking cvar
//

#include <amxmodx>
#include <dodx>

new g_dod_adminslots_mode, g_dod_adminslots_slotcount, g_dod_adminslots_redirectnew, g_dod_adminslots_redirectingame
new g_dod_adminslots_hidereserved, g_dod_adminslots_redirectport

public plugin_init()
{
	register_plugin("DoD AdminSlots","0.7","AMXX DoD Team")
	register_cvar("dod_adminslots_plugin", "Version 0.7 by FeuerSturm | www.dodplugins.net", FCVAR_SERVER|FCVAR_SPONLY)
	g_dod_adminslots_mode = register_cvar("dod_adminslots_mode","1")
	g_dod_adminslots_slotcount = register_cvar("dod_adminslots_slotcount","1")
	g_dod_adminslots_redirectnew = register_cvar("dod_adminslots_redirectnew","0")
	g_dod_adminslots_redirectingame = register_cvar("dod_adminslots_redirectingame","0")
	g_dod_adminslots_hidereserved = register_cvar("dod_adminslots_hidereserved","0")
	g_dod_adminslots_redirectport = register_cvar("dod_adminslots_redirectport","27015")	
	register_cvar("dod_adminslots_redirectip","127.0.0.1")
	register_cvar("dod_adminslots_redirectpw","none")
	register_dictionary("dod_adminslots.txt")
}

public plugin_cfg()
{
	set_task(5.0,"set_maxplayers")
}

public set_maxplayers()
{
	new maxpl = get_maxplayers()
	if(get_pcvar_num(g_dod_adminslots_hidereserved) == 0)
	{
		set_cvar_num("sv_visiblemaxplayers",maxpl)
		return PLUGIN_HANDLED
	}
	else if(get_pcvar_num(g_dod_adminslots_hidereserved) == 1)
	{
		new resslots = get_cvar_num("dod_adminslots_slotcount")
		set_cvar_num("sv_visiblemaxplayers",(maxpl - resslots))
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public client_authorized(id)
{
	new asmode = get_pcvar_num(g_dod_adminslots_mode)
	if(asmode == 0)
	{
		return PLUGIN_CONTINUE
	}
	new maxpl = get_maxplayers()
	new resslots = get_pcvar_num(g_dod_adminslots_slotcount)
	new redirectport = get_pcvar_num(g_dod_adminslots_redirectport)
	new redirectip[50]
	get_cvar_string("dod_adminslots_redirectip",redirectip,49)
	new redirectpw[32]
	get_cvar_string("dod_adminslots_redirectpw",redirectpw,31)
	if(asmode > 0 && asmode <= 2)
	{
		if((get_playersnum(1)) > (maxpl - resslots))
		{
			if(get_user_flags(id)&ADMIN_RESERVATION)
			{			
				new removepl = check_time()
				if(asmode == 1)
				{
					removepl = check_time()
				}
				else if(asmode == 2)
				{
					removepl = check_score()
				}
				if(removepl != 0)
				{
					new player[32]
					new admin[32]
					get_user_name(id,admin,31)
					get_user_name(removepl,player,31)
					new playerindex = get_user_index(player)
					new playerid = get_user_userid(removepl)
					if(get_pcvar_num(g_dod_adminslots_redirectingame) == 1)
					{
						client_print(0,print_chat,"[DoD AdminSlots] %L",LANG_PLAYER,"REDIRECTTOFREESLOT",player,redirectip,redirectport,admin)
						log_amx("[DoD AdminSlots] %L",LANG_SERVER,"REDIRECTTOFREESLOT",player,redirectip,redirectport,admin)
						if(equali(redirectpw,"none") == 0)
						{
							client_cmd(playerindex,"setinfo password %s",redirectpw)
						}
						client_cmd(playerindex,"connect %s:%d",redirectip,redirectport)
						return PLUGIN_CONTINUE
					}
					else if(get_pcvar_num(g_dod_adminslots_redirectingame) == 0)
					{
						client_print(0,print_chat,"[DoD AdminSlots] %L",LANG_PLAYER,"KICKTOFREESLOT",player,admin)
						log_amx("[DoD AdminSlots] %L",LANG_PLAYER,"KICKTOFREESLOT",player,admin)
						server_cmd("kick #%d %L",playerid,playerid,"ADMINNEEDSLOT")
						return PLUGIN_CONTINUE
					}					
				}
			} 
			else
			{
				if(get_pcvar_num(g_dod_adminslots_redirectnew) == 1)
				{
					if(equali(redirectpw,"none") == 0)
					{
						client_cmd(id,"setinfo password %s",redirectpw)
					}
					client_cmd(id,"connect %s:%d",redirectip,redirectport)
					return PLUGIN_CONTINUE
				}
				else if(get_pcvar_num(g_dod_adminslots_redirectnew) == 0)
				{
					new playerid = get_user_userid(id)
					server_cmd("kick #%d %L",playerid,playerid,"DROPPED_RES")
					return PLUGIN_CONTINUE
				}
			}
			return PLUGIN_CONTINUE
		}
		return PLUGIN_CONTINUE
	}
	if(asmode == 3)
	{
		if((get_playersnum(1)) > (maxpl - (resslots - check_adminnum())))
		{
			if(!(get_user_flags(id)&ADMIN_RESERVATION))
			{
				if(get_pcvar_num(g_dod_adminslots_redirectnew) == 1)
				{
					if((!(equali(redirectpw,"none"))))
					{
						client_cmd(id,"setinfo password %s",redirectpw)
					}
					client_cmd(id,"connect %s:%d",redirectip,redirectport)
					return PLUGIN_CONTINUE
				}
				else if(get_pcvar_num(g_dod_adminslots_redirectnew) == 0)
				{
					new playerid = get_user_userid(id)
					server_cmd("kick #%d %L",playerid,playerid,"DROPPED_RES")
					return PLUGIN_CONTINUE
				}
			}
			return PLUGIN_CONTINUE
		}
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

check_score()
{
	new maxslots = get_maxplayers()
	new kickme = 0, flagscore, unlimited = 0x7fffffff
	for(new i = 1; i <= maxslots; ++i)
	{
		if(is_user_connected(i) == 0) continue
		if(get_user_flags(i)&ADMIN_RESERVATION) continue
		flagscore = dod_get_user_score(i)
		if(unlimited > flagscore)
		{
			unlimited = flagscore
			kickme = i
		}
	}
	return kickme
}

check_time()
{
	new maxslots = get_maxplayers()
	new kickme = 0, playtime, unlimited = 0x7fffffff
	for(new i = 1; i <= maxslots; ++i)
	{
		if(is_user_connected(i) == 0 && is_user_connecting(i) == 0) continue
		if(get_user_flags(i) & ADMIN_RESERVATION) continue
		playtime = get_user_time(i)
		if(unlimited > playtime)
		{
			unlimited = playtime
			kickme = i
		}
	}
	return kickme
}

check_adminnum()
{
	new maxpl = get_maxplayers()
	new admins = 0
	for(new i=1; i<=maxpl; i++)
	{
		if((is_user_connected(i) == 1 || is_user_connecting(i) == 1) && (get_user_flags(i) & ADMIN_RESERVATION))
		{
			admins++
		}
	}
	return admins
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1031\\ f0\\ fs16 \n\\ par }
*/
