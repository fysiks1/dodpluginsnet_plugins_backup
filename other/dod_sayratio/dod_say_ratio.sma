//////////////////////////////////////////////////////////////////////////////////
//
//	DoD Say Ratio
//		- Version 1.0
//		- 06.28.2008
//		- diamond-optic
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
//   - Type /ratio in the chat to get a print-out of your K/D ratio
//   - There's also an option to print your K/D ratio when you die...
//
// CVARs & Commands:
//
//     dod_say_ratio "1" //Turn on(1)/off(0) auto-msg on death
//    
//   - type /ratio in the chat -> print your current Kill/Death ratio
//
// Changelog:
//
//   - 05.27.2006 Version 0.1
//  	  Initial release
//
//   - 08.06.2006 Version 0.2
//	  Changes death print-out delay from 0.5s to 1.0s
//  	  Changed returns
//
//   - 06.28.2008 Version 1.0
//	  Simplified code
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <dodfun>
#include <dodx>

#define VERSION "1.0"
#define SVERSION "v1.0 - by diamond-optic (www.AvaMods.com)"

new p_dod_say_ratio

public plugin_init()
{
	register_plugin("DoD Say Ratio",VERSION,"AMXX DoD Team")
	register_cvar("dod_say_ratio_stats",SVERSION,FCVAR_SERVER|FCVAR_SPONLY)
	
	p_dod_say_ratio = register_cvar("dod_say_ratio","1")
	
	register_clcmd("say /ratio","dod_ratio")
	register_clcmd("say_team /ratio","dod_ratio")
}

public dod_ratio(id) 
{
	if(is_user_connected(id))
		{		
		new deaths = dod_get_pl_deaths(id)
	
		if(!deaths)
			deaths = 1
	
		new Float:kd_ratio = floatdiv(float(dod_get_user_kills(id)),float(deaths))
	
		client_print(id,print_chat,"** Your kill/death ratio is %.2f **",kd_ratio)
		}
		
	return PLUGIN_CONTINUE
}

public client_death(killer,victim,wpnindex,hitplace,TK)
	if(!is_user_bot(victim) && is_user_connected(victim) && get_pcvar_num(p_dod_say_ratio))
		set_task(1.0,"dod_ratio",victim)
