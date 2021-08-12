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
// Requires AMX Mod X & DoDx Module!
//
//
// USAGE:
// ======
//
//
// CVARs:
// ------
//
// dod_teammanager_autobalance <1/0>	=  enable/disable automatic balancing
//
// dod_teammanager_playerdiff <amount >	=  sets amount of players that a team
//					   can have more than the other before
//					   the plugin balances the teams!
//					   (default is 1, so the plugin balances
//					   once there are 2 players difference)
//
// dod_teammanager_adminimmunity <1/0>	=  enable/disable admins' immunity
//					   from being switched by AutoTeamBalancing
//
// dod_teammanager_ignorebots <1/0>	=  enable/disable excluding bots from
//					   all actions
//
// dod_teammanager_autoteamjoin <1/0>	=  enable/disable auto assigning new
//					   players to the smaller team
//
// dod_teammanager_nochangedeath <1/0>	=  enable/disable "soft" killing of
//					   players that swith team
//					   (deaths won't be increased!)
//
// dod_teammanager_spectatorlock <1/0>	=  lock/unlock Spectators by default
//
// dod_teammanager_teamslayfx <1/0>	=  enable/disable special effects
//					   for teamslay (fire explosion)
//
//
// ADMIN COMMANDs:
// ---------------
//
// amx_teamlock <teamname>       =  lock/unlock specified team
//
// amx_axis <player>             =  switch player to axis
//
// amx_allies <player>           =  switch player to allies
//
// amx_spec <player>             =  switch player to spec
//
// amx_lock <player>             =  lock/unlock player to/from
//                                  his current team
//
// amx_slayteam <teamname>       =  slay specified team
//                                  (admins stay alive!)
//
// amx_adminteam <teamname>      =  switch all admins to specified
//                                  team and all public players to
//                                  the opposite team.
//                                  (admin team will be auto-locked)
//
// amx_swapteams                 =  switch axis to allies and vice versa
//                                  (including admins!)
//
// amx_kickteam <teamname>       =  kick all players of specified team
//                                  (admins excluded!)
//
// amx_balanceteams              =  remove team locks and balance
//
//
//
// DESCRIPTION:
// ============
//
// This Plugin is for Day of Defeat ONLY!
//
// This is a very effective (maybe even the most effective)
// AutoTeamBlancer for Day of Defeat! Admins basically don't
// have to care about even (by number of players!) teams
// anymore as it's all handled by the plugin.
// Furthermore there's a bunch of nice features for team
// management included.
//
//
// FEATURES:
// =========
//
// AutoTeamBalancer:
// - team checking independent from scoreboard
//   (sometimes DoD shows players in a team which
//   just started to connect to the server)
// - if the axis and allied team are even, a new player can
//   choose any of both.
// - if axis team has 1 player more than allied team, new player
//   can only join the allied team and vice versa.
// - if the teams are even players can't switch teams
//   (don't we all hate those "winning-team-joiners?)
// - "Auto-Assign" obeys locked teams
// - new players that chose a locked team can automatically
//   be assigned to the unlocked team
// - the team "spectators" can be locked by default
// - if a player leaves, the teams are checked and the next killed
//   player of the team with more players will be switched over
//   to balance the teams.
// - admins can still manually switch players when the teams are uneven.
// - ability to manually start a team check/balance after moving players
// - admins can switch teams and join spectators
// - admis are not auto-switched to balance the teams
//   (if dod_teammanager_adminimmunity is set to 1)
// - if teams are even and an admin switches and makes the teams uneven,
//   another non-admin player will automatically be switched to balance
//   again.
// - bots can be ignored, so only human players are counted/balanced
//
// Additional Features:
// - bots can completely be excluded from all actions
// - no death when switching teams
// - teams can be locked (Axis OR Allies) & Specatators
// - admins can slay a team whole team
// - teams can be swapped
// - admins and public players can be devided into teams
// - players can be switched independent from balancing
//   and can be locked/unlocked to/from teams
// - teams can completely be kicked
// - admins are immune to all (but the swapteam) command(s).
//
//
//
//
// CHANGELOG:
// ==========
//
// - 25.11.2004 Version 0.5beta
//   Initial Release
//
// - 27.11.2004 Version 0.6beta
//   added features:
//   - slay/respawn teams
//   - swap teams
//   - kick teams
//   - switch players with option
//     to lock them
//   - all admins to one team,
//     all public players to the other
//     and lock the admin team
//   generic changes:
//   - DoDx module is required now
//   - name changed to "DoD TeamManager"
//
// - 29.11.2004 Version 0.7beta
//   added feature:
//   - players don't get their deaths
//     increased anymore when they switch
//     teams as they don't really die before
//     they change team.
//   bug fixes:
//   - kickteam is working now
//   - autoswitching of players should
//     work fine as well now
//   generic changes:
//   - changed team "spectators" to "spec"
//     as it's faster to type in your
//     commands.
//   - renamed command "amx_checkteams"
//     to "amx_balanceteams" and changed
//     the way it works.
//     it now removes all locks from teams
//     and balances them.
//     player specific locks stay active!
//
// - 01.12.2004 Version 0.8beta
//   added feature:
//   - new players can automatically be sent
//     to the unlocked team if they chose a
//     locked team.
//     (new cvar: dod_teammanager_autojointeam <1/0>)
//   bug fixes:
//   - optimized swapteams and adminteam features,
//     this should prevent the server from crashing
//     when there are a lot of players as the processing
//     load was decreased by 50%
//   - fixed minor bugs with "Auto-Assign" handling
//
// - 08.12.2004 Version 0.85beta
//   - players can't be switched to even the
//     teams two times in a row anymore.
//
// - 12.12.2004 Version 0.90beta
//   - optimized the swap teams feature again
//   - fixed some minor bugs
//
// - 13.07.2005 Version 0.91beta
//   just a little update:
//   - added cvar "dod_teammanager_autobalance" to enable/disable
//     automatic team balancing  
//
// - 08.08.2005 Version 0.95beta
//   * major upgrades:
//     - bots can be excluded from all actions
//     - added special effects for slayteam command
//     - simplified/optimized all commands (review them!)
//     - fixed bugs in slayteam commands
//     - added/changed cvars (review them!)
//
// - 17.08.2005 Version 0.95beta2
//   just a little update:
//   - added cvar "dod_teammanager_playerdiff" with what you can
//     specify the amount of players that one team can have
//     more than the other before the plugin auto balances
//     (default is 1 player difference, so plugin balances
//      if one team has 2 players more)
//   NOTE: this only applies for the auto balancer, so don't
//         that players can still get on a team with more
//         players!
//
// - 22.04.2006 Version 1.0
//   ( Thx goes to cadav0r )
//   just little update:
//   - added mutlilanguage support
//   - added admin show acitvity
//   - fixed adressee message
//
// - 17.06.2007 Version 1.1 BETA
//   - optimized player-per-team calculation
//     now using "dod_client_changeteam" to determine
//     the number of players per team
//   - now only dead players will be switched to
//     balance uneven teams with using "client_death"
//     to check the teams
//   - now using "get_pcvar_num" instead of the old
//     "get_cvar_num"
//   - minor code optimizations
//
// - 19.06.2007 Version 1.2
//   - first of all BIG thanks to diamond-optic for his
//     great help getting into scripting again a bit better!
//   - changed from "dod_client_changeteam" to hooking
//     the "PTeam"-Message again as bots weren't counted
//   - optimized switching dead players with adding 0.1second
//     delay, so the game doesn't count a normal kill as teamkill
//   - added complete recalculation of players on "dod_client_spawn"
//     so the calculation cannot be messed up anymore with players
//     disconnecting without "client_disconnect" being called
//   - added new cvar "dod_teammanager_adminimmunity" to have the ability
//     to let the TeamManager Autobalance even switch admins to
//     balance the teams
//   - fixed command "amx_balanceteams", now the teams are balanced
//     immediately no matter if players are dead or alive.
//   - fixed some minor problems concerning bots
//   - fixed switching players to a wrong team
//
// - 21.06.2007 Version 1.3
//   - once again thanks to diamond-optic for helping me out a bit
//   - added team calculation & balancing on round end in addition
//     to only switching killed players to balance.
//   - player-per-team calculation should be bullet-proof now
//
// - 02.07.2007 Version 1.4
//   - added round state "Draw" to team balancing events
//   - renamed all cvars, please review them!
//   - added global tracking cvar
//

