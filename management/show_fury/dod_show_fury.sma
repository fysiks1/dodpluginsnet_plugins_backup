/*
Show Fury
Plugin originally designed to answer a request on the dodplugins.net forum. http://www.dodplugins.net/forums/showthread.php?t=462
QUOTE (Box Cutter)
"I'd appreciate it if a developer wouldnt mind whipping up a plugin that an admin could use to get everyones attention in the server like when they are being 
disruptive to give them a sign that the admin is pissed and they need to behave. I would like it if the plugin would play a sound like a thunder clash, make 
everyones screen flicker or quickly fade in and out and also shake. TIA to anyone who can help."

This is my response... but with a personal touch, lightning bolt strikes !! That will open some eyes....

Found out I love this plugin and have big plans for it.
It will find its way into a number of plugins I have on hand and some future ones...


It is highly customizable (as i like my plugins) and care should be taken when editing the source code
use the amxx.cfg file to make any changes but you should leave the defaults listed here alone...

AMXX.CFG CVARS:
warn_lights_pattern "aaaabcdefgfedccbbcccddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefffffffffffffffffggggggggggggggghhhhhhhhhhhiiiiiiiiiijjjjjjjjjjjj")//sets the pattern of lights (a = darkest z = brightest m ~ normal)
warn_length "15" //amount of time before server lighting is forced back to normal
warn_maxstrikes "5" //amount of lightning strikes randomly generated
warn_random_delay "5.0" //amount of random possible delay before lightning strikes
warn_msg "0" //enable/disable display of message during strike (0 = off 1 =on)
warn_message "I have become angry!! Cease your unruly behavior or suffer my WRATH" //message to be displayed to all players

VERSION INFO:
76.0 11/23/2006
initial code
76.1 11/24/2006
public code

NOTES:
Tested on Linux/Windows AMXX 1.76b
AUTHOR INFO:
Joseph Meyers AKA =|[76AD]|= TatsuSaisei - 76th Airborne Division RANK: General of the Army
http://76AD.com
http://TatsuSaisei.com
http://JosephMeyers.com

*/
#include <amxmodx>
#include <amxmisc>
#include <engine>

#define PLUGIN "Show Fury (Thunder & Lightning)"
#define VERSION "76.1"
#define AUTHOR "TatsuSaisei"

new light
new origin_bolt[3]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar("warn_lights_pattern", "aaaabcdefgfedccbbcccddddeeeeeeeeeeeeeeeeeeeeeeefffffffffggggggggghhhhhhhiiiiiiijjjjjjjkkkkkk")//sets the pattern of lights (a = darkest z = brightest m ~ normal)
	register_cvar("warn_length", "15")//amount of time before server lighting is forced back to normal
	register_cvar("warn_maxstrikes", "5")//amount of lightning strikes randomly generated
	register_cvar("warn_random_delay", "3.0")//amount of random possible delay before lightning strikes
	register_cvar("warn_msg", "0")//enable/disable display of message during strike (0 = off 1 =on)
	register_cvar("warn_message", "I have become angry!! Cease your unruly behavior or suffer my WRATH")//message to be displayed to all players
	register_concmd("warn_off", "no_lightning", ADMIN_RCON, "Fix Lights - Prematurely put server lighting back to normal")//command to force servfer lighting back to normal should you set length too high
	register_clcmd("show_fury", "show_fury", ADMIN_CHAT, "Display thunder and lightning to all players in the server" ) //command to produce strike(s) can be used multiple times for increased effect
}

public plugin_precache() { 
	precache_sound("ambience/thunder.wav") 
	light = precache_model("sprites/laserbeam.spr")
	return PLUGIN_CONTINUE 
} 

public show_fury(id,level,cid)
{
	new pattern[64]
	get_cvar_string("warn_lights_pattern", pattern, 64)
	if (!cmd_access(id,level,cid,1)){
		console_print(id,"Nice try sucka!! You can't handle this command!!")
		return PLUGIN_HANDLED
	}
	set_task ( random_float(0.0,get_cvar_float("warn_random_delay"))+0.1, "lightning", 420420 + id, pattern, 64, "a", random_num(0,get_cvar_num("warn_strikes")) +1)
	set_task ( get_cvar_float("warn_length")+get_cvar_float("warn_random_delay"), "no_lightning", 420420 + id, pattern, 64) 
	return PLUGIN_CONTINUE
}

public lightning(pattern[])
{
	if(get_cvar_num("warn_msg") == 1)
	{
		set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 6.0, 12.0)
		new message[128]
		get_cvar_string("warn_message", message, 128)
		show_hudmessage(0, message)
	}
	set_lights(pattern)
	client_cmd(0,"spk ambience/thunder.wav")
	
	new i
	for (i=0;i<get_maxplayers();i++)
	{
		if(is_user_alive(i))
		{
			get_user_origin(i,origin_bolt)
			message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
			write_byte( 0 )
			write_coord(origin_bolt[0] + random_num(-300,300))
			write_coord(origin_bolt[1] + random_num(-300,300))
			write_coord(origin_bolt[2] + random_num(400,500))
			write_coord(origin_bolt[0] + random_num(-300,300))
			write_coord(origin_bolt[1] + random_num(-300,300))
			write_coord((origin_bolt[2] - 100) + random_num(0,100))
			write_short( light )
			write_byte(0)	//start frame
			write_byte(7)	//framerate
			write_byte(8)	//life
			write_byte(7) 	//width
			write_byte(100)	//noise
			write_byte(200)	//red
			write_byte(200)	//green
			write_byte(255)	//blue
			write_byte(255)	//brightness
			write_byte(16)	//scroll speed
			message_end()
		}
	}
	
	
	return PLUGIN_CONTINUE
}

public no_lightning(stop[])
{
	set_lights("#OFF")
	return PLUGIN_CONTINUE
}
