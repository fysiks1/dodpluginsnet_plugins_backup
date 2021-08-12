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
//	Name:		DoD Admin Spectate ESP
//	Author:		|BW|.Zor
//	Description:	This plugin will allow the admin to spectate players and help
//				them to catch cheaters
//
//	Credits:
//			Steve Dudenhoeffer for the Spectator Hiding Code
//			KoST for the new way to run the lines and boxes
//			Depot for porting the code to amxmodx
//
//	Reference:	
//
//	CVARS:	( Place these Variables into the addons/amxmodx/configs/amxx.cfg File )
//
//			esp_active	1
//			esp_repeat	0.3
//
//	v0.1 	- Be!
//	v0.2	- Updated some things that I got from Krytol
//	v0.3	- Fixed the Aiming View
//		- Fixed who your looking at
//		- Fixed View Cone
//	v0.4	- Fixed statusvalue error found by diamond-optic
//	v0.5	- Added a preliminary blocking feature so that it looks like you are not dead
//	v0.6	- Added hiding of the player and the team
//
///////////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <dodx>

///////////////////////////////////////////////////////////////////////////////////////
// Version Control
//
new AUTH[] = "AMXX DoD Community"
new PLUGIN_NAME[] = "DoD Admin Spectator ESP"
new VERSION[] = "0.6"
//
///////////////////////////////////////////////////////////////////////////////////////

#define WPN_COUNT 38
#define TASK_ID 263548
#define BLOCK_TASK 9267

#define PLAYMODE_OBSERVER	5	// Player is observing
#define EF_NODRAW		128	// Dont draw the player
#define SOLID_NOT		0	// No interaction with other objects
#define MOVETYPE_NONE		0	// Never moves
#define OBS_IN_EYE		4	// Set it to look through the eyes

new bool:g_is_spectating[33]
new bool:g_can_spectate[33]
new bool:ducking[33]
new g_esp_box[33] = {0, ...}
new g_esp_line[33] = {0, ...}
new g_esp_aim[33] = {0, ...}
new g_esp_info[33] = {0, ...}
new g_esp_friendly[33] = {0, ...}
new g_who_viewing[33] = {0, ...}
new laser

// New Stuff
new g_players[32] = { 0, ... }
new players_count = 0
new user_team = 0
new viewing_pos = 0

// Spec Hide Stuff
new g_player_class[33]
new g_player_solid[33]
new g_player_movetype[33]
new g_player_effects[33]
new g_player_deadflags[33]
new g_player_team[33]

new Float:g_player_takedmg[33]
new Float:g_player_origin[33][3]
new Float:g_player_health[33]
new Float:g_player_armor[33]

new weapons[WPN_COUNT][32] = 
{ 
	"-", 
	"K-Bar", 
	"Grav-Knife",
	"Colt", 
	"Luger", 
	"Garand",
	"Scoped K-98", 
	"Thompson", 
	"STG-44", 
	"Springfield", 
	"K-98", 
	"BAR", 
	"MP-40", 
	"Pinapple", 
	"Masher",
	"-", 
	"-", 
	"MG-42", 
	"30-Cal", 
	"Shovel", 
	"M1-Carbine", 
	"MG34", 
	"Greasegun", 
	"FG-42", 
	"K-43", 
	"Enfield", 
	"Sten", 
	"Bren", 
	"Webley", 
	"Bazooka", 
	"Panzerschreck", 
	"PIAT", 
	"Scoped FG-42", 
	"M1-Carbine", 
	"-", 
	"Scoped Enfield", 
	"Mills Bomb", 
	"Sykes Fairbairn"
}

public plugin_precache()
{
	laser = precache_model("sprites/zbeam4.spr") 
}