#include <amxmodx>
#include <amxmisc>
#include <dodx>

#define ADMIN_TEAM ADMIN_RESERVATION

//
// DO NOT CHNAGE ANYTHING FROM HERE ON UNLESS YOU
// REALLY KNOW WHAT YOU ARE DOING!
//

#define SPECS 3
#define RANDOM 5

new g_dod_teammanager_spectatorlock, g_dod_teammanager_autojointeam, g_dod_teammanager_nochangedeath, g_dod_teammanager_autobalance, g_dod_teammanager_playerdiff, g_dod_teammanager_ignorebots, g_dod_teammanager_adminimmunity, g_dod_teammanager_slayteamfx

new g_team_axis = 0, g_team_allies = 0, g_team_spec = 0
new g_player_axis[33], g_player_allies[33], g_player_spec[33], g_player_locked[33], g_autoswitch_lock[33]
new g_lock_allies = 0, g_lock_axis = 0, g_team_balance = 1
new teamburn


public plugin_init()
{
	register_plugin("DoD TeamManager","1.4","AMXX DoD Team")
	register_cvar("dod_teammanager_plugin", "Version 1.4 by FeuerSturm | www.dodplugins.net", FCVAR_SERVER|FCVAR_SPONLY)
	register_statsfwd(XMF_DEATH)
	set_cvar_num("mp_teamlimit",0)
	g_dod_teammanager_spectatorlock = register_cvar("dod_teammanager_spectatorlock","0")
	g_dod_teammanager_autojointeam = register_cvar("dod_teammanager_autojointeam","1")
	g_dod_teammanager_nochangedeath = register_cvar("dod_teammanager_nochangedeath","1")
	g_dod_teammanager_autobalance = register_cvar("dod_teammanager_autobalance","1")
	g_dod_teammanager_playerdiff = register_cvar("dod_teammanager_playerdiff","1")
	g_dod_teammanager_ignorebots = register_cvar("dod_teammanager_ignorebots","0")
	g_dod_teammanager_adminimmunity = register_cvar("dod_teammanager_adminimmunity","1")
	g_dod_teammanager_slayteamfx = register_cvar("dod_teammanager_slayteamfx","1")
	register_concmd("amx_teamlock","admin_teamlock",ADMIN_BAN,"<teamname> = lock/unlock specified team")
	register_concmd("amx_axis","admin_axis",ADMIN_BAN,"<player> = switch player to axis")
	register_concmd("amx_allies","admin_allies",ADMIN_BAN,"<player> = switch player to allies")
	register_concmd("amx_spec","admin_spec",ADMIN_KICK,"<player> = switch player to spec")
	register_concmd("amx_lock","admin_lock",ADMIN_BAN,"<player> = lock/unlock player to/from his current team")
	register_concmd("amx_slayteam","admin_slayteam",ADMIN_BAN,"<team> = slay specified team")
	register_concmd("amx_adminteam","admin_adminteam",ADMIN_BAN,"<team> = move admins to specified team and others to the opposite")
	register_concmd("amx_swapteams","admin_swapteams",ADMIN_BAN,"swap all players' teams")
	register_concmd("amx_kickteam","admin_kickteam",ADMIN_BAN,"<team> = kick specified team")
	register_concmd("amx_balanceteams","admin_balanceteams",ADMIN_VOTE,"= check & balance teams")	
	register_clcmd("jointeam","handle_teamjoin")
	register_event("RoundState","roundend_calculate","a","1=3","1=4","1=5")
	register_message(get_user_msgid("PTeam"), "hook_team")
	register_dictionary("dod_teammanager.txt")
}

public plugin_precache(){
	teamburn = precache_model("sprites/explode1.spr") 
}

public client_authorized(id)
{
	g_player_axis[id] = 0
	g_player_allies[id] = 0
	g_player_spec[id] = 0
	g_player_locked[id] = 0
	g_autoswitch_lock[id] = 0
}

