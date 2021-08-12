///////////////////////////////////////////////////////////////////////////////////////
//
//	AMX Mod (X)
//
//	Developed by:
//	The Amxmodx DoD Community
//	|BW|.Zor Editor (zor@blackwatch.recongamer.com)
//	http://www.dodcommunity.net
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
//	Name:		Aim Bot Detector
//	Author:		|BW|.Zor
//	Description:	This Plugin will help to detect aimboters
//
//	v0.1 	- Be!
//	
///////////////////////////////////////////////////////////////////////////////////////
#include <amxmodx>
#include <fun>
#include <amxmisc>

//////////////////////////////////////////////
// Version Control
//
new AUTH[] = "Amxmodx DoD Communtiy"
new PLUGIN_NAME[] = "Aim Bot Detector"
new VERSION[] = "0.1d"
new ACCESS = ADMIN_LEVEL_A
//
//////////////////////////////////////////////

//////////////////////////////////////////////
// Globals
//
new bool:cloaked[32] = false
//
//////////////////////////////////////////////

//////////////////////////////////////////////
// Initializations of the Plugin
public plugin_init()
{
	// Register this plugin
	register_plugin(PLUGIN_NAME, VERSION, AUTH)

	register_concmd("amx_cloak", "cloak", ACCESS, "Detects Aim Bot'ers.")
	register_concmd("amx_uncloak", "cloak", ACCESS, "Stops Detection of Aim Bot'ers.")
}

//////////////////////////////////////////////
// Called prior to user disconnect
public client_disconnect(id)
{
	cloaked[id] = false
}

//////////////////////////////////////////////
// Will cloak or uncloak a person
public cloak(id, level, cid)
{
	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED

	new cmd[32]
	read_argv(0, cmd, 31)

	client_print(id, print_console, "Starting Cloaking!")

	// Cloak the caller
	if(equal(cmd, "amx_cloak"))
	{
		cloaked[id] = true
		if(is_user_alive(id))
		{
			set_user_footsteps(id, 1)
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0)
		}

		client_print(id, print_console, "You are being Cloaked!")
	}

	// Un-Cloak the caller
	else
	{
		cloaked[id] = false
		if(is_user_alive(id))
		{
			set_user_footsteps(id, 0)
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 255)
		}

		client_print(id, print_console, "You are being Un-Cloaked!")
	}

	return PLUGIN_HANDLED
}