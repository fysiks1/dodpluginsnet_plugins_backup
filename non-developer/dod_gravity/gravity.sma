   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //DOD_GRAVITY//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //by Blobby///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //Make sure you define you admin level where this line is shown register_concmd("amx_gravity","admin_gravity",ADMIN_LEVEL_H,"<
   //gravity >") where admin_level_h is to suit your settings////////////////////////////////////////////////////////////////////////
   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //The commands for this plugin are as follows/////////////////////////////////////////////////////////////////////////////////
   //To change the gravity of your server in console type sv_gravity 800 is standard settings and 100 is fun gravity////////////
   //you can choose any setting or gravity from 100 to 1000////////////////////////////////////////////////////////////////////////////////////////////////////////
   //There are also 2 chat commands for players to be able to find out what gravity is set to the command for this is /gravity in ither team chat or player chat//
   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   #include <amxmodx>
      
   #define PLUGIN "dod_gravity"
   #define VERSION "1.0"
   #define AUTHOR "Blobby"
   
   public admin_gravity(id,level){
       if (!(get_user_flags(id)&level)){
               console_print(id,"You have no access to that command sorry.")
               return PLUGIN_HANDLED
           }
       if (read_argc() < 2){
               new gravity_cvar = get_cvar_num("sv_gravity")
               console_print(id,"^"sv_gravity^"is^"%i^"",gravity_cvar)
               return PLUGIN_HANDLED
       }
       new gravity[6]
       read_argv(1,gravity,6)
       server_cmd("sv_gravity %s",gravity)
       console_print(id,"Gravity has been set to %s",gravity)
       return PLUGIN_HANDLED
   }
   public check_gravity(id){
       new gravity = get_cvar_num("sv_gravity")
       client_print(id,print_chat,"The gravity for this server is set to %i",gravity)
       return PLUGIN_HANDLED
   }
   public plugin_init(){
       register_plugin("dod_gravity","1.0","Blobby")
       register_cvar("dod_gravity", "Version 1.0 By Blobby", FCVAR_SERVER|FCVAR_SPONLY)
       register_concmd("amx_gravity","admin_gravity",ADMIN_LEVEL_H,"<gravity >")
       register_clcmd("say /gravity","check_gravity")
       register_clcmd("say_team /gravity","check_gravity")
       return PLUGIN_CONTINUE
   }
