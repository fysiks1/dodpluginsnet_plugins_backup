/*
	Bot Apology for TK by Fysiks
	
	Description:
		This plugin will make a bot apologize, in chat, for it's team kills.
		
	Cvars:
		amx_bot_apology <1|0>			-	On or Off.
		amx_bot_apology_prob <0-100>	-	The probability that the bot will apologize for a TK.
		amx_bot_apology_method <0-100>	-	The probability that team chat will be used. (0 -> public, 100 -> team)
		amx_bot_apology_delay <#>		-	The time between the TK and the apology (from last TK
											if there was another within the delay time of the
											previous TK).
	
	Thanks for feedback and suggestions:
		Vet
		Arkshine
		Exolent
		
*/

#include <amxmodx>
#include <amxmisc>

#define chance(%1) ( %1 > random_num(0,99) ) // %1 = probability

new g_szPhrases[10][65]
new g_iCount

new g_pCvarProbability
new g_pCvarDelay
new g_pCvarEnabled
new g_pCvarMethod
new is_bot[33]

public plugin_init()
{
	register_plugin("Bot Apology for TK", "3.0", "Fysiks")
	register_cvar("Bot Apology", "v3.0 by Fysiks", FCVAR_SERVER|FCVAR_SPONLY)
	g_pCvarEnabled = register_cvar("amx_bot_apology", "1")
	g_pCvarProbability = register_cvar("amx_bot_apology_prob","100")
	g_pCvarDelay = register_cvar("amx_bot_apology_delay","3.0")
	g_pCvarMethod = register_cvar("amx_bot_apology_method","10")
	register_event("DeathMsg", "player_death", "a","1>0")

	// Retrieve Sorry phrases from bot_apology.ini
	new szFilepath[64]
	get_configsdir(szFilepath, charsmax(szFilepath))
	add(szFilepath, charsmax(szFilepath), "/bot_apology.ini")
	
	if( !file_exists(szFilepath) )
	{
		copy(g_szPhrases[0], charsmax(g_szPhrases[]), "sorry")
		g_iCount = 1
		return
	}
	
	new f = fopen(szFilepath, "rt")
	
	new szData[sizeof(g_szPhrases[])]
	g_iCount = 0

	while( !feof(f) && g_iCount < sizeof(g_szPhrases)) 
	{ 
		fgets(f, szData, charsmax(szData))
		 
		trim(szData)
		if( !szData[0] || szData[0] == ';'
		    || szData[0] == '/' && szData[1] == '/' ) continue;
		copy(g_szPhrases[g_iCount], charsmax(g_szPhrases[]), szData)
		g_iCount++
	}
	
	fclose(f)
}

public client_putinserver(id)
{
	is_bot[id] = is_user_bot(id)
}

public player_death()
{
	if(get_pcvar_num(g_pCvarEnabled))
	{
		new iKillerID = read_data(1)
		new iVictimID = read_data(2)
		//		Is bot?			Didn't Kill Self?						Is Team Kill?
		if(is_bot[iKillerID] && iVictimID != iKillerID && get_user_team(iKillerID) == get_user_team(iVictimID))
		{
			remove_task(iKillerID) // Prevent kill,sorry,kill,sorry to get kill,kill,sorry
			set_task(get_pcvar_float(g_pCvarDelay),"say_sorry",iKillerID) // Prepare to say "sorry"
		}
	}
}

public say_sorry(id)
{
	// Does the bot happen to say sorry?
	if( chance(get_pcvar_num(g_pCvarProbability)) )
	{
		new szChatMethod[9]

		if(chance(get_pcvar_num(g_pCvarMethod))) // Is it said in public or team chat?
		{
			copy(szChatMethod, 8, "say_team");
		}
		else
		{
			copy(szChatMethod, 8, "say");
		}
		
		engclient_cmd(id,szChatMethod,g_szPhrases[random(g_iCount)]) // Saying "sorry"
	}
}

public client_disconnect(id)
{
	remove_task(id) // If bot leaves, don't say "sorry"
}
