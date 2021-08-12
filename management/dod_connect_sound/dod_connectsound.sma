///////////////////////////////////////////////
//                                           //
//  Developed by: The Amxmodx DoD Community  //
//  http://www.dodplugins.net                //	
//  Author: dimon1052                        //
//  Version: 1.0                             //
//                                           //
///////////////////////////////////////////////
#include <amxmodx>

#define Maxsounds 1

new soundlist[Maxsounds][] = {"misc/welcome"}

new plugin_author[] = "dimon1052"
new plugin_version[] = "1.0"

public plugin_init( )
{
	register_plugin("DoD Connect Sound", plugin_version, plugin_author)
	register_cvar("connectsound_version", plugin_version, FCVAR_SERVER)
}

public plugin_precache( )
{
	new temp[128], soundfile[128]
	for ( new a = 0; a < Maxsounds; a++ )
	{
		format(temp, 127, "sound/%s.wav", soundlist[a])
		if ( file_exists(temp) )
		{
			format(soundfile, 127, "%s.wav", soundlist[a])
			precache_sound(soundfile)
		}
	}
}

public client_putinserver( id )
{
	set_task(1.0, "consound", 100 + id)
}

public consound( timerid_id )
{
	new id = timerid_id - 100
	new Usertime
	Usertime = get_user_time(id, 0)
	if ( Usertime <= 0 )
	{
		set_task(1.0, "consound", timerid_id)
	}else
	{
		new i = random(Maxsounds)
		client_cmd(id, "spk ^"%s^"", soundlist[i])
	}
	
	return PLUGIN_CONTINUE
}