////////////////////////////////////////////
//            Author: dimon1052           //
//            Version 1.0                 //
////////////////////////////////////////////

#include <amxmodx>

#if AMXX_VERSION_NUM < 180
	#define charsmax(%1)	(sizeof(%1)-1)
#endif

new const PLUGIN[] = "DoD Killa HP"
new const VERSION[] = "1.0"
new const AUTHOR[] = "dimon1052"

new const g_msgTemplate[] = "^x03%s^x01[%d^x01HP]"
new const g_msgTemplateConsole[] = "%s [%d HP]"

new g_msgSayText

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("DeathMsg", "eventDeath", "a", "1>0")
	g_msgSayText = get_user_msgid("SayText")
}

public eventDeath()
{
	static aID, vID
	static aName[32], msgText[255]
	static aHealth, aArmor, aFrags, aDeaths
		
	aID = read_data(1)
	vID = read_data(2)
	
	// OPTIMIZED [by VEN] ->
	if(vID == aID)
	{
		return
	}
	// <- OPTIMIZED [by VEN]
	
	get_user_name(aID, aName, charsmax(aName))
	aHealth = get_user_health(aID)
	aArmor = get_user_armor(aID)
	
	aFrags = get_user_frags(aID)
	aDeaths = get_user_deaths(aID)
	
	formatex(msgText, charsmax(msgText), g_msgTemplate, aName, aHealth, aArmor, aFrags, aDeaths)
	msgText[192] = '^0'
	msgSayText(vID, msgText)

	formatex(msgText, charsmax(msgText), g_msgTemplateConsole, aName, aHealth, aArmor, aFrags, aDeaths)
	client_print(vID, print_console, msgText)
}

msgSayText(id, message[])
{
	message_begin(MSG_ONE, g_msgSayText, _, id)
	write_byte(id)		
	write_string(message)
	message_end()
}