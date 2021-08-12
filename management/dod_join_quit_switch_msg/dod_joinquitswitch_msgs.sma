//////////////////////////////////////////////////////////////////////////////////
//
//	DoD Join/Quit/Switch Messages +More
//		- Version 2.0
//		- 01.28.2009
//		- diamond-optic
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
// - Replaces join & quit messages, team switch msgs, and name change msgs
// - Can also hide bot & admin messages
// - Bots & admins can also have their own new messages instead
// - Set custom roundstart messages for each team
//
// - ** Requires AMXX 1.75 or higher **
//
//////////////////////////////////////////////////////
//
// CVARs:
//
//	dod_jqs_msgs "1"   	//"0" = use defualt messages
//			   	//"1" = use new messages
//			   	//"2" = hide messages
//
//	dod_jqs_bots "2"   	//"0" = no difference between bots & normal clients
//			  	//"1" = bots use their own new messages
//			   	//"2" = hide bot messages
//
//	dod_jqs_admins "2"	//"0" = no difference between admins & normal clients
//			   	//"1" = admins use their own new messages
//			   	//"2" = hide admin messages
//
//	dod_jqs_join "1"   	//"0" = defualt join message
//			   	//"1" = new join message
//			   	//"2" = hide join message
//
//	dod_jqs_join_geo "1"   	//"0" = no geoip country added to custom join msg
//			   	//"1" = add geoip country to custom join msg
//
//	dod_jqs_quit "1"  	//"0" = defualt quit message
//			   	//"1" = new quit message
//			   	//"2" = hide quit message
//
//	dod_jqs_teams "1"  	//"0" = defualt join team messages
//			   	//"1" = new join team messages
//			   	//"2" = hide join team messages
//
//	dod_jqs_spec "1"   	//"0" = defualt join spec message
//			   	//"1" = new join spec message
//			   	//"2" = hide join spec message
//
//	dod_jqs_name "1"   	//"0" = defualt name change message
//			   	//"1" = new name change message
//			   	//"2" = hide name change message
//
//	dod_jqs_start_allies "1"   	//"0" = defualt allies roundstart messages
//			   		//"1" = new allies roundstart messages
//			   		//"2" = hide allies roundstart messages
//
//	dod_jqs_start_brits "1"   	//"0" = defualt british roundstart messages
//			   		//"1" = new british roundstart messages
//			   		//"2" = hide british roundstart messages
//
//	dod_jqs_start_axis "1"   	//"0" = defualt axis roundstart messages
//			   		//"1" = new axis roundstart messages
//			   		//"2" = hide axis roundstart messages
//
//////////////////////////////////////////////////////
//
// Extra:
//
//	Change the "#define JQS_ADMIN_LEVEL ADMIN_LEVEL_H" line
//	to change the level used by dod_jqs_admins
//
//	Change the "#define JQS_COUNTRY_LEVEL ADMIN_BAN" line
//	to change the level used for admin custom countries
//
//      Place the 'dod_joinquitswitch_msgs.txt' file in your
//      amxmodx/data/lang/ directory. This is the file you
//      need to edit to use your own messages...   
//
//	To hide the team switch death messages use the DoD Team Manager
//	and enable the 'soft kill' feature
//
//	To use the custom country feature use the following method:
//		* setinfo custom_country "whatever you want here"
//
//////////////////////////////////////////////////////
//
// Change Log:
//
// - 05.13.2006 Version 1.0
//	Initial Release
//
// - 05.26.2006 Version 1.1
//	Fixed error where it was blocking all msgs
//      Renamed to DoD Join/Quit/Switch Messages
//      Added msgs for joining DoD Teams
//      Immunity to block joining spec msg for admins
//
// - 05.27.2006 Version 1.2
//	Added CVARs to set each new msg
//
// - 06.01.2006 Version 1.3
//	Added CVARs to turn on/off each new message
//
// - 06.05.2006 Version 1.4
//	Added seperate control over bots
//	Reworked the whole admin/immunity stuff
//      Condensed allies/axis/british cvars into one 'teams' cvar
//	Expanded the message control (defualt/new/hide)
//	Moved all new messages into a language file (byebye on the fly editing)
//	Removed <engine> (no idea why it was included lol..)
//
// - 06.11.2006 Version 1.4b
//	Fixed my stupidity of using amxx CVS includes...
//
// - 06.16.2006 Version 1.5
//	Added new msgs/hiding of name changes
//
// - 07.01.2006 Version 1.6
//	Fixed a few problems with msg blocks
//	Added msgs for roundstart text
//	Removed ENGINE module (requires amxx 1.75+)
//
// - 08.14.2006 Version 1.7
//	Fixed mistake in language file
//	Fixed problem with name changes not showing up
//	Changed some return values
//
// - 09.02.2006 Version 1.8
//	Changed LANG_SERVER to LANG_PLAYER
//
// - 01.28.2009 Version 2.0
//	Added option to have connect msg include players country
//	Fixed some mistakes here and there
//	Made some variables statics
//	Code Improvements
//	Added custom country ability for admins
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <amxmisc>
#include <dodx>
#include <geoip>


