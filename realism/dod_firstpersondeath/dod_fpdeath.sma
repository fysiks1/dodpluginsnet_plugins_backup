//////////////////////////////////////////////////////////////////////////////////
//
//	DoD First Person Death
//		- Version 1.1
//		- 04.06.2008
//		- by: diamond-optic
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
// 	- You no longer see your dead body in 3rd person,
//	  now you will fall to the ground with it :D
//
// CVARs: 
//
//	dod_fpdeath "1" 		//Turn ON(1)/OFF(0)
//
//	dod_fpdeath_headonly "0"	//Headshots only ON(1)/OFF(0)
//	dod_fpdeath_immunity "0"	//Admin Immunity ON(1)/OFF(0)
//
// Extra:
//
//	#define FPD_ADMIN ADMIN_IMMUNITY	//Sets admin immunity level (default: flag a)
//
// Changelog:
//
//	- 02.19.2007 Version 1.0
//		Initial Release
//
//	- 02.20.2007 Version 1.1
//		Added HeadShot only CVAR
//		Added admin immunity CVAR
//		Renamed everything from firstpersondeath to fpdeath (cvars too long)
//
//	- 04.06.2008 Version 1.1
//		Plugin re-release
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <dodx>

#define VERSION "1.1"
#define SVERSION "v1.1 - by diamond-optic (www.AvaMods.com)"

#define FPD_ADMIN	ADMIN_IMMUNITY

new Float:timeDied[33]
new p_plugin,p_headshots,p_admin

public plugin_init()
{
	register_plugin("Dod First Person Death",VERSION,"AMXX DoD Team")
	register_cvar("dod_fpdeath_stats",SVERSION,FCVAR_SERVER|FCVAR_SPONLY)
	
	p_plugin = register_cvar("dod_fpdeath","1")
	p_headshots = register_cvar("dod_fpdeath_headonly","0")
	p_admin = register_cvar("dod_fpdeath_immunity","0")
		
	register_event("YouDied","change_view","bd")
}

public change_view(id)
{
	if(get_pcvar_num(p_plugin) && is_user_connected(id) && !is_user_alive(id) && !is_user_bot(id) 
	   && ((get_pcvar_num(p_headshots) && get_gametime() < timeDied[id]) || !get_pcvar_num(p_headshots)) 
	   && ((get_pcvar_num(p_admin) && !access(id,FPD_ADMIN)) || !get_pcvar_num(p_admin)))
		{			
		set_pev(id,pev_iuser1,0)
		set_pev(id,pev_iuser2,0)
		set_pev(id,pev_iuser3,0)
		}
}

public client_death(killer,victim,wpnindex,hitplace,TK)
	if(get_pcvar_num(p_plugin) && get_pcvar_num(p_headshots) && hitplace == HIT_HEAD && !is_user_bot(victim))
		timeDied[victim] = get_gametime() + 1.0
