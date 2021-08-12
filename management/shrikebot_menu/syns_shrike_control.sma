/*=================================================================================================
Syn's Shrike Bot Controller v1.4
This script was designed to control the Shrikebot mod for DoD via menus.

===========================
v1.4 Changes
===========================
- Added support for per map shrikebot.cfgs.
- Added menu option Vote Bots On. Starts a vote to turn the bots on.
- Added menu option Vote Bots Off. Starts a vote to turn the bots off.
- Added alternating menu option Use Base Config/Use Per Map Confg. Changes between the two.
- Added console command amx_sc_vote_on to start a vote to turn the bots on.
- Added console command amx_sc_vote_off to start a vote to turn the bots off.
- Added alternating console command amx_sc_change_cfg. Changes between base or per map config.
- Added cvar sc_maps_list. Allows use of default mapcycle.txt or DeagsMapManager mapchoice.ini.
- Added cvar sc_vote_on. Allows voting to turn the bots on.
- Added cvar sc_vote_off. Allows voting to turn the bots off.
- Added cvar sc_vote_restore. Allows restoring bots to previous amount if all real players leave.
- Added cvar sc_vote_time. Specifies how long a player has to vote until voting ends.
- Updated information and added to notes.

===========================
v1.3 Changes
===========================
- Added menu option Remove Bots For Now. Will keep bots off even between map changes until menu
  option Bring Bots Back is used or console command amx_sc_bring_bots_back is used.
- Added menu option Bring Bots Back. Will bring bots back to set amount in cvar sc_return_bots
  and will allow them to come back on map changes.
- Added menu option Show Shrike Config to show current shrikebot.cfg settings.
- Added console command amx_sc_remove_bots. Will keep bots off even between map changes until
  menu option Bring Bots Back is used or console command amx_sc_bring_bots_back is used.
- Added console command amx_sc_bring_bots_back. Will bring bots back to set amount in cvar
  sc_return_bots and will allow them to come back on map changes.
- Added console command amx_sc_show_config to show current shrikebot.cfg settings.
- Added cvar sc_return_bots. Specifies how many bots to put back in the game when using menu
  option Bring Bots Back or console command sc_bring_bots_back.
- Shortend console commands. If you had them bound before, be sure to update your binds!
- Fixed issues with not properly detecting an existing shrikebot.cfg that wasn't made by Shrike
  Bot Controller. If you had problems with commands that required saving your settings to the 
  shrikebot.cfg before, this was why. Thanks {DwP} 325th ABN and johndoe on dodplugins.net for 
  your information that helped me locate this. After going through the code, it was blatenly
  obvious as soon as I looked at it. ;)
- Added missing checks to obey cvar sc_show_changes on use of amx_sc_kick and amx_sc_add console 
  commands.
- Added to the notes and updated information.
- Cleaned up some unused code.

===========================
v1.2 Changes
===========================
- Added menu option to quick kick all bots. Keeps them from coming back!
- Added console command to quick kick all bots. Keeps them from coming back!
- Added console command to quick add bots.
- Added seperate access flag cvar for quick kick and quick add.
- Added more control to Fill Server / Kick On x Real Players / Min Bots / Max Bots.
- Dropped access flag cvars by letter. It was not really needed and won't work anyway. To change,
  modify the access flag at the end of each console command.
- Updated information.

===========================
v1.1 Changes
===========================
- Updated confirmation message system to handle options that got issued to a live running server
  but also was a savable option and said it required shrikebot.cfg be saved.
- Clarified and added to the notes.

===========================
Features
===========================
- Menu based configuration. Can be added to amxmodmenu.
- Access to the following options:
  Adding a bot
  All chat options
  Reaction time
  Skill
  Team balance
  Fill server
  Fun Mode
  Kick all bots
  Kick when x real players join
  Kill all bots
  Max bots
  Min bots
  Bot shield | See notes
  View clan tag
  View skill
- Save option to write base shrikebot.cfg file and per map shrikebot.cfg depending on mode.
- Quick options to remove all and add bots.
- Quick options to keep bots away until needed even after map changes and bring them back later.
- Voting to turn bots on and off and mode to restore bots after all players are gone from a
  successful vote off.

===========================
Notes
===========================
- Tested on an AMXMODX v1.8 Linux server and v1.76 Windows server as well.
- Immediate changes to some options will not take effect until map change and require the
  configuration be saved.
- On first use, writes over shrikebot.cfg or per map shrikebot.cfg depending on mode.
- Assumes shrikebot.cfg is in the default directory of "dod\shrikebot". If you put it somewhere
  else, just change the data for the sc_shrike_config array. Base dir is dod. This is the same
  for per map configs but assumes they are located in "dod\shrikebot\config".
- To make sure the shrikebot.cfg location info is correct, make sure the sc_show_changes cvar is
  on and either use the menu option Show Shrike Config or console command amx_sc_show_config. If
  nothing shows up in the chat console then the shrikebot.cfg location is incorrect. You can also
  use this to verify that options are correctly saved. If they do not update the file may be read
  only (Windows) or incorrect permissions are set (Linux).
- For View Clan and View Skill, you can't have both. It's either one or the other.
- Bot fun shield mode is now usable but I can't seem to see any effect besides a glowing,
  floating rat. By default, the precaching of the model is commented out. Do not use the option
  without the model or the server will crash. For those without the model, you can find it on 
  your HL1 CD or by searching on Google. It goes in the "dod\models folder" on your server and
  your computer as well. To enabe this feature, uncomment the "Precache resources" section and
  also the global variable "nill".
- To change the access flag for the menu, be sure to change all of the access flages on each of
  the listings in plugin init under the heading "Register menus".
- You can make changes to the shrikebot.cfg file after it has been created by Shrike Bot
  Controller but do not change the structure. IE swapping options to different lines. It works by
  reading/writing options in a certain order.
- If set to use base shrikebot.cfg, it will automatically delete per map configs to avoid
  settings conflicts.
- If set to use per map shrikebot.cfg files, will create them if not already created.
- After changing shrikebot.cfg type to use, you will need to change the map for the changes to
  properly take effect. Notice that if you have lots of maps, your server could take a temporary
  hit to resources until the operation is completed.

===========================
Console Commands
===========================
amx_shrike_control 
- Opens Shrike Bot Control menu. Default access level is ADMIN_CVAR.

amx_sc_kick
- Quick kicks all bots. Simplifies the task of kicking the bots without having to enter the menu.
  Default access level is ADMIN_VOTE.

amx_sc_add | x
- Quick adds x amount of bots. Default access level is ADMIN_VOTE.

amx_sc_remove_bots
- Gets rid of bots even between map changes until menu option Bring Bots Back is used or console
  command sc_bring_bots_back is used. Changes stay even on map change. Default access level is
  ADMIN_VOTE.

amx_sc_bring_bots_back
- Bring bots back to set amount in cvar sc_return_bots. Changes stay even on map change. Default
  access level is ADMIN_VOTE.

amx_sc_show_config
- Shows current shrikebot.cfg settings in console. Default access level is ADMIN_VOTE.

amx_sc_vote_on
- Starts vote to turn bots on. Uses value from shrikebot.cfg. Default access level is ADMIN_VOTE.

amx_sc_vote_off
- Starts vote to turn bots off. Uses value from shrikebot.cfg. Default access level is ADMIN_VOTE.

amx_sc_change_cfg
- Changes which shrikebot.cfg to use. Base or per map. Alternates mode on use. Default is base.
  Default access level is ADMIN_RCON.

===========================
CVARS
===========================

sc_show_changes | 0 = off | 1 = on
- Gives confirmation of changes on screen. Default on.

sc_return_bots
- Sets the amount of bots to have return to the server when menu option Bring Bots Back is used
  or console command sc_bring_bots_back is used. Default 8.

sc_maps_list | 0 = mapcycle.txt | 1 = DeagsMapManager mapchoice.ini
- Allows use of default mapcycle.txt or DeagsMapManager mapchoice.ini. This option is for use
  with per map configs. Maps that are not listed in either file (depending on mode) will not get
  a custom shrikebot.cfg. Be sure to have have all the maps you want listed. Supports up to 255
  maps which should be enough but if not, change the first amount for sc_mapcycle or sc_mapchoice
  under "Declare global variables and values".

sc_vote_on | 0 = off | 1 = on
- Enables or disables voting to turn bots on. Default on.

sc_vote_off | 0 = off | 1 = on
- Enables or disables voting to turn bots off. Default on.

sc_vote_restore | 0 = off | 1 = on
- Enables or disables restoring of bots when all real players leave. Sets them according to the
  max_bots value from shrikebot.cfg. Default on.

sc_vote_time | x
- Specifies how long players have until vote ends. Enter intergers only. 1 = one second etc..
  Default 10 seconds

===========================
Installation
===========================
- Copy syns_shrike_control.amxx into your addons\amxmodx\plugins folder
- Add syns_shrike_control.amxx to the bottom of your addons\amxmodx\configs\plugins.ini
- Change the map or restart your server to start using the plugin!

===========================
Installing Into amxmodmenu
===========================
- Add this line > 
  amx_addmenuitem "Shrike Bot Menu" "amx_shrike_control" "hu" "Syn's Shrikebot Controller" 
  to your amxmodx\configs\custommenuitems.cfg

===========================
Binding Keys
===========================
- To bind certain options like the menu or quick kick/add all you have to do is bind them to a
  key. IE say you want your p key to quick kick all bots. Go into your console and type:
  bind p amx_shrike_control_kick
  then hit enter and now your p key will quick kick all bots.

===========================
License
===========================
Syn's Shrike Bot Controller
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

// =================================================================================================
// Declare global variables and values
// =================================================================================================
//new nill
new sc_shrike_config[] = "\shrikebot\shrikebot.cfg"
new sc_shrike_per_map_config[2][] = { "\shrikebot\config\",".bsp" }
new sc_shrike_maps_location[2][] = { "\mapcycle.txt","\addons\amxmodx\configs\mapchoice.ini" }
//new sc_mapcycle[255][32]
new sc_maps[255][32]

new configdata[20][32] = { "#SynSC","bot_chat_drop_percent 0","bot_chat_lower_percent 0",
"bot_chat_percent 0","bot_chat_swap_percent 0","bot_chat_tag_percent 0","bot_logo_percent 0",
"bot_reaction_time 1","bot_skill 1","bot_taunt_percent 0","bot_team_balance on","bot_whine_percent 0",
"botdontshoot off","funmode 0","min_bots 0","max_bots 8","kick_all_bots 2","#powerup off","view_clan off",
"view_skill off" }
new configdata_id[1][7]
new sc_cfg_type_console[3][] = { "","shr ","^"" }
new sc_cfg_cmd[24][] = { "","bot_chat_drop_percent ","bot_chat_lower_percent ","bot_chat_percent ",
"bot_chat_swap_percent ","bot_chat_tag_percent ","bot_logo_percent ","bot_reaction_time ","bot_skill ",
"bot_taunt_percent ","bot_team_balance ","bot_whine_percent ","botdontshoot ","funmode ","min_bots ",
"max_bots ","kick_all_bots ","powerup ","view_clan ","view_skill ","bot botstop ","addbot ","fill_serv ","#powerup " }
new sc_cfg_cmd_id
new sc_cfg_menu_selection[40][] = { "","0","10","20","30","40","50","60","70","80","90","100","0",
"2","4","6","8","10","12","14","16","18","20","22","24","26","28","30","32","on","off","1","2","0","1","2","3","4","5","6" }
new sc_cfg_menu_selection_id
new sc_cfg_menu_title[24][] = { "","Shrike Bot Menu - Add a Bot","Shrike Bot Menu - Freeze Bots",
"Shrike Bot Menu - Chat Options - Drop Percent","Shrike Bot Menu - Chat Options - Lower Percent",
"Shrike Bot Menu - Chat Options - Chat Percent","Shrike Bot Menu - Chat Options - Swap Percent",
"Shrike Bot Menu - Chat Options - Tag Percent","Shrike Bot Menu - Chat Options - Logo Percent",
"Shrike Bot Menu - Chat Options - Taunt Percent","Shrike Bot Menu - Chat Options - Whine Percent",
"Shrike Bot Menu - Bot Reaction Time","Shrike Bot Menu - Bot Skill","Shrike Bot Menu - Bot Team Balance",
"Shrike Bot Menu - Bots Shoot","Shrike Bot Menu - Fun Mode","Shrike Bot Menu - Kick Bots When x Players Join",
"Shrike Bot Menu - Max Bots","Shrike Bot Menu - Min Bots","Shrike Bot Menu - Extra Fun Bot Shield",
"Shrike Bot Menu - View Clan","Shrike Bot Menu - View Skill","Shrike Bot Menu - Bots Shoot",
"Shrike Bot Menu - Fill Server with Bots" }
new sc_cfg_menu_title_id
new sc_cfg_menu_sub[46][] = { "","0","10","20","30","40","50","60","70","80","90","100","Add a Bot",
"Freeze Bots","Bot Chat Lower Percent","Bot Chat Percent","Bot Chat Swap Percent","Bot Chat Tag Percent",
"Bot Logo Percent","Bot Taunt Percent","Bot Whine Percent","Back to Top Level","On","Off","Add Allies Bot",
"Add Axis Bot","1","2","0","2","4","6","8","10","12","14","16","18","20","22","24","26","28","30","32","Disable" }
new sc_cfg_menu_sub_id
new sc_cfg_type
new sc_cfg_holder[32]
new sc_cfg_holder2[32]
new sc_cfg_holder3[32]
new sc_id_keeper[2]
new sc_pc_wserc
new sc_pc_wshrc
new sc_confirmation
new sc_player_id_keeper
new sc_vote_keeper[32]
new sc_user_voted[32]
new sc_vote_message_type
new sc_bots_voted

// =================================================================================================
// Precache resources
// =================================================================================================
/*public plugin_precache()
{
	// Precache missing rat model for bot fun shield
	nill = precache_model("models/bigrat.mdl")
}
*/
// =================================================================================================
// Plugin init
// =================================================================================================
public plugin_init() {
	register_cvar("Syns_Shrike_Control", "Version 1.4 by Synthetic - www.weaksaucedod.com",FCVAR_SERVER|FCVAR_SPONLY)
	register_plugin("Syn's Shrikebot Controller", "1.4", "«Synthetiç» - www.weaksaucedod.com")
	register_cvar("sc_show_changes","1")
	register_cvar("sc_return_bots","8")
	register_cvar("sc_maps_list","0")
	register_cvar("sc_vote_on","1")
	register_cvar("sc_vote_off","1")
	register_cvar("sc_vote_restore","1")
	register_cvar("sc_vote_time","10")
	register_cvar("sc_cfg_mode","0") // Don't touch and don't do anything with it! :P
	if (file_exists("\shrikebot\sc.cfg") == 1)
	{
		new temp_cfg[2]
		new nibblewerfers
		read_file("\shrikebot\sc.cfg",1,temp_cfg,1,nibblewerfers)
		set_cvar_num("sc_cfg_mode",str_to_num(temp_cfg))
		//str_to_num(
		
	}
	else
	{
		write_file("\shrikebot\sc.cfg","Syn's Shrike Control Config",0)
		write_file("\shrikebot\sc.cfg","0",1)
	}
	// Register menus
	register_concmd("amx_shrike_control_gpt","func_shrike_control_gpt",ADMIN_CVAR)
	register_concmd("amx_shrike_control_gpt2","func_shrike_control_gpt2",ADMIN_CVAR)
	register_concmd("amx_shrike_control_gpt13","func_shrike_control_gpt13",ADMIN_CVAR)
	register_concmd("amx_shrike_control_gpt16","func_shrike_control_gpt16",ADMIN_CVAR)
	register_concmd("amx_shrike_control_reaction","func_shrike_control_reaction",ADMIN_CVAR)
	register_concmd("amx_shrike_control_skill","func_shrike_control_skill",ADMIN_CVAR)
	register_concmd("amx_shrike_control","func_shrike_control",ADMIN_CVAR)
	register_concmd("amx_shrike_control_chat","func_shrike_control_chat",ADMIN_CVAR)
	// Register non menu commands
	register_concmd("amx_sc_kick","func_shrike_control_kick",ADMIN_VOTE)
	register_concmd("amx_sc_add","func_shrike_control_add",ADMIN_VOTE," - Add x amount of bots.")
	register_concmd("amx_sc_remove_bots","func_remove_for_now",ADMIN_VOTE)
	register_concmd("amx_sc_bring_bots_back","func_bring_back",ADMIN_VOTE)
	register_concmd("amx_sc_show_config","func_show_config",ADMIN_VOTE)
	register_concmd("amx_sc_vote_on","func_vote_on", ADMIN_VOTE)
	register_concmd("amx_sc_vote_off","func_vote_off", ADMIN_VOTE)
	register_concmd("amx_sc_change_cfg","func_change_cfg",ADMIN_RCON)
	// Register vote menus
	register_menucmd(register_menuid("Vote Bots Off"),(1<<0)|(1<<1)|(1<<2), "func_vote_off_select")
	register_menucmd(register_menuid("Vote Bots On"),(1<<0)|(1<<1)|(1<<2), "func_vote_on_select")
	// Read shrikebot.cfg
	func_sc_read_config()
}