//////////////////////////////////////////////////////////////////////////////////
#define JQS_ADMIN_LEVEL ADMIN_LEVEL_H	//admin level used by dod_jqs_admins
#define JQS_COUNTRY_LEVEL ADMIN_KICK	//admin level used for custom country
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////


#define VERSION "2.0"
#define SVERSION "v2.0 - by diamond-optic (www.AvaMods.com)"

new p_dod_jqs_msgs, p_bots, p_admins, p_join, p_join_geo, p_quit, p_teams, p_spec, p_name, p_start_allies, p_start_axis, p_start_brits

public plugin_init()
{
	register_plugin("DoD Join/Quit/Switch Msgs +More",VERSION,"AMXX DoD Team")
	register_cvar("dod_joinquitswitch_msg",SVERSION,FCVAR_SERVER|FCVAR_SPONLY)
	
	register_dictionary("dod_joinquitswitch_msgs.txt")
	
	p_dod_jqs_msgs = register_cvar("dod_jqs_msgs", "1")
	
	p_bots = register_cvar("dod_jqs_bots", "2")
	p_admins = register_cvar("dod_jqs_admins", "2")
	
	p_join = register_cvar("dod_jqs_join", "1")
	p_join_geo = register_cvar("dod_jqs_join_geo", "1")
	p_quit = register_cvar("dod_jqs_quit", "1")
	
	p_teams = register_cvar("dod_jqs_teams", "1")
	p_spec = register_cvar("dod_jqs_spec", "1")
	
	p_name = register_cvar("dod_jqs_name", "1")
	
	p_start_allies = register_cvar("dod_jqs_start_allies", "1")
	p_start_brits = register_cvar("dod_jqs_start_brits", "1")
	p_start_axis = register_cvar("dod_jqs_start_axis", "1")
	
	register_message(get_user_msgid("TextMsg"), "block_message")

	register_event("TextMsg","join_axis","a","1=3","2=#game_joined_team","4=Axis")		//joined axis
	register_event("TextMsg","join_allies","a","1=3","2=#game_joined_team","4=Allies")	//joined allies
	register_event("TextMsg","join_spec","a","1=3","2=#game_joined_team","4=Spectators")	//joined spec
	register_event("TextMsg","change_name","a","1=3","2=#game_changed_name")		//changed name
	
	register_event("TextMsg","roundstart_allies1","bc","1=3","2=#game_roundstart_allie1")
	register_event("TextMsg","roundstart_allies2","bc","1=3","2=#game_roundstart_allie2")
	register_event("TextMsg","roundstart_brits1","bc","1=3","2=#game_roundstart_brit1")
	register_event("TextMsg","roundstart_brits2","bc","1=3","2=#game_roundstart_brit2")
	register_event("TextMsg","roundstart_axis1","bc","1=3","2=#game_roundstart_axis1")
	register_event("TextMsg","roundstart_axis2","bc","1=3","2=#game_roundstart_axis2")
}

