#include <amxmodx>
#include <amxmisc>
#include <dodfun>
#include <dodx>
#include <fakemeta>
#include <hamsandwich>

#pragma semicolon 1

#define PLUGIN "DOD Rocket Class"
#define VERSION "2.0"
#define AUTHOR "29th ID"

#define OFFSET_WPN_ID 	91
#define OFFSET_LINUX	4
#define MAX_CARBINE  	45
#define MAX_MP40	90
#define MAX_STEN	90

// Global variables
new g_msgWeaponList, g_msgAmmoX, g_cvarEnabled;

// String Declarations
enum classnames {
	weapon_,
	colt,
	luger,
	webley,
	m1carbine,
	mp40,
	sten
};
new const g_classnames[ classnames ][ ] = {
	"weapon_",
	"weapon_colt",
	"weapon_luger",
	"weapon_webley",
	"weapon_m1carbine",
	"weapon_mp40",
	"weapon_sten"
};

// For WeaponList
enum { melee, secondary, primary }
enum tech_weapons { TECH_M1CARBINE, TECH_MP40, TECH_STEN };
enum tech_categories { t_wpnid, t_ammotype, t_maxammo, t_clip, t_flags };
new g_wpncfg [ tech_weapons ][ tech_categories ] = 
{
	{ DODW_M1_CARBINE,	AMMO_ALTRIFLE, 	MAX_CARBINE,	15,	128 },
	{ DODW_MP40, 		AMMO_SMG, 		MAX_MP40, 	30,	130 },
	{ DODW_STEN, 		AMMO_SMG, 		MAX_STEN, 	30,	128 }
};

public plugin_init() {
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	g_msgWeaponList	= get_user_msgid( "WeaponList" );
	g_msgAmmoX	= get_user_msgid( "AmmoX" );
	g_cvarEnabled = register_cvar( "dod_rocketclass", "1" );
	register_cvar( "dod_rocketclass_stats", "2.0", FCVAR_SERVER|FCVAR_SPONLY );
}

public dod_client_spawn( id ) {
	if( get_pcvar_num(g_cvarEnabled) )
	{
		set_task( Float:0.1, "dod_client_spawn_delayed", id );
	}
}

public dod_client_spawn_delayed( id ) {
	switch( dod_get_user_class(id) )
	{
		case DODC_BAZOOKA:
		{
			ham_strip_weapon( id, g_classnames[colt] );
			ham_give_weapon( id, g_classnames[m1carbine] );
			limit_ammo( id, TECH_M1CARBINE );
		}
		case DODC_PANZERJAGER:
		{
			ham_strip_weapon( id, g_classnames[luger] );
			ham_give_weapon( id, g_classnames[mp40] );
			limit_ammo( id, TECH_MP40 );
		}
		case DODC_PIAT:
		{
			ham_strip_weapon( id, g_classnames[webley] );
			ham_give_weapon( id, g_classnames[sten] );
			limit_ammo( id, TECH_STEN );
		}
	}
	return PLUGIN_CONTINUE;
}

public dod_client_changeclass( id, class, oldclass ) {
	if( get_pcvar_num(g_cvarEnabled) )
	{
		switch( class )
		{
			case DODC_BAZOOKA: 		set_slot( id, TECH_M1CARBINE, secondary );
			case DODC_PANZERJAGER:	set_slot( id, TECH_MP40, secondary );
			case DODC_PIAT:			set_slot( id, TECH_STEN, secondary );
		}
		switch( oldclass )
		{
			case DODC_BAZOOKA: 		set_slot( id, TECH_M1CARBINE, primary );
			case DODC_PANZERJAGER:	set_slot( id, TECH_MP40, primary );
			case DODC_PIAT:			set_slot( id, TECH_STEN, primary );
		}
	}
}