public client_death(killer,victim,wpnindex,hitplace,TK)
{
	if(!is_user_connected(victim) || g_player_locked[victim] || g_autoswitch_lock[victim])
		return PLUGIN_CONTINUE
		
	if (get_user_flags(victim) & ADMIN_TEAM && get_pcvar_num(g_dod_teammanager_adminimmunity))
		return PLUGIN_CONTINUE

	if(is_user_bot(victim) && get_pcvar_num(g_dod_teammanager_ignorebots))
		return PLUGIN_CONTINUE
		
	if(g_team_balance && get_pcvar_num(g_dod_teammanager_autobalance))
		{
		new diff = get_pcvar_num(g_dod_teammanager_playerdiff)
		
		if(diff < 1)
			diff = 1
		
		new playerteam = get_user_team(victim)
		
		if(playerteam == AXIS && ((g_team_axis - g_team_allies) > diff)){
			new param[2]
			param[0] = victim
			param[1] = ALLIES
			set_task(0.1,"teamswitch_player",0,param,2)
		}
		else if(playerteam == ALLIES && ((g_team_allies - g_team_axis) > diff)){ 
			new param[2]
			param[0] = victim
			param[1] = AXIS
			set_task(0.1,"teamswitch_player",0,param,2)
		}	
	}
	
	return PLUGIN_CONTINUE
}

public teamswitch_player(param[]){
	new playerid = param[0]
	new newteam = param[1]
	if(is_user_connected(playerid) && !is_user_alive(playerid)){
		new playername[32]
		get_user_name(playerid,playername,31)	
		if(newteam == ALLIES){
			engclient_cmd(playerid,"jointeam","1")
			client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"AUTOSWITCHALLIED",playername)
		}
		else if(newteam == AXIS){
			engclient_cmd(playerid,"jointeam","2")
			client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"AUTOSWITCHAXIS",playername)
		}		
		if(is_user_bot(playerid)){
			engclient_cmd(playerid,"cls_random")
		}
		new lockswitch[32],pnum_lock
		get_players(lockswitch, pnum_lock)
		
		for(new i=0; i<pnum_lock; i++){
			new player_ids = lockswitch[i]	
			if(is_user_connected(player_ids) && g_autoswitch_lock[player_ids])
				g_autoswitch_lock[player_ids] = 0
		}
		g_autoswitch_lock[playerid] = 1
	}
}	

public dod_client_spawn(id){
	set_task(0.1,"team_calculation")
	return PLUGIN_CONTINUE
}

public team_calculation(){
	g_team_allies = 0
	g_team_axis = 0
	g_team_spec = 0
	new client[32], players
	
	if(get_pcvar_num(g_dod_teammanager_ignorebots))
		get_players(client,players,"ch")
	else
		get_players(client,players,"h")
	
	for(new i=0; i<players; i++){
		new client_id = client[i]
		new client_team = get_user_team(client_id)
		if(is_user_connected(client_id) && !is_user_connecting(client_id) && client_team){
			g_player_axis[client_id] = 0
			g_player_allies[client_id] = 0
			g_player_spec[client_id] = 0
			if(client_team == ALLIES){
				g_team_allies++
				g_player_allies[client_id] = 1
			}
			else if(client_team == AXIS){
				g_team_axis++
				g_player_axis[client_id] = 1
			}
			else if(client_team == SPECS){
				g_team_spec++
				g_player_spec[client_id] = 1
			}
		}
	}
	return PLUGIN_CONTINUE
}

public roundend_calculate(){
	team_calculation()
	if (get_pcvar_num(g_dod_teammanager_autobalance) == 1 && g_team_balance == 1){
		set_task(0.1,"check_teams")
	}
	return PLUGIN_CONTINUE
}

public client_disconnect(id)
{
	if(g_player_axis[id])
		g_team_axis--
	else if(g_player_allies[id])
		g_team_allies--
	else if(g_player_spec[id])
		g_team_spec--
	
	g_player_axis[id] = 0
	g_player_allies[id] = 0
	g_player_spec[id] = 0
	g_player_locked[id] = 0
	g_autoswitch_lock[id] = 0
}

public hook_team()
{
	new id = get_msg_arg_int(1)
	new team = get_msg_arg_int(2)
		
	if(is_user_bot(id) && get_pcvar_num(g_dod_teammanager_ignorebots))
		return PLUGIN_CONTINUE
		
	if(g_player_axis[id])
		g_team_axis--
	else if(g_player_allies[id])
		g_team_allies--
	else if(g_player_spec[id])
		g_team_spec--
		
	if(team == AXIS)
		{
		g_team_axis++
		g_player_axis[id] = 1
		g_player_allies[id] = 0
		g_player_spec[id] = 0
		}
	else if(team == ALLIES)
		{
		g_team_allies++
		g_player_axis[id] = 0
		g_player_allies[id] = 1
		g_player_spec[id] = 0
		}
	else if(team == SPECS)
		{
		g_team_spec++
		g_player_axis[id] = 0
		g_player_allies[id] = 0
		g_player_spec[id] = 1
		}

	return PLUGIN_CONTINUE
}

