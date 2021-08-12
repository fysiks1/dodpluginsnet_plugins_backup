/*
   DOD Disable Flags
   by Wilson [29th ID]
   visit our Realism Unit at www.29th.org
   
   Made for the DoD Plugins Community
   www.dodplugins.net
   
   DESCRIPTION
   Provides admin commands to enable/disable flag capping,
   as well as a CVAR that will automatically disable capping
   on map change if set.
   
   This plugin does NOT remove the flags. Removing flags prevents
   you from adding them back in mid-game. This plugin simply
   toggles whether or not players can touch flags or capture areas.
   This method is much more efficient than removing flags and does 
   not have an effect on spawnpoints in certain maps that are 
   dependant on flags.
   
   COMMANDS
   amx_cvar dod_disableflags <0/1>
	Setting to 1 will automatically disable flags on map change
   disable_flags
	Admin command to disable the flags mid-game
   enable_flags
	Admin command to enable the flags mid-game
	
   NOTES
   By default, ADMIN_CVAR is required for the console commands. You
   can change this in the #define ADMIN_REQ line in the header.
*/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#define PLUGIN "Dod Disable Flags"
#define VERSION "1.0"
#define AUTHOR "29th ID"

#define ADMIN_REQ ADMIN_CVAR

new p_enabled;

public plugin_init() {
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	p_enabled = register_cvar( "dod_disableflags", "0" );
	
	register_event( "RoundState", "event_RoundState", "a" );
	
	register_concmd( "disable_flags", "cmd_flags", ADMIN_REQ );
	register_concmd( "enable_flags",  "cmd_flags", ADMIN_REQ );
}

public event_RoundState() {
	if( get_pcvar_num(p_enabled) && read_data(1) == 1 )
		set_task( Float:0.5, "set_flags" );
}

public cmd_flags( id, level, cid ) {
	if( !cmd_access( id, level, cid, 1) )
		return PLUGIN_HANDLED;
	
	new cmd[16];
	read_argv( 0, cmd, 15 );
	
	if( equali(cmd, "disable_flags") )	set_flags( id, false );
	else if( equali(cmd, "enable_flags") )	set_flags( id, true );
	
	return PLUGIN_HANDLED;
}

public set_flags( id, bool:value ) {
	// Find all control points and capture areas
	new ent = -1;
	while( ( ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "dod_control_point" ) ) != 0 )
	{
		set_pev( ent, pev_solid, value );
	}
	
	ent = -1;
	while( ( ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "dod_capture_area" ) ) != 0 )
	{
		set_pev( ent, pev_solid, value );
	}
	
	// Set the CVAR as well in case of cap out or map change
	set_pcvar_num( p_enabled, value );
		
	// Echo the command if an admin used it
	if( id ) {
		// Echo to console of admin
		console_print( id, "[AMXX] %s flags", value ? "Enabled" : "Disabled" );
		
		new name[32];
		get_user_name( id, name, 31 );
		
		new msg[128];
		format( msg, 127, "[AMXX] %s used command %s", name, value ? "enable_flags" : "disable_flags" );
		
		for( new i = 1; i <= 32; i++ ) {
			if( is_user_connected(i) )
				client_print( i, print_chat, msg );
		}
	}
}
