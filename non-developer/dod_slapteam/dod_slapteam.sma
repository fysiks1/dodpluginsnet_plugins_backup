// amx_slapteam coded/developed by StrontiumDog
// Plugin in use at TheVille.Org II - DoD v1.3 Custom Map Server FF ON
// 63.210.145.199:27015
// http://www.theville.org 


#include <amxmodx>
#include <amxmisc>


public plugin_init(){
	register_plugin("DoD Slap Teams","1.2","StrontiumDog")
	register_concmd("amx_slapteam","admin_slapteams",ADMIN_SLAY,"<1 | 2 | 3> slap players - 1: Allies - 2: Axis - 3: All")
	register_cvar("amx_slapteam_admins", "0") // do we slap admins 0=no 1=yes
	register_cvar("amx_slapteam_value", "0") // How much to slap team: default 0
}

public admin_slapteams(id,level,cid){
	if (!cmd_access(id,level,cid,2))
	{
		console_print(id,"[SlapTeam] You need to be an Admin to use this command")
		return PLUGIN_HANDLED
	}
	
	new arg[32]
	read_argv(1, arg, 31)
	new team = str_to_num(arg)
	if (!team)
		return PLUGIN_HANDLED

	new player[32],p_total
	get_players(player, p_total)
	
	new myname[33]
	get_user_name(id, myname, 32)
	
	switch (team) 
	{
	case 1:
		{
			for(new i=0; i<p_total; i++)
			{
				if(is_user_connected(player[i]) == 1 && get_user_team(player[i]) == 1 && is_user_alive(player[i]) == 1 && check_ad(player[i]) == 0)
				{
						user_slap(player[i],get_cvar_num("amx_slapteam_value"))
				}
			}
		}
		
	case 2:
		{
			for(new i=0; i<p_total; i++)
			{
				if(is_user_connected(player[i]) == 1 && get_user_team(player[i]) == 2 && is_user_alive(player[i]) == 1 && check_ad(player[i]) == 0)
				{
						user_slap(player[i],get_cvar_num("amx_slapteam_value"))
				}
			}
		}
		
	case 3:
		{
			for(new i=0; i<p_total; i++)
			{
				if(is_user_connected(player[i]) == 1 && is_user_alive(player[i]) == 1 && check_ad(player[i]) == 0)
				{
						user_slap(player[i],get_cvar_num("amx_slapteam_value"))
				}
			}
		}
	
	default:
   		{
      	 client_print(id, print_chat, "amx_slapteam <1 | 2 | 3> slap players - 1: Allies - 2: Axis - 3: All")
    	}
	}
	return PLUGIN_HANDLED
}

public check_ad(check)
{
if (is_user_admin(check) == 1 && get_cvar_num("amx_slapteam_admins") == 0)
	{
	return 1;
	}
else return 0;
}