// =================================================================================================
// Main Functions
// =================================================================================================
public func_shrike_control(id, level, cid) {
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED
	
	sc_player_id_keeper = id
	new shrike_control_menu = menu_create("Shrike Bot Menu", "func_menu")
	menu_additem(shrike_control_menu, "Add a Bot", "1", 0)
	menu_additem(shrike_control_menu, "Remove Bots For Now", "2", 0)
	menu_additem(shrike_control_menu, "Bring Bots Back", "3", 0)
	menu_additem(shrike_control_menu, "Chat Options", "4", 0)
	menu_additem(shrike_control_menu, "Bot Reaction Time", "5", 0)
	menu_additem(shrike_control_menu, "Bot Skill", "6", 0)
	menu_additem(shrike_control_menu, "Bot Team Balance", "7", 0)
	menu_additem(shrike_control_menu, "Bots Shoot", "8", 0)
	menu_additem(shrike_control_menu, "Fill Server With Bots", "9", 0)
	menu_additem(shrike_control_menu, "Fun Mode", "10",0)
	menu_additem(shrike_control_menu, "Kick All Bots", "11", 0)
	menu_additem(shrike_control_menu, "Quick Kick All Bots", "12", 0)
	menu_additem(shrike_control_menu, "Kick Bots When x Real Players Join", "13", 0)
	menu_additem(shrike_control_menu, "Kill All Bots", "14", 0)
	menu_additem(shrike_control_menu, "Max Bots", "15", 0)
	menu_additem(shrike_control_menu, "Min Bots", "16", 0)
	menu_additem(shrike_control_menu, "Extra Fun Bot Shield", "17", 0)
	menu_additem(shrike_control_menu, "View Clan", "18", 0)
	menu_additem(shrike_control_menu, "View Skill", "19", 0)
	menu_additem(shrike_control_menu, "Save Configuration", "20", 0)
	menu_additem(shrike_control_menu, "Show Shrike Config", "21", 0)
	menu_additem(shrike_control_menu, "Vote Bots On","22",0)
	menu_additem(shrike_control_menu, "Vote Bots Off","23",0)
	if (get_cvar_num("sc_cfg_mode") == 0)
	{
		menu_additem(shrike_control_menu, "Use Per Map Confg","24",0)
	}
	if (get_cvar_num("sc_cfg_mode") == 1)
	{
		menu_additem(shrike_control_menu, "Use Base Config","24",0)
	}
	menu_setprop(shrike_control_menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, shrike_control_menu, 0)
	return PLUGIN_HANDLED
}

