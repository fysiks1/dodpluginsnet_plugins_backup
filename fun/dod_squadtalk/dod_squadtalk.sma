/*
	Created by Zor
		Thanks to code from Willson and the 29th ID
		Thanks to TwilightSuzuka
		
		http://dodplugins.net/forums/showthread.php?t=1261
		
	Ver 1.1
		Added TEAM so that when people join they can talk to the team
		Added Menus
		Fixed the dod_listsquads
*/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <dodconst>

#define PLUGIN "Squad Talk"
#define VERSION "1.1"
#define AUTHOR "DoD Plugins"

// Squad bit operators
#define TEAM		0
#define SQUAD_1 	4
#define SQUAD_2 	8
#define SQUAD_3 	16
#define SQUAD_4 	32

// Globals
new g_squad_members[32]

// CVARS
new g_enabled
new gForward

new g_allies_squad_names[5][] =
{
	"Allies All Team 0",
	"Allies Squad 1",
	"Allies Squad 2",
	"Allies Squad 3",
	"Allies Squad 4"
}

new g_axis_squad_names[5][] =
{
	"Allies All Team 0",
	"Axis Squad 1",
	"Axis Squad 2",
	"Axis Squad 3",
	"Axis Squad 4"
}

public plugin_init() 
{
	// Register the plugin
	register_plugin(PLUGIN, VERSION, AUTHOR)

	// CVAR to enable the plugin
	g_enabled  = register_cvar("dod_squadtalk_enable", "1")

	// To join a squad
	register_clcmd("dod_joinsquad", "cmdJoinSquad", 0, "- dod_joinsquad <squad number> - Join a squad (must be a member of a team)")
	register_clcmd("dod_listsquads", "cmdListSquads", 0, "- dod_listsquads - List squads and their members")
	
	// Menu System
	register_clcmd("dod_squadtalk_menu", "squadtalk_menu")
	
	// Register a forward
	gForward = register_forward(FM_Voice_SetClientListening, "fwd_SetClientListening")
}

public plugin_end() 
{
	if(!get_pcvar_num(g_enabled))
		return PLUGIN_CONTINUE
		
	DestroyForward(gForward)
	
	return PLUGIN_CONTINUE
}

public client_putinserver(id)
{
	// Reset the member
	g_squad_members[id] = TEAM
		
	return PLUGIN_CONTINUE
}

public client_changeteam(id)
{
	// Reset the member
	g_squad_members[id] = TEAM
	
	return PLUGIN_CONTINUE
}

public client_disconnect(id)
{
	// Reset the member
	g_squad_members[id] = TEAM
	
	return PLUGIN_CONTINUE
}

public squadtalk_menu(id)
{
	new menu = menu_create("\rDoD Squad Talk Menu:", "menu_handler")
		
	//Now lets add some things to select from the menu
	menu_additem(menu, "\wJoin Team Talk", "1", 0)
	menu_additem(menu, "\wJoin Squad 1", "2", 0)
	menu_additem(menu, "\wJoin Squad 2", "3", 0)
	menu_additem(menu, "\wJoin Squad 3", "4", 0)
	menu_additem(menu, "\wJoin Squad 4", "5", 0)
	menu_additem(menu, "\wList Squad Members", "6", 0)
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
}

public menu_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	new data[8], iName[64]
	new access, callback
	menu_item_getinfo(menu, item, access, data, 7, iName, 63, callback)

	switch(str_to_num(data))
	{
		case 1:
		{
			client_cmd(id, "dod_joinsquad 0")
			menu_destroy(menu)
		}
		
		case 2:
		{
			client_cmd(id, "dod_joinsquad 1")
			menu_destroy(menu)
		}
		
		case 3:
		{
			client_cmd(id, "dod_joinsquad 2")
			menu_destroy(menu)
		}
		
		case 4:
		{
			client_cmd(id, "dod_joinsquad 3")
			menu_destroy(menu)
		}
		
		case 5:
		{
			client_cmd(id, "dod_joinsquad 4")
			menu_destroy(menu)
		}
		
		case 6:
		{
			client_cmd(id, "dod_listsquads")
			menu_display(id, menu, 0)
		}
	}

	return PLUGIN_HANDLED
}

