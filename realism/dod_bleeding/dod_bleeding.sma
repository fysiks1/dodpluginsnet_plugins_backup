//
// AMX Mod X Script
//
// Developed by The AMX Mod X DoD Community
// http://www.dodplugins.net
//
// Author: Zor & FeuerSturm
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
// Requires AMX Mod X, FakeMeta, Fun, DoDx and DoDFun modules!
//
//
//
// USAGE (cvars for amxx.cfg):
// ===========================
//
// dod_bleeding_enabled <1/0>		= enable/disable DoD Bleeding by default
//					  1 = Bleeding is enbaled
//					  0 = Bleeding is disabled
//
// dod_bleeding_mindamage <#>		= set amount of damage that a player has to
//					  take to start bleeding.
//					  set it to 0 to make players start bleeding
//					  no matter how much damage was caused,
//					  choose a higher value if you don't want people
//					  to start bleeding after only small damage by
//					  for example a detonating grenade some meters away.
//
// dod_bleeding_bleedbyworld <1/0>	= enable/disable bleeding after falling down
//					  and losing health or being hit by a mortar
//					  on dod_caen for example.
//					  1 = start bleeding by "world" damages
//					  0 = only start bleeding by weapon damage
//
// dod_bleeding_dmgcenter <#>		= set how many healthpoints a player that is
//					  bleeding loses per second for body center hits
//
// dod_bleeding_dmgextremities <#>	= set how many healthpoints a player that is
//					  bleeding loses per second for body extremities hits
//
// dod_bleeding_messages <#>		= set how many times bleeding players should
//					  get the "Your are Bleeding" announcement after
//					  they managed to bandage the first time
//
// Please Note:
// No matter to what value (other than 0)
// you set this, the player will always get the
// announcement until he manages to bandage for the
// first time, then it counts as first message!
// So usually setting this to 1 does the trick and
// players won't be announced anymore after they found
// out how to bandage!
//
//
//
// DESCRIPTION:
// ============
//
// This Plugin will add some realism to your servers!
// - Wounded players will start to bleed and lose health
//   until they bandage their wounds!
// - While bandaging they can only use their melee weapon!
// - If you don't bandage you bleed to death!
// - Bleeding is handled like every other standard weapon,
//   if you shoot someone and he bleeds to death, you receive
//   the kill and the deathmessage will show you as the killer!
// - HLStats proof! Bleeding kills are handled like kills with
//   any other standard weapon and will be listed in the stats!
//       
//
//
//
// CHANGELOG:
// ==========
//
// This plugin was originally made by Zor,
// as it was kind of abandoned i will continue
// work on it with Zor's permission!
//
// - 04.08.2007 Version 0.9
//   - imported Zor's version "0.4a"
//   - changed cvar names
//   - changed to pcvar usage
//   - removed motd, client-commands & setinfos
//     from now on the "use"-key is the only way
//     to bandage!
//   - replaced Engine with FakeMeta module
//   - added hudmessage as announcement for
//     bleeding players
//   - added textmessage after respawn for players
//     that were bleeding but did not bandage
//   - added multilanguage support for those
//     announcements
//   - blocked "suicide" logmessage and replaced it
//     with a "X killed Y with bleeding" message
//   - completely HLStats proof now! Bleeding kills are
//     handled like any other standard weapon's kills,
//     now more "suicides" because of bleeding!
//     A nice little icon for your HLStats is included
//     as well!
//   - finally fixed "deployed"-bug, players with a
//     deployed mg/bar/fg42 now undeploy and switch
//     to knife/spade as well when bandaging
//   - fixed bots not switching to melee weapons when
//     bandaging
//
// - 09.08.2007 Version 1.0
//   - fixed blood squeezing "out of the air" instead
//     of the bleeding player.
//   - fixed overhead-icons disappearing
//   - added cvar "dod_bleeding_bleedbyworld" to define if
//     players should start to bleed after falling off and
//     losing health.(set to 1) or if they schould just
//     start bleeding after beeing hit by a weapon (set to 0)
//   - added cvar "dod_bleeding_mindamage" to define the minimum
//     of damage that has to be caused to a player to start bleeding.
//   - moved announcement hudmessage to the left of the screen, so it
//     doesn't influence players view while finishing their firefight
//     before bandaging
//

