//=============================================================//
//                        INFOS                                //
//=============================================================//
//  Createur : RaphXyZ alias =]S.T.F[= R@F
//  URL : http://www.raph.be
//  URL2 : http://www.team-stf.com
//
//  Commandes : 
//              - amx_con_music < 0 - 1 > (Desable or Enable the music connection)
//              - amx_con_message < 0 - 1 > (Desable or Enable the welcom message)
//              - amx_adm_sound < 0 - 1 > (Desable or Enable the admin comming sound)
//              - amx_mbr_sound < 0 - 1 > (Desable or Enable  the member comming sound)
//              - amx_con_stopsound < 0 - 1 > (Desable or Enable the automatic stopsound)
//              - amx_con_log < 0 - 1 > (Desable or Enable the accept players log)
//                                                     Cela permet de ne plus affiché le reglement aux personnes l'ayant deja accepté
//              - amx_con_erlogs (Erease Logs Files)
//                                              Si vous videz le fichier logs tout devra de nouveau accepter les regles.
//              - amx_adm_skin < 0 - 1 > (Desable or Enable the custom skins admin)
//              - amx_show_rules (Post the rules with everyone during the part)
//              - amx_restrict_name < nick > (add a new restrict name in the retrict names file or in the dbi)
//              - amx_con_belmode < 0 - 1 > (Desable or Enable add nade at respawn)
//              - amx_con_tagprotection < 0 - 1 > (Desable or Enable the tag protection)
//              - amx_con_nbrltrnick < 1 - 2 - 3 - ... > (Number minimum of caracters of the nick name)
//              - amx_con_tag < TAG > (The tag of your team. Only the member of your team is autorised)
//
// Changes Log :
//              - 03.06.2006 - 0.1
//                	  * Done!
//              - 22.06.2006 - 0.2
//                   * Fix possible lag :-s
//              - 10.07.2006 - 0.3b
//                   * Code Was optimised (80%)
//                   * Preparing code from amxmodx 1.75 (realease) because the current version does not function for the admin skins!
//                   * Transformation on a Multi-languages plugin
//                   * Fix Precaching download
//                   * Reduction in the resources used by the posting of the rules
//                   * No server planting if you do not have put the .mdl files
//                   * No server crash if you do not have put the sound files
//                   * BelMode was optimised
//                   * All the sounds can be in .wav or .mp3
//                   * Fix bug when client refuse the rules
//              - 11.07.2006 - 0.3
//                   * The plugin is ready for amxmodx 1.75
//              - 17.07.2006 - 0.4
//                   * Fix the bug if an admin or a member quit the server and a new client takes his id!
//                   * Various improvement of the code
//              - 24.07.2006 - 0.5
//                   * Add a restrict names list in "addons/amxmodx/configs/restrictnames.ini"
//                   * Add a new command "amx_restrict_nick < nickname >" (add a new restricted nick in "addons/amxmodx/configs/restrictnames.ini") 
//                      The client who respawn with one of these names will be kické with reason "Incorrect nickname!"
//                   * Add CVAR "amx_con_restrictname" < 0 - 1 > Enable or Desable the nickname checking
//              - 25.07.2006 - 0.6
//                   * Fix music none stop
//                   * Add a TAG Protection
//                   * Add cammand amx_con_tagprotection "[TAG-CLAN]" (All players who is not member of the TEAM, will not be able to have the tag)
//               - 26.07.2006 - 0.7
//                   * Fix all lttles bugs!
//               - 26.07.2006 - 0.7.1
//                   * Add a possibility SQL plugin! For desable the SQL mod, add "//" front the "#define USING_SQL"
//               - 27.07.2006 - 0.7.2
//                   * Add all nick name of player connect in data base
//               - 31.07.2006 - 0.7.3
//                   * Add number of visits from client
//                   * Add the date of the last visite from the client
//                   * Fix a litle laggy (reduction in the number of connection to the data base)
//               - 13.08.2006 - 0.7.4
//                   * Fixing DBI Error and improvement of the code
//                   * Remove the forcing precache of skins with the Fakemeta until
//               - 18.08.2006 0.7.5
//                   * I have find the bug in my rules menu :) And i have fixed it !
//                      The plugin is finished ;)
//               - 06.11.2006 0.8.5
//                    * Admin skins fixed!
//                    * Not download admin skins if mp_clan_match is set to 1
//                    * Changing commands to amx_con_erlogs amx_con_erlogs amx_show_rules
//               - 11.11.2006 0.9.5
//                    * Fix Error: Run time error 10 (plugin "dod_connection.amxx") (native "set_pcvar_num") Invalid CVAR pointer
//
//=============================================================//