public cmdJoinSquad(id, level, cid)
{
	if(!cmd_access(id, level, cid, 1) || !get_pcvar_num(g_enabled))
		return PLUGIN_HANDLED
		
	new team = get_user_team(id) 
	
	// Check to see if they are spectating, if so read them their rights!
	if(team == 3)
	{
		client_cmd(id, "dod_joinsquad")
		return PLUGIN_HANDLED
	}
	
	// Get the squad they want on
	new temp[8]
	read_argv(1, temp, 7)
	new squad_num = str_to_num(temp)

	// Make sure that the is withing our limits
	if(squad_num < 0 || squad_num > 4)
	{
		client_print(id, print_console, "Choose a number between 0 and 4 to choose a squad")
		client_print(id, print_chat, "Choose a number between 0 and 4 to choose a squad")
		return PLUGIN_HANDLED
	}	

	// now we bit op them to the team they want
	switch(squad_num)
	{
		case 0:
		{
			g_squad_members[id] = TEAM
			client_print(id, print_console, "You joined the Team Chat")
			client_print(id, print_chat, "You joined the Team Chat")
		}
		
		case 1:
		{
			g_squad_members[id] = SQUAD_1
			client_print(id, print_console, "You joined Squad One")
			client_print(id, print_chat, "You joined Squad One")
		}
		
		case 2:
		{
			g_squad_members[id] = SQUAD_2
			client_print(id, print_console, "You joined Squad Two")
			client_print(id, print_chat, "You joined Squad Two")
		}
		
		case 3:
		{
			g_squad_members[id] = SQUAD_3
			client_print(id, print_console, "You joined Squad Three")
			client_print(id, print_chat, "You joined Squad Three")
		}
		
		case 4:
		{
			g_squad_members[id] = SQUAD_4
			client_print(id, print_console, "You joined Squad Four")
			client_print(id, print_chat, "You joined Squad Four")
		}
	}
		
	return PLUGIN_HANDLED
}

public cmdListSquads(id, level, cid)
{
	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED
		
	if(!get_pcvar_num(g_enabled))
		return PLUGIN_CONTINUE
		
	new players[32], members[5][16], tracker[5], count, team = get_user_team(id)
	
	get_players(players, count, "ch")
	
	for(new i = 0; i < count; i++)
	{
		if(team == get_user_team(players[i]))
		{
			if((g_squad_members[players[i]]&TEAM))
				members[0][tracker[0]++] = players[i]
				
			if((g_squad_members[players[i]]&SQUAD_1))
				members[1][tracker[1]++] = players[i]
				
			else if((g_squad_members[players[i]]&SQUAD_2))
				members[2][tracker[2]++] = players[i]
				
			else if((g_squad_members[players[i]]&SQUAD_3))
				members[3][tracker[3]++] = players[i]
				
			else if((g_squad_members[players[i]]&SQUAD_4))
				members[4][tracker[4]++] = players[i]
		}
	}
	
	if(team == ALLIES)
	{
		new name[32]
		
		for(new i = 0; i < 5; i++)
		{		
			// Do we have members
			if(tracker[i] > 0)
			{
				client_print(id, print_console, "%s has %d %s", g_allies_squad_names[i], tracker[i], ((tracker[i] > 1) ? "Members" : "Member"))
				client_print(id, print_chat, "%s has %d %s", g_allies_squad_names[i], tracker[i], ((tracker[i] > 1) ? "Members" : "Member"))
				
				for(new x = 0; x < tracker[i]; x++)
				{
					get_user_name(members[i][x], name, 31)
					client_print(id, print_console, "%d) %s", x+1, name)
					client_print(id, print_chat, "%d) %s", x+1, name)
				}
			}
		}
	}
	
	if(team == AXIS)
	{
		new name[32]

		for(new i = 0; i < 5; i++)
		{
			// Do we have members
			if(tracker[i] > 0)
			{
				client_print(id, print_console, "%s has %d %s", g_axis_squad_names[i], tracker[i], ((tracker[i] > 1) ? "Members" : "Member"))
				client_print(id, print_chat, "%s has %d %s", g_axis_squad_names[i], tracker[i], ((tracker[i] > 1) ? "Members" : "Member"))

				for(new x = 0; x < tracker[i]; x++)
				{
					get_user_name(members[i][x], name, 31)
					client_print(id, print_console, "%d) %s", x+1, name)
					client_print(id, print_chat, "%d) %s", x+1, name)
				}
			}
		}
	}
		
	return PLUGIN_HANDLED
}


public fwd_SetClientListening(receiver, sender, listen) 
{
	if(!get_pcvar_num(g_enabled))
		return FMRES_IGNORED
		
	if(is_user_connected(sender) && is_user_connected(receiver))
	{
		if((get_user_team(sender) != get_user_team(receiver)) && !(g_squad_members[sender]&g_squad_members[receiver]))
		{
			// Now check to see if they are not in the same squad
			engfunc(EngFunc_SetClientListening, receiver, sender, false)
			return FMRES_SUPERCEDE
		}
	}
	
	return FMRES_IGNORED
}