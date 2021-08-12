/* DoD Damage Infliction Mod

"While I am not a part of a real realism DoD unit, I do have a desire to strive for a bit more 
realism in the game. The main premise of this plugin is to introduce "pain" and physical body 
damage..." =|[76AD]|= TatsuSaisei


CREDITS: Codes and examples, tutorials, and advisement

diamond-optic (AMXX DOD TEAM)
1. dod_shellshock - http://www.dodplugins.net/forums/showthread.php?t=56
2. dod_follow_the_wounded - http://www.dodplugins.net/forums/showthread.php?t=94
3. DoD Stamina Tutorial - http://www.dodplugins.net/forums/showthread.php?t=46

Wilson [29th ID] (AMXX DOD TEAM)
1. dod_mortar_class - http://www.dodplugins.net/forums/showthread.php?t=110

DESCRIPTION:

* If you manage to survive any head damage in the game you are screwed unless you are healed. A
players vision becomes heavily distorted and renders the player useless though alive.

* If you sustain too much damage to an arm, you will be unable to utilize a primary weapon and 
are forced to use "lighter" weapons until you are healed or die.

* If you sustain too much damage to your legs, you will be unable to "stand" up and will be forced
to "crouch" until you are healed or die.

* If during the course of war you are simply damaged, the weapon used to hurt you and the amount of
damage sustained determines "effects" upon the physical body..
a. Primary is the player stamina level, specifically the maximum allowed will be reduced as you are 
damaged... getting hurt in the stomach or chest will have the greatest impact on stamina.
b. Shellshock effect (courtesy of diamond-optic) has been included and occurs with grenade, mortar, 
and rifle butt damage. With the exception of butt damage which will generally force a player to go
"crouch" grenade and mortar damage will cause a player to fall "prone also, if a player happens 
to have a weapon deployed they will undeploy and drop their weapon and extra ammo.
c. Simple world damage, or falling from heights will also have adverse effects on a player.

* Currently testing a free life function, if a player is crouching, deployed, or prone, they will
slowly regenerate their health and stamina max is slowly increased. This will obviously have to be
adjusted to limit amount of health a player can receive and what body parts may become "healed"
Currently the free life function will "repair" broken arms or legs once a players health returns
to max life regen amount, but at the cost of 10 health for each healing... head trauma is NOT
"healed" through automation

* MedKits obtained can heal all damage done to a player e.g. Broken Leg or Arm and Head Trauma. 
requires the use of a secondary plugin

INSTRUCTIONS:
* Say Commands:
say /damagemod - Display MOTD

* Cvars:
dod_enable_damagemod "1" - enables/disables the whole mod
dod_enable_shellshock_snd "1" - enables/disables the shellshock sound
dod_leg_dmg_stamina "40" - amount subtracted from max stamina
dod_arm_dmg_stamina "15" - amount subtracted from max stamina
dod_body_dmg_stamina "55" - amount subtracted from max stamina
dod_head_dmg_stamina "25" - amount subtracted from max stamina
dod_dmg_hp_equals_stamina "10" - minimum hp when stamina max will = hp
dod_leg_dmg_break "35" - amount of damage needed to break legs
dod_arm_dmg_break "50" - amount of damage needed to break arms
dod_fall_dmg_drop "5" - amount of damage needed to cause primary weapon to drop if held
dod_headdmg_fade_red "200" - head damage fade red
dod_headdmg_fade_green "0" - head damage fade green
dod_headdmg_fade_blue "0" - head damage fade blue
dod_headdmg_fade_alpha "176" - head damage fade alpha
dod_dmg_freehealth "1" - enables/disable free auto health
dod_dmg_freehealth_time "3" - number of seconds and one health will be applied if crouching/deployed or 2 health if prone
dod_dmg_freehealth_max "100" - maximum limit before free health stops giving
dod_dmg_ftw "1" - enable/disable follow the wounded effect
dod_dmg_ftw_health "35" - under what health should footsteps show
dod_motd_msg_enable "1" - enable/disable MOTD auto message
dod_motd_msg_time "600" - amount of time in seconds between each showing of message about damage mod MOTD
dod_motd_msg_where "1" - 0 = center 1 = lower left

VERSION INFO:
76.0 10/2006
* Plugin Inception
* Utilized custom models to distinguish Medic from other players

76.1 12/2006
* Removed custom model support
* Cleaned up alot of code
* Added description and author comments

76.2 12/24/2006
* Public Plugin release

76.3 12/25/2006 - MERRY CHRISTMAS !!
* Cleaned up some misc. poor coding
* Changed broken leg behavior to allow player to go prone as desired. Not entirely as I wanted it, since
I am unable to hook the user pressing prone yet (Zor will get corrected in future dodx AMXX update)
in the meantime the work around is as follows: If legs are broken user must hold down jump button
until they go prone OR may hit their scoreboard button (TAB by default) I did not want to use this
button but could not find a suitable alternative.

76.4 12/26/2006
* Added Cvar to control primary weapon dropping on fall damage
* Added Cvars for auto message time and placement and enable/disable (show say/damagemod)

76.5 1/13/07
* Corrected minor errors that would occur if a player left game prematurely
* Corrected query_client_cvar issue by changing client_putinserver to client_connect
* Fixed some meddlesome AMXX Studio behaviors e.g. )// made for a bad combination.. indenter NEEDS a space there ) //
* Added option to turn on/off shellshock ringing sound (thanx HellsBattleMoose for suggestion to add)

76.6 2/7/07
* Completely removed medic code, although support IS enabled for my standalone medic plugin
* If the dod_medic_class.amxx plugin is used it MUST be listed after this plugin in plugins.ini !!


KNOWN ISSUES:
MINOR: Occasionally the plugin is unable to properly grab a players volume cvar and must be forced at a 
level of 1.0 which has not caused any complaints yet.

MINOR: First time users tend to complain alot as this plugin drastically changes the game we were all used
to. Alot of comments and questions will arise about the dropping of the gun, the ringing sound, not
being able to stand, etc... I plan to incorporate a MOTD soon that will help alleviate this issue
and serve to explain what the plugin does.

THINGS I WANT TO DO/ADD:
* Add text notification of leg/arm/head condition on the HUD
* Add some sort of graphical notification of leg/arm/head condition on the HUD without having to use text


AUTHOR INFO:
Joseph Meyers AKA =|[76AD]|= TatsuSaisei - 76th Airborne Division RANK: General of the Army
http://76AD.com
http://TatsuSaisei.com
http://JosephMeyers.com
http://CustomDoD.com
*/
#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>
#include <dodfun>
#include <dodx>
#include <fun> 

