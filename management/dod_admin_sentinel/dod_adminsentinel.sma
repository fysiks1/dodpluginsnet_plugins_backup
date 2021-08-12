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
//
// CVARs (for amxx.cfg):
// ---------------------
//
// dod_adminsentinel_mode <1/2/3/0>     = set server's mode
//                                        1 Voice- & TeamChat
//                                        2 TeamChat Only
//                                        3 VoiceChat Only
//                                        0 All disabled
//
// dod_adminsentinel_autoenabled <1/0>  = enable/disable automatically
//                                        setting admins to see/hear
//                                        enemy's communication after
//                                        joining the server.
//
//
// ADMIN COMMANDS:
// ---------------
//
// amx_enemychat                        = enable/disable seeing
//                                        enemy's teamchat
//
// amx_enemyvoice                       = enable/disable hearing
//                                        enemy's voicecomm
//
//
//
// DESCRIPTION:
// ============
//
// This plugin let's admins see enemy's teamchat and
// hear enemy's voicecomm.
// parts can seperatly be enabled/disabled by defeault
// and parts that are enabled by default can be disabled
// and reenabled by every single admin for himself.
// this way you can turn off hearing the enemy's voice
// communication if it annoys you, without stopping
// other admins from hearing it. same with the enemy teamchat.
// admins that join the server will automatically get the abilities
// which are set as server default (if that feature is enabled!).
// BUT: admins can't enable features that aren't allowed
//      by the server's mode.
//
//
//
//
// CHANGELOG:
// ==========
//
// - 05.12.2004 Version 0.5beta
//   Initial Release
//
// - 28.01.2005 Version 0.6beta
//   * added cvar to enable/disable
//     automatically setting admins to
//     see/hear enemy's communication
//     after joining the server.
//   * renamed main cvar
//
// - 27.03.2005 Version 0.7beta
//   * bugfix:
//     - enemy teamchat isn't displayed
//       several times anymore.
//       ("4 lines of the same sentence"-bug)
//
// - 12.07.2005 Version 0.8beta
//   * added displaying dead/spectator chat
//     to admins with ADMIN_BAN access.
//
// - 04.08.2005 Version 0.9beta
//   * fixed bug of multi chat lines caused by
//     missing check if chatter and admin are
//     both dead and at the same team.
//     (in this case, the game displayed the message
//      and the plugin as well)
//
// - 21.08.2005 Version 0.9beta2
//   * fixed bug of multi chat lines caused by
//     missing check if chatter and admin are
//     both dead and at different teams and message
//     was public and not team only.
//     (in this case, the game displayed the message
//      and the plugin as well)
//
// - 02.07.2007 Version 1.0
//   - using pcvar system now
//   - added global tracking cvar
//

#include <amxmodx>
#include <amxmisc>
#include <engine>

new g_dod_adminsentinel_mode, g_dod_adminsentinel_autoenabled

new g_NoEnemyVoice[33], g_NoEnemyChat[33]

public plugin_init()
{
	register_plugin("DoD AdminSentinel","1.0","AMXX DoD Team")
	register_cvar("dod_adminsentinel_plugin", "Version 1.0 by FeuerSturm | www.dodplugins.net", FCVAR_SERVER|FCVAR_SPONLY)
	g_dod_adminsentinel_mode = register_cvar("dod_adminsentinel_mode","1")
	g_dod_adminsentinel_autoenabled = register_cvar("dod_adminsentinel_autoenabled","1")
	register_concmd("amx_enemyvoice","admin_enemyvoice",ADMIN_BAN,"enable/disable hearing enemy voicecomm")
	register_concmd("amx_enemychat","admin_enemychat",ADMIN_BAN,"enable/disable seeing enemy teamchat")
	register_event("SayText","get_sayteaminfo","bc","2&(TEAM)")
	register_event("SayText","get_saydeadinfo","bc","2&(DEAD)")
}

public get_sayteaminfo()
{
	new SentinelMode = get_pcvar_num(g_dod_adminsentinel_mode)
	if(SentinelMode == 1 || SentinelMode == 2)
	{
		new chatter = read_data(1)
		if(is_user_alive(chatter) == 0)
		{
			return PLUGIN_CONTINUE
		}
		new teammessage[151]
		read_data(2,teammessage,150)
		new chatterteam = get_user_team(chatter)
		new plist_admin[32],pnum_admin
		get_players(plist_admin, pnum_admin)
		for(new i=0; i<pnum_admin; i++)
		{
			new pl_admin = plist_admin[i]
			if(is_user_connected(pl_admin) == 1 && g_NoEnemyChat[pl_admin] == 0 && (get_user_flags(pl_admin)&ADMIN_BAN))
			{
				new adminteam = get_user_team(pl_admin)
				if(chatterteam != adminteam){
					message_begin(MSG_ONE,get_user_msgid("SayText"),{0,0,0},pl_admin)
					write_byte(chatter)
					write_string(teammessage)
					message_end()
				}
			}
		}
	}
	return PLUGIN_CONTINUE
}

