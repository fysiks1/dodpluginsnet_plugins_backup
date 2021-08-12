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
//	Name:		DoD Admin Models
//	Author:		|BW|.Zor
//	Description:	This plugin will set the admin to have specific models
//	Reference:	
//
//	CVARS:	( Place these Variables into the addons/amxmodx/configs/amxx.cfg File )
//
//		dod_am_enabled	1
//
//	v0.1 	- Be!
//	v0.2	- Added the dod_set_body
//	v0.3	- Added the ability to set the model body for each person dod_set_body
//		- Added menu for higher level admins to fiddle with their bodies
//	v0.4	- Updated for DoDx 1.75
//	v0.4a	- Fixed error in dod_client_changeteam where user joins spectator
//	v0.5	- Major fix, non admin players were getting models as the tracking number
//		was not getting reset when an admin dropped/quit/spectated
//	v0.5a	- Fixed up some errors picked up by =|[76AD]|= TatsuSaisei	
//	v0.5b	- Added setting to change who can have the skin 
//	0.5b-1	- Fixed by Fysiks (debug cvar fix)
//
///////////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <dodx>

///////////////////////////////////////////////////////////////////////////////////////
// Version Control
//
new AUTH[] = "AMXX DoD Community"
new PLUGIN_NAME[] = "DoD Admin Models"
new VERSION[] = "0.5b-1"
//
///////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////
// Globals
#define USER ADMIN_LEVEL_H
#define MODELS 4
new models[MODELS][128] =
{
	"models/player/admin-allies/admin-allies.mdl",
	"models/player/admin-allies/admin-alliesT.mdl",
	"models/player/admin-axis/admin-axis.mdl",
	"models/player/admin-axis/admin-axisT.mdl"
}

new models_type[2][32] =
{
	"admin-allies",
	"admin-axis"
}

new body_number[33] = { 0, ...}

//CVARS
new g_dod_am_enabled

//
///////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////
//
// Initializations of the Plugin
//
public plugin_init()
{
	// Register this plugin
	register_plugin(PLUGIN_NAME, VERSION, AUTH)
	register_clcmd("amx_bodynum", "set_body_number_cmd", USER, "<nick> <number 0-10000> - Sets the body number for a player")
	
	// Register the Forwards
	register_forward(FM_PrecacheModel, "fw_precache") 
	register_forward(FM_PrecacheSound, "fw_precache") 
	register_forward(FM_PrecacheGeneric, "fw_precache")
	
	// Menu
	register_clcmd("amx_modelmenu", "show_main_menu", ADMIN_LEVEL_A, "- Main Menu Command for Model Body Testing")
	register_clcmd("body_number_cmd", "body_number_cmd", ADMIN_LEVEL_A, "- Captures Commands From Keyboard")
	register_menucmd(register_menuid("Model Body Test"), (MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3), "action_main_menu")
}

///////////////////////////////////////////////////////////////////////////////////////
//
// Configs the plugin
//
public plugin_cfg()
{
	// Get the placement of the joinleave file
	new temp[128]

	// Allow the server to run the config file
	get_configsdir(temp, 127)
	format(temp, 127, "%s/amxx.cfg", temp)
	server_cmd("exec %s", temp)
	server_exec()
	
	return PLUGIN_CONTINUE
}

///////////////////////////////////////////////////////////////////////////////////////
//
// Precache
//
public plugin_precache()
{
	// Register CVARS
	g_dod_am_enabled = register_cvar("dod_am_enabled", "1")
	
	for(new x = 0; x < MODELS; x++)
	{
		if(!file_exists(models[x]))
		{
			log_amx("File: %s Does not Exist, Disabling plugin!", models[x])
			set_pcvar_num(g_dod_am_enabled, 0)

			return PLUGIN_CONTINUE
		}
	
		precache_model(models[x])
		enforce(models[x])
	}
	
	precache_model("models/rpgrocket.mdl")
	
	return PLUGIN_CONTINUE
}

public client_putinserver(id)
{
	if(!is_user_connected(id) || !get_pcvar_num(g_dod_am_enabled))
		return PLUGIN_CONTINUE
		
	if(get_user_flags(id)&USER)
		body_number[id] = 12
	
	return PLUGIN_CONTINUE
}

public dod_client_changeteam(id, team, oldteam)
{
	if(!is_user_connected(id) || !get_pcvar_num(g_dod_am_enabled))
		return PLUGIN_CONTINUE

	if(get_user_flags(id)&USER)
	{
		if(team == ALLIES || team == AXIS)
			dod_set_model(id, models_type[team-1])
	}
		
	return PLUGIN_CONTINUE
}