// #define USING_SQL

#include <amxmodx>
#include <dodx>
#include <fun>
#include <amxmisc>

#if defined USING_SQL
#include <dbi>
#endif

#define LEVEL_ADMIN		ADMIN_BAN
#define LEVEL_MEMBER	ADMIN_RESERVATION
#define MAX_RESTRICT_NAME 120

//=============================================================//
//         Definition des fichiers skins et sons              //
//=============================================================//

// Don't touch !
enum sons {
	musique,
	message,
	adm_connect,
	mbr_connect
};

// Custom sounds in sound folder
new const g_SonsList[sons][128] = {
	"connection/connect.mp3",
	"connection/message.wav",
	"connection/adjoin.wav",
	"connection/mbjoin.wav"
};

// Custum models skins admin in models/player/ (not to reverse)
new models[4][128] = {
	"admin-allies/admin-allies.mdl",
	"admin-allies/admin-alliesT.mdl",
	"admin-axis/admin-axis.mdl",
	"admin-axis/admin-axisT.mdl"
};

// The names from the folder ex : admin-allies and admin-axis (not to reverse)
new models_type[2][32] = {
	"admin-allies",
	"admin-axis"
};

new PLUGIN_AUTH[]		= "=]S.T.F[= R@F";
new PLUGIN_NAME[]		= "DoD Connection";
new PLUGIN_VERSION[] 	= "0.9.5";
new indexregles[]		= "addons/amxmodx/configs/rules.txt";

#if defined USING_SQL
new Sql:sql, Result:result, Result:rresult;
#else
new regleslog[]			= "addons/amxmodx/configs/rules.log";
new restrictnames[]		= "addons/amxmodx/configs/restrictnames.ini";
#endif

new bool:is_an_admin[33] = { false, ...};
new bool:is_a_member[33] = { false, ...};
new bool:is_an_autorised[33] = { false, ...};
new g_restrictname[MAX_RESTRICT_NAME][128];
new text[1023];
new g_adm_sound, g_mbr_sound, g_con_nbrLtrNick, g_adm_skin, g_con_music, g_con_mess, g_nbrRestrictNames;
new g_con_restrictname, g_con_tagprotection, g_con_stopsound, g_con_belmode, g_con_log, g_con_rules;

