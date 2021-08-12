//////////////////////////////////////////////////////////////////////////////////
//
//	dod tackle
//		- Version 1.3
//		- 06.13.2007
//		- diamond-optic
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
// - Sprint into enemy players (or teammates with ff on) to do the following:
//	* knock the weapon out of their hands (primary weapon)
//	* knock any objects (tnt/satchel/etc) or their extra ammo out of their hands 
//	* knock them down on the ground (if not already prone)
//	* 'particle' effect -> little floating dots all around you
//	* quick little screenfade
//	* push the player when you hit them
//	* do damage to the player
//
// - Theres also a quicker fade for the attacker so you know when you hit someone
// - Various CVAR settings to control various aspects
// - Can Set it so admins can 'hit' teammates even with ff off
// - Logs various details for psychostats to pick up (thanks TatsuSaisei)
// - Has NO effect on bots (dont really think its worth processing them)
//
//////////////////////////////////////////////////////////////////////////////////
//
// CVARs:
//
// 	dod_tackle "1"			//turn ON(1)/OFF(0) plugin
//
//	dod_tackle_use "0"		//turn ON(1)/OFF(0) needing to press +use key
//					//while sprinting. Setting to "1" while having
//					//friendly fire on is useful so you dont hit
//					//teammates all the time...
//
//	dod_tackle_admins "0"		//turn ON(1)/OFF(0) admins being able to hit
//					//teammates even when ff is off (def. admin: immunity)
//
//	dod_tackle_ff "2"		//determines how plugin behaves in FF situations...
//						//"0" = NO friendly fire no matter what
//						//"1" = ALWAYS friendly fire
//						//"2" = Obeys mp_friendlyfire setting
//
//
//	dod_tackle_drop "1"		//turn ON(1)/OFF(0) dropping primary weapon & objects
//	dod_tackle_dropchance "2"	//chance of dropping weapon & objects (1 in # chance)
//
//	dod_tackle_prone "1"		//turn ON(1)/OFF(0) forcing prone
//	dod_tackle_pronechance "3"	//chance of forcing prone (1 in # chance)
//
//	dod_tackle_fade "1"		//turn ON(1)/OFF(0) screenfade
//	dod_tackle_fadechance "1"	//chance of screenfade (1 in # chance)
//	dod_tackle_fade_attacker "1"	//turn ON(1)/OFF(0) screenfade for the attacker
//
//	dod_tackle_push "1"		//turn ON(1)/OFF(0) pushing te victim
//	dod_tackle_pushchance "2"	//chance of pushing the victim (1 in # chance)
//
//	dod_tackle_dmg "1"		//turn ON(1)/OFF(0) doing damage
//	dod_tackle_dmgchance "4"	//chance of doing damage (1 in # chance)
//	dod_tackle_dmgamt "40"		//amount of damage for each hit
//
//	dod_tackle_particles "1"	//turn ON(1)/OFF(0) 'particle' effect
//	dod_tackle_particleschance "2"	//chance of effect happening (1 in # chance)
//
//	dod_tackle_vector "1"		//turn ON(1)/OFF(0) 'vector/punchangle' effect
//	dod_tackle_vectorchance "2"	//chance of effect happening (1 in # chance)
//
//////////////////////////////////////////////////////////////////////////////////
//
// Compiler Defines:
//
//	TACKLE_ADMIN
//		* controls the admin level used
//		* default level: immunity
//
//	VECTOR
//		* sets the angle used when calculating the vector/punchangle effect
//		* this number is set as the maximum posible angle
//		* the number is negated to set the minimum posible angle
//		* default value: 40
//	
//	FULL_PRECACHE
//		* controls whether all files are precached or not 
//		* If you find that some sounds dont work, enable this
//		* If you get any related precache errors, enable this
//
//////////////////////////////////////////////////////////////////////////////////
//
// Changelog:
//
// - 11.07.2006 Version 1.0
//	Initial Release
//
// - 11.13.2006 Version 1.1
//	Added new hit & damage sounds
//
// - 11.18.2006 Version 1.2
//	Fixed typo in the CVAR list comment (missing last 'c' in dod_tackle_fade_attacker)
//	Added CVAR to control how the plugin acts with friendly fire
//	Fixed being able to still hit bots
//
// - 11.18.2006 Version 1.2b
//	Fixed getting player team before checking if its really a player
//
// - 06.13.2007 Version 1.3
//	Removed some unneccesary code & made various improvements..
//	Blocked tackle after round end
//	Improved weapon dropping
//	Added dropping of objects & extra ammo
//	Now will undo some +/- client commands
//	Added 'particles' effect
//	Removed 'speed' cvar as sprint speed seems to always be constant	
//	Added 'vector' effect (punchangle)
//	Removed default DoD sounds from precache (dod already precaches them)
//	Added FULL_PRECACHE define to enable precaching all files
//	Adjusted 'push' force
//	Fixed bug with setting user kills
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <dodfun>
#include <dodx>

