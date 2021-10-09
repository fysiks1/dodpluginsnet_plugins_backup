////////////////////////////////////////////
//   Day of Defeat Mortar Class
//   Created by: 29th ID
//
//   Part of the 29th ID's modification to
//   Day of Defeat, making it more realistic
//   DOD:Realism - dodrealism.branzone.com
//
//   Credits:
//   Code for the mortar shell itself was 
//   based off of Ludwig Van's "Missile"
//   plugin. He also helped answer a few of
//   my general coding questions so credits 
//   to him.
//
//   The 29th ID Engineer Corps were the 
//   plugin's main testers and helped 
//   immensely.
//
//   Versions:
//
//   1.0 - Initial Release - 24 JUL 2006
//   1.1 - Basic Bug Fixes - 30 AUG 2006
//   1.11- Overlooked Bugs Fixes - 03 SEP 2006
//
//
//   Known Bugs: (Not sure how to fix)
//   -Player model displays inside of player
//    instead of in "holding" position
//   -World model is a bazooka/pschreck
//   -Switching to pistol plays "reload"
//    animation/sound for a second (client-only)
//
////////////////////////////////////////////
//   Description
//
//   This allows a player to use the mortar 
//   class in Day of Defeat, the class that 
//   the developer team never completed but
//   still made the class name and the view
//   model.
//
//   You can change your class to the mortar/
//   morserschutze and prone & deploy it.
//   You can then adjust the power of the 
//   mortar and fire it over buildings to land
//   on targets designated by firemarkers.
//
////////////////////////////////////////////
//   Usage (cvars for amxx.cfg):
//
//   dod_mortars <1/0>
//   	Enables or disables the plugin. (Default 1)
//   dod_mortar_damradius <amount>
//   	Radius mortar can cause damage from where
//   	it lands. (Default 550)
//   dod_mortar_maxdamage <amount>
//	Maximum hp damage caused by a player being
//	hit with a mortar shell. (Default 180)
//   dod_mortar_defaultpower <amount>
//	Default setting for the power of the mortar,
//	which has to do with the speed/distance the
//   	shell travels. (Default 700)
//   dod_mortar_ammo <amount>
//	Amount of mortar shells the client spawns 
// 	with. (Default 30)
//   dod_proned_decrease <amount>
//	Amount to decrease the damage if the mortar
//  	hits a client who is proned (Default 35)
//   dod_crouched_decrease <amount>
//	Amount to decrease the damage if the mortar
//	hits a client who is crouched (Default 10)
//   mp_limitalliesmortar <amount>
//   mp_limitaxismortar <amount>
//   mp_limitbritmortar <amount>
//	Works the same way as other class limits, to
//	limit how many players are allowed to use the
//	mortar on each team
//
//   Usage (client commands):
//
//   say /mortar
//	Brings up MOTD window with the following client
//	commands & instruction
//   class_mortar
//	Sets the users class to the mortar class. Must
//	respawn just like any other class.
//   mortar_deploy
//	Deploys the mortar and makes it ready to fire.
//	+attack2 will not do this.
//   mortar_up
//	Increases the power of the mortar by 100
//   mortar_down
//	Decreases the power of the mortar by 100
////////////////////////////////////////////
//   Updates
//   v.1.1
//   Thanks to 29th ID, Diamond-Optic, and 
//   =|[76AD]|= TatsuSaisei for finding bugs
//
//   -Fixed error messages when spectating mortar player
//   -Made death messages pending on mp_deathmsg
//   -Added class limits
//   -Switching weapons while deployed now undeploys
//   -Mortar kills now log as a mortar (instead of missile)
//   -Fixed bug with non-mortar classes getting ammo
//   -Fixed bazooka-drop-run bug
//
//   v1.11
//   -Fixed kills logging double
//   -Fixed class limits not recognising "-1"
////////////////////////////////////////////

#include <amxmodx>
#include <amxmisc>
#include <dodx>
#include <dodfun>
#include <engine>
#include <fakemeta>
#include <fun>

#define PLUGIN "Mortar Class"
#define VERSION "1.1"
#define AUTHOR "29th ID & Ludwig Van"

//Set this to the admin level at which they can change missile settings
#define ADMIN_MISSILE_SET ADMIN_LEVEL_H

//Settings for scorch mark made upon explosion
#define TE_WORLDDECAL 116 // Do not change
#define SCORCH 60

