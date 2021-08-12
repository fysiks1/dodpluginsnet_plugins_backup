#include <amxmodx>

#define PLUGIN "DoD TeamKill Sound"
#define VERSION "1.0"
#define AUTHOR "dimon1052"

new plA, plB, players[32], pnum, i, name[32]

public plugin_init()
{	
	register_plugin("DoD TeamKill Sound","1.0","dimon1052")
	register_cvar("dod_teamkill_sound", "1.0")
	register_event("DeathMsg", "death_event", "a")
}

public death_event()
{
	if(get_cvar_num("tk_sound") != 0) 
	{
		plA = read_data(1)
   		plB = read_data(2)
		if(get_user_name(plA, name, 31) != get_user_name(plB, name, 31))
		{
			if(get_user_team(plA) == get_user_team(plB))
			{
				play_sound()
			}
		}
	}
}

public play_sound()
{
	get_players(players, pnum, "ch")
	for (i = 0; i < pnum; i++)
	{
		client_cmd(players[i], "spk misc/teamkill.wav")
	}
}

public plugin_precache()
{
	precache_sound("misc/teamkill.wav");
}