public block_message()
{
	if(!get_pcvar_num(p_dod_jqs_msgs) || get_pcvar_num(p_dod_jqs_msgs) > 2)
		return PLUGIN_CONTINUE
	
	if(get_msg_argtype(2) == ARG_STRING)
		{
		static value[64]
		get_msg_arg_string(2,value,63)
		
		static name[32]
		read_data(3,name,31)
		new id = get_user_index(name)
		
		if(get_pcvar_num(p_dod_jqs_msgs) == 2)
			{
			if(equali(value,"#game_joined_game")
			|| equali(value,"#game_disconnected")
			|| equali(value,"#game_joined_team")
			|| equali(value,"#game_changed_name")
			|| equali(value,"#game_roundstart_allie1")
			|| equali(value,"#game_roundstart_allie2")
			|| equali(value,"#game_roundstart_brits1")
			|| equali(value,"#game_roundstart_brits2")
			|| equali(value,"#game_roundstart_axis1")
			|| equali(value,"#game_roundstart_axis2"))
				return PLUGIN_HANDLED
			}
		else if(is_user_bot(id) && get_pcvar_num(p_bots))
			{
			if(equali(value,"#game_joined_game")
			|| equali(value,"#game_disconnected")
			|| equali(value,"#game_joined_team")
			|| equali(value,"#game_changed_name"))
				return PLUGIN_HANDLED
			}
		else if(access(id,JQS_ADMIN_LEVEL) && get_pcvar_num(p_admins))
			{
			if(equali(value,"#game_joined_game")
			|| equali(value,"#game_disconnected")
			|| equali(value,"#game_joined_team")
			|| equali(value,"#game_changed_name"))
				return PLUGIN_HANDLED
			}
		else if(equali(value,"#game_joined_game") && get_pcvar_num(p_join))
			return PLUGIN_HANDLED
			
		else if(equali(value,"#game_disconnected") && get_pcvar_num(p_quit)) 
			return PLUGIN_HANDLED
			
		else if(equali(value,"#game_joined_team"))
			{
			static team[16]
			get_msg_arg_string(4,team,15)
			
			if(get_pcvar_num(p_teams) && (equali(team,"Axis") || equali(team,"Allies")))
				return PLUGIN_HANDLED
				
			else if(get_pcvar_num(p_spec) && equali(team,"Spectators"))
				return PLUGIN_HANDLED
			}
		else if(equali(value,"#game_changed_name") && get_pcvar_num(p_name)) 
			return PLUGIN_HANDLED

		else if(equali(value,"#game_roundstart_allie1") || equali(value,"#game_roundstart_allie2") && get_pcvar_num(p_start_allies)) 
			return PLUGIN_HANDLED

		else if(equali(value,"#game_roundstart_brit1") || equali(value,"#game_roundstart_brit2") && get_pcvar_num(p_start_brits)) 
			return PLUGIN_HANDLED

		else if(equali(value, "#game_roundstart_axis1") || equali(value, "#game_roundstart_axis2") && (get_pcvar_num(p_start_axis) == 1 || get_pcvar_num(p_start_axis) == 2)) 
			return PLUGIN_HANDLED
		}
		
	return PLUGIN_CONTINUE
}  

public client_putinserver(id)
{  
	if((get_pcvar_num(p_dod_jqs_msgs) != 1) || (is_user_bot(id) && get_pcvar_num(p_bots) == 2))
		return PLUGIN_HANDLED
		
	static putin_name[32]
	get_user_name(id,putin_name,32)
		
	if(access(id,JQS_ADMIN_LEVEL) && get_pcvar_num(p_admins) == 2)
		{
		if(get_pcvar_num(p_join_geo))
			{
			static country[128]
			static infoField[128]
			
			get_user_info(id,"custom_country",infoField,127)
				
			if(strlen(infoField) > 0 && access(id,JQS_COUNTRY_LEVEL))
				{
				formatex(country,127,"%s",infoField)
				
				client_print(0,print_chat,"%L",LANG_PLAYER,"JOIN_MSG_GEO",putin_name,country)
				}
			else
				return PLUGIN_HANDLED
			}
		else
			return PLUGIN_HANDLED
		}
				
	if(is_user_bot(id) && get_pcvar_num(p_bots) == 1)
		client_print(0,print_chat,"%L",LANG_PLAYER,"BOT_JOIN",putin_name)
		
	else if(access(id,JQS_ADMIN_LEVEL) && get_pcvar_num(p_admins) == 1)
		client_print(0,print_chat,"%L",LANG_PLAYER,"ADMIN_JOIN",putin_name)
		
	else if(get_pcvar_num(p_join) == 1)
		{
		if(get_pcvar_num(p_join_geo) && !is_user_bot(id))
			{
			static country[128]
			static infoField[128]
			
			get_user_info(id,"custom_country",infoField,127)
				
			if(strlen(infoField) > 0 && access(id,JQS_COUNTRY_LEVEL))
				formatex(country,127,"%s",infoField)
			else
				{
				//lookup country
				static ip[17]
				get_user_ip(id,ip,16,1)
				geoip_country(ip,country,128)
				
				if(equali(country,"error"))
					formatex(country,127,"Somewhere")
				}
				
			client_print(0,print_chat,"%L",LANG_PLAYER,"JOIN_MSG_GEO",putin_name,country)
			
			}
		else		
			client_print(0,print_chat,"%L",LANG_PLAYER,"JOIN_MSG",putin_name)
		}
	else
		{
		if(get_pcvar_num(p_join_geo))
			{
			static infoField[128]
			get_user_info(id,"custom_country",infoField,127)
			
			if(strlen(infoField) > 0 && access(id,JQS_COUNTRY_LEVEL))
				{
				static country[128]
				formatex(country,127,"%s",infoField)
					
				client_print(0,print_chat,"%L",LANG_PLAYER,"JOIN_MSG_GEO",putin_name,country)
				}
			}
		}
		
	return PLUGIN_CONTINUE
}

