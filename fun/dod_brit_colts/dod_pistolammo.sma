//////////////////////////////////////////////////////////////////////////////////
//
//	DoD Pistol Ammo (fixed for dod_britcolts)
//		- Version 0.5fixed
//		- 05.19.2006
//		- original: FireStorm
//		- fix: diamond-optic
//////////////////////////////////////////////////////////////////////////////////
//
// Changelog:
//
// - 05.19.2006 Version 0.5fixed
//	Fixed to work with dod_britcolts
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <dodfun>
#include <dodx>

public plugin_init(){
   register_plugin("DoD PistolAmmo","0.5fixed","AMXX DoD Team")
   register_cvar("dod_pistolammo_on","0")
   register_event("ResetHUD","give_pistolammo","be")
}

public give_pistolammo(id){
	if(get_cvar_num("dod_pistolammo_on") == 1){
		set_task(0.3,"give_ammo",id)
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public give_ammo(id){
	if(get_user_team(id) == AXIS)
		{
		dod_set_user_ammo(id,DODW_LUGER,999)
		return PLUGIN_HANDLED
		}
	else if(get_user_team(id) == ALLIES)
		{
		if(dod_get_map_info(MI_ALLIES_TEAM) == 1)
			{
			if (dod_get_user_class(id) == DODC_MARKSMAN)
				{
				dod_set_user_ammo(id,DODW_WEBLEY, 999)
				return PLUGIN_HANDLED
				}
			else
				{
				dod_set_user_ammo(id,DODW_WEBLEY,999)
				return PLUGIN_HANDLED
				}
			}
		else if(dod_get_map_info(MI_ALLIES_TEAM) == 0)
			{
			dod_set_user_ammo(id,DODW_COLT,999)
			return PLUGIN_HANDLED
			}
		}
        return PLUGIN_HANDLED
}
