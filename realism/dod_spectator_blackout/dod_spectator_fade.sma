/* DoD Spectator Fade Out/Blackout

"Allows server operators the ability to control what players see when they are spectating" =|[76AD]|= TatsuSaisei

DESCRIPTION:
Plugin allows operators to decide if spectators have a view, if it is colored, and how transparent it is...
also allows you to set options for death spectators as well

INSTRUCTIONS:
* Cvars:

dod_specfade "1" - 0 = disable 1 = enable spectator fade usage
dod_deathfade "1" - 0 = disable 1 = enable death fade usage
dod_admin_specfade "1" - 0 = disable 1 = enable admin spectator fade usage
dod_admin_deathfade "1" - 0 = disable 1 = enable admin death fade usage
dod_deathfade_instant "1" - 0 = disable 1 = enable instant death blackout
dod_specfade_instant "1" - 0 = disable 1 = enable instant spectator blackout
dod_specfade_permanent "1" - 0 = disable 1 = enable spectator infinite blackout (until respawn)
dod_deathfade_permanent "1" - 0 = disable 1 = enable death infinite blackout (until respawn)

dod_deathfade_allies_red "0"
dod_deathfade_allies_green "0"
dod_deathfade_allies_blue "0"
dod_deathfade_allies_alpha "255"

dod_deathfade_axis_red "0"
dod_deathfade_axis_green "0"
dod_deathfade_axis_blue "0"
dod_deathfade_axis_alpha "255"

dod_specfade_allies_red "0"
dod_specfade_allies_green "255"
dod_specfade_allies_blue "0"
dod_specfade_allies_alpha "255"

dod_specfade_axis_red "255"
dod_specfade_axis_green "0"
dod_specfade_axis_blue "0"
dod_specfade_axis_alpha "255"

dod_specfade_generic_red "0"
dod_specfade_generic_green "0"
dod_specfade_generic_blue "0"
dod_specfade_generic_alpha "255"

dod_deathfade_admin_red "0"
dod_deathfade_admin_green "0"
dod_deathfade_admin_blue "0"
dod_deathfade_admin_alpha "0"

dod_specfade_admin_red "0"
dod_specfade_admin_green "0"
dod_specfade_admin_blue "0"
dod_specfade_admin_alpha "0"

*Defines
#define SERVER_ADMIN ADMIN_BAN - this is who the admin effects apply to - changes have to be made in the plugin source code and recompiled to take effect

VERSION INFO:
76.0
* Plugin Inception

76.1 2/22/07
* Plugin Release

76.2 3/10/07
* Corrected a minor cvar issue

KNOWN ISSUES:
MINOR: none ?
MAJOR: none ?

THINGS I WANT TO DO/ADD:
nothing yet ??

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

#define PLUGIN "DoD Spectator Fade"
#define VERSION "76.2"
#define AUTHOR "=|[76AD]|= TatsuSaisei"

#define SERVER_ADMIN ADMIN_BAN

new deathfade,specfade,perm_deathfade,perm_specfade,instant_deathfade,instant_specfade,admin_specfade,admin_deathfade;

new allies_red_death,allies_green_death,allies_blue_death,allies_alpha_death;	
new axis_red_death,axis_green_death,axis_blue_death,axis_alpha_death;	
new allies_red_spec,allies_green_spec,allies_blue_spec,allies_alpha_spec;
new axis_red_spec,axis_green_spec,axis_blue_spec,axis_alpha_spec;	
new gen_red_spec,gen_green_spec,gen_blue_spec,gen_alpha_spec;
new admin_red_death,admin_green_death,admin_blue_death,admin_alpha_death;
new admin_red_spec,admin_green_spec,admin_blue_spec,admin_alpha_spec;

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
	
	register_event("YouDied", "death_view", "bd");
	
	specfade = register_cvar("dod_specfade", "1");
	deathfade = register_cvar("dod_deathfade", "1");
	admin_specfade = register_cvar("dod_admin_specfade", "1");
	admin_deathfade = register_cvar("dod_admin_deathfade", "1");
	instant_deathfade = register_cvar("dod_deathfade_instant", "1");
	instant_specfade = register_cvar("dod_specfade_instant", "1");
	perm_deathfade = register_cvar("dod_deathfade_permanent", "1");
	perm_specfade = register_cvar("dod_specfade_permanent", "1");
	
	allies_red_death = register_cvar("dod_deathfade_allies_red", "0");
	allies_green_death = register_cvar("dod_deathfade_allies_green", "0");
	allies_blue_death = register_cvar("dod_deathfade_allies_blue", "0");
	allies_alpha_death = register_cvar("dod_deathfade_allies_alpha", "255");
	
	axis_red_death = register_cvar("dod_deathfade_axis_red", "0");
	axis_green_death = register_cvar("dod_deathfade_axis_green", "0");
	axis_blue_death = register_cvar("dod_deathfade_axis_blue", "0");
	axis_alpha_death = register_cvar("dod_deathfade_axis_alpha", "255");
	
	allies_red_spec = register_cvar("dod_specfade_allies_red", "0");
	allies_green_spec = register_cvar("dod_specfade_allies_green", "255");
	allies_blue_spec = register_cvar("dod_specfade_allies_blue", "0");
	allies_alpha_spec = register_cvar("dod_specfade_allies_alpha", "255");
	
	axis_red_spec = register_cvar("dod_specfade_axis_red", "255");
	axis_green_spec  = register_cvar("dod_specfade_axis_green", "0");
	axis_blue_spec = register_cvar("dod_specfade_axis_blue", "0");
	axis_alpha_spec = register_cvar("dod_specfade_axis_alpha", "255");
	
	gen_red_spec = register_cvar("dod_specfade_generic_red", "0");
	gen_green_spec  = register_cvar("dod_specfade_generic_green", "0");
	gen_blue_spec = register_cvar("dod_specfade_generic_blue", "0");
	gen_alpha_spec = register_cvar("dod_specfade_generic_alpha", "255");
	
	admin_red_death = register_cvar("dod_deathfade_admin_red", "0");
	admin_green_death = register_cvar("dod_deathfade_admin_green", "0");
	admin_blue_death = register_cvar("dod_deathfade_admin_blue", "0");
	admin_alpha_death = register_cvar("dod_deathfade_admin_alpha", "0");
	
	admin_red_spec = register_cvar("dod_specfade_admin_red", "0");
	admin_green_spec  = register_cvar("dod_specfade_admin_green", "0");
	admin_blue_spec = register_cvar("dod_specfade_admin_blue", "0");
	admin_alpha_spec = register_cvar("dod_specfade_admin_alpha", "0");
}

public death_view(id)
{
	if(!get_pcvar_num(deathfade)) return PLUGIN_CONTINUE;
	
	new team = get_user_team(id);
	new instant = get_pcvar_num(instant_deathfade);
	new perm = get_pcvar_num(perm_deathfade);
	
	if(perm) perm = 5;
	else perm = 1;
	
	if(!instant) instant =  1<<13 ;
	
	if(get_pcvar_num(admin_deathfade) && get_user_flags(id)&SERVER_ADMIN)
	{
		new AdminFade = get_user_msgid("ScreenFade");
		message_begin(MSG_ONE_UNRELIABLE,AdminFade,{0,0,0},id);
		write_short( instant );
		write_short(~0);
		write_short(perm);
		write_byte(get_pcvar_num(admin_red_death)); //r
		write_byte(get_pcvar_num(admin_green_death)); //g
		write_byte(get_pcvar_num(admin_blue_death)); //b
		write_byte(get_pcvar_num(admin_alpha_death)); //alpha
		message_end();
	}
	else if (team == ALLIES)
	{
		new AlliesFade = get_user_msgid("ScreenFade");
		message_begin(MSG_ONE_UNRELIABLE,AlliesFade,{0,0,0},id);
		write_short(instant);
		write_short(~0);
		write_short( perm);
		write_byte(get_pcvar_num(allies_red_death)); //r
		write_byte(get_pcvar_num(allies_green_death)); //g
		write_byte(get_pcvar_num(allies_blue_death)); //b
		write_byte(get_pcvar_num(allies_alpha_death)); //alpha
		message_end();
	}
	else if (team == AXIS)
	{
		new AxisFade = get_user_msgid("ScreenFade");
		message_begin(MSG_ONE_UNRELIABLE,AxisFade,{0,0,0},id);
		write_short(instant);
		write_short(~0);
		write_short( perm);
		write_byte(get_pcvar_num(axis_red_death)); //r
		write_byte(get_pcvar_num(axis_green_death)); //g
		write_byte(get_pcvar_num(axis_blue_death)); //b
		write_byte(get_pcvar_num(axis_alpha_death)); //alpha
		message_end();
	}
	return PLUGIN_CONTINUE;
}

public dod_client_changeteam(id, team, oldteam)
{
	if(!get_pcvar_num(specfade)) return PLUGIN_CONTINUE;
	
	new instant = get_pcvar_num(instant_specfade);
	new perm = get_pcvar_num(perm_specfade);
	
	if(perm) perm = 5;
	else perm = 1;
	
	if(!instant) instant =  1<<13 ;
	
	
	if(get_pcvar_num(admin_specfade) && get_user_flags(id)&SERVER_ADMIN)
	{
		new AdminFade = get_user_msgid("ScreenFade");
		message_begin(MSG_ONE_UNRELIABLE,AdminFade,{0,0,0},id);
		write_short( instant );
		write_short(~0);
		write_short(perm);
		write_byte(get_pcvar_num(admin_red_spec)); //r
		write_byte(get_pcvar_num(admin_green_spec)); //g
		write_byte(get_pcvar_num(admin_blue_spec)); //b
		write_byte(get_pcvar_num(admin_alpha_spec)); //alpha
		message_end();
	}
	else if (oldteam == ALLIES && team == 3)
	{
		new AlliesFade = get_user_msgid("ScreenFade");
		message_begin(MSG_ONE_UNRELIABLE,AlliesFade,{0,0,0},id);
		write_short( instant );
		write_short(~0);
		write_short(perm);
		write_byte(get_pcvar_num(allies_red_spec)); //r
		write_byte(get_pcvar_num(allies_green_spec)); //g
		write_byte(get_pcvar_num(allies_blue_spec)); //b
		write_byte(get_pcvar_num(allies_alpha_spec)); //alpha
		message_end();
	}
	else if (oldteam == AXIS && team == 3)
	{
		new AxisFade = get_user_msgid("ScreenFade");
		message_begin(MSG_ONE_UNRELIABLE,AxisFade,{0,0,0},id);
		write_short( instant);
		write_short(~0);
		write_short(perm);
		write_byte(get_pcvar_num(axis_red_spec)); //r
		write_byte(get_pcvar_num(axis_green_spec)); //g
		write_byte(get_pcvar_num(axis_blue_spec)); //b
		write_byte(get_pcvar_num(axis_alpha_spec)); //alpha
		message_end();
	}
	else if (team == 3)
	{
		new SpecFade = get_user_msgid("ScreenFade");
		message_begin(MSG_ONE_UNRELIABLE,SpecFade,{0,0,0},id);
		write_short( instant );
		write_short(~0);
		write_short(perm);
		write_byte(get_pcvar_num(gen_red_spec)); //r
		write_byte(get_pcvar_num(gen_green_spec)); //g
		write_byte(get_pcvar_num(gen_blue_spec)); //b
		write_byte(get_pcvar_num(gen_alpha_spec)); //alpha
		message_end();
	}
	return PLUGIN_CONTINUE;
}
