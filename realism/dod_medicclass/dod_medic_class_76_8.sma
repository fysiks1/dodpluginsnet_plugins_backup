/* DoD_Medic_Class

"It was requested that code I used to "create" a medic class be seperated from the damage mod plugin... here it is..." 
~ =|[76AD]|= TatsuSaisei

"The main objective of the medic is to get the wounded away from the front lines. Many times this 
involves the medic climbing out from the protection of his sandbags during open assault or into no-
man’s-land to help a fallen comrade. Once with the wounded soldier, the medic would do a brief examination, 
evaluate the wound, apply a MedKit if necessary, sometimes inject a vial of morphine. Then he would 
drag or carry the patient out of harms way and to the rear*. This was many times done under enemy 
fire or artillery shelling. In most cases, the enemy respects the Red Cross armband."


DESCRIPTION:
* This is a medic class. The medic comes equip with MedKits and Syringes. The main ability a medic has is the ability
to heal their teammates automatically, just by simply being near them. The MedKits can be used to provide "chunks" of health
and are also recognized by my Damage Mod (will heal broken legs/arms head trauma) The syringes are used to provide
a temporary stamina boost (at the cost of some health) allowing a soldier to run faster and longer. A medics inventory 
will display when a medic tries to become a medic while they are a medic, or when ever they "drop" an item. Dropping an item
is as simple as using the secondary fire button while having the pistol or knife currently selected.

INSTRUCTIONS:

X. IF necessary compile source code (dod_medic_class.sma) into an actual pluginf ile (dod_medic_class.amxx)
*1. Install plugin (dod_medic_class.amxx) into amxmodx/plugins folder on the game server
*2. Install language file (dod_medic_class.txt) into amxmodx/data/lang folder on the game server
3. IF desired, put in custom settings for cvars in the amxx.cfg file located in amxmodx/config folder
4. IF you are updating from a previous version it is highly suggested that you do a complete server reboot
5. Add any custom language translation to the dod_medic_class.txt file and send me a copy of your translation to TatsuSaisei@76AD.com  ;P

* Say Commands:
say_team /medic - Call for medic (recommended as enemy will not see but can hear...)
say /medic - Call for medic (ALL will see text displayed)
say /bemedic - Change to Medic Class
say /medichelp - Show Medic Help Page

* Console Commands:
class_medic - Change to Medic Class
voice_medic - Call out for a Medic

* Cvars:
mp_limitaxismedic "3" - Axis Medic Class Limits
mp_limitalliedmedic "3" - Allied Medic Class Limits
dod_enable_medic "1" - enables/disables medic class
dod_enable_medic_stats "1" - enables/disables medic class stats logging
dod_enable_medic_strip "1" - enables/disables medic ability to pickup primary weapons (1 = strip and remove)
dod_enable_medic_menu "1" - enables/disables medic menu to allow players an easier interface at becoming a medic (will occur at Round Start or Player Spawn - normal rules still apply)

dod_medic_healhp "10" - how much hp a medic can give to a player
dod_medic_kits "10" - how many medkits a medic gets per life
dod_medic_kits_life "30.0" - amount of seconds a medkit will exist in the world if a player has not touched it
dod_medic_spawn_distance "256" - distance a player must be within their spawn location to make the change to a Medic
dod_medic_minhp "100"-  how much hp a player must have to become a medic (discourages coming back to spawn to get free health benefits)

dod_medic_syringes "3" - how many syringes a medic gets per life
dod_medic_boost_amt "25" - how much stamina boost a medic can give to a player
dod_medic_boost_duration "10.0" - amount of seconds a player will be "boosted"
dod_medic_boost_life "10.0" - amount of seconds a syringe will exist in the world if a player has not touched it
dod_medic_boost_dmg "10" - damage for accepting a stamina boost

dod_medic_freehealth_time "1" - number of seconds a medics distance from their location will be checked against his teammates location
dod_medic_freehealth_max "100" - maximum limit before free health stops giving
dod_medic_freehealth_distance "256" - distance a player must be from the medic to get free health
dod_medic_freehealth_amount "1" - amount of health a player will get by being near a medic per number of seconds set in freehealth_time

dod_medic_colt_ammo "9" - amount of bullets to give the US medic
dod_medic_luger_ammo "8" - amount of bullets to give the Axis medic
dod_medic_webley_ammo "6" - amount of bullets to give the British medic
dod_medic_grenade_ammo "2" - amount of grenades to give the medic

VERSION INFO:
76.0
* Plugin Inception

76.1 2/1/07
* Public Release

76.2 2/14/07
* If the dod_damageinfliction.amxx plugin is used it MUST be listed BEFORE this plugin in plugins.ini !!
* New method for becoming a medic
* Custom models now used to show who is a medic, and for medic items
* Completely new method of healing Soldiers !!

76.3 2/15/07
* Completely fixed spawning behavior to correct issue of becomign a medic with no wepaons !!
* added cvars to control amount of pistol ammo medics get for grabbing primary weapons and ammo boxes

76.3a 2/15/07
* left a tiny bit of code out, which caused MAJOR problems when trying to become a medic the second time (thanx Aaron for finding)

76.3b 2/22/07
* Corrected a minor issue brought to my attention by: raserle (Paradeplatz der Gardejaeger)

76.3c 2/22/07
* Re-Corrected a minor issue brought to my attention by: raserle (Paradeplatz der Gardejaeger)

76.4 2/23/07
* Cleaned up minor items
* Added new stats tracking
* added class limiting

76.5 2/24/07
* Checking if model exists. If model is not installed properly then thh plugin is simply disabled. (prevents server crash 'file failed to load')
* Changed the behavior that allows players to become Medics

76.6 3/16/07
* Fixed stamina issue where Medics or "boosted" players would "keep" their "altered" minimum stamina values
* Added check for minimum health before allowing a player to be a medic (discourages coming back to spawn to get free health benefits)
* Added option to display a menu on screen at Player Spawn to allow for increased/easier class switching
* Added a Medic Help Page !!!
* Added a language file for international usage (English only at this time: email translations to TatsuSaisei@76AD.com)
* Moved Medic Help Body to language file. Max length is defined in the plugin for 512 characters - it is only suggested that this "info" be changed only if the Medic help page appears to be down for more then 72 hours

76.7 4/27/2007
* Added Russian Language (dod_medic_class.txt) tranlsations (credit: IV|XX|OnEHiTwOnDeR|SoCal )
* Added French Language (dod_medic_class.txt) tranlsations (credit:(plugin) Pvt. Leduc [29th ID] | (webpage) Hunney Bunney)
* Added German Language (dod_medic_class.txt) tranlsations (credit: =|[76AD]|= MasterF)
* Completely altered the spawn catching routine to now support deathmatch style maps

76.8
* Added more languages
* Revamped primary weapon behavior
* Altered Ammo Box pickup bonuses

KNOWN ISSUES:
MINOR: need language translations !!
MAJOR: none ?

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
//#pragma dynamic 32768

#define PLUGIN "DoD Medic Class"
#define VERSION "76.8"
#define DEVS "=|[76AD]|= TatsuSaisei"
#define AUTHOR "AMXX DoD Community"

#define MENUKEYS (1<<0)|(1<<1)|(1<<2)|(1<<3) // Keys: 1234
#define MEDICCALL (1<<0)|(1<<1)|(1<<2) // Keys: 123

//global declarations
new medic_mod_enabled;
new cvar_medic_enabled, cvar_medic_pstats,cvar_medic_healhp,cvar_medic_medkits,cvar_medic_medkits_life;
new cvar_medic_distance,cvar_medic_menu,cvar_medic_minhp;
new cvar_medic_medsyringe,cvar_medic_boostamt,cvar_medic_boostdur,cvar_medic_boostlife,cvar_medic_boostdmg;
new cvar_medic_ammobox_ammo, cvar_medic_ammobox_syringe, cvar_medic_ammobox_medkit;
new cvar_medic_healthamt,cvar_medic_healdist,cvar_medic_healthtime,cvar_medic_healthmax;
new colt_ammo, luger_ammo, webley_ammo, grenade_ammo,cvar_medic_ammo_for_primary;
new cvar_axis_medic_limit,cvar_allied_medic_limit,cvar_medic_menu_time;

//global booleans
new bool:ismedic[33] = false, bool: ishealing[33] = false,bool:istossing[33] = false;
new bool:isboosted[33] = false,bool:medic_mdl_exists = false,bool:plugin_enabled = false;
//global arrays
new stop_medic_menu[33] ,medic_stop[33],medic_ent[33],medkits[33],syringes[33],stamina_min[33] = 0;


//hold players origins
new spawn_origin[33][3];
new go_medic_origin[33][3];

//count hp given away
new medic_hp_given[33];

//precache files
new ger_medic_wav[64] = "player/germedic.wav";
new brit_medic_wav[64] = "player/britmedic.wav";
new us_medic_wav[64] = "player/usmedic.wav";

new throw_medkit_snd[64] = "player/shot2.wav";
new touch_medkit_snd[64] = "player/stopbleed.wav";

new medic_models[64] = "models/para_medic03.mdl";


//for ammo hacking
new msgAmmoX;

//for MapMarker message creation
//new msgMapMarker;

//medic counts
new axis_medics = 0, allied_medics = 0;

//string arrays
new name[32];
new teams[32];
new classname[32];
new authids[64];
new modelname[128];
new ammoMessage[128];
new team_spam[128];
new Message[128];
new motd_title[128];
new motd_body[256];
new menu_option[1024];


public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	//-----------------------------------------------------------
	new plugin_info[128],pfilename[32],pname[32],pversion[16],pauthor[32],pstatus[16];
	get_plugin(-1,pfilename,31,pname,31,pversion,15,pauthor,31,pstatus,15);
	strcat ( plugin_info, "Version: ", 127) ;
	strcat ( plugin_info, VERSION, 127) ;
	strcat ( plugin_info, " by: ", 127) ;
	strcat ( plugin_info, DEVS, 127) ;
	register_cvar(PLUGIN, plugin_info, FCVAR_SERVER|FCVAR_SPONLY);
	register_cvar(pfilename, AUTHOR, FCVAR_SERVER|FCVAR_SPONLY);
	//-----------------------------------------------------------
	
	register_dictionary("dod_medic_class.txt");
	
	register_event("RoundState", "remove_dropped_models", "a", "1=0");

	register_message(get_user_msgid("PStatus"),"msg_PStatus");
	
	register_clcmd("fullupdate", "clcmd_fullupdate") ;
	
	register_forward(FM_PlayerPreThink, "PlayerPreThink");
	register_forward(FM_UpdateClientData, "UpdateClientData_Post", 1);
	
	register_statsfwd(XMF_DAMAGE);
	
	register_menucmd(register_menuid("Medic_Menu"), MENUKEYS, "PressedMedic_Menu");
	register_menucmd(register_menuid("Medic_Call"), MEDICCALL, "PressedMedic_Call");
	
	//console commands
	register_concmd("voice_medic", "call_medic",0,"Call out for a Medic");
	register_concmd("class_medic", "go_medic",0,"Change to Medic Class");
	
	//say commands
	register_clcmd("say_team /medic","call_medic");
	register_clcmd("say /medichelp","show_help");
	register_clcmd("say /medicmenu","ShowMedic_Menu");
	register_clcmd("say /medicinfo","medic_info");
	register_clcmd("say /medic","ShowMedic_Call");
	
	// CVARS for amxx.cfg
	cvar_medic_enabled = register_cvar("dod_enable_medic", "1"); //enables/disables medic class
	cvar_medic_pstats = register_cvar("dod_enable_medic_stats", "1"); //enables/disables medic class stats logging

	cvar_medic_menu = register_cvar("dod_enable_medic_menu", "1"); //enables/disables medic menu to allow players an easier interface at becoming a medic (will occur at Round Start or Player Spawn - normal rules still apply)
	cvar_medic_menu_time = register_cvar("dod_enable_medic_menu_time", "30"); //amount of time to display the menu before it self-closes (-1 = requires manual close)
	
	cvar_axis_medic_limit = register_cvar("mp_limitaxismedic", "3"); //Axis Medic class limits
	cvar_allied_medic_limit = register_cvar("mp_limitalliedmedic", "3"); //Allied (US and British) Medic class limits
	
	cvar_medic_healhp = register_cvar("dod_medic_healhp", "10"); //how much hp a medic can give to a player
	cvar_medic_medkits = register_cvar("dod_medic_kits", "10"); //how many medkits a medic gets per life
	cvar_medic_medkits_life = register_cvar("dod_medic_kits_life", "30.0"); //amount of seconds a medkit will exist in the world if a player has not touched it
	cvar_medic_distance = register_cvar("dod_medic_spawn_distance", "256"); //distance a player must be within their spawn location to make the change to a Medic
	cvar_medic_minhp = register_cvar("dod_medic_minhp", "100"); //how much hp a player must have to become a medic (discourages coming back to spawn to get free health benefits)
	
	cvar_medic_ammobox_ammo = register_cvar("dod_medic_ammo_ammo", "1"); //enable/disable 1 clip of pistol ammo on ammo box pickup
	cvar_medic_ammobox_syringe = register_cvar("dod_medic_ammo_syringe", "1"); //enable/disable 1 syringe on ammo box pickup
	cvar_medic_ammobox_medkit = register_cvar("dod_medic_ammo_medkit", "1"); //enable/disable 1 mekdit on ammo box pickup
	cvar_medic_ammo_for_primary = register_cvar("dod_medic_ammo_for_primary", "1"); //enable/disable 1 ammo pickup on primary pickup
	
	cvar_medic_medsyringe = register_cvar("dod_medic_syringes", "3"); //how many syringes a medic gets per life
	cvar_medic_boostamt = register_cvar("dod_medic_boost_amt", "25"); //how much stamina boost a medic can give to a player
	cvar_medic_boostdur = register_cvar("dod_medic_boost_duration", "10.0"); //amount of seconds a player will be "boosted"
	cvar_medic_boostlife = register_cvar("dod_medic_boost_life", "10.0"); //amount of seconds a syringe will exist in the world if a player has not touched it
	cvar_medic_boostdmg = register_cvar("dod_medic_boost_dmg", "10"); //damage for accepting a stamina boost
	
	cvar_medic_healthtime = register_cvar("dod_medic_freehealth_time","1"); //number of seconds a medics distance from their location will be checked against his teammates location
	cvar_medic_healthmax = register_cvar("dod_medic_freehealth_max","100"); //maximum limit before free health stops giving
	cvar_medic_healdist = register_cvar("dod_medic_freehealth_distance", "250"); //distance a player must be from the medic to get free health
	cvar_medic_healthamt = register_cvar("dod_medic_freehealth_amount","2"); //amount of health a player will get by being near a medic per number of seconds set in freehealth_time
	
	colt_ammo = register_cvar("dod_medic_colt_ammo", "25"); //amount of pistol bullets to give the US medic when touching a dropped weapon
	luger_ammo = register_cvar("dod_medic_luger_ammo", "25"); //amount of pistol bullets to give the Axis medic when touching a dropped weapon
	webley_ammo = register_cvar("dod_medic_webley_ammo", "25"); //amount of pistol bullets to give the British medic when touching a dropped weapon
	grenade_ammo = register_cvar("dod_medic_grenade_ammo", "2"); //amount of grenades to give the medic at "spawn"
	
	set_task(get_pcvar_float(cvar_medic_healthtime),"medic_heal");
	
	msgAmmoX = get_user_msgid("AmmoX");
	//msgMapMarker = get_user_msgid("MapMarker");
	
	medic_mod_enabled = get_pcvar_num(cvar_medic_enabled);	
}

public plugin_precache() 
{ 
	if(file_exists(medic_models)) 
	{
		precache_model(medic_models);
		medic_mdl_exists = true;
	}
	if(medic_mdl_exists)
	{
		precache_sound(touch_medkit_snd);
		precache_sound(throw_medkit_snd);
		precache_sound(ger_medic_wav);
		precache_sound(brit_medic_wav);
		precache_sound(us_medic_wav);
		plugin_enabled = true;
		server_print("%s %L",PLUGIN,0,"MEDIC_MODEL_PASS");
		log_amx("%s %L",PLUGIN,0,"MEDIC_MODEL_PASS");
	}
	else
	{
		plugin_enabled = false;
		server_print("%s %L %s",PLUGIN,0,"MEDIC_MODEL_FAIL", medic_models);
		log_amx("%s %L %s",PLUGIN,0,"MEDIC_MODEL_FAIL", medic_models);
	}
	return PLUGIN_CONTINUE;
}

public clcmd_fullupdate() 
{
	return PLUGIN_HANDLED;
}

public client_connect(id)
{
	if(plugin_enabled)
	{
		if(ismedic[id]) remove_medics(id);
		medic_stop[id] = 0;
		medic_ent[id] = 0;
		stop_medic_menu[id]  = 0;
	}
	return PLUGIN_CONTINUE;
}

public dod_client_changeteam(id, team, oldteam)
{
	if(plugin_enabled)
	{
		if(ismedic[id]) remove_medics(id);
	}
	return PLUGIN_CONTINUE;
}

public client_disconnect(id)
{
	if(plugin_enabled)
	{
		if(ismedic[id]) remove_medics(id);
	}
	return PLUGIN_CONTINUE;
}

public medic_info(id)
{
	if(is_user_alive(id) && !is_user_bot(id))
	{
		new player_ids[32],count;
		get_players(player_ids, count, "c");
		if(get_user_flags(id)&ADMIN_RCON)
		{
			client_print(id,print_center,"There are %d Allied Medics and %d Axis Medics",allied_medics,axis_medics);
		}
		else
		{
			client_print(id,print_chat,"[MEDIC] say_team /medic to call out for one and mark the map.");
		}
		for(new i = 0;i < count;i++)
		{
			new med_id = player_ids[i];
			if(ismedic[med_id])
			{
				new steamid[32],name[32],teamname[32];
				get_user_authid(med_id,steamid,32);
				get_user_name(med_id,name,32);
				get_user_team(med_id,teamname,32);
				if(get_user_flags(id)&ADMIN_RCON)
				{
					client_print(id,print_chat,"[%s] %s is a medic for the %s",steamid, name,teamname);
				}
				else
				{
					if(get_user_team(id) == get_user_team(med_id))
					{
						client_print(id,print_chat,"%s is a medic", name);
					}
				}
			}
		}
	}
	return PLUGIN_HANDLED;
}

public msg_PStatus(msgid,msgdest,id)
{
	if(msgdest == 2 && !id)
	{
		new player = get_msg_arg_int(1);
		new status = get_msg_arg_int(2);
	    
		if(is_user_connected(player) && status == 0) spawn_forward(player); //set_task(Float:0.1,"spawn_forward",player);
	}
}

public spawn_forward(id)
{
	if(plugin_enabled)
	{
		if(medic_mod_enabled  && is_user_alive(id))
		{
			new class;
			class = dod_get_user_class(id);
			PressedMedic_Call(id, 1);
			stamina_min[id] = 0;
			if(ismedic[id]) remove_medics(id);
			dod_set_stamina(id,STAMINA_SET,0);
			record_spawn_origin(id);
			if(get_pcvar_num(cvar_medic_menu) && !medic_stop[id] && !is_user_bot(id) && !(class == DODC_MG34 || class == DODC_MG42 || class == DODC_30CAL || class == DODC_SNIPER || class == DODC_SCHARFSCHUTZE || class == DODC_SCOPED_FG42 || class == DODC_PIAT || class == DODC_PANZERJAGER || class == DODC_MARKSMAN))
			{
				ShowMedic_Menu(id);
			}	
		}
	}
	return PLUGIN_CONTINUE;
} 

public go_medic(id)
{
	if(plugin_enabled)
	{	
		if(medic_mod_enabled)
		{
			new class = dod_get_user_class(id);
			if(class == DODC_MG34 || class == DODC_MG42 || class == DODC_30CAL || class == DODC_SNIPER || class == DODC_SCHARFSCHUTZE || class == DODC_SCOPED_FG42 || class == DODC_PIAT || class == DODC_PANZERJAGER || class == DODC_MARKSMAN  || class == DODC_BAZOOKA) return PLUGIN_HANDLED;
			if (!id || !is_user_alive(id)) return PLUGIN_HANDLED;
			new minhealth = get_pcvar_num(cvar_medic_minhp);
			if (!ismedic[id] && get_user_health(id) < minhealth) 
			{
				client_print(id,print_center,"%L",id,"MEDIC_MINIMUMHP",minhealth);
				return PLUGIN_HANDLED;
			}
			
			if(!ismedic[id] && get_user_team(id) == ALLIES && allied_medics >= get_pcvar_num(cvar_allied_medic_limit))
			{
				client_print(id,print_center,"%L",id,"MEDIC_ALLIED_LIMIT",allied_medics);
				return PLUGIN_HANDLED;
			}
			if(!ismedic[id] && get_user_team(id) == AXIS && axis_medics >= get_pcvar_num(cvar_axis_medic_limit))
			{
				client_print(id,print_center,"%L",id,"MEDIC_AXIS_LIMIT",axis_medics);
				return PLUGIN_HANDLED;
			}
			get_user_origin(id,go_medic_origin[id]);
			new med_distance = get_distance(go_medic_origin[id],spawn_origin[id]);
			new mindist = get_pcvar_num(cvar_medic_distance);
			format(team_spam,127,"%L",id,"MEDIC_TEAMSPAM");
			medic_hp_given[id] = 0;
			if(med_distance < mindist && !ismedic[id])
			{
				client_print(id,print_chat,"%L",id,"MEDIC_BECOME_CHAT");
				engclient_cmd(id,"say_team" ,team_spam);
				client_print(id,print_center,"%L",id,"MEDIC_BECOME_CENTER");
				get_user_name(id,name,31);
				new britishally = dod_get_map_info(MI_ALLIES_TEAM);
				new grenadeAmmo = get_pcvar_num(grenade_ammo);
				stamina_min[id] = 25;
				get_user_authid(id,authids,63);
				get_user_team(id,teams,31);
				strip_user_weapons(id);
				dod_set_stamina(id,STAMINA_SET,25,100);
				if (!medic_ent[id] && is_user_alive(id)&&!is_user_bot(id))
				{
					medic_ent[id] = create_entity("info_target");
					new team = get_user_team(id);
					if (medic_ent[id] > 0)
					{
						entity_set_model(medic_ent[id],medic_models);
						entity_set_int(medic_ent[id], EV_INT_movetype, MOVETYPE_FOLLOW);
						entity_set_edict(medic_ent[id], EV_ENT_aiment, id);
						if(team == ALLIES && !britishally)
						{
							allied_medics++;
							entity_set_int(medic_ent[id], EV_INT_body, 5);
							emit_sound(id,CHAN_VOICE, us_medic_wav, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
							give_item(id,"weapon_colt");
							give_item(id,"weapon_amerknife");
							//dod_set_user_class(id,DODC_THOMPSON);
							//grenade option
							if(grenadeAmmo)
							{
								give_item(id,"weapon_handgrenade");
								dod_set_user_ammo(id,DODW_HANDGRENADE,grenadeAmmo);
							}
						}
						else if (team == ALLIES && britishally)
						{
							allied_medics++;
							entity_set_int(medic_ent[id], EV_INT_body, 6);
							emit_sound(id,CHAN_VOICE, brit_medic_wav, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
							give_item(id,"weapon_webley");
							give_item(id,"weapon_amerknife");
							//dod_set_user_class(id,DODC_STEN);
							//grenade option
							if(grenadeAmmo)
							{
								give_item(id,"weapon_handgrenade");
								dod_set_user_ammo(id,DODW_HANDGRENADE,grenadeAmmo);
							}
						}
						else if(team == AXIS) 
						{
							axis_medics++;
							entity_set_int(medic_ent[id], EV_INT_body, 4);
							emit_sound(id,CHAN_VOICE, ger_medic_wav, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
							give_item(id,"weapon_luger");
							give_item(id,"weapon_gerknife");
							//dod_set_user_class(id,DODC_MP40);
							//grenade option
							if(grenadeAmmo)
							{
								give_item(id,"weapon_stickgrenade");
								dod_set_user_ammo(id,DODW_STICKGRENADE,grenadeAmmo);
							}
						}
						// Update user's HUD
						message_begin(MSG_ONE,msgAmmoX,{0,0,0},id);
						write_byte(9);
						write_byte(grenadeAmmo);
						message_end();
					}
				}
				
				if(!ismedic[id])
				{
					//Log the Class change
					if (get_pcvar_num(cvar_medic_pstats) && !ismedic[id])
					{
						log_message("\"%s<%d><%s><%s>\" changed role to \"#class_medic\"",name,get_user_userid(id),authids,teams);
					}
				}
				ismedic[id] = true;
				medkits[id] = get_pcvar_num(cvar_medic_medkits);
				syringes[id] = get_pcvar_num(cvar_medic_medsyringe);
				show_medic_ammo(id);
				return PLUGIN_HANDLED;
			}
			else if(ismedic[id])
			{
				client_print(id,print_chat,"%L",id,"MEDIC_ALREADY");
				show_medic_ammo(id);
				engclient_cmd(id,"say_team",team_spam);
			}
			else
			{
				client_print(id,print_center,"%L",id,"MEDIC_FAR_FROM_SPAWN");
			}
		}
	}
	else
	{
		client_print(id,print_center,"%L",id,"MEDIC_DISABLED");
	}
	return PLUGIN_HANDLED;
}

public remove_medics(id)
{
	if(ismedic[id]) 
	{
		new med_id = medic_ent[id];
		destroy_object(med_id);
		medic_ent[id] = 0;
		ismedic[id] = false;
		if(get_user_team(id) == ALLIES) allied_medics--;
		else axis_medics--;
		if(allied_medics < 0) allied_medics = 0;
		if(axis_medics < 0) axis_medics = 0;
	}
}

public destroy_object(ent_id)
{
	if(is_valid_ent(ent_id)) 
	{
		remove_entity(ent_id);
	}
}

public ShowMedic_Menu(id) 
{
	format(menu_option,1023,"\\w%L\n\\r1.\\w %L\n\\r2.\\w %L\n\\r3.\\w %L\n\\r4.\\w %L\n\n\\y %L\n\n\\wMedic Class (%s) by:\n=|[76AD]|= TatsuSaisei",id,"MEDIC_MENU_TITLE",id,"MEDIC_MENU_OPTION1",id,"MEDIC_MENU_OPTION2",id,"MEDIC_MENU_OPTION3",id,"MEDIC_MENU_OPTION4",id,"MEDIC_MENU_COMMENT1",VERSION);
	medic_stop[id]= 0;
	show_menu(id, MENUKEYS, menu_option,get_pcvar_num(cvar_medic_menu_time), "Medic_Menu");  // Display menu	
}

public ShowMedic_Call(id)
{
	if(is_user_alive(id) && !is_user_bot(id)) show_menu(id, MEDICCALL, "\\rCall Medic ?\n\\w1. YES !\n2. No/Close\n3. Disable this\n\n\\ysay_team /medic\nto call for a Medic\n\nsay /medic\nto reenable or\nuse this menu\n", 5, "Medic_Call") ; // Display menu
}

public PressedMedic_Menu(id, key) 
{
	switch (key) 
	{
		case 0: 
		{ // YES
			go_medic(id);
		}
		case 2: 
		{ // HELP
			show_help(id);
		}
		case 3: 
		{ // STOP MENU
			medic_stop[id]=  1;
		}
	}
	
}

public PressedMedic_Call(id, key) 
{
	/* Menu:
	* Call Medic ?
	* 1. YES !
	* 2. No/Close
	* 3. Disable this
	* 
	* say_team /medic
	*/
	
	switch (key) 
	{
		case 0: 
		{ // 1
			call_medic(id);
			ShowMedic_Call(id);
		}
		case 1:
		{
			stop_medic_menu[id]=  0;
		}
		case 2: 
		{ // 3
			stop_medic_menu[id] = 1;
		}
	}
}

