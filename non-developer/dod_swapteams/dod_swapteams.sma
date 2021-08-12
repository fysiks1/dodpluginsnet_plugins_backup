/* AMX Mod X
*   Day of Defeat Swap teams
*
* by <eVa>StrontiumDog
* http://www.theville.org
**
*
*  This program is free software; you can redistribute it and/or modify it
*  under the terms of the GNU General Public License as published by the
*  Free Software Foundation; either version 2 of the License, or (at
*  your option) any later version.
*
*  This program is distributed in the hope that it will be useful, but
*  WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
*  General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program; if not, write to the Free Software Foundation,
*  Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*
*  In addition, as a special exception, the author gives permission to
*  link the code of this program with the Half-Life Game Engine ("HL
*  Engine") and Modified Game Libraries ("MODs") developed by Valve,
*  L.L.C ("Valve"). You must obey the GNU General Public License in all
*  respects for all of the code used other than the HL Engine and MODs
*  from Valve. If you modify this file, you may extend this exception
*  to your version of the file, but you are not obligated to do so. If
*  you do not wish to do so, delete this exception statement from your
*  version.
*/

#include <amxmodx>
#include <amxmisc>
#include <dodx>
#include <dodfun>

#define PLUGIN_VERSION "1.2.000"

new autoswap_enabled

public plugin_init()
{
	register_plugin("DoD Swap Teams",PLUGIN_VERSION,"<eVa>Dog")
	register_cvar("dod_swapteams_version", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY)	
	
	register_concmd("amx_swapteams","admin_swapteams",ADMIN_SLAY,"swap all players' teams")
	
	register_event("RoundState", "autoswap", "a", "1=3"	, "1=4")
	autoswap_enabled = register_cvar("mp_autoswap_enabled", "0")
}

public plugin_modules()
{
	require_module("dodx")
}

