//////////////////////////////////////////////////////////////////////////////////
//
//	DoD BotClass
//		- Version 0.5
//		- 09.05.2006
//		- diamond-optic
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
//	Prevent bots from playing certain classes
//
// CVARs:
//
//	dod_botclass "1"		//Turn ON(1) / OFF(0)
//	dod_botclass_change "1"		//Bots change class on death
//	dod_botclass_change_chance "3"	//Chance (1 out of #) that bots will change class on death
//
//
//	//Allowed Classes - ON(1) / OFF(0)
//	dod_botclass_britlight "1"
//	dod_botclass_britassault "1"
//	dod_botclass_sniper "1"
//	dod_botclass_mg "1"
//	dod_botclass_piat "1"
//
//	dod_botclass_alliesgarand "1"
//	dod_botclass_alliescarbine "1"
//	dod_botclass_alliesthompson "1"
//	dod_botclass_alliesgreasegun "1"
//	dod_botclass_alliesspring "1"
//	dod_botclass_alliesbar "1"
//	dod_botclass_allies30cal "1"
//	dod_botclass_alliesbazooka "1"
//
//	dod_botclass_axiskar "1"
//	dod_botclass_axisk43 "1"
//	dod_botclass_axismp40 "1"
//	dod_botclass_axismp44 "1"
//	dod_botclass_axisscopedkar "1"
//	dod_botclass_axisfg42 "1"
//	dod_botclass_axisfg42s "1"
//	dod_botclass_axismg34 "1"
//	dod_botclass_axismg42 "1"
//	dod_botclass_axispschreck "1"
//
//////////////////////////////////////////////////////////////////////////////////
//
// Changelog:
//
// - 05.19.2006 Version 0.1
//	Initial Release
//
// - 05.22.2006 Version 0.2
//	When a bot joins, random allowed class is choosen
//	Added random chance that bot will change class
//
// - 05.25.2006 Version 0.3
//	Made random class change chance more probable
//	If class = rocket then change on next death
//
// - 07.24.2006 Version 0.4
//	Adjusted putinserver task time
//	Cleaned up code
//
// - 09.05.2006 Version 0.5
//	Basically re-wrote the whole plugin, much more user-friendly now
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <dodx>
#include <dodfun>

//pcvars
new p_botclass, p_changeclass, p_changechance
//british classes
new p_brit_light, p_brit_assault, p_brit_sniper, p_brit_mg, p_brit_piat
//allied classes
new p_allies_garand, p_allies_carbine, p_allies_thompson, p_allies_greasegun, p_allies_spring, p_allies_bar, p_allies_30cal, p_allies_bazooka
//axis classes
new p_axis_kar, p_axis_k43, p_axis_mp40, p_axis_mp44, p_axis_scopedkar, p_axis_mg34, p_axis_mg42, p_axis_pschreck
//axis para extra classes
new p_axis_fg42, p_axis_fg42s

