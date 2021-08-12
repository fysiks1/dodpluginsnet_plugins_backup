//////////////////////////////////////////////////////////////////////////////////
//
//	DoD StaminaHP (remake)
//		- Version 1.1
//		- 01.03.2006
//		- diamond-optic
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
// 	- Remake of an old plugin by FireStorm
//	- Max stamina goes down as you take damage
//
//	- CVAR to set hp level for effect to begin
//	- CVAR to set how much hp takes away each stamina point
//
// Credits:
//
//   	- Original plugin by FireStorm
//
// CVARs: 
//
//	dod_staminahp "1"		//turn ON(1)/OFF(0)
//	dod_staminahp_starthp "50"	//HP level at which to start lowering max stamina
//	dod_staminahp_ratio "2"		//Ammount of HP that will subtract 1 stamina point
//
// Changelog:
//
//	- 08.01.2006 Version 1.0
//		Initial remake release
//
//	- 01.03.2007 Version 1.1
//		Made sure a float value doesnt get passed to the stamina native (thanks santa_sh0t_tupac)
//		Fixed a typo in the cvar section of the comments (thanks santa_sh0t_tupac)
//		Replaced ResetHud forward with dod_client_spawn native
//		Added public cvar for tracking
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <dodfun>
#include <dodx>

new p_staminahp, p_starthp, p_ratio

public plugin_init()
{
	register_plugin("DoD StaminaHP (remake)", "1.1", "AMXX DoD Team")
	
	register_cvar("dod_staminahp_remake_stats", "1.1", FCVAR_SERVER|FCVAR_SPONLY)
	
	p_staminahp = register_cvar("dod_staminahp", "1")
	p_starthp = register_cvar("dod_staminahp_starthp", "50")
	p_ratio = register_cvar("dod_staminahp_ratio", "2")
	
	register_statsfwd(XMF_DAMAGE)
}

public client_damage(attacker,victim,damage,wpnindex,hitplace,TA)
{
	if(is_user_alive(victim) && is_user_connected(victim) && (get_user_health(victim) <= get_pcvar_num(p_starthp)) && get_pcvar_num(p_staminahp))
		{
		new stamina = (get_pcvar_num(p_starthp) - get_user_health(victim))
		new ratio = get_pcvar_num(p_ratio)
		
		if(ratio < 1)
			ratio = 1
		
		new stamina_value = (100 - (stamina / ratio))
		
		dod_set_stamina(victim, STAMINA_SET, 0, stamina_value)
		}
}

public dod_client_spawn(id)
{
	if(is_user_alive(id) && is_user_connected(id) && get_pcvar_num(p_staminahp))
		dod_set_stamina(id, STAMINA_RESET)
}