/////////////////////////////////////////////////
// FULL PRECACHE   (1=ON/0=OFF)
//
// Enable this if you find that some of
// the sounds dont play or they return
// precache errors.
// 
#define FULL_PRECACHE 0

/////////////////////////////////////////////////
// Admin Level
//
#define TACKLE_ADMIN	ADMIN_IMMUNITY

/////////////////////////////////////////////////
// Vector Angle
//
#define VECTOR	40.0 

//Global Variables
new gMsgScreenFade, gMsgDeathMsg, gMsgFrags
new Float:hitTime[33]
new bool:log_block_state = false
new bool:g_round_restart = false

//PCVARs
new p_tackle, p_use, p_admins, p_ff
new p_drop, p_dropchance
new p_prone, p_pronechance
new p_fade, p_fade2, p_fadechance
new p_dmg, p_dmgchance, p_dmgamt
new p_push, p_pushchance
new p_particles, p_particleschance
new p_vector, p_vectorchance

//Array for Sound Files
new tackle_sounds[15][] =
{
	"player/damage1.wav",
	"player/damage2.wav",
	"player/damage3.wav",
	"player/damage4.wav",
	"player/damage5.wav",
	"player/damage6.wav",
	"player/damage7.wav",
	"player/damage8.wav",
	"player/damage9.wav",
	"player/damage10.wav",
	"player/damage11.wav",
	"common/bodydrop1.wav",
	"common/bodydrop2.wav",
	"common/bodydrop3.wav",
	"common/bodydrop4.wav"
}

public plugin_init()
{
	register_plugin("DoD Tackle","1.3","AMXX DoD Team")
	register_cvar("dod_tackle_stats", "1.3", FCVAR_SERVER|FCVAR_SPONLY)
	
	//Register Forwards
	register_forward(FM_Touch, "touch")
	register_forward(FM_AlertMessage,"block_log")
	
	//Hook RoundState Message
	register_event("RoundState", "round_message", "a", "1=1", "1=3", "1=4" ,"1=5")
	
	//Get Message IDs
	gMsgDeathMsg = get_user_msgid("DeathMsg")
	gMsgScreenFade = get_user_msgid("ScreenFade")
	gMsgFrags = get_user_msgid("Frags")
	
	//CVARs
	p_tackle = register_cvar("dod_tackle","1")
	
	p_use = register_cvar("dod_tackle_use", "0")
	p_admins = register_cvar("dod_tackle_admins" , "0")
	p_ff = register_cvar("dod_tackle_ff" , "2")
		
	p_drop = register_cvar("dod_tackle_drop","1")
	p_dropchance = register_cvar("dod_tackle_dropchance","2")
	
	p_prone = register_cvar("dod_tackle_prone","1")
	p_pronechance = register_cvar("dod_tackle_pronechance","3")
	
	p_fade = register_cvar("dod_tackle_fade","1")
	p_fadechance = register_cvar("dod_tackle_fadechance","1")
	p_fade2 = register_cvar("dod_tackle_fade_attacker","1")
	
	p_push = register_cvar("dod_tackle_push","1")
	p_pushchance = register_cvar("dod_tackle_pushchance","2")
	
	p_dmg = register_cvar("dod_tackle_dmg","1")
	p_dmgchance = register_cvar("dod_tackle_dmgchance","3")
	p_dmgamt = register_cvar("dod_tackle_dmgamt","40")
	
	p_particles = register_cvar("dod_tackle_particles","1")
	p_particleschance = register_cvar("dod_tackle_particleschance","2")
	
	p_vector = register_cvar("dod_tackle_vector","1")
	p_vectorchance = register_cvar("dod_tackle_vectorchance","2")
}

public plugin_precache()
{
	
#if FULL_PRECACHE == 1
	
	//DoD already precache most of the files???
	for(new i = 0; i < 15; ++i)
		precache_sound(tackle_sounds[i])

#else
		
	precache_sound("common/bodydrop1.wav")
	precache_sound("common/bodydrop2.wav")
	precache_sound("common/bodydrop3.wav")
	precache_sound("common/bodydrop4.wav")
	
#endif

}