public func_shrike_control_chat(id, level, cid) {
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED
	
	sc_player_id_keeper = id
	new shrike_control_menu = menu_create("Shrike Bot Menu - Bot Chat Options", "func_menu_chat")
	menu_additem(shrike_control_menu, "Bot Chat Drop Percent", "1", 0)
	menu_additem(shrike_control_menu, "Bot Chat Lower Percent", "2", 0)
	menu_additem(shrike_control_menu, "Bot Chat Percent", "3", 0)
	menu_additem(shrike_control_menu, "Bot Chat Swap Percent", "4", 0)
	menu_additem(shrike_control_menu, "Bot Chat Tag Percent", "5", 0)
	menu_additem(shrike_control_menu, "Bot Logo Percent", "6", 0)
	menu_additem(shrike_control_menu, "Bot Taunt Percent", "7", 0)
	menu_additem(shrike_control_menu, "Bot Whine Percent", "8", 0)
	menu_additem(shrike_control_menu, "Back One Level", "9", 0)
	menu_setprop(shrike_control_menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, shrike_control_menu, 0)
	return PLUGIN_HANDLED
}

public func_shrike_control_reaction(id, level, cid) {
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED
	
	sc_player_id_keeper = id
	new shrike_control_menu = menu_create("Shrike Bot Menu - Bot Reaction Time", "func_menu_reaction")
	menu_additem(shrike_control_menu, "Off", "1", 0)
	menu_additem(shrike_control_menu, "Very Fast", "2", 0)
	menu_additem(shrike_control_menu, "Fast", "3", 0)
	menu_additem(shrike_control_menu, "Slow", "4", 0)
	menu_additem(shrike_control_menu, "Back One Level", "5", 0)
	menu_setprop(shrike_control_menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, shrike_control_menu, 0)
	return PLUGIN_HANDLED
}

public func_shrike_control_skill(id, level, cid) {
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED
	
	sc_player_id_keeper = id
	new shrike_control_menu = menu_create("Shrike Bot Menu - Bot Skill", "func_menu_skill")
	menu_additem(shrike_control_menu, "Evil", "1", 0)
	menu_additem(shrike_control_menu, "Bad Ass", "2", 0)
	menu_additem(shrike_control_menu, "Not Bad", "3", 0)
	menu_additem(shrike_control_menu, "Average", "4", 0)
	menu_additem(shrike_control_menu, "N00b", "5", 0)
	menu_additem(shrike_control_menu, "Pathetic", "6", 0)
	menu_additem(shrike_control_menu, "Back One Level", "7", 0)
	menu_setprop(shrike_control_menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, shrike_control_menu, 0)
	return PLUGIN_HANDLED
}

public func_shrike_control_gpt(id, level, cid) {
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED
		
	sc_player_id_keeper = id
	sc_id_keeper[0] = sc_cfg_menu_title_id
	sc_id_keeper[1] = sc_cfg_menu_sub_id
	new shrike_control_menu = menu_create(sc_cfg_menu_title[sc_cfg_menu_title_id], "func_menu_gpt")
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id], "1", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+1], "2", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+2], "3", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+3], "4", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+4], "5", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+5], "6", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+6], "7", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+7], "8", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+8], "9", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+9], "10", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+10], "11", 0)
	menu_additem(shrike_control_menu, "Back One Level", "12", 0)
	menu_setprop(shrike_control_menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, shrike_control_menu, 0)
	return PLUGIN_HANDLED
}

public func_shrike_control_gpt2(id, level, cid) {
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED
		
	sc_player_id_keeper = id
	if (sc_cfg_type == 1) {
		sc_cfg_menu_sub_id = 22
	}
	else if(sc_cfg_type == 2) {
		sc_cfg_menu_sub_id = 24
	}
	else if(sc_cfg_type == 3) {
		sc_cfg_menu_sub_id = 26
	}
	else if(sc_cfg_type == 4) {
		sc_cfg_menu_sub_id = 22
	}
	else if(sc_cfg_type == 5) {
		sc_cfg_menu_sub_id = 22
	}
	else if(sc_cfg_type == 6) {
		sc_cfg_menu_sub_id = 22
	}
	sc_id_keeper[0] = sc_cfg_menu_title_id
	sc_id_keeper[1] = sc_cfg_menu_sub_id
	new shrike_control_menu = menu_create(sc_cfg_menu_title[sc_cfg_menu_title_id], "func_menu_gpt2")
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id], "1", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+1], "2", 0)
	menu_additem(shrike_control_menu, "Back One Level", "3", 0)
	menu_setprop(shrike_control_menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, shrike_control_menu, 0)
	return PLUGIN_HANDLED
}

