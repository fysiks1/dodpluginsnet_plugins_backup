//////////////////////////////////////////////////////////////////////////////////
//
//	DoD Brit Colts
//		- Version 1.0
//		- 05.20.2008
//		- diamond-optic
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
//   - British will have Colt .45's instead of the Webley
//   - The marksman class still gets webley
//   - If you run 'dod_nadeforall' you must put this before it
//     if you give nades to any brit class besides marksman...
//
// CVARS:
//
//   dod_britcolts //Turn on(1)/off(0) giving brits colt45's
//
// Changelog:
//
//   - 02.23.2006 Version 0.1
//  	  Initial release
//  	  Marksman doesnt get a colt .45
//
//   - 03.05.2006 Version 0.2
//	  Added CVAR pointer
//	  A few minor changes
//
//   - 05.08.2006 Version 0.3
//	  Adjusted task so it will work with dod_nadeforall
//
//   - 05.20.2008 Version 1.0
//	  Changed Public CVAR format
//	  Replaced respawn hook with PStatus method
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <fun>
#include <dodx>

#define VERSION		"1.0"
#define SVERSION	"v1.0 - by diamond-optic (www.AvaMods.com)"

new p_dod_britcolts

public plugin_init()
{
	register_plugin("DOD Brit Colts",VERSION,"AMXX DoD Team")
	register_cvar("dod_britcolts_stats",SVERSION,FCVAR_SERVER|FCVAR_SPONLY)
	
	p_dod_britcolts = register_cvar("dod_britcolts","1")
	
	//Temp fix for spawning
	register_message(get_user_msgid("PStatus"),"msg_PStatus")
}

////////////////////////////////////////////////////
// Temp fix for spawn hook
//
public msg_PStatus(msgid,msgdest,id)
{
	if(get_pcvar_num(p_dod_britcolts) && msgdest == 2 && !id)
		{
		new player = get_msg_arg_int(1)
		new status = get_msg_arg_int(2)
		
		if(is_user_connected(player) && status == 0)
			set_task(Float:0.1,"respawn",player)
		}
}

public brit_task(id)
{
//	strip_user_weapons(id)				//take away the defualt weapons *would use this if marksman would work*
	new britclass = dod_get_user_class(id)		//get their class
	
	if(britclass == DODC_ENFIELD)			//class 1
		{
		strip_user_weapons(id)			//take away the defualt weapons 
		give_item(id,"weapon_enfield")
		give_item(id,"ammo_enfield")
		give_item(id,"weapon_colt")
		give_item(id,"ammo_colt")
		give_item(id,"weapon_amerknife")
		give_item(id,"weapon_handgrenade")
		give_item(id,"weapon_handgrenade")
		}
	else if(britclass == DODC_STEN)			//class 2
		{
		strip_user_weapons(id)			//take away the defualt weapons 
		give_item(id,"weapon_sten")
		give_item(id,"ammo_sten")
		give_item(id,"weapon_colt")
		give_item(id,"ammo_colt")
		give_item(id,"weapon_amerknife")
		give_item(id,"weapon_handgrenade")
		}
	else if(britclass == DODC_MARKSMAN)		//class 3 *not working*
		{
//		strip_user_weapons(id)
//		give_item(id,"weapon_scopedenfield")
//		give_item(id,"ammo_enfield_scoped")
//		give_item(id,"weapon_colt")
//		give_item(id,"ammo_colt")
//		give_item(id,"weapon_amerknife")
		}
	else if(britclass == DODC_BREN)			//class 4
		{
		strip_user_weapons(id)			//take away the defualt weapons 
		give_item(id,"weapon_bren")
		give_item(id,"ammo_bren")
		give_item(id,"weapon_colt")
		give_item(id,"ammo_colt")
		give_item(id,"weapon_amerknife")
		give_item(id,"weapon_handgrenade")
		}
	else 						//all thats left is class 5
		{
		strip_user_weapons(id)			//take away the defualt weapons 
		give_item(id,"weapon_piat")
		give_item(id,"ammo_piat")
		give_item(id,"weapon_colt")
		give_item(id,"ammo_colt")
		give_item(id,"weapon_amerknife")
		}
		
	return PLUGIN_HANDLED			
}
public respawn(id)
	if((get_user_team(id) == 1) && (dod_get_map_info(MI_ALLIES_TEAM) == 1))	//allies & brits?
		set_task(0.1,"brit_task",id)