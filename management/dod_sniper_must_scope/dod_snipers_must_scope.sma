/* DoD Sniper MUST Scope

CVARS:
dod_sniper_mustscope "1" - enable/disable plugin
	
dod_dod_spring_mustscope "1" - enable/disable allied springfield
dod_kar_mustscope "1" - enable/disbale axis scoped kar
dod_enfield_mustscope "1" - enable/disable british scoped enfield
	
dod_mustscope_msg "1" - enable/disable message about no-scope policy
dod_mustscope_msgx "-1.0" - message position in X (-1.0 = centered valid values 0.0 - 1.0)
dod_mustscope_msgy "-1.0" - message position in Y (-1.0 = centered valid values 0.0 - 1.0)
dod_mustscope_msgr "255" - message color red 0 - 255
dod_mustscope_msgg "0" - message color green 0 - 255
dod_mustscope_msgb "0" - message color blue 0 - 255
dod_mustscope_msgtime "3.0" - message duration to show
dod_mustscope_custmsg "Scoped Rifles must be Scoped in order to fire them !!" - the custom message to show noscopers

ISSUES:
NONE

VERSION INFO:
76.0 12/27/06
Initial Code

76.1 12/28/06
Public Release

AUTHOR INFO:
Joseph Meyers AKA =|[76AD]|= TatsuSaisei - 76th Airborne Division RANK: General of the Army
http://76AD.com
http://TatsuSaisei.com
http://JosephMeyers.com
http://CustomDoD.com

*/

#include <amxmodx>
#include <dodx>
#include <dodfun>
#include <fakemeta>
#include <fun>

#define PLUGIN "dod_sniper_mustscope"
#define VERSION "76.1"
#define AUTHOR "=|[76AD]|= TatsuSaisei"


new zoom[32] = 0
new p_dod_mustscope, p_dod_spring_mustscope, p_dod_kar_mustscope, p_dod_enfield_mustscope
new p_dod_mustscope_msg,p_dod_mustscope_msgx,p_dod_mustscope_msgy
new p_dod_mustscope_msgr,p_dod_mustscope_msgg,p_dod_mustscope_msgb,p_dod_mustscope_msgtime,p_dod_mustscope_custmsg 

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar("dod_sniper_must_scope", "version: 76.1 by: =|[76AD]|= TatsuSaisei", FCVAR_SERVER|FCVAR_SPONLY)
	p_dod_mustscope = register_cvar("dod_sniper_mustscope", "1")
	
	p_dod_spring_mustscope = register_cvar("dod_dod_spring_mustscope", "1")
	p_dod_kar_mustscope = register_cvar("dod_kar_mustscope", "1")
	p_dod_enfield_mustscope = register_cvar("dod_enfield_mustscope", "1")
	
	p_dod_mustscope_msg = register_cvar("dod_mustscope_msg", "1")
	p_dod_mustscope_msgx = register_cvar("dod_mustscope_msgx", "-1.0")
	p_dod_mustscope_msgy = register_cvar("dod_mustscope_msgy", "-1.0")
	p_dod_mustscope_msgr = register_cvar("dod_mustscope_msgr", "255")
	p_dod_mustscope_msgg = register_cvar("dod_mustscope_msgg", "0")
	p_dod_mustscope_msgb = register_cvar("dod_mustscope_msgb", "0")
	p_dod_mustscope_msgtime = register_cvar("dod_mustscope_msgtime" , "5.0")
	p_dod_mustscope_custmsg = register_cvar("dod_mustscope_custmsg" , "Your Rifle must be scoped in order to fire it !!")
	register_forward(FM_PlayerPreThink, "PlayerPreThink")
	register_forward(FM_UpdateClientData, "UpdateClientData_Post", 1)
	
	//For When Scoped 
	register_event("SetFOV","zoom_out","be","1=0")     //Not Zoomed 
	register_event("SetFOV","zoom_in","be","1=20"  )   //Zoomed!!!!!!!!
}


public PlayerPreThink(id)
{
	if(!get_pcvar_num(p_dod_mustscope) || !is_user_alive(id) || !is_user_connected(id) || is_user_bot(id)) return FMRES_IGNORED
	
	new clip, ammo, myWeapon = dod_get_user_weapon(id,clip,ammo)
	if(!zoom[id] && (myWeapon == DODW_SPRINGFIELD && get_pcvar_num(p_dod_spring_mustscope) || myWeapon == DODW_SCOPED_ENFIELD && get_pcvar_num(p_dod_enfield_mustscope) || myWeapon == DODW_SCOPED_KAR && get_pcvar_num(p_dod_kar_mustscope)))
	{
		if(pev(id,pev_button) & IN_ATTACK)
		{
			set_pev(id,pev_button,pev(id,pev_button) & ~IN_ATTACK)
			if(get_pcvar_num(p_dod_mustscope_msg))
			{
				new mg_msg[256]
				get_pcvar_string(p_dod_mustscope_custmsg,mg_msg,255)
				set_hudmessage(get_pcvar_num(p_dod_mustscope_msgr),get_pcvar_num(p_dod_mustscope_msgg), get_pcvar_num(p_dod_mustscope_msgb), get_pcvar_float(p_dod_mustscope_msgx), get_pcvar_float(p_dod_mustscope_msgy), 0, 6.0, get_pcvar_float(p_dod_mustscope_msgtime))
				show_hudmessage(id, mg_msg)
			}
			return FMRES_HANDLED
		}
	}
	return FMRES_IGNORED
}

public UpdateClientData_Post(id,sendweapons,cd_handle)
{
	if (!get_pcvar_num(p_dod_mustscope) || !is_user_alive(id) || !is_user_connected(id) || is_user_bot(id)) return FMRES_IGNORED
	
	new clip, ammo, myWeapon = dod_get_user_weapon(id,clip,ammo)
	if(!zoom[id] && (myWeapon == DODW_SPRINGFIELD && get_pcvar_num(p_dod_spring_mustscope) || myWeapon == DODW_SCOPED_ENFIELD && get_pcvar_num(p_dod_enfield_mustscope) || myWeapon == DODW_SCOPED_KAR && get_pcvar_num(p_dod_kar_mustscope)))
	{
		set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)
		return FMRES_HANDLED
	}
	return FMRES_IGNORED
} 

//////////////////////////////////////////////////////////////////////////////////////////////////////// 
// 
// Checking if zoomed in.. 
// 
public zoom_in(id)
{ 
	if(!is_user_bot(id) && is_user_alive(id)) zoom[id] = 1 
} 

public zoom_out(id)
{ 
	if(!is_user_bot(id)) zoom[id] = 0 
} 