public touch(id,ent)
{
	if(!get_pcvar_num(p_tackle) || !pev_valid(id) || !pev_valid(ent) || id>32 || ent>32|| id<1 || ent<1 || g_round_restart)
		return FMRES_IGNORED

	new classname[32], classname2[32]
	pev(id,pev_classname, classname, 31)
	pev(ent,pev_classname, classname2, 31)
		
	if(equali(classname,"player") && equali(classname2,"player"))
		{	
		new button = pev(id,pev_button)
			
		if(!is_user_bot(id) && !is_user_bot(ent) && is_user_alive(id) && is_user_alive(ent) && is_user_connected(id) && is_user_connected(ent) && !dod_get_pronestate(ent) && ((get_pcvar_num(p_use) && button & IN_USE && button & IN_RUN) || (!get_pcvar_num(p_use) && button & IN_RUN)))
			{
			new team = get_user_team(id)	
			new other_team = get_user_team(ent)
			
			new plugin_ff = get_pcvar_num(p_ff)
					
			if(team != other_team || (team == other_team && ((get_cvar_num("mp_friendlyfire") == 1 && plugin_ff == 2) || plugin_ff == 1)) || (access(id,TACKLE_ADMIN) && get_pcvar_num(p_admins)))
				{	
				if(get_gametime() > hitTime[id])
					{				
					new steam[32], teamname[32], name[32]
					get_user_authid(id, steam, 31)
					dod_get_pl_teamname(id, teamname, 31)
					get_user_name(id, name, 31)
					new userid = get_user_userid(id)
					
					new bp_head = 0,bp_chest = 0,bp_stomach = 0,bp_leftarm = 0,bp_rightarm = 0
					switch(random_num(0,4))
						{
						case 0: bp_head = 1
						case 1: bp_chest = 1
						case 2: bp_stomach = 1
						case 3: bp_leftarm = 1
						case 4: bp_rightarm = 1
						}
															
					log_message("^"%s<%d><%s><%s>^" triggered ^"weaponstats^" (weapon ^"tackle^") (shots ^"1^") (hits ^"1^") (kills ^"0^") (headshots ^"0^") (tks ^"0^") (damage ^"0^") (deaths ^"0^") (score ^"0^")",name,userid,steam,teamname)		
					log_message("^"%s<%d><%s><%s>^" triggered ^"weaponstats2^" (weapon ^"tackle^") (head ^"%d^") (chest ^"%d^") (stomach ^"%d^") (leftarm ^"%d^") (rightarm ^"%d^") (leftleg ^"0^") (rightleg ^"0^")",name,userid,steam,teamname,bp_head ,bp_chest ,bp_stomach ,bp_leftarm ,bp_rightarm)			
					
					emit_sound(id,CHAN_BODY,tackle_sounds[random_num(11,14)],1.0,ATTN_NORM,0,PITCH_NORM)
					
					hitTime[id] = get_gametime() + 1.0
		
					client_cmd(ent, "-attack;-attack2;-reload;-speed")
		
					if(get_pcvar_num(p_drop) && random_num(1,get_pcvar_num(p_dropchance)) == 1)
						client_cmd(ent,"slot3;+attack;wait;-attack;drop;dropobject;dropammo")
		
					if(get_pcvar_num(p_prone) && random_num(1,get_pcvar_num(p_pronechance)) == 1)
						client_cmd(ent, "prone")

					if(get_pcvar_num(p_particles) && random_num(1,get_pcvar_num(p_particleschance)) == 1)
						{
						new Float:float_origin[3],origin[3]
						pev(ent,pev_origin,float_origin)
						
						origin[0] = floatround(float_origin[0])
						origin[1] = floatround(float_origin[1])
						origin[2] = floatround(float_origin[2])
						
						message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,origin,ent)
						write_byte(TE_LAVASPLASH)
						write_coord(origin[0])
						write_coord(origin[1])
						write_coord(origin[2]-40)
						message_end()
						
						message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,origin,ent)
						write_byte(TE_LAVASPLASH)
						write_coord(origin[0])
						write_coord(origin[1])
						write_coord(origin[2])
						message_end()
						}
		
					if(get_pcvar_num(p_fade) && random_num(1,get_pcvar_num(p_fadechance)) == 1)
						{
						message_begin(MSG_ONE_UNRELIABLE,gMsgScreenFade,{0,0,0},ent)
						write_short(1<<10)  //duraiton
						write_short(1<<10)  //hold time
						write_short(0x0002)  //flags
						write_byte(50) //red
						write_byte(50) //green
						write_byte(50) //blue
						write_byte(150) //alpha
						message_end()
						}
												
					if(get_pcvar_num(p_fade2))
						{
						message_begin(MSG_ONE_UNRELIABLE,gMsgScreenFade,{0,0,0},id)
						write_short(1<<10)  //duraiton
						write_short(1<<10)  //hold time
						write_short(0x0002)  //flags
						write_byte(50) //red
						write_byte(50) //green
						write_byte(50) //blue
						write_byte(50) //alpha
						message_end()
						}
						
					if(get_pcvar_num(p_vector) && random_num(1,get_pcvar_num(p_vectorchance)) == 1)
						{
						new Float:fVec[3]
						new Float:vector_low = VECTOR * -1
						
						fVec[0] = random_float(vector_low, VECTOR)
						fVec[1] = random_float(vector_low, VECTOR)
						fVec[2] = random_float(vector_low, VECTOR)
						set_pev(ent,pev_punchangle,fVec)
						}
					
					if(get_pcvar_num(p_push) && random_num(1,get_pcvar_num(p_pushchance)) == 1)
						{
						new Float:a[2][3]
						pev(id,pev_origin,a[0])
						pev(ent,pev_origin,a[1])
						
						new Float:Vel[3], speed
						pev(id, pev_velocity, Vel)
						speed = floatround(vector_length(Vel))
						
						for(new b = 0; b <= 2; b++) 
							{
							a[1][b] -= a[0][b]
							a[1][b] *= speed / random_num(15,30)
							}
				
						set_pev(ent,pev_velocity,a[1])
						}
					
					if(get_pcvar_num(p_dmg) && random_num(1,get_pcvar_num(p_dmgchance)) == 1)
						{
						emit_sound(ent,CHAN_BODY,tackle_sounds[random_num(0,10)],1.0,ATTN_NORM,0,PITCH_NORM)
								
						new steam[32], teamname[32], name[32], steam2[32], teamname2[32], name2[32]
						get_user_authid(id, steam, 31)
						get_user_authid(ent, steam2, 31)
						dod_get_pl_teamname(id, teamname, 31)
						dod_get_pl_teamname(ent, teamname2, 31)
						get_user_name(id, name, 31)
						get_user_name(ent, name2, 31)
						new userid = get_user_userid(id)
						new userid2 = get_user_userid(ent)
						
						new dmgamt = get_pcvar_num(p_dmgamt)
														
						if((pev(ent, pev_health) > dmgamt))
							{					
							log_message("^"%s<%d><%s><%s>^" triggered ^"weaponstats^" (weapon ^"tackle^") (shots ^"0^") (hits ^"0^") (kills ^"0^") (headshots ^"0^") (tks ^"0^") (damage ^"%d^") (deaths ^"0^") (score ^"0^")",name,userid,steam,teamname,dmgamt)
							
							set_pev(ent, pev_health, float(pev(ent, pev_health) - dmgamt))
							}
						else
							{
							new ff_tackle = 0
							if(get_user_team(id) == get_user_team(ent))
								ff_tackle = 1
								
							log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"tackle^"", name, userid, steam, teamname, name2, userid2, steam2, teamname2)
		
							//killer
							log_message("^"%s<%d><%s><%s>^" triggered ^"weaponstats^" (weapon ^"tackle^") (shots ^"0^") (hits ^"0^") (kills ^"1^") (headshots ^"0^") (tks ^"%d^") (damage ^"%d^") (deaths ^"0^") (score ^"0^")",name,userid,steam,teamname,ff_tackle,dmgamt)

							//victim
							log_message("^"%s<%d><%s><%s>^" triggered ^"weaponstats^" (weapon ^"tackle^") (shots ^"0^") (hits ^"0^") (kills ^"0^") (headshots ^"0^") (tks ^"0^") (damage ^"0^") (deaths ^"1^") (score ^"0^")",name2,userid2,steam2,teamname2)
												
							//set_msg_block(gMsgDeathMsg,BLOCK_ONCE)
							log_block_state = true
							user_silentkill(ent)
							log_block_state = false
							
							message_begin(MSG_ALL, gMsgDeathMsg,{0,0,0}, 0)
							write_byte(id)
							write_byte(ent)
							write_byte(0)
							message_end()
							
							new kills = dod_get_user_kills(id) + 1
							dod_set_user_kills(id,kills,0)
							
							message_begin(MSG_BROADCAST, gMsgFrags, {0,0,0}, 0)
							write_byte(id)
							write_short(kills)
							message_end()
							}
						}
					}
				else
					{
					new steam2[32], teamname2[32], name2[32]
					get_user_authid(id, steam2, 31)
					dod_get_pl_teamname(id, teamname2, 31)
					get_user_name(id, name2, 31)
															
					log_message("^"%s<%d><%s><%s>^" triggered ^"weaponstats^" (weapon ^"tackle^") (shots ^"1^") (hits ^"0^") (kills ^"0^") (headshots ^"0^") (tks ^"0^") (damage ^"0^") (deaths ^"0^") (score ^"0^")",name2,get_user_userid(id),steam2,teamname2)		
					}	
				}
			}
		}	
	return FMRES_IGNORED		
}

///////////////////////////////////////////////////////////////////////////////////////
// Block tackle after round end
//
public round_message() 
{	
	if(read_data(1) == 1)
		g_round_restart = false
	else
		g_round_restart = true
}


///////////////////////////////////////////////////////////////////////////////////////
// Block suicide log
//
public block_log(type, msg[])
{
	return(log_block_state?FMRES_SUPERCEDE:FMRES_IGNORED)
}