public handle_teamjoin(id)
{
	if(is_user_bot(id) && get_pcvar_num(g_dod_teammanager_ignorebots))
		return PLUGIN_CONTINUE
	
	new team_s[2]
	read_argv(1,team_s,2)
	new team = str_to_num(team_s)
		
	if(team == ALLIES)
		{
		if(g_player_locked[id])
			{
			if(g_player_axis[id])
				{
				client_print(id,print_chat,"[DoD TeamManager] %L",id,"LOCKAXISCANTALLIED")
				return PLUGIN_HANDLED
				}
			else if(g_player_spec[id])
				{
				client_print(id,print_chat,"[DoD TeamManager] %L",id,"LOCKSPECCANTALLIED")
				return PLUGIN_HANDLED
				}
			}
		else if(g_team_allies > g_team_axis && g_team_balance && get_pcvar_num(g_dod_teammanager_autobalance) && !(get_user_flags(id) & ADMIN_TEAM))
			{
			if(get_pcvar_num(g_dod_teammanager_autojointeam) && !g_player_axis[id] && !g_player_allies[id] && !g_player_spec[id])
				{
				engclient_cmd(id,"jointeam","2")
				
				if(is_user_bot(id))
					engclient_cmd(id,"cls_random")
				
				client_print(id,print_chat,"[DoD TeamManager] %L",id,"SENTAXIS")
				return PLUGIN_HANDLED
				}
			else 
				{
				client_print(id,print_chat,"[DoD TeamManager] %L",id,"TEAMEVENALLIED")
				return PLUGIN_HANDLED
				}
			}
		else if(g_lock_allies && !(get_user_flags(id) & ADMIN_TEAM))
			{
			if(get_pcvar_num(g_dod_teammanager_autojointeam) && !g_player_axis[id] && !g_player_allies[id] && !g_player_spec[id])
				{
				engclient_cmd(id,"jointeam","2")
				
				if(is_user_bot(id))
					engclient_cmd(id,"cls_random")
				
				client_print(id,print_chat,"[DoD TeamManager] %L",id,"LOCKALLIEDSENTAXIS")
				return PLUGIN_HANDLED
				}
			else
				{
				client_print(id,print_chat,"[DoD TeamManager] %L",id,"CANTALLIEDLOCK")
				return PLUGIN_HANDLED
				}
			}
		else if(g_team_allies == g_team_axis && g_player_axis[id] && g_team_balance && get_pcvar_num(g_dod_teammanager_autobalance) && !(get_user_flags(id) & ADMIN_TEAM))
			{
			client_print(id,print_chat,"[DoD TeamManager] %L",id,"TEAMEVENALLIED")
			return PLUGIN_HANDLED
			}
		else if(g_team_balance && get_pcvar_num(g_dod_teammanager_autobalance) && get_user_flags(id) & ADMIN_TEAM)
			{
			if(is_user_alive(id) && get_pcvar_num(g_dod_teammanager_nochangedeath))
				dod_user_kill(id)
			
			return PLUGIN_CONTINUE
			}
		else
			{
			if(is_user_alive(id) && get_pcvar_num(g_dod_teammanager_nochangedeath))
				dod_user_kill(id)
			
			return PLUGIN_CONTINUE
			}
		}
	else if(team == AXIS)
		{
		if(g_player_locked[id])
			{
			if(g_player_allies[id])
				{
				client_print(id,print_chat,"[DoD TeamManager] %L",id,"LOCKALLIEDCANTAXIS")
				return PLUGIN_HANDLED
				}
			else if(g_player_spec[id])
				{
				client_print(id,print_chat,"[DoD TeamManager] %L",id,"LOCKSPECCANTAXIS")
				return PLUGIN_HANDLED
				}
			}
		else if(g_team_allies < g_team_axis && g_team_balance && get_pcvar_num(g_dod_teammanager_autobalance) && !(get_user_flags(id) & ADMIN_TEAM))
			{
			if(get_pcvar_num(g_dod_teammanager_autojointeam) && !g_player_axis[id] && !g_player_allies[id] && !g_player_spec[id])
				{
				engclient_cmd(id,"jointeam","1")
				
				if(is_user_bot(id))
					engclient_cmd(id,"cls_random")
				
				client_print(id,print_chat,"[DoD TeamManager] %L",id,"SENTALLIED")
				return PLUGIN_HANDLED
				}
			else
				{
				client_print(id,print_chat,"[DoD TeamManager] %L",id,"TEAMEVENAXIS")
				return PLUGIN_HANDLED
				}
			}
		else if(g_lock_axis && !(get_user_flags(id) & ADMIN_TEAM))
			{
			if(get_pcvar_num(g_dod_teammanager_autojointeam) && !g_player_axis[id] && !g_player_allies[id] && !g_player_spec[id])
				{
				engclient_cmd(id,"jointeam","1")
				
				if(is_user_bot(id))
					engclient_cmd(id,"cls_random")
				
				client_print(id,print_chat,"[DoD TeamManager] %L",id,"LOCKAXISSENTALLIED")
				return PLUGIN_HANDLED
				}
			else
				{
				client_print(id,print_chat,"[DoD TeamManager] %L",id,"CANTAXISLOCK")
				return PLUGIN_HANDLED
				}
			}
		else if(g_team_allies == g_team_axis && g_player_allies[id] && g_team_balance && get_pcvar_num(g_dod_teammanager_autobalance) && !(get_user_flags(id) & ADMIN_TEAM))
			{
			client_print(id,print_chat,"[DoD TeamManager] %L",id,"TEAMEVENAXIS")
			return PLUGIN_HANDLED
			}
		else if(g_team_balance && get_pcvar_num(g_dod_teammanager_autobalance) && get_user_flags(id) & ADMIN_TEAM)
			{
			if(is_user_alive(id) && get_pcvar_num(g_dod_teammanager_nochangedeath))
				dod_user_kill(id)
			
			return PLUGIN_CONTINUE
			}
		else 
			{
			if(is_user_alive(id) && get_pcvar_num(g_dod_teammanager_nochangedeath))
				dod_user_kill(id)

			return PLUGIN_CONTINUE
			}
		}
	else if(team == RANDOM)
		{
		if(g_player_locked[id])
			{
			if(g_player_allies[id])
				{
				client_print(id,print_chat,"[DoD TeamManager] %L",id,"YOURLOCKALLIED")
				return PLUGIN_HANDLED
				}
			else if(g_player_axis[id])
				{
				client_print(id,print_chat,"[DoD TeamManager] %L",id,"YOURLOCKAXIS")
				return PLUGIN_HANDLED
				}
			else if(g_player_spec[id])
				{
				client_print(id,print_chat,"[DoD TeamManager] %L",id,"YOURLOCKSPEC")
				return PLUGIN_HANDLED
				}
			}
		else if(g_team_allies > g_team_axis && g_team_balance && get_pcvar_num(g_dod_teammanager_autobalance) && !(get_user_flags(id) & ADMIN_TEAM))
			{
			if(is_user_alive(id) && !g_player_axis[id])
				dod_user_kill(id)

			engclient_cmd(id,"jointeam","2")
			
			if(is_user_bot(id))
				engclient_cmd(id,"cls_random")
			
			return PLUGIN_HANDLED
			}
		else if(g_team_allies < g_team_axis && g_team_balance && get_pcvar_num(g_dod_teammanager_autobalance) && !(get_user_flags(id) & ADMIN_TEAM))
			{
			if(is_user_alive(id) && !g_player_allies[id])
				dod_user_kill(id)
			
			engclient_cmd(id,"jointeam","1")
			
			if(is_user_bot(id))
				engclient_cmd(id,"cls_random")
			
			return PLUGIN_HANDLED
			}
		else if(g_team_allies == g_team_axis && (g_player_allies[id] || g_player_axis[id]) && g_team_balance && get_pcvar_num(g_dod_teammanager_autobalance) && !(get_user_flags(id) & ADMIN_TEAM))
			return PLUGIN_HANDLED

		else if(g_lock_axis && !g_team_balance && !(get_user_flags(id) & ADMIN_TEAM))
			{
			if(is_user_alive(id) && !g_player_allies[id])
				dod_user_kill(id)
				
			engclient_cmd(id,"jointeam","1")
			
			if(is_user_bot(id))
				engclient_cmd(id,"cls_random")
			
			return PLUGIN_HANDLED
			}
		else if(g_lock_allies && !g_team_balance && !(get_user_flags(id) & ADMIN_TEAM))
			{
			if(is_user_alive(id) && !g_player_axis[id])
				dod_user_kill(id)

			engclient_cmd(id,"jointeam","2")
			
			if(is_user_bot(id))
				engclient_cmd(id,"cls_random")
			
			return PLUGIN_HANDLED
			}
		else if(g_team_balance && get_pcvar_num(g_dod_teammanager_autobalance) && get_user_flags(id) & ADMIN_TEAM)
			{
			if(is_user_alive(id) && get_pcvar_num(g_dod_teammanager_nochangedeath))
				dod_user_kill(id)
			
			return PLUGIN_CONTINUE
			}
		else
			{
			if(is_user_alive(id) && get_pcvar_num(g_dod_teammanager_nochangedeath))
				dod_user_kill(id)

			return PLUGIN_CONTINUE
			}
		}
	else if(team == SPECS)
		{
		if(g_player_locked[id])
			{
			if(g_player_allies[id])
				{
				client_print(id,print_chat,"[DoD TeamManager] %L",id,"YOURLOCKALLIEDCANTSPEC")
				return PLUGIN_HANDLED
				}
			else if(g_player_axis[id])
				{
				client_print(id,print_chat,"[DoD TeamManager] %L",id,"YOURLOCKAXISCANTSPEC")
				return PLUGIN_HANDLED
				}
			}
		else if(get_pcvar_num(g_dod_teammanager_spectatorlock) && !(get_user_flags(id) & ADMIN_TEAM))
			{
			client_print(id,print_chat,"[DoD TeamManager] Only Admins can join Spectators!")
			return PLUGIN_HANDLED
			}
		else if(get_pcvar_num(g_dod_teammanager_spectatorlock) && g_team_balance && get_pcvar_num(g_dod_teammanager_autobalance) && get_user_flags(id) & ADMIN_TEAM)
			{
			if(is_user_alive(id) && get_pcvar_num(g_dod_teammanager_nochangedeath))
				dod_user_kill(id)
			
			return PLUGIN_CONTINUE
			}
		else if(!get_pcvar_num(g_dod_teammanager_spectatorlock) && g_team_balance && get_pcvar_num(g_dod_teammanager_autobalance))
			{
			if(is_user_alive(id) && get_pcvar_num(g_dod_teammanager_nochangedeath))
				dod_user_kill(id)
			
			return PLUGIN_CONTINUE
			}
		else 
			{
			if(is_user_alive(id) && get_pcvar_num(g_dod_teammanager_nochangedeath))
				dod_user_kill(id)
			
			return PLUGIN_CONTINUE
			}
	}
	return PLUGIN_CONTINUE
}

