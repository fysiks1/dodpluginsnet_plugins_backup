/*	Index		line
	public_ini	61
	Main Menu	78
	Rifle Menu	100
	Auto Menu	131
	Sniper Menu	162
	Mg Menu		189
	Rocket Menu	224
	Client Say	247
*/

#include <amxmodx>
#include <amxmisc>
#include <dodfun>
#include <dodx>

#define PLUGIN "DoD Class"
#define VERSION "0.9d"
#define AUTHOR "Allenwr"

enum DODClassData {
	DODCL_Class,
	DODCL_SayText[46],
	DODCL_WepName[46]
}

#define MAXCLASS 23
new CLASS[MAXCLASS][DODClassData] = {
	{DODC_GARAND,"garand","Garand"},	//0
	{DODC_CARBINE,"carbine","Carbine"},	//1
	{DODC_THOMPSON,"thompson","Thompson"},	//2
	{DODC_GREASE,"grease","Grease"},	//3
	{DODC_SNIPER,"sniper","Sniper"},	//4
	{DODC_BAR,"bar","BAR"},			//5
	{DODC_30CAL,"30cal","30Cal"},		//6
	{DODC_BAZOOKA,"bazooka","Bazooka"},	//7
	{DODC_KAR,"k98","Karbiner98"},		//8
	{DODC_K43,"k43","Karabiner43"},		//9
	{DODC_MP40,"mp40","MP40"},		//10
	{DODC_MP44,"mp44","MP44"},		//11
	{DODC_SCHARFSCHUTZE,"scharf","Scharfschutze"},	//12
	{DODC_FG42,"fg42","FG42"},			//13
	{DODC_SCOPED_FG42,"scopedfg42","Scoped FG42"},	//14
	{DODC_MG34,"mg34","MG34"},			//15
	{DODC_MG42,"mg42","MG42"},			//16
	{DODC_PANZERJAGER,"panzer","Panzerjager"},	//17
	{DODC_ENFIELD,"enfield","Enfield"},		//18
	{DODC_STEN,"sten","Sten"},			//19
	{DODC_MARKSMAN,"scoped-enfield","Marksman"},	//20
	{DODC_BREN,"bren","Bren"},			//21
	{DODC_PIAT,"piat","PIAT"}			//22
}

#define KeysMain (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<9)
#define KeysRifles (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<9)
#define KeysAutomatics (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<9)
#define KeysSnipers (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<9)
#define KeysMGs (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<9)
#define KeysRockets (1<<0)|(1<<1)|(1<<2)|(1<<9)

new mastercvar

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("ResetHUD","hudmodelset","b")
	
	mastercvar = register_cvar("sv_dodclass","1")
	
	register_menucmd(register_menuid("Main Menu"),KeysMain,"MainMenuSelect")
	register_menucmd(register_menuid("Rifle Menu"),KeysRifles,"RifleMenuSelect")
	register_menucmd(register_menuid("Auto Menu"),KeysAutomatics,"AutoMenuSelect")
	register_menucmd(register_menuid("Sniper Menu"),KeysSnipers,"SniperMenuSelect")
	register_menucmd(register_menuid("MG Menu"),KeysMGs,"MGMenuSelect")
	register_menucmd(register_menuid("Rocket Menu"),KeysRockets,"RocketMenuSelect")
	
	register_clcmd("say /classmenu","MainMenu",ADMIN_ALL,"")
	register_clcmd("say","clientsay",ADMIN_ALL,"")
}

public MainMenu(id,level,cid) {
	if(!cmd_access(id,level,cid,2) || !get_pcvar_num(mastercvar)) {
		client_print(id,print_chat,"[AMXX]Sorry, Menus are disabled")
		return PLUGIN_HANDLED
	}
		
	show_menu(id, KeysMain,"\yMain Menu^n^n\w1. Rifle Menu^n2. Automatic Menu^n3. Sniper Menu^n4. Mg Menu^n5. Rocket Menu^n0. Exit",-1, "Main Menu")
	return PLUGIN_CONTINUE
}