//Model Animations
#define ROUND_UP    0
#define ROUND_DOWN  1
#define IDLE_READY  2
#define FIRE        3
#define IDLE_UP     4
#define UP_TO_DOWN  5
#define IDLE_DOWN   6
#define DOWN_TO_UP  7
#define DRAW        8

#define SND_STOP	(1<<5)


#define DT 0.1
#define PI 3.1415926535897932384626433832795

new boom
new has_rocket[33]

new mortar_ammo[33]
new using_menu[33]
new tkcount[33]
new isDeployed[33]
new varPower[33]
new gmsgScoreInfo
new gmsgDeathMsg
new gmsgObject

new fileNames[2][] =
{
	"models/v_mortar.mdl", // Mortar View Model (Built into DoD GCF)
	"models/mapmodels/hk_mortar.mdl" // Mortar Map Model (Built into DoD GCF)
}

enum
{
	v_model,
	p_model
}


public plugin_init() {
	// CVARS
	register_cvar("dod_mortars","1",FCVAR_SERVER)
	register_cvar("dod_mortar_damradius","550")
	register_cvar("dod_mortar_defaultpower","700")
	register_cvar("dod_mortar_ammo","30")
	register_cvar("dod_mortar_maxdamage","180")
	register_cvar("dod_mortar_proned_decrease","35")
	register_cvar("dod_mortar_crouched_decrease","10")
	
	// Client Commands
	register_concmd("class_mortar", "go_mortar",0,"Change to Mortar Class")
	register_concmd("mortar_deploy", "cmd_deploy",0,"Deploy Mortar to Fire")
	register_concmd("mortar_up", "power_increase",0,"Increase Mortar Distance")
	register_concmd("mortar_down", "power_decrease",0,"Decrease Mortar Distance")
	register_clcmd("say /mortar", "mortar_motd")
	register_clcmd("drop", "drop_mortar")
	
	// Plugin Variables
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("ResetHUD", "reset_hud", "be")
	register_event("CurWeapon", "handle_gun", "be", "1=1")
	register_forward(FM_UpdateClientData, "UpdateClientData_Post", 1)
	register_think("lud_missile", "play_whistle")
	
	// Message Information
	gmsgDeathMsg = get_user_msgid("DeathMsg")
	gmsgScoreInfo = get_user_msgid("ScoreInfo")
	gmsgObject = get_user_msgid("Object")
}

public plugin_precache() {
	precache_model(fileNames[v_model])
	precache_model(fileNames[p_model])
	
	// Displayed on left of screen when deployed
	precache_model("sprites/mapsprites/ao_bangaloreobj.spr")
	// Models used as mortar shell (for each team - so they show up on minimap)
	precache_model("models/w_mills.mdl")
	precache_model("models/w_stick.mdl")

	// Sounds (come in GCF)
	precache_sound("weapons/mortar_shoot.wav")
	precache_sound("weapons/mortar_hit3.wav")
	precache_sound("weapons/mortar_incoming.wav")
	precache_sound("weapons/mortar_move.wav")

	boom = precache_model("sprites/zerogxplode.spr")
	
	return PLUGIN_CONTINUE
}

public reset_hud(id) {
	
	if(get_cvar_num("dod_mortars") == 0)
		return PLUGIN_CONTINUE
	
	new myClass = dod_get_user_class(id)
	// Sets default power for mortar
	varPower[id] = get_cvar_num("dod_mortar_defaultpower")
	// Makes sure client is undeployed
	isDeployed[id] = 0
	
	// Test if client is mortar class (us,brit,axis) - if so, give them a mortar
	if(myClass == 9){
		give_item(id, "weapon_pschreck")
		dod_set_user_ammo(id, DODW_PANZERSCHRECK, 0)
		mortar_ammo[id] = get_cvar_num("dod_mortar_ammo")
	}
	else if(myClass == 26){
		give_item(id, "weapon_pschreck")
		dod_set_user_ammo(id, DODW_PANZERSCHRECK, 0)
		mortar_ammo[id] = get_cvar_num("dod_mortar_ammo")
	}
	else if(myClass == 20){
		give_item(id, "weapon_bazooka")
		dod_set_user_ammo(id, DODW_BAZOOKA, 0)
		mortar_ammo[id] = get_cvar_num("dod_mortar_ammo")
	}
	else
		mortar_ammo[id] = 0
	
	return PLUGIN_CONTINUE
}