public set_slot( id, wpn, slot ) {
	message_begin( MSG_ONE, g_msgWeaponList, {0,0,0}, id );
	write_byte( g_wpncfg[tech_weapons:wpn][t_ammotype] ); // Ammo 1 Type
	write_byte( g_wpncfg[tech_weapons:wpn][t_maxammo] ); // Ammo 1 Max
	write_byte( -1 ); // Ammo 2 Type
	write_byte( -1 ); // Ammo 2 Max
	write_byte( slot ); // Slot (Starts at 0)
	write_byte( 1 ); // Bucket (Starts at 0)
	write_short(g_wpncfg[tech_weapons:wpn][t_wpnid] ); // Weapon ID
	write_byte( g_wpncfg[tech_weapons:wpn][t_flags] ); // Flags
	write_byte( g_wpncfg[tech_weapons:wpn][t_clip] ); // Clip Ammo
	message_end();
	//client_print( id, print_chat, "[Slot] Ammo1:%i, Max:%i, slot:%i, Wpnid:%i, Flags:%i, Clip:%i", g_wpncfg[tech_weapons:wpn][t_ammotype], g_wpncfg[tech_weapons:wpn][t_maxammo], slot, g_wpncfg[tech_weapons:wpn][t_wpnid], g_wpncfg[tech_weapons:wpn][t_flags], g_wpncfg[tech_weapons:wpn][t_clip] );
}

// Stock written by XxAvalanchexX
// gives a player a weapon efficiently
stock ham_give_weapon(id,const weapon[]) {
	if(!equal(weapon,g_classnames[weapon_],7)) return 0;
	
	new wEnt = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,weapon));
	if(!pev_valid(wEnt)) return 0;
	    
	set_pev(wEnt,pev_spawnflags,SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn,wEnt);
	    
	if(!ExecuteHamB(Ham_AddPlayerItem,id,any:wEnt) || !ExecuteHamB(Ham_Item_AttachToPlayer,wEnt,any:id))
	{
		if(pev_valid(wEnt)) set_pev(wEnt,pev_flags,pev(wEnt,pev_flags) & FL_KILLME);
		return 0;
	}
	  
	return 1;
}

// Stock written by XxAvalanchexX
// takes a weapon from a player efficiently
stock ham_strip_weapon(id,const weapon[]) {
	if(!equal(weapon,g_classnames[weapon_],7)) return 0;
	
	new wEnt = fm_find_ent_by_owner(1,weapon,id);
	if(!wEnt) return 0;

	new wId = dod_get_weapon_id(wEnt);
	if(!wId) return 0;
	    
	new dummy, weapon = get_user_weapon(id,dummy,dummy);
	if(weapon == wId) ExecuteHamB(Ham_Weapon_RetireWeapon,wEnt);
	    
	if(!ExecuteHamB(Ham_RemovePlayerItem,id,any:wEnt)) return 0;
	ExecuteHamB(Ham_Item_Kill,wEnt);
	
	set_pev(id,pev_weapons,pev(id,pev_weapons) & ~(1<<wId));
	return 1;
}

stock limit_ammo( id, wpn ) {
	new wpnid	= g_wpncfg[ tech_weapons:wpn ][ t_wpnid ];
	new channel	= g_wpncfg[ tech_weapons:wpn ][ t_ammotype ];
	new ammo     	= g_wpncfg[ tech_weapons:wpn ][ t_maxammo  ];
	
	dod_set_user_ammo( id, wpnid, ammo );
	
	message_begin( MSG_ONE, g_msgAmmoX, {0,0,0}, id );
	write_byte( channel );
	write_byte( ammo );
	message_end();
}

stock dod_get_weapon_id( wpnent ) return get_pdata_int( wpnent, OFFSET_WPN_ID, OFFSET_LINUX );

// From FM Utilities...pasted in here for people who can't figure out how to compile with the inc...
stock fm_find_ent_by_owner(index, const classname[], owner, jghgtype = 0) {
	new strtype[11] = "classname", ent = index;
	switch (jghgtype) {
		case 1: strtype = "target";
		case 2: strtype = "targetname";
	}

	while ((ent = engfunc(EngFunc_FindEntityByString, ent, strtype, classname)) && pev(ent, pev_owner) != owner) {}

	return ent;
}