public show_help(id)
{
	format(motd_body,255,"%L",id,"MEDIC_HELP_BODY");
	format(motd_title,127,"%L",id,"MEDIC_HELP_TITLE");
	show_motd(id, motd_body, motd_title);
}

public record_spawn_origin(id)
{
	if (is_valid_ent(id) && is_user_alive(id)) get_user_origin(id,spawn_origin[id]);
}

public remove_dropped_models(id)
{
	if(plugin_enabled)
	{	
		if(!medic_mod_enabled) return PLUGIN_CONTINUE; 
		
		new medkit_id = find_ent_by_class(-1, "MedKit");
		while((medkit_id = find_ent_by_class(-1, "MedKit")) > 0)
		{
			remove_entity(medkit_id);
		}
		
		new syringe_id = find_ent_by_class(-1, "Syringe");
		while((syringe_id = find_ent_by_class(-1, "Syringe")) > 0)
		{
			remove_entity(syringe_id);
		}
	}
	return PLUGIN_CONTINUE;
}

public PlayerPreThink(id)
{
	if(plugin_enabled)
	{	
		if(medic_mod_enabled)
		{
			if(!is_user_alive(id) || is_user_bot(id)|| !is_user_connected(id)) return FMRES_HANDLED; 

			if(stamina_min[id] > 100) stamina_min[id] = 100;
			new clip, ammo, myWeapon = dod_get_user_weapon(id,clip,ammo);
			if(ismedic[id] && !istossing[id] && (myWeapon == DODW_COLT || myWeapon == DODW_LUGER || myWeapon == DODW_WEBLEY))
			{
				if(pev(id,pev_button) & IN_ATTACK2) 
				{
					throw_medkit(id);
					show_medic_ammo(id);
				}
			}
			if(ismedic[id] && !ishealing[id] && (myWeapon == DODW_SPADE || myWeapon == DODW_GERKNIFE || myWeapon == DODW_AMERKNIFE || myWeapon == DODW_BRITKNIFE))
			{
				if(pev(id,pev_button) & IN_ATTACK2) 
				{
					throw_syringe(id);
					show_medic_ammo(id);
				}
			}
			if(ismedic[id])
			{
				dod_set_stamina(id,STAMINA_SET,stamina_min[id]);
			}
			if(isboosted[id])
			{
				dod_set_stamina(id,STAMINA_SET,stamina_min[id]);
			}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// This should prevent a medic from using a primary weapon
			if(ismedic[id] && (myWeapon == DODW_30_CAL || myWeapon == DODW_BAR || myWeapon == DODW_BAZOOKA || myWeapon == DODW_BREN|| myWeapon == DODW_ENFIELD || myWeapon == DODW_FG42
				 || myWeapon == DODW_FOLDING_CARBINE|| myWeapon == DODW_GARAND|| myWeapon == DODW_GARAND_BUTT || myWeapon == DODW_GREASEGUN || myWeapon == DODW_ENFIELD_BAYONET
				  || myWeapon == DODW_K43 || myWeapon == DODW_K43_BUTT|| myWeapon == DODW_KAR || myWeapon == DODW_KAR_BAYONET || myWeapon == DODW_M1_CARBINE
				   || myWeapon == DODW_MG34 || myWeapon == DODW_MG42|| myWeapon == DODW_MG34 || myWeapon == DODW_MP40 || myWeapon == DODW_PANZERSCHRECK
				    || myWeapon == DODW_PIAT || myWeapon == DODW_SCOPED_ENFIELD || myWeapon == DODW_SCOPED_FG42 || myWeapon == DODW_SCOPED_KAR 
				    || myWeapon == DODW_SPRINGFIELD|| myWeapon == DODW_STEN|| myWeapon == DODW_STG44 || myWeapon == DODW_THOMPSON))
			{
				if(pev(id,pev_button) & IN_ATTACK)
				{
					set_pev(id,pev_button,pev(id,pev_button) & ~IN_ATTACK);
				}
				if(pev(id,pev_button) & IN_ATTACK2)
				{
					set_pev(id,pev_button,pev(id,pev_button) & ~IN_ATTACK2);
				}
			}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		}
	}
	return FMRES_HANDLED;
}

