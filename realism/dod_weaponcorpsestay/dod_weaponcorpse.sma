/* DOD WEAPON/CORPSE STAY
 * Created by the 29th Infantry Division
 * www.29th.org (A Realism Unit)
 * www.dodrealism.branzone.com -- Revolutionizing Day of Defeat Realism
 *
 * DESCRIPTION
 * Will allow a server-side control of how long weapons stay
 * on the ground, and how long corpses stay on the ground.
 * Warning: Having too many weapons/corpses will cause lag
 * (This is done by very high settings of the CVARs)
 *
 * KNOWN BUGS
 * If player dies in mid air, fake corpse will fall through the ground
 *
 * CVARs
 * dod_weaponstay <-1/0/#>
 *   Setting to  0 will turn off Weaponstay
 *   Setting to -1 will force weapons to stay the entire round
 *   Setting above 0 will force weapons to stay for their normal period plus this #
 *
 * dod_corpsestay <-1/0/#>
 *   Setting to  0 will turn off Corpsestay
 *   Setting to -1 will force corpses to stay the entire round
 *   Setting above 0 will force corpses to stay this #
 */

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#pragma semicolon 1

#define PLUGIN "Weapon/Corpse Stay"
#define VERSION "1.0"
#define AUTHOR "29th ID"


new g_cvarWeapon, g_cvarCorpse, g_msgClCorpse, g_msgRoundState;
new g_szWeaponbox[32] = "weaponbox";
new g_szFakeCorpse[32] = "fakecorpse";

public plugin_init() {
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	// Register Think
	register_forward( FM_Think, "handle_think", 1 );
	
	// Register Messages
	g_msgClCorpse = get_user_msgid( "ClCorpse" );
	register_message( g_msgClCorpse, "handle_corpse" );
	g_msgRoundState = get_user_msgid( "RoundState" );
	register_message( g_msgRoundState, "handle_roundstate" );
	
	// Register CVARs
	g_cvarWeapon = register_cvar( "dod_weaponstay", "0" );
	g_cvarCorpse = register_cvar( "dod_corpsestay", "0" );
}

public handle_think( ent ) {
	if( !pev_valid( ent ) ) return PLUGIN_CONTINUE;
	static m_szClass[32];
	// Get Entity's Classname
	pev( ent, pev_classname, m_szClass, 31 );
	
	// If it's a weaponbox
	if( equal( m_szClass, g_szWeaponbox ) )
	{
		// Get current next think
		new Float:m_flNextThink, Float:m_flNewSetting;
		pev( ent, pev_nextthink, m_flNextThink );
		// Get CVAR Setting
		new Float:m_flWeapon = get_pcvar_float( g_cvarWeapon );
		
		// If CVAR is 0, return. If it's greater than 0, get new value. If -1, will set to 0.0 (no limit)
		if( m_flWeapon == 0 ) return FMRES_IGNORED;
		else if( m_flWeapon == -1 ) m_flNewSetting = 0.0;
		else if( m_flWeapon > 0 ) m_flNewSetting = m_flNextThink + m_flWeapon;
		
		if( m_flNextThink > 0.0 )
		{
			// Set next think to new setting
			set_pev( ent, pev_nextthink, m_flNewSetting );
			return FMRES_HANDLED;
		}
	}
	else if( equal( m_szClass, g_szFakeCorpse ) )
	{
		engfunc( EngFunc_RemoveEntity, ent );
		return FMRES_HANDLED;
	}
	return FMRES_IGNORED;
}

public handle_corpse() {
	// Get CVAR Data
	new Float:m_flNewSetting, Float:m_flCorpse = get_pcvar_float( g_cvarCorpse );
	
	// If CVAR is 0, return. If it's greater than 0, get new value. If -1, will set to 0.0 (no limit)
	if( m_flCorpse == 0.0 ) return PLUGIN_CONTINUE;
	else if( m_flCorpse == -1.0 ) m_flNewSetting = 0.0;
	else if( m_flCorpse > 0.0 ) m_flNewSetting = get_gametime() + m_flCorpse;
	
	// Retrieve Message Data
	
	// Model
	new m_szModel[64];
	get_msg_arg_string( 1, m_szModel, 63 );
	format( m_szModel, 63, "models/player/%s/%s.mdl", m_szModel, m_szModel );
	
	// Origin
	new Float:m_flOrigin[3];
	m_flOrigin[0] = get_msg_arg_float( 2 );
	m_flOrigin[1] = get_msg_arg_float( 3 );
	m_flOrigin[2] = get_msg_arg_float( 4 );
	m_flOrigin[2] += 1; // Looks underground without this
	
	// Angles
	new Float:m_flAngles[3];
	m_flAngles[0] = get_msg_arg_float( 5 );
	m_flAngles[1] = get_msg_arg_float( 6 );
	m_flAngles[2] = get_msg_arg_float( 7 );
	
	// Sequence
	new m_iSequence = get_msg_arg_int( 8 );
	
	// Create Fake Corpse Entity
	new ent = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
	set_pev( ent, pev_angles, m_flAngles );
	set_pev( ent, pev_classname, g_szFakeCorpse );
	set_pev( ent, pev_framerate, Float:1.0 );
	set_pev( ent, pev_sequence, m_iSequence );
	set_pev( ent, pev_origin, m_flOrigin );
	set_pev( ent, pev_nextthink, m_flNewSetting );
	engfunc( EngFunc_SetModel, ent, m_szModel );
	set_pev( ent, pev_mins, {Float:-16.0,Float:-16.0,Float:-18.0} );
	set_pev( ent, pev_maxs, {Float:16.0,Float:16.0,Float:18.0} );
	engfunc( EngFunc_DropToFloor, ent );
	
	return PLUGIN_HANDLED;
}

// Delete all fake corpses at round start
public handle_roundstate() {
	if( get_msg_arg_int( 1 ) == 0 )
	{
		new m_iStartEnt = 1;
		while( ( m_iStartEnt = engfunc( EngFunc_FindEntityByString, m_iStartEnt, "classname", g_szFakeCorpse ) ) )
		{
			if ( pev_valid(m_iStartEnt) )
				engfunc( EngFunc_RemoveEntity, m_iStartEnt );
		}
	}
}

stock echo_all( print_type, szMsg[] ) {
	for( new i = 1; i <= 32; i++ )
	{
		client_print( i, print_type, szMsg );
	}
}
