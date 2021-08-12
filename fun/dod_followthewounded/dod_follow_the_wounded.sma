
//////////////////////////////////////////////////////////////////////////////////
//
//	DoD Follow The Wounded
//		- Version 1.0
//		- 05.20.2008
//		- dod port: diamond-optic
//		- original: KRoT@L
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
//   - When the health of a player goes below ftw_health,
//     the footsteps of this player will be covered with blood,
//     thus you can follow him.
//
// CVARs:
//
//   ftw_active //Turn on(1)/off(0)
//   ftw_health //Health needs to be below this for effect
//
// Credits:
//
//   - Original plugin by KRoT@L
//   - http://www.amxmodx.org/forums/viewtopic.php?t=17688
//   - Ported to DoD by diamond-optic
//
// Known Problems:
//
//   - Sometime the footprints show up at wierd angles on the ground.
//
// Changelog:
//
//   - 02.23.2006 Version 0.1
//  	  Initial DoD port release
//
//   - 07.09.2006 Version 0.2
//  	  Replaced ENGINE module with FAKEMETA
//	  Removed AMXMISC module
//
//   - 05.20.2008 Version 1.0
//  	  Changed Public CVAR format
//	  Replaced respawn hook with PStatus method
//	  Removed dodx death & damage registers
//	  Moved task id to a define
//	  Added PCVARs
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <fakemeta>
#include <dodx>

#define VERSION	 "1.0"
#define SVERSION "v1.0 - by diamond-optic (www.AvaMods.com)"

#define TASK_ID	 424754

new decals[2] = {120,121}

new bool:g_isDying[33]
new g_decalSwitch[33]

new p_active,p_health

public plugin_init()
{
	register_plugin("DoD Follow the Wounded",VERSION,"AMXX DoD Team & KRoTaL")
	register_cvar("dod_follow_the_wounded_stats",SVERSION,FCVAR_SERVER|FCVAR_SPONLY)

	p_active = register_cvar("ftw_active","1")
	p_health = register_cvar("ftw_health","5")

	//Temp fix for spawning
	register_message(get_user_msgid("PStatus"),"msg_PStatus")
}

////////////////////////////////////////////////////
// Temp fix for spawn hook
//
public msg_PStatus(msgid,msgdest,id)
{
	if(msgdest == 2 && !id)
		{
		new player = get_msg_arg_int(1)
		new status = get_msg_arg_int(2)
		
		if(is_user_connected(player) && status == 0)
			set_task(Float:0.1,"player_spawn",player)
		}
}

public client_connect(id)
{
	if(g_isDying[id])
		{
		g_isDying[id] = false
		
		if(task_exists(TASK_ID+id))
			remove_task(TASK_ID+id)
		}
}

public player_spawn(id)
{
	if(g_isDying[id])
		{
		g_isDying[id] = false
		
		if(task_exists(TASK_ID+id))
			remove_task(4247545+id)
		}
}

public make_footsteps(param[])
{
	new id = param[0]
	
	if(!is_user_alive(id) || !get_pcvar_num(p_active) || get_user_speed(id) < 120)
		return

	new origin[3]
	get_user_origin(id,origin)
	
	if(pev(id,pev_bInDuck) == 1)
		origin[2] -= 18
	else
		origin[2] -= 36
		
	new Float:velocity[3],ent_angles[3],ent_origin[3]
	
	new ent = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))

	pev(id,pev_v_angle,ent_angles)
	pev(id,pev_origin,ent_origin)

	if(ent > 0)
		{
		ent_angles[0] = 0.0   //tried changing to 180
		
		if(g_decalSwitch[id] == 0)
			ent_angles[1] -= 90
		else 
			ent_angles[1] += 90
		
		set_pev(ent,pev_origin,ent_origin)
		set_pev(ent,pev_v_angle,ent_angles)
		velocity_by_aim(ent,12,velocity)

		engfunc(EngFunc_RemoveEntity,ent)
		}
		
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY,origin)
	write_byte(116)
	write_coord(origin[0] + floatround(velocity[0]))
	write_coord(origin[1] + floatround(velocity[1]))
	write_coord(origin[2])
	write_byte(decals[g_decalSwitch[id]])
	message_end()
	
	g_decalSwitch[id] = 1 - g_decalSwitch[id]
	
	return
}

public client_damage(attacker,victim,damage,wpnindex,hitplace,TA)
{
	if(!get_pcvar_num(p_active) || !is_user_alive(victim))
		return PLUGIN_CONTINUE

	if(!g_isDying[victim] && get_user_health(victim) <= get_pcvar_num(p_health))
		{
		g_isDying[victim] = true
		g_decalSwitch[victim] = 0
		
		new param[1]
		param[0] = victim
		
		set_task(0.2,"make_footsteps",TASK_ID+victim,param,1,"b")
		}
		
	return PLUGIN_CONTINUE
}

public client_death(killer,victim,wpnindex,hitplace,TK)
{
	if(g_isDying[victim])
		{
		g_isDying[victim] = false
		
		if(task_exists(TASK_ID+victim))
			remove_task(TASK_ID+victim)
		}
}

stock get_user_speed(id)	//stock from fakemeta_util by VEN
{		
	new Float:Vel[3]
	pev(id,pev_velocity,Vel)

	return floatround(vector_length(Vel))
}
