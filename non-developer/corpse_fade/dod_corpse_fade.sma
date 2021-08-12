/*****************************************************************************************
*
*	DOD Corpse Fade by Vet(3TT3V)
*		For use with DOD 1.3
*		Inspired by DoD Weapon/Corpse Stay by Wilson [29th ID]
*
*	Description:
*		This plugin simply fades corpses away instead of sinking into oblivion
*		The time before fading and the time of fading is configurable via CVar.
*
*	CVARs:
*		corpse_fade_enable <0/1> (disable/Enable fade effect)
*		corpse_fade_delay <#.#> (Time before corpse starts fading away. Default 7.0)
*		corpse_fade_decay <#.#> (Time it takes for corpse to fade away. Default 7.0)
*
******************************************************************************************/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "DOD_Corpse_Fade"
#define VERSION "1.7"
#define AUTHOR "Vet(3TT3V)"
#define SVALUE "v1.7 by Vet(3TT3V)"

// From VEN's FM_Utilities
#define fm_set_model(%1,%2) engfunc(EngFunc_SetModel, %1, %2)
#define fm_set_origin(%1,%2) engfunc(EngFunc_SetOrigin, %1, %2)
#define fm_set_size(%1,%2,%3) engfunc(EngFunc_SetSize, %1, %2, %3)
#define fm_remove_entity(%1) engfunc(EngFunc_RemoveEntity, %1)
#define fm_create_entity(%1) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, %1))

#define CORPSE_ID1 22351	// "vcf1"
#define CORPSE_ID2 22352	// "vcf2"
#define CORPSE_DELAY "7.0"
#define CORPSE_DECAY "7.0"
#define REND_AMTF 250.0
#define REND_STEP 0.10
#define CORPSE_MINS Float:{-16.000000, -16.000000, -36.000000}	// Player model size
#define CORPSE_MAXS Float:{ 16.000000,  16.000000,  36.000000}
#define MAX_PLAYERS 32

new g_enable
new g_delay_time
new g_decay_time
new Float:g_decay_step

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar(PLUGIN, SVALUE, FCVAR_SERVER|FCVAR_SPONLY)

	register_event("RoundState", "cleanup_corpses", "a", "1=1")
	register_message(get_user_msgid("ClCorpse"), "corpse_message")
	RegisterHam(Ham_Think, "info_target", "HAM_corpse_think")

	g_enable = register_cvar("corpse_fade_enable", "1")
	g_delay_time = register_cvar("corpse_fade_delay", CORPSE_DELAY)
	g_decay_time = register_cvar("corpse_fade_decay", CORPSE_DECAY)
}

public HAM_corpse_think(ent)
{
	static Float:tmp_flt
	if (pev_valid(ent)) {
		switch (pev(ent, pev_iuser1)) {
			case CORPSE_ID1: {		// Fade the primary corpse to 0
				pev(ent, pev_renderamt, tmp_flt)
				tmp_flt -= g_decay_step
				if (tmp_flt < 1.0) {
					fm_remove_entity(ent)
					return HAM_SUPERCEDE
				}
				set_pev(ent, pev_renderamt, tmp_flt)
				tmp_flt = get_gametime() + REND_STEP
				set_pev(ent, pev_nextthink, tmp_flt)
			}
			case CORPSE_ID2: {		// Delete the 'flicker hiding' corpse
				fm_remove_entity(ent)
				return HAM_SUPERCEDE
			}
		}
	}
	return HAM_IGNORED
}

