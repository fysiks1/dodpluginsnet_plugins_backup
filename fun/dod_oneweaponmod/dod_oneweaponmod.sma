/* DoD One Weapon Mod 
*  Originally by: SidLuke ( sidluke@o2.pl )
*  Updated by: Hell Phoenix ( Hell_Phoenix@frenchys-pit.com )
*  Version:	2.0
*  Description:
*    With this plugin you can set specific weapon battle
*
*   Thanks to Wilson from dodplugins for the scoped fg42/enfield stocks
*
*  Commands:
*    amx_oneweapon 0|1  -  enable/disable plugin
*    amx_setoneweapon < weapon index >  -  use this command to set weapon you want by Index number
*    amx_owmmenu - menu
*
*  Known Issues:
*    When choosing scoped fg42 or scoped enfield, your first shot with it you drop it...but when you pick
*     it up again, its then fine.  There currently is no way around this.  You must either drop your weapon
*     and pick it back up or fire it and pick it back up.
*
*  Versions:
*    1.0.1  Last known version by Sidluke...fixed some menu things
*    2.0    First version by Hell Phoenix
*             - Added all weapons to the plugin including scoped fg42/enfield
*             - Rewrote much of the plugin to current standards including using the new menu system
*    2.1    Fixed missing MG34/42 and 30 Cal.
*           Fixed it not killing everyone when called from menu
*
*/

#include <amxmodx>
#include <amxmisc>
#include <dodx>
#include <fun>
#include <dodfun>
#include <fakemeta>

#define NADE_ON (1<<0)
#define NADE_HUD (1<<1)
#define NADE_SOUND (1<<2)
#define WEAPONNUM 38

#define PLUGIN "DoD One Weapon Mod"
#define VERSION "2.1"
#define AUTHOR "AMXX DoD Community"


new g_nadecheck
new Float:g_spawntime[33]
new bool:g_OneWeaponEnabled
new g_owm_weapon
new owm_weapon

new g_WeaponData[WEAPONNUM][] = {
	"",
	"American Knife", 	//1
	"German Knife",		//2
	"Colt",			//3
	"Luger",		//4
	"Garand",		//5
	"Scoped K98",		//6
	"Thompson",		//7
	"STG44",		//8
	"Sringfield",		//9
	"K98",			//10
	"Bar",			//11
	"MP40",			//12
	"Handgrenade",		//13
	"Stickgrenade",		//14
	"",
	"",
	"MG42",			//17
	"30_CAL",		//18
	"Spade",		//19
	"M1 Carbine",		//20
	"MG34",			//21
	"Greasegun",		//22
	"FG42",			//23
	"K43",			//24
	"Enfield",		//25
	"Sten",			//26
	"Bren",			//27
	"Webley",		//28
	"Bazooka",		//29
	"Panzerschreck",	//30
	"Piat",			//31
	"Scoped FG42",		//32
	"Folding Carbine",	//33
	"",
	"Scoped Enfield",	//34
	"Mills Bomb",		//35
	"British Knife"		//36
}

new g_AmmoData[WEAPONNUM] = {
	0,
	0,
	0,
	14,
	24,
	80,
	60,
	180,
	180,
	50,
	60,
	240,
	180,
	
	// grenades
	3,
	3,
	0,
	0,
	
	500,
	300,
	0,
	150,
	375,
	180,
	240,
	70,
	50,
	180,
	150,
	12,
	
	5,
	5,
	5,
	240,
	150,
	0,
	50,
	3,
	0
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("amx_owmmenu","cmdOWMCfgMenu",ADMIN_LEVEL_A,"- displays One Weapon Mod configuration menu")	
	register_concmd("amx_oneweapon","cmdActivate",ADMIN_LEVEL_A,"<1|0> - One weapon only mode")
	register_concmd("amx_setoneweapon","cmdSetWeapon",ADMIN_LEVEL_A,"<1-31> - Set weapon for One weapon only mode")
	register_event("ResetHUD","eResetHUD","be")
	register_event("CurWeapon","eCurWeapon","be","1=1")
	register_event("ReloadDone","eReloadDone","be")
	owm_weapon = register_cvar("amx_owm_weapon","5")
	g_owm_weapon = get_pcvar_num(owm_weapon)
	
}