public func_shrike_control_gpt13(id, level, cid) {
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED
		
	sc_player_id_keeper = id
	sc_id_keeper[0] = sc_cfg_menu_title_id
	sc_id_keeper[1] = sc_cfg_menu_sub_id
	new shrike_control_menu = menu_create(sc_cfg_menu_title[sc_cfg_menu_title_id], "func_menu_gpt13")
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id], "1", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+1], "2", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+2], "3", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+3], "4", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+4], "5", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+5], "6", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+6], "7", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+7], "8", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+8], "9", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+9], "10", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+10], "11", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+11], "12", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+12], "13", 0)
	menu_additem(shrike_control_menu, "Back One Level", "14", 0)
	menu_setprop(shrike_control_menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, shrike_control_menu, 0)
	return PLUGIN_HANDLED
}

public func_shrike_control_gpt16(id, level, cid) {
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED
		
	sc_player_id_keeper = id
	sc_id_keeper[0] = sc_cfg_menu_title_id
	sc_id_keeper[1] = sc_cfg_menu_sub_id
	new shrike_control_menu = menu_create(sc_cfg_menu_title[sc_cfg_menu_title_id], "func_menu_gpt16")
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id], "1", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+1], "2", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+2], "3", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+3], "4", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+4], "5", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+5], "6", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+6], "7", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+7], "8", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+8], "9", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+9], "10", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+10], "11", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+11], "12", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+12], "13", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+13], "14", 0)
	menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+14], "15", 0)
	if (sc_cfg_type == 2)
	{
		menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+16], "16", 0)
	}
	else
	{
		menu_additem(shrike_control_menu, sc_cfg_menu_sub[sc_cfg_menu_sub_id+15], "16", 0)
	}
	menu_additem(shrike_control_menu, "Back One Level", "17", 0)
	menu_setprop(shrike_control_menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, shrike_control_menu, 0)
	return PLUGIN_HANDLED
}

public func_menu(id, shrike_control_menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(shrike_control_menu)
		return PLUGIN_HANDLED
	}
	new data[6], iName[64]
	new access, callback
	menu_item_getinfo(shrike_control_menu, item, access, data,5, iName, 63, callback)
	new key = str_to_num(data)
	
	switch(key)
	{
		case 1:{
			sc_cfg_menu_title_id = 1
			sc_cfg_type = 2
			sc_cfg_cmd_id = 21
			sc_pc_wserc = 1
			sc_pc_wshrc = 0
			sc_confirmation = 0
			client_cmd(id,"amx_shrike_control_gpt2")
		}
		case 2:{
			client_cmd(id,"amx_sc_remove_bots")
		}
		case 3:{
			client_cmd(id,"amx_sc_bring_bots_back")
		}
		case 4:{
			sc_confirmation = 1
			client_cmd(id,"amx_shrike_control_chat")
		}
		case 5:{ 
			sc_confirmation = 1
			client_cmd(id,"amx_shrike_control_reaction")
		}
		case 6:{
			sc_confirmation = 1
			client_cmd(id,"amx_shrike_control_skill")			
		}
		case 7:{
			sc_cfg_menu_title_id = 13
			sc_cfg_type = 1
			sc_cfg_cmd_id = 10
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			sc_confirmation = 1
			client_cmd(id,"amx_shrike_control_gpt2")
		}
		case 8:{
			sc_cfg_menu_title_id = 14
			sc_cfg_type = 4
			sc_cfg_cmd_id = 12
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			sc_confirmation = 1
			client_cmd(id,"amx_shrike_control_gpt2")
		}
		case 9:{
			sc_cfg_menu_title_id = 23
			sc_cfg_type = 1
			sc_cfg_cmd_id = 22
			sc_cfg_menu_selection_id = 14
			sc_pc_wserc = 1
			sc_pc_wshrc = 0
			sc_cfg_menu_sub_id = 29
			sc_confirmation = 0
			client_cmd(id,"amx_shrike_control_gpt16")
		}
		case 10:{
			sc_cfg_menu_title_id = 15
			sc_cfg_type = 5
			sc_cfg_cmd_id = 13
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			sc_confirmation = 1
			client_cmd(id,"amx_shrike_control_gpt2")
		}
		case 11:{
			if (get_cvar_num("sc_show_changes") == 1)
			{
				client_print(id,print_chat,"Syn's Shrike Control - All bots kicked.")
			}
			server_cmd("shr kick_all")
		}
		case 12:{
			if (get_cvar_num("sc_show_changes") == 1)
			{
				client_print(id,print_chat,"Syn's Shrike Control - Quick kicked all bots.")
			}
			server_cmd("shr ^"max_bots 0^"")
			set_task(3.0,"func_kick",id,"",0)
		}
		case 13:{
			sc_cfg_menu_title_id = 16
			sc_cfg_type = 2
			sc_cfg_cmd_id = 16
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			sc_cfg_menu_sub_id = 29
			sc_confirmation = 1
			client_cmd(id,"amx_shrike_control_gpt16")
		}
		case 14:{
			if (get_cvar_num("sc_show_changes") == 1)
			{
				client_print(id,print_chat,"Syn's Shrike Control - All bots killed.")
			}
			server_cmd("shr kill_all")
		}
		case 15:{
			sc_cfg_menu_title_id = 17
			sc_cfg_type = 3
			sc_cfg_cmd_id = 15
			sc_pc_wserc = 1
			sc_pc_wshrc = 1
			sc_cfg_menu_sub_id = 28
			sc_confirmation = 2
			client_cmd(id,"amx_shrike_control_gpt16")
		}
		case 16:{
			sc_cfg_menu_title_id = 18
			sc_cfg_type = 3
			sc_cfg_cmd_id = 14
			sc_pc_wserc = 1
			sc_pc_wshrc = 1
			sc_cfg_menu_sub_id = 28
			sc_confirmation = 2
			client_cmd(id,"amx_shrike_control_gpt16")
		}
		case 17:{
			sc_cfg_menu_title_id = 19
			sc_cfg_type = 6
			sc_cfg_cmd_id = 17
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			sc_confirmation = 1
			client_cmd(id,"amx_shrike_control_gpt2")
		}
		case 18:{
			sc_cfg_menu_title_id = 20
			sc_cfg_type = 1
			sc_cfg_cmd_id = 18
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			sc_confirmation = 1
			client_cmd(id,"amx_shrike_control_gpt2")
		}
		case 19:{
			sc_cfg_menu_title_id = 21
			sc_cfg_type = 1
			sc_cfg_cmd_id = 19
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			sc_confirmation = 1
			client_cmd(id,"amx_shrike_control_gpt2")
		}
		case 20:{
			func_sc_write_config()
		}
		case 21:{
			client_cmd(id,"amx_sc_show_config")
		}
		case 22:{
			client_cmd(id,"amx_sc_vote_on")
		}
		case 23:{
			client_cmd(id,"amx_sc_vote_off")
		}
		case 24:{
			client_cmd(id,"amx_sc_change_cfg")
		}
	}
	menu_destroy(shrike_control_menu)
	return PLUGIN_HANDLED
}

