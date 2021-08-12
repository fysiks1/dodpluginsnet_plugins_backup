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
//	Name:		DoD Limits
//	Author:		|BW|.Zor
//	Description:	This will limit the amount of NUM_CLASSES
//	Reference:	http://www.dodplugins.net/viewtopic.php?t=944
//
//	v0.1 	- Be!
//	v0.1a	- Update
//	v0.2	- Updated to use percentages
//	v0.3	- Updated the way we look at files, no more single file, now its
//		multiple files
//	v0.3a	- Updated slightly due to the bad loads on the names
//
///////////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <amxmisc>
#include <dodx>

///////////////////////////////////////////////////////////////////////////////////////
// Version Control
//
new AUTH[] = "AMXX DoD Community"
new PLUGIN_NAME[] = "DoD Limits"
new VERSION[] = "0.3a"
//
///////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////
// Globals
//

// Class stuff
#define NUM_CLASSES 23
new classListName[NUM_CLASSES][32] = 
{
	"mp_limitalliesgarand",
	"mp_limitalliescarbine",
	"mp_limitalliesthompson",
	"mp_limitalliesgreasegun",
	"mp_limitalliesspring",
	"mp_limitalliesbar",
	"mp_limitallies30cal",
	"mp_limitalliesbazooka",
	"mp_limitbritlight",
	"mp_limitbritassault",
	"mp_limitbritsniper",
	"mp_limitbritmg",
	"mp_limitbritpiat",
	"mp_limitaxiskar",
	"mp_limitaxisk43",
	"mp_limitaxismp40",
	"mp_limitaxismp44",
	"mp_limitaxisfg42",
	"mp_limitaxisfg42s",
	"mp_limitaxisscopedkar",
	"mp_limitaxismg34",
	"mp_limitaxismg42",
	"mp_limitaxispschreck"
}

new classListLimit[NUM_CLASSES] = 
{
	-1,	// Garand
	-1,	// Carbine
	-1,	// Thompson
	-1,	// Grease
	1,	// Spring
	4,	// Bar
	1,	// 30cal
	1,	// Zooka
	4,	// Enfield
	-1,	// Sten
	1,	// SEnfield
	4,	// Bren
	1,	// Piat
	4,	// Kar
	-1,	// K42
	-1,	// MP40
	4,	// MP44
	4,	// FG42
	1,	// FG42s
	1,	// SKar
	1,	// MG34
	1,	// MG42
	1	// Screck
}

new Float:classListPercent[NUM_CLASSES] = 
{
	0.0,	// Garand
	0.0,	// Carbine
	0.0,	// Thompson
	0.0,	// Grease
	0.25,	// Spring
	0.0,	// Bar
	0.25,	// 30cal
	0.25,	// Zooka
	0.0,	// Enfield
	0.0,	// Sten
	0.25,	// SEnfield
	0.0,	// Bren
	0.25,	// Piat
	0.0,	// Kar
	0.0,	// K42
	0.0,	// MP40
	0.0,	// MP44
	0.0,	// FG42
	0.25,	// FG42s
	0.0,	// SKar
	0.25,	// MG34
	0.25,	// MG42
	0.25	// Screck
}
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
	
	// Register Client Commands
	register_clcmd("dod_limit", "set_limit", ADMIN_LEVEL_H, "<class> <limit> <percent> - Will set the limit on that class")
	
	// Register CVARS
	register_cvar("dod_limit_debug", "0")
}

///////////////////////////////////////////////////////////////////////////////////////
//
// Configs the plugin
//
public plugin_cfg()
{
	set_task(5.0, "timedSettings")
}

///////////////////////////////////////////////////////////////////////////////////////
//
// Sets up the cvars
//
public timedSettings(params[])
{
	// Execute the server.cfg first
	if(file_exists("server.cfg"))
	{
		log_amx("Executing server.cfg")
		server_cmd("exec server.cfg")
	}

	// Get the map name
	new mapname[64]
	get_mapname(mapname, 63)
	format(mapname, 63, "%s.cfg", mapname)
	
	// Execute the dod_map.cfg second
	if(file_exists(mapname))
	{
		log_amx("Executing %s", mapname)
		server_cmd("exec %s", mapname)
	}
	
	// Execute the server exec
	server_exec()
	
	// Do the Configuring Setup
	do_config()
}