public admin_swapteams(id,level,cid){
	if (!cmd_access(id,level,cid,1))
	{
		console_print(id,"[TEAMS] You need to be an Admin to use this command")
		return PLUGIN_HANDLED
	}
	new plist_public[32],pnum_public
	new pl_class
	
	get_players(plist_public, pnum_public)
	
	// Is the map British or American (Thanks Diamond-Optic!)
	new uk = dod_get_map_info(MI_ALLIES_TEAM)
	
	for(new i=0; i<pnum_public; i++){
		
		// On Allied side - transfer to Axis
		if(is_user_connected(plist_public[i]) == 1 && get_user_team(plist_public[i]) == 1)
		{
			pl_class = dod_get_user_class(plist_public[i])
			dod_set_user_team(plist_public[i], 2, 1);
			switch (uk) 
			{
				case 0: 
				{
					switch (pl_class)
					{
						case DODC_GARAND:
							dod_set_user_class(plist_public[i], DODC_KAR) 	
						case DODC_CARBINE:
							dod_set_user_class(plist_public[i], DODC_K43)	
						case DODC_THOMPSON:
							dod_set_user_class(plist_public[i], DODC_MP40)	
						case DODC_GREASE: 
							dod_set_user_class(plist_public[i], DODC_MP44) 	
						case DODC_BAR: 
							dod_set_user_class(plist_public[i], DODC_MP44) 	
						case DODC_SNIPER: 
							dod_set_user_class(plist_public[i], DODC_SCHARFSCHUTZE) 	
						case DODC_30CAL: 
							dod_set_user_class(plist_public[i], DODC_MG42) 	
						case DODC_BAZOOKA: 
							dod_set_user_class(plist_public[i], DODC_PANZERJAGER) 	
					}
				}
				case 1: 
				{
					switch (pl_class)
					{
						case DODC_ENFIELD: 
							dod_set_user_class(plist_public[i], DODC_KAR) 	
						case DODC_STEN:     
							dod_set_user_class(plist_public[i], DODC_MP40)	
						case DODC_BREN:    
							dod_set_user_class(plist_public[i], DODC_MP44)	
						case DODC_MARKSMAN: 
							dod_set_user_class(plist_public[i], DODC_SCHARFSCHUTZE)	
						case DODC_PIAT:    
							dod_set_user_class(plist_public[i], DODC_PANZERJAGER) 	
					}
				}
			}	
		}
		
		
		// On Axis side - transfer to Allied
		else if(is_user_connected(plist_public[i]) == 1 && get_user_team(plist_public[i]) == 2)
		{
			pl_class = dod_get_user_class(plist_public[i])
			
			dod_set_user_team(plist_public[i], 1, 1);
			switch (uk) 
			{
				case 0: 
				{
					switch (pl_class)
					{
						case DODC_KAR:
							dod_set_user_class(plist_public[i], DODC_GARAND)
						case DODC_K43:
							dod_set_user_class(plist_public[i], DODC_CARBINE) 	
						case DODC_MP40:
							dod_set_user_class(plist_public[i], DODC_THOMPSON) 	
						case DODC_MP44: 
							dod_set_user_class(plist_public[i], DODC_GREASE)	
						case DODC_SCHARFSCHUTZE:
							dod_set_user_class(plist_public[i], DODC_SNIPER) 	
						case DODC_FG42: 
							dod_set_user_class(plist_public[i], DODC_BAR) 	
						case DODC_SCOPED_FG42:
							dod_set_user_class(plist_public[i], DODC_BAR) 	
						case DODC_MG34: 
							dod_set_user_class(plist_public[i], DODC_30CAL)	
						case DODC_MG42:
							dod_set_user_class(plist_public[i], DODC_30CAL) 	
						case DODC_PANZERJAGER:
							dod_set_user_class(plist_public[i], DODC_BAZOOKA) 	
					}
				}
				case 1: 
				{
					switch (pl_class)
					{
						case DODC_KAR:
							dod_set_user_class(plist_public[i], DODC_ENFIELD) 	
						case DODC_K43:
							dod_set_user_class(plist_public[i], DODC_ENFIELD) 	
						case DODC_MP40:
							dod_set_user_class(plist_public[i], DODC_STEN) 	
						case DODC_MP44:
							dod_set_user_class(plist_public[i], DODC_STEN) 	
						case DODC_SCHARFSCHUTZE:
							dod_set_user_class(plist_public[i], DODC_MARKSMAN) 	
						case DODC_FG42: 
							dod_set_user_class(plist_public[i], DODC_BREN) 	
						case DODC_SCOPED_FG42:
							dod_set_user_class(plist_public[i], DODC_BREN)	
						case DODC_MG34:
							dod_set_user_class(plist_public[i], DODC_BREN) 	
						case DODC_MG42:
							dod_set_user_class(plist_public[i], DODC_BREN) 	
						case DODC_PANZERJAGER: 
							dod_set_user_class(plist_public[i], DODC_PIAT) 	
					}
				}
			}
		}
	}
	client_print(0,print_chat,"[TEAMS] Teams were swapped")
	
	return PLUGIN_HANDLED
}

