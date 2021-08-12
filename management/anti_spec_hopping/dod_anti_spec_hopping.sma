/* Plugin requested by {GSR} Rollin~Death -=SR=-

INSTRUCTIONS:
* Say Commands:
say /specmode - Command to let others know if plugin is active and how much time to wait

* Cvars:
dod_spec_mode "1" - Enables the plugin (0=off/1=on)
dod_spec_motd "1" - Enables motd display (0=off/1=on)
dod_spec_timer "1" - Enables timer display (0=off/1=on)
dod_spec_motd_url "http://dodplugins.net" - URL for the motd display
dod_spec_motd_title "Anti-Spec Hopping" - motd title (also used in say message output)
dod_spec_free_msg "You are free to choose a team and begin playing again!" - message to display to player once timer runs out
dod_spec_timer_top "SPECTATOR" - word displayed over the remaining time left
dod_spec_timer_bottom "TIMER" - word displayed under the remaining time left
dod_spec_timer_r "255" - amount of RED color used in timer display
dod_spec_timer_g "0" - amount of GREEN color used in timer display
dod_spec_timer_b "0" - amount of BLUE color used in timer display
dod_spec_timer_x" -1.0" - position of timer on X axis (-1.0=centered/0.00-0.99=valid positions)
dod_spec_timer_y "0.60" - position of timer on Y axis (-1.0=centered/0.00-0.99=valid positions)
dod_spec_time "30" - number of seconds before being allowed to rejoin a team
	
VERSION INFO:
76.0
* Plugin Inception

76.1
* Public release to dodplugins.net

KNOWN ISSUES:
MINOR:
MAJOR:

THINGS I WANT TO DO/ADD:

AUTHOR INFO:
Joseph Meyers AKA =|[76AD]|= TatsuSaisei - 76th Airborne Division RANK: General of the Army
http://76AD.com
http://TatsuSaisei.com
http://JosephMeyers.com
http://CustomDoD.com
*/

#include <amxmodx>

#pragma semicolon 1
#pragma ctrlchar '\'

#define PLUGIN "dod_Anti_Spec_Hopping"
#define VERSION "76.1"
#define AUTHOR "=|[76AD]|= TatsuSaisei =*GoA*="

#define DELAY_TASK 46837

new canPlay[33] = true;
new param[1],timer[33] = 0;
new motd_url, motd_title;
new in_spec_time;
new timer_ttitle,timer_btitle,timer_r,timer_g,timer_b,timer_x,timer_y;
new free2play, spec_toggle,timer_toggle,motd_toggle;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	//-----------------------------------------------------------
	new plugin_info[128];
	strcat ( plugin_info, "Version: ", 127 ) ;
	strcat ( plugin_info, VERSION, 127 ) ;
	strcat ( plugin_info, " by: ", 127 ) ;
	strcat ( plugin_info, AUTHOR, 127 ) ;
	register_cvar(PLUGIN, plugin_info, FCVAR_SERVER|FCVAR_SPONLY);
	//-----------------------------------------------------------
	
	register_clcmd("jointeam 1","block_alliesrejoin");
	register_clcmd("jointeam 2","block_axisrejoin");
	register_clcmd("jointeam 3","time_spec");
	register_clcmd("say /specmode","show_cvars");
	
	spec_toggle = register_cvar("dod_spec_mode","1");
	timer_toggle = register_cvar("dod_spec_timer","1");
	motd_toggle = register_cvar("dod_spec_motd","1");
	motd_url = register_cvar("dod_spec_motd_url","http://dodplugins.net");
	motd_title = register_cvar("dod_spec_motd_title","Anti-Spec Hopping");
	free2play = register_cvar("dod_spec_free_msg","You are free to choose a team and begin playing again!");
	timer_ttitle = register_cvar("dod_spec_timer_top","SPECTATOR");
	timer_btitle = register_cvar("dod_spec_timer_bottom","TIMER");
	timer_r = register_cvar("dod_spec_timer_r","255");
	timer_g = register_cvar("dod_spec_timer_g","0");
	timer_b = register_cvar("dod_spec_timer_b","0");
	timer_x = register_cvar("dod_spec_timer_x","-1.0");
	timer_y = register_cvar("dod_spec_timer_y","0.60");
	in_spec_time = register_cvar("dod_spec_time","30");
}

public show_cvars(id)
{
	new  mtitle[32];
	get_pcvar_string(motd_title,mtitle,31);
	client_print(id, print_chat,"%s is %s",mtitle,get_pcvar_num(spec_toggle)?"ON":"OFF");
	if(get_pcvar_num(spec_toggle))
	{
		client_print(id, print_chat,"You must wait %d seconds before being able to respawn on a new team",get_pcvar_num(in_spec_time));
	}
}

public client_putinserver(id)
{
	canPlay[id] = true;
	timer[id] = 0;
}

public reset_spec_flag(param[])
{
	new id = param[0],msg[64];
	get_pcvar_string(free2play,msg,63);
	client_print(id,print_chat, msg);
	timer[id] = 0;
	canPlay[id] = true;
}

public time_spec(id)
{
	if(get_pcvar_num(spec_toggle))
	{
		if(!canPlay[id])
		{
			wait_tasks(id);
			return PLUGIN_HANDLED;
		}
		else slow_spawn(id);
	}
	return PLUGIN_CONTINUE;
}

public block_axisrejoin(id)
{
	if(!canPlay[id])
	{
		wait_tasks(id);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public block_alliesrejoin(id)
{
	if(!canPlay[id])
	{
		wait_tasks(id);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public slow_spawn(id)
{
	param[0] = id;
	canPlay[id] = false;
	set_task(get_pcvar_float(in_spec_time),"reset_spec_flag",DELAY_TASK+id,param,1);
	if(get_pcvar_num(timer_toggle)) set_task(1.0,"show_timer",DELAY_TASK+id+33,param,1,"a",get_pcvar_num(in_spec_time));
}

public wait_tasks(id)
{
	if(get_pcvar_num(motd_toggle))
	{
		new mpage[512], mbody[128], mtitle[32];
		get_pcvar_string(motd_url,mbody,127);
		get_pcvar_string(motd_title,mtitle,31);
		format(mpage,511,"<frameset cols=\"*\"><frame name=\"top\" src=\"%s\"></frameset>",mbody);
		show_motd(id,mpage,mtitle);
	}
}

public show_timer(param[])
{
	new id = param[0];
	if(timer[id] > 0 && timer[id] < 30)
	{
		new ttitle[16], btitle[16];
		get_pcvar_string(timer_ttitle,ttitle,15);
		get_pcvar_string(timer_btitle,btitle,15);
		set_hudmessage(get_pcvar_num(timer_r), get_pcvar_num(timer_g), get_pcvar_num(timer_b), get_pcvar_float(timer_x), get_pcvar_float(timer_y), 0, 1.0, 1.0,0.0,0.0,-1);
		show_hudmessage(id, "%s\n| %d |\n%s",ttitle,get_pcvar_num(in_spec_time)-timer[id],btitle);	
	}
	timer[id]++;
}

