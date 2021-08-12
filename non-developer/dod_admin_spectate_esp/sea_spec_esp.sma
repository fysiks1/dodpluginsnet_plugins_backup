/* AMX Mod X - Script
*
*	Admin Spectator ESP v1.2
*	Copyright (C) 2006 by KoST
*
*	this plugin along with its compiled version can de downloaded here:
*	http://www.amxmodx.org/forums/viewtopic.php?t=24787	
*	
*
*  This program is free software; you can redistribute it and/or
*  modify it under the terms of the GNU General Public License
*  as published by the Free Software Foundation; either version 2
*  of the License, or (at your option) any later version.
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program; if not, write to the Free Software
*  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*
*  In addition, as a special exception, the author gives permission to
*  link the code of this program with the Half-Life Game Engine ("HL
*  Engine") and Modified Game Libraries ("MODs") developed by Valve,
*  L.L.C ("Valve"). You must obey the GNU General Public License in all
*  respects for all of the code used other than the HL Engine and MODs
*  from Valve. If you modify this file, you may extend this exception
*  to your version of the file, but you are not obligated to do so. If
*  you do not wish to do so, delete this exception statement from your
*  version.
*/
//--------------------------------------------------------------------------------------------------

#include <amxmodx>
#include <engine>

// Here you can adjust the required admin level if needed
// there is a list of all levels http://www.amxmodx.org/funcwiki.php?go=module&id=1#const_admin

#define REQUIRED_ADMIN_LEVEL ADMIN_KICK

//--------------------------------------------------------------------------------------------------

#define PLUGIN "Admin Spectator ESP"
#define VERSION "1.2"
#define AUTHOR "KoST"

enum {
	ESP_ON=0,
	ESP_LINE,
	ESP_BOX,
	ESP_NAME,
	ESP_HEALTH_ARMOR,
	ESP_WEAPON,
	ESP_CLIP_AMMO,
	ESP_DISTANCE,
	ESP_TEAM_MATES,
	ESP_AIM_VEC,
}

enum {
	MOD_CS=1,
	MOD_DOD,
	MOD_TFC,
	MOD_NS,
	MOD_TS,
}

new bool:admin[33] // is/is not admin
new bool:first_person[33] //is/is not in first person view
new spec[33] // spec[player_id]=the players id if
new laser // precached model
new max_players // if you start hlds with +maxplayers 20 for example this would be 20
new team_colors[8][3]={{0,0,0},{0,150,0},{150,0,0},{0,150,0},{150,150,0},{0,150,150},{150,0,150},{150,150,45}} 
new esp_colors[5][3]={{0,255,0},{100,60,60},{60,60,100},{255,0,255},{128,128,128}}
new bool:ducking[33] //is/is not player ducked
new damage_done_to[33] //damage_done_to[p1]=p2 // p1 has hit p2
new view_target[33] // attackers victim
new bool:admin_options[33][10] // individual esp options
new bool:is_in_menu[33] // has esp menu open
new g_modName[15]
new g_team[33] //123...,<1=spec, dod
new g_mod

// weapon strings
//just doing this to keep with the standard... perhaps stick with one weapon array, use a large max, and then use the normal get_weapon_name cmds on init?, or a custom include file
#define CS_WPN_MAX 30
new const cs_weapons[CS_WPN_MAX][10]={"None","P228","Scout","HE","XM1014","C4",
	"MAC-10","AUG","Smoke","Elite","Fiveseven",
	"UMP45","SIG550","Galil","Famas","USP",
	"Glock","AWP","MP5","M249","M3","M4A1",
	"TMP","G3SG1","Flash","Deagle","SG552",
	"AK47","Knife","P90"}
#define DOD_WPN_MAX 42
new const dod_weapons[DOD_WPN_MAX][20]={
	"None","Knife-Am","Knife-Ge","Colt","LUGER","GARAND",
	"Kar-scoped","Thompson","STG44","SPRINGFIELD","Kar","Bar",
	"MP40","HANDGRENADE","STICKGRENADE","STICKGRENADE_EX",
	"HANDGRENADE_EX","MG42","30_CAL","SPADE","M1_CARBINE",
	"MG34","GREASEGUN","FG42","K43","ENFIELD","STEN","BREN",
	"WEBLEY","BAZOOKA","PANZERSCHRECK","PIAT","SCOPED_FG42",
	"FOLDING_CARBINE","KAR_BAYONET","SCOPED_ENFIELD","MILLS_BOMB",
	"BRITKNIFE","GARAND_BUTT","ENFIELD_BAYONET","MORTAR","K43_BUTT"}