public plugin_init() {
	register_plugin( PLUGIN_NAME , PLUGIN_VERSION , PLUGIN_AUTH );
	register_cvar( "dod_connection" , PLUGIN_VERSION , FCVAR_SERVER | FCVAR_EXTDLL | FCVAR_SPONLY );
	register_dictionary("dod_connection.txt");

	register_menucmd( register_menuid( PLUGIN_NAME ) , 1023 , "action_con_menu" );
	
	register_concmd( "amx_show_rules" , "affMenu2" , LEVEL_ADMIN , ": < authid , nick , @team ou #userid > Showing rules to everyone." );
	register_concmd( "amx_con_erlogs" , "supLog" , LEVEL_ADMIN , ": < 1 > Erase the connect logs." );
	register_concmd( "amx_restrict_name" , "restrictNick" , LEVEL_ADMIN , ":< authid , nick , @team ou #userid > Add an restricted name on the restrict list." );

	g_con_rules				= register_cvar( "amx_con_rules" , 			"1" );
	g_adm_sound 			= register_cvar( "amx_adm_sound" , 			"0" );
	g_mbr_sound 			= register_cvar( "amx_mbr_sound" , 			"0" );
	g_adm_skin 				= register_cvar( "amx_adm_skin" , 			"0" );
	g_con_music 			= register_cvar( "amx_con_music" , 			"1" );
	g_con_mess 				= register_cvar( "amx_con_mess" , 			"1" );
	g_con_log 				= register_cvar( "amx_con_log" , 			"1" );
	g_con_stopsound 		= register_cvar( "amx_con_stopsound" , 		"1" );
	g_con_belmode 			= register_cvar( "amx_con_belmode" , 		"1" );
	g_con_restrictname 		= register_cvar( "amx_con_restrictname" , 	"1" );
	g_con_tagprotection		= register_cvar( "amx_con_tagprotection" , 	"1" );
	g_con_nbrLtrNick		= register_cvar( "amx_con_nbrltrnick" , 	"3" );
	
	register_cvar( "amx_con_tag" , "[TAG-TEAM]" );
	
	#if defined USING_SQL
	register_cvar("amx_sql_host", "127.0.0.1");
	register_cvar("amx_sql_user", "root");
	register_cvar("amx_sql_pass", "");
	register_cvar("amx_sql_db", "amx");
	register_cvar("amx_con_table", "dod_con_accept");
	register_cvar("amx_restrict_table", "dod_con_restrict");
	#endif
	
	init_rules();
	init_restrictnames();
	
	return PLUGIN_CONTINUE;
}

public plugin_precache( ) {
	new max_sons = sizeof( g_SonsList );
	new max_mod = sizeof( models );
	new CurSon[128];
	new CurMod[128];
	
	for( new i=0; i < max_sons; i++ ) {
		copy( CurSon , 127 , g_SonsList[sons:i] );
		format( CurSon , 127 , "sound/%s" , CurSon );
		if( file_exists( CurSon ) )
			precache_generic( CurSon );
	}
	
	if( get_cvar_num( "amx_adm_skin" ) == 1 && get_cvar_num( "mp_clan_match" ) != 1) {
		for( new x = 0; x < max_mod; x++ ) {
			copy( CurMod , 127 , models[x] );
			format( CurMod , 127 , "models/player/%s" , CurMod );
			if( file_exists( CurMod ) )
				precache_model( CurMod );
			else {
				set_cvar_num( "amx_adm_skin" , 0 );
				return PLUGIN_CONTINUE;
			}
		}
	}
	
	return PLUGIN_CONTINUE;
}

public client_connect( id ) {
	is_an_autorised[id] = false;
	if( get_pcvar_num( g_con_music ) > 0 ) {
		new son[128];
		new SonId;
		SonId = musique;
		copy( son , 127 , g_SonsList[sons:SonId] );
		playSound( id , son , 1 );
	}
	#if defined USING_SQL
	set_visits( id );
	#endif
	
	return PLUGIN_CONTINUE;
}

public client_putinserver( id ){
	if( !is_user_connected( id ) )
		return PLUGIN_CONTINUE;
	
	is_an_autorised[id] = false;
	client_cmd( id , "mp3 stop" );
	
	new param[3];
	param[0] = id;
	
	if( get_user_flags( id ) & LEVEL_ADMIN ) is_an_admin[id] = true;
	else is_an_admin[id] = false;
	if( get_user_flags( id ) & LEVEL_MEMBER ) is_a_member[id] = true;
	else is_a_member[id] = false;
	
	if( get_pcvar_num( g_con_tagprotection ) > 0 && !is_a_member[id] )
		verifTag( id );
	
	if( get_pcvar_num( g_con_restrictname ) > 0 ) 
		verifName( id );
	
	if( get_pcvar_num( g_con_stopsound ) > 0 )
		set_task( 0.2 , "autoStopSound" , id + 51654 , param , 5 );
	
	if( get_pcvar_num( g_con_mess ) > 0 )
		set_task( 0.5 , "playMessage" , id + 22135 , param , 5 );

	if( is_an_admin[id] || is_a_member[id] ){
		if( get_pcvar_num( g_con_log ) == 0 )
			is_an_autorised[id] = true;
		if( get_pcvar_num( g_adm_sound ) > 0 || get_pcvar_num( g_mbr_sound ) > 0 )
			admSound( id );
	}
	
	if( get_pcvar_num( g_con_log ) > 0 && !is_an_autorised[id] ) {
		new autorisation = 0
		autorisation = get_accept( id );
		if( autorisation == 1 ) {
			is_an_autorised[id] = true;
			#if defined USING_SQL
			set_task( 8.0 , "setNicks" , id + 231551 , param , 5 );
			#endif
			return PLUGIN_CONTINUE;
		}
	}
	
	set_task( 10.0, "affMenu", id + 25486, param, 5 );

	return PLUGIN_CONTINUE;
}

