/*

Wanted! plugin
By: SidLuke/[RST] FireStorm
Updated By: Hell Phoenix         Hell_Phoenix@frenchys-pit.com
                                   http://www.frenchys-pit.com

Player with the best personal score on you is Wanted!,
if his kills(on you) - your kills(on him) >= (dod_wanted_start)

Cvars:
dod_wanted_enabled <1/0>    = enable\disable plugin
dod_wanted_start <amount>   = show Wanted! when difference between kills is >= amount
dod_wanted_onrespawn <1/0>  = show Wanted! after respawn
dod_wanted_personal <1/0>   = enable\disable personal kills MOTD

Say commands:
"/wanted" - Wanted! info
"/personal" - personal kills MOTD

Changelog:
   V1.0 - Updated to amxx 1.70 Standards
   
*/

#include <amxmodx>
#include <dodx>

#define MAX_BUFOR 2047 + 1
#define PLUGIN "DoD Wanted"
#define VERSION "1.0"
#define AUTHOR "AMXX DoD Community"

new g_enabled
new g_onrespawn
new g_start
new g_personal

new pkills[33][33]

new wantedmsg[3][]={"Go and get him!","Catch him if you can!","Fight for your honour!"}

public plugin_init(){
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_statsfwd(XMF_DEATH)
	register_event("ResetHUD","on_respawn","be")
	g_enabled = register_cvar("dod_wanted_enabled","1")
	g_onrespawn = register_cvar("dod_wanted_onrespawn","1")
	g_start = register_cvar("dod_wanted_start","3")
	g_personal = register_cvar("dod_wanted_personal","1")
	register_clcmd("say /wanted", "on_say")
	register_clcmd("say /personal","personal")
	return PLUGIN_CONTINUE
}

public plugin_modules(){
	require_module("dodx")
}

public client_disconnect(id){
	for(new i=1;i<33;i++)
	pkills[id][i] = 0
}

public client_death(killer,victim,wpnindex,hitplace,TK){
	if(TK == 0){
		pkills[killer][victim] += 1
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public get_wanted(id){
	new playerteam = get_user_team(id)
	new wantedID = 0
	new wStart
	wStart = get_pcvar_num(g_start)
	new diff
	diff = wStart
	new savekills
	savekills = 0
	for (new i=1;i<33;i++)
	if ((pkills[i][id] - pkills[id][i]) >= diff){
		new wantedteam = get_user_team(i)
		if(playerteam != wantedteam){
			if((pkills[i][id] - pkills[id][i]) == diff){
				if(pkills[i][id] > savekills){
					wantedID = i
					savekills = pkills[i][id]
				}
			}
			else {
				wantedID = i
				savekills = pkills[i][id]
				diff = (pkills[i][id] - pkills[id][i])
			}
		}

	}
	return wantedID
}

public on_respawn(id){
	if(get_pcvar_num(g_enabled) == 1 && get_pcvar_num(g_onrespawn) == 1){
		new wantedID = get_wanted(id)
		if( wantedID != 0){
			new wanted_name[32]
			get_user_name(wantedID,wanted_name,32)
			set_hudmessage(200, 100, 0, -1.0, 0.30, 0, 3.0, 3.0, 0.1, 0.2, 1)
			show_hudmessage(id,"Wanted!^n%s %d kill(s) -- %d death(s)^n%s",wanted_name,pkills[wantedID][id],pkills[id][wantedID],wantedmsg[random_num(0,2)])
		}
	}
	return PLUGIN_CONTINUE
}

public on_say(id){
	if(get_pcvar_num(g_enabled) == 1){
		new wantedID = get_wanted(id)
		if(wantedID != 0){
			new wanted_name[32]
			get_user_name(wantedID,wanted_name,32)
			client_print(id,print_chat,"[AMX] Wanted! %s with %d kill(s) -- %d death(s)",wanted_name,pkills[wantedID][id],pkills[id][wantedID])
		}
		else {
			client_print(id,print_chat,"[AMX] You have no Wanted!...")
		}
	}
	return PLUGIN_HANDLED
}

public personal(id){
	if(get_pcvar_num(g_personal) == 1){
		new bufor[MAX_BUFOR]
		new playerteam = get_user_team(id)
		new pos = 0
		new lp = 1
		for ( new i = 1;i < 33;i++){
			if(is_user_connected(i)){
				new xteam = get_user_team(i)
				if(playerteam != xteam){
					new x_name[32]
					get_user_name(i,x_name,32)
					pos += format(bufor[pos],MAX_BUFOR - pos, "%2d  %s  %d kill(s)  -- %d death(s)^n",lp,x_name,pkills[i][id],pkills[id][i])
					lp++
				}
			}
		}
		show_motd(id,bufor,"Personal kills")
	}
	return PLUGIN_HANDLED
}
