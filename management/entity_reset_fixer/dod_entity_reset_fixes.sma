/*
	DOD_Entity_Reset_Fixes for DOD 1.3
	by Vet(3TT3V)

	This plugin will fix problems with entities that don't set properly upon map
	(re)initialization. The fix envolves blocking a respawn call to either the
	Ham_DOD_RoundRespawn() or Ham_DOD_RoundRespawnEnt() routines as necessary.

	Notes:
	The Ham_DOD_RoundRespawnEnt() routine is called BEFORE Ham_DOD_RoundRespawn().
	If Ham_DOD_RoundRespawnEnt() is superceded, Ham_DOD_RoundRespawn() isn't called
	at all. Thus, I assume Ham_DOD_RoundRespawn() is called from within the
	Ham_DOD_RoundRespawnEnt() routine. If superceding either one fixes the entity
	reset, then I'd recommend superceding Ham_DOD_RoundRespawn() so that if anything
	else is done within Ham_DOD_RoundRespawnEnt(), it still gets carried out.

	Three entities have been discovered thus far.
	path_track: Because this entity doesn't reset properly, the func_traintrack entity
		loses its path and freezes up. Superceding either routine fixes it.
	func_door: If a door is open upon restarting a round, the door will remain open
		(func_door_rotating entities reset OK). Must supercede the
		Ham_DOD_RoundRespawnEnt() routine.
	dod_round_timer: The timer doesn't get disabled if the Offensive (the team that
		must complete the objectives before the timer runs out) team wins. Thus, if
		the Offensive team wins with only a few seconds remaining, the timer can hit
		0 during the round end time and trigger a win for the Defensive team as well.

	New entities can/will be added as discovered.
*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "dod_entity_reset_fixes"
#define VERSION "1.1"
#define AUTHOR "Vet(3TT3V)"

#define fm_find_ent_by_class(%1,%2) engfunc(EngFunc_FindEntityByString, %1, "classname", %2)

new g_round_ctrl = 0
new g_timer_ent = -1

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	RegisterHam(Ham_DOD_RoundRespawn, "path_track", "HAM_RndRsp")

	RegisterHam(Ham_DOD_RoundRespawnEnt, "func_door", "HAM_RndRsp_ent")

	// Find the 'dod_round_timer' entity if available
	g_timer_ent = fm_find_ent_by_class(g_timer_ent, "dod_round_timer")
	if (g_timer_ent) {
		RegisterHam(Ham_DOD_RoundRespawn, "dod_control_point_master", "HAM_RndRsp_CPM")
		RegisterHam(Ham_Use, "dod_score_ent", "HAM_score_ent_USE")
		RegisterHam(Ham_Think, "dod_round_timer", "HAM_timer_THINK")
	}

	return PLUGIN_CONTINUE
}

public HAM_RndRsp(ent)
{
	return HAM_SUPERCEDE
}

public HAM_RndRsp_ent(ent)
{
	return HAM_SUPERCEDE
}

// Disable the timer, if present, after a team wins.
// And then enable timer when the round reset occurs.
public HAM_RndRsp_CPM(ent)
{
	g_round_ctrl = 0
	ExecuteHamB(Ham_Think, g_timer_ent)

	return HAM_IGNORED
}

public HAM_score_ent_USE(ent)
{
	g_round_ctrl = 1

	return HAM_IGNORED
}

public HAM_timer_THINK(ent)
{
	if (g_round_ctrl)
		return HAM_SUPERCEDE

	return HAM_IGNORED
}
