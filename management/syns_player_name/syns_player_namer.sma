/*=================================================================================================
Syn's Player Namer v1.002

This plugin takes care of those players on your server with the default name "Player" or "(1)Player" 
and so on. A HUD notice is given along with instructions on how to change their name. They will be 
forced to change their name within a specified amount of time and if they don't, they will 
automatically be renamed to a random name from a list or to their Steam ID.

===========================
v1.002 Changes
===========================
- Fixed not creating timers for individual people with bad names.
- Now only checks once per player spawn. This should be sufficient.
- Made some adjustments. Thanks Dr. G for pointing those out.
- Added file support for names that you want changed. Thanks Diamond-Optic for all those names.

===========================
v1.001 Changes
===========================
- Changed renaming system using a completely different method.

===========================
CVARs
===========================
player_rename | 0 = off | 1 = on
- Enables or disables the "Player" rename plugin. Default on.

player_rename_time | x.x
- Specifies the amount of time a player named "Player" has before they will be automatically renamed
  to a different name. You can enter an integer or real number here. For example, a value of one 
  would be 1 second and a value of 1.5 would be 1 and a 1/2 seconds. Default 60.0.

player_rename_method | 0 = player_rename.ini | 1 = Steam ID
- Specifices whether the players named "Player" that have not changed their name within the allowed
  time get their name automatically changed to one from the file player_rename.ini or to their
  Steam ID. Default player_rename.ini
  
player_rename_type | 0 = continually countdown notify | 1 = notify once
- Allows changing the red HUD count down notification to continually display how many seconds are 
  left to a player that needs to change their name or notify them only once. Default notify once.
  
player_rename_case | 0 = not case sensitive | 1 = case sensitive
- Allows changing whether players names are checked case sensitively or not against the check for 
  names list. Not case sensitive means Poop is considered the same as poop and with case sensitive
  checking, Poop is not considered the same as poop. Default case sensitive.

===========================
player_rename.ini
===========================
This file contains a list of names used when renaming players named "Player". You can enter up to a
total of 64 names. Enter only one name per line.

===========================
player_rename_check.ini
===========================
This file contains a list of names that you wish to be used by the renaming plugin. These are names
you don't want in your server. You can enter up to a total of 128 names. Enter only one name per 
line. Checks are performed by identifying and entry in any part of a player's name. E.G. If you have
an entry for the word "Poop" and player named "Camel Poop" comes in along with one named "Dog Poop",
it will nail both of them.

===========================
Installation
===========================
- Compile the .sma file | An online compiler can be found here:
  http:www.amxmodx.org/webcompiler.cgi
- Copy the compiled .amxx file into your addons\amxmodx\plugins folder
- Edit the player_rename.ini and player_name_check.ini with names to your liking and copy to your 
  addons\amxmodx\configs\  folder.
- Copy or create a player_rename.ini file in your addons\amxmodx\configs\ folder with a list of 
  names.
- Change the map or restart your server to start using the plugin!

===========================
Support
===========================
Visit the AMXMODX Plugins section of the forums @ 
http:www.dodplugins.net or http:www.rivurs.com

===========================
License
===========================
Syn's Player Namer
Copyright (C) 2012 Synthetic

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=================================================================================================*/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

// =================================================================================================
// Declare global variables and values
// =================================================================================================
new p_player_rename
new p_player_rename_time
new p_player_rename_method
new p_player_rename_type
new p_player_rename_case
new player_check[33]
new config_dir[64]
new player_name_file[96]
new player_names[64][32]
new player_name_check_file[96]
new player_names_check[128][32]
new total_names
new total_names_check
new player_counter[33]
new player_warn_switch[33]
new show_hud

// =================================================================================================
// Plugin Init
// =================================================================================================
public plugin_init() {
	register_plugin("Syn's Player Namer","1.002","Synthetic")
	register_cvar("Version 1.002 by Synthetic - www.rivurs.com", "Syns_Player_Namer",FCVAR_SERVER|FCVAR_SPONLY)
	
	p_player_rename = register_cvar("player_rename","1")
	p_player_rename_time = register_cvar("player_rename_time","60.0")
	p_player_rename_method = register_cvar("player_rename_method","0")
	p_player_rename_type = register_cvar("player_rename_type","1")
	p_player_rename_case = register_cvar("player_rename_case","1")
	get_configsdir(config_dir,63)
	format(player_name_file,95,"%s/player_rename.ini",config_dir)
	format(player_name_check_file,95,"%s/player_rename_check.ini",config_dir)

	if(get_pcvar_num(p_player_rename))
	{
		set_task(0.5,"func_load_names")
		set_task(0.5,"func_load_names_check")
	}
	
	register_event("ResetHUD","func_respawn","be")
}