public plugin_init()
{
	// Register this plugin
	register_plugin(PLUGIN_NAME, VERSION, AUTH)
	
	// Register the Client Commands	
	register_concmd("esp_start", "esp_start", ADMIN_LEVEL_H, "Starts the ESP For this User")
	register_concmd("esp_stop", "esp_stop", ADMIN_LEVEL_H, "Stops the ESP For this User")
	register_concmd("esp_nextplayer", "esp_nextplayer", ADMIN_LEVEL_H, "Goes to the next teamate")
	register_concmd("esp_lastplayer", "esp_lastplayer", ADMIN_LEVEL_H, "Goes to the last teamate")
	
	// For the Death Message
	register_statsfwd(XMF_DEATH)
	
	// Register the menu
	register_clcmd("esp_menu", "show_use_menu", ADMIN_LEVEL_H, "Shows admins ESP for Detecting Hackers")
	register_menucmd(register_menuid("\yESP Menu:"), 1023, "esp_menu_cmd")
	
	// Register the CVARS
	register_cvar("esp_active", "1")
	register_cvar("esp_repeat", "0.3")
}

public client_changeteam(id, team, oldteam)
{
	if(team == ALLIES || team == AXIS)
		g_can_spectate[id] = true
	else
		g_can_spectate[id] = false
		
	if(g_is_spectating[id] && g_can_spectate[id])
		set_pev(id, pev_team, team)
		
	else if(g_is_spectating[id] && !g_can_spectate[id])
		client_cmd(id, "esp_stop")
}

public client_spawn(id)
{
	g_can_spectate[id] = true
}

public client_death(killer, victim, wpnindex, hitplace, TK)
{
	new list[32], total
	get_players(list, total)
	
	for(new x = 0; x < total; x++)
	{
		if(g_who_viewing[list[x]] == victim)
			client_cmd(list[x], "esp_nextplayer")
	}
}

public client_PreThink(id)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE
	
	new button = get_user_button(id)

	if(button == 0)
		return PLUGIN_CONTINUE
	
	if(button & IN_DUCK)
		ducking[id] = true

	else
		ducking[id] = false
	
	return PLUGIN_CONTINUE
}

public esp_start(id)
{
	if(!get_cvar_num("esp_active") || !g_can_spectate[id] || !(get_user_flags(id)&ADMIN_LEVEL_H))
		return PLUGIN_HANDLED
		
	g_is_spectating[id] = true
	user_team = get_user_team(id)
	
	// Get a list of teamates
	get_teamates(id)
		
	g_who_viewing[id] = g_players[0]
	viewing_pos = 0

	// Store the players data for later
	pev(id, pev_origin, g_player_origin[id])
	pev(id, pev_takedamage, g_player_takedmg[id])
	g_player_effects[id] = pev(id, pev_effects)
	g_player_solid[id] = pev(id, pev_solid)
	g_player_movetype[id] = pev(id, pev_movetype)
	g_player_class[id] = pev(id, pev_playerclass)
	pev(id, pev_health, g_player_health[id])
	pev(id, pev_armorvalue, g_player_armor[id])
	g_player_deadflags[id] = pev(id, pev_deadflag)
	g_player_team[id] = pev(id, pev_team)
	
	// Now start the spectating
	set_pev(id, pev_effects, pev(id, pev_effects) | EF_NODRAW)
	set_pev(id, pev_playerclass, PLAYMODE_OBSERVER)
	set_pev(id, pev_takedamage, 0.0)
	set_pev(id, pev_iuser1, OBS_IN_EYE)
	set_pev(id, pev_iuser2, g_who_viewing[id])
	set_pev(id, pev_movetype, MOVETYPE_NONE)
	set_pev(id, pev_solid, SOLID_NOT)
	set_pev(id, pev_deadflag, 0)
	
	new param[1]
	param[0] = id
	set_task(get_cvar_float("esp_repeat"), "draw_esp", (TASK_ID + id), param, 1, "b")
	
	client_print(id, print_center, "ESP Started")
	
	return PLUGIN_CONTINUE
}

