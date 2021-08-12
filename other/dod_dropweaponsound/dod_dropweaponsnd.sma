//////////////////////////////////////////////////////////////////////////////////
//
//	DoD Drop Weapon Sound
//		- Version 1.0
//		- 12.03.2007
//		- diamond-optic
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
//	- Very simple plugin that plays a sound on dropping a weapon
//
//	- No sound download needed
//
// Extra:
//
//	Requires DoDx Module version 1.8.1.3667 or higher
//
// Changelog:
//
// - 12.03.2007 Version 1.0
//	Initial Release
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <dodx>

#define VERSION "1.0"
#define SVERSION "v1.0 - by diamond-optic (www.AvaMods.com)"

new drop_sound[] = "object/object_dropped.wav"

public plugin_init()
{
	register_plugin("DoD Drop Weapon Sound",VERSION,"AMXX DoD Team")
	register_cvar("dod_dropweaponsnd_stats",SVERSION,FCVAR_SERVER|FCVAR_SPONLY)
}

public plugin_precache()
	 precache_sound(drop_sound)

public dod_client_weaponpickup(id,weapon,value)
	if(weapon && !value)
		emit_sound(id,CHAN_WEAPON,drop_sound,1.0,ATTN_NORM,0,PITCH_NORM)