// Changes client's class to the mortar class (must respawn to take effect)
public go_mortar(id) {
	new curAllies, curAxis, curBrit, team = get_user_team(id)
	new limAllies = get_cvar_num("mp_limitalliesmortar")
	new limBrit   = get_cvar_num("mp_limitbritmortar")
	new limAxis   = get_cvar_num("mp_limitaxismortar")
	
	for (new i = 1; i <= 32; i++) { 
		if (!is_user_connected(i)) continue 
		new iClass = dod_get_user_class(i)
		if(iClass == 9) curAllies++
		else if(iClass == 26) curBrit++
		else if(iClass == 20) curAxis++
	} 
	
	if(team == ALLIES && dod_get_map_info(MI_ALLIES_TEAM) == 0) {
		if(curAllies < limAllies || limAllies == -1) {
			dod_set_user_class(id, 9)
			client_print(id, print_chat, "*You will respawn as Mortar")
		} else
			client_cmd(id, "cls_mortar")
	}
	else if (team == ALLIES && dod_get_map_info(MI_ALLIES_TEAM) == 1) {
		if(curBrit < limBrit || limBrit == -1) {
			dod_set_user_class(id, 26)
			client_print(id, print_chat, "*You will respawn as Mortar")
		} else
			client_cmd(id, "cls_britmortar")
	}
	else if(team == AXIS) {
		if(curAxis < limAxis || limAxis == -1) {
			dod_set_user_class(id, 20)
			client_print(id, print_chat, "*You will respawn as Morserschutze")
		} else
			client_cmd(id, "cls_germortar")
	}
	
	return PLUGIN_HANDLED
}

// Replaces "slotholding" weapon with a mortar model
public handle_gun(id) {
	new team = get_user_team(id)
	new myWeapon = read_data(2)
	
	if(isDeployed[id]) cmd_deploy(id)
	
	// If it's supposed to be a mortar, make it one
	if((team == ALLIES && myWeapon == DODW_PANZERSCHRECK) || (team == AXIS && myWeapon == DODW_BAZOOKA))
	{
		entity_set_string(id, EV_SZ_viewmodel, fileNames[v_model])
		entity_set_string(id, EV_SZ_weaponmodel, fileNames[p_model])
		set_animation(id, IDLE_UP)
		
		// Adjust origin
		new currentent = -1, gunid = 0, Float:gunOrigin[3]

		// get origin
		new Float:origin[3];
		entity_get_vector(id,EV_VEC_origin,origin);
	
		while((currentent = find_ent_in_sphere(currentent,origin,Float:1.0)) != 0) {
			new classname[32];
			entity_get_string(currentent,EV_SZ_classname,classname,31);
	
			if(equal(classname,"weapon_bazooka") || equal(classname,"weapon_pschreck"))
				gunid = currentent
	
		}
		entity_get_vector(gunid, EV_VEC_origin, gunOrigin)
		gunOrigin[0] += 100
		gunOrigin[1] += 200
		gunOrigin[2] +=  10
		entity_set_vector(gunid, EV_VEC_origin, gunOrigin)
	}
	
	return PLUGIN_CONTINUE
}

// Plays weapon animations for the client only
// (this will not affect what other players see the client doing)
public set_animation(id, seq) 
{
	entity_set_int(id, EV_INT_weaponanim, seq);
	message_begin(MSG_ONE, SVC_WEAPONANIM, {0,0,0}, id);
	write_byte(seq);
	write_byte(entity_get_int(id, EV_INT_body));
	message_end();
	
	return PLUGIN_CONTINUE
}

// Displays sprite on the left side of the screen (to confirm you are deployed)
public show_sprite(id,config) {
	if(config){
		message_begin(MSG_ONE, gmsgObject, {500,300,100}, id)
		write_string("sprites/mapsprites/ao_bangaloreobj.spr")
		message_end()
	}
	else {
		message_begin(MSG_ONE, gmsgObject, {500,300,100}, id)
		write_string("")
		message_end()
	}
}