#include <amxmodx>
#include <fakemeta>
#include <fun>
#include <dodx>
#include <dodfun>

#define TE_BLOODSTREAM 101
#define TE_WORLDDECAL  116
#define TASK_ID_1 2277
#define TASK_ID_2 2377

new gBleedingSprite[33][64]
new gBleeding[33], gBandaging[33], gKiller[33], gDamage[33], gBleedingMsg[33]
new gmsgObject, gmsgFrags
new bool:bleeding_suicide[33]

new g_dod_bleeding_enabled, g_dod_bleeding_messages, g_dod_bleeding_dmgcenter, g_dod_bleeding_dmgextremities
new g_dod_bleeding_bleedbyworld, g_dod_bleeding_mindamage

new Bleeding_Sprite[4][] =
{
	"sprites/blood_icon.spr",
	"sprites/bandage_icon.spr",
	"sprites/blood.spr",
	"sprites/bloodspray.spr"
}

enum
{
	drop,
	bandage,
	blood,
	spray
}

new Bleeding_Sound[4][] =
{
	"player/ow.wav",
	"player/usmedic.wav",
	"player/germedic.wav",
	"player/britmedic.wav"
}

public plugin_init()
{	
	register_plugin("DoD Bleeding", "1.0", "AMXX DoD Team")
	register_cvar("dod_bleeding_plugin", "Version 1.0 by Zor & FeuerSturm | www.dodplugins.net", FCVAR_SERVER|FCVAR_SPONLY)
	register_forward(FM_AlertMessage, "fm_AlertMessage")
	register_message(get_user_msgid("DeathMsg"), "death_message")
	register_event("Object", "hook_object", "b")
	register_event("CurWeapon", "hook_cur_weapon", "be", "1=1", "2!1", "2!2", "2!19")
	register_event("PTeam", "hook_spectator", "a", "2=3")
	register_event("ResetHUD","client_respawn","be")
	g_dod_bleeding_enabled = register_cvar("dod_bleeding_enabled", "1")
	g_dod_bleeding_messages = register_cvar("dod_bleeding_messages", "3")
	g_dod_bleeding_dmgcenter = register_cvar("dod_bleeding_dmgcenter", "8")
	g_dod_bleeding_dmgextremities = register_cvar("dod_bleeding_dmgextremities", "4")
	g_dod_bleeding_bleedbyworld = register_cvar("dod_bleeding_bleedbyworld", "0")
	g_dod_bleeding_mindamage = register_cvar("dod_bleeding_mindamage", "0")
	gmsgObject = get_user_msgid("Object")
	gmsgFrags = get_user_msgid("Frags"), 
	register_dictionary("dod_bleeding.txt")
}

public plugin_precache()
{
	precache_model(Bleeding_Sprite[drop])
	precache_model(Bleeding_Sprite[bandage])
	precache_model(Bleeding_Sprite[blood]) 
	precache_model(Bleeding_Sprite[spray])	
	precache_sound(Bleeding_Sound[0])
	precache_sound(Bleeding_Sound[1])
	precache_sound(Bleeding_Sound[2])
	precache_sound(Bleeding_Sound[3])
	return PLUGIN_CONTINUE
}

public plugin_pause()
{
	set_pcvar_num(g_dod_bleeding_enabled,0)	
	for(new id = 1; id < 33; id++)
	{
		if(task_exists(TASK_ID_1+id))
		{
			remove_task(TASK_ID_1+id)
		}
		if(task_exists(TASK_ID_2+id))
		{
			remove_task(TASK_ID_2+id)
		}
	}
	return PLUGIN_CONTINUE
}

public plugin_unpause()
{
	set_pcvar_num(g_dod_bleeding_enabled,1)
	return PLUGIN_CONTINUE
}

