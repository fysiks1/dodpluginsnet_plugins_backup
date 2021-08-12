/* AMX Plugin
*
* (c) Copyright 2006, Orbit
* This file is provided as is (no warranties).
*
*/

#include <amxmodx>
#include <amxmisc>

public plugin_init()
{
        register_plugin("Shrikebot Admin", "0.9", "Orbit")
        register_concmd("amx_addbot", "Addbot", ADMIN_KICK, "<Team 1-2> <Class 1-8>")
        register_concmd("amx_botskill", "Botskill", ADMIN_KICK, "<1-6> Adjust the bots skill 1=best")
        register_concmd("amx_botbal", "Botbal", ADMIN_KICK, "<0/1> Turn on/off bot auto team balance")
        register_concmd("amx_botdontshoot", "Botdontshoot", ADMIN_KICK, "<0/1> Turn on/off bots ability to shoot")
        register_concmd("amx_botfunmode", "Botfunmode", ADMIN_KICK, "<0/1> Turn on/off bot funmode")
        register_concmd("amx_kickbots", "Kickbots", ADMIN_KICK, "<n> Number of humans before all bots kicked")
        register_concmd("amx_maxbots", "Maxbots", ADMIN_KICK, "<n> Set max number of bots, -1 to add bots manually")
        register_concmd("amx_botreaction", "Botreaction", ADMIN_KICK, "<0/1/2/3> Set the bot's reaction speed")
        register_concmd("amx_botviewskill", "Botviewskill", ADMIN_KICK, "<0/1> Turn on/off bots view skill")
        register_concmd("amx_botviewclan", "Botviewclan", ADMIN_KICK, "<0/1> Turn on/off bots view clan")
        register_concmd("amx_botslay", "Botslay", ADMIN_KICK, "Slay all bots")
}

public Addbot(id, level, cid)
{
        if (!cmd_access(id, level, cid, 2))
                return PLUGIN_HANDLED

        new arg1[2]
        new arg2[2]
        read_argv(1, arg1, 2)
        read_argv(2, arg2, 2)
	new team=str_to_num(arg1)
	new class=str_to_num(arg2)

	if ((team >= 1 && team <=2) && (class >=1 && class <= 8))
	{
		server_cmd("shr ^"addbot %d %d^"", team, class)
	}
	else
	{
		console_print(id, "[AMXX] Shrikebot Error <Team 1-2> <Class 1-8>")
	}
	
        return PLUGIN_HANDLED
}

public Botskill(id, level, cid)
{
        if (!cmd_access(id, level, cid, 2))
                return PLUGIN_HANDLED

        new arg1[3]
        read_argv(1, arg1, 2)
	new skill=str_to_num(arg1)

	if (skill >= 0 && skill <= 6)
	{
		server_cmd("shr ^"bot_skill %d^"", skill)
		console_print(id, "[AMXX] Shrikebot skill time adjusted to %d", skill)
	}
	else
	{
		console_print(id, "[AMXX] Shrikebot Error: <1-6> Adjust the bots skill 1=best")
	}

        return PLUGIN_HANDLED
}

public Botbal(id, level, cid)
{
        if (!cmd_access(id, level, cid, 2))
                return PLUGIN_HANDLED

	new onoff[5]
	read_argv(1, onoff, 4)

	if ( equal(onoff, "on") || equal(onoff, "1") )
	{
		server_cmd("shr ^"bot_team_balance on^"")
		console_print(id, "[AMXX] Shrikebot teambalance set to %s", onoff)
	}

	else if ( equal(onoff, "off") || equal(onoff, "0") )
	{
		server_cmd("shr ^"bot_team_balance off^"")
		console_print(id, "[AMXX] Shrikebot teambalance set to %s", onoff)
	}
	else
	{
		console_print(id, "[AMXX] Shrikebot Error <0/1> Turn on/off bot auto team balance")
	}

        return PLUGIN_HANDLED
}

public Botdontshoot(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED

	new onoff[5]
	read_argv(1, onoff, 4)

	if ( equal(onoff, "on") || equal(onoff, "1") )
	{
		server_cmd("shr ^"botdontshoot 1^"")
		console_print(id, "[AMXX] Shrikebot shootmode set to %s", onoff)
	}

	else if ( equal(onoff, "off") || equal(onoff, "0") )
	{
		server_cmd("shr ^"botdontshoot 0^"")
		console_print(id, "[AMXX] Shrikebot shootmode set to %s", onoff)
	}
	else
	{
		console_print(id, "[AMXX] Shrikebot Error <0/1> Turn on/off bots ability to shoot")
	}

	return PLUGIN_HANDLED
}

