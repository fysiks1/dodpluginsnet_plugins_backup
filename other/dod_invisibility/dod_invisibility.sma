/* DOD INVISIBILITY
   Made by Wilson 29thID from Dodplugins.net
   
   CVARS
   dod_invisibility     :: 1 enables invisibility, 0 disables invisibility
   dod_invisibility_amt :: From 0 to 255 (0 being entirely invisible, 255 being entirely visibile)
   
   CLIENT COMMANDS
   invisibility_on      :: Makes client invisible
   invisibility_off     :: Makes client visible
*/

// Define admin level is required here (third part)
#define INVISIBILE_ADMIN ADMIN_IMMUNITY

#include <amxmodx>
#include <amxmisc>
#include <fun>

new isInvisible[33]

public plugin_init() {
	register_plugin("Dod Invisibility", "1.0", "Wilson - Dodplugins.net")
	
	register_cvar("dod_invisibility", "1")
	register_cvar("dod_invisibility_amt", "0")
	register_concmd("invisibility_on", "invis_on", INVISIBILE_ADMIN)
	register_concmd("invisibility_off", "invis_off", INVISIBILE_ADMIN)
	
	register_event("ResetHUD", "reset_hud", "be")
}

public reset_hud(id) {
	if(isInvisible[id])
		invis_on(id,INVISIBILE_ADMIN,1)
}

public client_connect(id) {	
	isInvisible[id] = 0;
}

public invis_on(id,level,cid) {
	if( (!get_cvar_num("dod_invisibility")) || (!cmd_access(id,level,cid,1)) )
		return PLUGIN_HANDLED;
		
	new invisamt = get_cvar_num("dod_invisibility_amt");
	set_user_rendering(id,kRenderFxNone,0,0,0,kRenderTransAlpha,invisamt);
	set_user_footsteps(id, 1);
	isInvisible[id] = 1;
	client_print(id, print_chat, "You are now invisible.");
	return PLUGIN_HANDLED;
}

public invis_off(id,level,cid) {
	if( (!get_cvar_num("dod_invisibility")) || (!cmd_access(id,level,cid,1)) )
		return PLUGIN_HANDLED;
	set_user_rendering(id,kRenderFxNone,0,0,0,kRenderTransAlpha,255);
	set_user_footsteps(id, 0);
	isInvisible[id] = 0;
	client_print(id, print_chat, "You are now visible.");
	
	return PLUGIN_HANDLED;
}
