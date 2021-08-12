/* 
	DOD CUSTOMSUPPLY
	by Wilson [29th ID]
	www.29th.org
	
	Part of the 29th ID's modification to
	Day of Defeat, making it more realistic
	DOD:Realism - dodrealism.branzone.com
	
	DESCRIPTION
	This plugin allows you to customize every
	class in Day of Defeat. You can assign how
	many primary weapon clips each class gets,
	how many pistol clips they get, whether or
	not they get a pistol, whether or not they
	get a knife, and how many grenades they get.
	
	You can use this for knives-only or pistols-
	only by setting the weapons you don't want to
	give to -1. You can also have a class not 
	get any weapon at all if you like.
	
	This plugin is also compatable with Zor's
	smokegrenades plugin and 29th's Mortar Class.
	
	CREDITS
	www.dodplugins.net
	GO THERE - All your Dod plugins/scripting help!
*/
/*
	VERSIONS/CHANGELOG
	v1.0
	-Initial Release
	-Compatable with Zor's Smoke nade plugin
	-Compatable with 29th's Mortar Class plugin
	v1.1
	-Fixed bug that gave enemy grenades even if
	 smoke grenades were disabled
	v1.2
	-Included "clip ammo" in the cvars - this way
	 setting ammo to 2 means 1 in clip 1 in backpack
	-Fixed default bren grenade setting to 1
*/
/*
	USAGE (CVARS)
	
	dod_customsupply <1/0>
		Enable or disable the entire plugin
	dod_customsupply_allies <1/0>
		Enable or disable the plugin affecting
		allies
	dod_customsupply_axis <1/0>
		Enable or disable the plugin affecting
		axis
	---------------------------------
	SMOKE GRENADES
		There is nothing you need to adjust to 
		make this plugin compatable with smoke
		grenades. Do it how you usually would
		and it will work.
	---------------------------------	
	INSTRUCTIONS
	There are four sections to each
	class for this: Primary, Secondary, Melee, and 
	Grenades. They are set to the Dod defualts so put
	the ones you want to adjust in amxx.cfg (you don't
	need the ones you don't want to adjust)
	
	For Primary: Setting to "1" gives player 1 clip
	Setting to "2" gives player 2 clips, etc.
	Set to "0" to give player an empty gun
	Set to "-1" to not give player a gun
	
	For Secondary: Setting to "1" gives player 1 clip
	Setting to "2" gives player 2 clips, etc.
	Set to "-1" to not give a pistol
	
	For Melee: Setting to "1" gives player a knife.
	Set to "0" or "-1" to not give a knife
	
	For Grenades: Setting to "1" gives a player 1 nade.
	Setting to "2" gives player 2 nades, etc.
	----------------------------------
	SETTINGS (CVARS)
	
	// US Allies
	custom_rifleman_primary
	custom_rifleman_secondary
	custom_rifleman_melee
	custom_rifleman_gren
	
	custom_ssgt_primary
	custom_ssgt_secondary
	custom_ssgt_melee
	custom_ssgt_gren
	
	custom_msgt_primary
	custom_msgt_secondary
	custom_msgt_melee
	custom_msgt_gren
	
	custom_sgt_primary
	custom_sgt_secondary
	custom_sgt_melee
	custom_sgt_gren
	
	custom_sniper_primary
	custom_sniper_secondary
	custom_sniper_melee
	custom_sniper_gren
	
	custom_support_primary
	custom_support_secondary
	custom_support_melee
	custom_support_gren
	
	custom_mg_primary
	custom_mg_secondary
	custom_mg_melee
	custom_mg_gren
	
	custom_bazooka_primary
	custom_bazooka_secondary
	custom_bazooka_melee
	custom_bazooka_gren
	
	// Only for use with mortar plugin (available at dodplugins.net)
	custom_mortar_primary
	custom_mortar_secondary
	custom_mortar_melee
	custom_mortar_gren
	
	// British Allies
	custom_britrifleman_primary
	custom_britrifleman_secondary
	custom_britrifleman_melee
	custom_britrifleman_gren
	
	custom_britsgt_primary
	custom_britsgt_secondary
	custom_britsgt_melee
	custom_britsgt_gren
	
	custom_marksman_primary
	custom_marksman_secondary
	custom_marksman_melee
	custom_marksman_gren
	
	custom_gunner_primary
	custom_gunner_secondary
	custom_gunner_melee
	custom_gunner_gren
	
	custom_piat_primary
	custom_piat_secondary
	custom_piat_melee
	custom_piat_gren
	
	// Only for use with mortar plugin (available at dodplugins.net)
	custom_britmortar_primary
	custom_britmortar_secondary
	custom_britmortar_melee
	custom_britmortar_gren
	
	// Axis
	custom_grenadier_primary
	custom_grenadier_secondary
	custom_grenadier_melee
	custom_grenadier_gren
	
	custom_stross_primary
	custom_stross_secondary
	custom_stross_melee
	custom_stross_gren
	
	custom_unter_primary
	custom_unter_secondary
	custom_unter_melee
	custom_unter_gren
	
	custom_sturm_primary
	custom_sturm_secondary
	custom_sturm_melee
	custom_sturm_gren
	
	custom_scharfs_primary
	custom_scharfs_secondary
	custom_scharfs_melee
	custom_scharfs_gren
	
	custom_fg42_primary
	custom_fg42_secondary
	custom_fg42_melee
	custom_fg42_gren
	
	custom_fg42s_primary
	custom_fg42s_secondary
	custom_fg42s_melee
	custom_fg42s_gren
	
	custom_mg34_primary
	custom_mg34_secondary
	custom_mg34_melee
	custom_mg34_gren
	
	custom_mg42_primary
	custom_mg42_secondary
	custom_mg42_melee
	custom_mg42_gren
	
	custom_panzer_primary
	custom_panzer_secondary
	custom_panzer_melee
	custom_panzer_gren
	
	// Only for use with mortar plugin (available at dodplugins.net)
	custom_germortar_primary
	custom_germortar_secondary
	custom_germortar_melee
	custom_germortar_gren
*/