public cmdOWMCfgMenu(id,level,cid) {
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	
	new OneWeaponMenu = menu_create("\rDoD OneWeapon Menu", "OWMHandler")
	if ( g_OneWeaponEnabled )
		menu_additem(OneWeaponMenu, "Disable", "1", 0)
	else 
		menu_additem(OneWeaponMenu, "Enable", "1", 0)
	
	menu_additem(OneWeaponMenu, "Garand", "2", 0)
	menu_additem(OneWeaponMenu, "Enfield", "3", 0)
	menu_additem(OneWeaponMenu, "M1 Carbine", "4", 0)
	menu_additem(OneWeaponMenu, "K98", "5", 0)
	menu_additem(OneWeaponMenu, "K43", "6", 0)
	menu_additem(OneWeaponMenu, "Springfield", "7", 0)
	menu_additem(OneWeaponMenu, "Scoped Kar", "8", 0)
	menu_additem(OneWeaponMenu, "Scoped Enfield", "9", 0)
	menu_additem(OneWeaponMenu, "Scoped fg42", "10", 0)
	menu_additem(OneWeaponMenu, "Colt", "11", 0)
	menu_additem(OneWeaponMenu, "Webley", "12", 0)
	menu_additem(OneWeaponMenu, "Luger", "13", 0)
	menu_additem(OneWeaponMenu, "Thompson", "14", 0)
	menu_additem(OneWeaponMenu, "Sten", "15", 0)
	menu_additem(OneWeaponMenu, "Grease", "16",0)
	menu_additem(OneWeaponMenu, "MP40", "17", 0)
	menu_additem(OneWeaponMenu, "STG 44", "18", 0)
	menu_additem(OneWeaponMenu, "Bar", "19", 0)
	menu_additem(OneWeaponMenu, "Bren", "20", 0)
	menu_additem(OneWeaponMenu, "Fg42", "21", 0)
	menu_additem(OneWeaponMenu, "Handgrenade", "22", 0)
	menu_additem(OneWeaponMenu, "Stickgrenade", "24", 0)
	menu_additem(OneWeaponMenu, "Bazooka", "25", 0)
	menu_additem(OneWeaponMenu, "Piat", "26", 0)
	menu_additem(OneWeaponMenu, "Pchreck", "27", 0)
	menu_additem(OneWeaponMenu, "Knife", "28", 0)
	menu_additem(OneWeaponMenu, "Spade", "29", 0)
	menu_additem(OneWeaponMenu, "Gerknife", "30", 0)
	menu_additem(OneWeaponMenu, "MG42", "31", 0)
	menu_additem(OneWeaponMenu, "MG34", "32", 0)
	menu_additem(OneWeaponMenu, "30 CAL", "33", 0)
	menu_setprop(OneWeaponMenu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, OneWeaponMenu, 0)
	return PLUGIN_HANDLED
}