#pragma semicolon 1
#pragma ctrlchar '\'


#define PLUGIN "DoD Damage Infliction Mod"
#define VERSION "76.6"
#define AUTHOR "=|[76AD]|= TatsuSaisei"

#define PA_LOW  25.0
#define PA_HIGH 45.0
#define RINGSOUND "sound/misc/shellshock_ring_3.mp3"//ring sound fx file

//global declarations
new cvar_damagemod_enable, msg_where, msg_time, msg_enable, scoreboard_prone, jump_prone;
new cvar_leg_broke, cvar_arm_broke, cvar_falldrop_dmg;

//new cvar_leg_speed, cvar_body_speed
new cvar_leg_stamina, cvar_min_dmg_stamina, cvar_arm_stamina, cvar_body_stamina, cvar_head_stamina;
new cvar_head_dmg_fade_red, cvar_head_dmg_fade_green, cvar_head_dmg_fade_blue, cvar_head_dmg_fade_alpha;

//shellshock - diamond-optic
new cvar_shellshock_snd;
new gMsgScreenShake , gMsgScreenFade;
new Float:player_norm_mp3_vol[33];
new Float:player_norm_vol[33];

//follow the wounded - diamond-optic
new cvar_ftw, cvar_ftw_health;
new decals[2] = {120,121};
new bool:g_isDying[33];
new g_decalSwitch[33];

//global arrays
new stamina_max[33];

