/*
 Weapons Mod 2.0
 Brought to you by TooLz

 Special thanks to DoDPlugins.net for providing the wonderful community!
*/

#include <amxmodx> 
#include <amxmisc> 
#include <fun> 
#include <dodx>
#include <fakemeta>

#define MAXWEAPON 23
new got_weapon[32], Weapon_Name[33][32]
enum WeaponData {
	WMOD_Weapon,
	WMOD_SayCmd[32],
	WMOD_Disabled[32]
}
new WEAPON[MAXWEAPON][WeaponData] = {
	{DODW_KAR,"k98","amx_disable_k98"},					//0
	{DODW_GARAND,"garand","amx_disable_garand"},				//1
	{DODW_K43,"k43","amx_disablek43"},					//2
	{DODW_M1_CARBINE,"carbine","amx_disable_carbine"},			//3
	{DODW_MP40,"mp40","amx_disable_mp40"},					//4
	{DODW_THOMPSON,"thompson","amx_disable_thompson"},			//5
	{DODW_STG44,"stg44","amx_disable_stg44"},				//6
	{DODW_GREASEGUN,"greasegun","amx_disable_greasegun"},			//7
	{DODW_SCOPED_KAR,"scopedk98","amx_disable_scopedk98"},			//8
	{DODW_SPRINGFIELD,"springfield","amx_disable_springfield"},		//9
	{DODW_MG34,"mg34","amx_disable_mg34"},					//10
	{DODW_BAR,"bar","amx_disable_bar"},					//11
	{DODW_MG42,"mg42","amx_disable_mg42"},					//12
	{DODW_30_CAL,"30cal","amx_disable_30cal"},				//13
	{DODW_PANZERSCHRECK,"panzerschreck","amx_disable_panzerschreck"},	//14
	{DODW_BAZOOKA,"bazooka","amx_disable_bazooka"},				//15
	{DODW_ENFIELD,"enfield","amx_disable_enfield"},				//16
	{DODW_STEN,"sten","amx_disable_sten"},					//17
	{DODW_BREN,"bren","amx_disable_bren"},					//18
	{DODW_PIAT,"piat","amx_disable_piat"},					//19
	{DODW_FG42,"fg42","amx_disable_fg42"},					//20
	{DODW_SCOPED_FG42,"scopedfg42","amx_disable_scopedfg42"},		//21
	{DODW_SCOPED_ENFIELD,"scopedenfield","amx_disable_scopedenfield"}	//22
}
public plugin_init() 
{ 
	register_plugin("Weapons Mod 2.0","2.0","TooLz") 
	register_event("ResetHUD","respawn","be")
	register_clcmd("say","cmdSay",0,"- Checks which weapon was said")
	register_cvar("amx_weapon_changes", "2")
	register_cvar("amx_disable_scopedfg42","0")
	register_cvar("amx_disable_scopedenfield","0")
	register_cvar("amx_disable_k98", "0")
	register_cvar("amx_disable_garand", "0")
	register_cvar("amx_disable_carbine", "0")
	register_cvar("amx_disable_k43", "0")
	register_cvar("amx_disable_mp40", "0")
	register_cvar("amx_disable_thompson", "0")
	register_cvar("amx_disable_stg44", "0")
	register_cvar("amx_disable_bar", "0")
	register_cvar("amx_disable_fg42", "0")
	register_cvar("amx_disable_greasegun", "0")
	register_cvar("amx_disable_bazooka", "0")
	register_cvar("amx_disable_enfield", "0")
	register_cvar("amx_disable_sten", "0")
	register_cvar("amx_disable_mg42", "0")
	register_cvar("amx_disable_mg34", "0")
	register_cvar("amx_disable_30cal", "0")
	register_cvar("amx_disable_springfield", "0")
	register_cvar("amx_disable_scopedk98", "0")
	register_cvar("amx_disable_bren", "0")
	register_cvar("amx_disable_panzerschreck", "0")
	register_cvar("amx_disable_piat", "0")
}
public respawn(id){
	got_weapon[id] = 0
}
stock detect_weapon_id(id) {
// Big thanks to Wilson for this stock!
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
stock cmdWeapon(WeaponID, WeaponName[32]) {
	xmod_get_wpnlogname(WeaponID, WeaponName, 31);
	format(WeaponName, 31, "weapon_%s", WeaponName);
}
stock dod_get_scoped(id) {
    new m_iCurEnt = -1, m_iWpnEnt = 0, m_szWpn[32];
    new clip, ammo, m_iWpn = get_user_weapon(id,clip,ammo);
    new is_scoped
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
    is_scoped = get_pdata_int(m_iWpnEnt,115,4);
    return is_scoped;
}
public cmdMakeScoped(id){
	new is_scoped = dod_get_scoped(id)
	while(is_scoped != 1){
		is_scoped = dod_get_scoped(id)
		set_pdata_int(detect_weapon_id(id),115,1,4)
	}
	client_cmd(id,"slot2;wait;slot3")
}
public cmdGiveWeapon(id){
	if (!equali(Weapon_Name[id],"weapon_scoped_fg42") && !equali(Weapon_Name[id], "weapon_scoped_enfield")){
		give_item(id,Weapon_Name[id])
	}
	if(equali(Weapon_Name[id],"weapon_scoped_fg42")){
		give_item(id,"weapon_fg42")
		set_task(0.2,"cmdMakeScoped",id)
	}
	if(equali(Weapon_Name[id],"weapon_scoped_enfield")){
		give_item(id,"weapon_enfield")
		set_task(0.2,"cmdMakeScoped",id)
	}
	got_weapon[id]++
}
public cmdSay(id) {
	new said[32]
	read_argv(1,said,31)
	if(said[0] != '/')
		return PLUGIN_CONTINUE;
	for(new i = 0 ; i < MAXWEAPON ; i++) {
		if(equali(said[1],WEAPON[i][WMOD_SayCmd])) {
			if(get_cvar_num(WEAPON[i][WMOD_Disabled]) != 0){
				client_print(id,print_chat, "[Weapons Mod 2.0] This weapon is disabled on this server.")
				return PLUGIN_HANDLED
			}
			if (got_weapon[id] == get_cvar_num("amx_weapon_changes")){
				client_print(id,print_chat, "[Weapons Mod 2.0] You've used up your gun changes, you must wait until respawn to change guns again.")
				return PLUGIN_HANDLED
			}
			cmdWeapon(WEAPON[i][WMOD_Weapon],Weapon_Name[id])
			client_cmd(id, "drop")
			set_task(0.3,"cmdGiveWeapon", id)
			break;
		}
	}
	return PLUGIN_HANDLED
}