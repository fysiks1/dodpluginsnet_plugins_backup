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
//
// Requires AMX Mod X & DoDx module!
//
//
// 
// USAGE:
// ======
//
// amx_dodmatchmenu        = displays the DoD ClanMatch Menu
//                           (you can access all further commands
//                           and settings directly through the menu!)
//
// dod_cm_folder <folder>  = sets folder with your configs (cvar!)
//                           (default is "dod_clanmatch", don't change this
//                           if you just want to use this plugin in one league!)
//
//
// ===============================================================
// YOU ONLY NEED THE FOLLOWING COMMANDS IF YOU DON'T USE THE MENU!
// ===============================================================
//
//
// amx_setdodmatcha <map1> <map2> <mapmode> <time> <ff>
//                  <showtime> <showscore>
//
// amx_setdodmatchb <password> <servername> <clantag1> <clantag2>
//                  <readysig> <cancelsig> <matchresulttime>
//
// amx_loaddodmatch     = loads basic match environment from file
//                        "dod_matchbase.cfg"
//
// amx_startdodmatch    = starts the previous set match
//
// amx_stopdodmatch     = aborts a running match
//
// amx_restartdodmatch  = restarts the current round played
//
//
//
// <map1>       = the first map to be played
// <map2>       = the second map to be played
// <mapmode>    = sets mode to play the maps:
//                1 only play each map once
//                2 play each map two times
// <time>       = time in minutes to play each map
// <ff>         = enable/disable FriendlyFire
//                1 FriendlyFire enabled
//                0 FriendlyFire disabled
// <showtime>   = show time left to play
//                1 use a hud-message on roundstart
//                2 use chat text on roundstart
//                3 use a hud-message every minute
//                4 use chat text every minute
//                0 disabled
// <showscore>	= show teams' scores
//                1 use a hud-message on roundstart
//                2 use chat text on roundstart
//                3 hud-message & total match score on roundstart
//                4 chat text & total match score on roundstart
//                5 hud-message & total match score every min
//                6 chat text & total match score every min
//                0 disabled
//
// <password>         = sets password for the server
// <servername>       = sets name for the server while the
//                      clanmatch is running. (use quotes)
// <clantag1>         = sets clantag for the clan that will
//                      play Axis-Allies-Axis-Allies.
//                      (use quotes)
// <clantag2>         = sets clantag for the clan that will
//                      play Allies-Axis-Allies-Axis.
//                      (use quotes)
// <readysig>         = word to say to set "ready-status"
// <cancelsig>        = word to say to revoke "ready-status"
// <matchresulttime>  = sets the time in minutes for the map to
//                      display the ClanMatch Result Menus
//
//
//
//
// DESCRIPTION:
// ============
//
// This is a plugin that a lot of DoD admins have been
// waiting for! - a working DoD ClanMatch plugin!
// Features are:
// - plugin hooks up with DoD's included ClanMatch features
// - completely menu-driven! all settings and commands can
//   easiely acced by the "amx_dodmatchmenu"!
// - you can setup the whole match process before you start
// - you can setup two maps and decide whether to play them
//   twice (so you can play axis and allies) or only once.
// - a list of available maps for the clanmatchmenu can be
//   loaded from the file "dod_matchmaps.cfg" in your
//   "dod_clanmatch" folder in your amxx configs folder.
//   if it doesn't exist, the maps from your "mapcycle.txt"
//   are used. 
// - you can load match settings from "dod_matchbase.cfg" so
//   you don't have to apply the settings in-game as the command
//   gets longer and longer with every feature added.
// - you can set clantags for the teams which will be displayed
//   in the results and all messages.
// - servername can be set and applied for the match
// - "WarmUp"-mode is running on each map and the set timelimit
//   is applied after both teams are ready and the fight actually
//   starts.
// - time remaining can be displayed each roundstart / each min 
// - teams' scores can be displayed each roundstart / each min
// - map specific config files can be loaded for each map
//   the filename has to be MAPNAME_match.cfg
//   (i.e.: dod_kalt_match.cfg) and has to be placed into
//   your "dod_clanmatch" folder in your amxx configs folder
// - file "dod_clanmatch.cfg" will be executed if it exists in
//   your dod_clanmatch folder in you AMX Mod X configs folder
//   when the match is running.
//   (use that to set class limits)
// - file "dod_public.cfg" will be executed if it exists in
//   your dod_clanmatch folder in you AMX Mod X configs folder
//   when the match is finished.
//   (use that to remove class limits)
//   Furthermore your server.cfg and amxx.cfg is executed
//   as well, so most of your standard settings are recovered
//   after the match.
// - the result and match scoring details can be viewed after
//   the match is over. people will automatically see them
//   after they spawned. the password is still active and
//   the map will run 5min, then it's all set to normal again. 
// - a lot more!
//
//
//
// CHANGELOG:
// ==========
//
// - 20.02.2005 Version 0.4beta
//   Initial Release
//
// - 21.02.2005 Version 0.5beta
//   * fixed oversight that password
//     wasn't set for the match and not
//     removed again after the match
//
// - 21.02.2005 Version 0.6beta
//   * added features:
//     - the time in minutes remaining
//       on the current map can be displayed
//       on each roundstart
//     - the teams' scores can be displayed
//       on each roudstart
//   * Note:
//     the command usage changed, be sure
//     to review it!
//
// - 21.02.2005 Version 0.7beta
//   * added feature:
//     - a map specific config file for each map
//       (for scoring rules for example)
//       can be executed when the match is running.
//       the filenames have to be MAPNAME_match.cfg
//       and they have to be placed into the new
//       "dod_clanmatch" subfolder of your amxx configs
//       folder. (like all DoD ClanMatch related files)
//     - all stats settings are disabled when the match is running
//       and your previous stats settings are recovered after it's
//       finished
//   * changes:
//     - added folder "dod_clanmatch" to make it more
//       organized for you, so you don't have your
//       amxx configs folder full of DoD ClanMatch
//       config files!
//     - included new example scoring config files for some
//       maps
//
// - 22.02.2005 Version 0.75beta
//   * added feature:
//     - time remaining and teams' scores can either be displayed
//       as a hud-message or as chat text!
//   * changes:
//     - password is set immediately after using the
//       amx_startdodmatch command.
//
// - 24.02.2005 Version 0.8beta
//   * added feature:
//     - added config files for stopping and starting plugins again.
//   * changes:
//     - plugins are not paused anymore on map start, they are
//       stopped when the amx_startdodmatch command was executed.
//       that way they are turned off and behave like they weren't
//       loaded at all.
//     - use files "disable_plugins.cfg" and "enable_plugins.cfg"
//       to use the above mentioned feature
//     - as the plugins "TimeLeft" and "NextMap" were NOT stoppable
//       i had to remove that restriction from the "PauseCFG" plugin
//       to make them stoppable. so you need to replace your standard
//       "pausecfg.amxx" with the one i included to get it all to work
//       for now. i will request to get those two restrictions removed
//       from that plugin for the next release of AMX Mod X.
//
// - 25.02.2005 Version 0.85beta
//   * added feature:
//     - clans can cancel their ready-status with saying "cancel".
//       this only works if the other team isn't ready yet.
//   * changed feature:
//     - once again i changed the way the stats are disabled,
//       as stopping the plugin instead of pausing still doesn't help.
//       i readded the commands to turn off every single stats setting
//       to the config files and added the stats settings recover
//       command as well again.
//   * to do:
//     - add admin command to restart the match on current map
//     - add feature to display match's scores after the match
//       is over and the map changed
//     - some other stuff
//   * notes:
//     - if stopping one of your custom plugins doesn't work well
//       and you experience strange behavior, remove it from the
//       disable/enable configs and disable it by cvar in the
//       dod_clanmatch.cfg.
//
// - 26.02.2005 Version 0.9beta
//   * added feature:
//     - added two modes for displaying the time remaining on the current
//       map/round. the time remaining can be displayed every minute as a
//       hudmessage (mode 3) or every minute as a chattext message (mode 4).
//     - after the match all players can view the result and the scoring
//       details by saying "matchresult".
//   * to do:
//     - add admin command to restart the match on current map
//     - some other stuff
//
// - 27.02.2005 Version 0.95beta
//   * added features:
//     - added two modes for displaying the scores.
//       the total scores of all rounds played can be displayed besides
//       displaying the current round's scores:
//       as a hudmessage (mode 3) or chattext message (mode 4).
//     - after the match all players will automatically see the result
//       of the match after they spawned. the password is still active
//       and the map will run for 5min. enough time for everyone to look
//       at the result/details. then the map changes and all is set to
//       normal again and the pw is removed.
//     - added admincommand "amx_restartdodmatch", this will simply
//       restart the round and people have to set themselves ready again.
//       This will NOT restart the whole match, just the current round.
//     - when a team is ready, a hudmessage telling them how to revoke
//       their ready-status is displayed.
//   * to do:
//     - add some other stuff
//     - fix bugs if needed
//
// - 27.02.2005 Version 0.99beta
//   * upgrades:
//     - servername for the match can be set
//     - clantags for the teams can be set and will be displayed
//       in all messages and in the results
//     - added basic match config file to set the environment,
//       the file is called "dod_matchbase.cfg" and contains
//       a sample match setup. it can be loaded with the admincommand
//       "amx_loaddodmatch".
//     - the total scores display feature is real-time now, so it includes
//       the scores of previous rounds and the scores of the current round.
//   * important notes:
//     - it's of utmost importance that the teams are played the straight
//       way (Axis-Allies-Axis-Allies & Allies-Axis-Allies-Axis). if that's
//       not the case, the score counting is wrong!
//       (so if your team plays Axis-Allies-Allies-Axis the scores are fucked!)
//     - clantag1 has to be the clan that starts with axis on the first map
//     - clantag2 has to be the clan that starts with allies on the first map
//     - one you activated the matchmode with "amx_startdodmatch" all players
//       that connect and try to join a team will automatically join
//       Spectator and a message will tell them to which team they have to go!
//       this is mainly made to be sure that the clans join the teams that
//       are needed for a correct score calculation!
//   * general changes:
//     - Engine module is required now!
//     - i removed the examples for now, but i will add a detailed readme.txt
//       as soon as it reaches a stable state with all needed features
//   * to do:
//     - make "ready" and "cancel" commands customizable
//     - add "auto-endgame-scores-screenshot"-feature
//     - take a look at some HLTV stuff
//     - optimize the code
//     - fix some minor issues
//     - add some more useful stuff requested by users
//     - fix bugs reported by users
//
// - 02.03.2005 Version 0.99beta2
//   * fixes:
//     - matchtime is exactly how long you set it now
//     - fullcaps are counted correctly for ingame display now
//     - when restarting a match round, warmupmode is running again now
//   * general changes:
//     - the score displaying works like when players try to join a team
//       in match mode now. whatever team they click after connecting,
//       they join Spectators and the scores are displayed.
//       once they closed the display of the scores, they can join a team.
//   * to do:
//     - make "ready" and "cancel" commands customizable
//     - add "auto-endgame-scores-screenshot"-feature
//     - take a look at some HLTV stuff
//     - optimize the code
//     - fix some minor issues
//     - add some more useful stuff requested by users
//     - fix bugs reported by users
//
// - 05.03.2005 Version 0.99beta3
//   * added features:
//     - two new modes for "ShowScore"-option
//       5 use a hud-message with scores & totals every minute
//       6 use chattext with scores & totals every minute
//     - added admin command "amx_getdodmatch" which will show
//       the current settings of your match.
//     - added page 3 of the results called "Map Scores" which displays
//       the total scores of both clans for each map.
//   * fixes:
//     - scores for current round are reset when restarting the round
//     - timelimit is reset to 120 min when restarting the round and joining
//       warmup mode again.
//
// - 06.03.2005 Version 0.99beta4
//   * added features:
//     - chatcommands for "ready" and "cancel" can be set to any word you
//       would like to use. the messages automatically announce your set
//       words.
//   * bugfixes:
//     - hopefully fixed little problem with the clan-scoring-delay by
//       grabbing the scores again 1 second after the delay is over.
//   * general changes:
//     - added "<readysig>" & "<cancelsig>" to "amx_setdodmatch"
//       and all other needed admin commands.
//     - added "dod_cm_readysig" and "dod_cm_cancelsig" to the
//       "dod_matchbase.cfg". (only file that changed, keep your others)
//
// - 07.03.2005 Version 0.99beta4v2
//   * bugfix:
//     - the problem with displaying the total scores every minute
//       should finally be fixed now. (hopefully)
//
// - 11.03.2005 Version 0.99beta5
//   * bugfix:
//     - the scores taken by endgame screenshot should not differ
//       from the scores the plugin calculates anymore.
//       when then scoreboard came up 6 seconds before the map
//       really changes the game still continued, so if one or
//       more players ran into a flag when the scoreboard comes up,
//       the plugin still counted the taken flag, now calculating scores
//       is disabled as soon as the scoreboard comes up.
//
// - 27.03.2005 Version 0.99beta6
//   * added features:
//     - implemented a whole menu-system with access to changes and
//       commands. (amx_dodmatchmenu)
//     - added file "dod_matchmaps.cfg", list all maps that you want
//       to be available for the ClanMatchMenu
//   * bugfixes:
//     - fixed the hudmessage which tells the clans what team to join.
//       it now disappears immediately if a team was choosen, not before
//       and not too late anymore.
//     - fixed oversight that a running match's settings could had been
//       changed
//     - fixed problem of truncated lines with splitting the command
//       "amx_setdodmatch" into two commands (amx_setdodmatcha & amx_setdodmatchb)
//   * general changes:
//     - removed config files for stopping and starting plugins as my request
//       for altering the pausecfg.sma was just ignored for no reason.
//       that way you DON'T need to use the changed pausecfg plugin anymore.
//       just redownload the config files and add the plugins you want to pause/unpause
//       to dod_clanmatch.cfg and dod_public.cfg
//
// - 20.04.2005 Version 0.99beta7
//   * bugfixes:
//     - added 1 second delay between setting the server password
//       and changing to the 1st map to be played to get rid of the
//       "Wrong Password" issue.
//     - fixed problem with displaying what team to join not disappearing
//       for people that joined the match after it was already started
//
// - 08.05.2005 Version 0.99beta8
//   * added feature:
//     - added setting for the time the map is running to show the results
//       to the menu system.
//   * cosmetic changes:
//     - corrected some colors in the menus to look better
//
// - 13.07.2005 Version 0.99beta9
//   * added feature:
//     - the folder for the clanmatch configs can simply be changes
//       with the new cvar "dod_cm_folder" which is set to
//       "dod_clanmatch" by default.
//       if you don't intend to use this plugin for different leagues,
//       you don't need to touch this cvar!
//       Example of usage:
//       the value of this cvar is the name of the folder with your
//       config files, so if you want to use different configs for
//       different matches, duplicate the standard folder "dod_clanmatch"
//       and call it like the league you play.
//       for example you could call the duplicated folders "esl", "ed",
//       "clanbase" and so on.
//       so if you have an EnemyDown match comming up, you will need
//       to change the cvar "dod_cm_folder" to "ed", so the configfiles
//       in your "ed" folder will be used.
//
// - 15.07.2005 Version 0.5prefinal
//   * added feature:
//     - cvar "dod_cm_folder" is automatically reset to the default
//       value "dod_clanmatch" after a match is finished/aborted.
//
// - 04.08.2005 Version 0.6prefinal
//   * bugfix
//     - fixed "amx_dodmatchmenu" being available for all players.
//       (thanks to -=[JaeGeR]=- PapA for reporting it!)
//
// - 26.03.2006 Version 0.7prefinal
//	* bugfix
//	- fixed the errors caused by comparing serverpass to a number instead
//	of using a string length
//	- changed cvars over to pointers to cvars
//
// - 08.07.2007 Version 0.8
//      - removed need for engine-module
//      - major code optimizations
//      - removed a big bunch of lines of duplicate code
//      - added global tracking cvar
//
// - 12.07.2007 Version 0.9
//      - added Multilanguagesupport
//      - removed some lines of duplicate code
//