#include <amxmodx>
#include <amxmisc>
#include <dodx>
#include <dodfun>
#include <engine>
#include <fakemeta>
#include <fun>

#define PLUGIN "Dod CustomSupply"
#define VERSION "1.2"
#define AUTHOR "29th ID"

// Ammo Channels
#define AMMO_SMG 1 // thompson, greasegun, sten, mp40
#define AMMO_ALTRIFLE 2 // carbine, k43, mg34
#define AMMO_RIFLE 3 // garand, enfield, scoped enfield, k98, scoped k98
#define AMMO_PISTOL 4 // colt, webley, luger
#define AMMO_SPRING 5 // springfield
#define AMMO_HEAVY 6 // bar, bren, stg44, fg42, scoped fg42
#define AMMO_MG42 7    // mg42
#define AMMO_30CAL 8 // 30cal
#define AMMO_GREN 9 // grenades (should be all 3 types)
#define AMMO_ROCKET 13 // bazooka, piat, panzerschreck

new ammoStock[7]
new ammoWpnName[32]
new gmsgAmmoX
new clipCapacity[41] = {0,0,0,7,8,5,30,30,5,5,20,30,0,0,0,0,250,150,0,15,75,30,20,10,5,30,30,6,1,1,1,20,15,0,5,0,0,0,0,0,0}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("ResetHUD", "reset_hud", "be")
	gmsgAmmoX = get_user_msgid("AmmoX")
	
	// CVARS
	register_cvar("dod_customsupply", "1")
	register_cvar("dod_customsupply_allies", "1")
	register_cvar("dod_customsupply_axis", "1")
	
	// SETTINGS -- ALLIES (US)
	register_cvar("custom_rifleman_melee", "1")
	register_cvar("custom_rifleman_secondary", "3")
	register_cvar("custom_rifleman_primary", "11")
	register_cvar("custom_rifleman_gren", "2")
	
	register_cvar("custom_ssgt_melee", "1")
	register_cvar("custom_ssgt_secondary", "3")
	register_cvar("custom_ssgt_primary", "11")
	register_cvar("custom_ssgt_gren", "2")
	
	register_cvar("custom_msgt_melee", "1")
	register_cvar("custom_msgt_secondary", "3")
	register_cvar("custom_msgt_primary", "7")
	register_cvar("custom_msgt_gren", "1")
	
	register_cvar("custom_sgt_melee", "1")
	register_cvar("custom_sgt_secondary", "3")
	register_cvar("custom_sgt_primary", "7")
	register_cvar("custom_sgt_gren", "1")
	
	register_cvar("custom_sniper_melee", "1")
	register_cvar("custom_sniper_secondary", "3")
	register_cvar("custom_sniper_primary", "11")
	register_cvar("custom_sniper_gren", "0")
	
	register_cvar("custom_support_melee", "1")
	register_cvar("custom_support_secondary", "3")
	register_cvar("custom_support_primary", "13")
	register_cvar("custom_support_gren", "1")
	
	register_cvar("custom_mg_melee", "1")
	register_cvar("custom_mg_secondary", "3")
	register_cvar("custom_mg_primary", "2")
	register_cvar("custom_mg_gren", "0")
	
	register_cvar("custom_bazooka_melee", "1")
	register_cvar("custom_bazooka_secondary", "3")
	register_cvar("custom_bazooka_primary", "6")
	register_cvar("custom_bazooka_gren", "0")
	
	register_cvar("custom_mortar_melee", "1")
	register_cvar("custom_mortar_secondary", "3")
	register_cvar("custom_mortar_primary", "0") // Doesn't do anything - must edit in mortar plugin
	register_cvar("custom_mortar_gren", "0")
	
	
	
	// SETTINGS -- ALLIES (BRITISH)
	register_cvar("custom_britrifleman_melee", "1")
	register_cvar("custom_britrifleman_secondary", "2")
	register_cvar("custom_britrifleman_primary", "11")
	register_cvar("custom_britrifleman_gren", "2")
	
	register_cvar("custom_britsgt_melee", "1")
	register_cvar("custom_britsgt_secondary", "2")
	register_cvar("custom_britsgt_primary", "7")
	register_cvar("custom_britsgt_gren", "1")
	
	register_cvar("custom_marksman_melee", "1")
	register_cvar("custom_marksman_secondary", "2")
	register_cvar("custom_marksman_primary", "11")
	register_cvar("custom_marksman_gren", "0")
	
	register_cvar("custom_gunner_melee", "1")
	register_cvar("custom_gunner_secondary", "2")
	register_cvar("custom_gunner_primary", "6")
	register_cvar("custom_gunner_gren", "1")
	
	register_cvar("custom_piat_melee", "1")
	register_cvar("custom_piat_secondary", "2")
	register_cvar("custom_piat_primary", "6")
	register_cvar("custom_piat_gren", "0")
	
	register_cvar("custom_britmortar_melee", "1")
	register_cvar("custom_britmortar_secondary", "2")
	register_cvar("custom_britmortar_primary", "0") // Doesn't do anything - must edit in mortar plugin
	register_cvar("custom_britmortar_gren", "0")
	
	
	// SETTINGS -- AXIS
	register_cvar("custom_grenadier_melee", "1")
	register_cvar("custom_grenadier_secondary", "2")
	register_cvar("custom_grenadier_primary", "13")
	register_cvar("custom_grenadier_gren", "2")
	
	register_cvar("custom_stross_melee", "1")
	register_cvar("custom_stross_secondary", "2")
	register_cvar("custom_stross_primary", "8")
	register_cvar("custom_stross_gren", "2")
	
	register_cvar("custom_unter_melee", "1")
	register_cvar("custom_unter_secondary", "2")
	register_cvar("custom_unter_primary", "7")
	register_cvar("custom_unter_gren", "1")
	
	register_cvar("custom_sturm_melee", "1")
	register_cvar("custom_sturm_secondary", "2")
	register_cvar("custom_sturm_primary", "7")
	register_cvar("custom_sturm_gren", "1")
	
	register_cvar("custom_scharfs_melee", "1")
	register_cvar("custom_scharfs_secondary", "2")
	register_cvar("custom_scharfs_primary", "13")
	register_cvar("custom_scharfs_gren", "0")
	
	register_cvar("custom_fg42_melee", "1")
	register_cvar("custom_fg42_secondary", "2")
	register_cvar("custom_fg42_primary", "9")
	register_cvar("custom_fg42_gren", "1")
	
	register_cvar("custom_fg42s_melee", "1")
	register_cvar("custom_fg42s_secondary", "2")
	register_cvar("custom_fg42s_primary", "9")
	register_cvar("custom_fg42s_gren", "1")
	
	register_cvar("custom_mg34_melee", "1")
	register_cvar("custom_mg34_secondary", "2")
	register_cvar("custom_mg34_primary", "6")
	register_cvar("custom_mg34_gren", "0")
	
	register_cvar("custom_mg42_melee", "1")
	register_cvar("custom_mg42_secondary", "2")
	register_cvar("custom_mg42_primary", "2")
	register_cvar("custom_mg42_gren", "0")
	
	register_cvar("custom_panzer_melee", "1")
	register_cvar("custom_panzer_secondary", "2")
	register_cvar("custom_panzer_primary", "6")
	register_cvar("custom_panzer_gren", "0")
	
	register_cvar("custom_germortar_melee", "1")
	register_cvar("custom_germortar_secondary", "2")
	register_cvar("custom_germortar_primary", "0") // Doesn't do anything - must edit in mortar plugin
	register_cvar("custom_germortar_gren", "0")
}

