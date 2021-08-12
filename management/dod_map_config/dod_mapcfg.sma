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
//	Name:		DoD Map Configs
//	Author:		|BW|.Zor
//	Description:	This will call the map configs for all maps
//	Reference:	http://www.dodplugins.net/viewtopic.php?p=7241
//
//	v0.1 	- Be!
//
///////////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <amxmisc>

///////////////////////////////////////////////////////////////////////////////////////
// Version Control
//
new AUTH[] = "AMXX DoD Community"
new PLUGIN_NAME[] = "DoD Map Configs"
new VERSION[] = "0.1"
//
///////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////
// Globals
//
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
}