//global booleans
new bool:brokenleg[33] = false,bool: brokenarm[33] = false, bool:brained[33] = false;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_cvar("dod_damage_mod", "version: 76.6 by: =|[76AD]|= TatsuSaisei", FCVAR_SERVER|FCVAR_SPONLY);
	register_cvar("dod_shellshock_stats", "Custom code provided by: diamond-optic", FCVAR_SERVER|FCVAR_SPONLY);
	register_cvar("dod_follow_the_wounded_stats", "Custom code provided by: diamond-optic", FCVAR_SERVER|FCVAR_SPONLY);
	register_event("ResetHUD", "set_normal", "be");
	register_event("CurWeapon", "check_body","be");
	register_forward(FM_PlayerPreThink, "PlayerPreThink");
	
	register_statsfwd(XMF_DAMAGE);
	register_statsfwd(XMF_DEATH);
	
	register_clcmd("say /damagemod","show_dmg_motd");
	
	//shellshock effect - diamond-optic
	gMsgScreenShake = get_user_msgid("ScreenShake");
	gMsgScreenFade = get_user_msgid("ScreenFade");
	
	// CVARS for amxx.cfg
	cvar_damagemod_enable = register_cvar("dod_enable_damagemod", "1");//enables/disables the whole mod
	
	cvar_shellshock_snd = register_cvar("dod_enable_shellshock_snd", "1");//enables/disables the shellshock sound
	
	cvar_leg_stamina = register_cvar("dod_leg_dmg_stamina", "40");//amount subtracted from max stamina
	cvar_arm_stamina = register_cvar("dod_arm_dmg_stamina", "15");//amount subtracted from max stamina
	cvar_body_stamina = register_cvar("dod_body_dmg_stamina", "55");//amount subtracted from max stamina
	cvar_head_stamina = register_cvar("dod_head_dmg_stamina", "25");//amount subtracted from max stamina
	
	cvar_min_dmg_stamina = register_cvar("dod_dmg_hp_equals_stamina","10");//minimum hp when stamina max will = hp
	
	cvar_leg_broke = register_cvar("dod_leg_dmg_break", "35");//amount of damage needed to break legs
	cvar_arm_broke = register_cvar("dod_arm_dmg_break", "50");//amount of damage needed to break arms
	cvar_falldrop_dmg = register_cvar("dod_fall_dmg_drop", "5");//amount of damage needed to cause primary weapon to drop if held
	
	cvar_head_dmg_fade_red = register_cvar("dod_headdmg_fade_red","200");//headdamage fade red
	cvar_head_dmg_fade_green = register_cvar("dod_headdmg_fade_green","0");//headdamage fade green
	cvar_head_dmg_fade_blue = register_cvar("dod_headdmg_fade_blue","0");//headdamage fade blue
	cvar_head_dmg_fade_alpha = register_cvar("dod_headdmg_fade_alpha","176");//headdamage fade alpha
	
	cvar_ftw = register_cvar("dod_dmg_ftw", "1");//enable/disable follow the wounded effect
	cvar_ftw_health = register_cvar("dod_dmg_ftw_health", "35");//under what health should footsteps show
	
	msg_enable = register_cvar("dod_motd_msg_enable", "1");//enable/disable MOTD auto message
	msg_time = register_cvar("dod_motd_msg_time", "600");//amount of time in seconds between each showing of message about damage mod MOTD
	msg_where = register_cvar("dod_motd_msg_where", "1");//0 = center 1 = lower left
	
	scoreboard_prone = register_cvar("dod_dmg_sbtoprone", "0");//enable/disable the use of the scoreboard button to allow a player to go prone if they have broken legs
	jump_prone = register_cvar("dod_dmg_jumptoprone", "1");//enable/disable the use of the jump button to allow a player to go prone if they have broken legs
	
	set_task(15.0,"dmg_motd_help");
}

public dmg_motd_help()
{
	if(get_pcvar_num(msg_enable))
	{
		switch(get_pcvar_num(msg_where))
		{
			case 0: client_print(0, print_center, "%s (version: %s) by %s  | say /damagemod for more info and help" ,PLUGIN, VERSION, AUTHOR);
				case 1: client_print(0, print_chat, "%s (version: %s) by %s  | say /damagemod for more info and help" ,PLUGIN, VERSION, AUTHOR);
			}
		set_task(get_pcvar_float(msg_time),"dmg_motd_help");
	}
	return PLUGIN_CONTINUE;	
}