public esp_stop(id)
{
	if(!get_cvar_num("esp_active") || !g_is_spectating[id] || !(get_user_flags(id)&ADMIN_LEVEL_H))
		return PLUGIN_HANDLED
	
	remove_task(TASK_ID + id)
	g_is_spectating[id] = false
	players_count = 0
	viewing_pos = 0
	
	entity_set_origin(id, g_player_origin[id])
	set_pev(id, pev_takedamage, g_player_takedmg[id])
	set_pev(id, pev_effects, g_player_effects[id])
	set_pev(id, pev_iuser1, 0)
	set_pev(id, pev_iuser2, 0)
	set_pev(id, pev_movetype, g_player_movetype[id])
	set_pev(id, pev_solid, g_player_solid[id])
	set_pev(id, pev_playerclass, g_player_class[id])
	set_pev(id, pev_deadflag, g_player_deadflags[id])
	set_pev(id, pev_health, g_player_health[id])
	set_pev(id, pev_armorvalue, g_player_armor[id])
	set_pev(id, pev_team, g_player_team[id])
		
	client_print(id, print_center, "ESP Stopped")
	
	return PLUGIN_CONTINUE
}

public esp_nextplayer(id)
{
	if(!get_cvar_num("esp_active") || !g_is_spectating[id] || !(get_user_flags(id)&ADMIN_LEVEL_H))
		return PLUGIN_HANDLED
	
	get_teamates(id)
	viewing_pos++
	if(viewing_pos > players_count)
		viewing_pos = 0
		
	g_who_viewing[id] = g_players[viewing_pos]
	
	if(is_user_alive(g_who_viewing[id]))
		set_pev(id, pev_iuser2, g_who_viewing[id])
		
	return PLUGIN_CONTINUE
}

public esp_lastplayer(id)
{
	if(!get_cvar_num("esp_active") || !g_is_spectating[id] || !(get_user_flags(id)&ADMIN_LEVEL_H))
		return PLUGIN_HANDLED
		
	get_teamates(id)
	viewing_pos--
	if(viewing_pos < 0)
		viewing_pos = players_count
			
	g_who_viewing[id] = g_players[viewing_pos]
	
	if(is_user_alive(g_who_viewing[id]))
		set_pev(id, pev_iuser2, g_who_viewing[id])
		
	return PLUGIN_CONTINUE
}

public show_use_menu(id) 
{	
	if(!get_cvar_num("esp_active") || !g_can_spectate[id] || !(get_user_flags(id)&ADMIN_LEVEL_H))
		return PLUGIN_HANDLED

	new szMenuBody[1024]
	
	new len = format(szMenuBody, 1023, "\yESP Menu:^n")
	len += format(szMenuBody[len], 1023 - len, "^n\r1. \wStart")
	len += format(szMenuBody[len], 1023 - len, "^n\r2. \wStop")
	len += format(szMenuBody[len], 1023 - len, "^n\r3. \wNext Player")
	len += format(szMenuBody[len], 1023 - len, "^n\r4. \wPrevious Player")
	len += format(szMenuBody[len], 1023 - len, "^n\r5. \wDraw Box %s", ((g_esp_box[id]) ? "ON" : "OFF"))
	len += format(szMenuBody[len], 1023 - len, "^n\r6. \wDraw Line %s", ((g_esp_line[id]) ? "ON" : "OFF"))
	len += format(szMenuBody[len], 1023 - len, "^n\r7. \wAim Info %s", ((g_esp_aim[id]) ? "ON" : "OFF"))
	len += format(szMenuBody[len], 1023 - len, "^n\r8. \wDraw Info %s", ((g_esp_info[id]) ? "ON" : "OFF"))
	len += format(szMenuBody[len], 1023 - len, "^n\r9. \wDraw Friendlies %s", ((g_esp_friendly[id]) ? "ON" : "OFF"))
	len += format(szMenuBody[len], 1023 - len, "^n\r0. Exit")
	
	show_menu(id, 1023, szMenuBody, -1)
	
	return PLUGIN_HANDLED
}