public dod_client_spawn( id ) {
	if( !is_user_connected( id ) || get_cvar_num( "mp_clan_match" ) != 0 )
		return PLUGIN_HANDLED;
	
	if( is_user_hltv( id ) || is_user_bot( id ) )
		return PLUGIN_HANDLED;

	if( get_pcvar_num( g_con_belmode ) > 0 )
		belMode( id );
	
	if( get_pcvar_num( g_con_tagprotection ) > 0 && !is_a_member[id] )
		verifTag( id );

	if( get_pcvar_num( g_con_restrictname ) > 0 ) 
		verifName( id );

	if( !is_an_admin[id] || get_pcvar_num( g_adm_skin ) == 0 )
		return PLUGIN_HANDLED;
	
	new userBody = random_num( 1 , 3 );
	dod_set_body_number( id , userBody );
	
	return PLUGIN_HANDLED;
}

public dod_client_changeteam( id , team , oldteam ) {
	if( !is_user_connected( id ) || get_cvar_num( "mp_clan_match" ) != 0 )
		return PLUGIN_HANDLED;
	
	if( is_user_hltv( id ) || is_user_bot( id ) )
		return PLUGIN_HANDLED;
	
	if( !is_an_admin[id] || get_pcvar_num( g_adm_skin ) == 0 )
		return PLUGIN_HANDLED;
	
	if( team == 3 )
		return PLUGIN_HANDLED;
	
	dod_set_model( id , models_type[team-1] );
	
	return PLUGIN_CONTINUE;
}

public client_disconnect( id ) {
	is_an_admin[id] = false;
	is_a_member[id] = false;
	is_an_autorised[id] = false;
	if( task_exists( 123214 + id ) )
		remove_task( 123214 + id );
	
	return PLUGIN_HANDLED;
}

public playMessage( param[] ) {
	new id = param[0];
	new son[128];
	new SonId = message;
	copy( son , 127 , g_SonsList[sons:SonId] );

	playSound( id , son , 0 );
}

public autoStopSound( param[] ){
	new id = param[0];
	client_cmd( id , "stopsound" );
}

public affMenu( param[] ){
	new id = param[0];
	show_menu( id , (1<<0) | (1<<1) , text );
	
	return PLUGIN_CONTINUE;
}

public affMenu2( id , level , cid ){
	if (!cmd_access( id , level , cid , 1)) {
		client_print( id , print_chat , "[DoD Connection] %L" , LANG_PLAYER , "NO_AFF_RULES" );
		return PLUGIN_HANDLED;
	}
	
	new target[128];
	read_argv( 1 , target , 127 );
	new player = cmd_target( id , target , 127 );
	
	if ( player ) {
		show_menu( player , (1<<0) | (1<<1) , text );
		return PLUGIN_HANDLED;
	}
	else if( target[0] == 0 ) {
		for( new i=0; id < get_maxplayers(); ++i ) {
			show_menu( i , (1<<0) | (1<<1) , text );
		}
		return PLUGIN_HANDLED;
	}
	else
		client_print( id , print_chat , "[DoD Connection] %L" , LANG_PLAYER , "NO_FIND_PLAYER" , target );
	
	return PLUGIN_HANDLED;
}