public func_menu_chat(id, shrike_control_menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(shrike_control_menu)
		return PLUGIN_HANDLED
	}
	new data[6], iName[64]
	new access, callback
	menu_item_getinfo(shrike_control_menu, item, access, data,5, iName, 63, callback)
	new key = str_to_num(data)
	
	switch(key)
	{
		case 1:{
			sc_cfg_menu_title_id = 3
			sc_cfg_type = 1
			sc_cfg_cmd_id = 1
			sc_cfg_menu_selection_id = 1
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			sc_cfg_menu_sub_id = 1
			client_cmd(id,"amx_shrike_control_gpt")
		}
		case 2:{
			sc_cfg_menu_title_id = 4
			sc_cfg_type = 1
			sc_cfg_cmd_id = 2
			sc_cfg_menu_selection_id = 1
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			sc_cfg_menu_sub_id = 1
			client_cmd(id,"amx_shrike_control_gpt")
		}
		case 3:{ 
			sc_cfg_menu_title_id = 5
			sc_cfg_type = 1
			sc_cfg_cmd_id = 3
			sc_cfg_menu_selection_id = 1
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			sc_cfg_menu_sub_id = 1
			client_cmd(id,"amx_shrike_control_gpt")
		}
		case 4:{
			sc_cfg_menu_title_id = 6
			sc_cfg_type = 1
			sc_cfg_cmd_id = 4
			sc_cfg_menu_selection_id = 1
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			sc_cfg_menu_sub_id = 1
			client_cmd(id,"amx_shrike_control_gpt")
		}
		case 5:{
			sc_cfg_menu_title_id = 7
			sc_cfg_type = 1
			sc_cfg_cmd_id = 5
			sc_cfg_menu_selection_id = 1
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			sc_cfg_menu_sub_id = 1
			client_cmd(id,"amx_shrike_control_gpt")
		}
		case 6:{
			sc_cfg_menu_title_id = 8
			sc_cfg_type = 1
			sc_cfg_cmd_id = 6
			sc_cfg_menu_selection_id = 1
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			sc_cfg_menu_sub_id = 1
			client_cmd(id,"amx_shrike_control_gpt")
		}
		case 7:{
			sc_cfg_menu_title_id = 9
			sc_cfg_type = 1
			sc_cfg_cmd_id = 9
			sc_cfg_menu_selection_id = 1
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			sc_cfg_menu_sub_id = 1
			client_cmd(id,"amx_shrike_control_gpt")
		}
		case 8:{
			sc_cfg_menu_title_id = 10
			sc_cfg_type = 1
			sc_cfg_cmd_id = 11
			sc_cfg_menu_selection_id = 1
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			sc_cfg_menu_sub_id = 1
			client_cmd(id,"amx_shrike_control_gpt")
		}
		case 9:{
			
			client_cmd(id,"amx_shrike_control")
		}

	}
	menu_destroy(shrike_control_menu)
	return PLUGIN_HANDLED
}

public func_menu_reaction(id, shrike_control_menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(shrike_control_menu)
		return PLUGIN_HANDLED
	}
	new data[6], iName[64]
	new access, callback
	menu_item_getinfo(shrike_control_menu, item, access, data,5, iName, 63, callback)
	new key = str_to_num(data)

	switch(key)
	{
		case 1:{
			sc_cfg_menu_title_id = 11
			sc_cfg_cmd_id = 7
			sc_cfg_menu_selection_id = 33
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_reaction")
			
		}
		case 2:{
			sc_cfg_menu_title_id = 11
			sc_cfg_cmd_id = 7
			sc_cfg_menu_selection_id = 34
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_reaction")
		
		}
		case 3:{ 
			sc_cfg_menu_title_id = 11
			sc_cfg_cmd_id = 7
			sc_cfg_menu_selection_id = 35
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_reaction")
		}
		case 4:{ 
			sc_cfg_menu_title_id = 11
			sc_cfg_cmd_id = 7
			sc_cfg_menu_selection_id = 36
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_reaction")
		}
		case 5:{ 
			
			client_cmd(id,"amx_shrike_control")
		}

	}
	menu_destroy(shrike_control_menu)
	return PLUGIN_HANDLED
}

public func_menu_skill(id, shrike_control_menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(shrike_control_menu)
		return PLUGIN_HANDLED
	}
	new data[6], iName[64]
	new access, callback
	menu_item_getinfo(shrike_control_menu, item, access, data,5, iName, 63, callback)
	new key = str_to_num(data)
	
	switch(key)
	{
		case 1:{
			sc_cfg_menu_title_id = 12
			sc_cfg_cmd_id = 8
			sc_cfg_menu_selection_id = 34
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_skill")
			
		}
		case 2:{
			sc_cfg_menu_title_id = 12
			sc_cfg_cmd_id = 8
			sc_cfg_menu_selection_id = 35
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_skill")
		
		}
		case 3:{ 
			sc_cfg_menu_title_id = 12
			sc_cfg_cmd_id = 8
			sc_cfg_menu_selection_id = 36
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_skill")
		}
		case 4:{ 
			sc_cfg_menu_title_id = 12
			sc_cfg_cmd_id = 8
			sc_cfg_menu_selection_id = 37
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_skill")
		}
		case 5:{ 
			sc_cfg_menu_title_id = 12
			sc_cfg_cmd_id = 8
			sc_cfg_menu_selection_id = 38
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_skill")
		}
		case 6:{ 
			sc_cfg_menu_title_id = 12
			sc_cfg_cmd_id = 8
			sc_cfg_menu_selection_id = 39
			sc_pc_wserc = 0
			sc_pc_wshrc = 1
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_skill")
		}
		case 7:{ 
			
			client_cmd(id,"amx_shrike_control")
		}

	}
	menu_destroy(shrike_control_menu)
	return PLUGIN_HANDLED
}

