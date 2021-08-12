#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#define PLUGIN	"DOD Spawn Forward"
#define AUTHOR	"Captain Wilson"
#define VERSION	"1.0"

new const gName[32] = "dod_player_spawn"; // This is the name of the forward
new gForward, gReturn;

public plugin_init() {
	register_plugin( PLUGIN, VERSION, AUTHOR );
	register_message( get_user_msgid("PStatus"), "msg_PStatus" );
	register_forward( FM_Sys_Error, "plugin_end" );
	
	if( (gForward = CreateMultiForward(gName, ET_IGNORE, FP_CELL)) < 1 )
		log_amx( "Error creating %s forward", gName );
}

public msg_PStatus( msgid, msgdest, id ) {
	new player = get_msg_arg_int( 1 );
	new status = get_msg_arg_int( 2 );
	
	if( is_user_connected(player) && status == 0 ) // If Alive
	{
		// Without a slight delay, server will crash
		set_task( Float:0.1, "spawn_forward", player );
	}
}

public spawn_forward( id ) {
	if( !ExecuteForward( gForward, gReturn, id ) )
		log_amx( "Error executing %s forward", gName );
}

public plugin_end() {
	DestroyForward( gForward );
}