// Called upon player spawning
public reset_hud(id) {
	new myTeam = get_user_team(id)
	if(!get_cvar_num("dod_customsupply"))
		return PLUGIN_CONTINUE
	if( (myTeam == ALLIES && !get_cvar_num("dod_customsupply_allies")) || (myTeam == AXIS && !get_cvar_num("dod_customsupply_axis")) )
		return PLUGIN_CONTINUE
		
	set_task(0.1,"set_supply",id)
	
	return PLUGIN_CONTINUE
}

public set_supply(id) {
	// Get Ammo Supply for User from cvars based on class
	get_supply(id)
	
	new ammoPrimary   = ammoStock[0]
	new ammoSecondary = ammoStock[1]
	new ammoMelee      = ammoStock[2]
	new ammoGren       = ammoStock[3]
	new ammoSmoke      = ammoStock[4]
	new ammoChannel   = ammoStock[5]
	new ammoWeapon    = ammoStock[6]
	
	// Strip the user
	strip_user_weapons(id)
	
	// If US Allies
	if(get_user_team(id) == ALLIES && dod_get_map_info(MI_ALLIES_TEAM) == 0) {
		// Melee Weapon
		if(ammoMelee > 0)
			give_item(id, "weapon_amerknife")
		// Secondary Weapon
		if(ammoSecondary > -1) {
			give_item(id, "weapon_colt")
			set_ammo(id, DODW_COLT, AMMO_PISTOL, ammoSecondary)
		}
		// Primary Weapon
		if(ammoPrimary > -1) {
			give_item(id, ammoWpnName)
			set_ammo(id, ammoWeapon, ammoChannel, ammoPrimary)
		}
		// Grenades
		if(ammoGren > 0) {
			for(new i=0; i<ammoGren; i++)
				give_item(id, "weapon_handgrenade")
		}
		// Smoke Grenades
		if( (ammoSmoke > 0) && (get_cvar_num("dod_smokegrenades")) ) {
			for(new i=0; i<ammoSmoke; i++)
				give_item(id, "weapon_stickgrenade")
		}
	}
	// If British Allies
	else if(get_user_team(id) == ALLIES && dod_get_map_info(MI_ALLIES_TEAM) == 1) {
		if(ammoMelee > 0)
			give_item(id, "weapon_amerknife")
		if(ammoSecondary > -1) {
			give_item(id, "weapon_webley")
			set_ammo(id, DODW_WEBLEY, AMMO_PISTOL, ammoSecondary)
		}
		if(ammoPrimary > -1) {
			give_item(id, ammoWpnName)
			set_ammo(id, ammoWeapon, ammoChannel, ammoPrimary)
		}
		if(ammoGren > 0) {
			for(new i=0; i<ammoGren; i++)
				give_item(id, "weapon_handgrenade")
		}
		if( (ammoSmoke > 0) && (get_cvar_num("dod_smokegrenades")) ) {
			for(new i=0; i<ammoSmoke; i++)
				give_item(id, "weapon_stickgrenade")
		}
	}
	// If Axis
	else if(get_user_team(id) == AXIS) {
		if(ammoMelee > 0) {
			give_item(id, "weapon_spade")
			give_item(id, "weapon_gerknife")
		}
		if(ammoSecondary > -1) {
			give_item(id, "weapon_luger")
			set_ammo(id, DODW_LUGER, AMMO_PISTOL, ammoSecondary)
		}
		if(ammoPrimary > -1) {
			give_item(id, ammoWpnName)
			set_ammo(id, ammoWeapon, ammoChannel, ammoPrimary)
		}
		if(ammoGren > 0) {
			for(new i=0; i<ammoGren; i++)
				give_item(id, "weapon_stickgrenade")
		}
		if( (ammoSmoke > 0) && (get_cvar_num("dod_smokegrenades")) ) {
			for(new i=0; i<ammoSmoke; i++)
				give_item(id, "weapon_handgrenade")
		}
	}
	
	return PLUGIN_CONTINUE
}