///////////////////////////////////////////////////////////////////////////////////////
//
// Will set the limit that is defined by limit on the class
//
public set_limit(id, level, cid)
{
	// Check to see that <class> (limit) (percent) is in the command line
	if(!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED
		
	new class[32], number[8], percent[8], players_total

	// Get the class
	read_argv(1, class, 31)
	
	// Get the limit
	read_argv(2, number, 7)
	
	// Get the percent
	read_argv(3, percent, 7)
	
	if(contain(percent, "^%"))
	{
		client_cmd(id, "dod_limit")
		return PLUGIN_HANDLED
	}
	
	players_total = get_maxplayers()
	
	for(new counter = 0; counter < NUM_CLASSES; counter++)
	{
		if(equal(classListName[counter], class))
		{
			classListLimit[counter] = str_to_num(number)
			classListPercent[counter] = floatstr(percent)			
			
			client_print(id, print_console, "Set %s to %d when %d players out of %d are on the server.", class, classListLimit[counter], (players_total * classListPercent[counter]), players_total)
			
			return PLUGIN_HANDLED
		}
	}

	return PLUGIN_HANDLED
}

public client_putinserver(id)
{
	new percentage, players_on = get_playersnum()
	
	for(new counter = 0; counter < NUM_CLASSES; counter++)
	{
		percentage = floatround(get_maxplayers() * classListPercent[counter])
		
		if(get_cvar_num("dod_limit_debug"))
		{
			log_amx("Check Percentage: %d >= %d", players_on, percentage)
		}
		
		if(players_on >= percentage)
		{
			if(get_cvar_num(classListName[counter]) != classListLimit[counter])
			{
				set_cvar_num(classListName[counter], classListLimit[counter])
				server_cmd("%s %d", classListName[counter], classListLimit[counter])

				if(get_cvar_num("dod_limit_debug"))
				{
					new nick[32]
					get_user_name(id, nick, 31)
					log_amx("Player %s Joined so Setting %s = %d for %d >= %d", nick, classListName[counter], classListLimit[counter], players_on, percentage)
				}
			}
		}
	}
}

public client_disconnect(id)
{
	new percentage, players_on = get_playersnum()
	
	for(new counter = 0; counter < NUM_CLASSES; counter++)
	{
		percentage = floatround(get_maxplayers() * classListPercent[counter])
		
		if(get_cvar_num("dod_limit_debug"))
		{
			log_amx("Check Percentage: %d < %d", players_on, percentage)
		}
		
		if(players_on < percentage)
		{
			set_cvar_num(classListName[counter], 0)
			server_cmd("%s 0", classListName[counter])
			
			if(get_cvar_num("dod_limit_debug"))
			{
				new nick[32]
				get_user_name(id, nick, 31)
				log_amx("Player %s Left so Re-Setting %s = 0 for %d < %d", nick, classListName[counter], classListLimit[counter], players_on, percentage)
			}
		}
	}
}

stock do_config()
{
	new fileName[128], folderName[64], mapname[32], pos, readLine[1024], a, counter
	new cvar[32], amount[32], percent[32]

	get_mapname(mapname, 31)	
	get_configsdir(folderName, 63)

	format(fileName, 127, "%s/dod_limits/%s_limit.cfg", folderName, mapname)
	
	if(!file_exists(fileName))
	{
		run_cmds()
		return
	}

	while(read_file(fileName, pos++, readLine, 1023, a))
	{
		// Check to see if a comment
		if(containi(readLine, "//") == -1 && strlen(readLine) > 0)
		{
			// CVAR				Amount	Percent
			// "mp_limitalliesgarand"	"-1"	"0"
			parse(readLine, cvar, 31, amount, 31, percent, 31)

			for(counter = 0; counter < NUM_CLASSES; counter++)
			{
				if(equal(classListName[counter], cvar))
				{
					classListLimit[counter] = str_to_num(amount)

					if(equal(percent, "0") || equal(percent, "0.0"))
						classListPercent[counter] = 0.0

					else
						classListPercent[counter] = str_to_float(percent) / 100.0

					if(get_cvar_num("dod_limit_debug"))
					{
						log_amx("File - Class: ^"%s^" ^"%d^" ^"%f^"", classListName[counter], classListLimit[counter], classListPercent[counter])
					}

					counter = NUM_CLASSES
				}
			}
		}
	}
	
	run_cmds()
	return
}

stock run_cmds()
{
	for(new counter = 0; counter < NUM_CLASSES; counter++)
	{
		set_cvar_num(classListName[counter], 0)
		server_cmd("%s 0", classListName[counter])

		if(get_cvar_num("dod_limit_debug"))
		{
			new players_total = get_maxplayers()
			new percentage = floatround(players_total * classListPercent[counter])
			log_amx("Setting %s = 0 until %d players out of %d are on the server", classListName[counter], percentage, players_total)
		}
	}
}