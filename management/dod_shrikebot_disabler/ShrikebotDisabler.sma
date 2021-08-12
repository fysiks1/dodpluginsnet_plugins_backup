/*
 DoD ShrikeBot Disabler
 Brought to you by TooLz

 Thanks to DoDPlugins.net for making it all possible!
*/
#include <amxmodx>
#include <amxmisc>
new PlayerCount
public plugin_init(){
	register_plugin("DoD Shrikebot Disabler","1.0","TooLz")
	register_cvar("dod_shrikebot_maxbots","6")
}
public client_authorized(id){
	if(!is_user_bot(id)){
		PlayerCount++
		if(PlayerCount >= get_cvar_num("dod_shrikebot_maxbots")){
			server_cmd("shr ^"max_bots 0^"")
			return PLUGIN_CONTINUE
		}
	}
	return PLUGIN_CONTINUE
}
public client_disconnect(id){
	if(!is_user_bot(id)){
		PlayerCount--
		if(PlayerCount < get_cvar_num("dod_shrikebot_maxbots")){
			server_cmd("shr ^"max_bots %d^"",get_cvar_num("dod_shrikebot_maxbots"))
			return PLUGIN_CONTINUE
		}
	}
	return PLUGIN_CONTINUE
}