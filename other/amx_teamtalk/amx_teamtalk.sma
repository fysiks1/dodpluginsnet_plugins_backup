#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#define PLUGIN	"Team Talk"
#define AUTHOR	"Captain Wilson"
#define VERSION	"1.0"

new teamtalking[33];
new p_enabled, p_voiceprox;

public plugin_init()
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	register_clcmd( "+teamtalk", "clcmd_teamtalk" );
	register_clcmd( "-teamtalk", "clcmd_teamtalk" );
	register_forward( FM_Voice_SetClientListening, "fwd_SetClientListening" );
	
	p_enabled = register_cvar( "amx_teamtalk", "1" );
	p_voiceprox = get_cvar_pointer( "amx_voiceprox" );
}

public clcmd_teamtalk( id ) {
	if( plugin_enabled() )
	{
		new cmd[16];
		read_argv( 0, cmd, 15 );
		
		if( equal(cmd, "+", 1) )
		{
			teamtalking[id] = true;
			client_cmd( id, "+voicerecord" );
		}
		else
		{
			teamtalking[id] = false;
			client_cmd( id, "-voicerecord" );
		}
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public fwd_SetClientListening( receiver, sender, listen ) {
	if( plugin_enabled() )
	{
		if( is_user_connected(sender) && is_user_connected(receiver) && teamtalking[sender] )
		{
			new team_sender 	= get_user_team( sender );
			new team_receiver	= get_user_team( receiver );
			
			if( team_sender != team_receiver )
			{
				engfunc( EngFunc_SetClientListening, receiver, sender, false );
				return FMRES_SUPERCEDE;
			}
		}
	}
	return FMRES_IGNORED;
}

plugin_enabled() return (get_pcvar_num(p_enabled) && !get_pcvar_num(p_voiceprox));