public dod_client_changeclass(id, class, oldclass)
{
	if(!is_user_connected(id) || !get_pcvar_num(g_dod_am_enabled))
		return PLUGIN_CONTINUE

	if(get_user_flags(id)&USER)
	{
		// Here you can play with some bodys to see the number of them and determine what body for what class
		dod_set_body_number(id, body_number[id])
	}
		
	return PLUGIN_CONTINUE
}

public dod_client_spawn(id)
{
	if(!is_user_connected(id) || !get_pcvar_num(g_dod_am_enabled))
		return PLUGIN_CONTINUE

	if(get_user_flags(id)&USER)
	{
		// Here you can play with some bodys to see the number of them and determine what body for what class
		dod_set_body_number(id, body_number[id])
	}
		
	return PLUGIN_CONTINUE
}

public set_body_number_cmd(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2) || !get_pcvar_num(g_dod_am_enabled))
		return PLUGIN_HANDLED
		
	new number[32]
	read_argv(2, number, 128)
	remove_quotes(number)
	
	if(!is_str_num(number))
	{
		client_print(id, print_chat, "Sorry thats not a Number Please Try Again!")
		client_cmd(id, "amx_bodynum")
		return PLUGIN_HANDLED
	}
	
	new player[32]
	read_argv(1, player, 31)
	new player_id = get_player(player)
	
	if(!player_id)
	{
		client_print(id, print_chat, "Sorry thats not a player name!")
		client_cmd(id, "amx_bodynum")
		return PLUGIN_HANDLED
	}
	
	get_user_name(player_id, player, 31)
	
	if(get_user_flags(player_id)&USER)
	{
		client_print(id, print_chat, "You have Set Player %s's Body Number to %d", player, str_to_num(number))
		body_number[player_id] = str_to_num(number)
	}
	
	else
	{
		client_print(id, print_chat, "You Cannot Set Player %s's Body Number as they are not an admin!", player)
	}
	
	return PLUGIN_HANDLED
}

public show_main_menu(id, level, cid)
{
	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED

	display_main_menu(id)

	return PLUGIN_HANDLED
}

stock display_main_menu(id)
{
	new menuBody[1024]
	new keys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3
	new len = format(menuBody, 511, "\yModel Body Test^n^n")
	len += format(menuBody[len], (1023-len), "\rBody Set At: %d^n^n", entity_get_int(id, EV_INT_body))
	len += format(menuBody[len], (1023-len), "\r1) \w3rd Person On^n")
	len += format(menuBody[len], (1023-len), "\r2) \w3rd Person Off^n")
	len += format(menuBody[len], (1023-len), "\r3) \wSet Body Number^n")
	format(menuBody[len], (1023-len), "\r0) \wExit^n")

	show_menu(id, keys, menuBody, -1, "Model Body Test")

	return PLUGIN_HANDLED
}

public action_main_menu(id, key)
{
	switch(key)
	{
		case 0:
		{
			set_view(id, 1)
			client_cmd(id, "amx_modelmenu")
		}
		case 1:
		{
			set_view(id, 0)
			client_cmd(id, "amx_modelmenu")
		}
		case 2:
		{
			client_cmd(id, "messagemode body_number_cmd")
		}
		default:
		{
			set_view(id, 0)
		}
	}

	return PLUGIN_CONTINUE
}

public body_number_cmd(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED

	new arg[128]
	read_args(arg, 128)
	remove_quotes(arg)
	
	if(!is_str_num(arg))
	{
		client_print(id, print_chat, "Sorry thats not a Number Please Try Again!")
		client_cmd(id, "messagemode body_number_cmd")
		return PLUGIN_HANDLED
	}
	
	client_print(id, print_chat, "You have Set Your Body Number to %d", str_to_num(arg))	
	entity_set_int(id, EV_INT_body, str_to_num(arg))
	client_cmd(id, "amx_modelmenu")
	
	return PLUGIN_HANDLED

}

public fw_precache(const file[]) 
{
	enforce(file)
	return FMRES_IGNORED
}  

public enforce(const file[])
{
	force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, file)
}

public inconsistent_file(id, const filename[], reason[64])
{
	format(reason, 63, "Delete %s and reconnect to get proper file!", filename)
	return PLUGIN_CONTINUE
}

stock get_player(search[])
{
	// See if they are there by exact nick
	new player_id = find_player("ahjl", search)

	if(!player_id)
	{
		// Try to find them by portion of nick
		player_id = find_player("bhjl", search)
	}

	if(!player_id)
	{
		// Try to find them by steam id
		player_id = find_player("chj", search)
	}

	if(!player_id)
	{
		// Try to find them by ip
		player_id = find_player("dhj", search)
	}

	if(!player_id)
	{
		// Try to find them by userid
		player_id = find_player("khj", search)
	}

	return player_id
}