public Botfunmode(id, level, cid)
{
        if (!cmd_access(id, level, cid, 2))
                return PLUGIN_HANDLED

	new onoff[5]
	read_argv(1, onoff, 4)

	if ( equal(onoff, "on") || equal(onoff, "1") )
	{
		server_cmd("shr ^"funmode 1^"")
		console_print(id, "[AMXX] Shrikebot funmode set to %s", onoff)
	}

	else if ( equal(onoff, "off") || equal(onoff, "0") )
	{
		server_cmd("shr ^"funmode 0^"")
		console_print(id, "[AMXX] Shrikebot funmode set to %s", onoff)
	}
	else
	{
		console_print(id, "[AMXX] Shrikebot Error <0/1> Turn on/off bot funmode")
	}

        return PLUGIN_HANDLED
}

public Kickbots(id, level, cid)
{
        if (!cmd_access(id, level, cid, 2))
                return PLUGIN_HANDLED

        new arg1[3]
        read_argv(1, arg1, 2)
	new maxplayers = get_maxplayers()-1
	new kickbots=str_to_num(arg1)

	if (kickbots >= 0 && kickbots <= maxplayers)
	{
		server_cmd("shr ^"kick_all_bots %d^"", kickbots)
		console_print(id, "[AMXX] Shrikebot will kick all bots when %d humans are connected", kickbots)
	}
	else
	{
		console_print(id, "[AMXX] Shrikebot Error <n> Number of humans before all bots kicked")
	}

        return PLUGIN_HANDLED
}

public Maxbots(id, level, cid)
{
        if (!cmd_access(id, level, cid, 2))
                return PLUGIN_HANDLED

        new arg1[3]
        read_argv(1, arg1, 2)
	new maxplayers = get_maxplayers()-1
	new bots=str_to_num(arg1)

	if (bots > maxplayers){
		console_print(id, "[AMXX] That will make your server a bot server")
	}
	else 
	{
		server_cmd("shr ^"max_bots %d^"", bots)
		console_print(id, "[AMXX] Shrikebot limit adjusted to %d", bots)
	}

       	return PLUGIN_HANDLED

}

public Botreaction(id, level, cid)
{
        if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED

        new arg1[3]
        read_argv(1, arg1, 2)
	new reaction=str_to_num(arg1)

	if (reaction >= 0 && reaction <= 3)
	{
		server_cmd("shr ^"bot_reaction_time %d^"", reaction)
		console_print(id, "[AMXX] Shrikebot reaction time adjusted to %d", reaction)
	}
	else
	{
		console_print(id, "[AMXX] Shrikebot Error <0/1/2/3> Set the bot's reaction speed")
	}

	return PLUGIN_HANDLED
}

public Botslay(id, level, cid)
{
        if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED

	server_cmd("shr ^"kill_all ^"")
	console_print(id, "[AMXX] Shrikebot all bots have been slayed")

	return PLUGIN_HANDLED
}

public Botviewskill(id, level, cid)
{
        if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED

	new onoff[5]
	read_argv(1, onoff, 4)

	if ( equal(onoff, "on") || equal(onoff, "1") )
	{
		server_cmd("shr ^"view_skill on^"")
		console_print(id, "[AMXX] Shrikebot view skill set to %s", onoff)
	}

	else if ( equal(onoff, "off") || equal(onoff, "0") )
	{
		server_cmd("shr ^"view_skill off^"")
		console_print(id, "[AMXX] Shrikebot view skill set to %s", onoff)
	}
	else
	{
		console_print(id, "[AMXX] Shrikebot Error <0/1> Turn on/off bots view skill")
	}

	return PLUGIN_HANDLED
}

public Botviewclan(id, level, cid)
{
        if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED

	new onoff[5]
	read_argv(1, onoff, 4)

	if ( equal(onoff, "on") || equal(onoff, "1") )
	{
		server_cmd("shr ^"view_clan on^"")
		console_print(id, "[AMXX] Shrikebot view clan set to %s", onoff)
        }

	else if ( equal(onoff, "off") || equal(onoff, "0") )
	{
		server_cmd("shr ^"view_clan off^"")
		console_print(id, "[AMXX] Shrikebot view clan set to %s", onoff)
	}
	else
	{
		console_print(id, "[AMXX] Shrikebot Error <0/1> Turn on/off bots view clan")
	}

	return PLUGIN_HANDLED
}