public esp_menu_cmd(id, key)
{	
	switch(key)
	{
		case 0: client_cmd(id, "esp_start")
		case 1: client_cmd(id, "esp_stop")
		case 2: client_cmd(id, "esp_nextplayer")
		case 3: client_cmd(id, "esp_lastplayer")
		case 4: g_esp_box[id] = 1 - g_esp_box[id]
		case 5: g_esp_line[id] = 1 - g_esp_line[id]
		case 6: g_esp_aim[id] = 1 - g_esp_aim[id]
		case 7: g_esp_info[id] = 1 - g_esp_info[id]
		case 8: g_esp_friendly[id] = 1 - g_esp_friendly[id]
		case 9:
		{
			client_cmd(id, "esp_stop")
			return PLUGIN_HANDLED
		}
	}
	
	client_cmd(id, "esp_menu")
	
	return PLUGIN_HANDLED
}

public client_putinserver(id)
{
	g_is_spectating[id] = false
	g_esp_box[id] = 1
	g_esp_line[id] = 1
	g_esp_aim[id] = 1
	g_esp_info[id] = 1
	g_esp_friendly[id] = 1
	g_who_viewing[id] = 0
}

public client_disconnect(id)
{
	g_is_spectating[id] = false
	g_esp_box[id] = 1
	g_esp_line[id] = 1
	g_esp_aim[id] = 1
	g_esp_info[id] = 1
	g_esp_friendly[id] = 1
	g_who_viewing[id] = 0
}

public draw_esp(param[])
{
	new id = param[0]
	
	if(!get_cvar_num("esp_active") || !(get_user_flags(id)&ADMIN_LEVEL_H) || !g_is_spectating[id])
		return PLUGIN_CONTINUE

	if(!is_user_connected(g_who_viewing[id]))
		return PLUGIN_CONTINUE

	// get origin of who your spectating
	new Float:viewed_origin[3]
	
	new players[32], count
	get_players(players, count, "a")
	
	// loop through the targets
	for(new x = 0; x < count; x++)
	{
		if(!is_user_connected(g_who_viewing[id]))
			return PLUGIN_CONTINUE
			
		// get team of target
		new target_team = get_user_team(players[x])
			
		if(!g_esp_friendly[id] && target_team == user_team && players[x] != id)
			continue
			
		// Get the origin of whom your spectating (Updated every time as ppl move)
		entity_get_vector(g_who_viewing[id], EV_VEC_origin, viewed_origin)
		
		// do not target the one I am spectating
		if(players[x] != g_who_viewing[id])
		{
			// get origin of target
			new Float:target_origin[3]
			entity_get_vector(players[x], EV_VEC_origin, target_origin)

			// get distance from spectated to target
			new Float:distance = vector_distance(viewed_origin, target_origin)

			// if esp_line is 1
			if(g_esp_line[id] == 1)
			{ 
				// calculate width according to distance
				new width
				if(distance < 2040.0)
					width = (255 - floatround(distance / 8.0)) / 3
				else
					width = 1

				// create temp_ent
				make_TE_BEAMENTPOINT(id, target_origin, width, target_team)
			}
			
			// get vector from spectated to target
			new Float:v_middle[3]
			subVec(target_origin, viewed_origin, v_middle)

			//draw box if esp_box = 1 and if there is no line of sight between me and target
			if(g_esp_box[id] == 1)
			{
				// trace from spectated to target, getting hitpoint
				new Float:v_hitpoint[3]
				trace_line(-1, viewed_origin, target_origin, v_hitpoint)

				// get distance from me to hitpoint (nearest wall)
				new Float:distance_to_hitpoint = vector_distance(viewed_origin, v_hitpoint)

				// scale
				new Float:scaled_bone_len
				new Float:scaled_bone_width

				if(ducking[players[x]])
				{
					scaled_bone_len = distance_to_hitpoint / distance * (50.0 - 18.0)
					scaled_bone_width = distance_to_hitpoint / distance * (150.0 + 5.0)
				}

				else
				{
					scaled_bone_len = distance_to_hitpoint / distance * 50.0
					scaled_bone_width = distance_to_hitpoint / distance * 150.0
				}

				// get the point 10.0 units away from wall
				new Float:v_bone_start[3], Float:v_bone_end[3]
				new Float:offset_vector[3]
				normalize(v_middle, offset_vector, distance_to_hitpoint - 10.0) // offset from wall

				// set to eye level
				new Float:eye_level[3]
				copyVec(viewed_origin, eye_level)

				if(ducking[players[x]])
					eye_level[2] += 12.3
				else
					eye_level[2] += 17.5

				addVec(offset_vector, eye_level)

				// start and end of green box
				copyVec(offset_vector, v_bone_start)
				copyVec(offset_vector, v_bone_end)
				v_bone_end[2] -= scaled_bone_len

				new Float:distance_target_hitpoint = distance - distance_to_hitpoint
			
				new actual_bright = 255
				
				// this is to make green box darker if distance is larger
				if(distance_target_hitpoint < 2040.0)
					actual_bright = (255 - floatround(distance_target_hitpoint / 12.0))

				else
					actual_bright = 85

				make_TE_BEAMPOINTS(id, v_bone_start, v_bone_end, floatround(scaled_bone_width), actual_bright)
			}

			//show names if g_esp_info=1
			if(g_esp_info[id] == 1)
			{
				if(is_in_viewcone(g_who_viewing[id], target_origin))
				{
					new Float:xp = 2.0, Float:yp = 2.0 // x,y of hudmessage
					get_screen_pos(id, v_middle, xp, yp)
					draw_info(id, players[x], distance, xp, yp)
				}
			}
		}
	} // For Loop

	if(g_esp_aim[id] == 1)
	{
		new tmp[3]
		new Float:start[3], Float:end[3]
		
		// Get the Start
		get_user_origin(g_who_viewing[id], tmp, 1)
		IVecFVec(tmp, start)
		
		// Get the End Point
		get_user_origin(g_who_viewing[id], tmp, 3)
		IVecFVec(tmp, end)
		
		make_TE_AIMPOINTS(id, start, end)
	}

	return PLUGIN_CONTINUE	
}