public client_disconnect(id)
{
	if((get_pcvar_num(p_dod_jqs_msgs) != 1) || (access(id,JQS_ADMIN_LEVEL) && get_pcvar_num(p_admins) == 2) || (is_user_bot(id) && get_pcvar_num(p_bots) == 2))
		return PLUGIN_HANDLED
		
	static leave_name[32]
	get_user_name(id,leave_name,32)
	
	if(is_user_bot(id) && get_pcvar_num(p_bots) == 1)
		client_print(0,print_chat,"%L",LANG_PLAYER,"BOT_QUIT",leave_name)

	else if(access(id,JQS_ADMIN_LEVEL) && get_pcvar_num(p_admins) == 1)
		client_print(0,print_chat,"%L",LANG_PLAYER,"ADMIN_QUIT",leave_name)

	else if(get_pcvar_num(p_quit) == 1)
		client_print(0,print_chat,"%L",LANG_PLAYER,"QUIT_MSG",leave_name)

	return PLUGIN_CONTINUE
}

public join_axis()
{
	if(get_pcvar_num(p_dod_jqs_msgs) != 1)
		return PLUGIN_HANDLED
		
	static axis_name[32]
	read_data(3,axis_name,31)
	new id = get_user_index(axis_name)
	
	if((is_user_bot(id) && get_pcvar_num(p_bots) == 2) || (access(id,JQS_ADMIN_LEVEL) && get_pcvar_num(p_admins) == 2))
		return PLUGIN_HANDLED

	else if(is_user_bot(id) && get_pcvar_num(p_bots) == 1)
		client_print(0,print_chat,"%L",LANG_PLAYER,"BOT_AXIS",axis_name)

	else if(access(id, JQS_ADMIN_LEVEL) && get_pcvar_num(p_admins) == 1)
		client_print(0,print_chat,"%L",LANG_PLAYER,"ADMIN_AXIS",axis_name)

	else if(get_pcvar_num(p_teams) == 1)	
		client_print(0,print_chat,"%L",LANG_PLAYER,"AXIS_MSG",axis_name)

	return PLUGIN_CONTINUE
}

public join_allies()
{
	if(get_pcvar_num(p_dod_jqs_msgs) != 1)
		return PLUGIN_HANDLED
		
	static allies_name[32]
	read_data(3,allies_name,31)
	new id = get_user_index(allies_name)
	
	if((is_user_bot(id) && get_pcvar_num(p_bots) == 2) || (access(id,JQS_ADMIN_LEVEL) && get_pcvar_num(p_admins) == 2))
		return PLUGIN_HANDLED

	else if(dod_get_map_info(MI_ALLIES_TEAM) == 1)
		{
		if(is_user_bot(id) && get_pcvar_num(p_bots) == 1)
			client_print(0,print_chat,"%L",LANG_PLAYER,"BOT_BRITISH",allies_name)

		else if(access(id,JQS_ADMIN_LEVEL) && get_pcvar_num(p_admins) == 1)
			client_print(0,print_chat,"%L",LANG_PLAYER,"ADMIN_BRITISH",allies_name)

		else if(get_pcvar_num(p_teams) == 1)
			client_print(0,print_chat,"%L",LANG_PLAYER,"BRITISH_MSG",allies_name)

		}
	else if(dod_get_map_info(MI_ALLIES_TEAM) == 0)
		{
		if(is_user_bot(id) && get_pcvar_num(p_bots) == 1)
			client_print(0,print_chat,"%L",LANG_PLAYER,"BOT_ALLIES",allies_name)

		else if(access(id,JQS_ADMIN_LEVEL) && get_pcvar_num(p_admins) == 1)
			client_print(0, print_chat,"%L",LANG_PLAYER,"ADMIN_ALLIES",allies_name)

		else if(get_pcvar_num(p_teams) == 1)		
			client_print(0,print_chat,"%L",LANG_PLAYER,"ALLIES_MSG",allies_name)
		}
		
	return PLUGIN_CONTINUE
}

