/*

Use of plugins are at your own risk.
Author makes no claims of liabilty for the use of any plugin created/modified
Tested and compiled for AMXX 1.76a

AUTHOR:

=|[76AD]|= TatsuSaisei
TatsuSaisei@76AD.com

http://76AD.com
http://forum.76AD.com

DESCRIPTION:

Have you ever seen the script kiddies run around using a large MG as if it was the Thompson ?? No recoil... it made me mad... 
-OR-
The n00bs who pull off the lucky kills when they are confronted and fire the MG when it isn't deployed...

The large machine guns were not designed to be used this way,  and I hated seeing it happen.

This script will prevent the guns from firing unless the gun is actually deployed and set-up. 
If a player shoots the gun while not deployed, a message about deploying the gun will be displayed

CREDITS: 

http://amxmodx.org, and it's creators, for the awesome mod that allows for this to be a reality !!!
http://dodplugins.net, for their awesome site, and its members for helping out when asked !!!
Wilson [29th ID] for the code used come from a suggestion he made in the dodplugins.net forum about UpdateClientData_Post and his desire to make the game of DOD more realistic
diamond-optic for "fixing" the animation of the gun still going off as a player tries to shoot his/her MG (PlayerPreThink)

TO-DO: 

??

USAGE: 

dod_mg_mustdeploy <0|1> (disable|enable) 'turn plugin on/off, default 1(on)
dod_mg_mustdeploy_msg <0|1> (disable|enable) 'turn warning message on/off, default 1(on)

dod_mg30cal_mustdeploy <0|1> (disable|enable) 'turn effect for Allied 30 Caliber on/off, default 1(on)
dod_mg42_mustdeploy <0|1> (disable|enable) 'turn effect for Axis MG42 on/off, default 1(on)
dod_mg34_mustdeploy <0|1> (disable|enable) 'turn effect for Axis MG34 on/off, default 1(on)

To set a custom message to warn players about the need to deploy first before firing the weapon
dod_mg_mustdeploy_custommsg <string> MAX 255 characters

To customize the position of the message:
dod_mg_mustdeploy_msgx <-1.0 or 0.0-1.0> (left to right)
dod_mg_mustdeploy_msgy <-1.0 or 0.0-1.0> (top to bottom)

To set the color of the message:
dod_mg_mustdeploy_msgr <0-255> RED
dod_mg_mustdeploy_msgg <0-255> GREEN
dod_mg_mustdeploy_msgb <0-255> BLUE

To set the time the message is displayed:
dod_mg_mustdeploy_msg_time <0.0+> Number of SECONDS


VERSION HISTORY:

76.0
* Inception

76.1
* Fixed the problem where the gun would still appear to fire, although it would not hurt anyone

76.2
* added ability to turn plugin on/off
* added ability to turn warning message on/of
* added ability to turn effect of on each MG selectively
* added a hud message warning for players who try to use an MG undeployed
* added definition to allow for creating a custom message when a user tries to fire the weapon when it is not deployed
* added cvars to allow for customizing the color/placement/text of the custom message

76.3
* updated information. Plugin compiles and works in AMXX 1.76a
* minor optimizations and cleanup of code

76.4
* fixed major error in coding that was causing plugin to not work unless ALL weapons were being blocked at once.
* Plugin now officially works as designed
* Credit: Box Cutter for raising attention to error
*/

#include <amxmodx>
#include <dodx>
#include <dodfun>
#include <fakemeta>
#include <fun>

#define PLUGIN "dod_mg_mustdeploy"
#define VERSION "76.4"
#define AUTHOR "=|[76AD]|= TatsuSaisei"




