//////////////////////////////////////////////////////////////////////////////////
//
//	DoD MG Extra Recoil
//		- Version 1.4
//		- 06.28.2008
//		- diamond-optic
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
// 	- Adds extra recoil to undeployed MGs
//
// Credit:
//
//   	- Original idea came from TatsuSaisei's dod_mg_mustdeploy
//	  plugin, just I didnt want to totally disable undeployed
//	  MGs, i just wanted to make it a wee bit more difficult.
//	  
//
// CVARs: 
//
//	dod_mg_extrarecoil "1" 	//Turn ON(1)/OFF(0)
//
//	//these 3 control the max/min effect angles
//		dod_mg_extrarecoil_pitch "40"
//		dod_mg_extrarecoil_yaw "20"
//		dod_mg_extrarecoil_roll "3"
//
// Changelog:
//
//	- 11.02.2006 Version 1.0
//		Initial Release
//
//	- 12.03.2006 Version 1.1
//		Tweaked recoil.. Increased Pitch and Yaw, decreased Roll
//		Increased Max angle difference from 90 to 120 Yaw
//
//	- 12.16.2006 Version 1.2
//		Improved method of catching MG fire
//		Made whole thing more effecient :-)
//
//	- 05.28.2007 Version 1.3
//		Added cvars to control the angles of the effect
//		Combined the if statements into a single shorter one
//
//	- 06.28.2008 Version 1.4
//		Moved get_user_msgid to plugin_init
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <dodfun>
#include <fakemeta>

#define VERSION "1.4"
#define SVERSION "v1.4 - by diamond-optic (www.AvaMods.com)"

new msg_ScreenShake
new p_cvar,p_punch_a,p_punch_b,p_punch_c

public plugin_init()
{
	register_plugin("DoD MG Extra Recoil",VERSION,"AMXX DoD Team")
	register_cvar("dod_mg_extrarecoil_stats",SVERSION,FCVAR_SERVER|FCVAR_SPONLY)
	
	p_cvar = register_cvar("dod_mg_extrarecoil","1")
	
	p_punch_a = register_cvar("dod_mg_extrarecoil_pitch","40")
	p_punch_b = register_cvar("dod_mg_extrarecoil_yaw","20")
	p_punch_c = register_cvar("dod_mg_extrarecoil_roll","3")
	
	register_event("CurWeapon","recoil_check","be","1=1","2=17","2=18","2=21","3>0")
	
	msg_ScreenShake = get_user_msgid("ScreenShake")
}

public recoil_check(id)
{
	if(is_user_connected(id) && get_pcvar_num(p_cvar) && pev(id,pev_button) & IN_ATTACK && !dod_is_deployed(id))
		{
		new angle[3]
		angle[0] = get_pcvar_num(p_punch_a)
		angle[1] = get_pcvar_num(p_punch_b)
		angle[2] = get_pcvar_num(p_punch_c)			
			
		new Float:fVec[3]
		pev(id,pev_punchangle, fVec)
		fVec[0] += float(random_num(-(angle[0]),angle[0]))
		fVec[1] += float(random_num(-(angle[1]),angle[1]))
		fVec[2] += float(random_num(-(angle[2]),angle[2]))
		
		if(fVec[0] > 80.0)	
			fVec[0] = 80.0
		else if(fVec[0] < -80.0)	
			fVec[0] = -80.0
			
		if(fVec[1] > 75.0)	
			fVec[1] = 75.0
		else if(fVec[1] < -75.0)	
			fVec[1] = -75.0
			
		if(fVec[2] > 90.0)	
			fVec[2] = 90.0
		else if(fVec[2] < -90.0)
			fVec[2] = -90.0
		
		set_pev(id,pev_punchangle,fVec)
		
		message_begin(MSG_ONE_UNRELIABLE,msg_ScreenShake,{0,0,0},id)
		write_short(1<<14) //ammount 
		write_short(1<<12) //lasts this long 
		write_short(2<<12) //frequency
		message_end()
		}
}
