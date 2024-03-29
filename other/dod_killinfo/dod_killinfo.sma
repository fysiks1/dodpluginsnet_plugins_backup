//////////////////////////////////////////////////////////////////////////////////
//
//	DoD Kill Info
//		- Version 0.1
//		- 08.06.2006
//		- diamond-optic
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
//	- Shows a hud message in upper left corner of screen that displays who you
//	  just killed, from how far, with what weapon, and where you hit them.
//	- If kill was a TK, it will also display that as well...
//	- Can be set to display in either feet or meters
//
// CVARs & Commands:
//
//	dod_killinfo "1" 	//Turn on(1)/off(0)
//	dod_killinfo_units "1"	//Set units: 1=feet / 2=meters
//
// Changelog:
//
//	- 08.06.2006 Version 0.1
//		Initial release
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <dodx>

new Float:units_meters = 76.0
new Float:units_feet = 24.0

new pKillinfo, pUnits

public plugin_init()
{
	register_plugin("DoD Kill Info","0.1","AMXX DoD Team" )
	
	register_statsfwd(XMF_DEATH)
	
	pKillinfo = register_cvar("dod_killinfo","1")
	pUnits = register_cvar("dod_killinfo_units","1")
}

public client_death(killer,victim,wpnindex,hitplace,TK)
{
    	if(get_pcvar_num(pKillinfo) != 1 || is_user_connected(killer) != 1 || is_user_connected(victim) != 1 || is_user_bot(killer) == 1|| killer == victim)
		return PLUGIN_CONTINUE
        
	new name[33]
	get_user_name(victim,name,32 )
	
	new weapon[32]
	xmod_get_wpnname(wpnindex,weapon,31)
	
	new bodypart[128]
	switch(hitplace)
		{
		case HIT_CHEST: bodypart = "chest"
		case HIT_HEAD: bodypart = "head"
		case HIT_LEFTARM: bodypart = "left arm"
		case HIT_LEFTLEG: bodypart = "left leg"
		case HIT_RIGHTARM: bodypart = "right arm"
		case HIT_RIGHTLEG: bodypart = "right leg"
		case HIT_STOMACH: bodypart = "stomach"
		case HIT_GENERIC: bodypart = "all over"
		}
		
	new origin1[3]
	new origin2[3]
	get_user_origin(killer,origin1)
	get_user_origin(victim,origin2)
	new distance = get_distance(origin1,origin2)
	
	new units[7]
	if(distance == 1.0)
		switch(get_pcvar_num(pUnits))
			{
			case 1: units = "foot"
			case 2: units = "meter"
			}
	else
		switch(get_pcvar_num(pUnits))
			{
			case 1: units = "feet"
			case 2: units = "meters"
			}
			
	if(get_user_team(killer) == 1)
		set_hudmessage(0,200,0,0.01,0.06,0,3.0,5.0,0.5,1.5,1)
	else
		set_hudmessage(200,0,0,0.01,0.06,0,3.0,5.0,0.5,1.5,1)
	
	new message[512] =  "killed: %s^ndistance: %.1f %s^nweapon: %s^nhitplace: %s"
	
	if(TK == 1)
		add(message,127,"^n*Team Kill*")
	
	if(get_pcvar_num(pUnits) == 1)
		show_hudmessage(killer,message,name,distance/units_feet,units,weapon,bodypart)
	else if(get_pcvar_num(pUnits) == 2)
		show_hudmessage(killer,message,name,distance/units_meters,units,weapon,bodypart)
	
	return PLUGIN_CONTINUE
}