public func_menu_gpt2(id, shrike_control_menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(shrike_control_menu)
		return PLUGIN_HANDLED
	}
	new data[6], iName[64]
	new access, callback
	menu_item_getinfo(shrike_control_menu, item, access, data,5, iName, 63, callback)
	new key = str_to_num(data)
	
	switch(key)
	{
		case 1:{
			if (sc_cfg_type == 1) {
				sc_cfg_menu_selection_id = 29
			}
			else if(sc_cfg_type == 2) {
				sc_cfg_menu_selection_id = 31
			}
			else if(sc_cfg_type == 4) {
				sc_cfg_menu_selection_id = 34
			}
			else if(sc_cfg_type == 5) {
				sc_cfg_menu_selection_id = 34
			}
			else if(sc_cfg_type == 6) {
				sc_cfg_menu_selection_id = 29
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt2")
		}
		case 2:{
			if (sc_cfg_type == 1) {
				sc_cfg_menu_selection_id = 30
			}
			else if(sc_cfg_type == 2) {
				sc_cfg_menu_selection_id = 32
			}
			else if(sc_cfg_type == 4) {
				sc_cfg_menu_selection_id = 33
			}
			else if(sc_cfg_type == 5) {
				sc_cfg_menu_selection_id = 33
			}
			else if(sc_cfg_type == 6) {
				sc_cfg_menu_selection_id = 29
				sc_cfg_cmd_id = 23
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt2")
		}
		case 3:{ 
			
			client_cmd(id,"amx_shrike_control")
		}

	}
	menu_destroy(shrike_control_menu)
	return PLUGIN_HANDLED
}

public func_menu_gpt(id, shrike_control_menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(shrike_control_menu)
		return PLUGIN_HANDLED
	}
	new data[6], iName[64]
	new access, callback
	menu_item_getinfo(shrike_control_menu, item, access, data,5, iName, 63, callback)
	new key = str_to_num(data)
	
	switch(key)
	{
		case 1:{
			if (sc_cfg_type == 1) {
				sc_cfg_menu_selection_id = 1
			}
			else if(sc_cfg_type == 2) {
				sc_cfg_menu_selection_id = 13
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt")
		}
		case 2:{
			if (sc_cfg_type == 1) {
				sc_cfg_menu_selection_id = 2
			}
			else if(sc_cfg_type == 2) {
				sc_cfg_menu_selection_id = 14
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt")
		}
		case 3:{ 
			if (sc_cfg_type == 1) {
				sc_cfg_menu_selection_id = 3
			}
			else if(sc_cfg_type == 2) {
				sc_cfg_menu_selection_id = 15
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt")
		}
		case 4:{
			if (sc_cfg_type == 1) {
				sc_cfg_menu_selection_id = 4
			}
			else if(sc_cfg_type == 2) {
				sc_cfg_menu_selection_id = 16
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt")
		}
		case 5:{
			if (sc_cfg_type == 1) {
				sc_cfg_menu_selection_id = 5
			}
			else if(sc_cfg_type == 2) {
				sc_cfg_menu_selection_id = 17
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt")
		}
		case 6:{
			if (sc_cfg_type == 1) {
				sc_cfg_menu_selection_id = 6
			}
			else if(sc_cfg_type == 2) {
				sc_cfg_menu_selection_id = 18
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt")
		}
		case 7:{
			if (sc_cfg_type == 1) {
				sc_cfg_menu_selection_id = 7
			}
			else if(sc_cfg_type == 2) {
				sc_cfg_menu_selection_id = 19
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt")
		}
		case 8:{
			if (sc_cfg_type == 1) {
				sc_cfg_menu_selection_id = 8
			}
			else if(sc_cfg_type == 2) {
				sc_cfg_menu_selection_id = 20
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt")
		}
		case 9:{
			if (sc_cfg_type == 1) {
				sc_cfg_menu_selection_id = 9
			}
			else if(sc_cfg_type == 2) {
				sc_cfg_menu_selection_id = 21
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt")
		}
		case 10:{
			if (sc_cfg_type == 1) {
				sc_cfg_menu_selection_id = 10
			}
			else if(sc_cfg_type == 2) {
				sc_cfg_menu_selection_id = 22
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt")
		}
		case 11:{
			if (sc_cfg_type == 1) {
				sc_cfg_menu_selection_id = 11
			}
			else if(sc_cfg_type == 2) {
				sc_cfg_menu_selection_id = 23
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt")
		}
		case 12:{
			client_cmd(id,"amx_shrike_control")
		}

	}
	menu_destroy(shrike_control_menu)
	return PLUGIN_HANDLED
}

public func_menu_gpt13(id, shrike_control_menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(shrike_control_menu)
		return PLUGIN_HANDLED
	}
	new data[6], iName[64]
	new access, callback
	menu_item_getinfo(shrike_control_menu, item, access, data,5, iName, 63, callback)
	new key = str_to_num(data)
	
	switch(key)
	{
		case 1:{
			sc_cfg_menu_selection_id = 12
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt13")
		}
		case 2:{
			sc_cfg_menu_selection_id = 13
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt13")
		}
		case 3:{ 
			sc_cfg_menu_selection_id = 14
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt13")
		}
		case 4:{
			sc_cfg_menu_selection_id = 15
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt13")
		}
		case 5:{
			sc_cfg_menu_selection_id = 16
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt13")
		}
		case 6:{
			sc_cfg_menu_selection_id = 17
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt13")
		}
		case 7:{
			sc_cfg_menu_selection_id = 18
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt13")
		}
		case 8:{
			sc_cfg_menu_selection_id = 19
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt13")
		}
		case 9:{
			sc_cfg_menu_selection_id = 20
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt13")
		}
		case 10:{
			sc_cfg_menu_selection_id = 21
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt13")
		}
		case 11:{
			sc_cfg_menu_selection_id = 22
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt13")
		}
		case 12:{
			sc_cfg_menu_selection_id = 23
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt13")
		}
		case 13:{
			sc_cfg_menu_selection_id = 24
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt13")
		}
		case 14:{
			
			client_cmd(id,"amx_shrike_control")
		}

	}
	menu_destroy(shrike_control_menu)
	return PLUGIN_HANDLED
}

public func_menu_gpt16(id, shrike_control_menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(shrike_control_menu)
		return PLUGIN_HANDLED
	}
	new data[6], iName[64]
	new access, callback
	menu_item_getinfo(shrike_control_menu, item, access, data,5, iName, 63, callback)
	new key = str_to_num(data)
	
	switch(key)
	{
		case 1:{
			sc_cfg_menu_selection_id = 13
			if (sc_cfg_type == 3)
			{
				sc_cfg_menu_selection_id = 12
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt16")
		}
		case 2:{
			sc_cfg_menu_selection_id = 14
			if (sc_cfg_type == 3)
			{
				sc_cfg_menu_selection_id = 13
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt16")
		}
		case 3:{ 
			sc_cfg_menu_selection_id = 15
			if (sc_cfg_type == 3)
			{
				sc_cfg_menu_selection_id = 14
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt16")
		}
		case 4:{
			sc_cfg_menu_selection_id = 16
			if (sc_cfg_type == 3)
			{
				sc_cfg_menu_selection_id = 15
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt16")
		}
		case 5:{
			sc_cfg_menu_selection_id = 17
			if (sc_cfg_type == 3)
			{
				sc_cfg_menu_selection_id = 16
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt16")
		}
		case 6:{
			sc_cfg_menu_selection_id = 18
			if (sc_cfg_type == 3)
			{
				sc_cfg_menu_selection_id = 17
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt16")
		}
		case 7:{
			sc_cfg_menu_selection_id = 19
			if (sc_cfg_type == 3)
			{
				sc_cfg_menu_selection_id = 18
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt16")
		}
		case 8:{
			sc_cfg_menu_selection_id = 20
			if (sc_cfg_type == 3)
			{
				sc_cfg_menu_selection_id = 19
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt16")
		}
		case 9:{
			sc_cfg_menu_selection_id = 21
			if (sc_cfg_type == 3)
			{
				sc_cfg_menu_selection_id = 20
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt16")
		}
		case 10:{
			sc_cfg_menu_selection_id = 22
			if (sc_cfg_type == 3)
			{
				sc_cfg_menu_selection_id = 21
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt16")
		}
		case 11:{
			sc_cfg_menu_selection_id = 23
			if (sc_cfg_type == 3)
			{
				sc_cfg_menu_selection_id = 22
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt16")
		}
		case 12:{
			sc_cfg_menu_selection_id = 24
			if (sc_cfg_type == 3)
			{
				sc_cfg_menu_selection_id = 23
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt16")
		}
		case 13:{
			sc_cfg_menu_selection_id = 25
			if (sc_cfg_type == 3)
			{
				sc_cfg_menu_selection_id = 24
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt16")
		}
		case 14:{
			sc_cfg_menu_selection_id = 26
			if (sc_cfg_type == 3)
			{
				sc_cfg_menu_selection_id = 25
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt16")
		}
		case 15:{
			sc_cfg_menu_selection_id = 27
			if (sc_cfg_type == 3)
			{
				sc_cfg_menu_selection_id = 26
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt16")
		}
		case 16:{
			sc_cfg_menu_selection_id = 28
			if (sc_cfg_type == 3)
			{
				sc_cfg_menu_selection_id = 27
			}
			func_process_command(id,sc_pc_wserc,sc_pc_wshrc,0)
			client_cmd(id,"amx_shrike_control_gpt16")
		}
		case 17:{
			
			client_cmd(id,"amx_shrike_control")
		}
	}
	menu_destroy(shrike_control_menu)
	return PLUGIN_HANDLED
}

// =================================================================================================
// Read shrikebot.cfg Create new if not made by this shrike controler
// =================================================================================================
public func_sc_read_config() {
	new nibblewerfers
	if (get_cvar_num("sc_cfg_mode") == 0)
	{
		if(file_exists(sc_shrike_config))
		{
			read_file(sc_shrike_config,0,configdata_id[0],31,nibblewerfers)
			if (equali(configdata[0],configdata_id[0]))
			{
			
				for(new i=0;i<20;i++)
				{
					read_file(sc_shrike_config,i,configdata[i],31,nibblewerfers)
				}
			}
			else
			{
				delete_file(sc_shrike_config)
				func_sc_write_config()
			}
		}
		else
		{
			func_sc_write_config()
		}
	}
	if (get_cvar_num("sc_cfg_mode") == 1)
	{
		new temp_file_holder[32]
		new temp_map_holder[32]
		get_mapname(temp_map_holder,31)
		format(temp_file_holder,31,"%s%s_%s",sc_shrike_per_map_config[0],temp_map_holder,sc_shrike_per_map_config[1])
		if(file_exists(temp_file_holder))
		{
			read_file(temp_file_holder,0,configdata_id[0],31,nibblewerfers)
			if (equali(configdata[0],configdata_id[0]))
			{
			
				for(new i=0;i<20;i++)
				{
					read_file(temp_file_holder,i,configdata[i],31,nibblewerfers)
				}
			}
			else
			{
				delete_file(temp_file_holder)
				func_sc_write_config()
			}
		}
		else
		{
			func_sc_write_config()
		}
	}
}

// =================================================================================================
// Write shrikebot.cfg
// =================================================================================================
public func_sc_write_config() {
	if (get_cvar_num("sc_cfg_mode") == 0)
	{
		for(new i=0;i<20;i++)
		{	
			write_file(sc_shrike_config,configdata[i],i) 
		}
		if ( get_cvar_num("sc_show_changes") == 1)
		{
			client_print(sc_player_id_keeper,print_chat,"Syn's Shrike Control - shrikebot.cfg saved!")
		}
	}
	if (get_cvar_num("sc_cfg_mode") == 1)
	{
		new temp_file_holder[32]
		new temp_map_holder[32]
		get_mapname(temp_map_holder,31)
		format(temp_file_holder,31,"%s%s_%s",sc_shrike_per_map_config[0],temp_map_holder,sc_shrike_per_map_config[1])
		for(new i=0;i<20;i++)
		{	
			write_file(temp_file_holder,configdata[i],i) 
		}
		if ( get_cvar_num("sc_show_changes") == 1)
		{
			client_print(sc_player_id_keeper,print_chat,"Syn's Shrike Control - %s_shrikebot.cfg saved!",temp_map_holder)
		}
		
	}
}

// =================================================================================================
// Execute command
// =================================================================================================
public func_process_command(id,wserc,wshrc,type) {	
	if (type == 0)
	{
		if (wserc == 1)
		{
			format(sc_cfg_holder,31,"%s%s%s%s%s",sc_cfg_type_console[1],sc_cfg_type_console[2],sc_cfg_cmd[sc_cfg_cmd_id],sc_cfg_menu_selection[sc_cfg_menu_selection_id],sc_cfg_type_console[2])
			sc_cfg_holder2 = sc_cfg_holder
			server_cmd(sc_cfg_holder)
		}
		if (wshrc == 1)
		{
			format(sc_cfg_holder,strlen(sc_cfg_cmd[sc_cfg_cmd_id])+strlen(sc_cfg_menu_selection[sc_cfg_menu_selection_id]),"%s%s",sc_cfg_cmd[sc_cfg_cmd_id],sc_cfg_menu_selection[sc_cfg_menu_selection_id])
			sc_cfg_holder3 = sc_cfg_holder
			if (sc_cfg_type == 6)
			{
				format(configdata[17],strlen(sc_cfg_holder),"%s",sc_cfg_holder)
			}
			else
			{
				format(configdata[sc_cfg_cmd_id],strlen(sc_cfg_holder),"%s",sc_cfg_holder)
			}
		}
		if (get_cvar_num("sc_show_changes") == 1 && sc_confirmation == 0)
		{
			client_print(id,print_chat,"Syn's Shrike Control - %s",sc_cfg_holder2)
		}
		else if (get_cvar_num("sc_show_changes") == 1 && sc_confirmation == 1)
		{
			client_print(id,print_chat,"Syn's Shrike Control - %s takes effect on map change! - Save cfg!",sc_cfg_holder3)
		}
		else if (get_cvar_num("sc_show_changes") == 1 && sc_confirmation == 2)
		{
			client_print(id,print_chat,"Syn's Shrike Control - %s This can also be saved to the cfg!",sc_cfg_holder2)
		}
	}
}

// =================================================================================================
// Quick kick bots
// =================================================================================================
public func_shrike_control_kick(id,level,cid) {
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
		
	server_cmd("shr ^"max_bots 0^"")
	set_task(3.0,"func_kick",id,"",0)
	if (get_cvar_num("sc_show_changes") == 1)
	{
		client_print(id,print_chat,"Syn's Shrike Control - Quick kicked all bots.")
	}
	return PLUGIN_HANDLED
}
// Shrike bot doesn't like commands being issued immediately one after another so we have to 
// kick_all a few seconds after max_bots is set.
public func_kick() {
	server_cmd("shr ^"kick_all^"")
}

// =================================================================================================
// Quick add bots
// =================================================================================================
public func_shrike_control_add(id,level,cid) {
	if (!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED
		
	new holder[2]
	read_argv(1,holder,2)
	if (get_cvar_num("sc_show_changes") == 1)
	{
		client_print(id,print_chat,"Syn's Shrike Control - Quick added %d bots.",holder)
	}
	server_cmd("shr ^"max_bots %s^"",holder)
	return PLUGIN_HANDLED	
}

// =================================================================================================
// Remove the bots for now until further notice
// =================================================================================================
public func_remove_for_now(id,level,cid) {
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
		
	server_cmd("shr ^"max_bots 0^"")
	set_task(3.0,"func_kick",id,"",0)
	format(configdata[15],10,"max_bots 0")
	if (get_cvar_num("sc_show_changes") == 1)
	{
		client_print(id,print_chat,"Syn's Shrike Control - Bots removed for now.")
	}
	func_sc_write_config()
	return PLUGIN_HANDLED
}

// =================================================================================================
// Bring the bots back please
// =================================================================================================
public func_bring_back(id,level,cid) {
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	
	new return_holder[3]
	get_cvar_string("sc_return_bots",return_holder,2)
	server_cmd("shr ^"max_bots %s^"",return_holder)
	format(configdata[15],9+strlen(return_holder),"max_bots %s",return_holder)
	if (get_cvar_num("sc_show_changes") == 1)
	{
		client_print(id,print_chat,"Syn's Shrike Control - Brought back the bots.")
	}
	func_sc_write_config()
	return PLUGIN_HANDLED
}

// =================================================================================================
// Show current settigns in shrikebot.cfg
// =================================================================================================
public func_show_config(id,level,cid) {
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
		
	new nibblewerfers
	new show_settings[20][32]
	if (get_cvar_num("sc_cfg_mode") == 0)
	{
		if(file_exists(sc_shrike_config))
		{
			for(new i=1;i<20;i++)
			{
				read_file(sc_shrike_config,i,show_settings[i],31,nibblewerfers)
				client_print(id,print_chat,"%s",show_settings[i])
			}
		}
	}
	if (get_cvar_num("sc_cfg_mode") == 1)
	{
		new temp_file_holder[32]
		new temp_map_holder[32]
		get_mapname(temp_map_holder,31)
		format(temp_file_holder,31,"%s%s_%s",sc_shrike_per_map_config[0],temp_map_holder,sc_shrike_per_map_config[1])
		if(file_exists(temp_file_holder))
		{
			for(new i=1;i<20;i++)
			{
				read_file(temp_file_holder,i,show_settings[i],31,nibblewerfers)
				client_print(id,print_chat,"%s",show_settings[i])
			}
		}
	}
	return PLUGIN_HANDLED
}

// =================================================================================================
// Setup voting for bots on
// =================================================================================================
public func_vote_on_select(id,key) {
	new name[32] 
	get_user_name(id,name,31) 
	sc_user_voted[id] = 0
	switch (key) 
	{
		case 0:
		{
			sc_vote_keeper[id] = 1
			sc_user_voted[id] = 1
			client_print(0,print_chat,"%s voted Yes",name)
		}
		case 1:
		{
			sc_vote_keeper[id] = 0
			sc_user_voted[id] = 1
			client_print(0,print_chat,"%s voted No",name)
		}
		case 2:
		{
			sc_user_voted[id] = 0
			return PLUGIN_CONTINUE
		}
	}
	return PLUGIN_CONTINUE
}

public func_vote_on(id,level,cid) {
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED
		
	if (get_cvar_num("sc_vote_on") != 1)
	{
		client_print(id,print_chat,"Syn's Shrike Control - This feature has been disabled by admin!")
		return PLUGIN_HANDLED
	}
	sc_vote_message_type = 0
	new do_we_have_bots = 0
	new max_players[32],inum,i
	get_players(max_players,inum)
	for(i = 0; i < inum; ++i)
	{
		if (is_user_bot(max_players[i]))
		{
			do_we_have_bots = 1
		}
	}
	if (get_cvar_num("sc_vote_on") == 1 && do_we_have_bots == 0)
	{
		show_menu(0,(1<<0)|(1<<1)|(1<<2),"\yEnable Bots?\w^n1. Yes^n2. No^n3. Exit^n",get_cvar_num("sc_vote_time"), "Vote Bots On")
		set_task(get_cvar_float("sc_vote_time"),"func_get_votes",1,"",0,"",0)
	}
	if (do_we_have_bots == 1)
	{
			client_print(id,print_chat,"Syn's Shrike Control - No vote started! There are already bots playing!")
	}	
	return PLUGIN_CONTINUE
}

public func_vote_off_select(id,key) {
	new name[32] 
	get_user_name(id,name,31) 
	sc_user_voted[id] = 0
	switch (key) 
	{
		case 0:
		{
			sc_vote_keeper[id] = 1
			sc_user_voted[id] = 1
			client_print(0,print_chat,"%s voted Yes",name)
		}
		case 1:
		{
			sc_vote_keeper[id] = 0
			sc_user_voted[id] = 1
			client_print(0,print_chat,"%s voted No",name)
		}
		case 2:
		{
			sc_user_voted[id] = 0
			return PLUGIN_CONTINUE
		}
	}
	return PLUGIN_CONTINUE
}

public func_vote_off(id,level,cid) {
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED
		
	if (get_cvar_num("sc_vote_on") != 1)
	{
		client_print(id,print_chat,"Syn's Shrike Control - This feature has been disabled by admin!")
		return PLUGIN_HANDLED
	}
	sc_vote_message_type = 1
	new do_we_have_bots = 0
	new max_players[32],inum,i
	get_players(max_players,inum)
	for(i = 0; i < inum; ++i)
	{
		if (is_user_bot(max_players[i]))
		{
			do_we_have_bots = 1
		}
	}
	if (get_cvar_num("sc_vote_on") == 1 && do_we_have_bots == 1)
	{
		show_menu(0,(1<<0)|(1<<1)|(1<<2),"\yDisable Bots?\w^n1. Yes^n2. No^n3. Exit^n",get_cvar_num("sc_vote_time"), "Vote Bots Off")
		set_task(get_cvar_float("sc_vote_time"),"func_get_votes",1,"",0,"",0)
	}
	if (do_we_have_bots == 0)
	{
			client_print(id,print_chat,"Syn's Shrike Control - No vote started! There are already no bots playing!")
	}	
	return PLUGIN_CONTINUE
}

public func_get_votes() {
	new max_players[32],inum,i
	new yes,no
	get_players(max_players,inum,"c")
	for(i = 0; i < inum; ++i)
	{
		if (is_user_connected(max_players[i]) == 1 && sc_user_voted[max_players[i]] == 1)
		{
			
			if (sc_vote_keeper[max_players[i]] == 1)
			{
				yes = yes + 1
			}
			if (sc_vote_keeper[max_players[i]] == 0)
			{
				no = no + 1
			}
		}
	}
	if (yes > no && sc_vote_message_type == 0)
	{
		client_print(0,print_chat,"Syn's Shrike Control - Enable bots voting successful!")
		server_cmd("shr ^"%s^"",configdata[15])
	}
	if (yes > no && sc_vote_message_type == 1)
	{
		client_print(0,print_chat,"Syn's Shrike Control - Disable bots voting successful!")
		server_cmd("shr ^"max_bots 0^"")
		sc_bots_voted = 1
		set_task(3.0,"func_kick",20,"",0)
	}
	if (yes < no && sc_vote_message_type == 0)
	{
		client_print(0,print_chat,"Syn's Shrike Control - Enable bots voting failed!")
	}
	if (yes < no && sc_vote_message_type == 1)
	{
		client_print(0,print_chat,"Syn's Shrike Control - Disable bots voting failed!")
	}
	if (yes == no && sc_vote_message_type == 0)
	{
		client_print(0,print_chat,"Syn's Shrike Control - Enable bots vote tied! Voting failed! ")
	}
	if (yes == no && sc_vote_message_type == 1)
	{
		client_print(0,print_chat,"Syn's Shrike Control - Disable bots vote tied! Voting failed! ")
	}


}

// =================================================================================================
// Switch out config type
// =================================================================================================
public func_change_cfg(id,level,cid) {
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED
		
	new nibblewerfers
	if (get_cvar_num("sc_maps_list") == 0)
	{
		if (get_cvar_num("sc_cfg_mode") == 0)
		{
			if (get_cvar_num("sc_show_changes") == 1)
			{
				client_print(id,print_chat,"Syn's Shrike Control - Switching to per map configs. Restart or change map!")
			}
			new maps = file_size(sc_shrike_maps_location[0],1)
			new i, temp_name[64]
			for(i = 0; i < maps; ++i)
			{
				read_file(sc_shrike_maps_location[0],i,sc_maps[i],31,nibblewerfers)
				format(temp_name,63,"%s%s_shrikebot.cfg",sc_shrike_per_map_config[0],sc_maps[i])
				for(new i=0;i<20;i++)
				{
					write_file(temp_name,configdata[i],i)
				}
			}
			set_cvar_num("sc_cfg_mode",1)
			return PLUGIN_HANDLED
		}
		if (get_cvar_num("sc_cfg_mode") == 1)
		{
			if (get_cvar_num("sc_show_changes") == 1)
			{
				client_print(id,print_chat,"Syn's Shrike Control - Switching to base config. Restart or change map!")
			}
			new maps = file_size(sc_shrike_maps_location[0],1)
			new i, temp_name[64]
			for(i = 0; i < maps; ++i)
			{
				read_file(sc_shrike_maps_location[0],i,sc_maps[i],31,nibblewerfers)
				format(temp_name,63,"%s%s_shrikebot.cfg",sc_shrike_per_map_config[0],sc_maps[i])

				delete_file(temp_name) 
			}
			set_cvar_num("sc_cfg_mode",0)
			return PLUGIN_HANDLED
		}
	}
	if (get_cvar_num("sc_maps_list") == 1)
	{
		if (get_cvar_num("sc_cfg_mode") == 0)
		{
			if (get_cvar_num("sc_show_changes") == 1)
			{
				client_print(id,print_chat,"Syn's Shrike Control - Switching to per map configs. Restart or change map!")
			}
			new maps = file_size(sc_shrike_maps_location[1],1)
			new i, temp_name[64]
			for(i = 0; i < maps; ++i)
			{
				read_file(sc_shrike_maps_location[1],i,sc_maps[i],31,nibblewerfers)
				format(temp_name,63,"%s%s_shrikebot.cfg",sc_shrike_per_map_config[0],sc_maps[i])
				for(new i=0;i<20;i++)
				{
					write_file(temp_name,configdata[i],i)
				}
			}
			set_cvar_num("sc_cfg_mode",1)
			return PLUGIN_HANDLED
		}
		if (get_cvar_num("sc_cfg_mode") == 1)
		{
			if (get_cvar_num("sc_show_changes") == 1)
			{
				client_print(id,print_chat,"Syn's Shrike Control - Switching to base config. Restart or change map!")
			}
			new maps = file_size(sc_shrike_maps_location[1],1)
			new i, temp_name[64]
			for(i = 0; i < maps; ++i)
			{
				read_file(sc_shrike_maps_location[1],i,sc_maps[i],31,nibblewerfers)
				format(temp_name,63,"%s%s_shrikebot.cfg",sc_shrike_per_map_config[0],sc_maps[i])

				delete_file(temp_name) 
			}
			set_cvar_num("sc_cfg_mode",0)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE	
		
		
}

// =================================================================================================
// Restore bots if voted off and all real players have left
// =================================================================================================
public client_disconnect(id) {
	if (get_cvar_num("sc_vote_restore") == 1 && sc_bots_voted == 1)
	{
		new max_players[32],inum
		get_players(max_players,inum)
		if (inum == 1)
		{
			server_cmd("shr ^"%s^"",configdata[15])
			
		}
	}
}

public client_connect(id) {
	sc_bots_voted = 0
}
	