public client_connect(id) 
{ 
	if (!is_user_bot(id) && is_user_connected(id)) 
	{
		query_client_cvar(id, "MP3Volume", "mp3_remember");
		query_client_cvar(id, "volume", "vol_remember");
	}
	g_isDying[id] = false;
	if(task_exists(4247545+id)) remove_task(4247545+id);
	return PLUGIN_CONTINUE;
	
} 

public mp3_remember(id, const cvar[], const value[]) 
{ 
	if(str_to_float(value) == 0.0)
	{
		player_norm_mp3_vol[id] = 1.0;
	}
	else player_norm_mp3_vol[id] = str_to_float(value);
	return PLUGIN_CONTINUE;
} 

public vol_remember(id, const cvar[], const value[]) 
{ 
	if(str_to_float(value) == 0.0)
	{
		player_norm_vol[id] = 1.0;
	}
	else player_norm_vol[id] = str_to_float(value);
	return PLUGIN_CONTINUE;
}

public show_dmg_motd(id)
{
	show_motd(id,"<body bgcolor=\"#000000\"><iframe src=\"http://customdod.com/amxx_plugins/motds/dod_damagemod.html\" width=\"100%\" height=\"5000\" align=\"center\" border=\"0\" frameborder=\"0\" marginwidth=\"1\" marginheight=\"1\" name=\"motd76AD\" scrolling=\"no\"></iframe></body>","DoD Damage Mod");
	return PLUGIN_HANDLED;
}

public plugin_precache() 
{ 
	precache_generic(RINGSOUND);
	return PLUGIN_CONTINUE ;
} 

public dod_client_spawn(id)
{
	if(!is_user_bot(id) && get_pcvar_num(cvar_damagemod_enable))
	{
		set_normal(id);
	}
	return PLUGIN_CONTINUE;
}

public dod_client_changeclass(id, class, oldclass)
{
	if (!is_user_bot(id) && is_user_connected(id)) 
	{
		set_normal(id);
	}
	return PLUGIN_CONTINUE;
}

public dod_client_changeteam(id, team, oldteam)
{
	if (!is_user_bot(id) && is_user_connected(id)) 
	{
		set_normal(id);
	}
	return PLUGIN_CONTINUE;
}

public check_body(id)
{
	if(get_pcvar_num(cvar_damagemod_enable))
	{
		if(brokenarm[id])
		{
			client_cmd(id , "hud_fastswitch 1");
			client_cmd(id , "slot3");
			client_cmd(id , "drop");
		}
		if(brained[id])
		{
			client_cmd(id , "gl_ztrick 1");
		}
	}
	return PLUGIN_CONTINUE;
}

public PlayerPreThink(id)
{
	if(!is_user_alive(id) || is_user_bot(id)) return FMRES_HANDLED;//if player is not alive, dont waste resources
	if(get_pcvar_num(cvar_damagemod_enable))
	{
		if(brokenleg[id])
		{
			if(pev(id,pev_button) & IN_SCORE && get_pcvar_num(scoreboard_prone) || pev(id,pev_button) & IN_JUMP && get_pcvar_num(jump_prone))
			{
				client_cmd(id , "-duck");
				client_cmd(id , "prone");
				return FMRES_HANDLED;
			}
			else
			{
				client_cmd(id , "+duck");
			}
		}
	}
	return FMRES_HANDLED;
}