stock Float:get_screen_pos(target_id, Float:v_me_to_target[3], &Float:xp, &Float:yp)
{
	new Float:v_aim[3]
	VelocityByAim(target_id, 1, v_aim) // get aim vector
	
	new Float:aim[3]
	copyVec(v_aim, aim) // make backup copy of v_aim
	v_aim[2] = 0.0 // project aim vector vertically to x,y plane
	
	new Float:v_target[3]
	copyVec(v_me_to_target, v_target)
	v_target[2] = 0.0 // project target vector vertically to x,y plane
	
	// both v_aim and v_target are in the x,y plane, so angle can be calculated..
	new Float:x_angle
	xp = get_screen_pos_x(v_target,v_aim, x_angle) // get the x coordinate of hudmessage..
	yp = get_screen_pos_y(v_me_to_target, aim) // get the y coordinate of hudmessage..
	
	return x_angle
}

stock Float:get_screen_pos_x(Float:target[3], Float:aim[3], &Float:xangle)
{
	// get angle between vectors
	new Float:x_angle = floatacos(vectorProduct(aim, target) / (getVecLen(aim) * getVecLen(target)), 1) 
	new Float:x_pos
	
	if(scalar_triple_product(aim,target)<0.0) 
		x_angle *= -1 // make signed

	// if in fov of 90
	if(x_angle >= -45.0 && x_angle <= 45.0)
	{ 
		x_pos = 1.0 - (floattan(x_angle, degrees) + 1.0) / 2.0 // calulate y_pos of hudmessage
		xangle = x_angle
		
		return x_pos
	}
	
	xangle = 0.0
	
	return -2.0
}