#include <amxmodx>
#include <amxmisc>
#include <dodx>

#define MAX_MAPS 64

new clansready = 0
new axisready = 0
new alliesready = 0
new matchrunning = 0
new matchdone = 0
new mapdone = 0
new secdiff = 0
new sawresult[33]
new knowsteam[33]
new g_mapName[MAX_MAPS][32]
new g_mapNums
new g_menuPosition[33]
new usingmenu[33]

new dod_clanmatch
new dod_cm_mapsplayed
new dod_cm_mapmode
new dod_cm_time
new dod_cm_ff
new dod_cm_showtime
new dod_cm_showscore
new dod_cm_matchresulttime
new dod_cm_map11scoreaxis
new dod_cm_map11scoreallies
new dod_cm_map21scoreaxis
new dod_cm_map21scoreallies
new dod_cm_map12scoreaxis
new dod_cm_map12scoreallies
new dod_cm_map22scoreaxis
new dod_cm_map22scoreallies

public plugin_init()
{
	register_plugin("DoD ClanMatch","0.9","AMXX DoD Team")
	register_cvar("dod_clanmatch_plugin", "Version 0.9 by FeuerSturm | www.dodplugins.net", FCVAR_SERVER|FCVAR_SPONLY)
	register_statsfwd(XMF_SCORE)
	register_concmd("amx_loaddodmatch","cmd_loaddodmatch",ADMIN_CVAR,"- loads your match settings from dod_matchbase.cfg")
	register_concmd("amx_setdodmatcha","cmd_setdodmatcha",ADMIN_CVAR,"<map1> <map2> <mapmode> <time> <ff> <showtime> <showscore>")
	register_concmd("amx_setdodmatchb","cmd_setdodmatchb",ADMIN_CVAR,"<password> <servername> <clantag1> <clantag2> <readysig> <cancelsig> <matchresulttime>")
	register_concmd("amx_startdodmatch","cmd_startdodmatch",ADMIN_CVAR,"- starts the match!")
	register_concmd("amx_stopdodmatch","cmd_stopdodmatch",ADMIN_CVAR,"- stops the match!")
	register_concmd("amx_restartdodmatch","cmd_dodrestartround",ADMIN_CVAR,"- restarts the current round!")
	register_clcmd("amx_dodmatchmenu","show_clanmatch_menu",ADMIN_CVAR,"- displays DoD ClanMatch Menu")
	register_clcmd("match_serverpass","cmd_serverpass",ADMIN_CVAR,"- set ServerPassword")
	register_clcmd("match_servername","cmd_servername",ADMIN_CVAR,"- set ServerName")
	register_clcmd("match_clantag1","cmd_clantag1",ADMIN_CVAR,"- set ClanTag1")
	register_clcmd("match_clantag2","cmd_clantag2",ADMIN_CVAR,"- set ClanTag2")
	register_clcmd("match_readysig","cmd_readysig",ADMIN_CVAR,"- set ReadySignal")
	register_clcmd("match_cancelsig","cmd_cancelsig",ADMIN_CVAR,"- set CancelSignal")
	register_clcmd("match_resulttime","cmd_matchresulttime",ADMIN_CVAR,"- set MatchResultTime")
	register_clcmd("match_timelimit","cmd_timelimit",ADMIN_CVAR,"- set TimeLimit")
	register_clcmd("say","cmd_readycancel")
	register_clcmd("jointeam","spec_first")
	register_menucmd(register_menuid("DoD ClanMatch Map1"),1023,"changemap1menu")
	register_menucmd(register_menuid("DoD ClanMatch Map2"),1023,"changemap2menu")
	register_menucmd(register_menuid("DoD ClanMatch Menu"),(1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<8),"match_menu")
	register_menucmd(register_menuid("DoD ClanMatch Current Settings"),(1<<8),"match_showsettings")
	register_menucmd(register_menuid("DoD ClanMatch Change Settings 1"),(1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8),"match_changesettings1")
	register_menucmd(register_menuid("DoD ClanMatch Change Settings 2"),(1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8),"match_changesettings2")
	register_menucmd(register_menuid("DoD ClanMatch TimeLimit"),(1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<8),"match_changetime")
	register_menucmd(register_menuid("DoD ClanMatch MapMode"),(1<<0)|(1<<1)|(1<<8),"match_changemapmode")
	register_menucmd(register_menuid("DoD ClanMatch FriendlyFire"),(1<<0)|(1<<8)|(1<<9),"match_changeff")
	register_menucmd(register_menuid("DoD ClanMatch ShowScore"),(1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<8)|(1<<9),"match_changeshowscore")
	register_menucmd(register_menuid("DoD ClanMatch ShowTime"),(1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<8)|(1<<9),"match_changeshowtime")
	register_menucmd(register_menuid("DoD ClanMatch ServerPassword"),(1<<0)|(1<<1)|(1<<2)|(1<<8),"match_changeserverpass")
	register_menucmd(register_menuid("DoD ClanMatch ServerName"),(1<<0)|(1<<1)|(1<<2)|(1<<8),"match_changeservername")
	register_menucmd(register_menuid("DoD ClanMatch ClanTag1"),(1<<0)|(1<<1)|(1<<2)|(1<<8),"match_changeclantag1")
	register_menucmd(register_menuid("DoD ClanMatch ClanTag2"),(1<<0)|(1<<1)|(1<<2)|(1<<8),"match_changeclantag2")
	register_menucmd(register_menuid("DoD ClanMatch ReadySignal"),(1<<0)|(1<<1)|(1<<2)|(1<<8),"match_changereadysig")
	register_menucmd(register_menuid("DoD ClanMatch CancelSignal"),(1<<0)|(1<<1)|(1<<2)|(1<<8),"match_changecancelsig")
	register_menucmd(register_menuid("DoD ClanMatch MatchResultTime"),(1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<8),"match_changematchresulttime")
	register_menucmd(register_menuid("DoD ClanMatch Result"),(1<<1)|(1<<2)|(1<<9),"match_result")
	register_menucmd(register_menuid("DoD ClanMatch Details"),(1<<0)|(1<<2)|(1<<9),"match_details")
	register_menucmd(register_menuid("DoD ClanMatch Map Scores"),(1<<0)|(1<<1)|(1<<9),"match_mapscores")
	register_event("HudText","axis_ready","bC","1=#Clan_axis_ready")
	register_event("HudText","allies_ready","bC","1=#Clan_allies_ready")
	register_event("TextMsg","match_start","bC","2&game_roundstart")
	set_task(15.0,"get_matchmaps")
	dod_clanmatch = register_cvar("dod_clanmatch", "0")
	dod_cm_mapsplayed = register_cvar("dod_cm_mapsplayed", "0")
	dod_cm_mapmode = register_cvar("dod_cm_mapmode", "2")
	dod_cm_time = register_cvar("dod_cm_time", "15")
	dod_cm_ff = register_cvar("dod_cm_ff", "1")
	dod_cm_showtime = register_cvar("dod_cm_showtime", "1")
	dod_cm_showscore = register_cvar("dod_cm_showscore", "1")
	dod_cm_matchresulttime = register_cvar("dod_cm_matchresulttime", "5")
	dod_cm_map11scoreaxis = register_cvar("dod_cm_map11scoreaxis", "0")
	dod_cm_map11scoreallies = register_cvar("dod_cm_map11scoreallies", "0")
	dod_cm_map21scoreaxis = register_cvar("dod_cm_map21scoreaxis", "0")
	dod_cm_map21scoreallies = register_cvar("dod_cm_map21scoreallies", "0")
	dod_cm_map12scoreaxis = register_cvar("dod_cm_map12scoreaxis", "0")
	dod_cm_map12scoreallies = register_cvar("dod_cm_map12scoreallies", "0")
	dod_cm_map22scoreaxis = register_cvar("dod_cm_map22scoreaxis", "0")
	dod_cm_map22scoreallies = register_cvar("dod_cm_map22scoreallies", "0")
	register_cvar("dod_cm_folder", "dod_clanmatch")
	register_cvar("dod_cm_map1", "dod_avalanche")
	register_cvar("dod_cm_map2", "dod_flash")
	register_cvar("dod_cm_serverpass", "clanmatch")
	register_cvar("dod_cm_servername", "DoD ClanMatch in progress")
	register_cvar("dod_cm_clantag1", "[TeamAlpha]")
	register_cvar("dod_cm_clantag2", "[TeamBeta]")
	register_cvar("dod_cm_readysig", "ready")
	register_cvar("dod_cm_cancelsig", "cancel")
	register_dictionary("dod_clanmatch.txt")
}

public get_matchmaps()
{
	new matchmapfile[128]
	new matchfolder[32]
	get_cvar_string("dod_cm_folder",matchfolder,31)
	get_configsdir(matchmapfile,127)
	format(matchmapfile,127,"%s/%s/dod_matchmaps.cfg",matchmapfile,matchfolder)
	if(!file_exists(matchmapfile))
	{
		format(matchmapfile,127,"mapcycle.txt")
	}
	loadmatchmaps(matchmapfile)
}

public client_score(index,score,total)
{
	if(get_cvar_num("mp_clan_match") == 1 && get_pcvar_num(dod_clanmatch) == 1 && matchrunning == 1 && mapdone == 0)
	{
		set_task(1.0,"catch_scores")
		new scoringdelay = (get_cvar_num("mp_clan_scoring_delay") + 1)
		set_task(Float:float(scoringdelay),"catch_scores")
	}
	return PLUGIN_CONTINUE
}

public catch_scores()
{
	if(mapdone != 0)
	{
		return PLUGIN_HANDLED
	}
	new axisscore = dod_get_team_score(AXIS)
	new alliesscore = dod_get_team_score(ALLIES)
	new cm_mapmode = get_pcvar_num(dod_cm_mapmode)
	new cm_mapsplayed = get_pcvar_num(dod_cm_mapsplayed)
	if((cm_mapmode == 1 && cm_mapsplayed == 1) || (cm_mapmode == 2 && cm_mapsplayed == 1))
	{
		set_pcvar_num(dod_cm_map11scoreaxis,axisscore)
		set_pcvar_num(dod_cm_map11scoreallies,alliesscore)
	}
	if((cm_mapmode == 1 && cm_mapsplayed == 2) || (cm_mapmode == 2 && cm_mapsplayed == 3))
	{
		set_pcvar_num(dod_cm_map21scoreaxis,axisscore)
		set_pcvar_num(dod_cm_map21scoreallies,alliesscore)
	}
	if(cm_mapmode == 2 && cm_mapsplayed == 2)
	{
		set_pcvar_num(dod_cm_map12scoreaxis,axisscore)
		set_pcvar_num(dod_cm_map12scoreallies,alliesscore)
	}
	if(cm_mapmode == 2 && cm_mapsplayed == 4)
	{
		set_pcvar_num(dod_cm_map22scoreaxis,axisscore)
		set_pcvar_num(dod_cm_map22scoreallies,alliesscore)
	}
	return PLUGIN_HANDLED
}

public client_authorized(id)
{
	sawresult[id] = 0
	knowsteam[id] = 0
}

