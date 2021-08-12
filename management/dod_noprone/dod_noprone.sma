#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <dodx>

#define PLUGIN "dod_noprone"
#define VERSION "76.1"
#define DEVS "=|[76AD]|= TatsuSaisei"
#define AUTHOR "AMXX DoD Community"

new p_enabled;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	
	//-----------------------------------------------------------
	new plugin_info[128],pfilename[32],pname[32],pversion[16],pauthor[32],pstatus[16];
	get_plugin(-1,pfilename,31,pname,31,pversion,15,pauthor,31,pstatus,15);
	strcat ( plugin_info, "Version: ", 127) ;
	strcat ( plugin_info, VERSION, 127) ;
	strcat ( plugin_info, " by: ", 127) ;
	strcat ( plugin_info, DEVS, 127) ;
	register_cvar(pfilename, plugin_info, FCVAR_SERVER|FCVAR_SPONLY);
	register_cvar(PLUGIN, AUTHOR, FCVAR_SERVER|FCVAR_SPONLY);
	//-----------------------------------------------------------
	
	p_enabled = register_cvar("dod_noprone","1");
	register_forward( FM_PlayerPreThink, "hook_PlayerPreThink" );
}

public hook_PlayerPreThink( id ) 
{
	// Check classes, plugin enabled, etc. here
	if(!get_pcvar_num(p_enabled)) return PLUGIN_CONTINUE
	if( dod_get_pronestate( id )) dod_set_pronestate( id, 0 );
	return PLUGIN_CONTINUE
}

stock dod_set_pronestate( id, flag ) 
{
	set_pev( id, pev_iuser3, flag );
}