public client_death(killer,victim,wpnindex,hitplace, TK)
{
	if(get_pcvar_num(cvar_damagemod_enable))
	{
		new aname[32] ,vname[32] ;
		get_user_name(killer,aname,31) ;
		get_user_name(victim,vname,31) ;
		new bodypart[128];
		switch(hitplace)
		{
			case HIT_CHEST: bodypart = "chest";
				case HIT_HEAD: bodypart = "head";
				case HIT_LEFTARM: bodypart = "left arm";
				case HIT_LEFTLEG: bodypart = "left leg";
				case HIT_RIGHTARM: bodypart = "right arm";
				case HIT_RIGHTLEG: bodypart = "right leg";
				case HIT_STOMACH: bodypart = "stomach";
				case HIT_GENERIC: bodypart = "body";
			}
		if (killer == victim)
		{
			client_print(victim,print_chat,"You have hurt your %s and killed yourself!! Take better care of yourself Soldier !!",bodypart);
		}
		else
		{
			client_print(victim,print_chat,"%s attacked your %s and killed you!!",aname,bodypart);
			client_print(killer,print_chat,"You attacked %s in the %s and killed them!!",vname,bodypart);
		}
	}
	if(g_isDying[victim])
	{
		g_isDying[victim] = false;
		remove_task(4247545+victim);
	}
	return PLUGIN_CONTINUE;
}

public set_normal(id)
{
	if(is_user_alive(id))
	{
		volume_up_max(id);
		brokenleg[id] = false;
		brokenarm[id] = false;
		brained[id] = false;
		stamina_max[id] = 100;
		dod_set_stamina(id,STAMINA_SET,0,100);
		set_user_health(id,100);
		client_cmd(id , "-duck");
		//release trippy effect
		client_cmd(id , "gl_ztrick 0");
		if(g_isDying[id])
		{
			g_isDying[id] = false;
			remove_task(4247545+id);
		}
	}
	return PLUGIN_CONTINUE;
}

public pfn_touch (ptr, ptd)
{
	
	if(!is_user_alive(ptd)||ptr  == 0||!is_valid_ent(ptr)||!is_valid_ent(ptd)) return PLUGIN_CONTINUE;
	new classname[32];
	entity_get_string(ptr,EV_SZ_classname,classname,31);
	if(strfind(classname,"MedKit",0)>=0)
	{
		new namek[32],namev[32],authidk[35],authidv[35],teamk[32],teamv[32];
		new owner = entity_get_edict (ptr,EV_ENT_owner);
		new score = dod_get_user_score(owner);
		get_user_team(ptd,teamv,31);
		get_user_team(owner,teamk,31);
		get_user_name(ptd,namev,31);
		get_user_name(owner,namek,31);
		get_user_authid(ptd,authidv,34);
		get_user_authid(owner,authidk,34);
		if(brained[ptd])
		{
			show_hudmessage(ptd, "Your Head Trauma was healed by MEDIC: %s",namek);
			show_hudmessage(owner, "You healed %s Head Trauma",namev);
			brained[ptd] = false;
			client_cmd(ptd , "gl_ztrick 0");
			dod_set_user_score(owner,score + 5,1);
		}
		else if(brokenleg[ptd])
		{
			set_hudmessage(255, 0, 255, -1.0, 0.85, 0, 6.0, 9.0);
			show_hudmessage(ptd, "Your broken legs were healed by MEDIC: %s",namek);
			show_hudmessage(owner, "You healed %s broken legs",namev);
			brokenleg[ptd] = false;
			client_cmd(ptd , "-duck");
			dod_set_user_score(owner,score + 3,1);
		}
		else if(brokenarm[ptd])
		{
			set_hudmessage(0, 255, 255, -1.0, 0.85, 0, 6.0, 9.0);
			show_hudmessage(ptd, "Your broken arms were healed by MEDIC: %s",namek);
			show_hudmessage(owner, "You healed %s broken arms",namev);
			brokenarm[ptd] = false;
			dod_set_user_score(owner,score + 1,1);
		}
	}
	//thought maybe to be rid of weapon that a player wanted to pickup and has broken arms...
	//if(brokenarm[ptd] && strfind(classname,"weapon",0)>=0) remove_entity(ptr);
	return PLUGIN_CONTINUE;
}

public volume_up_1(id) 
{
	client_cmd(id , "volume 0.0");
	client_cmd(id , "MP3Volume 2.0");
	set_task(1.5 , "volume_up_2" , id);
}

public volume_up_2(id) 
{
	client_cmd(id , "MP3Volume 1.9");
	set_task(2.5 , "volume_up_3" , id);
}