public autoswap(id,level,cid)
{
	if (get_pcvar_num(autoswap_enabled)==1)
	{
		new plist_public[32],pnum_public
		new pl_class
		
		get_players(plist_public, pnum_public)
		
		new uk = dod_get_map_info(MI_ALLIES_TEAM)
		
		for(new i=0; i<pnum_public; i++)
		{
			
			// On Allied side - transfer to Axis
			if(is_user_connected(plist_public[i]) == 1 && get_user_team(plist_public[i]) == 1)
			{
				pl_class = dod_get_user_class(plist_public[i])
				dod_set_user_team(plist_public[i], 2, 1);
				switch (uk) 
				{
					case 0: 
					{
						switch (pl_class)
						{
							case DODC_GARAND:
								dod_set_user_class(plist_public[i], DODC_KAR) 	
							case DODC_CARBINE:
								dod_set_user_class(plist_public[i], DODC_K43)	
							case DODC_THOMPSON:
								dod_set_user_class(plist_public[i], DODC_MP40)	
							case DODC_GREASE: 
								dod_set_user_class(plist_public[i], DODC_MP44) 	
							case DODC_BAR: 
								dod_set_user_class(plist_public[i], DODC_MP44) 	
							case DODC_SNIPER: 
								dod_set_user_class(plist_public[i], DODC_SCHARFSCHUTZE) 	
							case DODC_30CAL: 
								dod_set_user_class(plist_public[i], DODC_MG42) 	
							case DODC_BAZOOKA: 
								dod_set_user_class(plist_public[i], DODC_PANZERJAGER) 	
						}
					}
					case 1: 
					{
						switch (pl_class)
						{
							case DODC_ENFIELD: 
								dod_set_user_class(plist_public[i], DODC_KAR) 	
							case DODC_STEN:    
								dod_set_user_class(plist_public[i], DODC_MP40)	
							case DODC_BREN:    
								dod_set_user_class(plist_public[i], DODC_MP44)	
							case DODC_MARKSMAN: 
								dod_set_user_class(plist_public[i], DODC_SCHARFSCHUTZE)	
							case DODC_PIAT:    
								dod_set_user_class(plist_public[i], DODC_PANZERJAGER) 	
						}
					}
				}	
			}
			
			
			// On Axis side - transfer to Allied
			else if(is_user_connected(plist_public[i]) == 1 && get_user_team(plist_public[i]) == 2)
			{
				pl_class = dod_get_user_class(plist_public[i])
				
				dod_set_user_team(plist_public[i], 1, 1);
				switch (uk) 
				{
					case 0: 
					{
						switch (pl_class)
						{
							case DODC_KAR: 
								dod_set_user_class(plist_public[i], DODC_GARAND)
							case DODC_K43:
								dod_set_user_class(plist_public[i], DODC_CARBINE) 	
							case DODC_MP40:
								dod_set_user_class(plist_public[i], DODC_THOMPSON) 	
							case DODC_MP44: 
								dod_set_user_class(plist_public[i], DODC_GREASE)	
							case DODC_SCHARFSCHUTZE:
								dod_set_user_class(plist_public[i], DODC_SNIPER) 	
							case DODC_FG42: 
								dod_set_user_class(plist_public[i], DODC_BAR) 	
							case DODC_SCOPED_FG42:
								dod_set_user_class(plist_public[i], DODC_BAR) 	
							case DODC_MG34: 
								dod_set_user_class(plist_public[i], DODC_30CAL)	
							case DODC_MG42:
								dod_set_user_class(plist_public[i], DODC_30CAL) 	
							case DODC_PANZERJAGER:
								dod_set_user_class(plist_public[i], DODC_BAZOOKA) 	
						}
					}
					case 1: 
					{
						switch (pl_class)
						{
							case DODC_KAR:
								dod_set_user_class(plist_public[i], DODC_ENFIELD) 	
							case DODC_K43:
								dod_set_user_class(plist_public[i], DODC_ENFIELD) 	
							case DODC_MP40:
								dod_set_user_class(plist_public[i], DODC_STEN) 	
							case DODC_MP44:
								dod_set_user_class(plist_public[i], DODC_STEN) 	
							case DODC_SCHARFSCHUTZE:
								dod_set_user_class(plist_public[i], DODC_MARKSMAN) 	
							case DODC_FG42: 
								dod_set_user_class(plist_public[i], DODC_BREN) 	
							case DODC_SCOPED_FG42:
								dod_set_user_class(plist_public[i], DODC_BREN)	
							case DODC_MG34:
								dod_set_user_class(plist_public[i], DODC_BREN) 	
							case DODC_MG42:
								dod_set_user_class(plist_public[i], DODC_BREN) 	
							case DODC_PANZERJAGER: 
								dod_set_user_class(plist_public[i], DODC_PIAT) 	
						}
					}
				}
				
			}
		}
		client_print(0,print_chat,"[TEAMS] Teams were swapped")
	}
	
	return PLUGIN_HANDLED
}
