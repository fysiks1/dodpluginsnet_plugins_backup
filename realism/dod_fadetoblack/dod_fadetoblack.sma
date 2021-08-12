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
// cvars (for amxx.cfg):
// ---------------------
//
// dod_fadetoblack_enabled <1/0>	=  enable/disable Fade-to-Black mode
//
// dod_fadetoblack_obeyimmunity <1/0>	=  enable/disable fading-immunity
//					   for admins
//
//
// console commands:
// -----------------
//
// amx_fadetoblack <1/0>		=  enable/disable Fade-to-Black mode
//
//
//
//
//
// DESCRIPTION:
// ============
//
// Very simple little plugin which brings Fade-to-Black back
// to the public servers as it's only available in ClanMatch
// mode normally.
// Dead player's screen will (like the name already says)
// fade to black and he cannot see from where he was shot.
// a little bit of realism for your public server ;-)
//
//
//
// CHANGELOG:
// ==========
//
// - 16.03.2005 Version 0.5beta
//   Initial Release
//
// - 17.03.2005 Version 0.6beta
//   * added admin command "amx_dodftb" to
//     enable/disable the plugin
//
// - 17.03.2005 Version 0.7beta
//   * added cvar to exclude admins from
//     fading to black after dieing
//
// - 12.08.2005 Version 0.8beta
//   * fixed scoped snipers not being faded
//
// - 02.07.2007 Version 0.9
//   - using pcvar system now
//   - changed cvar "dod_fadetoblack" to "dod_fadetoblack_enabled"
//   - changed console command "amx_dodftb" to "amx_dodfadetoblack"
//   - added global tracking cvar
//

#include <amxmodx>
#include <amxmisc>
#include <dodx>

new g_dod_fadetoblack_enabled, g_dod_fadetoblack_obeyimmunity

public plugin_init()
{
	register_plugin("DoD FadeToBlack","0.9","AMXX DoD Team")
	register_cvar("dod_fadetoblack_plugin", "Version 0.9 by FeuerSturm | www.dodplugins.net", FCVAR_SERVER|FCVAR_SPONLY)
	register_statsfwd(XMF_DEATH)
	g_dod_fadetoblack_enabled = register_cvar("dod_fadetoblack_enabled","1")
	g_dod_fadetoblack_obeyimmunity = register_cvar("dod_fadetoblack_obeyimmunity","0")
	register_concmd("amx_fadetoblack","cmdsetftb",ADMIN_CVAR,"<1/0> = enable/disable DoD FadeToBlack")
}	

public client_death(killer,victim,wpnindex,hitplace,TK)
{	
	if(get_pcvar_num(g_dod_fadetoblack_enabled) == 1)
	{
		if((get_user_flags(victim)&ADMIN_IMMUNITY) && get_pcvar_num(g_dod_fadetoblack_obeyimmunity) == 1)
		{
			return PLUGIN_CONTINUE
		}
		set_task(0.1,"fade_to_black",victim)
	}
	return PLUGIN_CONTINUE
}

public fade_to_black(victim)
{
	new FadeToBlack = get_user_msgid("ScreenFade")
	message_begin(MSG_ONE,FadeToBlack,{0,0,0},victim)
	write_short(12000)
	write_short(9000)
	write_short(0x0008)
	write_byte(0)
	write_byte(0)
	write_byte(0)
	write_byte(255)
	message_end()
}

public cmdsetftb(id,level,cid)
{
	if (!cmd_access(id,level,cid,2))
	{
		return PLUGIN_HANDLED
	}
	new ftb_s[2]
	read_argv(1,ftb_s,2)
	new ftb = str_to_num(ftb_s)
	if(ftb == 1)
	{
		if(get_pcvar_num(g_dod_fadetoblack_enabled) == 1)
		{
			client_print(id,print_chat,"[AMXX] DoD FadeToBlack is already enabled.....")
		}
		else if (get_pcvar_num(g_dod_fadetoblack_enabled) == 0)
		{
			set_pcvar_num(g_dod_fadetoblack_enabled,1)
			client_print(id,print_chat,"[AMXX] DoD FadeToBlack ENABLED.....")
		}
		return PLUGIN_HANDLED
	}
	else if(ftb == 0)
	{
		if(get_pcvar_num(g_dod_fadetoblack_enabled) == 0)
		{
			client_print(id,print_chat,"[AMXX] DoD FadeToBlack is already disabled.....")
		}
		else if(get_pcvar_num(g_dod_fadetoblack_enabled) == 1)
		{
			set_pcvar_num(g_dod_fadetoblack_enabled,0)
			client_print(id,print_chat,"[AMXX] DoD FadeToBlack DISABLED.....")
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1031\\ f0\\ fs16 \n\\ par }
*/