public plugin_init()
{
	register_plugin("DoD BotClass", "0.5", "AMXX DoD Team")
	
	p_botclass = register_cvar("dod_botclass", "1")
	p_changeclass = register_cvar("dod_botclass_change", "1")
	p_changechance = register_cvar("dod_botclass_change_chance", "3")
	
	p_brit_light = register_cvar("dod_botclass_britlight", "1")
	p_brit_assault = register_cvar("dod_botclass_britassault", "1")
	p_brit_sniper = register_cvar("dod_botclass_britsniper", "1")
	p_brit_mg = register_cvar("dod_botclass_britmg", "1")
	p_brit_piat = register_cvar("dod_botclass_britpiat", "1")
	
	p_allies_garand = register_cvar("dod_botclass_alliesgarand", "1")
	p_allies_carbine = register_cvar("dod_botclass_alliescarbine", "1")
	p_allies_thompson = register_cvar("dod_botclass_alliesthompson", "1")
	p_allies_greasegun = register_cvar("dod_botclass_alliesgreasegun", "1")
	p_allies_spring = register_cvar("dod_botclass_alliesspring", "1")
	p_allies_bar = register_cvar("dod_botclass_alliesbar", "1")
	p_allies_30cal = register_cvar("dod_botclass_allies30cal", "1")
	p_allies_bazooka = register_cvar("dod_botclass_alliesbazooka", "1")
	
	p_axis_kar = register_cvar("dod_botclass_axiskar", "1")
	p_axis_k43 = register_cvar("dod_botclass_axisk43", "1")
	p_axis_mp40 = register_cvar("dod_botclass_axismp40", "1")
	p_axis_mp44 = register_cvar("dod_botclass_axismp44", "1")
	p_axis_scopedkar = register_cvar("dod_botclass_axisscopedkar", "1")
	p_axis_fg42 = register_cvar("dod_botclass_axisfg42", "1")
	p_axis_fg42s = register_cvar("dod_botclass_axisfg42s", "1")
	p_axis_mg34 = register_cvar("dod_botclass_axismg34", "1")
	p_axis_mg42 = register_cvar("dod_botclass_axismg42", "1")
	p_axis_pschreck = register_cvar("dod_botclass_axispschreck", "1")
	
	register_statsfwd(XMF_DEATH)
}

public client_putinserver(id)
{
	if(is_user_bot(id) && is_user_connected(id))
		set_task(1.0,"change_class",id)
}

public client_death(killer,victim,wpnindex,hitplace,TK)
{
	if(is_user_connected(victim) && is_user_bot(victim) && get_pcvar_num(p_botclass) == 1 && get_pcvar_num(p_changeclass) == 1)
		if(random_num(1, get_pcvar_num(p_changechance)) == 1)
			set_task(1.0, "change_class", victim)
}