public action_con_menu( id , key ) {
	switch( key ) {
		case 0: {
			remove_task( 123214 + id );
			set_accept( id );
		}
		case 1: {
			remove_task( 123214 + id );
			client_cmd( id , "disconnect" );
		}
	}
	
	return PLUGIN_HANDLED;
}

public restrictNick( id , level , cid ) {
	if ( !cmd_access( id , level , cid , 1 ) )
		return PLUGIN_HANDLED;
	
	new target[128], addname[128];
	read_argv( 1 , target , 127 );
	
	new player = cmd_target( id , target , 127 );
	
	if ( player ) {
		get_user_name( player , addname , 127 );
		new kickReason[256];
		set_restrict( addname );
		format( kickReason , 255 , "%L" , LANG_PLAYER , "KICK_REASON" );
		server_cmd("kick ^"%s^" ^"%s^"" , addname , kickReason );
		log_amx( "[DoD Connection] %L" , LANG_SERVER , "ADD_RESTRICT_NAME" , addname );
		log_amx( "[DoD Connection] %L" , LANG_SERVER , "LOG_KICK" , addname );
	}
	else {
		read_argv( 1 , addname , 127 );
		set_restrict( addname );
		log_amx( "[DoD Connection] %L" , LANG_SERVER , "ADD_RESTRICT_NAME" , addname );
	}
	
	return PLUGIN_HANDLED;
}

public supLog( id , level , cid ) {
	if ( !cmd_access( id , level , cid , 0) ) {
		client_print( id , print_chat , "[DoD Connection] %L" , LANG_PLAYER , "NO_EREASE" );
		return PLUGIN_HANDLED;
	}
	#if defined USING_SQL
	if( !sql ) {
		if( !connect_db() )	return 0;
	}
	new table[32];
	get_cvar_string( "amx_con_table" , table , 31 );
	dbi_query( sql , "TRUNCATE TABLE `%s`" , table );
	client_print( id , print_chat , "[DoD Connection] %L" , LANG_PLAYER , "LOGS_EREASE" );
	#else
	if( !file_exists( regleslog ) )
		return PLUGIN_HANDLED;
	
	if( delete_file( regleslog ) )
		client_print( id , print_chat , "[DoD Connection] %L" , LANG_PLAYER , "LOGS_EREASE" );
	#endif
		
	return PLUGIN_HANDLED;
}

#if defined USING_SQL
public setNicks( param[] ) {
	new id = param[0];
	set_nicks( id );
}
#endif

verifTag( id ) {
	new playerName[32], tagprotection[32];
	get_user_info( id , "name" , playerName , 31 );
	get_cvar_string( "amx_con_tag" , tagprotection , 31 );
	
	if( !containi( playerName , tagprotection ) ) {
		new kickReason[256];
		format( kickReason , 255 , "%L" , LANG_PLAYER , "KICK_REASON" );
		server_cmd("kick ^"%s^" ^"%s^"" , playerName , kickReason );
		log_amx( "[DoD Connection] %L" , LANG_SERVER , "LOG_KICK" , playerName );
		client_print( 0 , print_chat , "[DoD Connection] %L" , LANG_PLAYER , "LOG_KICK" , playerName );
		
		return false;
	}
	
	return true;
}