#define TFC_WPN_MAX 32
new const tfc_weapons[TFC_WPN_MAX][20]={
	"None","Timer","SentryGun","Medkit","SPANNER","AXE","SNIPERRIFLE",
	"AUTORIFLE","SHOTGUN","SUPERSHOTGUN","NG","SUPERNG","GL",
	"FLAMETHROWER","RPG","IC","FLAMES","AC","UNK18","UNK19","TRANQ",
	"RAILGUN","PL","KNIFE","CALTROP","CONCUSSIONGRENADE","NORMALGRENADE",
	"NAILGRENADE","MIRVGRENADE","NAPALMGRENADE","GASGRENADE","EMPGRENADE"}
#define NS_WPN_MAX 32
new const ns_weapons[NS_WPN_MAX][20]={
	"NONE","CLAWS","SPIT","SPORES","SPIKE","BITE","BITE2","SWIPE",
	"WEBSPINNER","METABOLIZE","PARASITE","BLINK","DIVINEWIND","KNIFE",
	"PISTOL","LMG","SHOTGUN","HMG","WELDER","MINE","GRENADE_GUN",
	"LEAP","CHARGE","UMBRA","PRIMALSCREAM","BILEBOMB","ACIDROCKET",
	"HEALINGSPRAY","GRENADE","STOMP","DEVOUR","MAX"}
#define TS_WPN_MAX 38
new const ts_weapons[TS_WPN_MAX][20]={
	"None","GLOCK18","UNK1","UZI","M3","M4A1","MP5SD","MP5K","ABERETTAS",
	"MK23","AMK23","USAS","DEAGLE","AK47","57","AUG","AUZI","TMP","M82A1",
	"MP7","SPAS","GCOLTS","GLOCK20","UMP","M61GRENADE","CKNIFE","MOSSBERG",
	"M16A4","MK1","C4","A57","RBULL","M60E3","SAWED_OFF","KATANA","SKNIFE",
	"KUNG_FU","TKNIFE"}
	
public plugin_precache(){
	laser=precache_model("sprites/laserbeam.spr") 
}