public client_putinserver(id)
{
	bleeding_suicide[id] = false
	gBleeding[id] = 0
	gBandaging[id] = 0
	gKiller[id] = -1
	gDamage[id] = 0
	gBleedingMsg[id] = 0
	return PLUGIN_CONTINUE
}

public client_disconnect(id)
{
	if(task_exists(TASK_ID_1+id))
	{
		remove_task(TASK_ID_1+id)
	}	
	if(task_exists(TASK_ID_2+id))
	{
		remove_task(TASK_ID_2+id)
	}
	return PLUGIN_CONTINUE
}

public fm_AlertMessage(at_type, message[])
{
	if(at_type == 5)
	{
		if(containi(message, ">^" committed suicide with ^"world^"") != -1)
		{
			static dummy[1], userid, index
			parse_loguser(message, dummy, 0, userid)
			index =  find_player("k", userid)
			if(bleeding_suicide[index])
			{
				bleeding_suicide[index] = false
				return FMRES_SUPERCEDE
			}
		}
	}
	return FMRES_IGNORED
} 

public client_damage(attacker, victim, damage, wpnindex, hitplace, TA)
{
	if(get_pcvar_num(g_dod_bleeding_enabled) == 0 || is_user_alive(victim) == 0 || is_user_connected(victim) == 0)
	{
		return PLUGIN_CONTINUE
	}
	if((wpnindex < 1 || wpnindex > DODMAX_WEAPONS) && get_pcvar_num(g_dod_bleeding_bleedbyworld) == 0)
	{
		return PLUGIN_CONTINUE
	}
	if(gBleeding[victim] == 1)
	{
		gKiller[victim] = attacker
		return PLUGIN_CONTINUE
	}
	if(damage < get_pcvar_num(g_dod_bleeding_mindamage))
	{
		return PLUGIN_CONTINUE
	}
	if(is_user_bot(victim) == 0)
	{
		message_begin(MSG_ONE, gmsgObject, {0,0,0}, victim)
		write_string(Bleeding_Sprite[drop])
		message_end()
	}
	emit_sound(victim, CHAN_VOICE, Bleeding_Sound[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	gBleeding[victim] = 1
	gBandaging[victim] = 0
	gKiller[victim] = attacker
	new param[1]
	param[0] = victim
	if(hitplace == HIT_HEAD || hitplace == HIT_CHEST || hitplace == HIT_STOMACH)
	{
		gDamage[victim] = get_pcvar_num(g_dod_bleeding_dmgcenter)
	}	
	else if(hitplace == HIT_GENERIC || hitplace == HIT_LEFTARM || hitplace == HIT_RIGHTARM || hitplace == HIT_LEFTLEG || hitplace == HIT_RIGHTLEG)
	{
		gDamage[victim] = get_pcvar_num(g_dod_bleeding_dmgextremities)
	}
	set_task(1.0, "bloodDamage", TASK_ID_1+victim, param, 1)	
	return PLUGIN_CONTINUE
}

public death_message(id)
{
	if(get_pcvar_num(g_dod_bleeding_enabled) == 0)
	{
		return PLUGIN_CONTINUE
	}	
	new killer = get_msg_arg_int(1)
	new victim = get_msg_arg_int(2)
	new wpnindex = get_msg_arg_int(3)
	if(gBleeding[victim] == 1 || gBandaging[victim] == 1)
	{
		remove_task(TASK_ID_1+victim)
		remove_task(TASK_ID_2+victim)
		if(gKiller[victim] != -1 && killer == victim && wpnindex == 0 && is_user_connected(gKiller[victim]) == 1 && get_user_team(gKiller[victim]) != 3)
		{
			killer = gKiller[victim]
			dod_make_deathmsg(killer, victim, 0)
			if(get_user_team(killer) != get_user_team(victim))
			{
				new newfrags = dod_get_user_kills(killer)
				newfrags++
				dod_set_user_kills(killer,newfrags,0)
				message_begin(MSG_BROADCAST, gmsgFrags, {0,0,0}, 0)
				write_byte(killer)
				write_short(newfrags)
				message_end()
			}
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE
}

public hook_object(id)
{
	read_data(1, gBleedingSprite[id], 63)
	return PLUGIN_CONTINUE
}

public client_respawn(id)
{
	if(get_pcvar_num(g_dod_bleeding_enabled) == 0 || is_user_connected(id) == 0)
	{
		return PLUGIN_CONTINUE
	}
	if (gBleeding[id] == 1 && gBandaging[id] == 0 && gBleedingMsg[id] < get_pcvar_num(g_dod_bleeding_messages))
	{
		client_print(id,print_chat,"[DoD Bleeding] %L",id,"BANDAGE")
		client_print(id,print_chat,"[DoD Bleeding] %L",id,"PRESSUSE")
	}
	gBleeding[id] = 0
	gBandaging[id] = 0
	gKiller[id] = -1
	gDamage[id] = 0
	if(task_exists(TASK_ID_1+id))
	{
		remove_task(TASK_ID_1+id)
	}
	if(task_exists(TASK_ID_2+id))
	{
		remove_task(TASK_ID_2+id)
	}
	return PLUGIN_CONTINUE
}

public hook_cur_weapon(id)
{
	if(is_user_connected(id) == 1 && gBandaging[id] == 1)
	{
		switch_wpn(id)
	}
	return PLUGIN_CONTINUE
}

public hook_spectator(id)
{
	id = read_data(1)	
	if(get_pcvar_num(g_dod_bleeding_enabled) == 0 || is_user_connected(id) == 0)
	{
		return PLUGIN_CONTINUE
	}
	if(task_exists(TASK_ID_1+id))
	{
		remove_task(TASK_ID_1+id)
	}
	if(task_exists(TASK_ID_2+id))
	{
		remove_task(TASK_ID_2+id)
	}
	return PLUGIN_CONTINUE
}

public client_PreThink(id)
{
	if(is_user_connected(id) == 1 && is_user_alive(id) == 1 && gBleeding[id] == 1 && gBandaging[id] == 0)
	{
		new button = pev(id,pev_button)
		new oldbuttons = pev(id,pev_oldbuttons)
		if(button & IN_USE && oldbuttons & IN_USE)
		{
			bandage_command(id)
		}
	}
	return PLUGIN_CONTINUE
}

public bloodDamage(param[])
{	
	new id = param[0]	
	if(is_user_alive(id) == 1 && is_user_connected(id) == 1)
	{
		if(is_user_bot(id) == 1)
		{	
			new Float:randombandage = random_float(Float:1.0,Float:5.0)
			set_task(randombandage,"bandage_command",id)
		}
		else if(is_user_bot(id) == 0)
		{
			if(gBleedingMsg[id] < get_pcvar_num(g_dod_bleeding_messages))
			{
				set_hudmessage (255,0,0,0.1,-1.0,1,1.0,1.0,0.1,0.2,1) 
				show_hudmessage(id,"%L",id,"BLEEDING")
			}
		}
		if(is_user_alive(id) == 1 && is_user_connected(id) == 1 && gBandaging[id] == 0)
		{
			new iOrigin[3]
			get_user_origin(id,iOrigin)
			fx_bleed(iOrigin) 
			fx_blood_small(iOrigin, 5)
			emit_sound(id, CHAN_VOICE, Bleeding_Sound[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			new playerhealth = get_user_health(id)
			if((playerhealth - gDamage[id]) <= 0)
			{
				if(is_user_connected(gKiller[id]) == 1 && get_user_team(gKiller[id]) != 3)
				{
					new victim = id
					new killer = gKiller[victim]
					new killersteam[33], victimsteam[33]
					new killerteam[32], victimteam[32]
					if(get_user_team(killer) == ALLIES)
						format(killerteam,31,"Allies")
					if(get_user_team(killer) == AXIS)
						format(killerteam,31,"Axis")
					if(get_user_team(victim) == ALLIES)
						format(victimteam,31,"Allies")
					if(get_user_team(victim) == AXIS)
						format(victimteam,31,"Axis")
					new victimname[32], killername[32]
					get_user_name(victim,victimname,31)
					get_user_name(killer,killername,31)
					new killeruserid = get_user_userid(killer)
					new victimuserid = get_user_userid(victim)
					get_user_authid(killer,killersteam,32)
					get_user_authid(victim,victimsteam,32)
					log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"bleeding^"",killername,killeruserid,killersteam,killerteam,victimname,victimuserid,victimsteam,victimteam)
				}
				bleeding_suicide[id] = true
				set_user_health(id,(playerhealth - gDamage[id]))
				return PLUGIN_HANDLED
			}
			set_user_health(id,(playerhealth - gDamage[id]))
			set_task(1.0, "bloodDamage", TASK_ID_1+id, param, 1)
		}
	}
	return PLUGIN_HANDLED
}

public bandage_command(id)
{
	if(get_pcvar_num(g_dod_bleeding_enabled) == 0)
	{
		return PLUGIN_HANDLED
	}	
	if(gBleeding[id] == 0 || gBandaging[id] == 1 || is_user_alive(id) == 0)
	{
		return PLUGIN_HANDLED
	}
	gBandaging[id] = 1
	if(dod_is_deployed(id) == 1 && is_user_bot(id) == 0)
	{
		client_cmd(id,"+attack2;wait;wait;wait;-attack2;wait;wait;wait;weapon_spade;weapon_amerknife;weapon_gerknife")
	}
	switch_wpn(id)
	if(is_user_bot(id) == 0)
	{
		message_begin(MSG_ONE, gmsgObject, {0,0,0}, id)
		write_string(Bleeding_Sprite[bandage])
		message_end()
	}
	if(task_exists(TASK_ID_1+id))
	{
		remove_task(TASK_ID_1+id)
	}
	new param[1]
	param[0] = id
	set_task(3.0, "stopBleeding", TASK_ID_2+id, param, 1)
	new team_id = get_user_team(id)
	if(team_id == 1 && dod_get_map_info(MI_ALLIES_TEAM) == 1)
	{
		team_id = 3
	}
	emit_sound(id, CHAN_VOICE, Bleeding_Sound[team_id], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	if(gBleedingMsg[id] < get_pcvar_num(g_dod_bleeding_messages))
	{
		gBleedingMsg[id]++
	}
	return PLUGIN_HANDLED
}

public stopBleeding(param[])
{
	new id = param[0]
	if(is_user_bot(id) == 0)
	{
		message_begin(MSG_ONE, gmsgObject, {0,0,0}, id)
		write_string(gBleedingSprite[id])
		message_end()
	}
	gBleeding[id] = 0
	gBandaging[id] = 0
	gKiller[id] = -1
	engclient_cmd(id, "lastinv")
	return PLUGIN_HANDLED
}

stock switch_wpn(id)
{
	client_cmd(id, "weapon_spade")
	client_cmd(id, "weapon_amerknife")
	client_cmd(id, "weapon_gerknife")
}

stock fx_bleed(origin[3])
{
	message_begin(MSG_ALL, SVC_TEMPENTITY) 
	write_byte(TE_BLOODSTREAM) 
	write_coord(origin[0]) 
	write_coord(origin[1]) 
	write_coord(origin[2]+10) 
	write_coord(random_num(-100,100))
	write_coord(random_num(-100,100))
	write_coord(random_num(-10,10))
	write_byte(70)
	write_byte(random_num(50,100))
	message_end() 
}

stock fx_blood_small(origin[3], num)
{ 
	static const blood_small[7] = {204,205,206,207,208,209,210}
	for(new j = 0; j < num; j++)
	{ 
		message_begin(MSG_ALL, SVC_TEMPENTITY) 
		write_byte(TE_WORLDDECAL) 
		write_coord(origin[0]+random_num(-100,100)) 
		write_coord(origin[1]+random_num(-100,100)) 
		write_coord(origin[2]-36) 
		write_byte(blood_small[random_num(0,6)])
		message_end() 
	} 
}