verifName( id ) {
	new nameRestricted = false
	
	nameRestricted = getRestrictNames( id );
	
	if( nameRestricted ) {
		new kickReason[256],playerName[128];
		get_user_info( id , "name" , playerName , 31 );
		format( kickReason , 255 , "%L" , LANG_PLAYER , "KICK_REASON" );
		server_cmd("kick ^"%s^" ^"%s^"" , playerName , kickReason );
		client_print( 0 , print_chat , "[DoD Connection] %L" , LANG_PLAYER , "LOG_KICK" , playerName );
		
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

admSound( id ){
	new son[128];
	new SonId;
	if( get_pcvar_num( g_adm_sound ) > 0 && is_an_admin[id] )
		SonId = adm_connect;
	else if ( get_pcvar_num( g_mbr_sound ) > 0 && is_a_member[id] )
		SonId = mbr_connect;

	copy( son , 127 , g_SonsList[sons:SonId] );
	playSound( 0 , son , 0 );
}

belMode( id ) {
	new userTeam = get_user_team( id );
	if( userTeam == 1 )
		give_item( id , "weapon_handgrenade" );
	else
		give_item( id , "weapon_stickgrenade" );
}

playSound( id , son[] , boucle ) {
	if ( equali( son[strlen(son)-4] , ".mp3" ) ) {
		format( son , 127 , "sound/%s" , son );
		if( boucle == 1 )
			client_cmd( id , "mp3 loop %s" , son );
		else
			client_cmd( id , "mp3 play %s" , son );
	}
	else {
		client_cmd( id , "spk %s" , son );
	}
}

getRestrictNames( id ) {
	new nameRestricted = false;
	new playerName[32];
	get_user_info( id , "name" , playerName , 31 );
	new minLtrNick = get_pcvar_num( g_con_nbrLtrNick );
	
	for( new iv=1; iv!=MAX_RESTRICT_NAME; iv++ ) {
		if( !g_restrictname[iv][0] ) {
			break;
		}
		if( equali( g_restrictname[iv] , playerName ) ) {
			nameRestricted = true;
			break;
		}
	}
	
	if( strlen( playerName ) < minLtrNick ) nameRestricted = true;
	
	return nameRestricted;
}

stock init_rules() {
	if( get_pcvar_num( g_con_rules ) == 0 )
		return false;
	
	if( !file_exists( indexregles ) ) return 0;
	new len = format( text , 1023 , "\y%s %s: ^n^n\w" , PLUGIN_NAME , PLUGIN_VERSION );
	new rulesline[128], a, line = 0;
	while( read_file( indexregles , line++ , rulesline , 128 , a ) ) {
		if( rulesline[0] == ';' ) continue;
		len += format( text[len] , 1023-len , "%s^n" , rulesline );
	}
	len += format( text[len] , 1023-len , "^n\y1. \w%L ^n\r2. \w%L" , LANG_PLAYER , "ACCEPT" , LANG_PLAYER , "REFUSE" );

	return true;
}

stock init_restrictnames( ) {
	if( get_pcvar_num ( g_con_restrictname ) == 0 )
		return false;
	
	#if defined USING_SQL
	if( !sql ) {
		if( !connect_db() )	return 0;
	}
	
	new table[32], new_restrict_name[128];
	get_cvar_string( "amx_restrict_table" , table , 31 );
	new Result:res_restrict = dbi_query( sql , "SELECT nick FROM %s" , table );
	while( dbi_nextrow( res_restrict ) > 0 ) {
		g_nbrRestrictNames++;
		dbi_result( res_restrict , "nick" , new_restrict_name , 127 );
		format( g_restrictname[g_nbrRestrictNames] , 127 , "%s" , new_restrict_name );
	}
	#else
	if( file_exists( restrictnames ) ){
		new b, new_restrict_name[128];
		while( read_file( restrictnames , g_nbrRestrictNames++ , new_restrict_name , 127 , b ) )
			format( g_restrictname[g_nbrRestrictNames] , 127 , "%s" , new_restrict_name );
	}
	#endif

	log_amx( "%L" , LANG_SERVER , "RESTRICT_ONLINE" , g_nbrRestrictNames );

	return true;
}

stock get_accept( id ) {
	new authid[32], autorisation = 0;
	get_user_authid( id , authid , 31 );
	#if defined USING_SQL
	if( !sql ) {
		if( !connect_db() )	return 0;
	}
	
	new table[32], ResRow;
	get_cvar_string( "amx_con_table" , table , 31 );
	
	dbi_query2( sql , ResRow , "SELECT auth FROM %s WHERE auth='%s'", table, authid);
	
	
	if(ResRow > 0)
		autorisation = 1;
	
	#else
	if( file_exists( regleslog ) ){
		new rulesline[128], a, line = 0;
		while( read_file( regleslog , line++ , rulesline , 128 , a)){
			if( equal( authid , rulesline ) ) {
				autorisation = 1;
				break;
			}
		}
	}
	#endif

	return autorisation;
}

stock set_accept( id ) {
	new steamid[32], nick[128];
	get_user_authid( id , steamid , 31 );
	get_user_name( id , nick , 127 );
	
	#if defined USING_SQL
	if( !sql ) {
		if( !connect_db() )	return 0;
	}
	
	new table[32], dateins[15];
	get_cvar_string( "amx_con_table" , table , 31 );
	get_time( "%Y%m%d%H%M%S" , dateins , 14 );
	result = dbi_query( sql , "INSERT INTO %s value( '%s' , '%s' , '1' , '%s' )" , table , steamid , nick , dateins );

	if( result < RESULT_FAILED ) {
		new error[128];
		dbi_error( sql , error , 127 );
		log_amx( "[DoD Connection] %L" , LANG_SERVER , "PROB_ADD_ACCEPT" , steamid , error );
		
		return false;
	}
	if(result > RESULT_FAILED) {
		dbi_free_result( result );
		client_print( 0 , print_chat , "[DoD Connection] %L" , LANG_SERVER , "ADD_ACCEPT" , nick );
	}

	#else
	if( write_file( regleslog , steamid ) )
		client_print( 0 , print_chat , "[DoD Connection] %L" , LANG_SERVER , "ADD_ACCEPT" , nick );
	#endif

	return PLUGIN_HANDLED;
}

stock set_restrict( addname[] ) {
	#if defined USING_SQL
	if( !sql ) {
		if( !connect_db() )	return 0;
	}
	new id = get_user_index( addname );
	new nameRestricted = getRestrictNames( id );
	if( nameRestricted )
		return false;
	
	new table[32]
	get_cvar_string( "amx_restrict_table" , table , 31 );
	result = dbi_query( sql , "INSERT INTO %s value( '%s' )" , table , addname );

	if( result < RESULT_FAILED ) {
		new error[128];
		dbi_error( sql , error , 127 );
		log_amx( "[DoD Connection] %L" , LANG_SERVER , "PROB_ADD_RESTRICT_NAME" , addname , error );
		
		return false;
	}
	if( result > RESULT_FAILED ) {
		dbi_free_result( result );
		format( g_restrictname[g_nbrRestrictNames++] , 127 , "%s" , addname );
	}
	
	#else
	if( write_file( restrictnames , addname ) ) {
		format( g_restrictname[g_nbrRestrictNames++] , 127 , "%s" , addname );
		client_print( 0 , print_chat , "[DoD Connection] ^"%s^" %L" , addname , LANG_PLAYER , "ADD_RESTRICT_NAME" );
	}
	#endif
	
	return PLUGIN_HANDLED;
}

#if defined USING_SQL
stock set_visits( id ) {
	if( !sql ) {
		if( !connect_db() )	return 0;
	}
	
	new table[32], steamid[32];
	get_user_authid( id , steamid , 31 );
	get_cvar_string( "amx_con_table" , table , 31 );
	
	new Result:res = dbi_query( sql , "SELECT nbr FROM %s WHERE auth='%s' LIMIT 1", table, steamid);
	
	if( res < RESULT_FAILED ) {
		new error[128];
		dbi_error( sql , error , 127 );
		log_amx( "The server encountered an error while performing a query. Steam ID: '%s' Error: '%s'" , steamid , error );
		
		return false;
	}
	if( res <= RESULT_NONE )
		return false;

	dbi_nextrow( res );
	
	new nbrvis = dbi_result( res , "nbr" );
	new visites = nbrvis + 1;
	new dateins[15];
	get_time( "%Y%m%d%H%M%S" , dateins , 14 );
	result = dbi_query( sql , "UPDATE %s SET nbr='%d', date='%s' WHERE auth='%s' LIMIT 1" , table , visites , dateins , steamid );
	
	if( result > RESULT_FAILED )
		dbi_free_result(result);
	
	return true;
}

stock set_nicks( id ) {
	if( !sql ) {
		if( !connect_db() )	return 0;
	}
	
	new table[32], steamid[32];
	get_user_authid( id , steamid , 31 );
	get_cvar_string( "amx_con_table" , table , 31 );
	
	new Result:res = dbi_query( sql , "SELECT nick FROM %s WHERE auth='%s' LIMIT 1", table, steamid);
	
	if( res < RESULT_FAILED ) {
		new error[128];
		dbi_error( sql , error , 127 );
		log_amx( "The server encountered an error while performing a query. Steam ID: '%s' Error: '%s'" , steamid , error );
		
		return false;
	}
	
	if( res <= RESULT_NONE )
		return false;
	
	dbi_nextrow( res );
	
	new nicks[1024], nick[32];
	get_user_info( id , "name" , nick , 31 );
	dbi_result( res , "nick" , nicks , 1023 );
	
	if( !containi( nicks , nick ) )
		return false;
	
	format( nicks , 1023 , "%s, %s" , nick , nicks );
	result = dbi_query( sql , "UPDATE %s SET nick='%s' WHERE auth='%s' LIMIT 1" , table , nicks , steamid );
	
	if(result > RESULT_FAILED)
		dbi_free_result(result)
	
	return true;
}

public bool:connect_db() {
	new host[64], user[32], pass[32], db[128], table[32], rtable[32], error[128], dbType[7];
	dbi_type( dbType , 6 );
	get_cvar_string( "amx_sql_host" , host , 63 );
	get_cvar_string( "amx_sql_user" , user , 31 );
	get_cvar_string( "amx_sql_pass" , pass , 31 );
	get_cvar_string( "amx_sql_db" , db , 127 );
	get_cvar_string( "amx_con_table" , table , 31 );
	get_cvar_string( "amx_restrict_table" , rtable , 31 );

	sql = dbi_connect( host , user , pass , db , error , 127 );
	
	if( sql < SQL_OK ) {
		new error[128];
		dbi_error( sql , error , 127 );
		log_amx( "[DoD Connection] %L" , LANG_SERVER , "PROB_CONNECT_SQL" , error );
		
		return false;
	}
	
	if ( equali( dbType , "sqlite" ) ) {
		if ( !sqlite_table_exists( sql , table ) ) {
			result = dbi_query( sql , "CREATE TABLE %s ( auth TEXT NOT NULL DEFAULT '', nick TEXT NOT NULL DEFAULT '', nbr INT NOT NULL DEFAULT '1' , date INT NOT NULL DEFAULT '' )" , table );
		}
		if ( !sqlite_table_exists( sql , rtable ) ) {
			rresult = dbi_query( sql , "CREATE TABLE %s ( nick TEXT NOT NULL DEFAULT '' )" , rtable );
		}
	} 
	else {
		result = dbi_query( sql , "CREATE TABLE IF NOT EXISTS `%s` ( `auth` VARCHAR( 32 ) NOT NULL, `nick` TEXT NOT NULL, `nbr` INT( 11 ) NOT NULL DEFAULT '1', `date` VARCHAR( 11 ) NOT NULL ) COMMENT = 'DoD Connction'" , table );
		rresult = dbi_query( sql , "CREATE TABLE IF NOT EXISTS `%s` ( `nick` VARCHAR( 128 ) NOT NULL ) COMMENT = 'DoD Connction'" , rtable );
	}
	
	if( result < RESULT_FAILED || rresult < RESULT_FAILED ) {
		new error[128];
		dbi_error( sql , error , 127 );
		log_amx( "[DoD Connection] %L" , LANG_SERVER , "PROB_CONNECT_SQL" , error );
		
		return false;
	}
	
	dbi_free_result(result);
	dbi_free_result(rresult);
		
	return true;
}

public plugin_end() {
	if( sql > SQL_FAILED ) dbi_close( sql );
}
#endif