public join_spec()
{
	if(get_pcvar_num(p_dod_jqs_msgs) != 1)
		return PLUGIN_HANDLED
		
	static spec_name[32]
	read_data(3,spec_name,31)
	new id = get_user_index(spec_name)
	
	if(access(id,JQS_ADMIN_LEVEL) && get_pcvar_num(p_admins) == 2)
		return PLUGIN_HANDLED

	else if(access(id,JQS_ADMIN_LEVEL) && get_pcvar_num(p_admins) == 1)
		client_print(0,print_chat,"%L",LANG_PLAYER,"ADMIN_SPEC",spec_name)

	else if(get_pcvar_num(p_spec) == 1)
		client_print(0,print_chat,"%L",LANG_PLAYER,"SPEC_MSG",spec_name)

	return PLUGIN_CONTINUE
}

public change_name()
{
	if(get_pcvar_num(p_dod_jqs_msgs) != 1 || get_pcvar_num(p_name) != 1)
		return PLUGIN_HANDLED

	static old_name[32],new_name[32]
	read_data(3,old_name,31)
	read_data(4,new_name,31)
	new userID = get_user_index(old_name)

	if(access(userID,JQS_ADMIN_LEVEL) && get_pcvar_num(p_admins) == 2)
		return PLUGIN_HANDLED

	else if(access(userID,JQS_ADMIN_LEVEL) && get_pcvar_num(p_admins) == 1)
		client_print(0,print_chat,"%L",LANG_PLAYER,"ADMIN_NAME",old_name,new_name)

	else if(get_pcvar_num(p_name) == 1)
		client_print(0,print_chat,"%L",LANG_PLAYER,"NAME_MSG",old_name,new_name)

	return PLUGIN_CONTINUE
}

public roundstart_allies1(entity)
{
	if(get_pcvar_num(p_dod_jqs_msgs) != 1 || get_pcvar_num(p_start_allies) != 1 || !is_user_connected(entity) || is_user_bot(entity))
		return PLUGIN_HANDLED

	client_print(entity,print_chat,"%L",LANG_PLAYER,"START_ALLIES1_MSG")

	return PLUGIN_CONTINUE
}

public roundstart_allies2(entity)
{
	if(get_pcvar_num(p_dod_jqs_msgs) != 1 || get_pcvar_num(p_start_allies) != 1 || !is_user_connected(entity) || is_user_bot(entity))
		return PLUGIN_HANDLED
	
	client_print(entity,print_chat,"%L",LANG_PLAYER,"START_ALLIES2_MSG")
	
	return PLUGIN_CONTINUE
}

public roundstart_brits1(entity)
{
	if(get_pcvar_num(p_dod_jqs_msgs) != 1 || get_pcvar_num(p_start_brits) != 1 || !is_user_connected(entity) || is_user_bot(entity))
		return PLUGIN_HANDLED
	
	client_print(entity,print_chat,"%L",LANG_PLAYER,"START_BRITS1_MSG")

	return PLUGIN_CONTINUE
}

public roundstart_brits2(entity)
{
	if(get_pcvar_num(p_dod_jqs_msgs) != 1 || get_pcvar_num(p_start_brits) != 1 || !is_user_connected(entity) || is_user_bot(entity))
		return PLUGIN_HANDLED
	
	client_print(entity,print_chat,"%L",LANG_PLAYER,"START_BRITS2_MSG")
	
	return PLUGIN_CONTINUE
}

public roundstart_axis1(entity)
{
	if(get_pcvar_num(p_dod_jqs_msgs) != 1 || get_pcvar_num(p_start_axis) != 1 || !is_user_connected(entity) || is_user_bot(entity))
		return PLUGIN_HANDLED
	
	client_print(entity,print_chat,"%L",LANG_PLAYER,"START_AXIS1_MSG")

	return PLUGIN_CONTINUE
}

public roundstart_axis2(entity)
{
	if(get_pcvar_num(p_dod_jqs_msgs) != 1 || get_pcvar_num(p_start_axis) != 1 || !is_user_connected(entity) || is_user_bot(entity))
		return PLUGIN_HANDLED
	
	client_print(entity,print_chat,"%L",LANG_PLAYER,"START_AXIS2_MSG")
	
	return PLUGIN_CONTINUE
}