public UpdateClientData_Post(id,sendweapons,cd_handle)
{
	if(plugin_enabled)
	{	
		if(medic_mod_enabled)
		{
			new clip, ammo, myWeapon = dod_get_user_weapon(id,clip,ammo);
			if(ismedic[id] && (myWeapon == DODW_30_CAL || myWeapon == DODW_BAR || myWeapon == DODW_BREN|| myWeapon == DODW_ENFIELD || myWeapon == DODW_FG42
						 || myWeapon == DODW_FOLDING_CARBINE|| myWeapon == DODW_GARAND|| myWeapon == DODW_GARAND_BUTT || myWeapon == DODW_GREASEGUN || myWeapon == DODW_ENFIELD_BAYONET
						  || myWeapon == DODW_K43 || myWeapon == DODW_K43_BUTT|| myWeapon == DODW_KAR || myWeapon == DODW_KAR_BAYONET || myWeapon == DODW_M1_CARBINE
						   || myWeapon == DODW_MG34 || myWeapon == DODW_MG42|| myWeapon == DODW_MG34 || myWeapon == DODW_MP40 || myWeapon == DODW_PANZERSCHRECK
						    || myWeapon == DODW_PIAT || myWeapon == DODW_SCOPED_ENFIELD || myWeapon == DODW_SCOPED_FG42 || myWeapon == DODW_SCOPED_KAR 
						    || myWeapon == DODW_SPRINGFIELD|| myWeapon == DODW_STEN|| myWeapon == DODW_STG44 || myWeapon == DODW_THOMPSON))
			{
				if (!is_user_alive(id) || !is_user_connected(id))return FMRES_IGNORED;
			
				set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001);
				return FMRES_HANDLED;
			}
		}
	}

	return FMRES_IGNORED;
} 