// Called before a each frame is sent to a client
public client_PreThink(id) {
	if(!is_user_alive(id))
		return PLUGIN_HANDLED
		
	new team = get_user_team(id)
	new clip, ammo, myWeapon = get_user_weapon(id,clip,ammo)
	
	// If client is holding a mortar...
	if((team == ALLIES && myWeapon == DODW_PANZERSCHRECK) || (team == AXIS && myWeapon == DODW_BAZOOKA)) {
		// If cilent is not deployed, constantly play the "idle" animation
		// --if this is not here, it will play the bazooka's idle animation #
		// which is a different animation for the mortar model.
		if(!isDeployed[id])
			set_animation(id, IDLE_UP)
		// If firing, cancel bazooka fier and fire the mortar instead
		if(get_user_button(id) & IN_ATTACK) {
			new button = entity_get_int(id,EV_INT_button)
			entity_set_int(id,EV_INT_button,button & ~IN_ATTACK)
			cmd_launch(id)
			return PLUGIN_HANDLED
		}
		// If secondary firing, cancel it. I attempted making this also call
		// the deploy function but it gets very buggy and does not deploy unless
		// you presss attack2 several times.
		else if(get_user_button(id) & IN_ATTACK2) { 
			new button2 = entity_get_int(id,EV_INT_button);
			entity_set_int(id,EV_INT_button,button2 & ~IN_ATTACK2)
			return PLUGIN_HANDLED
		}
		// If client moves while deployed, undeploy if standing, or cancel if proned
		else if((get_user_button(id) & IN_FORWARD) && (isDeployed[id])) {
			if(!dod_get_pronestate(id)) cmd_deploy(id)
			new button = entity_get_int(id,EV_INT_button)
			entity_set_int(id,EV_INT_button,button & ~IN_FORWARD)
		}
		else if((get_user_button(id) & IN_BACK) && (isDeployed[id])) {
			if(!dod_get_pronestate(id)) cmd_deploy(id)
			new button = entity_get_int(id,EV_INT_button)
			entity_set_int(id,EV_INT_button,button & ~IN_BACK)
		}
		else if((get_user_button(id) & IN_MOVELEFT) && (isDeployed[id])) {
			if(!dod_get_pronestate(id)) cmd_deploy(id)
			new button = entity_get_int(id,EV_INT_button)
			entity_set_int(id,EV_INT_button,button & ~IN_MOVELEFT)
		}
		else if((get_user_button(id) & IN_MOVERIGHT) && (isDeployed[id])) {
			if(!dod_get_pronestate(id)) cmd_deploy(id)
			new button = entity_get_int(id,EV_INT_button)
			entity_set_int(id,EV_INT_button,button & ~IN_MOVERIGHT)
		}
		
	}
	
	return PLUGIN_CONTINUE
}

// This is also called when a client receives a frame. It basically disables the firing
// of the bazooka client-side, which allows for proper animations, etc.
// Thanks KCE for the below function
public UpdateClientData_Post( id, sendweapons, cd_handle )
{
	if ( !is_user_alive(id) )
		return FMRES_IGNORED;
	new team = get_user_team(id)
	new clip, ammo, myWeapon = get_user_weapon(id,clip,ammo)
	// If holding a mortar disable firing of the bazooka holding its slot
	if((team == ALLIES && myWeapon == DODW_PANZERSCHRECK) || (team == AXIS && myWeapon == DODW_BAZOOKA))
		set_cd(cd_handle, CD_flNextAttack, halflife_time() + 0.001 );

	return FMRES_HANDLED;
}

// This function fires the mortar
public cmd_launch(id) {
	if( (!dod_get_pronestate(id)) && (is_user_alive(id)) ) {
		client_print(id, print_center, "You must be proned and deployed to fire the mortar!")
		return PLUGIN_CONTINUE
	}
	if((!isDeployed[id]) && (is_user_alive(id)) ) {
		client_print(id, print_center, "You must be deployed to fire the mortar!")
		return PLUGIN_CONTINUE
	}
	
	// If client has a shell that is still in the air, cancel firing
	// This prevents rapid fire and works well to safeguard long range shots
	if(has_rocket[id])
		return PLUGIN_HANDLED

	new cmd[32]
	read_argv(0,cmd,31)
	
	// Display current mortar ammunition on the HUD
	show_mortar_ammo(id)

	if( mortar_ammo[id] <= 0 ){
		client_print(id,print_center,"You have no more mortar shells.")
		return PLUGIN_HANDLED
	}
	else {
	// Decrease mortar ammunition
	mortar_ammo[id] -= 1
	}
	show_mortar_ammo(id)
	make_shell(id,varPower[id])
	
	// Play the animation client-side
	set_animation(id, FIRE)
	
	return PLUGIN_CONTINUE
}

