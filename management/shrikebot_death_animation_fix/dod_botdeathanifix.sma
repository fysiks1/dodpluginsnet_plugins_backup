#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN_NAME "DoD_bot_death_ani_fix"
#define PLUGIN_VERSION "1.0H"
#define PLUGIN_AUTHOR "VET"

#define MAX_PLAYERS 32
new g_watch[MAX_PLAYERS + 1]
new Float:g_frame[MAX_PLAYERS + 1]
new Float:g_step_amt
new g_frame_step

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

	RegisterHam(Ham_Killed, "player", "HAM_player_death", 1)
	RegisterHam(Ham_Player_PreThink, "player", "HAM_client_think")

	g_frame_step = register_cvar("bot_ani_step", "0.5")
	g_step_amt = get_pcvar_float(g_frame_step)
}

public HAM_client_think(id)
{ 
	static Float:panim

	if (!g_watch[id])
		return FMRES_IGNORED
	switch (pev(id, pev_deadflag)) {
		case 3: {
			if (pev(id, pev_frame) < 250) {
				switch (g_watch[id]) {
					case 1: {
						g_frame[id] = float(pev(id, pev_frame))
						g_watch[id] = 2
					}
					case 2: {
						g_frame[id] += g_step_amt
						panim = float(floatround(g_frame[id]))
						set_pev(id, pev_frame, panim)
					}
				}
			} else {
				g_watch[id] = 0
			}
		}
		case 0: {
			g_watch[id] = 0
		}
	}
	return FMRES_IGNORED
}

public HAM_player_death(victim, attacker, gib)
{
	g_watch[victim] = is_user_bot(victim)

	return PLUGIN_HANDLED
}
