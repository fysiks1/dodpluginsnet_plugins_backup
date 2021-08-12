//////////////////////////////////////////////////////////////////////////////////
//
//	DoD Weapon Suicide
//		- Version 1.0
//		- 01.29.2008
//		- diamond-optic
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
//	- When a player types "kill" in the console or is slayed, the death
//	  message will show that they used their weapon to kill themselves
//
//	- Goes by the weapon they are holding at the time
//
//	- Will not show for grenades or rockets
//
// Changelog:
//
//	- 01.29.2008 Version 1.0
//		Initial Release
//
///////////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <dodx>


#define VERSION "1.0"
#define SVERSION "v1.0 - by diamond-optic (www.AvaMods.com)"

new gMsgDeathMsg


public plugin_init()
{
	register_plugin("DoD Weapon Suicide",VERSION,"AMXX DoD Team")
	register_cvar("dod_weaponsuicide_stats",SVERSION,FCVAR_SERVER|FCVAR_SPONLY)	
	
	gMsgDeathMsg = get_user_msgid("DeathMsg")
	register_message(gMsgDeathMsg, "death_check")
}

public death_check(msg_id,msg_dest,msg_entity)
{
	new victim = get_msg_arg_int(2)
	new weapon = get_msg_arg_int(3)
	
	if(weapon == 13 || weapon == 14 || weapon == 15 || weapon == 16 || weapon == 13 || weapon == 29 || weapon == 30 || weapon == 31 || weapon == 32 || weapon == 34 || weapon == 39 || weapon == 41)
		return PLUGIN_CONTINUE
		
	if(get_msg_arg_int(1) == victim)
		{
		new ammo, clip, zGun = dod_get_user_weapon(victim,clip,ammo)
		
		if(zGun == DODW_BAZOOKA || zGun == DODW_HANDGRENADE || zGun == DODW_HANDGRENADE_EX || zGun == DODW_MILLS_BOMB || zGun == DODW_PANZERSCHRECK || zGun == DODW_PIAT || zGun == DODW_STICKGRENADE || zGun == DODW_STICKGRENADE_EX)
			return PLUGIN_CONTINUE
		
		message_begin(MSG_ALL, gMsgDeathMsg,{0,0,0}, 0)
		write_byte(victim)
		write_byte(victim)
		write_byte(dod_weaponid_to_deathmsgid(zGun))
		message_end()
		
		return PLUGIN_HANDLED
		}

	return PLUGIN_CONTINUE
}

////////////////////////////////////////////////////////////////////
// by diamond-optic (12.24.07)
//
//    converts weapon ids (from dod_get_user_weapon for example)
//    into the ids used for those weapons in death messages
//
stock dod_weaponid_to_deathmsgid(weaponid)
{
    if(weaponid > 31 && weaponid < 38)
        return weaponid+3
    else if(weaponid == 38 || weaponid == 41)
        return 42
    else if(weaponid == 39)
        return 43
    else if(weaponid == 40)
        return 32
    
    return weaponid
}