// =================================================================================================
// Remove checking for player IDs no longer in use
// =================================================================================================
public client_disconnect(id) {
	if(get_pcvar_num(p_player_rename))
	{
		player_check[id] = 0
		id = id - 2300
		if(task_exists(id))
			remove_task(id)
	}
}

// =================================================================================================
// Check for a player using a "Player" variant and if so handle them
// =================================================================================================
public func_respawn(id) {
	if(is_user_alive(id))
	{
		new check_name[64],i,found_one
		get_user_name(id,check_name,63)
		new check_case = get_pcvar_num(p_player_rename_case)
		
		for(i=0;i<total_names_check;i++)
		{
			switch(check_case)
			{
				case 0: {
					if(containi(check_name,player_names_check[i]) != -1)
					{
						if(!player_check[id])
						{
							player_check[id] = 1
							player_warn_switch[id] = 1
						}
						found_one = 1
					}
				}
				case 1: {
					if(contain(check_name,player_names_check[i]) != -1)
					{
						if(!player_check[id])
						{
							player_check[id] = 1
							player_warn_switch[id] = 1
						}
						found_one = 1
					}
				}
			}
			
		}
		
		// If player changes name before time up, turn off check
		if(!found_one)
		{
			player_check[id] = 0
			if(task_exists(id+2400))
				remove_task(id+2400)
		}
		
		// Show warning messages
		if(player_check[id])
		{
			if(player_warn_switch[id])
			{
				set_task(1.0,"func_warning",id+2400,"",0,"b")
				player_warn_switch[id] = 0
				client_print(id,print_chat,"To change your name, type: name ^"my name^" into the console!")
				player_counter[id] = floatround(get_pcvar_float(p_player_rename_time))
			}
		}
	}
}

// =================================================================================================
// Load player rename definition file
// =================================================================================================
public func_load_names() {
	// Load name file if it exists
	if(file_exists(player_name_file))
	{
		new n,temp_holder[63]
		new file = fopen(player_name_file,"rt")
		
		// Load names into array
		while(!feof(file))
		{
			fgets(file,temp_holder,62)
			replace(temp_holder,62,"^n","")
			format(player_names[n],63,"%s",temp_holder)
			n++
			total_names = n
		}
		fclose(file)
	}
}

// =================================================================================================
// Load player check definition file
// =================================================================================================
public func_load_names_check() {
	// Load name file if it exists
	if(file_exists(player_name_check_file))
	{
		new n,temp_holder[63]
		new file = fopen(player_name_check_file,"rt")
		
		// Load names into array
		while(!feof(file))
		{
			fgets(file,temp_holder,62)
			replace(temp_holder,62,"^n","")
			format(player_names_check[n],63,"%s",temp_holder)
			n++
			total_names_check = n
		}
		fclose(file)
	}
}

// =================================================================================================
// Warn player with HUD message
// =================================================================================================
public func_warning(id) {
	id = id - 2400
	if(player_counter[id] > 0 && !show_hud)
	{
		new Float:duration[2] = { 0.9,5.0 }
		new duration_type
		
		switch(get_pcvar_num(p_player_rename_type))
		{
			case 0: {
				show_hud = 0
				duration_type = 0
			}
			case 1: {
				show_hud = 1
				duration_type = 1
			}
		}
			
		set_hudmessage(255,0,0,-1.0,0.5,0,0.2,duration[duration_type],0.05,0.05,-1)
		show_hudmessage(id,"You have %i second(s) to change your name or you will be renamed.",player_counter[id])
		set_hudmessage(255,0,0,-1.0,0.6,0,0.2,duration[duration_type],0.05,0.05,-1)
		show_hudmessage(id,"To change your name, type: name ^"my name^" into the console!")
	}
	if(!player_counter[id])
	{
		new random_name[128]
			
		// Change name
		if(!get_pcvar_num(p_player_rename_method))
		{
			format(random_name,127,"%s",player_names[random_num(0,total_names - 1)])
			client_cmd(id,"name ^"%s^"",random_name)
		}
		else
		{
			get_user_authid(id,random_name,127)
			client_cmd(id,"name ^"%s^"",random_name)
		}
		player_check[id] = 0
		remove_task(id)
	}
	player_counter[id]--
}
