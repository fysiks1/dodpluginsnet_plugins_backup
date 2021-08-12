/*=================================================================================================
Syn's No Scope Notifier v2.001

This plugin will display no scope kills and keeps track of them. I know I've seen servers with
something similar but could never find the plugin so I just made my own. It works with the scoped
Kar, Springfield, and Enfield. It should be possible to port this to other mods just by changing
out the mod specific include, get_user_weapon, and alter/add weapon id numbers, etc..

===========================
v2.001 Changes
===========================
- Found and fixed a bug with displaying no scope to regular kill percentage. It was triggered with
CVAR no_scope_notify_headshot instead of a seperate CVAR causing to only work when headshot
notification was enabled.
- Added new CVAR no_scope_percent to enable or disable the extra no scope to regular kill 
percnetage information.

===========================
v2.0 Changes
===========================
- Fixed function using wrong player ID. Thanks Diamond.
- Fixed best no scope records loading log error. Thanks Diamond.
- Added a few more switch optimizations I missed previously. Thanks Dr.G
- Added yet more optizations.
- Fixed Headshot HUD message getting overlapped when using standard HUD no scope shot messages.

===========================
v1.9 Changes
===========================
- Some parts of the code were overhauled for speed. Engine is no longer used.
- Best shots/records now hold the top 3 players instead of 1.
- Added temporary best no scope shot per current map played with say command /noscoperound.
- Added CVAR no_scope_round to enable or disable temporary best shot record per map feature.
- Best shot records are now on a per map basis. You will need to create a folder named "no_scope" in
  your amxmodx configs directory.
- Fixed a couple issues of not checking if a player was still connected when performing some 
functions. Thanks again Diamond-Optic for sharing your log info.

===========================
v1.8 Changes
===========================
- Fixed no scope head shot totals for PsychoStats logging. Thanks Diamond-Optic for letting me
know of the problem.

===========================
v1.7 Changes
===========================
- Added percentage of no scope shots to other kills in the output of say command /noscopes.
- Added optional HUD message of no scope headshot.
- Added optional shot distance in feet or meters along with body part hit.
- Added some speed improvements.
- Added optional shot blocking with message when trying to use the scope.
- Added say command /noscopehits that shows no scope kills by hit box.

===========================
v1.6 Changes
===========================
- Fixed on kill private chat message of total no scope kills. It was displaying with other
  weapons and could flood the chat box. Thanks to Tank from BAM for spotting it.
- Fixed invalid player errors on player disconnect for keeping track of final score.
- Added no scope best shot distance record option.
- Added CVAR no_scope_record for enabling and disabling best no scope shot record feature.

===========================
v1.5 Changes
===========================
- Added checking for players that weren't connected under MG non deployed reload message fix. 
  Gave invalid player errors in log. Not necessary but I like to keep things clean.

===========================
v1.4 Changes
===========================
- Changed some natives to fakemeta equivalents. This includes the scope / non scope detection.
  Should be 100% accurate now.
- Fixed MG non deployed reload small hud text message. Showed last no scope kill info along with
  message about needing to deploy to reload. Since this message is apparently client side, I did
  find a work around but it shifts the reload message to the left.
- Fixed crashing issue for detection of player team info. Thanks again johndoe on dodplugins.net
  for providing the debug output.

===========================
v1.3 Changes
===========================
- Changed get_user_team function to dod specific dod_get_pl_teamname. Reading the amxmodx forums
  I found posts that stated get_user_team is buggy. This dropped no scope kill weapon stats on
  failure. Thanks johndoe on dodplugins.net for spotting the crash.

===========================
v1.2 Changes
===========================
- Added cvar to enable or disable TK no scope kill notification.

===========================
v1.1 Changes
===========================
- Added cvars to adjust how long a no scope kill HUD notification stays on screen.
- Added cvar to mirror no scope kill HUD notification types in chat.
- Added detailed weapon stats logging for no scope kills.
- Added FF support. FF kills now do not add to the /noscopes total.
- Changed /noscopes to properly display "1 kill" instead of "1 kills".
- Clarified and added to the notes.

===========================
Features:
===========================
- Choose between small and large HUD text display or chat only notification.
- No scope kill logging for use with Psychostats. Reports no scope kills by individual gun used.
- Optional no scope record keeping.
- Optional display of shot distance and body part hit.
- Reporting of total no scope kills per round along with percentage of no scope kills in regards to
regular kills.
- Optional scoped shot blocking with message.
- Players are able to see their no scope kills by body part informaiton the entire map.
- Optional HUD notification of no scoped head shots.

===========================
Notes:
===========================
- Tested on an AMXMODX v1.8 Linux server and v1.76 Windows server as well.
- Detailed no scope kill weapon stats do not interfere with regular scope weapon stats. They
  still log as normal when no scope logging is on. IE a no scoped kill still counts as a regular
  stat kill for that type of gun.

===========================
Say Commands:
===========================
/noscopes - Displays how many no scope kills a player has accumulated along with percentage of no
scope shots.

/noscopehits - Displays a player's total kills by hit box to a player.
.
/noscoperecord - Displays the best no scope records and who the holders are for the current map.

/noscoperound - Displays the best no scope records and who the holders are for the current map
played. This is temporary data and is discarded on map change.

===========================
CVARS:
===========================
no_scope_notify | 0 = off | 1 = on
- Gives confirmation on screen of a no scope kill. Default on.

no_scope_notify_type | 0 = small | 1 = large | 2 = in chat
- Changes size and type of no scope kill notification. Default small.

no_scope_notify_small_time | 0 = 3.8 sec | 1 = 4.8 sec | 2 = 5.8 sec | 3 = 6.8 sec
- Changes duration of small HUD no scope kill notification. Due to the nature of this type of HUD
  message, the minimum is 3.8 seconds and the options available should be sufficient. Default 3.8. 

no_scope_notify_large_time | x or x.x
- Changes duration of large HUD no scope kill notification. You can enter an integer or real
  number here. For example, a value of one would just be 1 second and a value of 1.5 would be
  1 and a 1/2 seconds. Default 3.0.

no_scope_notify_tk_notify | 0 = off | 1 = on
- Enable or disable TK no scope notification. Default off.

no_scope_notify_mirror_chat | 0 = off | 1 = on
- Enables or disables mirroring of no scope kill notification in chat box. This is helpful if 
  you have allot of people no scoping and the regular notification changes too fast to read.
  This automatically checks to see if no_scope_notify_type is set to chat so you don't get 
  double notifications. Default off.

no_scope_notify_chat | 0 = off | 1 = on
- Displays total no scope kills in chat privately to player on no scope kill. Default off.

no_scope_notify_say | 0 = off | 1 = on
- Enables or disables the say command /noscopes. Default on.

no_scope_logging | 0 = off | 1 = on
- Enables logging of no scope kills. Default off.

no_scope_notify_distance | 0 = off | 1 = on
- Enables or disables showing of shot in "game distance" in no scope kill notification. Defualt
  on.

no_scope_notify_distance_type | 0 = meters | 1 = feet
- Sets whether shot in "game distance" is shown as meters or feet. Default meters.

no_scope_notify_hitbox | 0 = off | 1 = on
- Enables or disables showing of hitbox hit in no scope kill notification. Default on.

no_scope_notify_block_scope | 0 = off | 1 = on
- Enables or disables the blocking of scoped shots. Default off.

no_scope_notify_block_notify | 0 = off | 1 = on
- Enables or disables telling a user that you can't fire scoped when blocking of scoped shots is
  enabled. Default on.

no_scope_record | 0 = off | 1 = on
- Enables or disables best no scope shot record feature. Default on.

no_scope_round | 0 = off | 1 = on
- Enables or disables the temporary map best shot record feature. Default on.

no_scope_notify_headshot | 0 = off | 1 = on
- Enables or disables displaying a no scope headshot notification on all player's HUD. Default on.

no_scope_hits_say | 0 = off | 1 = on
- Enables or disables the say command /noscopehits. Default on.

no_scope_percent | 0 = off | 1 = on
- Enables or disables additional no scope kill to regular kill percentage when using say command
/noscopes.

===========================
Installation
===========================
- Compile the .sma file | An online compiler can be found here:
  http:www.amxmodx.org/webcompiler.cgi
- Copy the compiled .amxx file into your addons\amxmodx\plugins folder.
- Add the name of the compiled .amxx to the bottom of your addons\amxmodx\configs\plugins.ini
- Create a new folder named no_scope in your addons\amxmodx\configs folder.
- Change the map or restart your server to start using the plugin!

===========================
Psychostats v1.9.1:
===========================
- This version automatically picks up no scope kills. Nothing is needed on your part.

===========================
Psychostats v3:
===========================
- To get no scope kills to show up in this version, login into an admin account. Now under
  "configuration", click "weapons". You will need to add three new entries here by clicking the
  "new" button. The first Unique ID will be NoScopeKar, second NoScopeSpring, lastly
  NoScopeEnfield. The other options are up to you and how your PsychoStats are set up.

===========================
Support
===========================
Visit the AMXMODX Plugins section of the forums @ 
http:www.dodplugins.net or http:www.rivurs.com

===========================
License
===========================
Syn's No Scope Notifier
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
#include <dodx>
#include <fakemeta>

// =================================================================================================
// Declare global variables and values
// =================================================================================================
new noscope_kills[33]
new players_zoomed[33]
new Float:attacker_victim_distance
new attacker_victim_distance_holder
new final_distance[6]
new hit_place[8][16] = { "general","head","chest","stomach","left arm","right arm","left leg","right arm" }
new player_regular_kills[33]
new player_killer_name_small_hud[33]
new player_victim_name_small_hud[33]
new player_id
new nill
new nill_char[1]
new weapon_id_shot
new weapon_clip_shot
new weapon_ammo_holder_shot[33]
new TA_holder
new user_final_score[33]
new user_final_name[33][33]
new user_final_authid[33][33]
new stat_userid[33]
new stat_teams[33]
new stat_team[16]
new stat_team_atk[16]
new stat_team_vic[16]
new attacker_origin[3]
new victim_origin[3]
new record_names[3][65] // Holds top three record holder names
new record_distances[3] // Holds top three record shots
new current_names[3][65] // Holds top three tempoarry record holder names for the currently played map
new current_distances[3] // Holds top three temporary record shots for the currently played map

new pntr_notify
new pntr_notify_type
new pntr_notify_small_time
new pntr_notify_large_time
new pntr_notify_tk_notify
new pntr_notify_mirror_chat
new pntr_notify_chat
new pntr_notify_say
new pntr_notify_distance
new pntr_notify_distance_type
new pntr_notify_hitbox
new pntr_notify_block_scope
new pntr_notify_block_notify
new pntr_logging
new pntr_record
new pntr_round
new pntr_notify_headshot
new pntr_hits_say
new pntr_notify_perc

new total_stats_general[33]
new total_stats_head[33]
new total_stats_chest[33]
new total_stats_stomache[33]
new total_stats_leftarm[33]
new total_stats_rightarm[33]
new total_stats_leftleg[33]
new total_stats_rightleg[33]

new kar_stats_shots[33]
new kar_stats_hits[33]
new kar_stats_kills[33]
new kar_stats_headshots[33]
new kar_stats_tks[33]
new kar_stats_damage[33]
new kar_stats_deaths[33]
new kar_stats_head[33]
new kar_stats_chest[33]
new kar_stats_stomache[33]
new kar_stats_leftarm[33]
new kar_stats_rightarm[33]
new kar_stats_leftleg[33]
new kar_stats_rightleg[33]

new spring_stats_shots[33]
new spring_stats_hits[33]
new spring_stats_kills[33]
new spring_stats_headshots[33]
new spring_stats_tks[33]
new spring_stats_damage[33]
new spring_stats_deaths[33]
new spring_stats_head[33]
new spring_stats_chest[33]
new spring_stats_stomache[33]
new spring_stats_leftarm[33]
new spring_stats_rightarm[33]
new spring_stats_leftleg[33]
new spring_stats_rightleg[33]

new enfield_stats_shots[33]
new enfield_stats_hits[33]
new enfield_stats_kills[33]
new enfield_stats_headshots[33]
new enfield_stats_tks[33]
new enfield_stats_damage[33]
new enfield_stats_deaths[33]
new enfield_stats_head[33]
new enfield_stats_chest[33]
new enfield_stats_stomache[33]
new enfield_stats_leftarm[33]
new enfield_stats_rightarm[33]
new enfield_stats_leftleg[33]
new enfield_stats_rightleg[33]

// =================================================================================================
// Plugin init
// =================================================================================================
public plugin_init() {
	register_plugin("Syn's No Scope Notifier","2.001","«Synthetiç» www.rivurs.com")
	register_cvar("Syns_No_Scope_Notifier", "v2.001 www.rivurs.com",FCVAR_SERVER|FCVAR_SPONLY)
	pntr_notify = register_cvar("no_scope_notify","1")
	pntr_notify_type = register_cvar("no_scope_notify_type","0")
	pntr_notify_small_time = register_cvar("no_scope_notify_small_time","0")
	pntr_notify_large_time = register_cvar("no_scope_notify_large_time","3.0")
	pntr_notify_tk_notify = register_cvar("no_scope_notify_tk_notify","0")
	pntr_notify_mirror_chat = register_cvar("no_scope_notify_mirror_chat","0")
	pntr_notify_chat = register_cvar("no_scope_notify_chat","0")
	pntr_notify_say = register_cvar("no_scope_notify_say","1")
	pntr_notify_distance = register_cvar("no_scope_notify_distance","1")
	pntr_notify_distance_type = register_cvar("no_scope_notify_distance_type","0")
	pntr_notify_hitbox = register_cvar("no_scope_notify_hitbox","1")
	pntr_notify_block_scope = register_cvar("no_scope_notify_block_scope","0")
	pntr_notify_block_notify = register_cvar("no_scope_notify_block_notify","1")
	pntr_logging = register_cvar("no_scope_logging","0")
	pntr_record = register_cvar("no_scope_record","1")
	pntr_round = register_cvar("no_scope_round","1")
	pntr_notify_headshot = register_cvar("no_scope_notify_headshot","1")
	pntr_hits_say = register_cvar("no_scope_hits_say","1")
	pntr_notify_perc = register_cvar("no_scope_percent","1")
	register_clcmd("say /noscopes", "func_no_scope_kills", 0, "Get No Scope Kills")
	register_clcmd("say /noscoperecord","func_no_scope_record",0)
	register_clcmd("say /noscoperound","func_no_scope_round",0)
	register_clcmd("say /noscopehits","func_no_scope_boxes",0)
	register_forward(FM_AlertMessage,"func_block_death_msg")
	register_forward(FM_ClientPutInServer,"func_client_connect")
	register_forward(FM_PlayerPreThink, "func_prethink")
	register_event("CurWeapon","func_mg_reload","b")
	
	set_task(0.1,"func_get_best")
}

// =================================================================================================
// Check if player got a no scope kill and send appropriate notification
// =================================================================================================
public client_damage(attacker,victim,damage,wpnindex,hitplace,TA) {
	new found_slot
	new found_slotc
	new save_records
	new player_temp_killer_name[33]
	new player_temp_victim_name[33]
	
	get_user_origin(attacker,attacker_origin)
	get_user_origin(victim,victim_origin)
	attacker_victim_distance_holder = get_distance(attacker_origin,victim_origin)
	TA_holder = TA
	
	// Keep track of users final score
	if(is_user_connected(attacker))
		user_final_score[attacker] = dod_get_user_score(attacker)
		
	if(is_user_connected(victim))
		user_final_score[victim] = dod_get_user_score(victim)
	
	// Keep track of regular kills
	if(get_user_health(victim) <= 0)
	{	
		if(players_zoomed[attacker] == 1)
		{
			switch(wpnindex)
			{
				case 6,9,35: {
					player_regular_kills[attacker]++
				}
			}
		}
		if(wpnindex != 6 && wpnindex != 9 && wpnindex != 35)
		{
			player_regular_kills[attacker]++
		}
	}
	
	// Detect no scope shots and perform requested operations
	if(players_zoomed[attacker] == 0 && get_user_health(victim) <= 0)
	{
		if(wpnindex == 6 || wpnindex == 9 || wpnindex == 35)
		{
			get_user_name(attacker,player_temp_killer_name,32)
			get_user_name(victim,player_temp_victim_name,32)
			get_user_name(attacker,player_killer_name_small_hud,32)
			get_user_name(victim,player_victim_name_small_hud,32)
				
			// Keep track of total kills by hitbox
			switch(hitplace)
			{
				case 0:{
					total_stats_general[attacker]++
				}
				case 1:{
					total_stats_head[attacker]++
				}
				case 2:{
					total_stats_chest[attacker]++
				}
				case 3:{
					total_stats_stomache[attacker]++
				}
				case 4:{
					total_stats_leftarm[attacker]++
				}
				case 5:{
					total_stats_rightarm[attacker]++
				}
				case 6:{
					total_stats_leftleg[attacker]++
				}
				case 7:{
					total_stats_rightleg[attacker]++
				}
				
			}
				
			// Check for friendly fire
			if(get_cvar_num("mp_friendlyfire") == 1)
			{
				if(TA == 1)
				{
					noscope_kills[attacker] = noscope_kills[attacker] + 0
				}
				if (TA == 0)
				{
					++noscope_kills[attacker]
				}
			}
			else
			{
				++noscope_kills[attacker]
			}
			
			// Check to see if shot beat a record and if so notify and save
			if(record_distances[0] < attacker_victim_distance_holder && get_pcvar_num(pntr_record))
			{
				// Organize record arrays if needed
				if(record_distances[0] > 0)
				{
					format(record_names[2],64,"%s",record_names[1])
					record_distances[2] = record_distances[1]
					
					format(record_names[1],64,"%s",record_names[0])
					record_distances[1] = record_distances[0]
				}
				// Update record array and notify
				format(record_names[0],63,"%s",player_temp_killer_name)
				record_distances[0] = attacker_victim_distance_holder
				if(get_pcvar_num(pntr_notify_distance_type) == 0)
				{
					func_shot_notification(0,attacker_victim_distance_holder,nill_char,player_killer_name_small_hud,14,2,nill)
				}
				else
				{
					func_shot_notification(0,attacker_victim_distance_holder,nill_char,player_killer_name_small_hud,13,2,nill)
				}
				found_slot = 1
				save_records = 1
			}
			if(record_distances[1] < attacker_victim_distance_holder && get_pcvar_num(pntr_record) && !found_slot)
			{
				// Organize record arrays if needed
				if(record_distances[1] > 0)
				{
					format(record_names[2],64,"%s",record_names[1])
					record_distances[2] = record_distances[1]
					found_slot = 1
				}
				// Update record array and notify
				format(record_names[1],63,"%s",player_temp_killer_name)
				record_distances[1] = attacker_victim_distance_holder
				if(get_pcvar_num(pntr_notify_distance_type) == 0)
				{
					func_shot_notification(0,attacker_victim_distance_holder,nill_char,player_killer_name_small_hud,16,2,nill)
				}
				else
				{
					func_shot_notification(0,attacker_victim_distance_holder,nill_char,player_killer_name_small_hud,15,2,nill)
				}
				found_slot = 1
				save_records = 1
			}
			if(record_distances[2] < attacker_victim_distance_holder && get_pcvar_num(pntr_record)  && !found_slot)
			{
				// Update record array and notify
				format(record_names[2],63,"%s",player_temp_killer_name)
				record_distances[2] = attacker_victim_distance_holder
				if(get_pcvar_num(pntr_notify_distance_type) == 0)
				{
					func_shot_notification(0,attacker_victim_distance_holder,nill_char,player_killer_name_small_hud,18,2,nill)
				}
				else
				{
					func_shot_notification(0,attacker_victim_distance_holder,nill_char,player_killer_name_small_hud,17,2,nill)
				}
				save_records = 1
			}
				
			// Save record shots anytime a record is broken
			if(save_records && get_pcvar_num(pntr_record))
			{
				new file_name[129]
				new config_dir[33]
				new map_name[33]
				new rec_dir[96]
				
				get_mapname(map_name,32)
				get_configsdir(config_dir,32)
				format(file_name,128,"%s/no_scope/%s.ini",config_dir,map_name)
				format(rec_dir,95,"%s/no_scope",config_dir)
				
				// Create definition file
				if(dir_exists(rec_dir))
				{
					new file = fopen(file_name,"w")
					// Write records
					fprintf(file,"%s^n",record_names[0])
					fprintf(file,"%i^n",record_distances[0])
					fprintf(file,"%s^n",record_names[1])
					fprintf(file,"%i^n",record_distances[1])
					fprintf(file,"%s^n",record_names[2])
					fprintf(file,"%i^n",record_distances[2])
					
					fclose(file)
				}
			}
			// Check to see if shot beat a temp record and if so notify and save
			if(current_distances[0] < attacker_victim_distance_holder && get_pcvar_num(pntr_round))
			{
				// Organize record arrays if needed
				if(current_distances[0] > 0)
				{
					format(current_names[2],64,"%s",current_names[1])
					current_distances[2] = current_distances[1]
					
					format(current_names[1],64,"%s",current_names[0])
					current_distances[1] = current_distances[0]
				}
				// Update record array and notify
				format(current_names[0],63,"%s",player_temp_killer_name)
				current_distances[0] = attacker_victim_distance_holder
				found_slotc = 1
			}
			if(current_distances[1] < attacker_victim_distance_holder && get_pcvar_num(pntr_round) && !found_slotc)
			{
				// Organize record arrays if needed
				if(current_distances[1] > 0)
				{
					format(current_names[2],64,"%s",current_names[1])
					current_distances[2] = current_distances[1]
					found_slot = 1
				}
				// Update record array and notify
				format(current_names[1],63,"%s",player_temp_killer_name)
				current_distances[1] = attacker_victim_distance_holder
				found_slotc = 1
			}
			if(current_distances[2] < attacker_victim_distance_holder && get_pcvar_num(pntr_round)  && !found_slotc)
			{
				// Update record array and notify
				format(current_names[2],63,"%s",player_temp_killer_name)
				current_distances[2] = attacker_victim_distance_holder
			}
				
			if (get_pcvar_num(pntr_notify) == 1)
			{
				// Display no scope headshot HUD display message if enabled
				if (get_pcvar_num(pntr_notify_headshot) && hitplace == 1)
				{
					set_hudmessage(0,155,255, -1.0, 0.36, 2, 0.02,get_pcvar_float(pntr_notify_large_time),0.01,0.1,-1) 
					show_hudmessage(0,"%s just fired a no scope shot right into %s's head!",player_temp_killer_name,player_temp_victim_name)
				}
				
				// Let's print small hud message of a no scope kill
				if(get_pcvar_num(pntr_notify_type) == 0)
				{
					// Let's show no scope team kill notification with meters distance info
					if(get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 0 && get_pcvar_num(pntr_notify_hitbox) == 0 && get_pcvar_num(pntr_notify_tk_notify) == 1 && TA == 1)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,8,1,nill)
					}
					// Let's show no scope kill notification with meters distance info
					if(get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 0 && get_pcvar_num(pntr_notify_hitbox) == 0 && TA == 0)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,2,1,nill)
					}
					// Let's show no scope team kill notification with foot distance info
					if (get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 1 && get_pcvar_num(pntr_notify_hitbox) == 0 && get_pcvar_num(pntr_notify_tk_notify) == 1 && TA == 1)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,9,1,nill)
					}
					// Let's show no scope kill notification with foot distance info
					if (get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 1 && get_pcvar_num(pntr_notify_hitbox) == 0 && TA == 0)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,3,1,nill)
					}
					// Let's show no scope team kill notification with hitbox and meters distance info
					if (get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 0 && get_pcvar_num(pntr_notify_hitbox) == 1 && get_pcvar_num(pntr_notify_tk_notify) == 1 && TA == 1)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,12,1,hitplace)
					}
					// Let's show no scope kill notification with hitbox and meters distance info
					if (get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 0 && get_pcvar_num(pntr_notify_hitbox) == 1 && TA == 0)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,6,1,hitplace)
					}
					// Let's show no scope team kill notification with hitbox and foot distance info
					if (get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 1 && get_pcvar_num(pntr_notify_hitbox) == 1 && get_pcvar_num(pntr_notify_tk_notify) == 1 && TA == 1)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,11,1,hitplace)
					}
					// Let's show no scope kill notification with hitbox and foot distance info
					if (get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 1 && get_pcvar_num(pntr_notify_hitbox) == 1 && TA == 0)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,5,1,hitplace)
					}
					// Let's show no scope team kill notification with hitbox info
					if (get_pcvar_num(pntr_notify_distance) == 0 && get_pcvar_num(pntr_notify_distance_type) == 0 && get_pcvar_num(pntr_notify_hitbox) == 1 && get_pcvar_num(pntr_notify_tk_notify) == 1 && TA == 1)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,10,1,hitplace)
					}
					// Let's show no scope kill notification with hitbox info
					if (get_pcvar_num(pntr_notify_distance) == 0 && get_pcvar_num(pntr_notify_distance_type) == 0 && get_pcvar_num(pntr_notify_hitbox) == 1 && TA == 0)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,4,1,hitplace)
					}
					// Let's show no scope team kill notification with no extra info
					if (get_pcvar_num(pntr_notify_distance) == 0 && get_pcvar_num(pntr_notify_hitbox) == 0 && get_pcvar_num(pntr_notify_tk_notify) == 1 && TA == 1)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,7,1,nill)
					}
					// Let's show no scope kill notification with no extra info
					if (get_pcvar_num(pntr_notify_distance) == 0 && get_pcvar_num(pntr_notify_hitbox) == 0 && TA == 0)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,1,1,nill)
					}
				
					switch(get_pcvar_num(pntr_notify_small_time))
					{
						case 1:{
							set_task(1.0,"func_small_hud_timer",1,"",0,"a",1)
						}
						case 2:{
							set_task(2.0,"func_small_hud_timer",1,"",0,"a",2)
						}
						case 3:{
							set_task(3.0,"func_small_hud_timer",1,"",0,"a",3)
						}
					}
				}
				// Let's print large hud message of a no scope kill
				else if (get_pcvar_num(pntr_notify_type) == 1)
				{
					// Let's show no scope team kill notification with meters distance info
					if (get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 0 && get_pcvar_num(pntr_notify_hitbox) == 0 && get_pcvar_num(pntr_notify_tk_notify) == 1 && TA == 1)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,8,3,nill)
					}
					// Let's show no scope kill notification with meters distance info
					if (get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 0 && get_pcvar_num(pntr_notify_hitbox) == 0 && TA == 0)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,2,3,nill)
					}
					
					// Let's show no scope team kill notification with foot distance info
					if (get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 1 && get_pcvar_num(pntr_notify_hitbox) == 0 && get_pcvar_num(pntr_notify_tk_notify) == 1 && TA == 1)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,9,3,nill)
					}
					// Let's show no scope kill notification with foot distance info
					if (get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 1 && get_pcvar_num(pntr_notify_hitbox) == 0 && TA == 0)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,3,3,nill)
					}
					// Let's show no scope team kill notification with hitbox and meters distance info
					if (get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 0 && get_pcvar_num(pntr_notify_hitbox) == 1 && get_pcvar_num(pntr_notify_tk_notify) == 1 && TA == 1)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,12,3,hitplace)
					}
					// Let's show no scope kill notification with hitbox and meters distance info
					if (get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 0 && get_pcvar_num(pntr_notify_hitbox) == 1 && TA == 0)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,6,3,hitplace)
					}
					// Let's show no scope team kill notification with hitbox and foot distance info
					if (get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 1 && get_pcvar_num(pntr_notify_hitbox) == 1 && get_pcvar_num(pntr_notify_tk_notify) == 1 && TA == 1)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,11,3,hitplace)
					}
					// Let's show no scope kill notification with hitbox and foot distance info
					if (get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 1 && get_pcvar_num(pntr_notify_hitbox) == 1 && TA == 0)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,5,3,hitplace)
					}
					// Let's show no scope team kill notification with hitbox info
					if (get_pcvar_num(pntr_notify_distance) == 0 && get_pcvar_num(pntr_notify_distance_type) == 0 && get_pcvar_num(pntr_notify_hitbox) == 1 && get_pcvar_num(pntr_notify_tk_notify) == 1 && TA == 1)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,10,3,hitplace)
					}
					// Let's show no scope kill notification with hitbox info
					if (get_pcvar_num(pntr_notify_distance) == 0 && get_pcvar_num(pntr_notify_distance_type) == 0 && get_pcvar_num(pntr_notify_hitbox) == 1 && TA == 0)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,4,3,hitplace)
					}
					// Let's show no scope team kill notification with no extra info
					if (get_pcvar_num(pntr_notify_distance) == 0 && get_pcvar_num(pntr_notify_hitbox) == 0 && get_pcvar_num(pntr_notify_tk_notify) == 1 && TA == 1)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,7,3,nill)
					}
					// Let's show no scope kill notification with no extra info
					if (get_pcvar_num(pntr_notify_distance) == 0 && get_pcvar_num(pntr_notify_hitbox) == 0 && TA == 0)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,1,3,nill)
					}
				}
				// Let's print no scope kill in chat
				else if (get_pcvar_num(pntr_notify_type) == 2 || get_pcvar_num(pntr_notify_mirror_chat))
				{
					// Let's show no scope team kill notification with meters distance info
					if (get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 0 && get_pcvar_num(pntr_notify_hitbox) == 0 && get_pcvar_num(pntr_notify_tk_notify) == 1 && TA == 1)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,8,2,nill)
					}
					// Let's show no scope kill notification with meters distance info
					if (get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 0 && get_pcvar_num(pntr_notify_hitbox) == 0 && TA == 0)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,2,2,nill)
					}
					// Let's show no scope team kill notification with foot distance info
					if (get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 1 && get_pcvar_num(pntr_notify_hitbox) == 0 && get_pcvar_num(pntr_notify_tk_notify) == 1 && TA == 1)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,9,2,nill)
					}
					// Let's show no scope kill notification with foot distance info
					if (get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 1 && get_pcvar_num(pntr_notify_hitbox) == 0 && TA == 0)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,3,2,nill)
					}
					// Let's show no scope team kill notification with hitbox and meters distance info
					if (get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 0 && get_pcvar_num(pntr_notify_hitbox) == 1 && get_pcvar_num(pntr_notify_tk_notify) == 1 && TA == 1)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,12,2,hitplace)
					}
					// Let's show no scope kill notification with hitbox and meters distance info
					if (get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 0 && get_pcvar_num(pntr_notify_hitbox) == 1 && TA == 0)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,6,2,hitplace)
					}
					// Let's show no scope team kill notification with hitbox and foot distance info
					if (get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 1 && get_pcvar_num(pntr_notify_hitbox) == 1 && get_pcvar_num(pntr_notify_tk_notify) == 1 && TA == 1)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,11,2,hitplace)
					}
					// Let's show no scope kill notification with hitbox and foot distance info
					if (get_pcvar_num(pntr_notify_distance) == 1 && get_pcvar_num(pntr_notify_distance_type) == 1 && get_pcvar_num(pntr_notify_hitbox) == 1 && TA == 0)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,5,2,hitplace)
					}
					// Let's show no scope team kill notification with hitbox info
					if (get_pcvar_num(pntr_notify_distance) == 0 && get_pcvar_num(pntr_notify_distance_type) == 0 && get_pcvar_num(pntr_notify_hitbox) == 1 && get_pcvar_num(pntr_notify_tk_notify) == 1 && TA == 1)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,10,2,hitplace)
					}
					// Let's show no scope kill notification with hitbox info
					if (get_pcvar_num(pntr_notify_distance) == 0 && get_pcvar_num(pntr_notify_distance_type) == 0 && get_pcvar_num(pntr_notify_hitbox) == 1 && TA == 0)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,4,2,hitplace)
					}
					// Let's show no scope team kill notification with no extra info
					if (get_pcvar_num(pntr_notify_distance) == 0 && get_pcvar_num(pntr_notify_hitbox) == 0 && get_pcvar_num(pntr_notify_tk_notify) == 1 && TA == 1)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,7,2,nill)
					}
					// Let's show no scope kill notification with no extra info
					if (get_pcvar_num(pntr_notify_distance) == 0 && get_pcvar_num(pntr_notify_hitbox) == 0 && TA == 0)
					{
						func_shot_notification(0,attacker_victim_distance_holder,player_victim_name_small_hud,player_killer_name_small_hud,1,2,nill)
					}
				}
				
				// Lets keep track of damage/hit/kills/heashots/damage/chest/stomache/la/ra/ll/rl detailed stats
				if (get_pcvar_num(pntr_logging) == 1 && TA == 0)
				{
					switch(wpnindex)
					{
						case 6: {
							kar_stats_damage[attacker] = kar_stats_damage[attacker] + damage
							++kar_stats_hits[attacker]
							++kar_stats_kills[attacker]
							
							switch(hitplace)
							{
								case 1:{
									++kar_stats_headshots[attacker]
								}
								case 2:{
									++kar_stats_chest[attacker]
								}
								case 3:{
									++kar_stats_stomache[attacker]
								}
								case 4:{
									++kar_stats_leftarm[attacker]
								}
								case 5:{
									++kar_stats_rightarm[attacker]
								}
								case 6:{
									++kar_stats_leftleg[attacker]
								}
								case 7:{
									++kar_stats_rightleg[attacker]
								}
							}
						}
						case 9: {
							spring_stats_damage[attacker] = spring_stats_damage[attacker] + damage
							++spring_stats_hits[attacker]
							++spring_stats_kills[attacker]
							
							switch(hitplace)
							{
								case 1:{
									++spring_stats_headshots[attacker]
								}
								case 2:{
									++spring_stats_chest[attacker]
								}
								case 3:{
									++spring_stats_stomache[attacker]
								}
								case 4:{
									++spring_stats_leftarm[attacker]
								}
								case 5:{
									++spring_stats_rightarm[attacker]
								}
								case 6:{
									++spring_stats_leftleg[attacker]
								}
								case 7:{
									++spring_stats_rightleg[attacker]
								}
							}
						}
						case 35: {
							enfield_stats_damage[attacker] = enfield_stats_damage[attacker] + damage
							++enfield_stats_hits[attacker]
							++enfield_stats_kills[attacker]
							
							switch(hitplace)
							{
								case 1:{
									++enfield_stats_headshots[attacker]
								}
								case 2:{
									++enfield_stats_chest[attacker]
								}
								case 3:{
									++enfield_stats_stomache[attacker]
								}
								case 4:{
									++enfield_stats_leftarm[attacker]
								}
								case 5:{
									++enfield_stats_rightarm[attacker]
								}
								case 6:{
									++enfield_stats_leftleg[attacker]
								}
								case 7:{
									++enfield_stats_rightleg[attacker]
								}
							}
						}
					}
				}
				// Let's keep track of team kills
				if(TA == 1)
				{
					switch(wpnindex)
					{
						case 6:{
							++kar_stats_tks[attacker]
						}
						case 9:{
							++spring_stats_tks[attacker]
						}
						case 35:{
							++enfield_stats_tks[attacker]
						}
					}
				}
			}
		}
		player_id = attacker
		
		// Let's print in chat the total no scope kills to a player on a no scope kill
		if (get_pcvar_num(pntr_notify_chat) == 1)
		{
			client_print(attacker,print_chat,"No Scope Notifier - You have %d no scope kills!",noscope_kills[attacker])
		}
		
		// Let's log the no scope kill and friendly fire kills
		if (get_pcvar_num(pntr_logging) == 1)
		{
			new temp_atk_name[33],temp_vic_name[33],temp_authid_atk[35],temp_authid_vic[35]
			get_user_name(victim,temp_vic_name,32)
			get_user_name(attacker,temp_atk_name,32)
			get_user_authid(victim,temp_authid_vic,34)
			get_user_authid(attacker,temp_authid_atk,34)
			switch(stat_teams[attacker])
			{
				case 1:{
					format(stat_team_atk,15,"Allies")
				}
				case 2:{
					format(stat_team_atk,15,"Axis")
				}
			}
			switch(stat_teams[victim])
			{
				case 1:{
					format(stat_team_vic,15,"Allies")
				}
				case 2:{
					format(stat_team_vic,15,"Axis")
				}
			}
			switch(wpnindex)
			{
				case 6:{
					log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"NoScopeKar^"",temp_atk_name,get_user_userid(attacker),temp_authid_atk,stat_team_atk,temp_vic_name,get_user_userid(victim),temp_authid_vic,stat_team_vic)
				}
				case 9:{
					log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"NoScopeSpring^"",temp_atk_name,get_user_userid(attacker),temp_authid_atk,stat_team_atk,temp_vic_name,get_user_userid(victim),temp_authid_vic,stat_team_vic)
				}
				case 35:{
					log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"NoScopeEnfield^"",temp_atk_name,get_user_userid(attacker),temp_authid_atk,stat_team_atk,temp_vic_name,get_user_userid(victim),temp_authid_vic,stat_team_vic)
				}
			}
		}
	}
	// Let's keep track of non kill damage/hit/head/chest/stomache/la/ra/ll/rl detailed stats
	if(players_zoomed[attacker] == 0 && get_user_health(victim) > 0)
	{
		if(get_pcvar_num(pntr_logging) == 1 && TA == 0) 
		{
			switch(wpnindex)
			{
				case 6: {
					kar_stats_damage[attacker] = kar_stats_damage[attacker] + damage
					++kar_stats_hits[attacker]
					switch(hitplace)
					{
						case 1:{
							++kar_stats_head[attacker]
						}
						case 2:{
							++kar_stats_chest[attacker]
						}
						case 3:{
							++kar_stats_stomache[attacker]
						}
						case 4:{
							++kar_stats_leftarm[attacker]
						}
						case 5:{
							++kar_stats_rightarm[attacker]
						}
						case 6:{
							++kar_stats_leftleg[attacker]
						}
						case 7:{
							++kar_stats_rightleg[attacker]
						}
					}
				}
				case 9: {
					spring_stats_damage[attacker] = spring_stats_damage[attacker] + damage
					++spring_stats_hits[attacker]
					switch(hitplace)
					{
						case 1:{
							++spring_stats_head[attacker]
						}
						case 2:{
							++spring_stats_chest[attacker]
						}
						case 3:{
							++spring_stats_stomache[attacker]
						}
						case 4:{
							++spring_stats_leftarm[attacker]
						}
						case 5:{
							++spring_stats_rightarm[attacker]
						}
						case 6:{
							++spring_stats_leftleg[attacker]
						}
						case 7:{
							++spring_stats_rightleg[attacker]
						}
					}
				}
				case 35: {
					enfield_stats_damage[attacker] = enfield_stats_damage[attacker] + damage
					++enfield_stats_hits[attacker]
					switch(hitplace)
					{
						case 1:{
							++enfield_stats_head[attacker]
						}
						case 2:{
							++enfield_stats_chest[attacker]
						}
						case 3:{
							++enfield_stats_stomache[attacker]
						}
						case 4:{
							++enfield_stats_leftarm[attacker]
						}
						case 5:{
							++enfield_stats_rightarm[attacker]
						}
						case 6:{
							++enfield_stats_leftleg[attacker]
						}
						case 7:{
							++enfield_stats_rightleg[attacker]
						}
					}
				}
			}
		}
	}
	// Let's keep track of a no scope killer's deaths
	if(is_user_connected(victim) && players_zoomed[victim] == 0 && get_user_health(victim) <= 0)
	{
		new death_clip
		new death_ammo
		new death_weapon
		if(is_user_connected(victim))
			death_weapon = dod_get_user_weapon(victim,death_clip,death_ammo)
			
		switch(death_weapon)
		{
			case 6: {
				++kar_stats_deaths[victim]
			}
			case 9: {
				++spring_stats_deaths[victim]
			}
			case 35: {
				++enfield_stats_deaths[victim]
			}
		}
	}
	// Keep track of score
	if(is_user_connected(attacker))
		user_final_score[attacker] = dod_get_user_score(attacker)
		
	return PLUGIN_HANDLED
}
// =================================================================================================
// Detect shots and FOV
// =================================================================================================
public func_prethink(id) {
	
	if(!is_user_connected(id))
		return FMRES_IGNORED 
	
	if(get_pcvar_num(pntr_logging))
	{
		if(pev(id,pev_button) & IN_ATTACK && pev(id,pev_oldbuttons) & IN_ATTACK)
		{
			weapon_id_shot = dod_get_user_weapon(id,weapon_clip_shot,nill)
			if (weapon_clip_shot != 0 && weapon_clip_shot != weapon_ammo_holder_shot[id] && players_zoomed[id] == 0)
			{
				weapon_ammo_holder_shot[id] = weapon_clip_shot
				switch(weapon_id_shot) {
					case 6: {
						++kar_stats_shots[id]
					}
					case 9: {
						++spring_stats_shots[id]
					}
					case 35: {
						++enfield_stats_shots[id]
					}
				}
			}
		}
	}
	// Store FOV
	players_zoomed[id] = pev(id,pev_fov)
	
	// Store a player's team
	stat_teams[id] = pev(id,pev_team)
	
	// Block scoped shots
	if(get_pcvar_num(pntr_notify_block_scope) && players_zoomed[id] > 0)
	{
		new morenill,morenull
		new wpnindex = get_user_weapon(id,morenill,morenull)
		
		switch(wpnindex) {
			case 6,9,35: {
				if(pev(id,pev_button) & IN_ATTACK && pev(id,pev_oldbuttons) & IN_ATTACK)
				{
					if (get_pcvar_num(pntr_notify) && get_pcvar_num(pntr_notify_block_notify))
					{
						set_hudmessage(255,255,255, -1.0, 0.32, 2, 0.02,5.0, 0.01, 0.1, 2) 
						show_hudmessage(id,"No Scope mod is running! All shots are blocked while scoped!")
						set_pev(id, pev_button,pev(id,pev_button) & ~IN_ATTACK)
					}
				}
			}
		}
	}
	return FMRES_HANDLED
}


// =================================================================================================
// Say command for a player to get his no scope kills and no scope kill to regular kill percentage
// =================================================================================================
public func_no_scope_kills(id) {
	new Float:noscope_ratio
	new noscope_ratio_holder[4]
	
	if (get_pcvar_num(pntr_notify_say) == 1)
	{
		if (noscope_kills[id] == 1)
		{
			client_print(id,print_chat,"[No Scope Notifier] You have %d no scope kill!",noscope_kills[id])
			if(get_pcvar_num(pntr_notify_perc))
			{
				if(noscope_kills[id] > 0 && player_regular_kills[id] > 0)
				{
					noscope_ratio = floatdiv(float(noscope_kills[id]),float(player_regular_kills[id]))
					float_to_str(noscope_ratio,noscope_ratio_holder,4)
					client_print(id,print_chat,"[No Scope Notifier] Your no scope kill to regular kill ratio is: %s",noscope_ratio_holder)
				}
				if(noscope_kills[id] > 0 && player_regular_kills[id] == 0)
				{
					client_print(id,print_chat,"[No Scope Notifier] Your no scope kill to regular kill ratio is: %i",noscope_kills[id])
				}
				if(noscope_kills[id] == 0 && player_regular_kills[id] > 1)
				{
					noscope_ratio = floatdiv(float(1),float(player_regular_kills[id]))
					float_to_str(noscope_ratio,noscope_ratio_holder,4)
					client_print(id,print_chat,"[No Scope Notifier] Your no scope kill to regular kill ratio is: %s",noscope_ratio_holder)
				}
			}
		}
		else
		{
			client_print(id,print_chat,"[No Scope Notifier] You have %d no scope kills!",noscope_kills[id])
			if(get_pcvar_num(pntr_notify_perc))
			{
				if(noscope_kills[id] > 0 && player_regular_kills[id] > 0)
				{
					noscope_ratio = floatdiv(float(noscope_kills[id]),float(player_regular_kills[id]))
					float_to_str(noscope_ratio,noscope_ratio_holder,4)
					client_print(id,print_chat,"[No Scope Notifier] Your no scope kill to regular kill ratio is: %s",noscope_ratio_holder)
				}
				if(noscope_kills[id] > 0 && player_regular_kills[id] == 0)
				{
					client_print(id,print_chat,"[No Scope Notifier] Your no scope kill to regular kill ratio is: %i",noscope_kills[id])
				}
				if(noscope_kills[id] == 0 && player_regular_kills[id] > 1)
				{
					noscope_ratio = floatdiv(float(1),float(player_regular_kills[id]))
					float_to_str(noscope_ratio,noscope_ratio_holder,4)
					client_print(id,print_chat,"[No Scope Notifier] Your no scope kill to regular kill ratio is: %s",noscope_ratio_holder)
				}
			}
		}
	}
}

// =================================================================================================
// Say command for a player to get their no scope kill hit box specific stats
// =================================================================================================
public func_no_scope_boxes(id) {
	if (get_pcvar_num(pntr_hits_say) == 1)
	{
		client_print(id,print_chat,"[No Scope Notifier] General: %i | Head: %i | Chest: %i | Stomace: %i | Left arm: %i | Right arm: %i | Left leg: %i | Right leg: %i",total_stats_general[id],total_stats_head[id],total_stats_chest[id],total_stats_stomache[id],total_stats_leftarm[id],total_stats_rightarm[id],total_stats_leftleg[id],total_stats_rightleg[id])
	}
}

// =================================================================================================
// Show small hud no scope kill notification
// =================================================================================================
public func_small_hud_timer() {
	if (get_pcvar_num(pntr_notify_tk_notify) == 1 && TA_holder == 1)
	{
		client_print(0,print_center,"%s just got no scoped by teammate %s!",player_victim_name_small_hud,player_killer_name_small_hud)
	}
	if (TA_holder == 0)
	{
		client_print(0,print_center,"%s just got no scoped by %s!",player_victim_name_small_hud,player_killer_name_small_hud)
	}
}

// =================================================================================================
// Fix non deployed mg reload message
// =================================================================================================
public func_mg_reload(id) {
	new mg_type,clip,ammo
	if (is_user_connected(id) == 1)
	{
		mg_type = dod_get_user_weapon(id,clip,ammo)
	}
	if (mg_type == 18 || mg_type == 17 || mg_type == 21)
	{
		client_print(id,print_center,"                                                                                        ")
	}
}

// =================================================================================================
// Reset no scope score and detailed stats if new player takes previously used id number
// =================================================================================================
public func_client_connect(id) {
	
	noscope_kills[id] = 0
	
	total_stats_general[id] = 0
	total_stats_head[id] = 0
	total_stats_chest[id] = 0
	total_stats_stomache[id] = 0
	total_stats_leftarm[id] = 0
	total_stats_rightarm[id] = 0
	total_stats_leftleg[id] = 0
	total_stats_rightleg[id] = 0
	
	kar_stats_shots[id] = -1
	kar_stats_hits[id] = 0
	kar_stats_kills[id] = 0
	kar_stats_headshots[id] = 0
	kar_stats_tks[id] = 0
	kar_stats_damage[id] = 0
	kar_stats_deaths[id] = 0
	kar_stats_head[id] = 0
	kar_stats_chest[id] = 0
	kar_stats_stomache[id] = 0
	kar_stats_leftarm[id] = 0
	kar_stats_rightarm[id] = 0
	kar_stats_leftleg[id] = 0
	kar_stats_rightleg[id] = 0
	
	spring_stats_shots[id] = -1
	spring_stats_hits[id] = 0
	spring_stats_kills[id] = 0
	spring_stats_headshots[id] = 0
	spring_stats_tks[id] = 0
	spring_stats_damage[id] = 0
	spring_stats_deaths[id] = 0
	spring_stats_head[id] = 0
	spring_stats_chest[id] = 0
	spring_stats_stomache[id] = 0
	spring_stats_leftarm[id] = 0
	spring_stats_rightarm[id] = 0
	spring_stats_leftleg[id] = 0
	spring_stats_rightleg[id] = 0
	
	enfield_stats_shots[id] = -1
	enfield_stats_hits[id] = 0
	enfield_stats_kills[id] = 0
	enfield_stats_headshots[id] = 0
	enfield_stats_tks[id] = 0
	enfield_stats_damage[id] = 0
	enfield_stats_deaths[id] = 0
	enfield_stats_head[id] = 0
	enfield_stats_chest[id] = 0
	enfield_stats_stomache[id] = 0
	enfield_stats_leftarm[id] = 0
	enfield_stats_rightarm[id] = 0
	enfield_stats_leftleg[id] = 0
	enfield_stats_rightleg[id] = 0
}

// =================================================================================================
// Block log message for no scope kills
// =================================================================================================
public func_block_death_msg(a,msg[]) {
	if (get_pcvar_num(pntr_logging) == 1)
	{
		new temp_user_name[33]
		get_user_name(player_id,temp_user_name,32)
		if (contain(msg,temp_user_name) > 0 && players_zoomed[player_id] == 0)
		{
			if (contain(msg, ">^" with ^"scopedkar^"") > 0 || contain(msg, ">^" with ^"spring^"") > 0 || contain(msg, ">^" with ^"scoped_enfield^"") > 0 )
			{
				return FMRES_SUPERCEDE
			}
		}
	}
	return FMRES_IGNORED
}

// =================================================================================================
// Log detailed stats
// =================================================================================================
public client_disconnect(id) {
	if (get_pcvar_num(pntr_logging) == 1)
	{
		get_user_name(id,user_final_name[id],32)
		get_user_authid(id,user_final_authid[id],32)
		stat_userid[id] = get_user_userid(id)
		
		switch(stat_teams[id]) {
			case 1: {
				format(stat_team,15,"Allies")
			}
			case 2: {
				format(stat_team,15,"Axis")
			}
		}

		if (kar_stats_shots[id] > 0)
		{
			log_message("^"%s<%d><%s><%s>^" triggered ^"weaponstats^" (weapon ^"NoScopeKar^") (shots ^"%d^") (hits ^"%d^") (kills ^"%d^") (headshots ^"%d^") (tks ^"%d^") (damage ^"%d^") (deaths ^"%d^") (score ^"%d^")",
			user_final_name[id],stat_userid[id],user_final_authid[id],stat_team,kar_stats_shots[id],kar_stats_hits[id],kar_stats_kills[id], kar_stats_headshots[id],kar_stats_tks[id],kar_stats_damage[id],kar_stats_deaths[id],user_final_score[id])
			log_message("^"%s<%d><%s><%s>^" triggered ^"weaponstats2^" (weapon ^"NoScopeKar^") (head ^"%d^") (chest ^"%d^") (stomach ^"%d^") (leftarm ^"%d^") (rightarm ^"%d^") (leftleg ^"%d^") (rightleg ^"%d^")",
			user_final_name[id],stat_userid[id],user_final_authid[id],stat_team,kar_stats_head[id]+kar_stats_headshots[id],kar_stats_chest[id],kar_stats_stomache[id],kar_stats_leftarm[id],kar_stats_rightarm[id],kar_stats_leftleg[id],kar_stats_rightleg[id])
		}
		if (spring_stats_shots[id] > 0)
		{
			log_message("^"%s<%d><%s><%s>^" triggered ^"weaponstats^" (weapon ^"NoScopeSpring^") (shots ^"%d^") (hits ^"%d^") (kills ^"%d^") (headshots ^"%d^") (tks ^"%d^") (damage ^"%d^") (deaths ^"%d^") (score ^"%d^")",
			user_final_name[id],stat_userid[id],user_final_authid[id],stat_team,spring_stats_shots[id],spring_stats_hits[id],spring_stats_kills[id], spring_stats_headshots[id],spring_stats_tks[id],spring_stats_damage[id],spring_stats_deaths[id],user_final_score[id])
			log_message("^"%s<%d><%s><%s>^" triggered ^"weaponstats2^" (weapon ^"NoScopeSpring^") (head ^"%d^") (chest ^"%d^") (stomach ^"%d^") (leftarm ^"%d^") (rightarm ^"%d^") (leftleg ^"%d^") (rightleg ^"%d^")",
			user_final_name[id],stat_userid[id],user_final_authid[id],stat_team,spring_stats_head[id]+spring_stats_headshots[id],spring_stats_chest[id],spring_stats_stomache[id],spring_stats_leftarm[id],spring_stats_rightarm[id],spring_stats_leftleg[id],spring_stats_rightleg[id])
		}
		if (enfield_stats_shots[id] > 0)
		{
			log_message("^"%s<%d><%s><%s>^" triggered ^"weaponstats^" (weapon ^"NoScopeEnfield^") (shots ^"%d^") (hits ^"%d^") (kills ^"%d^") (headshots ^"%d^") (tks ^"%d^") (damage ^"%d^") (deaths ^"%d^") (score ^"%d^")",
			user_final_name[id],stat_userid[id],user_final_authid[id],stat_team,enfield_stats_shots[id],enfield_stats_hits[id],enfield_stats_kills[id], enfield_stats_headshots[id],enfield_stats_tks[id],enfield_stats_damage[id],enfield_stats_deaths[id],user_final_score[id])
			log_message("^"%s<%d><%s><%s>^" triggered ^"weaponstats2^" (weapon ^"NoScopeEnfield^") (head ^"%d^") (chest ^"%d^") (stomach ^"%d^") (leftarm ^"%d^") (rightarm ^"%d^") (leftleg ^"%d^") (rightleg ^"%d^")",
			user_final_name[id],stat_userid[id],user_final_authid[id],stat_team,enfield_stats_head[id]+enfield_stats_headshots[id],enfield_stats_chest[id],enfield_stats_stomache[id],enfield_stats_leftarm[id],enfield_stats_rightarm[id],enfield_stats_leftleg[id],enfield_stats_rightleg[id])
		}
	}
}

// =================================================================================================
// Get best shot stats
// =================================================================================================
public func_get_best(id) {
	new file_name[129]
	new config_dir[33]
	new map_name[33]
	
	if(get_pcvar_num(pntr_record))
	{
		get_mapname(map_name,32)
		get_configsdir(config_dir,32)
		format(file_name,128,"%s/no_scope/%s.ini",config_dir,map_name)
	
		// Load map records file if it exists
		if(file_exists(file_name))
		{
			new temp_holder[65]
			new file = fopen(file_name,"rt")
			new total_lines
	
			// Load names into array
			while(!feof(file) && total_lines < 3)
			{
				fgets(file,temp_holder,64)
				replace(temp_holder,64,"^n","")
				format(record_names[total_lines],64,"%s",temp_holder)
				
				fgets(file,temp_holder,64)
				replace(temp_holder,64,"^n","")
				record_distances[total_lines] = str_to_num(temp_holder)
				
				total_lines++
			}
			fclose(file)
		}
	}
}

// =================================================================================================
// Display best no scope shot info
// =================================================================================================
public func_no_scope_record(id) {
	if(get_pcvar_num(pntr_record))
	{
		if (get_pcvar_num(pntr_notify_distance_type) == 0)
		{
			if(record_distances[0] > 0)
			{
				func_shot_notification(id,record_distances[0],nill_char,record_names[0],19,2,nill)
			}
			if(record_distances[1] > 0)
			{
				func_shot_notification(id,record_distances[1],nill_char,record_names[1],20,2,nill)
			}
			if(record_distances[2] > 0)
			{
				func_shot_notification(id,record_distances[2],nill_char,record_names[2],21,2,nill)
			}
		}
		else
		{
			if(record_distances[0] > 0)
			{
				func_shot_notification(id,record_distances[0],nill_char,record_names[0],22,2,nill)
			}
			if(record_distances[1] > 0)
			{
				func_shot_notification(id,record_distances[1],nill_char,record_names[1],23,2,nill)
			}
			if(record_distances[2] > 0)
			{
				func_shot_notification(id,record_distances[2],nill_char,record_names[2],24,2,nill)
			}
		}
	}
}

// =================================================================================================
// Display best no scope shot info for that round/map only
// =================================================================================================
public func_no_scope_round(id) {
	if(get_pcvar_num(pntr_round))
	{
		if (get_pcvar_num(pntr_notify_distance_type) == 0)
		{
			if(current_distances[0] > 0)
			{
				func_shot_notification(id,current_distances[0],nill_char,current_names[0],25,2,nill)
			}
			if(current_distances[1] > 0)
			{
				func_shot_notification(id,current_distances[1],nill_char,current_names[1],26,2,nill)
			}
			if(current_distances[2] > 0)
			{
				func_shot_notification(id,current_distances[2],nill_char,current_names[2],27,2,nill)
			}
		}
		else
		{
			if(current_distances[0] > 0)
			{
				func_shot_notification(id,current_distances[0],nill_char,current_names[0],28,2,nill)
			}
			if(current_distances[1] > 0)
			{
				func_shot_notification(id,current_distances[1],nill_char,current_names[1],29,2,nill)
			}
			if(current_distances[2] > 0)
			{
				func_shot_notification(id,current_distances[2],nill_char,current_names[2],30,2,nill)
			}
		}
	}
}

// =================================================================================================
// Shot notificatinon function
// =================================================================================================
func_shot_notification(id,distance,vic_name[],kill_name[],info_type,disp_type,hitplace) {
	new shot_message[128]
			
	switch(info_type) {
		case 3,6,9,12,14,16,18,19,20,21,25,26,27: {
			attacker_victim_distance = distance * 0.0254
			float_to_str(attacker_victim_distance,final_distance,5)
		}
		case 2,5,8,11,13,15,17,22,23,24,28,29,30: {
			attacker_victim_distance = distance * 0.0254 * 3.2808
			float_to_str(attacker_victim_distance,final_distance,5)
		}
	}
	
	switch(info_type) {
		case 1: {
			format(shot_message,127,"%s just got no scoped by %s!",vic_name,kill_name)
		}
		case 2: {
			format(shot_message,127,"%s just got no scoped by %s at %s feet!",vic_name,kill_name,final_distance)
		}
		case 3: {
			format(shot_message,127,"%s just got no scoped by %s at %s meters!",vic_name,kill_name,final_distance)
		}
		case 4: {
			format(shot_message,127,"%s just got no scoped by %s in the %s!",vic_name,kill_name,hit_place[hitplace])
		}
		case 5: {
			format(shot_message,127,"%s just got no scoped by %s in the %s at %s feet!",vic_name,kill_name,hit_place[hitplace],final_distance)
		}
		case 6: {
			format(shot_message,127,"%s just got no scoped by %s in the %s at %s meters!",vic_name,kill_name,hit_place[hitplace],final_distance)
		}
		case 7: {
			format(shot_message,127,"%s just got no scoped by teammate %s!",vic_name,kill_name)
		}
		case 8: {
			format(shot_message,127,"%s just got no scoped by teammate %s at %s feet!",vic_name,kill_name,final_distance)
		}
		case 9: {
			format(shot_message,127,"%s just got no scoped by teammate %s at %s meters!",vic_name,kill_name,final_distance)
		}
		case 10: {
			format(shot_message,127,"%s just got no scoped by teammate %s in the %s!",vic_name,kill_name,hit_place[hitplace])
		}
		case 11: {
			format(shot_message,127,"%s just got no scoped by teammate %s in the %s at %s feet!",vic_name,kill_name,hit_place[hitplace],final_distance)
		}
		case 12: {
			format(shot_message,127,"%s just got no scoped by teammate %s in the %s at %s meters!",vic_name,kill_name,hit_place[hitplace],final_distance)
		}
		case 13: {
			format(shot_message,127,"%s just beat the 1st place no scope shot at %s feet!",kill_name,final_distance)
		}
		case 14: {
			format(shot_message,127,"%s just beat the 1st place no scope shot at %s meters!",kill_name,final_distance)
		}
		case 15: {
			format(shot_message,127,"%s just beat the 2nd place no scope shot at %s feet!",kill_name,final_distance)
		}
		case 16: {
			format(shot_message,127,"%s just beat the 2nd place no scope shot at %s meters!",kill_name,final_distance)
		}
		case 17: {
			format(shot_message,127,"%s just beat the 3rd place no scope shot at %s feet!",kill_name,final_distance)
		}
		case 18: {
			format(shot_message,127,"%s just beat the 3rd place no scope shot at %s meters!",kill_name,final_distance)
		}
		case 19: {
			format(shot_message,127,"[No Scope Notifier] 1st place shot by: %s at %s meters!",kill_name,final_distance)
		}
		case 20: {
			format(shot_message,127,"[No Scope Notifier] 2nd best shot by: %s at %s meters!",kill_name,final_distance)
		}
		case 21: {
			format(shot_message,127,"[No Scope Notifier] 3rd best shot by: %s at %s meters!",kill_name,final_distance)
		}
		case 22: {
			format(shot_message,127,"[No Scope Notifier] 1st place shot by: %s at %s feet!",kill_name,final_distance)
		}
		case 23: {
			format(shot_message,127,"[No Scope Notifier] 2nd best shot by: %s at %s feet!",kill_name,final_distance)
		}
		case 24: {
			format(shot_message,127,"[No Scope Notifier] 2nd best shot by: %s at %s feet!",kill_name,final_distance)
		}
		case 25: {
			format(shot_message,127,"[No Scope Notifier] 1st place temporary shot by: %s at %s meters!",kill_name,final_distance)
		}
		case 26: {
			format(shot_message,127,"[No Scope Notifier] 2nd best temporary shot by: %s at %s meters!",kill_name,final_distance)
		}
		case 27: {
			format(shot_message,127,"[No Scope Notifier] 3rd best temporary shot by: %s at %s meters!",kill_name,final_distance)
		}
		case 28: {
			format(shot_message,127,"[No Scope Notifier] 1st place temporary shot by: %s at %s feet!",kill_name,final_distance)
		}
		case 29: {
			format(shot_message,127,"[No Scope Notifier] 2nd best temporary shot by: %s at %s feet!",kill_name,final_distance)
		}
		case 30: {
			format(shot_message,127,"[No Scope Notifier] 2nd best temporary shot by: %s at %s feet!",kill_name,final_distance)
		}
	}
	
	switch(disp_type) {
		case 1: {
			client_print(id,print_center,"%s",shot_message)
		}
		case 2: {
			client_print(id,print_chat,"%s",shot_message)
		}
		case 3: {
			set_hudmessage(255,255,255, -1.0, 0.16, 2, 0.02,get_pcvar_float(pntr_notify_large_time), 0.01, 0.1, 2) 
			show_hudmessage(id,"%s",shot_message)
		}
	}
	
	return final_distance
}
