/////////////////////////////////////////////////////////////////////////////////////////////////
//*This plugin will play a small wav every time a player joins the server*///////////////////////
//*Things i wanna add a leave sound and also a cvar to be able to turn the plugin off at will*///
//*Add a part so that clan leader or admins have a differnt wav to public players*///////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>

#define	PLUGIN	"Player connect sound"
#define	VERSION	"1.0"
#define	AUTHOR	"Blobby"

new g_iMsgSayText, newplayer[] = "misc/newplayer.wav";

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
        register_cvar("player_connect_sound", "Version 1.0 By Blobby", FCVAR_SERVER|FCVAR_SPONLY);
	g_iMsgSayText = get_user_msgid("SayText");
}

public plugin_precache()
{
	precache_sound("misc/newplayer.wav");
}

public client_authorized(id)
{
	if(is_user_bot(id)) return PLUGIN_CONTINUE;

	new szUserName[33];
	get_user_name(id, szUserName, 32);

	new szAuthID[33];
	get_user_authid(id , szAuthID , 32);

	new iPlayers[32], iNum, i;
	get_players(iPlayers, iNum);

	for(i = 0; i <= iNum; i++)
	{
		new x = iPlayers[i];

		if(!is_user_connected(x) || is_user_bot(x)) continue;

		client_cmd(x, "spk %s", newplayer);

		new szMessage[164];
		format(szMessage, 163, "^x04%s (^x01%s^x04) connected", szUserName , szAuthID);

		message_begin( MSG_ONE, g_iMsgSayText, {0,0,0}, x );
		write_byte  ( x );
		write_string( szMessage );
		message_end ();
	}

	return PLUGIN_CONTINUE;
}