public MainMenuSelect(id, key) {
	switch(key) {
		case 0: RifleMenu(id)
		case 1: AutoMenu(id)
		case 2: SniperMenu(id)
		case 3: MGMenu(id)
		case 4: RocketMenu(id)
		case 9: return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE
}

public RifleMenu(id) {
	show_menu(id, KeysRifles,"\yRifle Menu^n^n\w1. Garand^n2. Carbine^n3. Karbiner 98^n4. Karabiner 43^n5. Enfield^n0. Exit",-1, "Rifle Menu")
}

public RifleMenuSelect(id, key) {
	switch(key) {
		case 0: {
			dod_set_user_class(id, CLASS[0][DODCL_Class])
			print_client(id, 0)
		}
		case 1: {
			dod_set_user_class(id, CLASS[1][DODCL_Class])
			print_client(id, 1)
		}
		case 2: {
			dod_set_user_class(id, CLASS[8][DODCL_Class])
			print_client(id, 8)
		}
		case 3: {
			dod_set_user_class(id, CLASS[9][DODCL_Class])
			print_client(id, 9)
		}
		case 4: {
			dod_set_user_class(id, CLASS[18][DODCL_Class])
			print_client(id, 18)
		}
		case 9: return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE
}

public AutoMenu(id) {
	show_menu(id, KeysAutomatics,"\yAuto Menu^n^n\w1. Thompson^n2. Grease Gun^n3. MP40^n4. MP44^n5. Sten^n0. Exit",-1, "Auto Menu")
}

public AutoMenuSelect(id, key) {
	switch(key) {
		case 0: {
			dod_set_user_class(id, CLASS[2][DODCL_Class])
			print_client(id, 2)
		}
		case 1: {
			dod_set_user_class(id, CLASS[3][DODCL_Class])
			print_client(id, 3)
		}
		case 2: {
			dod_set_user_class(id, CLASS[10][DODCL_Class])
			print_client(id, 10)
		}
		case 3: {
			dod_set_user_class(id, CLASS[11][DODCL_Class])
			print_client(id, 11)
		}
		case 4: {
			dod_set_user_class(id, CLASS[19][DODCL_Class])
			print_client(id, 19)
		}
		case 9:	return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public SniperMenu(id) {
	show_menu(id, KeysSnipers,"\ySniper Menu^n^n\w1. Springfield^n2. Scharfschutze^n3. Enfield^n4. FG42^n0. Exit",-1, "Sniper Menu")
}

public SniperMenuSelect(id, key) {
	switch(key) {
		case 0: {
			dod_set_user_class(id, CLASS[4][DODCL_Class])
			print_client(id, 4)
		}
		case 1: {
			dod_set_user_class(id, CLASS[12][DODCL_Class])
			print_client(id, 12)
		}
		case 2: {
			dod_set_user_class(id, CLASS[20][DODCL_Class])
			print_client(id, 20)
		}
		case 3: {
			dod_set_user_class(id, CLASS[14][DODCL_Class])
			print_client(id, 14)
		}
		case 9: return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE
}

public MGMenu(id) {
	show_menu(id, KeysMGs,"\yMG Menu^n^n\w1. BAR^n2. .30 Cal^n3. MG34^n4. MG42^n5. FG42^n6. Bren^n0. Exit",-1, "MG Menu")
}

public MGMenuSelect(id, key) {
	switch(key) {
		case 0: {
			dod_set_user_class(id, CLASS[5][DODCL_Class])
			print_client(id, 5)
		}
		case 1: {
			dod_set_user_class(id, CLASS[6][DODCL_Class])
			print_client(id, 6)
		}
		case 2: {
			dod_set_user_class(id, CLASS[15][DODCL_Class])
			print_client(id, 15)
		}
		case 3: {
			dod_set_user_class(id, CLASS[16][DODCL_Class])
			print_client(id, 16)
		}
		case 4: {
			dod_set_user_class(id, CLASS[13][DODCL_Class])
			print_client(id, 13)
		}
		case 5: {
			dod_set_user_class(id, CLASS[21][DODCL_Class])
			print_client(id, 21)
		}
		case 9: return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE
}

public RocketMenu(id) {
	show_menu(id, KeysRockets,"\yRocket Menu^n^n\w1. Bazooka^n2. Panzerschrek^n3. PIAT^n0. Exit",-1, "Rocket Menu")
}

public RocketMenuSelect(id, key) {
	switch(key) {
		case 0: {
			dod_set_user_class(id, CLASS[7][DODCL_Class])
			print_client(id, CLASS[7][DODCL_WepName])
		}
		case 1: {
			dod_set_user_class(id, CLASS[17][DODCL_Class])
			print_client(id, CLASS[17][DODCL_WepName])
		}
		case 2: {
			dod_set_user_class(id, CLASS[22][DODCL_Class])
			print_client(id, CLASS[22][DODCL_WepName])
		}
		case 9: return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE
}

public clientsay(id,level,cid) {
	if(!cmd_access(id,level,cid,2) || !get_pcvar_num(mastercvar)) {
		client_print(id, print_chat,"[AMXX]Sorry, Weapons are disabled")
		return PLUGIN_HANDLED;
	}
	
	new txt[32], dir[80], file[64]
	read_argv(1,txt,31)
	
	if(equali(txt,"/allies") || equali(txt,"/axis") || equali(txt,"/british") || equali(txt,"/axis-para")) {
		get_localinfo("amxx_configsdir",dir,79)
		format(file, 63,"%s/dodclass/%s.txt",dir,txt)
		show_motd(id,file,"Allen's DoD Class System")
	}
	if(txt[0] != '/')
		return PLUGIN_CONTINUE;
	
	for(new i = 0 ; i < MAXCLASS ; i++) {
		if(equali(txt[1],CLASS[i][DODCL_SayText])) {
			dod_set_user_class(id,CLASS[i][DODCL_Class]);
			print_client(id, i)
			break;
		}
	}
	return PLUGIN_HANDLED
}

public print_client(id, iClass) {
	client_print(id, print_chat, "[AMXX] You're respawn weapon is a: %s", CLASS[iClass][DODCL_WepName]);
}

//---------------------------thanks to diamond-optic
public hudmodelset(id) {
	new team = get_user_team(id)
	
	switch(team) {
		case 1: {
			new is_brit = dod_get_map_info(MI_ALLIES_TEAM)
			
			switch(is_brit) {
				case 0: {
					new is_para = dod_get_map_info(MI_ALLIES_PARAS)
					
					switch(is_para) {
						case 0: dod_set_model(id, "us-inf")
						case 1: dod_set_model(id, "us-para")
					}
				}
				case 1: dod_set_model(id, "brit-inf")
			}
		}
		case 2: {
			new is_para = dod_get_map_info(MI_AXIS_PARAS)
			
			switch(is_para) {
				case 0: dod_set_model(id, "axis-inf")
				case 1: dod_set_model(id, "axis-para")
			}
		}
	}
}
//----------------------------end thanks
public dod_client_changeteam(id, team, oldteam)
	dod_clear_model(id)