public admin_balanceteams(id,level,cid)
{
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
		
	g_lock_allies = 0
	g_lock_axis = 0
	g_team_balance = 1
	
	client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"BALANCETEAM")
	check_teams()
	return PLUGIN_HANDLED
}

public check_teams(){
	new diff = get_pcvar_num(g_dod_teammanager_playerdiff)
	if(diff < 1){
		diff = 1
	}
	if((g_team_axis - g_team_allies) > diff){
		new switchallies = check_axis()
		if(switchallies != 0){
			new moveallies[32]
			get_user_name(switchallies,moveallies,31)
			new switchindex = get_user_index(moveallies)
			client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"AUTOSWITCHALLIED",moveallies)
			if(is_user_alive(switchindex) == 1){
				dod_user_kill(switchindex)
			}
			engclient_cmd(switchindex,"jointeam","1")
			new plist_lock[32],pnum_lock
			get_players(plist_lock, pnum_lock)
			for(new i=0; i<pnum_lock; i++){
				if(is_user_connected(plist_lock[i]) && g_autoswitch_lock[plist_lock[i]] == 1){
					g_autoswitch_lock[plist_lock[i]] = 0
				}
			}
			g_autoswitch_lock[switchindex] = 1
			set_task(1.0,"check_teams")
			return PLUGIN_HANDLED
		}
	}
	else if((g_team_allies - g_team_axis) > diff){
		new switchaxis = check_allies()
		if(switchaxis != 0){
			new moveaxis[32]
			get_user_name(switchaxis,moveaxis,31)
			new switchindex = get_user_index(moveaxis)
			client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"AUTOSWITCHAXIS",moveaxis)
			if(is_user_alive(switchindex) == 1){
				dod_user_kill(switchindex)
			}
			engclient_cmd(switchindex,"jointeam","2")
			new plist_lock[32],pnum_lock
			get_players(plist_lock, pnum_lock)
			for(new i=0; i<pnum_lock; i++){
				if(is_user_connected(plist_lock[i]) && g_autoswitch_lock[plist_lock[i]] == 1){
					g_autoswitch_lock[plist_lock[i]] = 0
				}
			}
			g_autoswitch_lock[switchindex] = 1
			set_task(1.0,"check_teams")
			return PLUGIN_HANDLED
		}
	}
	else {
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

check_axis(){
	new ignorebots = get_pcvar_num(g_dod_teammanager_ignorebots)
	new maxslots = get_maxplayers()
	new switchme = 0, playtime, unlimited = 0x7fffffff
	for(new i = 1; i <= maxslots; ++i){
		if(!is_user_connected(i)) continue
		if(get_user_flags(i)&ADMIN_TEAM) continue
		if(!g_player_axis[i]) continue
		if(g_player_locked[i]) continue
		if(g_autoswitch_lock[i]) continue
		if(is_user_bot(i) && ignorebots) continue
		playtime = get_user_time(i)
		if(unlimited > playtime){
			unlimited = playtime
			switchme = i
		}
	}
	return switchme
}

check_allies(){
	new ignorebots = get_pcvar_num(g_dod_teammanager_ignorebots)
	new maxslots = get_maxplayers()
	new switchme = 0, playtime, unlimited = 0x7fffffff
	for(new i = 1; i <= maxslots; ++i){
		if(!is_user_connected(i)) continue
		if(get_user_flags(i)&ADMIN_TEAM) continue
		if(!g_player_allies[i]) continue
		if(g_player_locked[i]) continue
		if(g_autoswitch_lock[i]) continue
		if(is_user_bot(i) && ignorebots) continue
		playtime = get_user_time(i)
		if(unlimited > playtime){
			unlimited = playtime
			switchme = i
		}
	}
	return switchme
}

public admin_teamlock(id,level,cid)
	{
	if (!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED
		
	new lockteam[10], adminname[32]
	read_argv(1,lockteam,10)
	get_user_name(id,adminname,31)
	
	if(equali(lockteam,"allies"))
		{
		if(!g_lock_allies && !g_lock_axis)
			{
			g_lock_allies = 1
			g_team_balance = 0
			
			switch(get_cvar_num("amx_show_activity"))
				{
				case 2: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"LOCKALLIEDA",adminname)
				case 1: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"LOCKALLIED")
				case 0: client_print(id,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"LOCKALLIED")
				}
			}
		else if(!g_lock_allies && g_lock_axis)
			client_print(id,print_chat,"[DoD TeamManager] %L",id,"UNLOCKAXISFIRST")

		else if(g_lock_allies && !g_lock_axis)
			{
			g_lock_allies = 0
			g_team_balance = 1
			
			switch(get_cvar_num("amx_show_activity"))
				{
				case 2: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"UNLOCKALLIEDA",adminname)
				case 1: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"UNLOCKALLIED")
				case 0: client_print(id,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"UNLOCKALLIED")
				}
			}
		}
	else if(equali(lockteam,"axis"))
		{
		if(!g_lock_allies && !g_lock_axis)
			{
			g_lock_axis = 1
			g_team_balance = 0
			
			switch(get_cvar_num("amx_show_activity"))
				{
				case 2: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"LOCKAXISA",adminname)
				case 1: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"LOCKAXIS")
				case 0: client_print(id,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"LOCKAXIS")
				}
			}
		else if(g_lock_allies && !g_lock_axis)
			client_print(id,print_chat,"[DoD TeamManager] %L",id,"UNLOCKALLIEDFIRST")
			
		else if(!g_lock_allies && g_lock_axis)
			{
			g_lock_axis = 0
			g_team_balance = 1
			
			switch(get_cvar_num("amx_show_activity"))
				{
				case 2: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"UNLOCKAXISA",adminname)
				case 1: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"UNLOCKAXIS")
				case 0: client_print(id,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"UNLOCKAXIS")
				}
			}
		}
	else if(equali(lockteam,"spec"))
		{
		if(!get_pcvar_num(g_dod_teammanager_spectatorlock))
			{
			switch(get_cvar_num("amx_show_activity"))
				{
				case 2: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"LOCKSPECA",adminname)
				case 1: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"LOCKSPEC")
				case 0: client_print(id,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"LOCKSPEC")
				}
				
			set_pcvar_num(g_dod_teammanager_spectatorlock,1)
			}
		else if(get_pcvar_num(g_dod_teammanager_spectatorlock))
			{
			switch(get_cvar_num("amx_show_activity"))
				{
				case 2: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"UNLOCKSPECA",adminname)
				case 1: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"UNLOCKSPEC")
				case 0: client_print(id,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"UNLOCKSPEC")
				}
				
			set_pcvar_num(g_dod_teammanager_spectatorlock,0)
			}
		}
	else
		client_print(id,print_chat,"[DoD TeamManager] %L",id,"VALIDTEAMS")
		
	return PLUGIN_HANDLED
}