public plugin_init(){
	register_plugin(PLUGIN,VERSION,AUTHOR)
	server_print("^n^t%s v%s by %s^n",PLUGIN,VERSION,AUTHOR)

	// g_mod init, maybe i should have done boolean, or both, main use is for picking the weapon array
	get_modname(g_modName,14)
	if(equal(g_modName,"cstrike")) g_mod = MOD_CS;
	else if(equal(g_modName,"dod")) g_mod = MOD_DOD;
	else if(equal(g_modName,"tfc")) g_mod = MOD_TFC;
	else if(equal(g_modName,"ns")) g_mod = MOD_NS;
	else if(equal(g_modName,"ts")) g_mod = MOD_TS;
	
	// cvars
	register_cvar("esp","1")
	register_cvar("esp_timer","0.3")
	register_cvar("esp_allow_all","0")
	register_cvar("esp_disable_default_keys","0")
	
	// client commands
	register_clcmd("esp_menu","cmd_esp_menu",ADMIN_ALL,"Shows ESP Menu")
	register_clcmd("esp_toggle","cmd_esp_toggle",ADMIN_ALL,"Toggle ESP on/off")
	register_clcmd("say /esp_menu","cmd_esp_menu",ADMIN_ALL,"Shows ESP Menu")
	register_clcmd("say /esp_toggle","cmd_esp_toggle",ADMIN_ALL,"Toggle ESP on/off")
	register_clcmd("amx_ginfo","cmd_ginfo")
	
	// events
	if(equal(g_modName,"cstrike")) {
	register_event("SpecHealth2","spec_target","bd")
	register_event("Damage", "event_Damage", "b", "2!0", "3=0", "4!0")
	register_event("TextMsg","spec_mode","b","2&#Spec_Mode")
	}
	else if(equal(g_modName,"dod")) { //Gessu http://www.amxmodx.org/forums/viewtopic.php?t=8222
	register_event("TextMsg","spec_mode","b","2&#Spec_Mode")
	register_event("StatusValue","on_StatusValue","bd")//,"1=2")
	register_event("TextMsg","on_joinTeam","a","2=#game_joined_team")
	register_event("Health", "event_Damage","b")
	}
	else if(equal(g_modName,"tfc")) {
	register_event("TextMsg","spec_mode","b","2&#Spec_Mode")
	register_event("StatusValue","on_StatusValue","bd")//,"1=2")
	register_event("Damage", "event_Damage", "b", "2!0", "3=0", "4!0")
	}
	else if(equal(g_modName,"ns")) {
	set_task( 0.5, "ent_update_spec",_,_,_, "b" )
	//register_event("TextMsg","spec_mode","b","2&#Spec_Mode")
	//register_event("StatusValue","on_StatusValue","bd")//,"1=2")
	//register_event("Damage", "event_Damage", "b", "2!0", "3=0", "4!0")
	}
	else if(equal(g_modName,"ts")) {
	set_task( 0.5, "ent_update_spec",_,_,_, "b" )
	//register_event("TextMsg","spec_mode","b","2&#Spec_Mode")
	//register_event("StatusValue","on_StatusValue","bd")//,"1=2")
	//register_event("Damage", "event_Damage", "b", "2!0", "3=0", "4!0")
	}
	else {
	set_task( 0.5, "ent_update_spec",_,_,_, "b" )
	}
	
	// menu
	new keys=MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9
	register_menucmd(register_menuid("Admin Specator ESP"),keys,"menu_esp")
	
	max_players=get_maxplayers()
	
	// start esp_timer for the first time
	set_task(1.0,"esp_timer")
} 
public cmd_ginfo(id){
	new team[31]
	get_user_team(id,team,30)
	client_print(id, print_chat,"get_user_team:%s,get_user_team#%d,team#%d:,spec:%d,g_modName:%s,is_user_alive:%d,get_team:%d,first_person:%d", team,get_user_team(id),g_team[id],spec[id],g_modName,is_user_alive(id),get_team(id),first_person[id])
	client_print(id, print_chat,"%d,%d,%d,%d",entity_get_int(id, EV_INT_iuser1),entity_get_int(id, EV_INT_iuser2),entity_get_int(id, EV_INT_iuser3),entity_get_int(id, EV_INT_iuser4))
}

public cmd_esp_menu(id){
	if (admin[id] && get_cvar_num("esp")==1){
		show_esp_menu(id)
	}
}

public cmd_esp_toggle(id){
	if (admin[id] && get_cvar_num("esp")==1){
		change_esp_status(id,!admin_options[id][0])
	}
}

public show_esp_menu(id){
	is_in_menu[id]=true
	new menu[301]
	new keys=MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9
	new onoff[2][]={{"\roff\w"},{"\yon\w"}} // \r=red \y=yellow \w white
	new text[2][]={{"(use move forward/backward to switch on/off)"},{"(use esp_toggle command to toggle)"}} // \r=red \y=yellow \w white
	new text_index=get_cvar_num("esp_disable_default_keys")
	if (text_index!=1) text_index=0
	format(menu, 300, "Admin Specator ESP^nis %s %s^n^n1. Line is %s^n2. Box is %s^n3. Name is %s^n4. Health/Armor is %s^n5. Weapon is %s^n6. Clip/Ammo is %s^n7. Distance is %s^n8. Show TeamMates is %s^n9. Show AimVector is %s^n^n0. Exit",
	onoff[admin_options[id][ESP_ON]],
	text[text_index],
	onoff[admin_options[id][ESP_LINE]],
	onoff[admin_options[id][ESP_BOX]],
	onoff[admin_options[id][ESP_NAME]],
	onoff[admin_options[id][ESP_HEALTH_ARMOR]],
	onoff[admin_options[id][ESP_WEAPON]],
	onoff[admin_options[id][ESP_CLIP_AMMO]],
	onoff[admin_options[id][ESP_DISTANCE]],
	onoff[admin_options[id][ESP_TEAM_MATES]],
	onoff[admin_options[id][ESP_AIM_VEC]])
	show_menu(id,keys,menu)
	
	return PLUGIN_HANDLED
}

public menu_esp(id,key){
	if (key==9){ // exit
		is_in_menu[id]=false
		return PLUGIN_HANDLED
	}
	// toggle esp options
	if (admin_options[id][key+1]){
		admin_options[id][key+1]=false
		}else{
		admin_options[id][key+1]=true
	}
	show_esp_menu(id)
	return PLUGIN_HANDLED
}