// Set the users backapck ammo and update it on the hud
// Note, when adding rather than decreasing the amount 
// of magazines, sometimes the number in the corner 
// does not update until you reload
stock set_ammo(id,weapon,channel,ammo) {
	new bpAmmo, clipAmmo
	if(ammo) {
		bpAmmo = (ammo - 1) * clipCapacity[weapon]
		clipAmmo = clipCapacity[weapon]
	}
	dod_set_user_ammo(id, weapon, bpAmmo)
	// Update user's HUD
	message_begin(MSG_ONE,gmsgAmmoX,{0,0,0},id);
	write_byte(channel);
	write_byte(bpAmmo);
	message_end();
	
	set_clip(id,ammoWpnName,clipAmmo)
	
	return PLUGIN_CONTINUE
}

// Set current clip (not backpack ammo)
stock set_clip(id,const weapon[],clip) {

	new currentent = -1, gunid = 0

	// get origin
	new Float:origin[3];
	entity_get_vector(id,EV_VEC_origin,origin);
	
	while((currentent = find_ent_in_sphere(currentent,origin,Float:1.0)) != 0) {
		new classname[32];
		entity_get_string(currentent,EV_SZ_classname,classname,31);
	
		if(equal(classname,weapon))
			gunid = currentent
	
	}
	
	set_pdata_int(gunid,108,clip); // set their ammo
	
	return PLUGIN_CONTINUE
}