public admin_axis(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED
		
	new target[32]
	read_argv(1,target,31)
	
	new player = cmd_target(id,target,1)
	
	if(!player)
		return PLUGIN_HANDLED

	if(get_user_flags(player) & ADMIN_TEAM)
		{
		client_print(id,print_chat,"[DoD TeamManager] %L",id,"CANTSWITCHADMIN")
		
		return PLUGIN_HANDLED
		}
		
	new adminname[32], playername[32]
	get_user_name(id,adminname,31)
	get_user_name(player,playername,31)
	
	if(g_player_axis[player])
		client_print(id,print_chat,"[DoD TeamManager] %L",id,"ALREADYINAXIS",playername)

	else if(g_player_allies[player] || g_player_spec[player])
		{
		switch(get_cvar_num("amx_show_activity"))
			{
			case 2: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SWITCHINAXISA",adminname,playername)
			case 1: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SWITCHINAXIS",playername)
			case 0: client_print(id,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SWITCHINAXIS",playername)
			}
			
		if(is_user_alive(player))
			dod_user_kill(player)

		engclient_cmd(player,"jointeam","2")
		
		if(is_user_bot(player))
			engclient_cmd(player,"cls_random")
		}
		
	return PLUGIN_HANDLED
}

public admin_allies(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED
		
	new target[32]
	read_argv(1,target,31)
	new player = cmd_target(id,target,1)
	
	if(!player)
		return PLUGIN_HANDLED
	
	if(get_user_flags(player) & ADMIN_TEAM)
		{
		client_print(id,print_chat,"[DoD TeamManager] %L",id,"CANTSWITCHADMIN")
		
		return PLUGIN_HANDLED
		}
		
	new adminname[32], playername[32]
	get_user_name(id,adminname,31)
	get_user_name(player,playername,31)
	
	if(g_player_allies[player])
		client_print(id,print_chat,"[DoD TeamManager] %L",id,"ALREADYINALLIED",playername)

	else if(g_player_axis[player] || g_player_spec[player])
		{
		switch(get_cvar_num("amx_show_activity"))
			{
			case 2: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SWITCHINALLIEDA",adminname,playername)
			case 1: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SWITCHINALLIED",playername)
			case 0: client_print(id,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SWITCHINALLIED",playername)
			}
			
		if(is_user_alive(player))
			dod_user_kill(player)

		engclient_cmd(player,"jointeam","1")
		
		if(is_user_bot(player))
			engclient_cmd(player,"cls_random")
		}
		
	return PLUGIN_HANDLED
}

public admin_spec(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED
		
	new target[32]
	read_argv(1,target,31)
	
	new player = cmd_target(id,target,1)
	
	if(!player)
		return PLUGIN_HANDLED

	if(get_user_flags(player) & ADMIN_TEAM)
		{
		client_print(id,print_chat,"[DoD TeamManager] %L",id,"CANTSWITCHADMIN")
		
		return PLUGIN_HANDLED
		}
		
	new adminname[32], playername[32]
	get_user_name(id,adminname,31)
	get_user_name(player,playername,31)
	
	if(g_player_spec[player])
		client_print(id,print_chat,"[DoD TeamManager] %L",id,"ALREADYINSPEC",playername)
		
	else if(g_player_axis[player] || g_player_allies[player])
		{
		switch(get_cvar_num("amx_show_activity"))
			{
			case 2: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SWITCHINSPECA",adminname,playername)
			case 1: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SWITCHINSPEC",playername)
			case 0: client_print(id,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SWITCHINSPEC",playername)
			}
			
		if(is_user_alive(player))
			dod_user_kill(player)
		
		engclient_cmd(player,"jointeam","3")
		}
		
	return PLUGIN_HANDLED
}

public admin_lock(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED
		
	new target[32]
	read_argv(1,target,31)
	new player = cmd_target(id,target,1)
	
	if(!player)
		return PLUGIN_HANDLED
	
	if(get_user_flags(player) & ADMIN_TEAM && !(get_user_flags(id) & ADMIN_IMMUNITY))
		{
		client_print(id,print_chat,"[DoD TeamManager] %L",id,"CANTLOCKADMIN")
		return PLUGIN_HANDLED
		}
		
	new adminname[32], playername[32]
	get_user_name(id,adminname,31)
	get_user_name(player,playername,31)
	
	if(g_player_locked[player])
		{
		switch (get_cvar_num("amx_show_activity"))
			{
			case 2: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"UNLOCKPLAYERA",adminname,playername)
			case 1: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"UNLOCKPLAYER",playername)
			case 0: client_print(id,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"UNLOCKPLAYER",playername)
			}
			
		g_player_locked[player] = 0
		}
	else
		{
		switch (get_cvar_num("amx_show_activity"))
			{
			case 2: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"LOCKPLAYERA",adminname,playername)
			case 1: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"LOCKPLAYER",playername)
			case 0: client_print(id,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"LOCKPLAYER",playername)
			}
			
		g_player_locked[player] = 1
		}
		
	return PLUGIN_HANDLED
}

