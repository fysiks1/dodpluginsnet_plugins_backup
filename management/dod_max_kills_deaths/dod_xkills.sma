///////////////////////////////////////////////////////////////////////////////////////
//
//	AMX Mod (X)
//
//	Developed by:
//	The Amxmodx DoD Community
//	|BW|.Zor Editor (zor@blackwatchclan.net)
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
//	Name:		DoD Reset at 255
//	Author:		DOD Amxmodx Community
//	Description:	This plugin will reset users scores at 255 so that the server
//			doesn't crash
//
//	CVARS:
//		dod_maxkds 255	// The total kills or deaths needed before reset
//
//	Reference:
//
//	v0.1 	- Originaly done by FireStorm
//	v0.2	- Changed to dod_maxkds
//	v0.3	- Fixed error with checking victims kills, made it look at victims deaths
//		- Added code to reset score instead of kicking
//	v0.4	- Added check to make sure victim and killer are connected before checking
//		their stats
//		
//		v0.3 and v0.4 is fixed thanks to diamond-optic, Cheers!
//
///////////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <dodx>
#include <dodfun>

///////////////////////////////////////////////////////////////////////////////////////
// Version Control
//
new AUTH[] = "AMXX DoD Plugins"
new PLUGIN_NAME[] = "DoD Reset at 255"
new VERSION[] = "0.4"
//
///////////////////////////////////////////////////////////////////////////////////////
public plugin_init()
{
	// Register this plugin
	register_plugin(PLUGIN_NAME, VERSION, AUTH)
	
	register_statsfwd(XMF_DEATH)
	register_cvar("dod_maxkds", "255")
}

public client_death(killer, victim, wpnindex, hitplace, TK)
{
	if(is_user_hltv(killer) || is_user_hltv(victim))
		return PLUGIN_CONTINUE
		
	if(!is_user_connected(killer) || !is_user_connected(victim))
		return PLUGIN_CONTINUE
		
	new name[32]
	
	if(dod_get_user_kills(killer) >= get_cvar_num("dod_maxkds") || dod_get_pl_deaths(killer) >= get_cvar_num("dod_maxkds"))
	{
		dod_set_user_kills(killer, 0, 1)
		dod_set_pl_deaths(killer, 0, 1)
		dod_set_user_score(killer, 0, 1)
		
		get_user_name(killer, name, 31)
		client_print(killer, print_center, "%s, Your score has been reset to prevent the server from crashing", name)
	}

	if(dod_get_user_kills(victim) >= get_cvar_num("dod_maxkds") || dod_get_pl_deaths(victim) >= get_cvar_num("dod_maxkds"))
	{
		dod_set_user_kills(victim, 0, 1)
		dod_set_pl_deaths(victim, 0, 1)
		dod_set_user_score(victim, 0, 1)

		get_user_name(victim, name, 31)
		client_print(victim, print_center, "%s, Your score has been reset to prevent the server from crashing", name)
	}

	return PLUGIN_HANDLED
}