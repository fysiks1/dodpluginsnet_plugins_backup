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
//  USAGE:
//  ======
//
//  cvars:
//  ------
//
//  dod_finishround_enabled <1/0>    =  enable/disable players' being able to
//                                      finish the round before changing map
//
//  dod_finishround_minteam <#>      =  sets minimum number of players per
//                                      team to allow the round to be finished
//
//  dod_finishround_voxspeech <1/0>  =  enable/disable HL's Vox Engine saying
//                                      "Last Round before Level switch!" and
//                                      displaying it as a hudmessage
//
//  dod_finishround_permhud <1/2/0>  =  sets mode for permanently displayed
//                                      hudmessage (red in the top-left corner)
//                                      1 = display "Last round on <mapname>!"
//                                      2 = display "Last round on <mapname>!
//                                                   Next Map is <nextmap>!"
//                                      0 = disabled / no message
//
//
//
//  DESCRIPTION:
//  ============
//
//  - Players can be allowed to finish the current round before the
//    map changes.
//  - different types of announcements possible.
//  - a minimum amount of players per team can be set to allow
//    finishing the current round.
//  - works with AMXX's "MapChooser" or my "Simple MapExtend"
//    without any problems. (won't work with other map choosers/votings
//    like "Deags Mapmanager")
//
//
//
//
// CHANGELOG:
// ==========
//
// - 28.07.2005 Version 0.5beta
//   Initial Release
//
// - 02.07.2007 Version 0.6
//   - using pcvar system now
//   - added "Draw" as trigger for finished round
//   - added global tracking cvar
//
// - 21.07.2007 Version 0.7
//   - added Multilanguagesupport
//   - fixed oversight that bots were counted as
//     players, in some cases the map never changed when
//     only bots were playing
//   - if the nextmap is identical with the currentmap,
//     a different announcement is displayed stating that
//     the map will be reloaded after the round is finished.
//

#include <amxmodx>
#include <dodx>

new g_dod_finishround_enabled, g_dod_finishround_minteam, g_dod_finishround_voxspeech, g_dod_finishround_permhud
new oldtimelimit, lastround = 0

public plugin_init()
{
	register_plugin("DoD FinishRound","0.7","AMXX DoD Team")
	register_cvar("dod_finishround_plugin", "Version 0.7 by FeuerSturm | www.dodplugins.net", FCVAR_SERVER|FCVAR_SPONLY)
	register_event("RoundState","delayed_mapchange","a","1=3","1=4","1=5")
	set_task(60.0,"last_round",655673,"",0,"d")
	g_dod_finishround_enabled = register_cvar("dod_finishround_enabled","1")
	g_dod_finishround_minteam = register_cvar("dod_finishround_minteam","0")
	g_dod_finishround_voxspeech = register_cvar("dod_finishround_voxspeech","1")
	g_dod_finishround_permhud = register_cvar("dod_finishround_permhud","2")
	register_dictionary("dod_finishround.txt")
}

public plugin_cfg()
{
	set_task(5.0,"get_timelimit")
}

public get_timelimit()
{
	oldtimelimit = get_cvar_num("mp_timelimit")
	return PLUGIN_HANDLED
}

public delayed_mapchange()
{
	if(lastround == 0 || get_pcvar_num(g_dod_finishround_enabled) == 0)
	{
		return PLUGIN_CONTINUE
	}
	message_begin(MSG_ALL,SVC_INTERMISSION)
	message_end()
	set_task(6.0,"real_mapchange")
	return PLUGIN_CONTINUE
}

public real_mapchange()
{
	if(task_exists(655673))
	{
		remove_task(655673)
	}
	if(cvar_exists("amx_nextmap") == 1)
	{
		new nextmap[64]
		get_cvar_string("amx_nextmap",nextmap,63)
		server_cmd("changelevel %s",nextmap)
	}
	else
	{
		set_cvar_num("mp_timelimit",oldtimelimit)
	}
	return PLUGIN_HANDLED
}

public last_round()
{
	if(get_pcvar_num(g_dod_finishround_enabled) == 0)
	{
		return PLUGIN_HANDLED
	}
	if(enoughplayers() == 0)
	{
		if(lastround == 1 && get_pcvar_num(g_dod_finishround_permhud) != 0)
		{
			if(task_exists(132456))
			{
				remove_task(132456)
			}
			set_hudmessage(255, 0, 0, 0.02, 0.1, 0, 6.0, 8.0, 0.1, 0.2, 4)
			show_hudmessage(0,"%L",LANG_PLAYER,"NOTENOUGHPL")
			set_task(8.0,"delayed_mapchange")
		}
		return PLUGIN_HANDLED
	}
	if(lastround == 0)
	{
		set_cvar_num("mp_timelimit",(get_cvar_num("mp_timelimit")) + 3)
		if(get_pcvar_num(g_dod_finishround_voxspeech) == 1)
		{
			client_cmd(0,"spk ^"last round before level switch^"")
			set_hudmessage(255, 0, 0, 0.02, 0.1, 2, 5.0, 8.0, 0.1, 0.2, 4)
			show_hudmessage(0,"Last Round before Level switch!")
		}
		if(get_pcvar_num(g_dod_finishround_permhud) != 0)
		{
			set_task(8.0,"show_lastround",132456,"",0,"b")
		}
		lastround = 1
		set_task(0.1,"extend_round")
		return PLUGIN_HANDLED
	}
	else if(lastround == 1)
	{
		set_cvar_num("mp_timelimit",(get_cvar_num("mp_timelimit")) + 1)
		set_task(0.1,"extend_round")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public extend_round()
{
	set_task(195.0,"last_round",655673,"",0,"d")
	return PLUGIN_HANDLED
}

public show_lastround()
{
	new mapname[64]
	get_mapname(mapname,63)
	set_hudmessage(255, 0, 0, 0.02, 0.1, 0, 6.0, 8.0, 0.1, 0.2, 4)
	if(get_pcvar_num(g_dod_finishround_permhud) == 1)
	{
		show_hudmessage(0,"%L",LANG_PLAYER,"LASTROUND",mapname)
		return PLUGIN_HANDLED
	}
	else if(get_pcvar_num(g_dod_finishround_permhud) == 2)
	{
		if(cvar_exists("amx_nextmap") == 1)
		{
			new nextmap[64]
			get_cvar_string("amx_nextmap",nextmap,63)
			if(equal(mapname,nextmap) == 1)
			{
				show_hudmessage(0,"%L",LANG_PLAYER,"MAPRELOAD",mapname)
			}
			else
			{
				show_hudmessage(0,"%L",LANG_PLAYER,"LASTROUNDNM",mapname,nextmap)
			}
			return PLUGIN_HANDLED
		}
		else
		{
			show_hudmessage(0,"%L",LANG_PLAYER,"LASTROUND",mapname)
			return PLUGIN_HANDLED
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

enoughplayers()
{
	new plist[32],pnum, alliedplayers, axisplayers, enough
	get_players(plist,pnum,"ch")
	for(new i=0; i<pnum; i++)
	{
		new id = plist[i]
		if(is_user_connected(id) == 1 && get_user_team(id) == ALLIES)
		{
			alliedplayers++
		}
		else if(is_user_connected(id) == 1 && get_user_team(id) == AXIS)
		{
			axisplayers++
		}
	}
	new teamstrenght = get_pcvar_num(g_dod_finishround_minteam)
	if(axisplayers >= teamstrenght && alliedplayers >= teamstrenght)
	{
		enough = 1
	}
	else
	{
		enough = 0
	}
	return enough
}