public pfn_touch (ptr, ptd) //ptd = touched ptr = toucher
{
	if(plugin_enabled)
	{	
		if(!is_user_alive(ptd)||ptr  == 0||!is_valid_ent(ptr)||!is_valid_ent(ptd)) return PLUGIN_CONTINUE;
		new owner;
		new medteam;
		new team = get_user_team(ptd);
		new britishally = dod_get_map_info(MI_ALLIES_TEAM);
		new namek[32],namev[32],authidk[35],authidv[35];
		new healhp = get_pcvar_num(cvar_medic_healhp);
		new boostamt = get_pcvar_num(cvar_medic_boostamt);
		//new clip, ammo, myWeapon = dod_get_user_weapon(ptd,clip,ammo);
		new coltAmmo = get_pcvar_num(colt_ammo);
		new lugerAmmo = get_pcvar_num(luger_ammo);
		new webleyAmmo = get_pcvar_num(webley_ammo);
		new ammo_for_primary = get_pcvar_num(cvar_medic_ammo_for_primary);
		get_user_name(ptd,namev,31);
		get_user_name(owner,namek,31);
		get_user_authid(ptd,authidv,34);
		get_user_authid(owner,authidk,34);
		entity_get_string(ptr,EV_SZ_classname,classname,31);
		entity_get_string(ptr,EV_SZ_model,modelname,128);
		if(equali(classname,"dod_control_point") && ismedic[ptd])
		{
			return PLUGIN_HANDLED;
		}
		if(strfind(classname,"ammo_generic",0)>= 0  && ismedic[ptd]) 
		{
			owner = entity_get_edict (ptr,EV_ENT_owner);
			if(team == ALLIES && !britishally && owner != ptd && strfind(classname,"american",0)>=0) //if ally
			{
				if(get_pcvar_num(cvar_medic_ammobox_medkit))
				{
					medkits[ptd]  += 1;
					client_print(ptd,print_chat,"%L",ptd,"MEDIC_MEDKIT_PICKUP");
				}
				if(get_pcvar_num(cvar_medic_ammobox_syringe))
				{
					syringes[ptd]  += 1;
					client_print(ptd,print_chat,"%L",ptd,"MEDIC_SYRINGE_PICKUP");
				}
				if(get_pcvar_num(cvar_medic_ammobox_ammo))
				{
					// set pistol ammo
					dod_set_user_ammo(ptd,DODW_COLT, coltAmmo);
					// Update user's HUD
					message_begin(MSG_ONE,msgAmmoX,{0,0,0},ptd);
					write_byte(4);
					write_byte(coltAmmo);
					message_end();
				}
				remove_entity(ptr);
				
			}
			else if (team == ALLIES && britishally && owner != ptd && strfind(classname,"british",0)>=0) //if british
			{
				if(get_pcvar_num(cvar_medic_ammobox_medkit))
				{
					medkits[ptd]  += 1;
					client_print(ptd,print_chat,"%L",ptd,"MEDIC_MEDKIT_PICKUP");
				}
				if(get_pcvar_num(cvar_medic_ammobox_syringe))
				{
					syringes[ptd]  += 1;
					client_print(ptd,print_chat,"%L",ptd,"MEDIC_SYRINGE_PICKUP");
				}
				if(get_pcvar_num(cvar_medic_ammobox_ammo))
				{
					// set pistol ammo
					dod_set_user_ammo(ptd,DODW_WEBLEY, webleyAmmo);
					// Update user's HUD
					message_begin(MSG_ONE,msgAmmoX,{0,0,0},ptd);
					write_byte(4);
					write_byte(webleyAmmo);
					message_end();
				}
				remove_entity(ptr);
			}
			else if(team == AXIS && owner != ptd && strfind(classname,"german",0)>=0) //if axis
			{
				if(get_pcvar_num(cvar_medic_ammobox_medkit))
				{
					medkits[ptd]  += 1;
					client_print(ptd,print_chat,"%L",ptd,"MEDIC_MEDKIT_PICKUP");
				}
				if(get_pcvar_num(cvar_medic_ammobox_syringe))
				{
					syringes[ptd]  += 1;
					client_print(ptd,print_chat,"%L",ptd,"MEDIC_SYRINGE_PICKUP");
				}
				if(get_pcvar_num(cvar_medic_ammobox_ammo))
				{
					// set pistol ammo
					dod_set_user_ammo(ptd,DODW_LUGER,lugerAmmo);
					// Update user's HUD
					message_begin(MSG_ONE,msgAmmoX,{0,0,0},ptd);
					write_byte(4);
					write_byte(lugerAmmo);
					message_end();
				}
				remove_entity(ptr);
			}
			show_medic_ammo(ptd);
		}
		if(strfind(classname,"MedKit",0)>=0)
		{
			new player_health = get_user_health(ptd);
			owner = entity_get_edict (ptr,EV_ENT_owner);
			if(player_health < 100)
			{
				if(owner == ptd) //if medic picks up his own bag
				{
					set_user_health(ptd,player_health + healhp);
				}
				else //all others touched the bag
				{
					set_user_health(ptd,player_health  +  healhp);
					
					if(is_user_alive(owner)) 
					{
						stamina_min[owner] += boostamt/2;
						if(stamina_min[owner] > 100) stamina_min[owner] = 100;
						dod_set_stamina(owner,STAMINA_SET,stamina_min[owner]);
						medteam = get_user_team(owner);
						medic_hp_given[owner] += healhp;
					}
					
					if(team == medteam)
					{
						new player_score = dod_get_user_score(owner);
						dod_set_user_score(owner, player_score + 2,1);
						//log the heal
						if (get_pcvar_num(cvar_medic_pstats))
						{
							//custom weapon support
							log_message("\"%s<%d><%s><%s>\" triggered \"weaponstats\" (weapon \"MedKit\") (shots \"0\") (hits \"1\") (kills \"1\") (headshots \"0\") (tks \"0\") (damage \"%d\") (deaths \"0\") (score \"2\")",namek,get_user_userid(owner),authidk,owner,-1 * get_pcvar_num(cvar_medic_healhp));
						}
					}
					else
					{
						if(is_user_connected(owner) )
						{
							new player_score = dod_get_user_score(owner);
							stamina_min[owner] = 0;
							dod_set_user_score(owner, player_score - 2,1);
							if (get_pcvar_num(cvar_medic_pstats))
							{
								//custom weapon support
								log_message("\"%s<%d><%s><%s>\" triggered \"weaponstats\" (weapon \"MedKit\") (shots \"0\") (hits \"1\") (kills \"-1\") (headshots \"0\") (tks \"0\") (damage \"%d\") (deaths \"0\") (score \"-2\")",namek,get_user_userid(owner),authidk,owner,-1 * get_pcvar_num(cvar_medic_healhp));
							}
						}
						
					}
					
				}
				remove_entity(ptr);
				remove_task(1576 + ptr);
				remove_task(1976 + ptr);
				// Make the touch sound
				emit_sound(ptd, CHAN_VOICE, touch_medkit_snd, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
			else if(ismedic[ptd])
			{
				medkits[ptd]  += 1;
				client_print(ptd,print_chat,"%L",ptd,"MEDIC_MEDKIT_PICKUP");
				remove_entity(ptr);
				remove_task(1576 + ptr);
				remove_task(1976 + ptr);
				show_medic_ammo(ptd);
			}
		}
		if(strfind(classname,"Syringe",0)>=0)
		{
			new score;
			owner = entity_get_edict (ptr,EV_ENT_owner);
			if(is_valid_ent(owner)) score = dod_get_user_score(owner);
			if(ismedic[ptd])
			{
				syringes[ptd]  += 1;
				client_print(ptd,print_chat,"%L",ptd,"MEDIC_SYRINGE_PICKUP");
				remove_entity(ptr);
				remove_task(1676 + ptr);
				remove_task(1876 + ptr);
				show_medic_ammo(ptd);
			}
			else
			{
				new ida[32];
				ida[0] = ptd;
				ida[1] = owner;
				stamina_min[ptd] += get_pcvar_num(cvar_medic_boostamt);
				if(stamina_min[ptd] > 100) stamina_min[ptd] = 100;
				dod_set_stamina(ptd,STAMINA_SET,stamina_min[ptd]);
				
				
				remove_task(1776 + ptr);
				set_task(get_pcvar_float(cvar_medic_boostdur),"boost_duration",1776+ptd,ida,32);
				remove_entity(ptr);
				remove_task(1876 + ptr);
				remove_task(1676 + ptr);
				isboosted[ptd] = true;
				if(is_valid_ent(owner)) dod_set_user_score(owner, score + 1,1);
			}
		}
		if((strfind(classname,"weaponbox",0)>=0 || strfind(classname,"weapon_",0)>=0) && ismedic[ptd])
		{
			if(pev(ptd,pev_button) & IN_USE)
			{
				//give pistol ammo in exchange for primary weapon pickup - should keep medics alive a bit longer .. lol
				if(team == ALLIES && !britishally && ammo_for_primary)
				{
					// set pistol ammo
					dod_set_user_ammo(ptd,DODW_COLT, coltAmmo );
					// Update user's HUD
					message_begin(MSG_ONE,msgAmmoX,{0,0,0},ptd);
					write_byte(4);
					write_byte(coltAmmo);
					message_end();
				}
				else if (team == ALLIES && britishally && ammo_for_primary)
				{
					// set pistol ammo
					dod_set_user_ammo(ptd,DODW_WEBLEY,  webleyAmmo);
					// Update user's HUD
					message_begin(MSG_ONE,msgAmmoX,{0,0,0},ptd);
					write_byte(4);
					write_byte(lugerAmmo);
					message_end();
				}
				else if(team == AXIS && ammo_for_primary) 
				{
					// set pistol ammo
					dod_set_user_ammo(ptd,DODW_LUGER,  lugerAmmo);
					// Update user's HUD
					message_begin(MSG_ONE,msgAmmoX,{0,0,0},ptd);
					write_byte(4);
					write_byte( lugerAmmo);
					message_end();
				}
			}
			else return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_CONTINUE;
}

public boost_duration(ida[])
{
	new id = ida[0];
	new player_health = get_user_health(id);
	new boostdmg = get_pcvar_num(cvar_medic_boostdmg);

	set_user_health(id,player_health - boostdmg);
	stamina_min[id] = 0;
	dod_set_stamina(id,STAMINA_RESET);
	isboosted[id] = false;
	return PLUGIN_CONTINUE;
}

public call_medic(id)
{
	if(plugin_enabled)
	{	
		new player_health = get_user_health(id);
		if(is_user_alive(id) && !is_user_bot(id) && player_health < 100)
		{
			new team = get_user_team(id);
			new britishally = dod_get_map_info(MI_ALLIES_TEAM);
			format( Message,127,"%L",id,"MEDIC_CALL",player_health);
			if(team == ALLIES && britishally == 0)
			{
				emit_sound(id,CHAN_VOICE, us_medic_wav, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				
			}
			else if (team == ALLIES && britishally == 1)
			{
				emit_sound(id,CHAN_VOICE, brit_medic_wav, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			}
			else if(team == AXIS) 
			{
				emit_sound(id,CHAN_VOICE, ger_medic_wav, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			}
			engclient_cmd(id,"say_team", Message);
			client_cmd(id,"firemarker");
			
			
		}
		//show the medic information for the team
		medic_info(id);
	}
	else
	{
		client_print(id,print_center,"%L",id,"MEDIC_DISABLED");
	}
	return PLUGIN_HANDLED;
}

public toss_delay (ida[])
{
	new id  = ida[0];
	istossing[id] = false;
	return PLUGIN_CONTINUE;
}

public throw_medkit(id)
{
	if(istossing[id] || medkits[id] <= 0) return PLUGIN_CONTINUE;
	new team = get_user_team(id);
	istossing[id] = true;
	new ida[32];
	ida[0] = id;
	set_task(1.0,"toss_delay",0,ida,31,"a",1);
	
	new medkit_id = create_entity("info_target");
	
	// Exit out if we get a 0
	if(!medkit_id) return PLUGIN_HANDLED;
	
	// calculate how hard to throw the medkit based on the aim angle
	new Float:vAngle[3];
	new Float:punchAngle[3];
	new Float:throwAngle[3];
	
	entity_get_vector(id, EV_VEC_v_angle, vAngle);
	entity_get_vector(id, EV_VEC_punchangle, punchAngle);
	throwAngle[0] = vAngle[0] + punchAngle[0] * 5;
	
	if(throwAngle[0] < 0) throwAngle[0] = -10 + throwAngle[0] * ((90 - 10) / 90.0);
	
	else throwAngle[0] = -10 + throwAngle[0] * ((90 + 10) / 90.0);
	
	new Float:flVel = (90 - throwAngle[0]) * 5;
	
	// limit out velocity to a maximum of 300
	if(flVel > 300.0) flVel = 300.0;
	
	new Float:PlayerOrigin[3];
	new Float:velocity[3];
	new Float:pangle[3];
	
	// throw angle and velocity
	velocity_by_aim(id, floatround(flVel), velocity);				
	
	// get the player origin
	entity_get_vector(id, EV_VEC_origin, PlayerOrigin);
	
	entity_get_vector(id, EV_VEC_angles, pangle);
	
	// Make the throw sound
	emit_sound(id, CHAN_VOICE, throw_medkit_snd, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	//log the throw
	new name[32],teamname[32],steam[32];
	get_user_authid(id, steam, 31);
	get_user_team(id,teamname,32);
	get_user_name(id,name,32);
	
	entity_set_string(medkit_id, EV_SZ_classname, "MedKit");	
	entity_set_origin(medkit_id, PlayerOrigin);			// set its origin to the player
	entity_set_model(medkit_id, medic_models);			// set its model
	if(team == ALLIES)
	{
		entity_set_int(medkit_id, EV_INT_body, 1);
	}
	else
	{
		entity_set_int(medkit_id, EV_INT_body, 2);
	}
	entity_set_int(medkit_id , EV_INT_movetype, MOVETYPE_TOSS);	// set movetype so it doesn't bounce
	entity_set_float(medkit_id, EV_FL_friction, 1.0);		// set its friction
	entity_set_vector(medkit_id, EV_VEC_velocity, velocity);	// set the launch velocity and vector
	entity_set_edict(medkit_id, EV_ENT_owner, id);			// set the owner
	
	//subtract a medkit
	medkits[id]--;
	show_medic_ammo(id);
	
	// medkit thrown, now make it touchable on the ground
	new param[1];
	param[0] = medkit_id;
	set_task(0.3, "make_bbox", 1976 + medkit_id, param, 1);
	set_task(get_pcvar_float(cvar_medic_medkits_life), "destroy_object", 1576 + medkit_id, param, 1);
	return PLUGIN_HANDLED;
}



public throw_syringe(id)
{
	if(istossing[id] || syringes[id] <= 0) return PLUGIN_CONTINUE;
	//new team = get_user_team(id);
	istossing[id] = true;
	new ida[32];
	ida[0] = id;
	set_task(1.0,"toss_delay",0,ida,31,"a",1);
	
	new syringe_id = create_entity("info_target");
	
	// Exit out if we get a 0
	if(!syringe_id) return PLUGIN_HANDLED;
	
	// calculate how hard to throw the syringe based on the aim angle
	new Float:vAngle[3];
	new Float:punchAngle[3];
	new Float:throwAngle[3];
	
	entity_get_vector(id, EV_VEC_v_angle, vAngle);
	entity_get_vector(id, EV_VEC_punchangle, punchAngle);
	throwAngle[0] = vAngle[0] + punchAngle[0] * 5;
	
	if(throwAngle[0] < 0) throwAngle[0] = -10 + throwAngle[0] * ((90 - 10) / 90.0);
	
	else throwAngle[0] = -10 + throwAngle[0] * ((90 + 10) / 90.0);
	
	new Float:flVel = (90 - throwAngle[0]) * 5;
	
	// limit out velocity to a maximum of 300
	if(flVel > 300.0) flVel = 300.0;
	
	new Float:PlayerOrigin[3];
	new Float:velocity[3];
	new Float:pangle[3];
	
	// throw angle and velocity
	velocity_by_aim(id, floatround(flVel), velocity);				
	
	// get the player origin
	entity_get_vector(id, EV_VEC_origin, PlayerOrigin);
	
	entity_get_vector(id, EV_VEC_angles, pangle);
	
	
	//log the throw
	new name[32],teamname[32],steam[32];
	get_user_authid(id, steam, 31);
	get_user_team(id,teamname,32);
	get_user_name(id,name,32);
	
	entity_set_string(syringe_id, EV_SZ_classname, "Syringe");	
	entity_set_origin(syringe_id, PlayerOrigin);			// set its origin to the player
	entity_set_model(syringe_id, medic_models);			// set its model
	entity_set_int(syringe_id, EV_INT_body, 0);
	entity_set_int(syringe_id , EV_INT_movetype, MOVETYPE_TOSS);	// set movetype so it doesn't bounce
	entity_set_float(syringe_id, EV_FL_friction, 1.0);		// set its friction
	entity_set_vector(syringe_id, EV_VEC_velocity, velocity);	// set the launch velocity and vector
	entity_set_edict(syringe_id, EV_ENT_owner, id);			// set the owner
	
	
	//subtract a syringe
	syringes[id]--;
	show_medic_ammo(id);
	
	// syringe thrown, now make it touchable on the ground
	new param[1];
	param[0] = syringe_id;
	set_task(0.3, "make_bbox", 1876 + syringe_id, param, 1);
	set_task(get_pcvar_float(cvar_medic_boostlife), "destroy_object", 1676 + syringe_id, param, 1);
	return PLUGIN_HANDLED;
}

//make bounding box around the entity so it may be touchable
public make_bbox(param[])
{
	new bbox_id = param[0];
	if(!is_valid_ent(bbox_id)) return PLUGIN_CONTINUE;
	new Float:mina[3],Float:maxa[3];
	//think from an origin (center point) of the object you want to surround
	mina[0]=-2.0; //neg width 
	mina[1]=-2.0; //neg length 
	mina[2]=0.0; //down 
	maxa[0]=2.0; //pos width 
	maxa[1]=2.0; //pos length 
	maxa[2]=4.0; //up
	//set property so it can be touched
	entity_set_int(bbox_id, EV_INT_solid, SOLID_TRIGGER);		// set solid type
	entity_set_size(bbox_id,mina,maxa);
	
	return PLUGIN_CONTINUE;
}

public show_medic_ammo(id)
{
	if(is_user_alive(id) && !is_user_bot(id))
	{
		set_hudmessage(255, 10, 10, 0.80, 0.60, 0, 0.02, 6.0, 1.01, 1.1, 55);
		format(ammoMessage,127,"%L: %d\n%L: %d",id,"MEDIC_MEDKITS",medkits[id],id,"MEDIC_SYRINGES",syringes[id]);
		show_hudmessage(id,"%s",ammoMessage);
	}
	return PLUGIN_HANDLED;
}

public medic_heal()
{
	new m,p;
	new freehealth_distance = get_pcvar_num(cvar_medic_healdist);
	new freehealth = get_pcvar_num(cvar_medic_healthamt);
	new freehealth_max = get_pcvar_num(cvar_medic_healthmax);
	for (m=0;m<33;m++) //medics
	{
		if(is_user_alive(m) && ismedic[m])
		{
			new medic_health = get_user_health(m);
			if(medic_health < freehealth_max)
			{
				set_user_health(m,medic_health + freehealth);
			}
			for (p=0;p<33;p++) //players
			{
				
				if(is_user_alive(p) && p != m)
				{
					new player_origin[3],medic_origin[3];
					new mteam = get_user_team(m),pteam = get_user_team(p);
					get_user_origin(p,player_origin);
					get_user_origin(m,medic_origin);
					new distance = get_distance(medic_origin,player_origin);
					if(distance < freehealth_distance && mteam == pteam)
					{
						new player_health = get_user_health(p);
						if(player_health < freehealth_max)
						{
							medic_hp_given[m] += freehealth;
							set_user_health(p,player_health + freehealth);
							stamina_min[m]++;
							if(medic_hp_given[m] >= 100)
							{
								new steam[32], name[32],teamname[32];
								dod_set_user_kills(m,dod_get_user_kills(m) + 1,1);
								dod_set_user_score(m,dod_get_user_score(m) + 5,1);
								get_user_team(m,teamname,32);
								get_user_authid(m, steam, 31);
								get_user_name(m, name, 31);
								client_print(m,print_center,"Well Done, you have healed 100 HP your get a +50 health boost");
								set_user_health(m,get_user_health(m) + 50);
								log_message("\"%s<%d><%s><%s>\" triggered \"weaponstats\" (weapon \"healing\") (shots \"0\") (hits \"0\") (kills \"1\") (headshots \"0\") (tks \"0\") (damage \"0\") (deaths \"0\") (score \"5\")",name,get_user_userid(m),steam,teamname);
								medic_hp_given[m] -= 100;
							}
						}
					}
				}
			}
		}
	}
	set_task(get_pcvar_float(cvar_medic_healthtime),"medic_heal");
	return PLUGIN_CONTINUE;
}