// Get ammo count from cvars based on player class
stock get_supply(id) {
	new ammoPrimary, ammoSecondary, ammoMelee, ammoGren, ammoSmoke, ammoChannel, ammoWeapon
	new myClass = dod_get_user_class(id)
	
	if(get_cvar_num("dod_customsupply_allies"))
	{
		switch(myClass)
		{
			case DODC_GARAND: {
				ammoPrimary   = get_cvar_num("custom_rifleman_primary")
				ammoSecondary = get_cvar_num("custom_rifleman_secondary")
				ammoMelee      = get_cvar_num("custom_rifleman_melee")
				ammoGren       = get_cvar_num("custom_rifleman_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_garand")
				ammoChannel   = AMMO_RIFLE
				ammoWeapon    = DODW_GARAND
				ammoWpnName   = "weapon_garand"
			}
			case DODC_CARBINE: {
				ammoPrimary   = get_cvar_num("custom_ssgt_primary")
				ammoSecondary = get_cvar_num("custom_ssgt_secondary")
				ammoMelee      = get_cvar_num("custom_ssgt_melee")
				ammoGren       = get_cvar_num("custom_ssgt_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_carbine")
				ammoChannel   = AMMO_ALTRIFLE
				ammoWeapon    = DODW_M1_CARBINE
				ammoWpnName   = "weapon_m1carbine"
			}
			case DODC_THOMPSON: {
				ammoPrimary   = get_cvar_num("custom_msgt_primary")
				ammoSecondary = get_cvar_num("custom_msgt_secondary")
				ammoMelee      = get_cvar_num("custom_msgt_melee")
				ammoGren       = get_cvar_num("custom_msgt_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_thompson")
				ammoChannel   = AMMO_SMG
				ammoWeapon    = DODW_THOMPSON
				ammoWpnName   = "weapon_thompson"
			}
			case DODC_GREASE: {
				ammoPrimary   = get_cvar_num("custom_sgt_primary")
				ammoSecondary = get_cvar_num("custom_sgt_secondary")
				ammoMelee      = get_cvar_num("custom_sgt_melee")
				ammoGren       = get_cvar_num("custom_sgt_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_grease")
				ammoChannel   = AMMO_SMG
				ammoWeapon    = DODW_GREASEGUN
				ammoWpnName   = "weapon_greasegun"
			}
			case DODC_SNIPER: {
				ammoPrimary   = get_cvar_num("custom_sniper_primary")
				ammoSecondary = get_cvar_num("custom_sniper_secondary")
				ammoMelee      = get_cvar_num("custom_sniper_melee")
				ammoGren       = get_cvar_num("custom_sniper_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_sniper")
				ammoChannel   = AMMO_SPRING
				ammoWeapon    = DODW_SPRINGFIELD
				ammoWpnName   = "weapon_spring"
			}
			case DODC_BAR: {
				ammoPrimary   = get_cvar_num("custom_support_primary")
				ammoSecondary = get_cvar_num("custom_support_secondary")
				ammoMelee      = get_cvar_num("custom_support_melee")
				ammoGren       = get_cvar_num("custom_support_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_bar")
				ammoChannel   = AMMO_HEAVY
				ammoWeapon    = DODW_BAR
				ammoWpnName   = "weapon_bar"
			}
			case DODC_30CAL: {
				ammoPrimary   = get_cvar_num("custom_mg_primary")
				ammoSecondary = get_cvar_num("custom_mg_secondary")
				ammoMelee      = get_cvar_num("custom_mg_melee")
				ammoGren       = get_cvar_num("custom_mg_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_30cal")
				ammoChannel   = AMMO_30CAL
				ammoWeapon    = DODW_30_CAL
				ammoWpnName   = "weapon_30cal"
			}
			case DODC_BAZOOKA: {
				ammoPrimary   = get_cvar_num("custom_bazooka_primary") 
				ammoSecondary = get_cvar_num("custom_bazooka_secondary")
				ammoMelee      = get_cvar_num("custom_bazooka_melee")
				ammoGren       = get_cvar_num("custom_bazooka_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_bazooka")
				ammoChannel   = AMMO_ROCKET
				ammoWeapon    = DODW_BAZOOKA
				ammoWpnName   = "weapon_bazooka"
			}
			case 9: {
				ammoPrimary   = 0
				ammoSecondary = get_cvar_num("custom_mortar_secondary")
				ammoMelee      = get_cvar_num("custom_mortar_melee")
				ammoGren       = get_cvar_num("custom_mortar_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_mortar")
				ammoChannel   = AMMO_ROCKET
				ammoWeapon    = DODW_PANZERSCHRECK
				ammoWpnName   = "weapon_pschreck"
			}
			case DODC_ENFIELD: {
				ammoPrimary   = get_cvar_num("custom_britrifleman_primary")
				ammoSecondary = get_cvar_num("custom_britrifleman_secondary")
				ammoMelee      = get_cvar_num("custom_britrifleman_melee")
				ammoGren       = get_cvar_num("custom_britrifleman_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_enfield")
				ammoChannel   = AMMO_RIFLE
				ammoWeapon    = DODW_ENFIELD
				ammoWpnName   = "weapon_enfield"
			}
			case DODC_STEN: {
				ammoPrimary   = get_cvar_num("custom_britsgt_primary") 
				ammoSecondary = get_cvar_num("custom_britsgt_secondary")
				ammoMelee      = get_cvar_num("custom_britsgt_melee")
				ammoGren       = get_cvar_num("custom_britsgt_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_sten")
				ammoChannel   = AMMO_SMG
				ammoWeapon    = DODW_STEN
				ammoWpnName   = "weapon_sten"
			}
			case DODC_MARKSMAN: {
				ammoPrimary   = get_cvar_num("custom_marksman_primary")
				ammoSecondary = get_cvar_num("custom_marksman_secondary")
				ammoMelee      = get_cvar_num("custom_marksman_melee")
				ammoGren       = get_cvar_num("custom_marksman_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_marksman")
				ammoChannel   = AMMO_RIFLE
				ammoWeapon    = DODW_SCOPED_ENFIELD
				ammoWpnName   = "weapon_scoped_enfield"
			}
			case DODC_BREN: {
				ammoPrimary   = get_cvar_num("custom_gunner_primary")
				ammoSecondary = get_cvar_num("custom_gunner_secondary")
				ammoMelee      = get_cvar_num("custom_gunner_melee")
				ammoGren       = get_cvar_num("custom_gunner_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_bren")
				ammoChannel   = AMMO_HEAVY
				ammoWeapon    = DODW_BREN
				ammoWpnName   = "weapon_bren"
			}
			case DODC_PIAT: {
				ammoPrimary   = get_cvar_num("custom_piat_primary")
				ammoSecondary = get_cvar_num("custom_piat_secondary")
				ammoMelee      = get_cvar_num("custom_piat_melee")
				ammoGren       = get_cvar_num("custom_piat_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_piat")
				ammoChannel   = AMMO_ROCKET
				ammoWeapon    = DODW_PIAT
				ammoWpnName   = "weapon_piat"
			}
			case 26: {
				ammoPrimary   = 0
				ammoSecondary = get_cvar_num("custom_britmortar_secondary")
				ammoMelee      = get_cvar_num("custom_britmortar_melee")
				ammoGren       = get_cvar_num("custom_britmortar_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_britmortar")
				ammoChannel   = AMMO_ROCKET
				ammoWeapon    = DODW_PANZERSCHRECK
				ammoWpnName   = "weapon_pschreck"
			}
		}
	}
	
	if(get_cvar_num("dod_customsupply_axis"))
	{
		switch(myClass)
		{
			case DODC_KAR: {
				ammoPrimary   = get_cvar_num("custom_grenadier_primary")
				ammoSecondary = get_cvar_num("custom_grenadier_secondary")
				ammoMelee      = get_cvar_num("custom_grenadier_melee")
				ammoGren       = get_cvar_num("custom_grenadier_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_kar")
				ammoChannel   = AMMO_RIFLE
				ammoWeapon    = DODW_KAR
				ammoWpnName   = "weapon_kar"
			}
			case DODC_K43: {
				ammoPrimary   = get_cvar_num("custom_stross_primary")
				ammoSecondary = get_cvar_num("custom_stross_secondary")
				ammoMelee      = get_cvar_num("custom_stross_melee")
				ammoGren       = get_cvar_num("custom_stross_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_k43")
				ammoChannel   = AMMO_ALTRIFLE
				ammoWeapon    = DODW_K43
				ammoWpnName   = "weapon_k43"
			}
			case DODC_MP40: {
				ammoPrimary   = get_cvar_num("custom_unter_primary")
				ammoSecondary = get_cvar_num("custom_unter_secondary")
				ammoMelee      = get_cvar_num("custom_unter_melee")
				ammoGren       = get_cvar_num("custom_unter_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_mp40")
				ammoChannel   = AMMO_SMG
				ammoWeapon    = DODW_MP40
				ammoWpnName   = "weapon_mp40"
			}
			case DODC_MP44: {
				ammoPrimary   = get_cvar_num("custom_sturm_primary")
				ammoSecondary = get_cvar_num("custom_sturm_secondary")
				ammoMelee      = get_cvar_num("custom_sturm_melee")
				ammoGren       = get_cvar_num("custom_sturm_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_mp44")
				ammoChannel   = AMMO_HEAVY
				ammoWeapon    = DODW_STG44
				ammoWpnName   = "weapon_mp44"
			}
			case DODC_SCHARFSCHUTZE: {
				ammoPrimary   = get_cvar_num("custom_scharfs_primary")
				ammoSecondary = get_cvar_num("custom_scharfs_secondary")
				ammoMelee      = get_cvar_num("custom_scharfs_melee")
				ammoGren       = get_cvar_num("custom_scharfs_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_scharfschutze")
				ammoChannel   = AMMO_RIFLE
				ammoWeapon    = DODW_SCOPED_KAR
				ammoWpnName   = "weapon_scopedkar"
			
			}
			case DODC_FG42: {
				ammoPrimary   = get_cvar_num("custom_fg42_primary")
				ammoSecondary = get_cvar_num("custom_fg42_secondary")
				ammoMelee      = get_cvar_num("custom_fg42_melee")
				ammoGren       = get_cvar_num("custom_fg42_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_fg42")
				ammoChannel   = AMMO_HEAVY
				ammoWeapon    = DODW_FG42
				ammoWpnName   = "weapon_fg42"
			}
			case DODC_SCOPED_FG42: {
				ammoPrimary   = get_cvar_num("custom_fg42s_primary")
				ammoSecondary = get_cvar_num("custom_fg42s_secondary")
				ammoMelee      = get_cvar_num("custom_fg42s_melee")
				ammoGren       = get_cvar_num("custom_fg42s_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_scoped_fg42")
				ammoChannel   = AMMO_HEAVY
				ammoWeapon    = DODW_SCOPED_FG42
				ammoWpnName   = "weapon_scoped_fg42"
			}
			case DODC_MG34: {
				ammoPrimary   = get_cvar_num("custom_mg34_primary")
				ammoSecondary = get_cvar_num("custom_mg34_secondary")
				ammoMelee      = get_cvar_num("custom_mg34_melee")
				ammoGren       = get_cvar_num("custom_mg34_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_mg34")
				ammoChannel   = AMMO_ALTRIFLE
				ammoWeapon    = DODW_MG34
				ammoWpnName   = "weapon_mg34"
			}
			case DODC_MG42: {
				ammoPrimary   = get_cvar_num("custom_mg42_primary")
				ammoSecondary = get_cvar_num("custom_mg42_secondary")
				ammoMelee      = get_cvar_num("custom_mg42_melee")
				ammoGren       = get_cvar_num("custom_mg42_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_mg42")
				ammoChannel   = AMMO_MG42
				ammoWeapon    = DODW_MG42
				ammoWpnName   = "weapon_mg42"
			}
			case DODC_PANZERJAGER: {
				ammoPrimary   = get_cvar_num("custom_panzer_primary")
				ammoSecondary = get_cvar_num("custom_panzer_secondary")
				ammoMelee      = get_cvar_num("custom_panzer_melee")
				ammoGren       = get_cvar_num("custom_panzer_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_panzerjager")
				ammoChannel   = AMMO_ROCKET
				ammoWeapon    = DODW_PANZERSCHRECK
				ammoWpnName   = "weapon_pschreck"
			}
			case 20: {
				ammoPrimary   = 0
				ammoSecondary = get_cvar_num("custom_germortar_secondary")
				ammoMelee      = get_cvar_num("custom_germortar_melee")
				ammoGren       = get_cvar_num("custom_germortar_gren")
				ammoSmoke      = get_cvar_num("dod_smoke_germortar")
				ammoChannel   = AMMO_ROCKET
				ammoWeapon    = DODW_BAZOOKA
				ammoWpnName   = "weapon_bazooka"
			}
		}
	}
	
	// Store the retrieved data in an array
	ammoStock[0] = ammoPrimary
	ammoStock[1] = ammoSecondary
	ammoStock[2] = ammoMelee
	ammoStock[3] = ammoGren
	ammoStock[4] = ammoSmoke
	ammoStock[5] = ammoChannel
	ammoStock[6] = ammoWeapon
	
	// Don't return the array - arrays are passed through reference
	return PLUGIN_CONTINUE
}