new p_dod_mg_mustdeploy,p_dod_mg34_mustdeploy,p_dod_mg42_mustdeploy,p_dod_mg30cal_mustdeploy
new p_dod_mg_mustdeploy_msg,p_dod_mg_mustdeploy_msgx,p_dod_mg_mustdeploy_msgy
new p_dod_mg_mustdeploy_msgr,p_dod_mg_mustdeploy_msgg,p_dod_mg_mustdeploy_msgb,p_dod_mg_mustdeploy_msg_time,p_dod_mg_mustdeploy_custommsg 

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	p_dod_mg_mustdeploy = register_cvar("dod_mg_mustdeploy", "1")
	p_dod_mg30cal_mustdeploy = register_cvar("dod_mg30cal_mustdeploy", "1")
	p_dod_mg42_mustdeploy = register_cvar("dod_mg42_mustdeploy", "1")
	p_dod_mg34_mustdeploy = register_cvar("dod_mg34_mustdeploy", "1")
	p_dod_mg_mustdeploy_msg = register_cvar("dod_mg_mustdeploy_msg", "1")
	p_dod_mg_mustdeploy_msgx = register_cvar("dod_mg_mustdeploy_msgx", "-1.0")
	p_dod_mg_mustdeploy_msgy = register_cvar("dod_mg_mustdeploy_msgy", "-1.0")
	p_dod_mg_mustdeploy_msgr = register_cvar("dod_mg_mustdeploy_msgr", "255")
	p_dod_mg_mustdeploy_msgg = register_cvar("dod_mg_mustdeploy_msgg", "0")
	p_dod_mg_mustdeploy_msgb = register_cvar("dod_mg_mustdeploy_msgb", "0")
	p_dod_mg_mustdeploy_msg_time = register_cvar("dod_mg_mustdeploy_msg_time" , "5.0")
	p_dod_mg_mustdeploy_custommsg = register_cvar("dod_mg_mustdeploy_custommsg" , "Your machine gun must be deployed before using it !")
	register_forward(FM_PlayerPreThink, "PlayerPreThink")
	register_forward(FM_UpdateClientData, "UpdateClientData_Post", 1)
}

public PlayerPreThink(id){
	if(get_pcvar_num(p_dod_mg_mustdeploy)  == 1){
		
		if(!is_user_alive(id) || !is_user_connected(id))
			return FMRES_IGNORED
		
		new clip, ammo, myWeapon = dod_get_user_weapon(id,clip,ammo)
		if((myWeapon == DODW_MG42 &&get_pcvar_num(p_dod_mg42_mustdeploy) == 1) || (myWeapon == DODW_MG34&&get_pcvar_num(p_dod_mg34_mustdeploy) == 1) || (myWeapon == DODW_30_CAL&&get_pcvar_num(p_dod_mg30cal_mustdeploy) == 1))
		{
			if(pev(id,pev_button) & IN_ATTACK && dod_is_deployed(id) == 0)
			{
				if(get_pcvar_num(p_dod_mg_mustdeploy_msg)  == 1){
					new mg_msg[256]
					get_pcvar_string(p_dod_mg_mustdeploy_custommsg,mg_msg,255)
					set_hudmessage(get_pcvar_num(p_dod_mg_mustdeploy_msgr),get_pcvar_num(p_dod_mg_mustdeploy_msgg), get_pcvar_num(p_dod_mg_mustdeploy_msgb), get_pcvar_float(p_dod_mg_mustdeploy_msgx), get_pcvar_float(p_dod_mg_mustdeploy_msgy), 0, 6.0, get_pcvar_float(p_dod_mg_mustdeploy_msg_time))
					show_hudmessage(id, mg_msg)
					set_pev(id,pev_button,pev(id,pev_button) & ~IN_ATTACK)
				}
				return FMRES_HANDLED
			}
		}
	}
	return FMRES_IGNORED
}

public UpdateClientData_Post(id,sendweapons,cd_handle){
	if(get_pcvar_num(p_dod_mg_mustdeploy)  == 1){
		if (!is_user_alive(id) || !is_user_connected(id))
			return FMRES_IGNORED
		
		new clip, ammo, myWeapon = dod_get_user_weapon(id,clip,ammo)
		if((myWeapon == DODW_MG42 &&get_pcvar_num(p_dod_mg42_mustdeploy) == 1) || (myWeapon == DODW_MG34&&get_pcvar_num(p_dod_mg34_mustdeploy) == 1) || (myWeapon == DODW_30_CAL&&get_pcvar_num(p_dod_mg30cal_mustdeploy) == 1))
		{
			if(dod_is_deployed(id) == 0)
			{
				set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)
				return FMRES_HANDLED
			}
		}
	}
	return FMRES_IGNORED
} 