stock Float:get_screen_pos_y(Float:v_target[3],Float:aim[3])
{
	new Float:target[3]
	
	// rotate vector about z-axis directly over the direction vector (to get height angle)
	rotateVectorZ(v_target, aim, target)

	// get angle between aim vector and target vector
	// get angle between vectors
	new Float:y_angle = floatacos(vectorProduct(aim, target) / (getVecLen(aim) * getVecLen(target)), 1)

	new Float:y_pos
	new Float:norm_target[3], Float:norm_aim[3]

	// get normalized target and aim vectors
	normalize(v_target, norm_target, 1.0)
	normalize(aim, norm_aim, 1.0)
	
	//since the 'angle between vectors' formula returns always positive values
	if(norm_target[2] < norm_aim[2])
		y_angle *= -1 //make signed

	// if in fov of 90
	if(y_angle >= -45.0 && y_angle <= 45.0)
	{ 
		y_pos = 1.0 - (floattan(y_angle, degrees) + 1.0) / 2.0 // calulate y_pos of hudmessage
		
		if(y_pos >= 0.0 && y_pos <= 1.0)
			return y_pos
	}
	
	return -2.0
}

stock draw_info(id, target_id, Float:distance, Float:xp, Float:yp)
{
	// if in visible range
	if(xp > 0.0 && xp <= 1.0 && yp > 0.0 && yp <= 1.0)
	{
		// show the player info
		set_hudmessage(255, 255, 0, floatabs(xp - 0.04), floatabs(yp), 0, 0.0, get_cvar_float("esp_repeat"))

		new name[33]
		get_user_name(target_id, name, 32)
		new health = get_user_health(target_id)
		new clip, ammo
		new weapon_id = dod_get_user_weapon(target_id, clip, ammo)

		if(weapon_id < 0 || weapon_id > WPN_COUNT)
			weapon_id = 0

		show_hudmessage(id, "[%s]^nHealth: %d Distance: %d^n%s^nclip: %d ammo: %d", name, health, floatround(distance), weapons[weapon_id], clip, ammo)
	}
}

// Vector Operations -------------------------------------------------------------------------------

stock Float:getVecLen(Float:Vec[3])
{
	new Float:VecNull[3] = {0.0, 0.0, 0.0}
	new Float:len = vector_distance(Vec, VecNull)
	return len
}

stock Float:scalar_triple_product(Float:a[3], Float:b[3])
{
	new Float:up[3] = {0.0, 0.0, 1.0}
	new Float:Ret[3]
	
	Ret[0] = a[1] * b[2] - a[2] * b[1]
	Ret[1] = a[2] * b[0] - a[0] * b[2]
	Ret[2] = a[0] * b[1] - a[1] * b[0]
	
	return vectorProduct(Ret, up)
}

stock normalize(Float:Vec[3],Float:Ret[3],Float:multiplier)
{
	new Float:len = getVecLen(Vec)
	copyVec(Vec, Ret)
	Ret[0] /= len
	Ret[1] /= len
	Ret[2] /= len
	Ret[0] *= multiplier
	Ret[1] *= multiplier
	Ret[2] *= multiplier
}

stock rotateVectorZ(Float:Vec[3], Float:direction[3], Float:Ret[3])
{
	// rotates vector about z-axis
	new Float:tmp[3]
	copyVec(Vec, tmp)
	tmp[2] = 0.0
	
	new Float:dest_len = getVecLen(tmp)
	copyVec(direction, tmp)
	tmp[2] = 0.0
	
	new Float:tmp2[3]
	normalize(tmp, tmp2, dest_len)
	tmp2[2] = Vec[2]
	copyVec(tmp2, Ret)
}

stock Float:vectorProduct(Float:Vec1[3], Float:Vec2[3])
{
	return (Vec1[0] * Vec2[0] + Vec1[1] * Vec2[1] + Vec1[2] * Vec2[2])
}

stock copyVec(Float:Vec[3],Float:Ret[3])
{
	Ret[0] = Vec[0]
	Ret[1] = Vec[1]
	Ret[2] = Vec[2]
}

