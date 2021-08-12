///////////////////////////////////////////////////////////////////////////////////////
//
//	AMX Mod (X)
//
//	Developed by:
//	The Amxmodx DoD Community
//	Hell Phoenix (Hell_Phoenix@frenchys-pit.com)
//	http://www.dodplugins.net
//
//	This program is free software; you can redistribute it and/or modify it
//	under the terms of the GNU General Public License as published by the
//	Free Software Foundation; either version 2 of the License, or (at
//	your option) any later version.
//
//	This program is distributed in the hope that it will be useful, but
//	WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//	General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with this program; if not, write to the Free Software Foundation,
//	Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
//	In addition, as a special exception, the author gives permission to
//	link the code of this program with the Half-Life Game Engine ("HL
//	Engine") and Modified Game Libraries ("MODs") developed by Valve,
//	L.L.C ("Valve"). You must obey the GNU General Public License in all
//	respects for all of the code used other than the HL Engine and MODs
//	from Valve. If you modify this file, you may extend this exception
//	to your version of the file, but you are not obligated to do so. If
//	you do not wish to do so, delete this exception statement from your
//	version.
//
//	Name:	DoD Unlimited Pistol Ammo
//	Author:	Hell Phoenix
//
//	Description:	This plugin allows for unlimited pistol ammo
//
//	
//
//	
//
//  Commands:  
//  Cvars:     dod_pistolammo (0|1)  (Default is off 0)
//
//  v1.0    - Created
//
//  ToDo    Nothing
//	   
//
///////////////////////////////////////////////////////////////////////////////////////


#include <amxmodx>
#include <dodfun>
#include <dodx>

#define PLUGIN "DoD Unlimited Pistol Ammo"
#define VERSION "1.0"
#define AUTHOR "AMXX DoD Community"
new pistolammo

public plugin_init(){
   register_plugin(PLUGIN, VERSION, AUTHOR)
   pistolammo = register_cvar("dod_pistolammo","0")
   register_event("ResetHUD","give_ammo","be")
}

public give_ammo(id){
	if(get_pcvar_num(pistolammo)){
		set_task(0.1,"give_pammo",id)
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public give_pammo(id){
	if(get_user_team(id) == AXIS){
		dod_set_user_ammo(id,DODW_LUGER,999)
		return PLUGIN_HANDLED
	}
	else if(get_user_team(id) == ALLIES){
		if(dod_get_map_info(MI_ALLIES_TEAM) == 1){
			dod_set_user_ammo(id,DODW_WEBLEY,999)
			return PLUGIN_HANDLED
		}
		else if(dod_get_map_info(MI_ALLIES_TEAM) == 0){
			dod_set_user_ammo(id,DODW_COLT,999)
			return PLUGIN_HANDLED
		}
        }
        return PLUGIN_HANDLED
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
