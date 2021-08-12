//					!Unlimited Stamina!
//
//	Alright this is basically not my plugin. I came up with the idea and tried to code it
//	but was unsuccessful (since i have no coding knowledge or experience in amxx coding...
//	or any other coding for that matter...except html and asp...but that doesn't count,
//	ANYWAY), so Hell Pheonix told me what was wrong with it, and did up this code, so most
//	of the credit should go to him. THANKS HELL PHEONIX!
//	
//	ok so the commands:
//	
//	dod_stamina 1 <gives everybody unlimited stamina>
//	dod_stamina 0 <takes away their unlimited stamina until they die>
//
//
//	Credits:
//
//	Hell Pheonix
//	Mr.Shadow (I probably shouldn't even be putting myself in here)

#include <amxmodx>
#include <amxmisc>
#include <dodfun>
 
#define PLUGIN "DoD Unlimited Stamina"
#define VERSION "1.0"
#define AUTHOR "Mr.Shadow"
new g_stamina
new g_set[33]
 
public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR)
    g_stamina = register_cvar("dod_stamina","0")
    register_event("ResetHUD","give_stamina","be")
    register_clcmd("fullupdate", "clcmd_fullupdate")
}
 
public give_stamina(id){
    if(get_pcvar_num(g_stamina) && !g_set[id]){
        dod_set_stamina(id,STAMINA_SET,100,100)
        g_set[id] = 1
    }else if (!get_pcvar_num(g_stamina) && g_set[id]){
        dod_set_stamina(id,STAMINA_SET,0,100)
        g_set[id] = 0
    }
    return PLUGIN_HANDLED
}
 
public clcmd_fullupdate() {
    return PLUGIN_HANDLED
}