//////////////////////////////////////////////////////////////////////////////////
//Description i made this plugin in about 30mins for my clan/////////////////////
//so i though i would share it with the rest of the gaming community enjoy xD///
//AMX_FRIENDLYFIRE/////////////////////////////////////////////////////////////
//MADE BY BLOBBY//////////////////////////////////////////////////////////
//Commads are as follows:-///////////////////////////////////////////////////
//amx_friendlyfire 1=on 0=off///////////////////////////////////////////////
//say /ff tells public players if ff is on or off//////////////////////////
//////////////////////////////////////////////////////////////////////////

#include <amxmodx>

public admin_ff(id,level){
	if (!(get_user_flags(id)&level)){
		console_print(id,"You have no access to that command.")
		return PLUGIN_HANDLED
	}
	if (read_argc() < 2){
			new ff_cvar = get_cvar_num("mp_friendlyfire")
			console_print(id,"^"mp_friendlyfire^" is ^"%i^"",ff_cvar)
			return PLUGIN_HANDLED
	}

	new ff_s[2]
	read_argv(1,ff_s,2)
	new ff = str_to_num(ff_s)

	if(ff == 1) {
		server_cmd("mp_friendlyfire 1")
		console_print(id,"Friendly fire is now on")
	}
	else if(ff == 0) {
		server_cmd("mp_friendlyfire 0")
		console_print(id,"Friendly fire is now off")
	}

	return PLUGIN_HANDLED
}

public check_ff(id) {
	new ff = get_cvar_num("mp_friendlyfire")
	if(ff == 1)
		client_print(id,print_chat,"Friendly fire is on")
	else if(ff == 0)
		client_print(id,print_chat,"Friendly fire is off")
	return PLUGIN_HANDLED
}

public plugin_init(){
	register_plugin("amx_friendlyfire","1.0","BLOBBY")
        register_cvar("amx_friendlyfire", "Version 1.0 BY Blobby", FCVAR_SERVER|FCVAR_SPONLY)
	register_concmd("amx_friendlyfire","admin_ff",ADMIN_LEVEL_H,"< 0/1 >")
	register_clcmd("say /ff","check_ff")
	register_clcmd("say_team /ff","check_ff")
	return PLUGIN_CONTINUE
}