public event_Damage(id){     
	if (id>0) {         
		new attacker=get_user_attacker(id)         
		if (attacker>0 && attacker<= get_maxplayers()){             
			if (view_target[attacker]==id){                 
				damage_done_to[attacker]=id             
			}         
		}     
	}     
	return PLUGIN_CONTINUE 
}

public spec_mode(id){
	// discover if in first_person_view
	new specMode[12]
	read_data(2,specMode,11)
	
	if(equal(specMode,"#Spec_Mode4")){
		first_person[id]=true
		}else{
		first_person[id]=false
	}
	return PLUGIN_CONTINUE
}

public spec_target(id){
	new target=read_data(2)
	if (target!=0){
		spec[id]=target
	}
	return PLUGIN_CONTINUE
}

public on_StatusValue(id){    
	if(!first_person[id])
		return PLUGIN_CONTINUE

	new origin[3], targetorigin[3]
	new players[32], numberofplayers, i
	new targetid = 0
	new name[32]

	get_user_origin(id, origin)

	get_players(players, numberofplayers, "a")
	new player
	for (i=0;i<numberofplayers;i++){
		player = players[i]
		if(player != id ){
			get_user_origin(player, targetorigin)
			get_user_name(player, name, 31)

			if( get_distance(origin, targetorigin) < 50 ){
				targetid = player
				break
			}
		}
	}

	if( targetid == 0 )
		return PLUGIN_CONTINUE

	spec[id] = targetid

	return PLUGIN_CONTINUE
}

public on_joinTeam(){
	new name[32], team[32]
	read_data(4,team,31)
	read_data(3,name,31)

	new id = get_user_index(name)
	//client_print(id, print_chat,".%s.%s.",name,team)
	if(equal(team,"Spectators")){
		g_team[id] = 0
	}
	else if(equal(team,"Allies")){
		g_team[id] = 1
	}
	else if(equal(team,"Axis")){
		g_team[id] = 2
	}
	return PLUGIN_CONTINUE
}

public ent_update_spec()
{
	new Players[32]
	new num, i, player
	get_players(Players, num, "bc")//dead, not bot
	for (i=0; i<num; i++)
	{
		player = Players[i]
		if(admin[player])
		{//White Panther http://www.modns.org/forums/index.php?showtopic=2180
			if(entity_get_int(player, EV_INT_iuser1) == 4 || (g_mod == MOD_TS && entity_get_int(player, EV_INT_iuser1) == 1))
				first_person[player] = true
			else
				first_person[player] = false
			spec[player] = entity_get_int(player, EV_INT_iuser2)
		}
	}
}

public client_putinserver(id){
	first_person[id]=false
	if ((get_user_flags(id) & REQUIRED_ADMIN_LEVEL) || get_cvar_num("esp_allow_all")==1){
		admin[id]=true
		init_admin_options(id)
		
		}else{
		admin[id]=false
	}
}

public init_admin_options(id){
	for (new i=0;i<10;i++){
		admin_options[id][i]=true
	}
	admin_options[id][ESP_TEAM_MATES]=false
}

public client_disconnect(id){
	admin[id]=false
}

public change_esp_status(id,bool:on){
	if (on){
		admin_options[id][0]=true
		if (!is_in_menu[id]) client_print(id,print_chat,"[%s] ON",PLUGIN)
		if (is_in_menu[id]) show_esp_menu(id)
	}else{
		admin_options[id][0]=false
		if (!is_in_menu[id]) client_print(id,print_chat,"[%s] OFF",PLUGIN)
		if (is_in_menu[id]) show_esp_menu(id)
	}
}

public client_PreThink(id){
	if (!is_user_connected(id)) return PLUGIN_CONTINUE
	
	new button=get_user_button(id)
	if (button==0) return PLUGIN_CONTINUE // saves a lot of cpu
	
	new oldbutton=get_user_oldbutton(id)
	
	if (button & IN_DUCK){
		ducking[id]=true
		}else{
		ducking[id]=false
	}
	
	if ((get_cvar_num("esp")==1) && (get_cvar_num("esp_disable_default_keys")!=1)){
		if (admin[id]){
			if (first_person[id] && !is_user_alive(id)){
				if ((button & IN_RELOAD) && !(oldbutton & IN_RELOAD)){
					show_esp_menu(id)
				}
				if ((button & IN_FORWARD)  && !(oldbutton & IN_FORWARD) && !admin_options[id][0]){
					change_esp_status(id,true)
				}
				if ((button & IN_BACK)  && !(oldbutton & IN_BACK) && admin_options[id][0]){
					change_esp_status(id,false)
				}
			}
		}
	}
	return PLUGIN_CONTINUE
}

