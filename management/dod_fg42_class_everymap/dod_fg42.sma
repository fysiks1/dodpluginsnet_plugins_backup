#include <amxmodx>
#include <amxmisc>
#include <dodx>
#include <dodfun>
#include <fakemeta>

#pragma semicolon 1

#define PLUGIN "Enable FG42"
#define VERSION "1.0"
#define AUTHOR "29th ID"

#define MENU_AXIS_INF	13
#define MENU_AXIS_PARAS 14

new p_enabled, p_limit_fg42, p_limit_fg42_s;
new g_isAxisParas, bool:g_blockmsg[33];

public plugin_init() {
	register_plugin( PLUGIN, VERSION, AUTHOR );
	register_message( get_user_msgid( "VGUIMenu" ), "hook_VGUIMenu" );
	
	register_message( get_user_msgid( "TextMsg" ), 	"handle_textmsg" );
	
	register_clcmd( "cls_fg42", 	"cls_fg42_override" );
	register_clcmd( "cls_fg42_s", 	"cls_fg42_override" );
	
	p_enabled 		= register_cvar( "dod_fg42", "1" );
	p_limit_fg42 	= get_cvar_pointer( "mp_limitaxisfg42" );
	p_limit_fg42_s 	= get_cvar_pointer( "mp_limitaxisfg42s" );
	g_isAxisParas 	= dod_get_map_info( MI_AXIS_PARAS );
}

// Hook axis class menu and change it to axis para class menu
public hook_VGUIMenu() {
	if( plugin_enabled() )
	{
		if( get_msg_arg_int( 1 ) == MENU_AXIS_INF )
			set_msg_arg_int( 1, ARG_BYTE, MENU_AXIS_PARAS );
	}
}

public cls_fg42_override( id ) {
	if( plugin_enabled() )
	{
		if( get_user_team(id) == AXIS )
		{
			// Get Class Selection
			new cmd[32];
			read_argv( 0, cmd, 31 );
			new scoped = equali( cmd, "cls_fg42_s" );
			
			new limitfg42  	= get_pcvar_num( p_limit_fg42 );
			new limitfg42s 	= get_pcvar_num( p_limit_fg42_s );
			
			// Get Current Usage of Weapons to Determine Availability
			new totalfg42, totalfg42s;
			for( new i = 1; i <= 32; i++ )
			{
				if( !is_user_connected(i) ) continue;
				
				if( dod_get_user_class(i) == DODC_FG42 ) totalfg42++;
				else if( dod_get_user_class(i) == DODC_SCOPED_FG42 ) totalfg42s++;
			}
			
			// Regular FG42
			if( !scoped && (totalfg42 < limitfg42 || limitfg42 == -1) )
			{
				if( !dod_get_user_class(id) ) // If newly connected/first class chosen
				{
					g_blockmsg[id] = true;
					engclient_cmd( id, "cls_k43" ); // For some reason, the client must actually be a class to spawn
					client_print( id, print_chat, "#game_spawn_as #class_axispara_fg42bipod" ); // Multi-Lingual Support ftw
				}
				else
				{
					client_print( id, print_chat, "#game_respawn_as #class_axispara_fg42bipod" ); // Multi-Lingual Support ftw
				}
				
				dod_set_user_class( id, DODC_FG42 );
				dod_set_model( id, "axis-inf" );
				
				return PLUGIN_HANDLED;
			}
			
			// Scoped FG42
			else if( scoped && (totalfg42s < limitfg42s || limitfg42s == -1) )
			{
				if( !dod_get_user_class(id) ) // If newly connected/first class chosen
				{
					g_blockmsg[id] = true;
					engclient_cmd( id, "cls_k43" ); // For some reason, the client must actually be a class to spawn
					client_print( id, print_chat, "#game_spawn_as #class_axispara_fg42scope" ); // Multi-Lingual Support ftw
				}
				else
				{
					client_print( id, print_chat, "#game_respawn_as #class_axispara_fg42scope" ); // Multi-Lingual Support ftw
				}
				
				dod_set_user_class( id, DODC_SCOPED_FG42 );
				dod_set_model( id, "axis-inf" );
				
				return PLUGIN_HANDLED;
			}
		}
	}
	return PLUGIN_CONTINUE;
}

// Block "You will respawn as Stosstruppe" message
public handle_textmsg( msgid, msgdest, id ) {
	if( plugin_enabled() )
	{
		if( g_blockmsg[id] && get_msg_args() > 2 && get_msg_argtype( 3 ) == ARG_STRING )
		{
			new arg3[32];
			get_msg_arg_string( 3, arg3, 31 );
			
			if( equal(arg3, "#class_axis_k43") )
			{
				g_blockmsg[id] = false;
				return PLUGIN_HANDLED;
			}
		}
	}
	return PLUGIN_CONTINUE;
}

// Stop forcing model if player goes from FG42 class to Allies
public dod_client_changeteam( id, team, oldteam ) {
	if( team == ALLIES && oldteam == AXIS )
		dod_clear_model( id );
}

public client_connect( id ) g_blockmsg[id] = false;

plugin_enabled() return ( get_pcvar_num(p_enabled) && !g_isAxisParas );