public corpse_message()
{
	if (!get_pcvar_num(g_enable))
		return PLUGIN_CONTINUE

	static Float:org_info[3], Float:ang_info[3], Float:n_think
	static pla_model[32], set_model[128]
	static seq, body

	new ent = fm_create_entity("info_target")
	set_pev(ent, pev_iuser1, CORPSE_ID1)

	get_msg_arg_string(1, pla_model, 31)
	format(set_model, 127, "models/player/%s/%s.mdl", pla_model, pla_model)
	fm_set_model(ent, set_model)
	fm_set_size(ent, CORPSE_MINS, CORPSE_MAXS)

	seq = get_msg_arg_int(8)
	set_pev(ent, pev_sequence, seq)

	set_pev(ent, pev_solid, SOLID_TRIGGER)
	set_pev(ent, pev_movetype, MOVETYPE_TOSS)

	org_info[0] = get_msg_arg_float(2)
	org_info[1] = get_msg_arg_float(3)
	org_info[2] = get_msg_arg_float(4)
	fm_set_origin(ent, org_info)

	ang_info[0] = get_msg_arg_float(5)
	ang_info[1] = get_msg_arg_float(6)
	ang_info[2] = get_msg_arg_float(7)
	set_pev(ent, pev_angles, ang_info)

/* BODY INFO
On the player model. There are 4 model part groups, Body, Helmet, Head and Gear which are set via the pev_body key.
Once you've cycled through all of one body part, increasing the value jumps to the next body part. Then the count
starts all over again. Kind of a funky binary count, only in decimal.

The Body part has 6 submodels (#s 0 - 5).
The Helmet part has 8 submodels (#s that are multiples of 6 (0, 6, 12, 18, 24, 30, 36, 42).
The Head part has 7 submodels (#s that are multiples of 48 (0, 48, 96, 144, 192, 240, 288).
The Gear part has 7 submodels (#s that are multiples of 336 (0, 336, 672, 1008, 1344, 1680, 2016)

So, to eliminate the Gear part, do the math. And like I said, while you CAN set pev_body to these values on a PLAYER,
the value seems to be limited to byte-size on other entity types. Weird. But then again, I think DOD is the only HL1
mod to have this many body options.
*/

	body = get_msg_arg_int(9)
	//client_print(0, print_chat, "Corpse Model:%s, Seq:%d, Body:%d", pla_model, seq, body)
	body -= (body / 336) * 336
	set_pev(ent, pev_body, body)

	set_pev(ent, pev_frame, 256.0)

	set_pev(ent, pev_rendermode, kRenderTransAlpha)
	set_pev(ent, pev_renderamt, REND_AMTF)

	n_think = get_gametime() + get_pcvar_float(g_delay_time)
	set_pev(ent, pev_nextthink, n_think)

	ent = fm_create_entity("info_target")	// Create an identical 2nd entity to cover the 1st because when
	set_pev(ent, pev_iuser1, CORPSE_ID2)	// MOVETYPE_TOSS and SOLID_TRIGGER are applied, it causes a
	fm_set_model(ent, set_model)			// 1 frame flicker. This entity will hide the flickering.
	fm_set_origin(ent, org_info)
	set_pev(ent, pev_angles, ang_info)
	set_pev(ent, pev_sequence, seq)
	set_pev(ent, pev_body, body)
	set_pev(ent, pev_frame, 256.0)
	set_pev(ent, pev_rendermode, kRenderTransAlpha)
	set_pev(ent, pev_renderamt, REND_AMTF)
	n_think = get_gametime() + 0.1
	set_pev(ent, pev_nextthink, n_think)

	g_decay_step = REND_AMTF/(get_pcvar_float(g_decay_time)/REND_STEP)

	return PLUGIN_HANDLED
}

public cleanup_corpses()
{
	new ent = -1
	while ((ent = fm_find_ent_by_integer(ent, pev_iuser1, CORPSE_ID1))) {
		fm_remove_entity(ent)
	}
	while ((ent = fm_find_ent_by_integer(ent, pev_iuser1, CORPSE_ID2))) {
		fm_remove_entity(ent)
	}

	return PLUGIN_CONTINUE
}

stock fm_find_ent_by_integer(index, pev_field, value) {
	static maxents
	if (!maxents)
		maxents = global_get(glb_maxEntities)

	for (new i = index + 1; i < maxents; ++i) {
		if (pev_valid(i) && pev(i, pev_field) == value)
			return i
	}

	return 0
}
