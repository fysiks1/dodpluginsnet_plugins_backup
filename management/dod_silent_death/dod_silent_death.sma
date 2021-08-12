/* DoD Silent Death

"This is a little something small but useful to realism servers... when a player dies they can not hear anything any longer... including voice chat..." =|[76AD]|= TatsuSaisei

DESCRIPTION:

INSTRUCTIONS:
* Cvars:
dod_silent_death_on "1" - 0 = disable 1 = enable a silent death
dod_silent_spec_on "1" - 0 = disable 1 = enable a silent spectator
dod_silent_death_msg "1"- 0 = disable 1 = enable a silent death message
dod_silent_death_msgx "-1.0"
dod_silent_death_msgy "-1.0"
dod_silent_death_msgr "255"
dod_silent_death_msgg "0"
dod_silent_death_msgb "0"
dod_silent_death_msg_time "5.0"
dod_silent_death_custommsg "Volumes will be reenabled shortly.... Enjoy the silence..."

VERSION INFO:
76.0
* Plugin Inception

76.1
* Public Release

KNOWN ISSUES:
MINOR:does not "lock" the volumes - smart players can easily circumvent the spectator silence by reentering volumes...
MAJOR: none ?

THINGS I WANT TO DO/ADD:
nothing?

AUTHOR INFO:
Joseph Meyers AKA =|[76AD]|= TatsuSaisei - 76th Airborne Division RANK: General of the Army
http://76AD.com
http://TatsuSaisei.com
http://JosephMeyers.com
http://CustomDoD.com
*/

#include <amxmodx>
#include <dodx>

#pragma semicolon 1
#pragma ctrlchar '\'

#define PLUGIN "DoD Silent Death"
#define VERSION "76.1"
#define AUTHOR "=|[76AD]|= TatsuSaisei"




new Float:player_norm_mp3_vol[33];
new Float:player_norm_vol[33];
new plugin_enable,spec_enable,msg_enable,silent_death_msgx,silent_death_msgy,silent_death_msgr,silent_death_msgg,silent_death_msgb,silent_death_msg_time,silent_death_custommsg;

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	//-----------------------------------------------------------
	new plugin_info[128];
	strcat ( plugin_info, "Version: ", 128 ) ;
	strcat ( plugin_info, VERSION, 128 ) ;
	strcat ( plugin_info, " by: ", 128 ) ;
	strcat ( plugin_info, AUTHOR, 128 ) ;
	register_cvar(PLUGIN, plugin_info, FCVAR_SERVER|FCVAR_SPONLY);
	//-----------------------------------------------------------
	
	register_event("YouDied", "change_view", "bd");
	plugin_enable = register_cvar("dod_silent_death_on", "1");
	spec_enable = register_cvar("dod_silent_spec_on", "1");
	msg_enable = register_cvar("dod_silent_death_msg", "1");
	silent_death_msgx = register_cvar("dod_silent_death_msgx", "-1.0");
	silent_death_msgy = register_cvar("dod_silent_death_msgy", "-1.0");
	silent_death_msgr = register_cvar("dod_silent_death_msgr", "255");
	silent_death_msgg = register_cvar("dod_silent_death_msgg", "0");
	silent_death_msgb = register_cvar("dod_silent_death_msgb", "0");
	silent_death_msg_time = register_cvar("dod_silent_death_msg_time" , "5.0");
	silent_death_custommsg = register_cvar("dod_silent_death_custommsg" , "Volumes will be reenabled shortly.... Enjoy the silence...");
	
}
public dod_client_changeteam(id, team, oldteam)
{
	if(!get_pcvar_num(plugin_enable)) return PLUGIN_CONTINUE;
	if (get_pcvar_num(spec_enable) && team == 3)
	{
		volume_down_5(id);
	}
	else if (team ==3) volume_fix(id);
	return PLUGIN_CONTINUE;
}

public change_view(id)
{
	if(get_pcvar_num(plugin_enable) && is_user_connected(id) && !is_user_alive(id) && !is_user_bot(id))
	{
		volume_down_1(id);
		if (get_pcvar_num(msg_enable))
		{
			new silent_msg[256];
			get_pcvar_string(silent_death_custommsg,silent_msg,256);
			set_hudmessage(get_pcvar_num(silent_death_msgr), get_pcvar_num(silent_death_msgg), get_pcvar_num(silent_death_msgb), get_pcvar_float(silent_death_msgx), get_pcvar_float(silent_death_msgy), 0, 6.0, get_pcvar_float(silent_death_msg_time));
			show_hudmessage(id, silent_msg);
		}
		
	}
	return PLUGIN_CONTINUE;
}

public dod_client_spawn(id)
{
	if(get_pcvar_num(plugin_enable) && !is_user_bot(id) )
	{
		volume_fix(id);
	}
	return PLUGIN_CONTINUE;
}

public client_connect(id) 
{ 
	if (get_pcvar_num(plugin_enable) && !is_user_bot(id) && is_user_connected(id)) 
	{
		query_client_cvar(id, "MP3Volume", "mp3_remember");
		query_client_cvar(id, "volume", "vol_remember");
	}
	return PLUGIN_CONTINUE;
	
} 

public client_disconnect(id) 
{ 
	if (get_pcvar_num(plugin_enable) && !is_user_bot(id) && is_user_connected(id)) 
	{
		volume_fix(id);
	}
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

public volume_down_1(id) 
{
	client_cmd(id , "volume %f",player_norm_vol[id] - 0.2);
	client_cmd(id , "MP3Volume %f",player_norm_mp3_vol[id] - 0.2);
	set_task(0.5 , "volume_down_2" , id);
}

public volume_down_2(id) 
{
	client_cmd(id , "volume %f",player_norm_vol[id] - 0.4);
	client_cmd(id , "MP3Volume %f",player_norm_mp3_vol[id] - 0.4);
	set_task(0.5, "volume_down_3" , id);
}

public volume_down_3(id) 
{
	client_cmd(id , "volume %f",player_norm_vol[id] - 0.6);
	client_cmd(id , "MP3Volume %f",player_norm_mp3_vol[id] - 0.6);
	set_task(0.5 , "volume_down_4" , id);
}

public volume_down_4(id) 
{
	client_cmd(id , "volume %f",player_norm_vol[id] - 0.8);
	client_cmd(id , "MP3Volume %f",player_norm_mp3_vol[id] - 0.8);
	set_task(0.5 , "volume_down_5" , id);
}

public volume_down_5(id) 
{
	client_cmd(id , "volume 0.0");
	client_cmd(id , "MP3Volume 0.0");
	client_cmd(id , "MP3 stop");
}

public volume_fix(id) 
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