public draw_aim_vector(i,s,len){
	new Float:endpoint[3]
	new tmp[3]
	new Float:vec1[3]
	get_user_origin(s, tmp, 1)
	IVecFVec(tmp,vec1)
	vec1[2]-=6.0
	VelocityByAim(s,len,endpoint) // get aim vector
	addVec(endpoint,vec1) // add origin to get absolute coordinates
	make_TE_BEAMPOINTS(i,4,vec1,endpoint,10,0,255)
	return PLUGIN_CONTINUE
}

public esp_timer(){
	
	if (get_cvar_num("esp")!=1) { // if esp is not 1, it is off
		set_task(1.0,"esp_timer") // check for reactivation in 1 sec intervals
		return PLUGIN_CONTINUE
	}
	
	for (new i=1;i<=max_players;i++){ // loop through players
		
		if (admin_options[i][ESP_ON] && first_person[i] && is_user_connected(i) && admin[i] && (!is_user_alive(i))){ // :)
			
			new spec_id=spec[i]
			if(spec_id == 0) continue;
			new Float:my_origin[3] 
			entity_get_vector(i,EV_VEC_origin,my_origin) // get origin of spectating admin
			new my_team
			my_team=get_team(spec_id) // get team of spectated :)
			
			new Float:smallest_angle=180.0 
			new smallest_id=0
			new Float:xp=2.0,Float:yp=2.0 // x,y of hudmessage
			new Float:dist
			
			for (new s=1;s<=max_players;s++){ // loop through the targets
				if (is_user_alive(s)){ // target must be alive
					new target_team=get_team(s) // get team of target
					if (!(target_team<1)){ //if not spectator
						if (spec_id!=s){ // do not target myself
							// if the target is in the other team and not spectator
							
							if ((my_team!=target_team || admin_options[i][ESP_TEAM_MATES]) && (target_team>0 && target_team<5)){
								
								new Float:target_origin[3]
								// get origin of target
								entity_get_vector(s,EV_VEC_origin,target_origin)
								
								
								// get distance from me to target
								new Float:distance=vector_distance(my_origin,target_origin)
								
								if (admin_options[i][ESP_LINE]){
									
									new width
									if (distance<2040.0){
										// calculate width according to distance
										width=(255-floatround(distance/8.0))/3
										}else{
										width=1
									}	
									// create temp_ent
									make_TE_BEAMENTPOINT(i,target_origin,width,target_team)
								}
								
								
								// get vector from me to target
								new Float:v_middle[3]
								subVec(target_origin,my_origin,v_middle)
								
								// trace from me to target, getting hitpoint
								new Float:v_hitpoint[3]
								trace_line (-1,my_origin,target_origin,v_hitpoint)
								
								// get distance from me to hitpoint (nearest wall)
								new Float:distance_to_hitpoint=vector_distance(my_origin,v_hitpoint)
								
								// scale
								new Float:scaled_bone_len
								if (ducking[spec_id]){
									scaled_bone_len=distance_to_hitpoint/distance*(50.0-18.0)
									}else{
									scaled_bone_len=distance_to_hitpoint/distance*50.0
								}
								scaled_bone_len=distance_to_hitpoint/distance*50.0
								
								new Float:scaled_bone_width=distance_to_hitpoint/distance*150.0
								
								new Float:v_bone_start[3],Float:v_bone_end[3]
								new Float:offset_vector[3]
								// get the point 10.0 units away from wall
								normalize(v_middle,offset_vector,distance_to_hitpoint-10.0) // offset from wall
								
								// set to eye level
								new Float:eye_level[3]
								copyVec(my_origin,eye_level)
								
								if (ducking[spec_id]){
									eye_level[2]+=12.3
									}else{
									eye_level[2]+=17.5
								}
								
								
								addVec(offset_vector,eye_level)
								
								// start and end of green box
								copyVec(offset_vector,v_bone_start)
								copyVec(offset_vector,v_bone_end)
								v_bone_end[2]-=scaled_bone_len
								
								new Float:distance_target_hitpoint=distance-distance_to_hitpoint
								
								new actual_bright=255
								
								if (admin_options[i][ESP_BOX]){
									// this is to make green box darker if distance is larger
									if (distance_target_hitpoint<2040.0){
										actual_bright=(255-floatround(distance_target_hitpoint/12.0))
										
										}else{
										actual_bright=85
									}	
									new color
									if (distance_to_hitpoint!=distance){ // if no line of sight
										color=0
										}else{ // if line of sight
										color=target_team
									}
									
									if (damage_done_to[spec_id]==s) {
										color=3
										damage_done_to[spec_id]=0
									}
									make_TE_BEAMPOINTS(i,color,v_bone_start,v_bone_end,floatround(scaled_bone_width),target_team,actual_bright)
								}
								
								
								if (admin_options[i][ESP_AIM_VEC] || admin_options[i][ESP_NAME] || admin_options[i][ESP_HEALTH_ARMOR] || admin_options[i][ESP_WEAPON] || admin_options[i][ESP_CLIP_AMMO] || admin_options[i][ESP_DISTANCE]){
									
									
									new Float:ret[2]
									new Float:x_angle=get_screen_pos(spec_id,v_middle,ret)
									
									// find target with the smallest distance to crosshair (on x-axis)
									if (smallest_angle>floatabs(x_angle)){
										if (floatabs(x_angle)!=0.0){
											smallest_angle=floatabs(x_angle)
											view_target[spec_id]=s
											smallest_id=s // store nearest target id..
											xp=ret[0] // and x,y coordinates of hudmessage
											yp=ret[1]
											dist=distance
										}
									}
								}
							}
						}
					}
				}
			} // inner player loop end
			if (smallest_id>0 && admin_options[i][ESP_AIM_VEC]){
				draw_aim_vector(i,smallest_id,2000)
			}
			if (xp>0.0 && xp<=1.0 && yp>0.0 && yp<=1.0){ // if in visible range
				// show the player info
				set_hudmessage(255, 255, 0, floatabs(xp), floatabs(yp), 0, 0.0, get_cvar_float("esp_timer"))
				
				new name[37]=""
				new tmp[33]
				get_user_name(smallest_id,tmp,32)
				if (admin_options[i][ESP_NAME]){
					format(name,36,"[%s]^n",tmp)
				}
				
				
				new health[25]=""
				if (admin_options[i][ESP_HEALTH_ARMOR]){
					new hp=get_user_health(smallest_id)
					new armor=get_user_armor(smallest_id)
					format(health,24,"health: %d armor: %d^n",hp,armor)
				}
				
				
				new clip_ammo[22]=""
				new clip,ammo
				new weapon_id=get_user_weapon(smallest_id,clip,ammo)
				if (admin_options[i][ESP_CLIP_AMMO]){
					format(clip_ammo,21,"clip: %d ammo: %d^n",clip,ammo)
				}
				
				new weapon_name[21]=""
				if (admin_options[i][ESP_WEAPON]){
					//if ((weapon_id-1)<0 || (weapon_id-1)>29) weapon_id=1
					//format(weapon_name,20,"weapon: %s^n",weapons[weapon_id-1])
					////copy(weapon_name,9,weapons[weapon_id-1])
					if(weapon_id<0)
						weapon_id=0
					switch(g_mod){
					case MOD_CS:{
					if(weapon_id > CS_WPN_MAX-1) weapon_id = 0
					format(weapon_name,20,"weapon: %s^n",cs_weapons[weapon_id])
					}
					case MOD_DOD:{
					if(weapon_id > DOD_WPN_MAX-1) weapon_id = 0
					format(weapon_name,20,"weapon: %s^n",dod_weapons[weapon_id])
					}
					case MOD_TFC:{
					if(weapon_id > TFC_WPN_MAX-1) weapon_id = 0
					format(weapon_name,20,"weapon: %s^n",tfc_weapons[weapon_id])
					}
					case MOD_NS:{
					if(weapon_id > NS_WPN_MAX-1) weapon_id = 0
					format(weapon_name,20,"weapon: %s^n",ns_weapons[weapon_id])
					}
					case MOD_TS:{
					if(weapon_id > TS_WPN_MAX-1) weapon_id = 0
					format(weapon_name,20,"weapon: %s^n",ts_weapons[weapon_id])
					}
					default:{
					//format(weapon_name,20,"weapon: %s^n",cs_weapons[0])
					}
					}//end switch
					
				}
				
				new str_dist[19]
				if (admin_options[i][ESP_DISTANCE]){
					format(str_dist,18,"distance: %d^n",floatround(dist))
				}
				
				show_hudmessage(i, "%s%s%s%s%s",name,health,weapon_name,clip_ammo,str_dist)
			}
		}
	}
	set_task(get_cvar_float("esp_timer"),"esp_timer") // keep it going
	return PLUGIN_CONTINUE	
}