// This command is called when the client deploys the mortar
// -- sets the mortar to firing/live status
public cmd_deploy(id) {
	new team = get_user_team(id)
	new clip, ammo, myWeapon = get_user_weapon(id,clip,ammo)
	if((team == ALLIES && myWeapon != DODW_PANZERSCHRECK) || (team == AXIS && myWeapon != DODW_BAZOOKA))
		return PLUGIN_HANDLED
	if( (!dod_get_pronestate(id)) && (!isDeployed[id]) ) {
		client_print(id, print_center, "You must be proned to deploy/undeploy the mortar!")
		return PLUGIN_CONTINUE
	}
	
	new Float:speed
	
	if(isDeployed[id]) {
		if(dod_get_pronestate(id) > 0)
			speed = 60.0
		else
			speed = 600.0
		isDeployed[id] = 0
		show_sprite(id, 0)
		set_animation(id, DOWN_TO_UP)
	}
	else {
		speed = 0.0
		isDeployed[id] = 1
		show_sprite(id, 1)
		set_animation(id, UP_TO_DOWN)
	}
	set_user_maxspeed(id, speed)
	
	return PLUGIN_HANDLED
}

// This function is called when the client increases the power of the mortar
public power_increase(id) {
	new team = get_user_team(id)
	new clip, ammo, myWeapon = get_user_weapon(id,clip,ammo)
	if(!isDeployed[id])
		return PLUGIN_CONTINUE
	
	if((team == ALLIES && myWeapon == DODW_PANZERSCHRECK) || (team == AXIS && myWeapon == DODW_BAZOOKA)) {
		if(varPower[id] < 1500)
			varPower[id] = varPower[id]+100
		client_print(id,print_center,"Mortar Power Set to %i", varPower[id])
		emit_sound(id, CHAN_WEAPON, "weapons/mortar_move.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
	return PLUGIN_HANDLED
}

// This function is called when the client increases the power of the mortar
public power_decrease(id) {
	
	new team = get_user_team(id)
	new clip, ammo, myWeapon = get_user_weapon(id,clip,ammo)
	if(!isDeployed[id])
		return PLUGIN_CONTINUE
	
	if((team == ALLIES && myWeapon == DODW_PANZERSCHRECK) || (team == AXIS && myWeapon == DODW_BAZOOKA)) {
		if(varPower[id] > 400)
			varPower[id] = varPower[id]-100
		client_print(id,print_center,"Mortar Power Set to %i", varPower[id])
		emit_sound(id, CHAN_WEAPON, "weapons/mortar_move.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
	return PLUGIN_HANDLED
}

// This function undeploys the mortar when it is dropped so you are not stuck
// not being able to move
public drop_mortar(id) {
	new team = get_user_team(id)
	new clip, ammo, myWeapon = get_user_weapon(id,clip,ammo)
	if((team == ALLIES && myWeapon != DODW_PANZERSCHRECK) || (team == AXIS && myWeapon != DODW_BAZOOKA))
		return PLUGIN_CONTINUE
	if(dod_get_pronestate(id) > 0)
		set_user_maxspeed(id,60.0)
	else
		set_user_maxspeed(id,600.0)
	isDeployed[id] = 0
	show_sprite(id, 0)
	return PLUGIN_CONTINUE
}

public client_connect(id) {
	using_menu[id] = 0
	has_rocket[id] = 0
	tkcount[id] = 0
}

public client_disconnect(id){
	has_rocket[id] = 0
	tkcount[id] = 0
}

public vexd_pfntouch(pToucher, pTouched) {

	if ( !is_valid_ent(pToucher) ) return

	new szClassName[32]
	entity_get_string(pToucher, EV_SZ_classname, szClassName, 31)

	if(equal(szClassName, "lud_missile")) {
		new damradius = get_cvar_num("dod_mortar_damradius")
		new maxdamage = get_cvar_num("dod_mortar_maxdamage")

		if (damradius <= 0) {
			log_amx("Damage Radius must be set higher than 0, defaulting to 240")
			damradius = 240
			set_cvar_num("dod_mortar_damradius",damradius)
		}
		if (maxdamage <= 0) {
			log_amx("Max Damage must be set higher than 0, defaulting to 140")
			maxdamage = 140
			set_cvar_num("dod_mortar_maxdamage",maxdamage)
		}

		//remove_task(2020+pToucher)
		new tk = 0
		new Float:fl_vExplodeAt[3]
		entity_get_vector(pToucher, EV_VEC_origin, fl_vExplodeAt)
		new vExplodeAt[3]
		vExplodeAt[0] = floatround(fl_vExplodeAt[0])
		vExplodeAt[1] = floatround(fl_vExplodeAt[1])
		vExplodeAt[2] = floatround(fl_vExplodeAt[2])
		new id = entity_get_edict(pToucher, EV_ENT_owner)
		new unarmed = mortar_ammo[id]
		new origin[3],dist,i,Float:dRatio,damage
		attach_view(id, id)
		if(has_rocket[id] == pToucher)
		has_rocket[id] = 0

		for ( i = 1; i < 32; i++) {

			if(is_user_alive(i)){
				get_user_origin(i,origin)
				dist = get_distance(origin,vExplodeAt)
				if (dist <= damradius) {

					dRatio = floatdiv(float(dist),float(damradius))
					damage = maxdamage - floatround( maxdamage * dRatio)

					if(cvar_exists("mp_friendlyfire")) {
						if( get_cvar_num("mp_friendlyfire") ) {
							if((get_user_team(i) == get_user_team(id)) && (i != id)) tk = 1
							do_victim(i,id,damage,unarmed,tk)
						}
						else {
							if(get_user_team(i) != get_user_team(id)) {
								do_victim(i,id,damage,unarmed,0)
							}
						}
					}
					else {
						do_victim(i,id,damage,unarmed,0)
					}
				}
			}

		}

		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(3)
		write_coord(vExplodeAt[0])
		write_coord(vExplodeAt[1])
		write_coord(vExplodeAt[2])
		write_short(boom)
		write_byte(100)
		write_byte(15)
		write_byte(0)
		message_end()

		emit_sound(pToucher, CHAN_WEAPON, "weapons/mortar_hit3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		emit_sound(pToucher, CHAN_VOICE, "weapons/mortar_hit3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		emit_sound(pToucher, CHAN_ITEM, "weapons/mortar_hit3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		
		// Draw scorch on ground or wall
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		write_coord(vExplodeAt[0]) 
		write_coord(vExplodeAt[1]) 
		write_coord(vExplodeAt[2]) 
		write_byte(SCORCH)
		message_end()

		remove_entity(pToucher)

		if ( is_valid_ent(pTouched) ) {
			new szClassName2[32]
			entity_get_string(pTouched, EV_SZ_classname, szClassName2, 31)

			if(equal(szClassName2, "lud_missile")) {
				emit_sound(pTouched, CHAN_WEAPON, "weapons/mortar_hit3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				emit_sound(pTouched, CHAN_VOICE, "weapons/mortar_hit3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				emit_sound(pTouched, CHAN_ITEM, "weapons/mortar_hit3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				new id2 = entity_get_edict(pTouched, EV_ENT_owner)
				attach_view(id2, id2)
				if(has_rocket[id2] == pTouched){
					has_rocket[id2] = 0
				}
				remove_entity(pTouched)
			}
		}
	}
}

do_victim(victim,attacker,damage,unarmed,tk) {
	new namek[32],namev[32],authida[35],authidv[35],teama[32],teamv[32]
	get_user_name(victim,namev,31)
	get_user_name(attacker,namek,31)
	get_user_authid(victim,authidv,34)
	get_user_authid(attacker,authida,34)
	get_user_team(victim,teamv,31)
	get_user_team(attacker,teama,31)
	
	// If victim is proned or crouched, do less damage
	if((dod_get_pronestate(victim) > 0) && (damage > 0))
		damage = (damage - get_cvar_num("dod_mortar_proned_decrease"))
	else if((get_user_button(victim) & IN_DUCK) && (damage > 0))
		damage = (damage - get_cvar_num("dod_mortar_crouched_decrease"))
	if(damage < 1) damage = 0

	if(damage >= get_user_health(victim)){

		if(get_cvar_num("mp_logdetail") == 3){
			log_message("^"%s<%d><%s><%s>^" attacked ^"%s<%d><%s><%s>^" with ^"mortar^" (hit ^"chest^") (damage ^"%d^") (health ^"0^")",
				namek,get_user_userid(attacker),authida,teama,namev,get_user_userid(victim),authidv,teamv,damage)
		}

		if(unarmed == 2){
			log_amx("^"%s<%d><%s><%s>^" admin mortar killed ^"%s<%d><%s><%s>^"",
				namek,get_user_userid(attacker),authida,teama,namev,get_user_userid(victim),authidv,teamv)
		}

		if(tk > 0) {
			tkcount[attacker] += 1
			set_user_frags(attacker,get_user_frags(attacker) - 1 )
		}

		set_msg_block(gmsgDeathMsg,BLOCK_ONCE)
		set_msg_block(gmsgScoreInfo,BLOCK_ONCE)
		user_kill(victim,1)
		replace_dm(attacker,victim,0)

		log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"mortar^"",
			namek,get_user_userid(attacker),authida,teama,namev,get_user_userid(victim),authidv,teamv)
		}
	else {
		set_user_health(victim,get_user_health(victim) - damage )

		if(get_cvar_num("mp_logdetail") == 3) {
			log_message("^"%s<%d><%s><%s>^" attacked ^"%s<%d><%s><%s>^" with ^"mortar^" (hit ^"chest^") (damage ^"%d^") (health ^"%d^")",
				namek,get_user_userid(attacker),authida,teama,namev,get_user_userid(victim),authidv,teamv,damage,get_user_health(victim))
		}
	}
}

make_shell(id,iarg1) {

	if (!is_user_alive(id)) return PLUGIN_CONTINUE

	new args[16]
	new Float:vOrigin[3]
	new Float:vAngles[3]
	entity_get_vector(id, EV_VEC_origin, vOrigin)
	entity_get_vector(id, EV_VEC_v_angle, vAngles)
	new notFloat_vOrigin[3]
	notFloat_vOrigin[0] = floatround(vOrigin[0])
	notFloat_vOrigin[1] = floatround(vOrigin[1])
	notFloat_vOrigin[2] = floatround(vOrigin[2])

	new NewEnt
	NewEnt = create_entity("info_target")
	if(NewEnt == 0) {
		client_print(id,print_chat,"Mortar Failure")
		return PLUGIN_HANDLED_MAIN
	}
	has_rocket[id] = NewEnt

	entity_set_string(NewEnt, EV_SZ_classname, "lud_missile")

	new team = get_user_team(id)
	if(team == AXIS)
		entity_set_model(NewEnt, "models/w_stick.mdl")
	else
		entity_set_model(NewEnt, "models/w_mills.mdl")

	new Float:fl_vecminsx[3] = {-1.0, -1.0, -1.0}
	new Float:fl_vecmaxsx[3] = {1.0, 1.0, 1.0}

	entity_set_vector(NewEnt, EV_VEC_mins,fl_vecminsx)
	entity_set_vector(NewEnt, EV_VEC_maxs,fl_vecmaxsx)

	entity_set_origin(NewEnt, vOrigin)
	entity_set_vector(NewEnt, EV_VEC_angles, vAngles)

	//entity_set_int(NewEnt, EV_INT_effects, 2)

	entity_set_int(NewEnt, EV_INT_solid, 2)
	entity_set_int(NewEnt, EV_INT_movetype, 6)
	entity_set_edict(NewEnt, EV_ENT_owner, id)
	entity_set_float(NewEnt, EV_FL_health, 10000.0)
	entity_set_float(NewEnt, EV_FL_takedamage, 100.0)
	entity_set_float(NewEnt, EV_FL_dmg_take, 100.0)

	new Float:fl_iNewVelocity[3]
	new iNewVelocity[3]
	VelocityByAim(id, iarg1, fl_iNewVelocity)
	entity_set_vector(NewEnt, EV_VEC_velocity, fl_iNewVelocity)
	iNewVelocity[0] = floatround(fl_iNewVelocity[0])
	iNewVelocity[1] = floatround(fl_iNewVelocity[1])
	iNewVelocity[2] = floatround(fl_iNewVelocity[2])

	emit_sound(NewEnt, CHAN_WEAPON, "weapons/mortar_shoot.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	// Continuously play "whistle" sound to avoid "sky-blockage"
	entity_set_float(NewEnt, EV_FL_nextthink, get_gametime() + 0.5)
	

	args[0] = id
	args[1] = NewEnt
	args[2] = iarg1
	args[3] = iNewVelocity[0]
	args[4] = iNewVelocity[1]
	args[5] = iNewVelocity[2]
	args[8] = notFloat_vOrigin[0]
	args[9] = notFloat_vOrigin[1]
	args[10] = notFloat_vOrigin[2]
	
	entity_set_float(NewEnt, EV_FL_gravity, 0.25)

	return PLUGIN_HANDLED_MAIN
}

// This function plays the whistling sound of the shell falling.
// It is called repeatedly because if it is only called once, the "sky" of the map will
// block the sound from being heard.
public play_whistle(ent) {
	new Float:myVelocity[3]
	entity_get_vector(ent, EV_VEC_velocity, myVelocity)
	if(myVelocity[2] <= 0.0) {
		emit_sound(ent, CHAN_ITEM, "weapons/mortar_incoming.wav", VOL_NORM, ATTN_NONE, 0, PITCH_NORM)
		entity_set_float(ent, EV_FL_nextthink, get_gametime() + 1.0)
	} else
		entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.5)
}

// This function displays mortar ammo/shell count on the HUD
show_mortar_ammo(id){
	new Message[350]
	new len = 349
	new n = 0

	set_hudmessage(255, 10, 10, 0.80, 0.60, 0, 0.02, 6.0, 1.01, 1.1, 55)
	n += format( Message[n],len-n,"Shells: %d ^n",mortar_ammo[id])

	show_hudmessage(id,Message)
	return PLUGIN_HANDLED
}

// Creates a new death message to allow the killer and victim to be displayed properly
// and includes the proper weapon (mortar)
public replace_dm(id,tid,tbody) {
	
	if(get_cvar_num("mp_deathmsg"))
		dod_make_deathmsg(id, tid, 41)
	
	// Check to see if its a TK, if not increment score
	if(get_user_team(id) != get_user_team(tid))
		dod_set_user_kills(id, dod_get_user_kills(id) + 1)
	
	return PLUGIN_CONTINUE
}

public CalculateVelocity(Float:vOrigin[3], Float:vEnd[3], Float:vVelocity[3]){
	vVelocity[0] = (vEnd[0] - vOrigin[0]) / DT
	vVelocity[1] = (vEnd[1] - vOrigin[1]) / DT
	vVelocity[2] = (vEnd[2] - vOrigin[2]) / DT
}	

// MOTD Popup with client information
// Thanks to Ludwig Van.
public mortar_motd(id){

	new len = 1024
	new buffer[1025]
	new n = 0
#if !defined NO_STEAM
	n += copy( buffer[n],len-n,"<html><head><style type=^"text/css^">pre{color:#FFB000;}body{background:#000000;margin-left:8px;margin-top:0px;}</style></head><body><pre>")
#endif
	n += copy( buffer[n],len-n,"To use the mortar class you must type the following command^n")
	n += copy( buffer[n],len-n,"in your console and then respawn to change class:^n^n")
	n += copy( buffer[n],len-n,"class_mortar^n^n")
	n += copy( buffer[n],len-n,"You must then bind the following commands to keys to use it.^n^n")
	n += copy( buffer[n],len-n,"bind KEY mortar_deploy^n")
	n += copy( buffer[n],len-n,"(deploys mortar and makes it ready to fire)^n^n")
	n += copy( buffer[n],len-n,"bind KEY mortar_up^n")
	n += copy( buffer[n],len-n,"(increases mortar power/speed)^n^n")
	n += copy( buffer[n],len-n,"bind KEY mortar_down^n")
	n += copy( buffer[n],len-n,"(decreases mortar power/speed)^n^n^n^n")
	n += copy( buffer[n],len-n,"Part of DOD:Realism - making DoD More Realistic.^n")
	n += copy( buffer[n],len-n,"Visit http://dodrealism.branzone.com^n")
	// Please leave the link in - we are helping improve DoD's realism and need people to know about it.
	

#if !defined NO_STEAM
	n += copy( buffer[n],len-n,"</pre></body></html>")
#endif

	show_motd(id, buffer, "Mortar Class Help:")
	return PLUGIN_CONTINUE
}
