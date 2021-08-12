//////////////////////////////////////////////////////////////////////////////////
//
//	DoD BotJoinScore
//		- Version 1.4
//		- 04.06.2008
//		- diamond-optic
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
//	Sets bots to have 0 kills/deaths/flags when they join.
//
//	..I noticed that bots would have kills, leave
//        the server, and later a bot would join and
//        still have the previous bot's kills but 0 deaths
//        so this just makes them start at 0:0:0
//
//////////////////////////////////////////////////////////////////////////////////
//
// Changelog:
//
// - 05.03.2006 Version 1.0
//	Initial Release
//
// - 05.05.2006 Version 1.1
//	Added Flags & Deaths just incase
//      Renamed to DoD BotJoinScore
//
// - 05.08.2006 Version 1.2
//	Fixed Invalid Player Runtime Error
//
// - 05.27.2006 Version 1.3
//	Fixed another Runtime Error
//
// - 04.06.2008 Version 1.4
//	Fixed some if statement stuff
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <dodfun>

#define VERSION "1.4"
#define SVERSION "v1.4 - by diamond-optic (www.AvaMods.com)"

public plugin_init()
{
	register_plugin("DoD BotJoinScore",VERSION,"AMXX DoD Team")
	register_cvar("dod_botjoinscore_stats",SVERSION,FCVAR_SERVER|FCVAR_SPONLY)
}

public client_putinserver(id)
	if(is_user_bot(id))
		set_task(1.0,"bot_score",id)

public bot_score(id)
{
	if(is_user_connected(id) && is_user_bot(id))
		{
		dod_set_user_kills(id,0,1)
		dod_set_user_score(id,0,1)
		dod_set_pl_deaths(id,0,1)
		}
}