public admin_slayteam(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED
		
	new slayteam[10], adminname[32]
	read_argv(1,slayteam,10)
	get_user_name(id,adminname,31)
	
	if(equali(slayteam,"allies"))
		{
		new plist_public[32],pnum_public
		get_players(plist_public, pnum_public)
		
		for(new i=0; i<pnum_public; i++)
			{
			new player_id = plist_public[i]
				
			if(is_user_connected(player_id) && is_user_alive(player_id))
				{
				if(g_player_allies[player_id] && !(get_user_flags(player_id) & ADMIN_TEAM))
					{	
					if(get_pcvar_num(g_dod_teammanager_slayteamfx))
						{
						new playerorigin[3]
						get_user_origin(player_id,playerorigin)
						
						message_begin(MSG_BROADCAST,SVC_TEMPENTITY,playerorigin)   
						write_byte(3)   
						write_coord(playerorigin[0])   
						write_coord(playerorigin[1])   
						write_coord(playerorigin[2]) 
						write_short(teamburn)   
						write_byte(60)
						write_byte(10)
						write_byte(0)
						message_end()
						}				
					user_kill(player_id)
					}
				}
			}
			
		switch (get_cvar_num("amx_show_activity"))
			{
			case 2: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SLAYALLIEDA",adminname)
			case 1: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SLAYALLIED")
			case 0: client_print(id,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SLAYALLIED")
			}
		}
	else if(equali(slayteam,"axis"))
		{
		new plist_public[32],pnum_public
		get_players(plist_public, pnum_public)
		
		for(new i=0; i<pnum_public; i++)
			{
			new player_id = plist_public[i]
				
			if(is_user_connected(player_id) && is_user_alive(player_id))
				{
				if(g_player_axis[player_id] && !(get_user_flags(player_id) & ADMIN_TEAM))
					{						
					if(get_pcvar_num(g_dod_teammanager_slayteamfx))
						{
						new playerorigin[3]
						get_user_origin(player_id,playerorigin)
						
						message_begin(MSG_BROADCAST,SVC_TEMPENTITY,playerorigin)   
						write_byte(3)   
						write_coord(playerorigin[0])   
						write_coord(playerorigin[1])   
						write_coord(playerorigin[2]) 
						write_short(teamburn)   
						write_byte(60)
						write_byte(10)
						write_byte(0)
						message_end()
						}						
					user_kill(player_id)
					}
				}
			}
			
		switch(get_cvar_num("amx_show_activity"))
			{
			case 2: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SLAYAXISA",adminname)
			case 1: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SLAYAXIS")
			case 0: client_print(id,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SLAYAXIS")
			}
		}
	else 
		client_print(id,print_chat,"[DoD TeamManager] %L",id,"VALIDTEAMS")	
	
	return PLUGIN_HANDLED
}

public admin_adminteam(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED
	
	new adminteam[10], adminname[32]
	read_argv(1,adminteam,10)
	get_user_name(id,adminname,31)
	
	if(equali(adminteam,"allies"))
		{
		new plist_public[32],pnum_public
		get_players(plist_public, pnum_public)
		
		for(new i=0; i<pnum_public; i++)
			{
			new player_id = plist_public[i]
				
			if(is_user_connected(player_id))
				{
				if(g_player_allies[player_id] && !(get_user_flags(player_id) & ADMIN_TEAM))
					{
					if(is_user_alive(player_id))
						dod_user_kill(player_id)
					
					engclient_cmd(player_id,"jointeam","2")
					
					if(is_user_bot(player_id))
						engclient_cmd(player_id,"cls_random")
					
					if(g_player_locked[player_id])
						g_player_locked[player_id] = 0
					
					}
				else if(g_player_axis[player_id] && get_user_flags(player_id) & ADMIN_TEAM)
					{
					if(is_user_alive(player_id))
						dod_user_kill(player_id)
					
					engclient_cmd(player_id,"jointeam","1")
					
					if(is_user_bot(player_id))
						engclient_cmd(player_id,"cls_random")
					}
				}
			}
			
		g_lock_axis = 0
		g_lock_allies = 1
		g_team_balance = 0
		
		switch(get_cvar_num("amx_show_activity"))
			{
			case 2: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SWITHCNONADMINAXISA",adminname)
			case 1: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SWITHCNONADMINAXIS")
			case 0: client_print(id,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SWITHCNONADMINAXIS")
			}
		}
	else if(equali(adminteam,"axis"))
		{
		new plist_public[32],pnum_public
		get_players(plist_public, pnum_public)
		
		for(new i=0; i<pnum_public; i++)
			{
			new player_id = plist_public[i]
			
			if(is_user_connected(player_id))
				{
				if(g_player_axis[player_id] && !(get_user_flags(player_id) & ADMIN_TEAM))
					{
					if(is_user_alive(player_id))
						dod_user_kill(player_id)
					
					engclient_cmd(player_id,"jointeam","1")
					
					if(is_user_bot(player_id))
						engclient_cmd(player_id,"cls_random")
					
					if(g_player_locked[player_id])
						g_player_locked[player_id] = 0
					
					}
				else if(g_player_allies[player_id] && get_user_flags(player_id)& ADMIN_TEAM)
					{
					if(is_user_alive(player_id))
						dod_user_kill(player_id)
					
					engclient_cmd(player_id,"jointeam","2")
					
					if(is_user_bot(player_id))
						engclient_cmd(player_id,"cls_random")
					}
				}
			}
		
		g_lock_axis = 1
		g_lock_allies = 0
		g_team_balance = 0
		
		switch(get_cvar_num("amx_show_activity"))
			{
			case 2: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SWICHTNONADMINALLIEDA",adminname)
			case 1: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SWICHTNONADMINALLIED")
			case 0: client_print(id,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SWICHTNONADMINALLIED")
			}
		}
	else 
		client_print(id,print_chat,"[DoD TeamManager] %L",id,"VALIDTEAMS")
	
	return PLUGIN_HANDLED
}

public admin_swapteams(id,level,cid)
{
	if(!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
		
	new adminname[32]
	get_user_name(id,adminname,31)
	
	new plist_public[32],pnum_public
	get_players(plist_public, pnum_public)
	
	for(new i=0; i<pnum_public; i++)
		{
		new player_id = plist_public[i]
			
		if(is_user_connected(player_id) && g_player_axis[player_id])
			{
			if(is_user_alive(player_id))
				dod_user_kill(player_id)
			
			engclient_cmd(player_id,"jointeam","1")
			
			if(is_user_bot(player_id))
				engclient_cmd(player_id,"cls_random")
			}
		else if(is_user_connected(player_id) && g_player_allies[player_id])
			{
			if(is_user_alive(player_id))
				dod_user_kill(player_id)
			
			engclient_cmd(player_id,"jointeam","2")
			
			if(is_user_bot(player_id))
				engclient_cmd(player_id,"cls_random")
			}
		}
		
	switch(get_cvar_num("amx_show_activity"))
		{
		case 2: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SWAPPEDA",adminname)
		case 1: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SWAPPED")
		case 0: client_print(id,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"SWAPPED")
		}
		
	return PLUGIN_HANDLED
}

public admin_kickteam(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED
		
	new kickteam[10], adminname[32]
	read_argv(1,kickteam,10)
	get_user_name(id,adminname,31)
	
	if(equali(kickteam,"allies"))
		{
		new plist_public[32],pnum_public
		get_players(plist_public, pnum_public)
		
		for(new i=0; i<pnum_public; i++)
			{
			new player_id = plist_public[i]
				
			if(is_user_connected(player_id))
				if(g_player_allies[player_id] && !(get_user_flags(player_id) & ADMIN_TEAM))
					server_cmd("kick #%d %L",get_user_userid(player_id),"KICKALLIEDREASON")
			}
			
		switch(get_cvar_num("amx_show_activity"))
			{
			case 2: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"KICKALLIEDA",adminname)
			case 1: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"KICKALLIED")
			case 0: client_print(id,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"KICKALLIED")
			}
			
		g_lock_allies = 0
		}
	else if(equali(kickteam,"axis"))
		{
		new plist_public[32],pnum_public
		get_players(plist_public, pnum_public)
		
		for(new i=0; i<pnum_public; i++)
			{
			new player_id = plist_public[i]
				
			if(is_user_connected(player_id))
				if(g_player_axis[player_id]  && !(get_user_flags(player_id) & ADMIN_TEAM))
					server_cmd("kick #%d %L",get_user_userid(player_id),"KICKAXISREASON")

			}
			
		switch(get_cvar_num("amx_show_activity"))
			{
			case 2: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"KICKAXISA",adminname)
			case 1: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"KICKAXIS")
			case 0: client_print(id,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"KICKAXIS")
			}
			
		g_lock_axis = 0

		}
	else if(equali(kickteam,"spec"))
		{
		new plist_public[32],pnum_public
		get_players(plist_public, pnum_public)
		
		for(new i=0; i<pnum_public; i++)
			{
			new player_id = plist_public[i]
				
			if(is_user_connected(player_id))
				if(g_player_spec[player_id] && !(get_user_flags(player_id) & ADMIN_TEAM))
					server_cmd("kick #%d %L",get_user_userid(player_id),"KICKSPECREASON")
			}
		
		switch(get_cvar_num("amx_show_activity"))
			{
			case 2: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"KICKSPECA",adminname)
			case 1: client_print(0,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"KICKSPEC")
			case 0: client_print(id,print_chat,"[DoD TeamManager] %L",LANG_PLAYER,"KICKSPEC")
			}
		}
	else
		client_print(id,print_chat,"[DoD TeamManager] %L",id,"VALIDTEAMS")
	
	return PLUGIN_HANDLED
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1036\\ f0\\ fs16 \n\\ par }
*/