stock subVec(Float:Vec1[3], Float:Vec2[3], Float:Ret[3])
{
	Ret[0] = Vec1[0]-Vec2[0]
	Ret[1] = Vec1[1]-Vec2[1]
	Ret[2] = Vec1[2]-Vec2[2]
}

stock addVec(Float:Vec1[3],Float:Vec2[3])
{
	Vec1[0] += Vec2[0]
	Vec1[1] += Vec2[1]
	Vec1[2] += Vec2[2]
}

stock addVecRet(Float:Vec1[3],Float:Vec2[3], Float:Ret[3])
{
	Ret[0] = Vec1[0] + Vec2[0]
	Ret[1] = Vec1[1] + Vec2[1]
	Ret[2] = Vec1[2] + Vec2[2]
}

stock make_TE_BEAMPOINTS(id, Float:Vec1[3], Float:Vec2[3], width, brightness)
{
	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, {0,0,0}, id) //message begin
	write_byte(0)
	write_coord(floatround(Vec1[0])) // start position
	write_coord(floatround(Vec1[1]))
	write_coord(floatround(Vec1[2]))
	write_coord(floatround(Vec2[0])) // end position
	write_coord(floatround(Vec2[1]))
	write_coord(floatround(Vec2[2]))
	write_short(laser) // sprite index
	write_byte(3) // starting frame
	write_byte(0) // frame rate in 0.1's
	write_byte(floatround(get_cvar_float("esp_repeat") * 10.0)) // life in 0.1's
	write_byte(width) // line width in 0.1's
	write_byte(0) // noise amplitude in 0.01's
	write_byte(0)
	write_byte(255)
	write_byte(0)
	write_byte(brightness) // brightness)
	write_byte(0) // scroll speed in 0.1's
	message_end()
}

stock make_TE_BEAMENTPOINT(id, Float:target_origin[3], width, target_team)
{
	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, {0,0,0}, id)
	write_byte(1)
	write_short(id)
	write_coord(floatround(target_origin[0]))
	write_coord(floatround(target_origin[1]))
	write_coord(floatround(target_origin[2]))
	write_short(laser)
	write_byte(1)		
	write_byte(1000)
	write_byte(floatround(get_cvar_float("esp_repeat") * 10.0))
	write_byte(width)
	write_byte(0)
	
	// Allies
	if(target_team  ==  1)
	{
		write_byte(50)
		write_byte(0)
		write_byte(255)
	}

	// Axis
	else if(target_team  ==  2)
	{
		write_byte(255)
		write_byte(0)
		write_byte(50)
	}
	
	write_byte(255)
	write_byte(0)
	message_end()
}

stock make_TE_AIMPOINTS(id, Float:Vec1[3], Float:Vec2[3])
{
	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, {0,0,0}, id) //message begin
	write_byte(0)
	write_coord(floatround(Vec1[0])) // start position
	write_coord(floatround(Vec1[1]))
	write_coord(floatround(Vec1[2]))
	write_coord(floatround(Vec2[0])) // end position
	write_coord(floatround(Vec2[1]))
	write_coord(floatround(Vec2[2]))
	write_short(laser) // sprite index
	write_byte(3) // starting frame
	write_byte(0) // frame rate in 0.1's
	write_byte(floatround(get_cvar_float("esp_repeat") * 10.0)) // life in 0.1's
	write_byte(1) // line width in 0.1's
	write_byte(0) // noise amplitude in 0.01's
	write_byte(0)
	write_byte(255)
	write_byte(0)
	write_byte(255) // brightness)
	write_byte(0) // scroll speed in 0.1's
	message_end()
}

stock get_teamates(id)
{
	new list[32], total
	get_players(list, total)

	players_count = 0

	for(new counter = 0; counter < total; counter++)
	{
		if(get_user_team(list[counter]) == user_team && list[counter] != id)
			g_players[players_count++] = list[counter]
	}
	
}