public Float:get_screen_pos(id,Float:v_me_to_target[3],Float:Ret[2]){
	new Float:v_aim[3]
	VelocityByAim(id,1,v_aim) // get aim vector
	new Float:aim[3]
	copyVec(v_aim,aim) // make backup copy of v_aim
	v_aim[2]=0.0 // project aim vector vertically to x,y plane
	new Float:v_target[3]
	copyVec(v_me_to_target,v_target)
	v_target[2]=0.0 // project target vector vertically to x,y plane
	// both v_aim and v_target are in the x,y plane, so angle can be calculated..
	new Float:x_angle
	new Float:x_pos=get_screen_pos_x(v_target,v_aim,x_angle) // get the x coordinate of hudmessage..
	new Float:y_pos=get_screen_pos_y(v_me_to_target,aim) // get the y coordinate of hudmessage..
	Ret[0]=x_pos 
	Ret[1]=y_pos
	return x_angle
}

public Float:get_screen_pos_x(Float:target[3],Float:aim[3],&Float:xangle){
	new Float:x_angle=floatacos(vectorProduct(aim,target)/(getVecLen(aim)*getVecLen(target)),1) // get angle between vectors
	new Float:x_pos
	//this part is a bit tricky..
	//the problem is that the 'angle between vectors' formula returns always positive values
	//how can be determined if the target vector is on the left or right side of the aim vector? with only positive angles?
	//the solution:
	//the scalar triple product returns the volume of the parallelepiped that is created by three input vectors
	//
	//i used the aim and target vectors as the first two input parameters
	//and the third one is a vector pointing straight upwards [0,0,1]
	//if now the target is on the left side of spectator origin the created parallelepipeds volume is negative 
	//and on the right side positive
	//now we can turn x_angle into a signed value..
	if (scalar_triple_product(aim,target)<0.0) x_angle*=-1 // make signed
	if (x_angle>=-45.0 && x_angle<=45.0){ // if in fov of 90
		x_pos=1.0-(floattan(x_angle,degrees)+1.0)/2.0 // calulate y_pos of hudmessage
		xangle=x_angle
		return x_pos
	}
	xangle=0.0
	return -2.0
}