public volume_up_3(id) 
{
	client_cmd(id , "MP3Volume 1.8");
	set_task(2.0 , "volume_up_4" , id);
}

public volume_up_4(id) 
{
	client_cmd(id , "MP3Volume 1.7");
	set_task(1.5 , "volume_up_5" , id);
}

public volume_up_5(id) 
{
	client_cmd(id , "volume 0.2");
	client_cmd(id , "MP3Volume 1.6");
	set_task(1.5 , "volume_up_6" , id);
}

public volume_up_6(id) 
{
	client_cmd(id , "volume 0.4");
	client_cmd(id , "MP3Volume 1.5");
	set_task(1.5 , "volume_up_7" , id);
}

public volume_up_7(id) 
{
	client_cmd(id , "volume 0.6");
	client_cmd(id , "MP3Volume 1.4");
	set_task(1.5 , "volume_up_8" , id);
}

public volume_up_8(id) 
{
	client_cmd(id , "volume 0.7");
	client_cmd(id , "MP3Volume 1.3");
	set_task(1.5 , "volume_up_9" , id);
}

public volume_up_9(id) 
{
	client_cmd(id , "volume 0.8");
	client_cmd(id , "MP3Volume 1.2");
	set_task(1.5 , "volume_up_10" , id);
}

public volume_up_10(id) 
{
	client_cmd(id , "volume 0.9");
	client_cmd(id , "MP3Volume 1.1");
	set_task(1.5 , "volume_up_max" , id);
}

public volume_up_max(id) 
{
	if(player_norm_mp3_vol[id] == 0)
	{
		player_norm_mp3_vol[id] = 1.0;
	}
	if(player_norm_vol[id] == 0)
	{
		player_norm_vol[id] = 1.0;
	}
	client_cmd(id , "volume %f",player_norm_vol[id]);
	client_cmd(id , "MP3Volume %f",player_norm_mp3_vol[id]);
}


public make_footsteps(param[])
{
	new id = param[0];
	if(!is_user_alive(id) || get_pcvar_num(cvar_ftw) == 0 || get_user_speed(id) < 120) return PLUGIN_CONTINUE;
	new origin[3];
	get_user_origin(id, origin);
	
	if(pev(id, pev_bInDuck) == 1) origin[2] -= 18;
	else origin[2] -= 36;
	new Float:velocity[3];
	new Float:ent_angles[3];
	new Float:ent_origin[3];
	
	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	
	pev(id, pev_v_angle, ent_angles);
	pev(id, pev_origin, ent_origin);
	
	if(ent > 0)
	{
		ent_angles[0] = 0.0;  //tried changing to 180
		if(g_decalSwitch[id] == 0) ent_angles[1] -= 90;
		else ent_angles[1] += 90;
		set_pev(ent, pev_origin, ent_origin);
		set_pev(ent, pev_v_angle, ent_angles);
		velocity_by_aim(ent, 12, velocity);
		
		engfunc(EngFunc_RemoveEntity, ent);
	}
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, origin);
	write_byte(116);
	write_coord(origin[0] + floatround(velocity[0]));
	write_coord(origin[1] + floatround(velocity[1]));
	write_coord(origin[2]);
	write_byte(decals[g_decalSwitch[id]]);
	// color code here ??
	message_end();
	g_decalSwitch[id] = 1 - g_decalSwitch[id];
	return PLUGIN_CONTINUE;
}

stock get_user_speed(id)	//stock from fakemeta_util by VEN
{		
	new Float:Vel[3];
	pev(id, pev_velocity, Vel);
	
	return floatround(vector_length(Vel));
}

