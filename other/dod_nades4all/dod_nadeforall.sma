//////////////////////////////////////////////////////////////////////////////////
//
//	DoD Nade For All
//		- Version 1.1
//		- 08.06.2006
//		- diamond-optic (original code by FireStorm)
//
//////////////////////////////////////////////////////////////////////////////////
//
// Credit:
//
//   - Original Code by FireStorm (dod_nadeforall v0.5beta)
//
// Information:
//
//   - This will allow you to give snipers, mgs, and rockets
//     a grenade when they spawn.
//
// CVARs:
//
//   dod_nadeforall "1" //Turn on(1)/off(0)
//
//   dod_nadeforall_snipers "1" //Turn on(1)/off(0) nade for snipers
//   dod_nadeforall_mgs "1" //Turn on(1)/off(0) nade for mgs
//   dod_nadeforall_rockets "1" //Turn on(1)/off(0) nade for rockets
//
// Changelog:
//
//   - 05.27.2005 Version 0.5beta
//	  Initial Release by FireStorm
//
//   - 08.04.2006 Version 1.0 	****** FIX THIS DATE!!!!! ******
//  	  Modification of FireStorms original code
//
//   - 08.06.2006 Version 1.1
//  	  Changed some returns
//	  Corrected Changelog mistake
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <fun>
#include <dodx>

new p_dod_nadeforall, p_dod_nadeforall_snipers, p_dod_nadeforall_mgs, p_dod_nadeforall_rockets

public plugin_init(){
	register_plugin("DoD NadeForAll","1.1","AMXX DoD Team")
	
	p_dod_nadeforall = register_cvar("dod_nadeforall","1")
	
	p_dod_nadeforall_snipers = register_cvar("dod_nadeforall_snipers","1")
	p_dod_nadeforall_mgs = register_cvar("dod_nadeforall_mgs","1")
	p_dod_nadeforall_rockets = register_cvar("dod_nadeforall_rockets","1")
		
	register_event("ResetHUD","check_class","be")
}

public check_class(id){
	if((get_pcvar_num(p_dod_nadeforall) != 1) || !is_user_alive(id) || !is_user_connected(id) || is_user_hltv(id))
		return PLUGIN_CONTINUE
		
	new pclass = dod_get_user_class(id)
	
	if((get_pcvar_num(p_dod_nadeforall_snipers) == 1) && (pclass == DODC_SCHARFSCHUTZE || pclass == DODC_SNIPER || pclass == DODC_MARKSMAN)){
		set_task(0.1,"give_nade",id)
		return PLUGIN_CONTINUE
	}
	else if((get_pcvar_num(p_dod_nadeforall_mgs) == 1) && (pclass == DODC_MG34 || pclass == DODC_MG42 || pclass == DODC_30CAL)){
		set_task(0.1,"give_nade",id)
		return PLUGIN_CONTINUE
	}
	else if((get_pcvar_num(p_dod_nadeforall_rockets) == 1) && (pclass == DODC_PANZERJAGER || pclass == DODC_BAZOOKA || pclass == DODC_PIAT)){
		set_task(0.1,"give_nade",id)
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public give_nade(id){
	if(is_user_connected(id) == 1 && is_user_alive(id) == 1){ 
		if(get_user_team(id) == 2){
			give_item(id, "weapon_stickgrenade")
		}
		else if(get_user_team(id) == 1){
			give_item(id, "weapon_handgrenade")
		}
	}
	return PLUGIN_HANDLED
}