public OWMHandler(id, OneWeaponMenu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(OneWeaponMenu)
		return PLUGIN_HANDLED
	}
	new data[6], iName[64]
	new access, callback
	menu_item_getinfo(OneWeaponMenu, item, access, data,5, iName, 63, callback)
	new key = str_to_num(data)
	
	switch(key)
	{
		case 1:{
			if ( g_OneWeaponEnabled )
				server_cmd("amx_oneweapon 0")
			
			else
				server_cmd("amx_oneweapon 1")
			
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 2:{
			set_owm( id , DODW_GARAND)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 3:{ 
			set_owm( id , DODW_ENFIELD)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 4:{
			set_owm( id , DODW_M1_CARBINE)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 5:{
			set_owm( id , DODW_KAR)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 6:{
			set_owm( id , DODW_K43)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 7:{
			set_owm( id , DODW_SPRINGFIELD)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 8:{
			set_owm( id , DODW_SCOPED_KAR)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 9:{
			set_owm( id , DODW_SCOPED_ENFIELD)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 10:{
			set_owm( id , DODW_SCOPED_FG42)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 11:{
			set_owm( id , DODW_COLT)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 12:{
			set_owm( id , DODW_WEBLEY)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 13:{
			set_owm( id , DODW_LUGER)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 14:{
			set_owm( id , DODW_THOMPSON)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 15:{
			set_owm( id , DODW_STEN)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 16:{
			set_owm( id , DODW_GREASEGUN)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 17:{
			set_owm( id , DODW_MP40)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 18:{
			set_owm( id , DODW_STG44)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 19:{
			set_owm( id , DODW_BAR)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 20:{
			set_owm( id , DODW_BREN)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 21:{
			set_owm( id , DODW_FG42)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 22:{
			set_owm( id , DODW_HANDGRENADE)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 24:{
			set_owm( id , DODW_STICKGRENADE)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 25:{
			set_owm( id , DODW_BAZOOKA)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 26:{
			set_owm( id , DODW_PIAT)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 27:{
			set_owm( id , DODW_PANZERSCHRECK)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 28:{
			set_owm( id , DODW_AMERKNIFE)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 29:{
			set_owm( id , DODW_SPADE)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 30:{
			set_owm( id , DODW_GERKNIFE)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 31:{
			set_owm( id , DODW_MG42)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 32:{
			set_owm( id , DODW_MG34)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
		case 33:{
			set_owm( id , DODW_30_CAL)
			menu_destroy(OneWeaponMenu)
			return PLUGIN_HANDLED
		}
	}
	
	menu_destroy(OneWeaponMenu)
	return PLUGIN_HANDLED
}

exec_owm(id){
	new players[32],num
	get_players(players,num)
	for ( new i=0;i<num;i++ ){
		if ( is_user_alive(players[i]) )
			dod_user_kill(players[i])
	}
	
	console_print(id,"%s Only Mode %s",g_WeaponData[g_owm_weapon],g_OneWeaponEnabled ? "Enabled" : "Disabled")
	client_print(0,print_center,"%s Only Mode Has Been %s!",g_WeaponData[g_owm_weapon],g_OneWeaponEnabled ? "Enabled" : "Disabled")
	
	new szMessage[32]
	if( g_OneWeaponEnabled )
		format(szMessage,31,"%s only allowed",g_WeaponData[g_owm_weapon])
	else 
		format(szMessage,31,"all guns allowed")
	
	set_hudmessage(0, 100, 0, 0.05, 0.65, 2, 0.02, 10.0, 0.01, 0.1, 2)
	show_hudmessage(0,szMessage)
}

set_owm( id , weapon ){
	if ( weapon ){
		g_owm_weapon = weapon
		g_OneWeaponEnabled = true
		disableNadeEvents()
	}
	else {
		g_OneWeaponEnabled = false
		restoreNadeEvents()
	}
	exec_owm(id)
}

public cmdActivate(id,level,cid) {
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	
	new arg1[4]
	read_argv(1,arg1,3)
	if ( equal(arg1,"1")||equali(arg1,"on") ){
		g_OneWeaponEnabled = true
		disableNadeEvents()
	}
	else if (equal(arg1,"0")||equali(arg1,"off")){
		g_OneWeaponEnabled = false
		restoreNadeEvents()
	}
	else {
		console_print(id,"One Weapon Only Mode is %s",g_OneWeaponEnabled ? "Enabled" : "Disabled")
		return PLUGIN_HANDLED
	}
	exec_owm(id)
	return PLUGIN_HANDLED
}

public cmdSetWeapon(id,level,cid) {
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	
	if(g_OneWeaponEnabled){
		client_print(id,print_center,"[OWM] You can't change weapon now ! Disable OWM and try again.")
		return PLUGIN_HANDLED
	}
	
	new arg1[4]
	read_argv(1,arg1,3)
	new i = str_to_num(arg1)
	
	if ( i == 0 ){
		g_owm_weapon = 0
		return PLUGIN_HANDLED
	}
	
	if ( !i || i>WEAPONNUM || !g_WeaponData[i][0] ){
		client_print(id,print_center,"[OWM] Wrong weapon ID !")
		return PLUGIN_HANDLED
	}
	
	g_owm_weapon = i
	client_print(id,print_center,"[OWM] Weapon Changed to %s !",g_WeaponData[g_owm_weapon])
	
	return PLUGIN_HANDLED
}

public cmdMakeScoped(id){
	set_pdata_int(detect_weapon_id(id),115,1,4)
}

public eCurWeapon(id){
	if ( !g_OneWeaponEnabled )
		return PLUGIN_CONTINUE
	new ammo, clip, wid
	wid = dod_get_user_weapon(id, clip, ammo)	
	if ( wid != g_owm_weapon && (get_gametime()-g_spawntime[id])>2 ){
		client_cmd(id,"drop")
		client_print(id,print_chat,"Sorry buddy, but you can't use this weapon :P")
	}
	return PLUGIN_CONTINUE
}

public eResetHUD(id){
	if ( !g_OneWeaponEnabled )
		return PLUGIN_CONTINUE
	
	new params[2]
	params[0] = id
	params[1] = 1
	set_task(0.2,"player_give",id,params,2)
	g_spawntime[id] = get_gametime()
	
	return PLUGIN_CONTINUE
}

public eReloadDone(id){
	if ( !g_OneWeaponEnabled )
		return PLUGIN_CONTINUE
	
	dod_set_user_ammo(id,g_owm_weapon,g_AmmoData[g_owm_weapon])
	
	return PLUGIN_CONTINUE
}

public player_give(params[]){
	
	if ( params[1] )
		strip_user_weapons(params[0])
	
	if ( g_owm_weapon == 0 )
		return PLUGIN_CONTINUE 
		
	new szWpnName[32];
	get_dod_wpnname( g_owm_weapon, szWpnName );
	
	if(equali(szWpnName,"weapon_scoped_fg42")){
		if ( !give_item(params[0],"weapon_fg42"))
			client_print(0,print_console,"[OWM] Couldn't create entity (%s)",szWpnName)
		set_task(0.5,"cmdMakeScoped",params[0])
	}
	
	if(equali(szWpnName,"weapon_scoped_enfield")){
		if ( !give_item(params[0],"weapon_enfield"))
			client_print(0,print_console,"[OWM] Couldn't create entity (%s)",szWpnName)
		set_task(0.5,"cmdMakeScoped",params[0])
	}
	if (!equali(szWpnName,"weapon_scoped_fg42") && !equali(szWpnName, "weapon_scoped_enfield")){
		if ( !give_item(params[0], szWpnName) )
			client_print(0,print_console,"[OWM] Couldn't create entity (%s)",szWpnName)
	}
	
	
	return PLUGIN_CONTINUE
}


public grenade_throw(index,greindex,wId){
	if ( !g_OneWeaponEnabled || ( wId != g_owm_weapon && wId!=36 ))
		return PLUGIN_CONTINUE
	
	new par[2]
	par[0] = index
	player_give(par)
	
	return PLUGIN_CONTINUE
}

disableNadeEvents(){
	new i
	if ( g_owm_weapon == 13 || g_owm_weapon == 14 ){
		g_nadecheck |= NADE_ON
		if ( xvar_exists( "GreCatch" ) && get_xvar_num( (i = get_xvar_id("GreCatch")) ) ){
			g_nadecheck |= NADE_HUD
			set_xvar_num( i,0 )
		}
		if ( xvar_exists( "GreCatchSound" ) && get_xvar_num( (i = get_xvar_id( "GreCatchSound")) ) ){
			g_nadecheck |= NADE_SOUND
			set_xvar_num( i,0 )
		}
	}
}

restoreNadeEvents(){
	if ( g_nadecheck ){
		if (g_nadecheck&NADE_HUD ) set_xvar_num( get_xvar_id( "GreCatch" ),1 )
		if (g_nadecheck&NADE_SOUND) set_xvar_num( get_xvar_id( "GreCatchSound" ),1 )
		g_nadecheck = 0
	}
}

stock get_dod_wpnname( wpnID, szWpnName[32] ) {
	xmod_get_wpnlogname( wpnID, szWpnName, 31 );
	format( szWpnName, 31, "weapon_%s", szWpnName );
	if(equal(szWpnName, "weapon_grenade")) szWpnName = "weapon_handgrenade";
	if(equal(szWpnName, "weapon_grenade2")) szWpnName = "weapon_stickgrenade";
}

stock detect_weapon_id(id) {
	new m_iCurEnt = -1, m_iWpnEnt = 0, m_szWpn[32];
	new clip, ammo, m_iWpn = get_user_weapon(id,clip,ammo);
	xmod_get_wpnlogname(m_iWpn, m_szWpn, 31);
	format(m_szWpn, 31, "weapon_%s", m_szWpn);
	if(equal(m_szWpn, "weapon_scoped_enfield")) m_szWpn = "weapon_enfield";
	if(equal(m_szWpn, "weapon_scoped_fg42")) m_szWpn = "weapon_fg42";
	new Float:m_flOrigin[3];
	pev(id, pev_origin, m_flOrigin);
	while((m_iCurEnt = engfunc(EngFunc_FindEntityInSphere, m_iCurEnt, m_flOrigin, Float:1.0)) != 0) {
		new m_szClassname[32];
		pev(m_iCurEnt, pev_classname, m_szClassname, 31);
		if(equal(m_szClassname, m_szWpn))
			m_iWpnEnt = m_iCurEnt;
	}
	return m_iWpnEnt;
}

