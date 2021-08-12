
#include <amxmodx>
#include <fun>
#include <engine>

#define PLUGIN "DoD Checkpoint"
#define VERSION "1.2"
#define AUTHOR "h0_noMan"

new checkpoint[33][3]
new language = 2 		// FR=1    EN=2

//-------------------------------------------------------//
//--------------------- plugin_init ---------------------//
//                                                       //
//-------------------------------------------------------//
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("add_checkpoint", "dod_add_checkpoint", -1, "Create a checkpoint")
	register_clcmd("go_checkpoint", "dod_go_checkpoint", -1, "Go to the last checkpoint saved")
	register_cvar("dod_checkpoint", "1")
	register_event("TextMsg","join","a","1=3","2=#game_joined_team")
}

//--------------------------------------------------------------//
//--------------------- dod_add_checkpoint ---------------------//
//                                                              //
// A player can save his position to be teleported to the saved //
// position later                                               //
//                                                              //
//--------------------------------------------------------------//
public dod_add_checkpoint(id)
{

	if(get_cvar_num("dod_checkpoint")==0)
	{
		switch(language)
		{
			case 1 : client_print(id,print_chat,"[DoD Checkpoint] n'est pas active.")
			case 2 : client_print(id,print_chat,"[DoD Checkpoint] is not enabled.")
		}
		
		return PLUGIN_HANDLED 
	}
    
	if(is_user_alive(id))
	{	
		
		new temp[3]
		get_user_origin(id, temp, 1)	
		
		if(dod_stucked(id)==-1)
		{
			switch(language)
			{
				case 1 : client_print(0,print_chat,"[DoD Checkpoint] Point de sauvegarde corrompu.")
				case 2 : client_print(0,print_chat,"[DoD Checkpoint] Checkpoint seems corrupted.")
			}
			
		}else{

			checkpoint[id] = temp
			
			new name[32]
			get_user_name(id,name,31)
        
			switch(language)
			{
				case 1 : client_print(0,print_chat,"[DoD Checkpoint] %s a sauvegarde sa position.",name)
				case 2 : client_print(0,print_chat,"[DoD Checkpoint] %s has saved his location.",name)
			}
		}
	   
	}else{
		switch(language)
		{
			case 1 : client_print(id,print_chat,"[DoD Checkpoint] Vous n'etes pas vivant.")
			case 2 : client_print(id,print_chat,"[DoD Checkpoint] Your are dead.")
		}
	}
    
	return PLUGIN_HANDLED    
}

//---------------------------------------------------------//
//------------------- dod_go_checkpoint -------------------//
//                                                         //
// When a player has saved a position he can be teleported //
// to his last position saved                              //
//                                                         //
//---------------------------------------------------------//
public dod_go_checkpoint(id)
{

	if(get_cvar_num("dod_checkpoint")==0)
	{
		switch(language)
		{
			case 1 : client_print(id,print_chat,"[DoD Checkpoint] n'est pas active.")
			case 2 : client_print(id,print_chat,"[DoD Checkpoint] is not enabled.")
		}
		
		return PLUGIN_HANDLED 
	}
	
    
	if(is_user_alive(id))
	{

		if(checkpoint[id][0] && checkpoint[id][1] && checkpoint[id][2])
		{		
			new name[32]
			get_user_name(id,name,31)        
			set_user_origin(id, checkpoint[id])
			
			switch(language)
			{
				case 1 : client_print(0,print_chat,"[DoD Checkpoint] %s retourne a sa position sauvegardee.",name)
				case 2 : client_print(0,print_chat,"[DoD Checkpoint] %s return to his last saved location.",name)
			}
			
		}else{
			switch(language)
			{
				case 1 : client_print(id,print_chat,"[DoD Checkpoint] Aucune sauvegarde de position effectuee.")
				case 2 : client_print(id,print_chat,"[DoD Checkpoint] No checkpoint saved.")
			}
		}
	}
	
	return PLUGIN_HANDLED
}

//---------------------------------------------------------//
//---------------------- dod_stucked ----------------------//
//                                                         //
// Test if a player is stucked in a wall or other         //
//                                                         //
//---------------------------------------------------------//
public dod_stucked(id)
{
	new Float:temp[3]
	IVecFVec( checkpoint[id], temp )
	
	if(trace_hull(temp,1,1,1)==0)
	{
		return 1	// OK
	}
	
	return -1	// Stucked

}

//---------------------------------------------------//
//----------------------- join ----------------------//
//                                                   //
// Reset the checkpoint saved when a new player join //
//                                                   //
//---------------------------------------------------//
public join()
{
	new name[32]
	read_data(3,name,31)
	new id = get_user_index(name)
    
	checkpoint[id][0] = 0
	checkpoint[id][1] = 0
	checkpoint[id][2] = 0
    
	return PLUGIN_HANDLED
}