public Float:get_screen_pos_y(Float:v_target[3],Float:aim[3]){
	new Float:target[3]
	
	// rotate vector about z-axis directly over the direction vector (to get height angle)
	rotateVectorZ(v_target,aim,target)
	
	// get angle between aim vector and target vector
	new Float:y_angle=floatacos(vectorProduct(aim,target)/(getVecLen(aim)*getVecLen(target)),1) // get angle between vectors
	
	new Float:y_pos
	new Float:norm_target[3],Float:norm_aim[3]
	
	// get normalized target and aim vectors
	normalize(v_target,norm_target,1.0)
	normalize(aim,norm_aim,1.0)
	
	//since the 'angle between vectors' formula returns always positive values
	if (norm_target[2]<norm_aim[2]) y_angle*=-1 //make signed
	
	if (y_angle>=-45.0 && y_angle<=45.0){ // if in fov of 90
		y_pos=1.0-(floattan(y_angle,degrees)+1.0)/2.0 // calulate y_pos of hudmessage
		if (y_pos>=0.0 && y_pos<=1.0) return y_pos
	}
	return -2.0
}

public get_team(id){
	switch(g_mod)
	{
		case MOD_CS:{
			new team[2]
			get_user_team(id,team,1)
			switch(team[0]){
			case 'T':{
				return 1
			}
			case 'C':{
				return 2
			}
			case 'S':{
				return 0
			}
			default:{}
			}
		}
		case MOD_DOD:{
			return g_team[id]
		}
		case MOD_TFC:{
			return get_user_team(id)
		}
		case MOD_NS:{
			new temp = get_user_team(id)
			if(temp == 15)
				return 0
			if(temp == 4)
				return 2
			return temp
		}
		case MOD_TS:{
			return get_user_team(id)
		}
		default:{
			return get_user_team(id)
		}
	}
	return 0
}

