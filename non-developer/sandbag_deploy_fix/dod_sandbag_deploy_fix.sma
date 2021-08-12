/*****************************************************************************************

	Fix for 'dod_trigger_sandbag' allowing deploy at improper angles
		Written by Vet(3TT3V) for DOD v1.3

******************************************************************************************/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "DoD_Sandbag_Deploy_Fix"
#define VERSION "1.11"
#define AUTHOR "Vet(3TT3V)"

new g_sb_max[1024]		// Index = Entity ID. Initially loaded with the angle and range
new g_sb_min[1024]		// Later, in plugin_init(), Min and Max angles are calculated
new g_max_players

public plugin_precache()
{
	register_forward(FM_KeyValue, "forward_keyvalue")
	return PLUGIN_CONTINUE
}

public forward_keyvalue(ent, handle)	// Load angle and range parameters into arrays
{
	static angle_t[8], angle_y[8], tmpstr[32]
	if (!pev_valid(ent))
		return FMRES_IGNORED

	get_kvd(handle, KV_ClassName, tmpstr, 31)
	if (tmpstr[0] != 100)			// Quick check for proper entity. Most entities
		return FMRES_IGNORED		// will fail this test. (Its a speed thing)
	if (equal(tmpstr, "dod_trigger_sandbag")) {
		get_kvd(handle, KV_KeyName, tmpstr, 31)
		if (equal(tmpstr, "angles")) {
			get_kvd(handle, KV_Value, tmpstr, 31)
			parse(tmpstr, angle_t, 7, angle_y, 7, angle_t, 7)
			g_sb_max[ent] = str_to_num(angle_y)
		} else {
			if (equal(tmpstr, "sandbag_range")) {
				get_kvd(handle, KV_Value, tmpstr, 31)
				g_sb_min[ent] = str_to_num(tmpstr)
			}
		}
	}
	return FMRES_IGNORED
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	g_max_players = get_maxplayers() + 1
	new tmpint
	for (new i = 0; i < 1024; i++) {		// Convert angle and range to Min & Max angles allowed
		if (g_sb_min[i]) {			// Skip if 'sandbag_range' is 0
			tmpint = g_sb_max[i]
			g_sb_max[i] += g_sb_min[i]
			if (g_sb_max[i] > 179)		// Convert to match player angle method
				g_sb_max[i] = (360 - g_sb_max[i]) * -1
			g_sb_min[i] = tmpint - g_sb_min[i] - 1
			if (g_sb_min[i] > 179)
				g_sb_min[i] = (360 - g_sb_min[i]) * -1
		}
	}

	RegisterHam(Ham_Touch, "dod_trigger_sandbag", "HAM_dts_Touch", 1)
}

public HAM_dts_Touch(ent, player)
{
	static Float:p_vu1[3], Float:p_ang[3], p_angle, wpn
	if (pev_valid(player) && (0 < player < g_max_players)) {
		pev(player, pev_vuser1, p_vu1)
		if (pev(player, pev_flags) & (1 << 14) || pev(player, pev_iuser3))
			p_vu1[0] = 0.0							// Crouching or prone, prohibit deployment
		else {
			wpn = get_user_weapon(player)
			switch (wpn) {
				case 11, 17, 18, 21, 23, 27: {			// List of deployable weapons
					if (p_vu1[0] < 2.0) {				// Weapon not yet deployed, so check angles
						pev(player, pev_angles, p_ang)	// Player angle = +0.0 to +179.9 / -0.0 to -179.9
						p_angle = floatround(p_ang[1], floatround_floor)
						p_vu1[0] = 1.0				// Set default to allow deployment
						if (g_sb_max[ent] > g_sb_min[ent]) {
							if (p_angle > g_sb_max[ent] || p_angle < g_sb_min[ent])
								p_vu1[0] = 0.0		// Out of range, prohibit deployment
						} else {
							if (p_angle >= g_sb_max[ent] && p_angle < g_sb_min[ent])
								p_vu1[0] = 0.0		// Out of range, prohibit deployment
						}
					} else
						return HAM_IGNORED
				}
			}
		}
		set_pev(player, pev_vuser1, p_vu1)					// Set deployment value
	}
	return HAM_IGNORED
}