public plugin_cfg()
{
	new cm_mapmode = get_pcvar_num(dod_cm_mapmode)
	new cm_mapsplayed = get_pcvar_num(dod_cm_mapsplayed)
	new clanmatch = get_pcvar_num(dod_clanmatch)
	if(get_cvar_num("mp_clan_match") == 1 && clanmatch == 1)
	{
		if((cm_mapmode == 1 && cm_mapsplayed < 2) || (cm_mapmode == 2 && cm_mapsplayed < 4))
		{
			set_pcvar_num(dod_cm_mapsplayed,(cm_mapsplayed + 1))
			set_task(5.0,"load_match")
			return PLUGIN_CONTINUE
		}
		if((cm_mapmode == 1 && cm_mapsplayed == 2) || (cm_mapmode == 2 && cm_mapsplayed == 4))
		{
			set_pcvar_num(dod_cm_mapsplayed,(cm_mapsplayed + 1))
			set_cvar_num("mp_clan_match",0)
			set_pcvar_num(dod_clanmatch,0)
			set_task(5.0,"load_aftermatch")
			return PLUGIN_CONTINUE
		}
		return PLUGIN_CONTINUE
	}
	if(get_cvar_num("mp_clan_match") == 0 && clanmatch == 0)
	{
		if((cm_mapmode == 1 && cm_mapsplayed >= 3) || (cm_mapmode == 2 && cm_mapsplayed >= 5))
		{
			set_pcvar_num(dod_cm_mapsplayed,0)
			set_task(5.0,"load_standard")
			return PLUGIN_CONTINUE
		}
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public load_match()
{
	new matchconfig[128]
	get_configsdir(matchconfig,128)
	new matchfolder[32]
	get_cvar_string("dod_cm_folder",matchfolder,31)
	format(matchconfig,127,"%s/%s/dod_clanmatch.cfg",matchconfig,matchfolder)
	if(file_exists(matchconfig))
	{
		server_cmd("exec %s",matchconfig)
	}
	new mapname[64]
	get_mapname(mapname,63)
	new mapconfig[128]
	get_configsdir(mapconfig,128)
	format(mapconfig,127,"%s/%s/%s_match.cfg",mapconfig,matchfolder,mapname)
	if(file_exists(mapconfig))
	{
		server_cmd("exec %s",mapconfig)
	}
	set_cvar_num("mp_clan_readyrestart",1)
	set_cvar_num("mp_timelimit",120)
	set_cvar_num("mp_friendlyfire",get_pcvar_num(dod_cm_ff))
	new serverpass[32]
	get_cvar_string("dod_cm_serverpass",serverpass,31)
	set_cvar_string("sv_password",serverpass)
	new servername[128]
	get_cvar_string("dod_cm_servername",servername,127)
	server_cmd("hostname ^"%s^"",servername)
	new readysig[32]
	get_cvar_string("dod_cm_readysig",readysig,31)
	set_cvar_string("mp_clan_ready_signal",readysig)
	set_cvar_num("mp_allowspectators",1)
	set_cvar_num("sv_maxspectators",-1)	
	set_task(5.0,"ready_remind",53452,"",0,"b")
	return PLUGIN_HANDLED
}

public load_aftermatch()
{
	new matchconfig[128]
	get_configsdir(matchconfig,128)
	new matchfolder[32]
	get_cvar_string("dod_cm_folder",matchfolder,31)
	format(matchconfig,127,"%s/%s/dod_clanmatch.cfg",matchconfig,matchfolder)
	if(file_exists(matchconfig))
	{
		server_cmd("exec %s",matchconfig)
	}
	new mapname[64]
	get_mapname(mapname,63)
	new mapconfig[128]
	get_configsdir(mapconfig,128)
	format(mapconfig,127,"%s/%s/%s_match.cfg",mapconfig,matchfolder,mapname)
	if(file_exists(mapconfig))
	{
		server_cmd("exec %s",mapconfig)
	}
	new resulttime = get_pcvar_num(dod_cm_matchresulttime)
	set_cvar_num("mp_timelimit",resulttime)
	new serverpass[32]
	get_cvar_string("dod_cm_serverpass",serverpass,31)
	set_cvar_string("sv_password",serverpass)
	set_cvar_num("mp_allowspectators",1)
	set_cvar_num("sv_maxspectators",-1)
	matchdone = 1
	return PLUGIN_HANDLED
}

public delayed_mapchange()
{
	catch_scores()
	mapdone = 1
	message_begin(MSG_ALL, SVC_INTERMISSION)
	message_end()
	if(secdiff <= 6)
	{
		set_cvar_num("mp_timelimit",(get_cvar_num("mp_timelimit") + 1))
	}
	set_task(6.0,"real_mapchange")
	return PLUGIN_HANDLED
}

public real_mapchange()
{
	new nextmap[64]
	new cm_mapmode = get_pcvar_num(dod_cm_mapmode)
	new cm_mapsplayed = get_pcvar_num(dod_cm_mapsplayed)	
	if((cm_mapmode == 1 && cm_mapsplayed == 1) || (cm_mapmode == 2 && cm_mapsplayed == 2) || (cm_mapmode == 2 && cm_mapsplayed == 3))
	{
		get_cvar_string("dod_cm_map2",nextmap,63)
		server_cmd("changelevel %s",nextmap)
		return PLUGIN_HANDLED
	}
	if((cm_mapmode == 2 && cm_mapsplayed == 1) || (cm_mapmode == 1 && cm_mapsplayed == 2) || (cm_mapmode == 2 && cm_mapsplayed == 4))
	{
		get_cvar_string("dod_cm_map1",nextmap,63)
		server_cmd("changelevel %s",nextmap)
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public load_standard()
{
	set_cvar_string("sv_password","")
	set_cvar_string("dod_cm_folder","dod_clanmatch")
	server_cmd("exec server.cfg")
	new amxxconfig[64]
	get_configsdir(amxxconfig,64)
	format(amxxconfig,63,"%s/amxx.cfg",amxxconfig)
	server_cmd("exec %s",amxxconfig)
	new pubconfig[128]
	get_configsdir(pubconfig,128)
	new matchfolder[32]
	get_cvar_string("dod_cm_folder",matchfolder,31)
	format(pubconfig,127,"%s/%s/dod_public.cfg",pubconfig,matchfolder)
	if(file_exists(pubconfig))
	{
		server_cmd("exec %s",pubconfig)
	}
	return PLUGIN_HANDLED
}

public ready_remind()
{
	if(alliesready == 0 || axisready == 0)
	{
		new readysig[32]
		get_cvar_string("mp_clan_ready_signal",readysig,31)
		new clantag1[32]
		get_cvar_string("dod_cm_clantag1",clantag1,31)
		new clantag2[32]
		get_cvar_string("dod_cm_clantag2",clantag2,31)
		new cm_mapmode = get_pcvar_num(dod_cm_mapmode)
		new cm_mapsplayed = get_pcvar_num(dod_cm_mapsplayed)
		new plist[32],pnum
		get_players(plist,pnum)
		for(new i=0; i<pnum; i++)
		{
			new id = plist[i]
			if(is_user_connected(id) == 1)
			{
				if((cm_mapmode == 1 && cm_mapsplayed == 1) || (cm_mapmode == 2 && cm_mapsplayed == 1) || (cm_mapmode == 2 && cm_mapsplayed == 3))
				{
					if(get_user_team(id) == ALLIES && alliesready == 0)
					{
						set_hudmessage(0, 255, 0, 0.03, 0.5, 0, 6.0, 5.0, 0.1, 0.2, 4)
						show_hudmessage(id,"%L",id,"LEADERSAYREADY",clantag2,readysig)
					}
					else if(get_user_team(id) == AXIS && axisready == 0)
					{
						set_hudmessage(255, 0, 0, 0.03, 0.3, 0, 6.0, 5.0, 0.1, 0.2, 3)
						show_hudmessage(id,"%L",id,"LEADERSAYREADY",clantag1,readysig)
					}		
				}
				if((cm_mapmode == 1 && cm_mapsplayed == 2) || (cm_mapmode == 2 && cm_mapsplayed == 2) || (cm_mapmode == 2 && cm_mapsplayed == 4))
				{
					if(get_user_team(id) == ALLIES && alliesready == 0)
					{
						set_hudmessage(0, 255, 0, 0.03, 0.5, 0, 6.0, 5.0, 0.1, 0.2, 4)
						show_hudmessage(id,"%L",id,"LEADERSAYREADY",clantag1,readysig)
					}
					else if(get_user_team(id) == AXIS && axisready == 0)
					{
						set_hudmessage(255, 0, 0, 0.03, 0.3, 0, 6.0, 5.0, 0.1, 0.2, 3)
						show_hudmessage(id,"%L",id,"LEADERSAYREADY",clantag2,readysig)
					}
				}
			}
		}
	}
	return PLUGIN_HANDLED
}

public cmd_loaddodmatch(id,level,cid)
{
	if(!cmd_access(id,level,cid,1))
	{
		return PLUGIN_HANDLED
	}
	if(get_cvar_num("mp_clan_match") == 1 && get_pcvar_num(dod_clanmatch) == 1)
	{
		client_print(id,print_console,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
		client_print(id,print_chat,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
		if(usingmenu[id] == 1)
		{
			usingmenu[id] = 0
			clanmatch_menu(id)
		}
		return PLUGIN_HANDLED
	}
	new matchbase[128]
	get_configsdir(matchbase,128)
	new matchfolder[32]
	get_cvar_string("dod_cm_folder",matchfolder,31)
	format(matchbase,127,"%s/%s/dod_matchbase.cfg",matchbase,matchfolder)
	if(file_exists(matchbase))
	{
		server_cmd("exec %s",matchbase)
		if(usingmenu[id] == 1)
		{
			usingmenu[id] = 0
			set_task(0.1,"clanmatch_showsettings",id)
			client_print(id,print_chat,"[DoD ClanMatch] %L",id,"MATCHBASELOADED")
		}
		else
		{
			set_task(0.1,"match_loaded",id)
		}
		return PLUGIN_HANDLED
	}
	else if(!file_exists(matchbase))
	{
		client_print(id,print_console,"[DoD ClanMatch] %L",id,"MATCHBASEMISSING")
		client_print(id,print_chat,"[DoD ClanMatch] %L",id,"MATCHBASEMISSING")
		if(usingmenu[id] == 1)
		{
			usingmenu[id] = 0
			clanmatch_menu(id)
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public match_loaded(id)
{
	new map1[64]
	get_cvar_string("dod_cm_map1",map1,63)
	new map2[64]
	get_cvar_string("dod_cm_map2",map2,63)
	new mapmode = get_pcvar_num(dod_cm_mapmode)
	new mtime = get_pcvar_num(dod_cm_time)
	new ff = get_pcvar_num(dod_cm_ff)
	new showtime = get_pcvar_num(dod_cm_showtime)
	new showscore = get_pcvar_num(dod_cm_showscore)
	new serverpass[32]
	get_cvar_string("dod_cm_serverpass",serverpass,31)
	new servername[128]
	get_cvar_string("dod_cm_servername",servername,127)
	new clantag1[32]
	get_cvar_string("dod_cm_clantag1",clantag1,31)
	new clantag2[32]
	get_cvar_string("dod_cm_clantag2",clantag2,31)
	new readysig[32]
	get_cvar_string("dod_cm_readysig",readysig,31)
	new cancelsig[32]
	get_cvar_string("dod_cm_cancelsig",cancelsig,31)
	new matchresulttime = get_pcvar_num(dod_cm_matchresulttime)
	client_print(id,print_console,"[DoD ClanMatch] Map1 = %s ; Map2 = %s ; MapMode = %d ; Time = %d ; FF = %d ; ",map1,map2,mapmode,mtime,ff)
	client_print(id,print_console,"ShowTime = %d ; ShowScore = %d ; Password = %s ; ",showtime,showscore,serverpass)
	client_print(id,print_console,"ServerName = %s ; ClanTag1 = %s ; ClanTag2 = %s ; ",servername,clantag1,clantag2)
	client_print(id,print_console,"ReadySignal = %s ; CancelSignal = %s ; MatchResultTime = %d",readysig,cancelsig,matchresulttime)
	return PLUGIN_HANDLED
}	

public cmd_setdodmatcha(id,level,cid)
{
	if(!cmd_access(id,level,cid,8))
	{
		return PLUGIN_HANDLED
	}
	if(get_cvar_num("mp_clan_match") == 1 && get_pcvar_num(dod_clanmatch) == 1)
	{
		client_print(id,print_console,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
		client_print(id,print_chat,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
		return PLUGIN_HANDLED
	}
	new map1[64]
	read_argv(1,map1,64)
	new map2[128]
	read_argv(2,map2,64)
	new mapmode_s[2]
	read_argv(3,mapmode_s,2)
	new mapmode = str_to_num(mapmode_s)
	new mtime_s[5]
	read_argv(4,mtime_s,5)
	new mtime = str_to_num(mtime_s)
	new ff_s[2]
	read_argv(5,ff_s,2)
	new ff = str_to_num(ff_s)
	new showtime_s[2]
	read_argv(6,showtime_s,2)
	new showtime = str_to_num(showtime_s)
	new showscore_s[2]
	read_argv(7,showscore_s,2)
	new showscore = str_to_num(showscore_s)
	if(is_map_valid(map1) == 0)
	{
		client_print(id,print_console,"[DoD ClanMatch] %L",id,"MAP1INVALID",map1)
		return PLUGIN_HANDLED
	}
	if(is_map_valid(map2) == 0)
	{
		client_print(id,print_console,"[DoD ClanMatch] %L",id,"MAP2INVALID",map2)
		return PLUGIN_HANDLED
	}
	if(mapmode < 0 || mapmode > 2)
	{
		client_print(id,print_console,"[DoD ClanMatch] %L",id,"MAPMODEINVALID",mapmode)
		return PLUGIN_HANDLED
	}
	if(mtime <= 0)
	{
		client_print(id,print_console,"[DoD ClanMatch] %L",id,"TIMEINVALID",mtime)
		return PLUGIN_HANDLED
	}
	if(ff < 0 || ff > 1)
	{	
		client_print(id,print_console,"[DoD ClanMatch] %L",id,"FFINVALID",ff)
		return PLUGIN_HANDLED
	}
	if(showtime < 0 || showtime > 4)
	{	
		client_print(id,print_console,"[DoD ClanMatch] %L",id,"SHOWTIMEINVALID",showtime)
		return PLUGIN_HANDLED
	}
	if(showscore < 0 || showscore > 6)
	{	
		client_print(id,print_console,"[DoD ClanMatch] %L",id,"SHOWSCOREINVALID",showscore)
		return PLUGIN_HANDLED
	}
	set_cvar_string("dod_cm_map1",map1)
	set_cvar_string("dod_cm_map2",map2)
	set_pcvar_num(dod_cm_mapmode,mapmode)
	set_pcvar_num(dod_cm_time,mtime)
	set_pcvar_num(dod_cm_ff,ff)
	set_pcvar_num(dod_cm_showtime,showtime)
	set_pcvar_num(dod_cm_showscore,showscore)
	client_print(id,print_console,"[DoD ClanMatch] Map1 = %s ; Map2 = %s ; MapMode = %d ; Time = %d ; FF = %d ; ",map1,map2,mapmode,mtime,ff)
	client_print(id,print_console,"ShowTime = %d ; ShowScore = %d",showtime,showscore)
	return PLUGIN_HANDLED
}

public cmd_setdodmatchb(id,level,cid)
{
	if(!cmd_access(id,level,cid,8))
	{
		return PLUGIN_HANDLED
	}
	if(get_cvar_num("mp_clan_match") == 1 && get_pcvar_num(dod_clanmatch) == 1)
	{
		client_print(id,print_console,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
		client_print(id,print_chat,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
		return PLUGIN_HANDLED
	}
	new serverpass[32]
	read_argv(1,serverpass,32)
	new servername[128]
	read_argv(2,servername,128)
	new clantag1[32]
	read_argv(3,clantag1,32)
	new clantag2[32]
	read_argv(4,clantag2,32)
	new readysig[32]
	read_argv(5,readysig,32)
	new cancelsig[32]
	read_argv(6,cancelsig,32)
	new matchresulttime_s[5]
	read_argv(7,matchresulttime_s,5)
	new matchresulttime = str_to_num(matchresulttime_s)
	if(strlen(serverpass) < 1 || equal(serverpass,"none") == 1)
	{	
		client_print(id,print_console,"[DoD ClanMatch] %L",id,"PWINVALID",serverpass)
		return PLUGIN_HANDLED
	}
	set_cvar_string("dod_cm_serverpass",serverpass)
	set_cvar_string("dod_cm_servername",servername)
	set_cvar_string("dod_cm_clantag1",clantag1)
	set_cvar_string("dod_cm_clantag2",clantag2)
	set_cvar_string("dod_cm_readysig",readysig)
	set_cvar_string("dod_cm_cancelsig",cancelsig)
	set_pcvar_num(dod_cm_matchresulttime,matchresulttime)
	client_print(id,print_console,"[DoD ClanMatch] Password = %s ; ServerName = %s ; ClanTag1 = %s ; ClanTag2 = %s ; ",serverpass,servername,clantag1,clantag2)
	client_print(id,print_console,"ReadySignal = %s ; CancelSignal = %s ; MatchResultTime = %d",readysig,cancelsig,matchresulttime)
	return PLUGIN_HANDLED
}

public cmd_startdodmatch(id,level,cid)
{
	if(!cmd_access(id,level,cid,1))
	{
		return PLUGIN_HANDLED
	}
	if(get_cvar_num("mp_clan_match") == 1 && get_pcvar_num(dod_clanmatch) == 1)
	{
		client_print(id,print_console,"[DoD ClanMatch] %L",id,"MATCHALREADYLIVE")
		client_print(id,print_chat,"[DoD ClanMatch] %L",id,"MATCHALREADYLIVE")
		if(usingmenu[id] == 1)
		{
			usingmenu[id] = 0
			clanmatch_menu(id)
		}
		return PLUGIN_HANDLED
	}
	set_cvar_num("mp_clan_match",1)
	set_pcvar_num(dod_clanmatch,1)
	set_pcvar_num(dod_cm_mapsplayed,0)
	reset_scores()
	matchdone = 0
	new serverpass[32]
	get_cvar_string("dod_cm_serverpass",serverpass,31)
	set_cvar_string("sv_password",serverpass)
	new servername[128]
	get_cvar_string("dod_cm_servername",servername,127)
	server_cmd("hostname ^"%s^"",servername)
	set_task(1.0,"change_to_startmap")
	return PLUGIN_HANDLED
}

public change_to_startmap()
{
	new startmap[128]
	get_cvar_string("dod_cm_map1",startmap,63)
	server_cmd("changelevel %s",startmap)
	return PLUGIN_HANDLED
}

public cmd_stopdodmatch(id,level,cid)
{
	if(!cmd_access(id,level,cid,1))
	{
		return PLUGIN_HANDLED
	}
	if(get_cvar_num("mp_clan_match") == 0 && get_pcvar_num(dod_clanmatch) == 0)
	{
		client_print(id,print_console,"[DoD ClanMatch] %L",id,"MATCHNOTLIVE")
		client_print(id,print_chat,"[DoD ClanMatch] %L",id,"MATCHNOTLIVE")
		if(usingmenu[id] == 1)
		{
			usingmenu[id] = 0
			clanmatch_menu(id)
		}
		return PLUGIN_HANDLED
	}
	set_cvar_num("mp_clan_match",0)
	set_pcvar_num(dod_clanmatch,0)
	set_pcvar_num(dod_cm_mapsplayed,0)
	reset_scores()
	remove_task(73823)
	remove_task(53452)
	remove_task(98125)
	matchrunning = 0
	load_standard()
	set_hudmessage(0, 0, 255, -1.0, -1.0, 0, 6.0, 10.0, 0.1, 0.2, 4)
	show_hudmessage(0,"%L",LANG_PLAYER,"MATCHABORTED")
	if(usingmenu[id] == 1)
	{
		usingmenu[id] = 0
		clanmatch_menu(id)
		client_print(id,print_chat,"[DoD ClanMatch] %L",id,"MATCHABORTED")
	}
	return PLUGIN_HANDLED
}

public reset_scores()
{
	set_pcvar_num(dod_cm_map11scoreaxis,0)
	set_pcvar_num(dod_cm_map11scoreallies,0)
	set_pcvar_num(dod_cm_map21scoreaxis,0)
	set_pcvar_num(dod_cm_map21scoreallies,0)
	set_pcvar_num(dod_cm_map12scoreaxis,0)
	set_pcvar_num(dod_cm_map12scoreallies,0)
	set_pcvar_num(dod_cm_map22scoreaxis,0)
	set_pcvar_num(dod_cm_map22scoreallies,0)
	return PLUGIN_HANDLED
}
	
public cmd_readycancel(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
	{
		return PLUGIN_CONTINUE
	}
	if(get_cvar_num("mp_clan_match") == 0 && get_pcvar_num(dod_clanmatch) == 0)
	{
		return PLUGIN_CONTINUE
	}
	new word[32]
	read_argv(1,word,32)
	new cancelsig[32]
	get_cvar_string("dod_cm_cancelsig",cancelsig,31)
	if((equal(word,cancelsig) != 1) || (clansready != 1 && matchrunning != 0))
	{
		return PLUGIN_CONTINUE
	}
	new clantag1[32]
	get_cvar_string("dod_cm_clantag1",clantag1,31)
	new clantag2[32]
	get_cvar_string("dod_cm_clantag2",clantag2,31)
	new cm_mapmode = get_pcvar_num(dod_cm_mapmode)
	new cm_mapsplayed = get_pcvar_num(dod_cm_mapsplayed)
	if((cm_mapmode == 1 && cm_mapsplayed == 1) || (cm_mapmode == 2 && cm_mapsplayed == 1) || (cm_mapmode == 2 && cm_mapsplayed == 3))
	{
		if(get_user_team(id) == ALLIES && alliesready == 1)
		{
			alliesready = 0
			clansready--
			set_cvar_num("mp_clan_readyrestart",1)
			set_hudmessage(0, 255, 0, 0.03, 0.5, 0, 6.0, 5.0, 0.1, 0.2, 4)
			show_hudmessage(id,"%L",id,"REVOKEDREADY",clantag2)
		}
		else if(get_user_team(id) == AXIS && axisready == 1)
		{
			axisready = 0
			clansready--
			set_cvar_num("mp_clan_readyrestart",1)
			set_hudmessage(255, 0, 0, 0.03, 0.3, 0, 6.0, 5.0, 0.1, 0.2, 3)
			show_hudmessage(id,"%L",id,"REVOKEDREADY",clantag1)
		}		
	}
	if((cm_mapmode == 1 && cm_mapsplayed == 2) || (cm_mapmode == 2 && cm_mapsplayed == 2) || (cm_mapmode == 2 && cm_mapsplayed == 4))
	{
		if(get_user_team(id) == ALLIES && alliesready == 1)
		{
			alliesready = 0
			clansready--
			set_cvar_num("mp_clan_readyrestart",1)
			set_hudmessage(0, 255, 0, 0.03, 0.5, 0, 6.0, 5.0, 0.1, 0.2, 4)
			show_hudmessage(id,"%L",id,"REVOKEDREADY",clantag1)
		}
		else if(get_user_team(id) == AXIS && axisready == 1)
		{
			axisready = 0
			clansready--
			set_cvar_num("mp_clan_readyrestart",1)
			set_hudmessage(255, 0, 0, 0.03, 0.3, 0, 6.0, 5.0, 0.1, 0.2, 3)
			show_hudmessage(id,"%L",id,"REVOKEDREADY",clantag2)
		}
	}	
	return PLUGIN_HANDLED
}

public axis_ready()
{
	axisready = 1
	clansready++
	new clantag1[32]
	get_cvar_string("dod_cm_clantag1",clantag1,31)
	new clantag2[32]
	get_cvar_string("dod_cm_clantag2",clantag2,31)
	new cancelsig[32]
	get_cvar_string("dod_cm_cancelsig",cancelsig,31)
	new cm_mapmode = get_pcvar_num(dod_cm_mapmode)
	new cm_mapsplayed = get_pcvar_num(dod_cm_mapsplayed)
	set_hudmessage(255, 0, 0, 0.03, 0.3, 0, 6.0, 5.0, 0.1, 0.2, 3)
	if((cm_mapmode == 1 && cm_mapsplayed == 1) || (cm_mapmode == 2 && cm_mapsplayed == 1) || (cm_mapmode == 2 && cm_mapsplayed == 3))
	{
		show_hudmessage(0,"%L",LANG_PLAYER,"READYTOFIGHT",clantag1)
	}
	if((cm_mapmode == 1 && cm_mapsplayed == 2) || (cm_mapmode == 2 && cm_mapsplayed == 2) || (cm_mapmode == 2 && cm_mapsplayed == 4))
	{
		show_hudmessage(0,"%L",LANG_PLAYER,"READYTOFIGHT",clantag2)
	}
	new plist[32],pnum
	get_players(plist,pnum)
	for(new i=0; i<pnum; i++)
	{
		new id = plist[i]
		if(is_user_connected(id) == 1 && get_user_team(id) == AXIS && axisready == 1 && clansready == 1)
		{
			set_hudmessage(255, 0, 0, -1.0, 0.8, 0, 6.0, 5.0, 0.1, 0.2, 4)
			show_hudmessage(id,"%L",id,"SAYREVOKE",cancelsig)
		}
	}
	return PLUGIN_HANDLED
}

public allies_ready()
{
	alliesready = 1
	clansready++
	new clantag1[32]
	get_cvar_string("dod_cm_clantag1",clantag1,31)
	new clantag2[32]
	get_cvar_string("dod_cm_clantag2",clantag2,31)
	new cancelsig[32]
	get_cvar_string("dod_cm_cancelsig",cancelsig,31)
	new cm_mapmode = get_pcvar_num(dod_cm_mapmode)
	new cm_mapsplayed = get_pcvar_num(dod_cm_mapsplayed)
	set_hudmessage(0, 255, 0, 0.03, 0.5, 0, 6.0, 5.0, 0.1, 0.2, 4)
	if((cm_mapmode == 1 && cm_mapsplayed == 1) || (cm_mapmode == 2 && cm_mapsplayed == 1) || (cm_mapmode == 2 && cm_mapsplayed == 3))
	{
		show_hudmessage(0,"%L",LANG_PLAYER,"READYTOFIGHT",clantag2)
	}
	if((cm_mapmode == 1 && cm_mapsplayed == 2) || (cm_mapmode == 2 && cm_mapsplayed == 2) || (cm_mapmode == 2 && cm_mapsplayed == 4))
	{
		show_hudmessage(0,"%L",LANG_PLAYER,"READYTOFIGHT",clantag1)
	}
	new plist[32],pnum
	get_players(plist,pnum)
	for(new i=0; i<pnum; i++)
	{
		new id = plist[i]
		if(is_user_connected(id) == 1 && get_user_team(id) == ALLIES && alliesready == 1 && clansready == 1)
		{
			set_hudmessage(0, 255, 0, -1.0, 0.8, 0, 6.0, 5.0, 0.1, 0.2, 3)
			show_hudmessage(id,"%L",id,"SAYREVOKE",cancelsig)
		}
	}
	return PLUGIN_HANDLED
}

public show_tr()
{
	new tl = get_timeleft()
	new ml = tl / 60
	if(get_pcvar_num(dod_cm_showtime) == 3)
	{
		if(ml > 1)
		{
			set_hudmessage(255, 255, 255, -1.0, 0.9, 0, 6.0, 6.0, 0.1, 0.2, 4)
			show_hudmessage(0,".: %d min :.",ml)
		}
		else if(ml <= 1)
		{
			set_hudmessage(255, 255, 255, -1.0, 0.9, 0, 6.0, 6.0, 0.1, 0.2, 4)
			show_hudmessage(0,".: %L :.",LANG_PLAYER,"LASTMINUTE")
			remove_task(98125)
		}
	}
	else if(get_pcvar_num(dod_cm_showtime) == 4)
	{
		if(ml > 1)
		{
			client_print(0,print_chat,"[DoD ClanMatch] %L",LANG_PLAYER,"MINREMAINING",ml)
		}
		else if(ml <= 1)
		{
			client_print(0,print_chat,"[DoD ClanMatch] %L",LANG_PLAYER,"LASTMINUTE",ml)
			remove_task(98125)
		}
	}
	return PLUGIN_HANDLED
}

public show_tscores()
{
	catch_scores()
	set_task(1.0,"show_tscores_real")
	return PLUGIN_HANDLED
}

public show_tscores_real()
{
	new cm_showscore = get_pcvar_num(dod_cm_showscore)
	if(cm_showscore != 5 && cm_showscore != 6)
	{
		return PLUGIN_HANDLED
	}
	new axisscore = dod_get_team_score(AXIS)
	new alliesscore = dod_get_team_score(ALLIES)
	new clantag1[32]
	get_cvar_string("dod_cm_clantag1",clantag1,31)
	new clantag2[32]
	get_cvar_string("dod_cm_clantag2",clantag2,31)
	new map11axis = get_pcvar_num(dod_cm_map11scoreaxis)
	new map11allies = get_pcvar_num(dod_cm_map11scoreallies)
	new map21axis = get_pcvar_num(dod_cm_map21scoreaxis)
	new map21allies = get_pcvar_num(dod_cm_map21scoreallies)
	new team1total, team2total
	new cm_mapmode = get_pcvar_num(dod_cm_mapmode)
	if(cm_mapmode == 1)
	{
		team1total = (map11axis+map21allies)
		team2total = (map11allies+map21axis)
	}
	else if(cm_mapmode == 2)
	{
		new map12axis = get_pcvar_num(dod_cm_map12scoreaxis)
		new map12allies = get_pcvar_num(dod_cm_map12scoreallies)
		new map22axis = get_pcvar_num(dod_cm_map22scoreaxis)
		new map22allies = get_pcvar_num(dod_cm_map22scoreallies)
		team1total = (map11axis+map12allies+map21axis+map22allies)
		team2total = (map11allies+map12axis+map21allies+map22axis)
	}
	if(cm_showscore == 5)
	{
		set_hudmessage(255, 153, 1, -1.0, 0.3, 0, 6.0, 6.0, 0.1, 0.2, 3)
		show_hudmessage(0,".: Axis (%d - %d) Allies :.^n^nClan %s: %d^nClan %s: %d",axisscore,alliesscore,clantag1,team1total,clantag2,team2total)
	}
	else if(cm_showscore == 6)
	{
		client_print(0,print_chat,"[DoD ClanMatch] Axis (%d - %d) Allies",axisscore,alliesscore)
		client_print(0,print_chat,"[DoD ClanMatch] Clan %s  %d  -  %d  Clan %s",clantag1,team1total,team2total,clantag2)
	}
	return PLUGIN_HANDLED
}

public cmd_dodrestartround(id,level,cid)
{
	if(!cmd_access(id,level,cid,1))
	{
		return PLUGIN_HANDLED
	}
	if(get_cvar_num("mp_clan_match") == 0 || get_pcvar_num(dod_clanmatch) == 0 || matchrunning == 0)
	{
		client_print(id,print_console,"[DoD ClanMatch] %L",id,"CANTRESTART")
		client_print(id,print_chat,"[DoD ClanMatch] %L",id,"CANTRESTART")
		if(usingmenu[id] == 1)
		{
			usingmenu[id] = 0
			clanmatch_menu(id)
		}
		return PLUGIN_HANDLED
	}
	new cm_mapmode = get_pcvar_num(dod_cm_mapmode)
	new cm_mapsplayed = get_pcvar_num(dod_cm_mapsplayed)
	if((cm_mapmode == 1 && cm_mapsplayed == 1) || (cm_mapmode == 2 && cm_mapsplayed == 1))
	{
		set_pcvar_num(dod_cm_map11scoreaxis,0)
		set_pcvar_num(dod_cm_map11scoreallies,0)
	}
	if((cm_mapmode == 1 && cm_mapsplayed == 2) || (cm_mapmode == 2 && cm_mapsplayed == 3))
	{
		set_pcvar_num(dod_cm_map21scoreaxis,0)
		set_pcvar_num(dod_cm_map21scoreallies,0)
	}
	if(cm_mapmode == 2 && cm_mapsplayed == 2)
	{
		set_pcvar_num(dod_cm_map12scoreaxis,0)
		set_pcvar_num(dod_cm_map12scoreallies,0)
	}
	if(cm_mapmode == 2 && cm_mapsplayed == 4)
	{
		set_pcvar_num(dod_cm_map22scoreaxis,0)
		set_pcvar_num(dod_cm_map22scoreallies,0)
	}
	set_cvar_num("mp_clan_match",1)
	set_cvar_num("mp_clan_readyrestart",1)
	new secleft = get_timeleft()
	new minleft = secleft / 60
	new timelimit = get_cvar_num("mp_timelimit")
	set_cvar_num("mp_timelimit",(120 + (timelimit - minleft)))
	remove_task(98125)
	remove_task(17265)
	clansready = 0
	alliesready = 0
	axisready = 0
	matchdone = 0
	matchrunning = 0
	set_task(5.0,"ready_remind",53452,"",0,"b")
	if(usingmenu[id] == 1)
	{
		usingmenu[id] = 0
		clanmatch_menu(id)
		client_print(id,print_chat,"[DoD ClanMatch] %L",id,"RESTARTING")
	}
	return PLUGIN_HANDLED
}
	
public calc_seconds()
{
	new secleft = get_timeleft()
	new matchsec = get_pcvar_num(dod_cm_time)*60
	secdiff = secleft - matchsec
	set_task(Float:float(secdiff),"delayed_mapchange",73823,"",0,"d")
	return PLUGIN_HANDLED
}

public match_start()
{
	if(clansready == 2  && matchrunning == 0)
	{
		clansready = 0
		remove_task(53452)
		alliesready = 0
		axisready = 0
		new secleft = get_timeleft()
		new minleft = secleft / 60
		new timelimit = get_cvar_num("mp_timelimit")
		new matchlimit = get_pcvar_num(dod_cm_time)
		set_cvar_num("mp_timelimit",(matchlimit + (timelimit - minleft)))
		matchrunning = 1
		set_task(0.1,"calc_seconds")		
	}
	if(get_cvar_num("mp_clan_match") == 1 && get_pcvar_num(dod_clanmatch) == 1 && matchrunning == 1)
	{
		if(get_pcvar_num(dod_cm_showtime) != 0)
		{
			new cm_showtime = get_pcvar_num(dod_cm_showtime)
			new tl = get_timeleft()
			new ml = tl / 60
			if(cm_showtime == 1)
			{			
				set_hudmessage(255, 255, 255, -1.0, 0.9, 0, 6.0, 6.0, 0.1, 0.2, 4)
				show_hudmessage(0,".: %d min :.",ml)
			}
			else if(cm_showtime == 2)
			{
				client_print(0,print_chat,"[DoD ClanMatch] %L",LANG_PLAYER,"MINREMAINING",ml)
			}
			else if(cm_showtime == 3 && task_exists(98125) == 0)
			{			
				set_hudmessage(255, 255, 255, -1.0, 0.9, 0, 6.0, 6.0, 0.1, 0.2, 4)
				show_hudmessage(0,".: %d min :.",ml)
				set_task(60.0,"show_tr",98125,"",0,"b")
			}
			else if(cm_showtime == 4 && task_exists(98125) == 0)
			{			
				client_print(0,print_chat,"[DoD ClanMatch] %L",LANG_PLAYER,"MINREMAINING",ml)
				set_task(60.0,"show_tr",98125,"",0,"b")
			}
		}
		if(get_pcvar_num(dod_cm_showscore) != 0)
		{
			new cm_showscore = get_pcvar_num(dod_cm_showscore)
			new axisscore = dod_get_team_score(AXIS)
			new alliesscore = dod_get_team_score(ALLIES)
			new clantag1[32]
			get_cvar_string("dod_cm_clantag1",clantag1,31)
			new clantag2[32]
			get_cvar_string("dod_cm_clantag2",clantag2,31)
			new team1total, team2total
			if(cm_showscore >= 3 && cm_showscore <= 6)
			{
				new map11axis = get_pcvar_num(dod_cm_map11scoreaxis)
				new map11allies = get_pcvar_num(dod_cm_map11scoreallies)
				new map21axis = get_pcvar_num(dod_cm_map21scoreaxis)
				new map21allies = get_pcvar_num(dod_cm_map21scoreallies)
				if(get_pcvar_num(dod_cm_mapmode) == 1)
				{
					team1total = (map11axis+map21allies)
					team2total = (map11allies+map21axis)
				}
				else if(get_pcvar_num(dod_cm_mapmode) == 2)
				{
					new map12axis = get_pcvar_num(dod_cm_map12scoreaxis)
					new map12allies = get_pcvar_num(dod_cm_map12scoreallies)
					new map22axis = get_pcvar_num(dod_cm_map22scoreaxis)
					new map22allies = get_pcvar_num(dod_cm_map22scoreallies)
					team1total = (map11axis+map12allies+map21axis+map22allies)
					team2total = (map11allies+map12axis+map21allies+map22axis)
				}
			}
			if(cm_showscore == 1)
			{
				set_hudmessage(255, 153, 1, -1.0, 0.3, 0, 6.0, 6.0, 0.1, 0.2, 3)
				show_hudmessage(0,".: Axis (%d - %d) Allies :.",axisscore,alliesscore)
			}
			else if(cm_showscore == 2)
			{
				client_print(0,print_chat,"[DoD ClanMatch] Axis (%d - %d) Allies",axisscore,alliesscore)
			}
			if(cm_showscore == 4)
			{
				set_hudmessage(255, 153, 1, -1.0, 0.3, 0, 6.0, 6.0, 0.1, 0.2, 3)
				show_hudmessage(0,".: Axis (%d - %d) Allies :.^n^nClan %s: %d^nClan %s: %d",axisscore,alliesscore,clantag1,team1total,clantag2,team2total)
			}
			else if(cm_showscore == 4)
			{
				client_print(0,print_chat,"[DoD ClanMatch] Axis (%d - %d) Allies",axisscore,alliesscore)
				client_print(0,print_chat,"[DoD ClanMatch] Clan %s  %d  -  %d  Clan %s",clantag1,team1total,team2total,clantag2)
			}
			else if(cm_showscore == 5 && task_exists(17265) == 0)
			{			
				set_hudmessage(255, 153, 1, -1.0, 0.3, 0, 6.0, 6.0, 0.1, 0.2, 3)
				show_hudmessage(0,".: Axis (%d - %d) Allies :.^n^nClan %s: %d^nClan %s: %d",axisscore,alliesscore,clantag1,team1total,clantag2,team2total)
				set_task(60.0,"show_tscores",17265,"",0,"b")
			}
			else if(cm_showscore == 6 && task_exists(17265) == 0)
			{			
				client_print(0,print_chat,"[DoD ClanMatch] Axis (%d - %d) Allies",axisscore,alliesscore)
				client_print(0,print_chat,"[DoD ClanMatch] Clan %s  %d  -  %d  Clan %s",clantag1,team1total,team2total,clantag2)
				set_task(60.0,"show_tscores",17265,"",0,"b")
			}
		}
	}
	return PLUGIN_HANDLED
}

public clanmatch_result(id)
{
	if(matchdone == 0 || is_user_bot(id) == 1 || is_user_hltv(id) == 1 || sawresult[id] == 1)
	{
		return PLUGIN_HANDLED
	}
	new show_result[1024]
	new key
	new map11axis = get_pcvar_num(dod_cm_map11scoreaxis)
	new map11allies = get_pcvar_num(dod_cm_map11scoreallies)
	new map21axis = get_pcvar_num(dod_cm_map21scoreaxis)
	new map21allies = get_pcvar_num(dod_cm_map21scoreallies)
	new clantag1[32]
	get_cvar_string("dod_cm_clantag1",clantag1,31)
	new clantag2[32]
	get_cvar_string("dod_cm_clantag2",clantag2,31)
	new team1total, team2total
	new winnerteam[32], scorediff
	if(get_pcvar_num(dod_cm_mapmode) == 1)
	{
		team1total = (map11axis+map21allies)
		team2total = (map11allies+map21axis)
	}
	else if(get_pcvar_num(dod_cm_mapmode) == 2)
	{
		new map12axis = get_pcvar_num(dod_cm_map12scoreaxis)
		new map12allies = get_pcvar_num(dod_cm_map12scoreallies)
		new map22axis = get_pcvar_num(dod_cm_map22scoreaxis)
		new map22allies = get_pcvar_num(dod_cm_map22scoreallies)
		team1total = (map11axis+map12allies+map21axis+map22allies)
		team2total = (map11allies+map12axis+map21allies+map22axis)
	}
	if(team1total > team2total)
	{
		winnerteam = clantag1
		scorediff = (team1total-team2total)
	}
	else if(team1total < team2total)
	{
		winnerteam = clantag2
		scorediff = (team2total-team1total)
	}
	else if(team1total == team2total)
	{
		winnerteam = "DRAW"
		scorediff = (team1total-team2total)
	}
	format(show_result,1023,"\rDoD ClanMatch Result^n^n\yClan %s^n\w- Total Score: %d^n^n\yClan %s^n\w- Total Score: %d^n^n\yWinner: \w%s with %dpoints difference!^n^n\r2. \wDetails  /  \r3. \wMap Scores  /  \r0. \wClose",clantag1,team1total,clantag2,team2total,winnerteam,scorediff)
	key = (1<<1)|(1<<2)|(1<<9)
	show_menu(id,key,show_result,-1)
	return PLUGIN_HANDLED
}

public clanmatch_details(id)
{
	new show_details[1024]
	new key
	new mapname1[64]
	new mapname2[64]
	get_cvar_string("dod_cm_map1",mapname1,63)
	get_cvar_string("dod_cm_map2",mapname2,63)
	new map11axis = get_pcvar_num(dod_cm_map11scoreaxis)
	new map11allies = get_pcvar_num(dod_cm_map11scoreallies)
	new map21axis = get_pcvar_num(dod_cm_map21scoreaxis)
	new map21allies = get_pcvar_num(dod_cm_map21scoreallies)
	if(get_pcvar_num(dod_cm_mapmode) == 1)
	{
		format(show_details,1023,"\rDoD ClanMatch Details^n^n\yMap1: %s^n\w- Axis: %d^n- Allies: %d^n^n\yMap2: %s^n\w- Axis: %d^n- Allies: %d^n^n\r1. \wResult  /  \r3. \wMap Scores  /  \r0. \wClose",mapname1,map11axis,map11allies,mapname2,map21axis,map21allies)
	}
	else if(get_pcvar_num(dod_cm_mapmode) == 2)
	{
		new map12axis = get_pcvar_num(dod_cm_map12scoreaxis)
		new map12allies = get_pcvar_num(dod_cm_map12scoreallies)
		new map22axis = get_pcvar_num(dod_cm_map22scoreaxis)
		new map22allies = get_pcvar_num(dod_cm_map22scoreallies)
		format(show_details,1023,"\rDoD ClanMatch Details^n^n\yMap1: %s Round1^n\w- Axis: %d^n- Allies: %d^n\yMap1: %s Round2^n\w- Axis: %d^n- Allies: %d^n^n\yMap2: %s Round1^n\w- Axis: %d^n- Allies: %d^n\yMap2: %s Round2^n\w- Axis: %d^n- Allies: %d^n^n\r1. \wResult  /  \r3. \wMap Scores  /  \r0. \wClose",mapname1,map11axis,map11allies,mapname1,map12axis,map12allies,mapname2,map21axis,map21allies,mapname2,map22axis,map22allies)
	}
	key = (1<<0)|(1<<2)|(1<<9)
	show_menu(id,key,show_details,-1)
	return PLUGIN_HANDLED
}

public clanmatch_mapscores(id)
{
	new show_mapscores[1024]
	new key
	new mapname1[64]
	new mapname2[64]
	get_cvar_string("dod_cm_map1",mapname1,63)
	get_cvar_string("dod_cm_map2",mapname2,63)
	new clantag1[32]
	get_cvar_string("dod_cm_clantag1",clantag1,31)
	new clantag2[32]
	get_cvar_string("dod_cm_clantag2",clantag2,31)
	new map11axis = get_pcvar_num(dod_cm_map11scoreaxis)
	new map11allies = get_pcvar_num(dod_cm_map11scoreallies)
	new map21axis = get_pcvar_num(dod_cm_map21scoreaxis)
	new map21allies = get_pcvar_num(dod_cm_map21scoreallies)
	if(get_pcvar_num(dod_cm_mapmode) == 1)
	{
		format(show_mapscores,1023,"\rDoD ClanMatch Map Scores^n^n\yMap1: %s^n\w- Clan %s: %d^n- Clan %s: %d^n^n\yMap2: %s^n\w- Clan %s: %d^n- Clan %s: %d^n^n\r1. \wResult  /  \r2. \wDetails  /  \r0. \wClose",mapname1,clantag1,map11axis,clantag2,map11allies,mapname2,clantag1,map21allies,clantag2,map21axis)
	}
	else if(get_pcvar_num(dod_cm_mapmode) == 2)
	{
		new map12axis = get_pcvar_num(dod_cm_map12scoreaxis)
		new map12allies = get_pcvar_num(dod_cm_map12scoreallies)
		new map22axis = get_pcvar_num(dod_cm_map22scoreaxis)
		new map22allies = get_pcvar_num(dod_cm_map22scoreallies)
		new clan1score1 = (map11axis + map12allies)
		new clan2score1 = (map11allies + map12axis)
		new clan1score2 = (map21axis + map22allies)
		new clan2score2 = (map21allies + map22axis)
		format(show_mapscores,1023,"\rDoD ClanMatch Map Scores^n^n\yMap1: %s^n\w- Clan %s: %d^n- Clan %s: %d^n^n\yMap2: %s^n\w- Clan %s: %d^n- Clan %s: %d^n^n\r1. \wResult  /  \r2. \wDetails  /  \r0. \wClose",mapname1,clantag1,clan1score1,clantag2,clan2score1,mapname2,clantag1,clan1score2,clantag2,clan2score2)
	}
	key = (1<<0)|(1<<1)|(1<<9)
	show_menu(id,key,show_mapscores,-1)
	return PLUGIN_HANDLED
}

public match_result(id,key)
{
	switch(key)
	{
		case 1:
		{
			clanmatch_details(id)
			return PLUGIN_HANDLED
		}
		case 2:
		{
			clanmatch_mapscores(id)
			return PLUGIN_HANDLED
		}
		case 9:
		{
			sawresult[id] = 1
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public match_details(id,key)
{
	switch(key)
	{
		case 0:
		{
			clanmatch_result(id)
			return PLUGIN_HANDLED
		}
		case 2:
		{
			clanmatch_mapscores(id)
			return PLUGIN_HANDLED
		}
		case 9:
		{
			sawresult[id] = 1
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public match_mapscores(id,key)
{
	switch(key)
	{
		case 0:
		{
			clanmatch_result(id)
			return PLUGIN_HANDLED
		}
		case 1:
		{
			clanmatch_details(id)
			return PLUGIN_HANDLED
		}
		case 9:
		{
			sawresult[id] = 1
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public spec_first(id)
{
	if(get_cvar_num("mp_clan_match") == 1 && get_pcvar_num(dod_clanmatch) == 1 && matchdone == 0 && knowsteam[id] == 0)
	{
		engclient_cmd(id,"jointeam","3")
		set_task(1.0,"organizeteams",id,"",0,"b")
		knowsteam[id] = 1
		return PLUGIN_HANDLED
	}
	if(get_cvar_num("mp_clan_match") == 1 && get_pcvar_num(dod_clanmatch) == 1 && matchdone == 0 && knowsteam[id] == 1)
	{
		if(task_exists(id))
		{
			remove_task(id)
		}
		return PLUGIN_CONTINUE
	}
	if(get_cvar_num("mp_clan_match") == 0 && get_pcvar_num(dod_clanmatch) == 0 && matchdone == 1 && sawresult[id] == 0)
	{
		engclient_cmd(id,"jointeam","3")
		clanmatch_result(id)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public organizeteams(id)
{
	new clantag1[32]
	get_cvar_string("dod_cm_clantag1",clantag1,31)
	new clantag2[32]
	get_cvar_string("dod_cm_clantag2",clantag2,31)
	set_hudmessage(255, 255, 255, -1.0, -1.0, 0, 6.0, 1.0, 0.1, 0.2, 3)
	new cm_mapmode = get_pcvar_num(dod_cm_mapmode)
	new cm_mapsplayed = get_pcvar_num(dod_cm_mapsplayed)
	if((cm_mapmode == 1 && cm_mapsplayed == 1) || (cm_mapmode == 2 && cm_mapsplayed == 1) || (cm_mapmode == 2 && cm_mapsplayed == 3))
	{
		show_hudmessage(id,"%L",id,"CLANJOINTEAM",clantag1,clantag2)
	}
	if((cm_mapmode == 1 && cm_mapsplayed == 2) || (cm_mapmode == 2 && cm_mapsplayed == 2) || (cm_mapmode == 2 && cm_mapsplayed == 4))
	{
		show_hudmessage(id,"%L",id,"CLANJOINTEAM",clantag2,clantag1)
	}
	return PLUGIN_HANDLED
}

public changemap1menu(id,key)
{
	switch (key)
	{
		case 7:
		{
			displayMap1Menu(id,++g_menuPosition[id])
		}
		case 8:
		{
			displayMap1Menu(id,--g_menuPosition[id])
		}
		default:
		{
			new a = g_menuPosition[id] * 6 + key
			set_cvar_string("dod_cm_map1",g_mapName[a])
			client_print(id,print_chat,"[DoD ClanMatch] Map1 %L: %s!",id,"SETTO",g_mapName[a])
			clanmatch_changesettings1(id)
		}
	}
	return PLUGIN_HANDLED
}

public displayMap1Menu(id,pos)
{
	if (pos < 0)
	{
		clanmatch_changesettings1(id)
		return
	}
	new currmap1[64]
	get_cvar_string("dod_cm_map1",currmap1,63)
	new menuBody[1024]
	new start = pos * 6
	new b = 0
	if (start >= g_mapNums)
	{
		start = pos = g_menuPosition[id] = 0
	}
	new len = format(menuBody,1023,"\rDoD ClanMatch Map1\R%d/%d^n^n\yCurrent setting: \w%s^n^n\yChange Map1 to\w^n",pos+1,(g_mapNums/6+((g_mapNums%6)?1:0)),currmap1)
	new end = start + 6
	new keys = MENU_KEY_9
	if (end > g_mapNums)
	{
		end = g_mapNums
	}
	for (new a = start; a < end; ++a)
	{
		keys |= (1<<b)
		len += format(menuBody[len],1023-len,"\r%d. \w %s^n",++b,g_mapName[a])
	}
	if (end != g_mapNums)
	{
		format(menuBody[len],1023-len,"^n\y8. \wmore...^n\y9. \w%s", pos ? "back..." : "Settings Menu")
		keys |= MENU_KEY_8
	}
	else
	{
		format(menuBody[len],1023-len,"^n\y9. \wback...")
	}
	show_menu(id,keys,menuBody,-1)
}

loadmatchmaps(filename[])
{
	if (!file_exists(filename))
	{
		return 0
	}
	new text[256]
	new a , pos = 0
	while (g_mapNums < MAX_MAPS && read_file(filename,pos++,text,255,a))
	{
		if (text[0] == ';')
		{
			continue
		}
		if (parse(text,g_mapName[g_mapNums],31) < 1)
		{
			continue
		}
		if (!is_map_valid(g_mapName[g_mapNums]))
		{
			continue
		}
		g_mapNums++
	}
	return 1
}

public changemap2menu(id,key)
{
	switch (key)
	{
		case 7:
		{
			displayMap2Menu(id,++g_menuPosition[id])
		}
		case 8:
		{
			displayMap2Menu(id,--g_menuPosition[id])
		}
		default:
		{
			new a = g_menuPosition[id] * 6 + key
			set_cvar_string("dod_cm_map2",g_mapName[a])
			client_print(id,print_chat,"[DoD ClanMatch] Map2 %L: %s!",id,"SETTO",g_mapName[a])
			clanmatch_changesettings1(id)
		}
	}
	return PLUGIN_HANDLED
}

public displayMap2Menu(id,pos)
{
	if (pos < 0)
	{
		clanmatch_changesettings1(id)
		return
	}
	new currmap2[64]
	get_cvar_string("dod_cm_map2",currmap2,63)
	new menuBody[1024]
	new start = pos * 6
	new b = 0
	if (start >= g_mapNums)
	{
		start = pos = g_menuPosition[id] = 0
	}
	new len = format(menuBody,1023,"\rDoD ClanMatch Map2\R%d/%d^n^n\yCurrent setting: \w%s^n^n\yChange Map2 to\w^n",pos+1,(g_mapNums/6+((g_mapNums%6)?1:0)),currmap2)
	new end = start + 6
	new keys = MENU_KEY_9
	if (end > g_mapNums)
	{
		end = g_mapNums
	}
	for (new a = start; a < end; ++a)
	{
		keys |= (1<<b)
		len += format(menuBody[len],1023-len,"\r%d. \w %s^n",++b,g_mapName[a])
	}
	if (end != g_mapNums)
	{
		format(menuBody[len],1023-len,"^n\y8. \wmore...^n\y9. \w%s",pos ? "back..." : "Settings Menu")
		keys |= MENU_KEY_8
	}
	else
	{
		format(menuBody[len],1023-len,"^n\y9. \wback...")
	}
	show_menu(id,keys,menuBody,-1)
}

public show_clanmatch_menu(id,level,cid)
{
	if(!cmd_access(id,level,cid,1))
	{
		return PLUGIN_HANDLED
	}
	clanmatch_menu(id)
	return PLUGIN_HANDLED
}

public clanmatch_menu(id)
{
	new show_matchmenu[1024]
	new key
	format(show_matchmenu,1023,"\rDoD ClanMatch Menu^n^n\y1. \wStart ClanMatch^n\y2. \wAbort ClanMatch^n\y3. \wRestart current round^n^n\y4. \wShow Settings^n\y5. \wChange Settings^n^n\y6. \wLoad Settings^n^n\y9. \wClose")
	key = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<8)
	show_menu(id,key,show_matchmenu,-1)
	return PLUGIN_HANDLED
}

public match_menu(id,key)
{
	switch(key)
	{
		case 0:
		{
			usingmenu[id] = 1
			client_cmd(id,"amx_startdodmatch")
			return PLUGIN_HANDLED
		}
		case 1:
		{
			usingmenu[id] = 1
			client_cmd(id,"amx_stopdodmatch")
			return PLUGIN_HANDLED
		}
		case 2:
		{
			usingmenu[id] = 1
			client_cmd(id,"amx_restartdodmatch")
			return PLUGIN_HANDLED
		}
		case 3:
		{
			clanmatch_showsettings(id)
			return PLUGIN_HANDLED
		}
		case 4:
		{
			if(get_cvar_num("mp_clan_match") == 1 && get_pcvar_num(dod_clanmatch) == 1)
			{
				client_print(id,print_chat,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
				clanmatch_menu(id)
				return PLUGIN_HANDLED
			}
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
		case 5:
		{
			if(get_cvar_num("mp_clan_match") == 1 && get_pcvar_num(dod_clanmatch) == 1)
			{
				client_print(id,print_chat,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
				clanmatch_menu(id)
				return PLUGIN_HANDLED
			}
			usingmenu[id] = 1
			client_cmd(id,"amx_loaddodmatch")
			return PLUGIN_HANDLED
		}
		case 8:
		{
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public clanmatch_showsettings(id)
{
	new map1[64]
	get_cvar_string("dod_cm_map1",map1,63)
	new map2[64]
	get_cvar_string("dod_cm_map2",map2,63)
	new mapmode = get_pcvar_num(dod_cm_mapmode)
	new mtime = get_pcvar_num(dod_cm_time)
	new ff = get_pcvar_num(dod_cm_ff)
	new showtime = get_pcvar_num(dod_cm_showtime)
	new showscore = get_pcvar_num(dod_cm_showscore)
	new serverpass[32]
	get_cvar_string("dod_cm_serverpass",serverpass,31)
	new servername[128]
	get_cvar_string("dod_cm_servername",servername,127)
	new clantag1[32]
	get_cvar_string("dod_cm_clantag1",clantag1,31)
	new clantag2[32]
	get_cvar_string("dod_cm_clantag2",clantag2,31)
	new readysig[32]
	get_cvar_string("dod_cm_readysig",readysig,31)
	new cancelsig[32]
	get_cvar_string("dod_cm_cancelsig",cancelsig,31)
	new matchresulttime = get_pcvar_num(dod_cm_matchresulttime)
	new show_settings[1024]
	new key
	format(show_settings,1023,"\rDoD ClanMatch Current Settings^n^n\yMap1: \w%s^n\yMap2: \w%s^n\yMapMode: \w%d^n\yTimeLimit: \w%d^n\yFriendlyFire: \w%d^n\yShowTime: \w%d^n\yShowScore: \w%d^n\yServerPass: \w%s^n\yServerName: \w%s^n\yClanTag1: \w%s^n\yClanTag2: \w%s^n\yReadySig: \w%s^n\yCancelSig: \w%s^n\yMatchResultTime: \w%d^n^n\r9. \wClanMatch Menu",map1,map2,mapmode,mtime,ff,showtime,showscore,serverpass,servername,clantag1,clantag2,readysig,cancelsig,matchresulttime)
	key = (1<<8)
	show_menu(id,key,show_settings,-1)
	return PLUGIN_HANDLED
}

public match_showsettings(id,key)
{
	switch(key)
	{
		case 8:
		{
			clanmatch_menu(id)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public clanmatch_changesettings1(id)
{
	new show_change1[1024]
	new key
	format(show_change1,1023,"\rDoD ClanMatch Change Settings 1/2^n^n\y1. \wMap 1^n\y2. \wMap 2^n\y3. \wMapMode^n\y4. \wTimeLimit^n\y5. \wFriendlyFire^n\y6. \wShowTime^n\y7. \wShowScore^n^n\y8. \wmore...^n\y9. \wClanMatch Menu")
	key = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)
	show_menu(id,key,show_change1,-1)
	return PLUGIN_HANDLED
}

public match_changesettings1(id,key)
{
	switch(key)
	{
		case 0:
		{
			displayMap1Menu(id,g_menuPosition[id] = 0)
			return PLUGIN_HANDLED
		}
		case 1:
		{
			displayMap2Menu(id,g_menuPosition[id] = 0)
			return PLUGIN_HANDLED
		}
		case 2:
		{
			clanmatch_changemapmode(id)
			return PLUGIN_HANDLED
		}
		case 3:
		{
			clanmatch_changetime(id)
			return PLUGIN_HANDLED
		}
		case 4:
		{
			clanmatch_changeff(id)
			return PLUGIN_HANDLED
		}
		case 5:
		{
			clanmatch_changeshowtime(id)
			return PLUGIN_HANDLED
		}
		case 6:
		{
			clanmatch_changeshowscore(id)
			return PLUGIN_HANDLED
		}
		case 7:
		{
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
		case 8:
		{
			clanmatch_menu(id)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public clanmatch_changesettings2(id)
{
	new show_change2[1024]
	new key
	format(show_change2,1023,"\rDoD ClanMatch Change Settings 2/2^n^n\y1. \wServerPassword^n\y2. \wServerName^n\y3. \wClanTag1^n\y4. \wClanTag2^n\y5. \wReadySignal^n\y6. \wCancelSignal^n\y7. \wMatchResultTime^n^n\y8. \wback...^n\y9. \wClanMatch Menu")
	key = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)
	show_menu(id,key,show_change2,-1)
	return PLUGIN_HANDLED
}

public match_changesettings2(id,key)
{
	switch(key)
	{
		case 0:
		{
			clanmatch_changeserverpass(id)
			return PLUGIN_HANDLED
		}
		case 1:
		{
			clanmatch_changeservername(id)
			return PLUGIN_HANDLED
		}
		case 2:
		{
			clanmatch_changeclantag1(id)
			return PLUGIN_HANDLED
		}
		case 3:
		{
			clanmatch_changeclantag2(id)
			return PLUGIN_HANDLED
		}
		case 4:
		{
			clanmatch_changereadysig(id)
			return PLUGIN_HANDLED
		}
		case 5:
		{
			clanmatch_changecancelsig(id)
			return PLUGIN_HANDLED
		}
		case 6:
		{
			clanmatch_changematchresulttime(id)
			return PLUGIN_HANDLED
		}
		case 7:
		{
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
		case 8:
		{
			clanmatch_menu(id)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public clanmatch_changeserverpass(id)
{
	new currpass[32]
	get_cvar_string("dod_cm_serverpass",currpass,31)
	new show_changepass[1024]
	new key
	format(show_changepass,1023,"\rDoD ClanMatch ServerPassword^n^n\yCurrent setting: \w%s^n^n\yChange ServerPassword to^n\r1. \wclanmatch^n\r2. \wmatchrunning^n^n\r3. \wCustomize Password^n^n\y9. \wSettings Menu",currpass)
	key = (1<<0)|(1<<1)|(1<<2)|(1<<8)
	show_menu(id,key,show_changepass,-1)
	return PLUGIN_HANDLED
}

public match_changeserverpass(id,key)
{
	switch(key)
	{
		case 0:
		{
			set_cvar_string("dod_cm_serverpass","clanmatch")
			client_print(id,print_chat,"[DoD ClanMatch] ServerPassword %L: clanmatch",id,"SETTO")
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
		case 1:
		{
			set_cvar_string("dod_cm_serverpass","matchrunning")
			client_print(id,print_chat,"[DoD ClanMatch] ServerPassword %L: matchrunning",id,"SETTO")
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
		case 2:
		{
			usingmenu[id] = 1
			client_cmd(id,"messagemode match_serverpass")
			return PLUGIN_HANDLED
		}
		case 8:
		{
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public cmd_serverpass(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
	{
		return PLUGIN_HANDLED
	}
	if(get_cvar_num("mp_clan_match") == 1 && get_pcvar_num(dod_clanmatch) == 1)
	{
		client_print(id,print_console,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
		client_print(id,print_chat,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
		return PLUGIN_HANDLED
	}
	new serverpass[32]
	read_argv(1,serverpass,32)
	if(strlen(serverpass) < 1 || equal(serverpass,"none") == 1)
	{	
		client_print(id,print_chat,"[DoD ClanMatch] %L",id,"PWINVALID",serverpass)
		return PLUGIN_HANDLED
	}
	set_cvar_string("dod_cm_serverpass",serverpass)
	client_print(id,print_chat,"[DoD ClanMatch] ServerPassword %L: %s",id,"SETTO",serverpass)
	if(usingmenu[id] == 1)
	{
		usingmenu[id] = 0
		clanmatch_changesettings2(id)
	}
	return PLUGIN_HANDLED
}

public cmd_timelimit(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
	{
		return PLUGIN_HANDLED
	}
	if(get_cvar_num("mp_clan_match") == 1 && get_pcvar_num(dod_clanmatch) == 1)
	{
		client_print(id,print_console,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
		client_print(id,print_chat,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
		return PLUGIN_HANDLED
	}
	new timelimit_s[5]
	read_argv(1,timelimit_s,5)
	new timelimit = str_to_num(timelimit_s)
	set_pcvar_num(dod_cm_time,timelimit)
	client_print(id,print_chat,"[DoD ClanMatch] Timelimit %L: %s%L",id,"SETTO",timelimit,id,"MINPERROUND")
	if(usingmenu[id] == 1)
	{
		usingmenu[id] = 0
		clanmatch_changesettings1(id)
	}
	return PLUGIN_HANDLED
}

public clanmatch_changetime(id)
{
	new currtime = get_pcvar_num(dod_cm_time)
	new show_changetime[1024]
	new key
	format(show_changetime,1023,"\rDoD ClanMatch TimeLimit^n^n\yCurrent setting: \w%d minutes per round^n^n\yChange TimeLimit to^n\r1. \w10 minutes^n\r2. \w15 minutes^n\r3. \w20 minutes^n\r4. \w25 minutes^n\r5. \w30 minutes^n^n\r6. \wCustomize TimeLimit^n^n\y9. \wSettings Menu",currtime)
	key = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<8)
	show_menu(id,key,show_changetime,-1)
	return PLUGIN_HANDLED
}

public match_changetime(id,key)
{
	switch(key)
	{
		case 0:
		{
			set_pcvar_num(dod_cm_time,10)
			client_print(id,print_chat,"[DoD ClanMatch] TimeLimit %L: 10%L",id,"SETTO",id,"MINPERROUND")
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
		case 1:
		{
			set_pcvar_num(dod_cm_time,15)
			client_print(id,print_chat,"[DoD ClanMatch] Timelimit %L: 15%L",id,"SETTO",id,"MINPERROUND")
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
		case 2:
		{
			set_pcvar_num(dod_cm_time,20)
			client_print(id,print_chat,"[DoD ClanMatch] Timelimit %L: 20%L",id,"SETTO",id,"MINPERROUND")
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
		case 3:
		{
			set_pcvar_num(dod_cm_time,25)
			client_print(id,print_chat,"[DoD ClanMatch] Timelimit %L: 25%L",id,"SETTO",id,"MINPERROUND")
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
		case 4:
		{
			set_pcvar_num(dod_cm_time,30)
			client_print(id,print_chat,"[DoD ClanMatch] Timelimit %L: 30%L",id,"SETTO",id,"MINPERROUND")
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
		case 5:
		{
			usingmenu[id] = 1
			client_cmd(id,"messagemode match_timelimit")
			return PLUGIN_HANDLED
		}
		case 8:
		{
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public cmd_servername(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
	{
		return PLUGIN_HANDLED
	}
	if(get_cvar_num("mp_clan_match") == 1 && get_pcvar_num(dod_clanmatch) == 1)
	{
		client_print(id,print_console,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
		client_print(id,print_chat,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
		return PLUGIN_HANDLED
	}
	new servername[128]
	read_argv(1,servername,128)
	set_cvar_string("dod_cm_servername",servername)
	client_print(id,print_chat,"[DoD ClanMatch] ServerName %L: %s",id,"SETTO",servername)
	if(usingmenu[id] == 1)
	{
		usingmenu[id] = 0
		clanmatch_changesettings2(id)
	}
	return PLUGIN_HANDLED
}

public clanmatch_changeservername(id)
{
	new currname[32]
	get_cvar_string("dod_cm_servername",currname,31)
	new show_changename[1024]
	new key
	format(show_changename,1023,"\rDoD ClanMatch ServerName^n^n\yCurrent setting: \w%s^n^n\yChange ServerName to^n\r1. \wDoD ClanMatch in progress^n\r2. \wTrainingMatch running^n^n\r3. \wCustomize Name^n^n\y9. \wSettings Menu",currname)
	key = (1<<0)|(1<<1)|(1<<2)|(1<<8)
	show_menu(id,key,show_changename,-1)
	return PLUGIN_HANDLED
}

public match_changeservername(id,key)
{
	switch(key)
	{
		case 0:
		{
			set_cvar_string("dod_cm_servername","DoD ClanMatch in progress")
			client_print(id,print_chat,"[DoD ClanMatch] ServerName %L: DoD ClanMatch in progress",id,"SETTO")
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
		case 1:
		{
			set_cvar_string("dod_cm_servername","TrainingMatch running")
			client_print(id,print_chat,"[DoD ClanMatch] ServerName %L: TrainingMatch running",id,"SETTO")
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
		case 2:
		{
			usingmenu[id] = 1
			client_cmd(id,"messagemode match_servername")
			return PLUGIN_HANDLED
		}
		case 8:
		{
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public cmd_clantag1(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
	{
		return PLUGIN_HANDLED
	}
	if(get_cvar_num("mp_clan_match") == 1 && get_pcvar_num(dod_clanmatch) == 1)
	{
		client_print(id,print_console,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
		client_print(id,print_chat,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
		return PLUGIN_HANDLED
	}
	new clantag1[32]
	read_argv(1,clantag1,32)
	set_cvar_string("dod_cm_clantag1",clantag1)
	client_print(id,print_chat,"[DoD ClanMatch] ClanTag1 %L: %s",id,"SETTO",clantag1)
	if(usingmenu[id] == 1)
	{
		usingmenu[id] = 0
		clanmatch_changesettings2(id)
	}
	return PLUGIN_HANDLED
}

public clanmatch_changeclantag1(id)
{
	new currclantag1[32]
	get_cvar_string("dod_cm_clantag1",currclantag1,31)
	new show_changeclantag1[1024]
	new key
	format(show_changeclantag1,1023,"\rDoD ClanMatch ClanTag1^n^n\yCurrent setting: \w%s^n^n\yChange ClanTag1 to^n\r1. \w[TeamAlpha]^n\r2. \w{SquadAlpha}^n^n\r3. \wCustomize ClanTag1^n^n\y9. \wSettings Menu",currclantag1)
	key = (1<<0)|(1<<1)|(1<<2)|(1<<8)
	show_menu(id,key,show_changeclantag1,-1)
	return PLUGIN_HANDLED
}

public match_changeclantag1(id,key)
{
	switch(key)
	{
		case 0:
		{
			set_cvar_string("dod_cm_clantag1","[TeamAlpha]")
			client_print(id,print_chat,"[DoD ClanMatch] ClanTag1 %L: [TeamAlpha]",id,"SETTO")
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
		case 1:
		{
			set_cvar_string("dod_cm_clantag1","{SquadAlpha}")
			client_print(id,print_chat,"[DoD ClanMatch] ClanTag1 %L: {SquadAlpha}",id,"SETTO")
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
		case 2:
		{
			usingmenu[id] = 1
			client_cmd(id,"messagemode match_clantag1")
			return PLUGIN_HANDLED
		}
		case 8:
		{
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public cmd_clantag2(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
	{
		return PLUGIN_HANDLED
	}
	if(get_cvar_num("mp_clan_match") == 1 && get_pcvar_num(dod_clanmatch) == 1)
	{
		client_print(id,print_console,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
		client_print(id,print_chat,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
		return PLUGIN_HANDLED
	}
	new clantag2[32]
	read_argv(1,clantag2,32)
	set_cvar_string("dod_cm_clantag2",clantag2)
	client_print(id,print_chat,"[DoD ClanMatch] ClanTag2 %L: %s",id,"SETTO",clantag2)
	if(usingmenu[id] == 1)
	{
		usingmenu[id] = 0
		clanmatch_changesettings2(id)
	}
	return PLUGIN_HANDLED
}

public clanmatch_changeclantag2(id)
{
	new currclantag2[32]
	get_cvar_string("dod_cm_clantag2",currclantag2,31)
	new show_changeclantag2[1024]
	new key
	format(show_changeclantag2,1023,"\rDoD ClanMatch ClanTag2^n^n\yCurrent setting: \w%s^n^n\yChange ClanTag2 to^n\r1. \w[TeamBeta]^n\r2. \w{SquadBeta}^n^n\r3. \wCustomize ClanTag2^n^n\y9. \wSettings Menu",currclantag2)
	key = (1<<0)|(1<<1)|(1<<2)|(1<<8)
	show_menu(id,key,show_changeclantag2,-1)
	return PLUGIN_HANDLED
}

public match_changeclantag2(id,key)
{
	switch(key)
	{
		case 0:
		{
			set_cvar_string("dod_cm_clantag2","[TeamBeta]")
			client_print(id,print_chat,"[DoD ClanMatch] ClanTag2 %L: [TeamBeta]",id,"SETTO")
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
		case 1:
		{
			set_cvar_string("dod_cm_clantag2","{SquadBeta}")
			client_print(id,print_chat,"[DoD ClanMatch] ClanTag2 %L: {SquadBeta}",id,"SETTO")
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
		case 2:
		{
			usingmenu[id] = 1
			client_cmd(id,"messagemode match_clantag2")
			return PLUGIN_HANDLED
		}
		case 8:
		{
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public cmd_readysig(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
	{
		return PLUGIN_HANDLED
	}
	if(get_cvar_num("mp_clan_match") == 1 && get_pcvar_num(dod_clanmatch) == 1)
	{
		client_print(id,print_console,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
		client_print(id,print_chat,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
		return PLUGIN_HANDLED
	}
	new readysig[32]
	read_argv(1,readysig,32)
	set_cvar_string("dod_cm_readysig",readysig)
	client_print(id,print_chat,"[DoD ClanMatch] ReadySignal %L: %s",id,"SETTO",readysig)
	if(usingmenu[id] == 1){
		usingmenu[id] = 0
		clanmatch_changesettings2(id)
	}
	return PLUGIN_HANDLED
}

public clanmatch_changereadysig(id)
{
	new currreadysig[32]
	get_cvar_string("dod_cm_readysig",currreadysig,31)
	new show_changereadysig[1024]
	new key
	format(show_changereadysig,1023,"\rDoD ClanMatch ReadySignal^n^n\yCurrent setting: \w%s^n^n\yChange ReadySignal to^n\r1. \wready^n\r2. \wgo^n^n\r3. \wCustomize ReadySignal^n^n\y9. \wSettings Menu",currreadysig)
	key = (1<<0)|(1<<1)|(1<<2)|(1<<8)
	show_menu(id,key,show_changereadysig,-1)
	return PLUGIN_HANDLED
}

public match_changereadysig(id,key)
{
	switch(key)
	{
		case 0:
		{
			set_cvar_string("dod_cm_readysig","ready")
			client_print(id,print_chat,"[DoD ClanMatch] ReadySignal %L: ready",id,"SETTO")
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
		case 1:
		{
			set_cvar_string("dod_cm_readysig","go")
			client_print(id,print_chat,"[DoD ClanMatch] ReadySignal %L: go",id,"SETTO")
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
		case 2:
		{
			usingmenu[id] = 1
			client_cmd(id,"messagemode match_readysig")
			return PLUGIN_HANDLED
		}
		case 8:
		{
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public cmd_cancelsig(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
	{
		return PLUGIN_HANDLED
	}
	if(get_cvar_num("mp_clan_match") == 1 && get_pcvar_num(dod_clanmatch) == 1)
	{
		client_print(id,print_console,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
		client_print(id,print_chat,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
		return PLUGIN_HANDLED
	}
	new cancelsig[32]
	read_argv(1,cancelsig,32)
	set_cvar_string("dod_cm_cancelsig",cancelsig)
	client_print(id,print_chat,"[DoD ClanMatch] CancelSignal %L: %s",id,"SETTO",cancelsig)
	if(usingmenu[id] == 1)
	{
		usingmenu[id] = 0
		clanmatch_changesettings2(id)
	}
	return PLUGIN_HANDLED
}

public clanmatch_changecancelsig(id)
{
	new currcancelsig[32]
	get_cvar_string("dod_cm_cancelsig",currcancelsig,31)
	new show_changecancelsig[1024]
	new key
	format(show_changecancelsig,1023,"\rDoD ClanMatch CancelSignal^n^n\yCurrent setting: \w%s^n^n\yChange CancelSignal to^n\r1. \wcancel^n\r2. \wrevoke^n^n\r3. \wCustomize CancelSignal^n^n\y9. \wSettings Menu",currcancelsig)
	key = (1<<0)|(1<<1)|(1<<2)|(1<<8)
	show_menu(id,key,show_changecancelsig,-1)
	return PLUGIN_HANDLED
}

public match_changecancelsig(id,key)
{
	switch(key)
	{
		case 0:
		{
			set_cvar_string("dod_cm_cancelsig","cancel")
			client_print(id,print_chat,"[DoD ClanMatch] CancelSignal %L: cancel",id,"SETTO")
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
		case 1:
		{
			set_cvar_string("dod_cm_cancelsig","revoke")
			client_print(id,print_chat,"[DoD ClanMatch] CancelSignal %L: revoke",id,"SETTO")
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
		case 2:
		{
			usingmenu[id] = 1
			client_cmd(id,"messagemode match_cancelsig")
			return PLUGIN_HANDLED
		}
		case 8:
		{
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public cmd_matchresulttime(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
	{
		return PLUGIN_HANDLED
	}
	if(get_cvar_num("mp_clan_match") == 1 && get_pcvar_num(dod_clanmatch) == 1)
	{
		client_print(id,print_console,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
		client_print(id,print_chat,"[DoD ClanMatch] %L",id,"CANTCHANGEMATCH")
		return PLUGIN_HANDLED
	}
	new matchresulttime_s[5]
	read_argv(1,matchresulttime_s,5)
	new matchresulttime = str_to_num(matchresulttime_s)
	set_pcvar_num(dod_cm_matchresulttime,matchresulttime)
	client_print(id,print_chat,"[DoD ClanMatch] MatchResultTime %L: %dmin",id,"SETTO",matchresulttime)
	if(usingmenu[id] == 1)
	{
		usingmenu[id] = 0
		clanmatch_changesettings2(id)
	}
	return PLUGIN_HANDLED
}

public clanmatch_changematchresulttime(id)
{
	new currmatchresulttime = get_pcvar_num(dod_cm_matchresulttime)
	new show_changematchresulttime[1024]
	new key
	format(show_changematchresulttime,1023,"\rDoD ClanMatch MatchResultTime^n^n\yCurrent setting: \w%d minutes^n^n\yChange MatchResultTime to^n\r1. \w5 minutes^n\r2. \w6 minutes^n\r3. \w7 minutes^n\r4. \w8 minutes^n\r5. \w9 minutes^n^n\r6. \wCustomize MatchResultTime^n^n\y9. \wSettings Menu",currmatchresulttime)
	key = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<8)
	show_menu(id,key,show_changematchresulttime,-1)
	return PLUGIN_HANDLED
}

public match_changematchresulttime(id,key)
{
	switch(key)
	{
		case 0:
		{
			set_pcvar_num(dod_cm_matchresulttime,5)
			client_print(id,print_chat,"[DoD ClanMatch] MatchResultTime %L: 5min!",id,"SETTO")
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
		case 1:
		{
			set_pcvar_num(dod_cm_matchresulttime,6)
			client_print(id,print_chat,"[DoD ClanMatch] MatchResultTime %L: 6min!",id,"SETTO")
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
		case 2:
		{
			set_pcvar_num(dod_cm_matchresulttime,7)
			client_print(id,print_chat,"[DoD ClanMatch] MatchResultTime %L: 7min!",id,"SETTO")
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
		case 3:
		{
			set_pcvar_num(dod_cm_matchresulttime,8)
			client_print(id,print_chat,"[DoD ClanMatch] MatchResultTime %L: 8min!",id,"SETTO")
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
		case 4:
		{
			set_pcvar_num(dod_cm_matchresulttime,9)
			client_print(id,print_chat,"[DoD ClanMatch] MatchResultTime %L: 9min!",id,"SETTO")
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
		case 5:
		{
			usingmenu[id] = 1
			client_cmd(id,"messagemode match_resulttime")
			return PLUGIN_HANDLED
		}
		case 8:
		{
			clanmatch_changesettings2(id)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public clanmatch_changeshowscore(id)
{
	new currshowscore = get_pcvar_num(dod_cm_showscore)
	new show_changeshowscore[1024]
	new key
	format(show_changeshowscore,1023,"\rDoD ClanMatch ShowScore^n^n\yCurrent setting: \w%d^n^n\yChange ShowScore to^n\r1. \whudmessage on roundstart^n\r2. \wchatmessage on roundstart^n\r3. \whudmessage & total match score on roundstart^n\r4. \wchatmessage & total match score on roundstart^n\r5. \whudmessage & total match score every minute^n\r6. \wchatmessage & total match score every minute^n\r0. \wDisabled^n^n\y9. \wSettings Menu",currshowscore)
	key = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<8)|(1<<9)
	show_menu(id,key,show_changeshowscore,-1)
	return PLUGIN_HANDLED
}

public match_changeshowscore(id,key)
{
	switch(key)
	{
		case 0:
		{
			set_pcvar_num(dod_cm_showscore,1)
			client_print(id,print_chat,"[DoD ClanMatch] ShowScore %L: hudmessage %L",id,"SETTO",id,"ONROUNDSTART")
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
		case 1:
		{
			set_pcvar_num(dod_cm_showscore,2)
			client_print(id,print_chat,"[DoD ClanMatch] ShowScore %L: chatmessage %L",id,"SETTO",id,"ONROUNDSTART")
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
		case 2:
		{
			set_pcvar_num(dod_cm_showscore,3)
			client_print(id,print_chat,"[DoD ClanMatch] ShowScore %L: hudmessage & total match score %L",id,"SETTO",id,"ONROUNDSTART")
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
		case 3:
		{
			set_pcvar_num(dod_cm_showscore,4)
			client_print(id,print_chat,"[DoD ClanMatch] ShowScore %L: chatmessage & total match score %L",id,"SETTO",id,"EVERYMINUTE")
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
		case 4:
		{
			set_pcvar_num(dod_cm_showscore,5)
			client_print(id,print_chat,"[DoD ClanMatch] ShowScore %L: hudmessage & total match score %L",id,"SETTO",id,"EVERYMINUTE")
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
		case 5:
		{
			set_pcvar_num(dod_cm_showscore,6)
			client_print(id,print_chat,"[DoD ClanMatch] ShowScore %L: chatmessage & total match score %L",id,"SETTO",id,"EVERYMINUTE")
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
		case 8:
		{
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
		case 9:
		{
			set_pcvar_num(dod_cm_showscore,0)
			client_print(id,print_chat,"[DoD ClanMatch] ShowScore %L: %L",id,"SETTO",id,"FEATUREOFF")
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public clanmatch_changeshowtime(id)
{
	new currshowtime = get_pcvar_num(dod_cm_showtime)
	new show_changeshowtime[1024]
	new key
	format(show_changeshowtime,1023,"\rDoD ClanMatch ShowTime^n^n\yCurrent setting: \w%d^n^n\yChange ShowTime to^n\r1. \whudmessage on roundstart^n\r2. \wchatmessage on roundstart^n\r3. \whudmessage every minute^n\r4. \wchatmessage every minute^n\r0. \wDisabled^n^n\y9. \wSettings Menu",currshowtime)
	key = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<8)|(1<<9)
	show_menu(id,key,show_changeshowtime,-1)
	return PLUGIN_HANDLED
}

public match_changeshowtime(id,key)
{
	switch(key)
	{
		case 0:
		{
			set_pcvar_num(dod_cm_showtime,1)
			client_print(id,print_chat,"[DoD ClanMatch] ShowTime %L: hudmessage %L",id,"SETTO",id,"ONROUNDSTART")
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
		case 1:
		{
			set_pcvar_num(dod_cm_showtime,2)
			client_print(id,print_chat,"[DoD ClanMatch] ShowTime %L: chatmessage %L",id,"SETTO",id,"ONROUNDSTART")
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
		case 2:
		{
			set_pcvar_num(dod_cm_showtime,3)
			client_print(id,print_chat,"[DoD ClanMatch] ShowTime %L: hudmessage %L",id,"SETTO",id,"EVERYMINUTE")
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
		case 3:
		{
			set_pcvar_num(dod_cm_showtime,4)
			client_print(id,print_chat,"[DoD ClanMatch] ShowTime %L: chatmessage %L",id,"SETTO",id,"EVERYMINUTE")
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
		case 8:
		{
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
		case 9:
		{
			set_pcvar_num(dod_cm_showtime,0)
			client_print(id,print_chat,"[DoD ClanMatch] ShowTime %L: %L",id,"SETTO",id,"FEATUREOFF")
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public clanmatch_changemapmode(id)
{
	new currmapmode = get_pcvar_num(dod_cm_mapmode)
	new show_changemapmode[1024]
	new key
	format(show_changemapmode,1023,"\rDoD ClanMatch MapMode^n^n\yCurrent setting: \w%d^n^n\yChange MapMode to^n\r1. \wplay each map once^n\r2. \wplay each map twice^n^n\y9. \wSettings Menu",currmapmode)
	key = (1<<0)|(1<<1)|(1<<8)
	show_menu(id,key,show_changemapmode,-1)
	return PLUGIN_HANDLED
}

public match_changemapmode(id,key)
{
	switch(key)
	{
		case 0:
		{
			set_pcvar_num(dod_cm_mapmode,1)
			client_print(id,print_chat,"[DoD ClanMatch] MapMode %L: %L",id,"SETTO",id,"MAPONCE")
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
		case 1:
		{
			set_pcvar_num(dod_cm_mapmode,2)
			client_print(id,print_chat,"[DoD ClanMatch] MapMode %L: %L",id,"SETTO",id,"MAPTWICE")
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
		case 8:
		{
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public clanmatch_changeff(id)
{
	new currff = get_pcvar_num(dod_cm_ff)
	new show_changeff[1024]
	new key
	format(show_changeff,1023,"\rDoD ClanMatch FriendlyFire^n^n\yCurrent setting: \w%d^n^n\yChange FriendlyFire to^n\r1. \wEnabled^n\r0. \wDisabled^n^n\y9. \wSettings Menu",currff)
	key = (1<<0)|(1<<8)|(1<<9)
	show_menu(id,key,show_changeff,-1)
	return PLUGIN_HANDLED
}

public match_changeff(id,key)
{
	switch(key)
	{
		case 0:
		{
			set_pcvar_num(dod_cm_ff,1)
			client_print(id,print_chat,"[DoD ClanMatch] FriendlyFire %L: %L",id,"SETTO",id,"FEATUREON")
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
		case 8:
		{
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
		case 9:
		{
			set_pcvar_num(dod_cm_ff,0)
			client_print(id,print_chat,"[DoD ClanMatch] FriendlyFire %L: %L",id,"SETTO",id,"FEATUREOFF")
			clanmatch_changesettings1(id)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1031\\ f0\\ fs16 \n\\ par }
*/