public get_saydeadinfo()
{
	new SentinelMode = get_pcvar_num(g_dod_adminsentinel_mode)
	if(SentinelMode == 1 || SentinelMode == 2)
	{
		new deadchatter = read_data(1)
		new deadmessage[151]
		read_data(2,deadmessage,150)
		new deadteam = get_user_team(deadchatter)
		new plist_admin[32],pnum_admin
		get_players(plist_admin, pnum_admin)
		for(new i=0; i<pnum_admin; i++){
			new pl_admin = plist_admin[i]
			if(is_user_connected(pl_admin) == 1 && g_NoEnemyChat[pl_admin] == 0 && (get_user_flags(pl_admin)&ADMIN_BAN))
			{
				if(is_user_alive(pl_admin) == 0 && get_user_team(pl_admin) == deadteam)
				{
					// do nothing, admin will see it without the plugin
				}
				else if(is_user_alive(pl_admin) == 0 && get_user_team(pl_admin) != deadteam && contain(deadmessage,"(TEAM)") == -1){
					// do nothing, admin will see it without the plugin
				}
				else
				{
					message_begin(MSG_ONE,get_user_msgid("SayText"),{0,0,0},pl_admin)
					write_byte(deadchatter)
					write_string(deadmessage)
					message_end()
				}
			}
		}
	}
}

public client_putinserver(id)
{
	if(is_user_connected(id) == 1)
	{
		new SentinelMode = get_pcvar_num(g_dod_adminsentinel_mode)
		if((SentinelMode == 1 || SentinelMode == 3) && get_pcvar_num(g_dod_adminsentinel_autoenabled) == 1 && (get_user_flags(id)&ADMIN_BAN))
		{
			set_speak(id,SPEAK_LISTENALL)
			g_NoEnemyVoice[id] = 0
			g_NoEnemyChat[id] = 0
			return PLUGIN_CONTINUE
		}
		else
		{
			set_speak(id,SPEAK_NORMAL)
			g_NoEnemyVoice[id] = 1
			g_NoEnemyChat[id] = 1
			return PLUGIN_CONTINUE
		}
	}
	return PLUGIN_CONTINUE
}

public admin_enemyvoice(id,level,cid)
{
	if (!cmd_access(id,level,cid,1))
	{
		return PLUGIN_HANDLED
	}
	new SentinelMode = get_pcvar_num(g_dod_adminsentinel_mode)
	if((SentinelMode == 1 || SentinelMode == 3) && g_NoEnemyVoice[id] == 0 && get_speak(id) == SPEAK_LISTENALL)
	{
		g_NoEnemyVoice[id] = 1
		set_speak(id,SPEAK_NORMAL)
		client_print(id,print_chat,"[DoD AdminSentinel] You can't hear the enemy's VoiceComm anymore!")
		return PLUGIN_HANDLED
	}
	else if((SentinelMode == 1 || SentinelMode == 3) && g_NoEnemyVoice[id] == 1 && get_speak(id) == SPEAK_NORMAL)
	{
		g_NoEnemyVoice[id] = 0
		set_speak(id,SPEAK_LISTENALL)
		client_print(id,print_chat,"[DoD AdminSentinel] You can hear the enemy's VoiceComm again!")
		return PLUGIN_HANDLED
	}
	else if((SentinelMode == 0 || SentinelMode == 2))
	{
		client_print(id,print_chat,"[DoD AdminSentinel] VoiceComm features are disabled!")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public admin_enemychat(id,level,cid)
{
	if (!cmd_access(id,level,cid,1))
	{
		return PLUGIN_HANDLED
	}
	new SentinelMode = get_pcvar_num(g_dod_adminsentinel_mode)
	if((SentinelMode == 1 || SentinelMode == 2) && g_NoEnemyChat[id] == 0)
	{
		g_NoEnemyChat[id] = 1
		client_print(id,print_chat,"[DoD AdminSentinel] You can't see the enemy's TeamChat anymore!")
		return PLUGIN_HANDLED
	}
	else if((SentinelMode == 1 || SentinelMode == 2) && g_NoEnemyChat[id] == 1)
	{
		g_NoEnemyChat[id] = 0
		client_print(id,print_chat,"[DoD AdminSentinel] You can see the enemy's TeamChat again!")
		return PLUGIN_HANDLED
	}
	else if(SentinelMode == 0 || SentinelMode == 3)
	{
		client_print(id,print_chat,"[DoD AdminSentinel] TeamChat features are disabled!")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1031\\ f0\\ fs16 \n\\ par }
*/