public change_class(id)
{
	if(is_user_connected(id) && is_user_bot(id) && get_pcvar_num(p_botclass) == 1)
		{
		//british
		if(get_user_team(id) == 1 && dod_get_map_info(MI_ALLIES_TEAM) == 1)	
			switch(random_num(1, 5))
				{
				case 1:	{
					if(get_pcvar_num(p_brit_light) == 1)
						dod_set_user_class(id, DODC_ENFIELD)
					else
						change_class(id)
					}			
				case 2:	{
					if(get_pcvar_num(p_brit_assault) == 1)
						dod_set_user_class(id, DODC_STEN)
					else
						change_class(id)
					}
				case 3:	{
					if(get_pcvar_num(p_brit_sniper) == 1)
						dod_set_user_class(id, DODC_MARKSMAN)
					else
						change_class(id)
					}
				case 4:	{
					if(get_pcvar_num(p_brit_mg) == 1)
						dod_set_user_class(id, DODC_BREN)
					else
						change_class(id)
					}
				case 5:	{
					if(get_pcvar_num(p_brit_piat) == 1)
						dod_set_user_class(id, DODC_PIAT)
					else
						change_class(id)
					}
				}
		//allies
		else if(get_user_team(id) == 1)						
			switch(random_num(1, 8))
				{
				case 1:	{
					if(get_pcvar_num(p_allies_garand) == 1)
						dod_set_user_class(id, DODC_GARAND)
					else
						change_class(id)
					}			
				case 2:	{
					if(get_pcvar_num(p_allies_carbine) == 1)
						dod_set_user_class(id, DODC_CARBINE)
					else
						change_class(id)
					}
				case 3:	{
					if(get_pcvar_num(p_allies_thompson) == 1)
						dod_set_user_class(id, DODC_THOMPSON)
					else
						change_class(id)
					}
				case 4:	{
					if(get_pcvar_num(p_allies_greasegun) == 1)
						dod_set_user_class(id, DODC_GREASE)
					else
						change_class(id)
					}
				case 5:	{
					if(get_pcvar_num(p_allies_spring) == 1)
						dod_set_user_class(id, DODC_SNIPER)
					else
						change_class(id)
					}
				case 6:	{
					if(get_pcvar_num(p_allies_bar) == 1)
						dod_set_user_class(id, DODC_BAR)
					else
						change_class(id)
					}
				case 7:	{
					if(get_pcvar_num(p_allies_30cal) == 1)
						dod_set_user_class(id, DODC_30CAL)
					else
						change_class(id)
					}
				case 8:	{
					if(get_pcvar_num(p_allies_bazooka) == 1)
						dod_set_user_class(id, DODC_BAZOOKA)
					else
						change_class(id)
					}
				}
		//axis para
		else if(get_user_team(id) == 2 && dod_get_map_info(MI_AXIS_PARAS) == 1)						
			switch(random_num(1, 10))
				{
				case 1:	{
					if(get_pcvar_num(p_axis_kar) == 1)
						dod_set_user_class(id, DODC_KAR)
					else
						change_class(id)
					}			
				case 2:	{
					if(get_pcvar_num(p_axis_k43) == 1)
						dod_set_user_class(id, DODC_K43)
					else
						change_class(id)
					}
				case 3:	{
					if(get_pcvar_num(p_axis_mp40) == 1)
						dod_set_user_class(id, DODC_MP40)
					else
						change_class(id)
					}
				case 4:	{
					if(get_pcvar_num(p_axis_mp44) == 1)
						dod_set_user_class(id, DODC_MP44)
					else
						change_class(id)
					}
				case 5:	{
					if(get_pcvar_num(p_axis_scopedkar) == 1)
						dod_set_user_class(id, DODC_SCHARFSCHUTZE)
					else
						change_class(id)
					}
				case 6:	{
					if(get_pcvar_num(p_axis_fg42) == 1)
						dod_set_user_class(id, DODC_FG42)
					else
						change_class(id)
					}
				case 7:	{
					if(get_pcvar_num(p_axis_fg42s) == 1)
						dod_set_user_class(id, DODC_SCOPED_FG42)
					else
						change_class(id)
					}
				case 8:	{
					if(get_pcvar_num(p_axis_mg34) == 1)
						dod_set_user_class(id, DODC_MG34)
					else
						change_class(id)
					}
				case 9:	{
					if(get_pcvar_num(p_axis_mg42) == 1)
						dod_set_user_class(id, DODC_MG42)
					else
						change_class(id)
					}
				case 10:{
					if(get_pcvar_num(p_axis_pschreck) == 1)
						dod_set_user_class(id, DODC_PANZERJAGER)
					else
						change_class(id)
					}
				}
		//axis non-para
		else if(get_user_team(id) == 2 && dod_get_map_info(MI_AXIS_PARAS) == 0)							
			switch(random_num(1, 8))
				{
				case 1:	{
					if(get_pcvar_num(p_axis_kar) == 1)
						dod_set_user_class(id, DODC_KAR)
					else
						change_class(id)
					}			
				case 2:	{
					if(get_pcvar_num(p_axis_k43) == 1)
						dod_set_user_class(id, DODC_K43)
					else
						change_class(id)
					}
				case 3:	{
					if(get_pcvar_num(p_axis_mp40) == 1)
						dod_set_user_class(id, DODC_MP40)
					else
						change_class(id)
					}
				case 4:	{
					if(get_pcvar_num(p_axis_mp44) == 1)
						dod_set_user_class(id, DODC_MP44)
					else
						change_class(id)
					}
				case 5:	{
					if(get_pcvar_num(p_axis_scopedkar) == 1)
						dod_set_user_class(id, DODC_SCHARFSCHUTZE)
					else
						change_class(id)
					}
				case 6:	{
					if(get_pcvar_num(p_axis_mg34) == 1)
						dod_set_user_class(id, DODC_MG34)
					else
						change_class(id)
					}
				case 7:	{
					if(get_pcvar_num(p_axis_mg42) == 1)
						dod_set_user_class(id, DODC_MG42)
					else
						change_class(id)
					}
				case 8:	{
					if(get_pcvar_num(p_axis_pschreck) == 1)
						dod_set_user_class(id, DODC_PANZERJAGER)
					else
						change_class(id)
					}
				}
		}
}