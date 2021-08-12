//////////////////////////////////////////////////////////////////////////////////
//
//	DoD Death Fade
//		- Version 1.1
//		- 03.11.2009
//		- diamond-optic
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
// 	- Semi-transparent screen fade on client death
//
// CVARS: 
//
//	dod_deathfade "1"  //(1)ON or (0)OFF
//
//////////////////////////////////////////////////////////////
//
// Settings (Global Variables)
//
//	set_FadeAlpha 	225	//Fade alpha level
//
//	set_FadeRed 	225	//Fade red level
//	set_FadeGreen 	0	//Fade green level
//	set_FadeBlue 	0	//Fade blue level
//
//////////////////////////////////////////////////////////////
//
// Changelog:
//
//	 - 05.01.2006 Version 0.1
//		Initial Release
//
//	 - 05.06.2006 Version 0.2
//		Changed from MSG_ONE to MSG_ONE_UNRELIABLE
//
//	 - 05.30.2006 Version 0.3
//		Adjusted ScreenFade message variables
//
//	 - 06.02.2006 Version 0.4
//		Added CVARs to control fade RGB & alpha levels
//
//	 - 06.28.2008 Version 1.0
//		Minor code improvement
//		Moved get_user_msgid to plugin_init
//
//	 - 03.11.2009 Version 1.1
//		Changed DoDx death forward to HamSandwich
//		Changed some CVARs to global variables (faster)
//
//////////////////////////////////////////////////////////////////////////////////


#include <amxmodx>
#include <hamsandwich>

#define VERSION "1.1"
#define SVERSION "v1.1 - by diamond-optic (www.AvaMods.com)"

////////////////////////////////////////
// *** SETTINGS ***
//
new set_FadeAlpha =	225
new set_FadeRed =	225
new set_FadeGreen =	0
new set_FadeBlue =	0
//
// *** END OF SETTINGS ***
////////////////////////////////////////

// Global Variables
new DeathFade
new p_dod_deathfade

public plugin_init()
{
	register_plugin("DoD Death Fade",VERSION,"AMXX DoD Team")
	register_cvar("dod_death_fade_stats",SVERSION,FCVAR_SERVER|FCVAR_SPONLY)
	
	p_dod_deathfade = register_cvar("dod_deathfade","1")

	
	DeathFade = get_user_msgid("ScreenFade")
	
	RegisterHam(Ham_Killed,"player","func_HamKilled")
}

public func_HamKilled(victim,killer,shouldgib)
{	
	if(get_pcvar_num(p_dod_deathfade) && !is_user_alive(victim) && is_user_connected(victim) && !is_user_bot(victim))
		{
		message_begin(MSG_ONE_UNRELIABLE,DeathFade,{0,0,0},victim)
		write_short(~0)
		write_short(8000)
		write_short(0x0002)
		write_byte(set_FadeRed)
		write_byte(set_FadeGreen)
		write_byte(set_FadeBlue)
		write_byte(set_FadeAlpha)
		message_end()
		}
}