//The pudding in the pop....
//bulk of the effects are dealt within the following code.................................................................................................................................................
//
//
public client_damage(attacker, victim, damage, wpnindex, hitplace, TA)
{	
	if(is_user_connected(victim) && !is_user_bot(victim) && get_pcvar_num(cvar_damagemod_enable))
	{
		new bodypart[128];
		new Float:stamina = 0.0 ;
		set_pev(victim, pev_fuser4, stamina);
		switch(hitplace) 
		{
			case 0:
			{
				// damage from grenade/rocket/mortar/world (fall)
				bodypart = "body";
				stamina_max[victim] -= damage;
				switch(wpnindex) 
				{
					case DODW_HANDGRENADE, DODW_HANDGRENADE_EX, DODW_STICKGRENADE, DODW_STICKGRENADE_EX, DODW_MILLS_BOMB, DODW_MORTAR,DODW_BAZOOKA, DODW_PIAT, DODW_PANZERSCHRECK:
					{
						client_cmd(victim , "-duck");
						client_cmd(victim , "prone");
					}
				}
				if(damage > get_pcvar_num(cvar_leg_broke) || get_user_health(victim) < 50 && !brokenleg[victim])
				{
					brokenleg[victim] = true;
				}
				if(damage > get_pcvar_num(cvar_falldrop_dmg))
				{
					//drop commands
					client_cmd(victim , "+attack2");
					client_cmd(victim , "-attack2");
					client_cmd(victim , "drop");
				}
				client_cmd(victim , "dropammo");
				client_cmd(victim , "dropobject");

			}	
			case 1:
			{
				//head
				bodypart = "head";
				
				if(damage>35) //trippy effect
				{
					client_cmd(victim , "gl_ztrick 1");
					brained[victim] = true;
				}
				stamina_max[victim] -= get_pcvar_num(cvar_head_stamina);
				new DamageFade = get_user_msgid("ScreenFade");
				if(DamageFade>0)
				{
					message_begin(MSG_ONE_UNRELIABLE,DamageFade,{0,0,0},victim);
					write_short( ~0 );//1<<13
					write_short(8000);//1<<12
					write_short(0x0002);//1<<12
					write_byte(get_pcvar_num(cvar_head_dmg_fade_red));
					write_byte(get_pcvar_num(cvar_head_dmg_fade_blue));
					write_byte(get_pcvar_num(cvar_head_dmg_fade_green));
					write_byte(get_pcvar_num(cvar_head_dmg_fade_alpha));
					message_end();
				}
				
				//drop commands
				client_cmd(victim , "+attack2");
				client_cmd(victim , "-attack2");
				client_cmd(victim , "dropammo");
				client_cmd(victim , "drop");
			}
			case 2,3:
			{
				//chest 2, stomach 3
				if(wpnindex == 2) bodypart = "chest";
				else bodypart = "stomach";
				stamina_max[victim] -= get_pcvar_num(cvar_body_stamina);
				switch(wpnindex) 
				{
					case DODW_AMERKNIFE,DODW_GERKNIFE,DODW_SPADE,DODW_BRITKNIFE,DODW_KAR_BAYONET,DODW_ENFIELD_BAYONET,DODW_GARAND_BUTT,DODW_K43_BUTT:
					{
						client_cmd(victim , "+attack2");
						client_cmd(victim , "-attack2");
						brokenleg[victim] = true;
					}
				}
			}
			case 4,5:
			{
				// arm
				bodypart = "arm";
				if(damage>get_pcvar_num(cvar_arm_broke)||get_user_health(victim)<30)
				{
					brokenarm[victim] = true;
				}
				stamina_max[victim] -= get_pcvar_num(cvar_arm_stamina);
				
				
				//drop commands
				client_cmd(victim , "hud_fastswitch 1");
				client_cmd(victim , "slot3");
				client_cmd(victim , "drop");
			}
			case 6,7:
			{
				// leg - does NOT include fall damage, that is covered in "body"
				bodypart = "leg";
				client_cmd(victim , "+attack2");
				client_cmd(victim , "-attack2");
				if(damage>get_pcvar_num(cvar_leg_broke))
				{
					brokenleg[victim] = true;
				}
				stamina_max[victim] -= get_pcvar_num(cvar_leg_stamina);
				if(stamina_max[victim]<1) stamina_max[victim] = 1;
				switch(wpnindex) 
				{
					case DODW_AMERKNIFE,DODW_GERKNIFE,DODW_SPADE,DODW_BRITKNIFE,DODW_KAR_BAYONET,DODW_ENFIELD_BAYONET,DODW_GARAND_BUTT,DODW_K43_BUTT,DODW_HANDGRENADE,DODW_HANDGRENADE_EX,DODW_STICKGRENADE,DODW_STICKGRENADE_EX,DODW_MILLS_BOMB,DODW_MORTAR,DODW_BAZOOKA, DODW_PIAT,DODW_PANZERSCHRECK:
					{
						client_cmd(victim , "+attack2");
						client_cmd(victim , "-attack2");
						client_cmd(victim , "-duck");
						client_cmd(victim , "prone");
					}
				}
				//drop commands
				client_cmd(victim , "dropammo");
			}
		}
		new aname[32] ,vname[32] ;
		get_user_name(attacker,aname,31);
		get_user_name(victim,vname,31);
		if (attacker == victim)
		{
			client_print(victim,print_chat,"You have hurt your %s for %d dmg !! Take better care of yourself Soldier !!",bodypart,damage);
		}
		else
		{
			client_print(victim,print_chat,"%s attacked your %s for %d dmg !!",aname,bodypart,damage);
			client_print(attacker,print_chat,"You attacked %s for %d dmg in the %s !!",vname,damage,bodypart);
		}
	}
	if(stamina_max[victim]<1)
	{
		stamina_max[victim] = 1;
	}
	if(is_user_alive(victim)) dod_set_stamina(victim,STAMINA_SET,_, stamina_max[victim] );
	new playerhealth = get_user_health(victim);
	if(playerhealth > 0 && playerhealth < get_pcvar_num(cvar_min_dmg_stamina)) 
	{
		dod_set_stamina(victim,STAMINA_SET,_,playerhealth );
	}
	if(wpnindex==DODW_MILLS_BOMB||wpnindex==DODW_HANDGRENADE||wpnindex==DODW_HANDGRENADE_EX||wpnindex==DODW_STICKGRENADE||wpnindex==DODW_STICKGRENADE_EX||wpnindex == DODW_PIAT||wpnindex==DODW_BAZOOKA||wpnindex==DODW_MORTAR||wpnindex==DODW_PANZERSCHRECK||wpnindex==DODW_GARAND_BUTT||wpnindex==DODW_K43_BUTT)
	{
		client_cmd(victim , "hud_fastswitch 1");
		client_cmd(victim , "slot3");
		client_cmd(victim , "drop");
		client_cmd(victim , "dropammo");
		client_cmd(victim , "dropobject");
		client_cmd(victim , "volume 2");
		client_cmd(victim , "MP3Volume 1");
		if(get_pcvar_num(cvar_shellshock_snd))
		{
			client_cmd(victim,"mp3 play %s",RINGSOUND);
		}
		set_task(0.6 , "volume_up_1" , victim);
		new Float:fVec[3];
		fVec[0] = random_float(PA_LOW , PA_HIGH);
		fVec[1] = random_float(PA_LOW , PA_HIGH);
		fVec[2] = random_float(PA_LOW , PA_HIGH);
		entity_set_vector(victim , EV_VEC_punchangle , fVec);
		
		message_begin(MSG_ONE_UNRELIABLE , gMsgScreenShake , {0,0,0} ,victim);
		write_short( 1<<12 );
		write_short( 1<<12 );
		write_short( 1<<12 );
		message_end();
		
		message_begin(MSG_ONE_UNRELIABLE , gMsgScreenFade , {0,0,0} , victim);
		write_short( 1<<13 );
		write_short( 1<<12 );
		write_short( 1<<12 );
		write_byte( 76 );
		write_byte( 0 );
		write_byte( 0 );
		write_byte( 255 );
		message_end();
	}
	if(!get_cvar_num("ftw_active")) return PLUGIN_CONTINUE;
	
	if(!g_isDying[victim] && is_user_alive(victim) && playerhealth <= get_pcvar_num(cvar_ftw_health))
	{
		g_isDying[victim] = true;
		g_decalSwitch[victim] = 0;
		new param[1];
		param[0] = victim;
		set_task(0.2, "make_footsteps", 4247545+victim, param, 1, "b");
	}
	return PLUGIN_CONTINUE;
	
}