// Vector Operations -------------------------------------------------------------------------------

public Float:getVecLen(Float:Vec[3]){
	new Float:VecNull[3]={0.0,0.0,0.0}
	new Float:len=vector_distance(Vec,VecNull)
	return len
}

public Float:scalar_triple_product(Float:a[3],Float:b[3]){
	new Float:up[3]={0.0,0.0,1.0}
	new Float:Ret[3]
	Ret[0]=a[1]*b[2]-a[2]*b[1]
	Ret[1]=a[2]*b[0]-a[0]*b[2]
	Ret[2]=a[0]*b[1]-a[1]*b[0]
	return vectorProduct(Ret,up)
}

public normalize(Float:Vec[3],Float:Ret[3],Float:multiplier){
	new Float:len=getVecLen(Vec)
	copyVec(Vec,Ret)
	Ret[0]/=len
	Ret[1]/=len
	Ret[2]/=len
	Ret[0]*=multiplier
	Ret[1]*=multiplier
	Ret[2]*=multiplier
}

public rotateVectorZ(Float:Vec[3],Float:direction[3],Float:Ret[3]){
	// rotates vector about z-axis
	new Float:tmp[3]
	copyVec(Vec,tmp)
	tmp[2]=0.0
	new Float:dest_len=getVecLen(tmp)
	copyVec(direction,tmp)
	tmp[2]=0.0
	new Float:tmp2[3]
	normalize(tmp,tmp2,dest_len)
	tmp2[2]=Vec[2]
	copyVec(tmp2,Ret)
}

public Float:vectorProduct(Float:Vec1[3],Float:Vec2[3]){
	return Vec1[0]*Vec2[0]+Vec1[1]*Vec2[1]+Vec1[2]*Vec2[2]
}

public copyVec(Float:Vec[3],Float:Ret[3]){
	Ret[0]=Vec[0]
	Ret[1]=Vec[1]
	Ret[2]=Vec[2]
}

public subVec(Float:Vec1[3],Float:Vec2[3],Float:Ret[3]){
	Ret[0]=Vec1[0]-Vec2[0]
	Ret[1]=Vec1[1]-Vec2[1]
	Ret[2]=Vec1[2]-Vec2[2]
}

public addVec(Float:Vec1[3],Float:Vec2[3]){
	Vec1[0]+=Vec2[0]
	Vec1[1]+=Vec2[1]
	Vec1[2]+=Vec2[2]
}

// Temporary Entities ------------------------------------------------------------------------------
// there is a list of much more temp entities at: http://djeyl.net/forum/index.php?s=80ec5b9163006b5cbd0a51dd198e563a&act=Attach&type=post&id=290870
// all messages are sent with MSG_ONE_UNRELIABLE flag to avoid overflow in case of very low esp_timer setting and much targets

public make_TE_BEAMPOINTS(id,color,Float:Vec1[3],Float:Vec2[3],width,target_team,brightness){
	message_begin(MSG_ONE_UNRELIABLE ,SVC_TEMPENTITY,{0,0,0},id) //message begin
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
	write_byte(floatround(get_cvar_float("esp_timer")*10)) // life in 0.1's
	write_byte(width) // line width in 0.1's
	write_byte(0) // noise amplitude in 0.01's
	write_byte(esp_colors[color][0])
	write_byte(esp_colors[color][1])
	write_byte(esp_colors[color][2])
	write_byte(brightness) // brightness)
	write_byte(0) // scroll speed in 0.1's
	message_end()
}

public make_TE_BEAMENTPOINT(id,Float:target_origin[3],width,target_team){
	message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,{0,0,0},id)
	write_byte(1)
	write_short(id)
	write_coord(floatround(target_origin[0]))
	write_coord(floatround(target_origin[1]))
	write_coord(floatround(target_origin[2]))
	write_short(laser)
	write_byte(1)		
	write_byte(1)
	write_byte(floatround(get_cvar_float("esp_timer")*10))
	write_byte(width)
	write_byte(0)
	write_byte(team_colors[target_team][0])
	write_byte(team_colors[target_team][1])
	write_byte(team_colors[target_team][2])
	write_byte(255)
	write_byte(0)
	message_end()
}
