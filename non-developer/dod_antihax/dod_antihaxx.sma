/*=================================================================================================
DoD Antihax v1.11

===========================
Features & Notes
===========================
- Check Player's Config for Bad CVARs

- Prevent Players to use modified models or WAD

- AutoUpdate Data Files (CVARs, General Models and Map Dependencies)

- Warn admins when a new version of the plugin is available

- Multilingual

===========================
Changelog
===========================
Version 1.01 :
- Fixed an issue with query_client_cvar() returning a value of "Bad cvar request"

Version 1.02 :
- Plugin will now ban player after 3 warning (Kick was only in Beta)
- Plugin will now display the correct default value for a CVAR when a detection is displayed
- Plugin will now load CVARs even if the "antihax_cvars" is 0 (but not detect, it will detect only if the cvar is 1)

Version 1.03 :
- Use of PCVARs

Version 1.10 :
- Improving sending parameters with set_task()
- Fixing a "index out of bounds" with the number of players
- Delay for displaying Informations to admins increased by 5 seconds

Version 1.11 :
- Improving the construction of the log filename
- Fixed a "index out of bounds" with the number of CVARs


===========================
CVARs
===========================

antihax_banlength (Default: 1440)
- When a player is detected with Bad CVARs 3 times he will be banned for this time (in seconds)

antihax_cvars | 0 = off | 1 = on (Default: 1)
- Disable or Enable the scanning Player's Config function

===========================
Required Modules
===========================
- <sockets>

===========================
Installation
===========================
- Compile the .sma file | An online compiler can be found here:
  http:www.amxmodx.org/webcompiler.cgi
- Copy the compiled .amxx file into your addons\amxmodx\plugins folder
- Add the name of the compiled .amxx to the bottom of your addons\amxmodx\configs\plugins.ini
- Copy the .txt file to your addons\amxmodx\data\lang folder
- Copy all .dat file to your addons\amxmodx\configs\dod_antihax folder
- Change the map or restart your server to start using the plugin!

===========================
Support
===========================
Visit the AMXMODX Plugins section of the forums @ 
http://www.dodplugins.net

=================================================================================================*/ 

#include <amxmisc>
#include <sockets>

#define PLUGIN_NAME			"DoD AntiHax"
#define PLUGIN_VERSION 		"1.11"
#define PLUGIN_AUTHOR  		"h0_noMan"

#define CFG_DIRECTORY		"dod_antihax"				// Antihax Config Directory
#define SERVER_HOST			"dod.antihax.free.fr"		// Antihax Server Host
#define SERVER_DIRECTORY	"data"						// Antihax Server Directory

#define TASK_ID     		7563							// Task ID
#define TASK_MIN   			5.0							// (Float) Minimum Number of time between 2 scans
#define TASK_LOOP			8.0							// (Float) Number of time a player is scanned in the entire round
#define TASK_RANDOM			2.0							// Random Time added to each loop -TASK_RANDOM to +TASK_RANDOM
#define TASK_OFFSET1		34
#define TASK_OFFSET2		68

#define DATAFILE_GENMODEL	"data_models"				// Filename of Antihax General Models File
#define DATAFILE_CVARS		"data_cvars"				// Filename of Antihax CVARs File

#define MENU_TITLE 			"\yDoD Antihax :^n"			// Title of Detection Menu

#define MAX_WARNS		3								// Maximum number of warnings
#define MAX_CVARS		32								// Maximum number of CVARs
#define MAX_PLAYERS		33								// Maximum number of Players

#define ERROR			-1
#define NOERROR			1

#define FILE_DIFFERENT	0
#define FILE_SAME		1

#define MB_EQUAL		0								// Must be Equal
#define MB_NOTEQUAL		1								// Must be Not Equal
#define MB_SUPERIOR		2								// Must be Superior
#define MB_INFERIOR		3								// Must be Inferior
#define MB_BOTH			4								// Must be Both

// =================================================================================================
// Global Variables
// =================================================================================================

// Antihax Custom States
new bool:g_cvarsFileLoaded					// CVARs File is loaded or not
new bool:g_genModelsFileLoaded				// General Models File is loaded or not
new bool:g_mapModelsFileLoaded				// Map Dependencies File is loaded or not
new bool:g_antihaxServerReachable			// Antihax Server is reachable or not
new bool:g_pluginUpdated					// Plugin is up to date or not
new bool:g_controlCvars						// Plugin control CVARs or not

// Static Variables
new g_antihaxCfgDirectory[64]				// Antihax CFG Directory
new g_currentMap[32]						// Current Map
new g_logFilename[32]						// Log Filename
new g_maxPlayers							// Server Max Players
new g_port									// Server Port
new g_banLength								// Ban Length

// Scanning Variables
new g_playerToScan							// ID of actual player that is scanned
new g_totalControlled						// Number of player that have been controlled

// Task Step
new Float:g_taskStep						// Task Loop Step
	
// SCAN TICKET Array
new bool:g_ticket[MAX_PLAYERS]				// Ticket Free or not (one for each player)
new bool:g_scanned[MAX_PLAYERS]				// Player Scanned or not

// CVARs Array
new g_cvars[MAX_CVARS][32]					// CVAR Name
new g_value[MAX_CVARS][10]					// CVAR Control Value
new g_default[MAX_CVARS][10]				// CVAR Default Value
new g_type[MAX_CVARS]						// CVAR Type (INT or FLOAT)
new g_limit[MAX_CVARS]						// CVAR Control Limiter ( = ! < > )
new g_totalCvars							// CVAR Count

// Detection Array
new g_detections[MAX_PLAYERS][MAX_CVARS]	// CVARs Detected as bad on player
new g_warns[MAX_PLAYERS]					// Number of warns for player

// PCVARs
new pcvar_banlength
new pcvar_cvars

// =================================================================================================
// Plugin Init
// =================================================================================================

public plugin_init()
{
	// Plugin Registration
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)	
	
	// Menu Registration
	register_menucmd(register_menuid(MENU_TITLE), 1023, "control_menuChoice")
	
	// Register Dictionnary
	register_dictionary("dod_antihax.txt")
	
	// Register CVAR
	pcvar_banlength = register_cvar("antihax_banlength", "1440")			// Ban length after MAX_WARNS warning
	pcvar_cvars     = register_cvar("antihax_cvars", "1")					// 1 = Plugin will control CVARs // 0 = Plugin wont control CVARs
	
	// Control CVAR
	cvar_control()
	
	// Cleaning Array
	clean_scannedArray(true)	
	
	// Calculating Task Step
	set_task(1.0, "get_taskStep")
	
	// Formatting Log Filename
	get_time("antihax_%Y%m%d.log", g_logFilename, 31)
		
	// Checking & Loading <DATAFILE_CVARS>.DAT	
	if(g_antihaxServerReachable)
		checking_datFile(DATAFILE_CVARS)
	load_cvarsFile(DATAFILE_CVARS)
}

// =================================================================================================
// Calculate Loop Task Step
// =================================================================================================

public get_taskStep()
{
	// Retrieving Max Players & Timeleft	
	g_maxPlayers = get_maxplayers()
	
	// Calculating Task Step
	g_taskStep = floatdiv(float(get_timeleft()), TASK_LOOP) 
	g_taskStep = floatdiv(g_taskStep, float(g_maxPlayers))
	if(g_taskStep < TASK_MIN)
		g_taskStep = TASK_MIN	
}

// =================================================================================================
// Plugin Precache
// =================================================================================================

public plugin_precache()
{	
	// Initializing Antihax Custom States
	g_cvarsFileLoaded        = false
	g_genModelsFileLoaded    = false
	g_mapModelsFileLoaded    = false
	
	// Retrive Antihax Config Directory && Current Mapname
	get_antihaxConfigDirectory()
	get_mapname(g_currentMap, 31)
	
	// Checking Plugin Version
	check_pluginVersion()
		
	// Checking & Loading <DATAFILE_GENMODEL>.DAT
	if(g_antihaxServerReachable)
		checking_datFile(DATAFILE_GENMODEL)
	load_modelsFile(DATAFILE_GENMODEL)
	
	// Checking & Loading <MAPNAME>.DAT
	if(g_antihaxServerReachable)
		checking_datFile(g_currentMap)
	load_modelsFile(g_currentMap)
	
	return PLUGIN_CONTINUE
}
	
// =================================================================================================
// Called when a player join the server
// =================================================================================================

public client_putinserver(id)
{
	// Not a BOT or HLTV
	if(is_user_bot(id) || is_user_hltv(id))
		return PLUGIN_CONTINUE
		
	// Display to Admin Error Message
	if(is_user_admin(id))
		if(!g_pluginUpdated || !g_cvarsFileLoaded || !g_genModelsFileLoaded || !g_mapModelsFileLoaded)
			set_task(25.0 , "display_errorMessage", (TASK_ID + id + TASK_OFFSET1)) 
		
	// Launching Manage Ticket Task
	launch_manageTicket()
	
	// Clean Player Data
	clean_playerData(id)
	
	return PLUGIN_CONTINUE
}

// =================================================================================================
// Clean/Reset data for a player
// =================================================================================================

public clean_playerData(id)
{
	// Cleaning Detection
	for(new i=0; i<MAX_CVARS; i++)
		g_detections[id][i] = false
		
	// Cleaning Warns
	g_warns[id] = 0
	
	// Giving him a free SCAN Ticket
	g_ticket[id] = true
}

// =================================================================================================
// Called when a player leave the server
// =================================================================================================

public client_disconnect(id)
{
	// Set the client TICKET Free
	g_ticket[id] = false
	
	// IF   there is no player on the server
	// THEN it stop the MANAGE TICKET task
	if(!get_playersnum(1) && task_exists(TASK_ID))
		remove_task(TASK_ID)
}

// =================================================================================================
// Display Errors/Informations messages to an admin
// =================================================================================================

public display_errorMessage(func_id)
{
	// Retrieving ID from Parameters
	new id = func_id - TASK_ID - TASK_OFFSET1
	
	// Formatting HUD Message
	set_hudmessage(200, 20, 20, 0.0, 0.60, 0, 0.0, 12.0, 0.1, 0.2, 2 )
	
	// Message
	new message[256]
	format(message, 255, " [DoD Antihax] Informations :^r^n")
	
	if(!g_pluginUpdated)
		format(message, 255, "%s  - %L^r^n", message, id, "NEW_VERSION")	
	if(!g_cvarsFileLoaded)
		format(message, 255, "%s  - %L^r^n", message, id, "CVAR_NOTLOADED")
	if(!g_genModelsFileLoaded)
		format(message, 255, "%s  - %L^r^n", message, id, "GMDL_NOTLOADED")
	if(!g_mapModelsFileLoaded)
		format(message, 255, "%s  - %L", message, id, "MAPD_NOTLOADED", g_currentMap)
		
	// Displaying Message
	show_hudmessage(id, message)
}

// =================================================================================================
// Function that Control,protect and launch the manageTicket()
// =================================================================================================

public launch_manageTicket()
{	
	// Test if the plugin will control CVARs
	g_controlCvars = (get_pcvar_num(pcvar_cvars) > 0) ? true : false	
	
	// Lauching the Manage Ticket Task
	// IF the CVARs file is loaded
	// IF the task is not already launched
	if(g_cvarsFileLoaded && g_controlCvars &&!task_exists(TASK_ID))
	{
		new Float:loop = g_taskStep + random_float(-TASK_RANDOM, TASK_RANDOM) 
		if(loop < TASK_MIN)
			loop = TASK_MIN
		set_task(loop, "manage_ticket", TASK_ID, "", 0, "b")
	}
}

// =================================================================================================
// Function that manage the cvar control of players
// =================================================================================================

public manage_ticket()
{	
	// Finding a player to Scan
	for(new i=0 ; i < MAX_PLAYERS ; i++)
	{	
		if(g_ticket[i] && !g_scanned[i])
		{		
			g_playerToScan = i
			g_totalControlled++
			set_task(0.1, "scan_playerConfig")
			return PLUGIN_CONTINUE
		}
	}
	
	// Calculating Extra Time
	new Float:extra_time = floatmul(float(g_maxPlayers - g_totalControlled), g_taskStep)
	
	// Cleaning Scanned Array
	clean_scannedArray(false)
			
	// Re-lauching Manage Ticket
	set_task(extra_time, "launch_manageTicket")
	remove_task(TASK_ID)	

	return PLUGIN_CONTINUE
}

// =================================================================================================
// Function that control the plugin CVARs
// =================================================================================================

public cvar_control()
{
	// Ban Length must be between 60 (1 Hour) and 10080 (1 Week)
	g_banLength = get_pcvar_num(pcvar_banlength)
	if(g_banLength < 60)
		g_banLength = 60
	else if(g_banLength > 10080)
		g_banLength = 10080
		
	// Test if the plugin will control CVARs
	g_controlCvars = (get_pcvar_num(pcvar_cvars) > 0) ? true : false	
}

// =================================================================================================
// Function that clean/erase data of a player
// =================================================================================================

public clean_scannedArray(bool:init)
{
	
	// Cleaning Scanned Array
	if(init) {
		for(new i=0 ; i < MAX_PLAYERS ; i++) {
			g_ticket[i] = false
			g_scanned[i] = false
		}
	} else {
		for(new i=0 ; i < MAX_PLAYERS ; i++)
			g_scanned[i] = false
	}
		
	g_totalControlled = 0
}

// =================================================================================================
// Function that query a player for Controlled CVARs
// =================================================================================================

public scan_playerConfig()
{
	// Retrieving the ID
	new id = g_playerToScan
	
	// Test if the player is connected
	if(!is_user_connected(id))
		return ERROR
	
	// Querying Player for all CVARs
	for(new i=0; i < g_totalCvars; i++)
	{
		new param[2]
		param[0] = i
		query_client_cvar(id, g_cvars[i], "check_playerConfig", 1, param)
	}
		
	// Player has been scanned
	g_scanned[id] = true
	
	return NOERROR
}

// =================================================================================================
// Function that control the value of Controlled CVARs
// =================================================================================================

public check_playerConfig(id, const cvar[], const value[], const param[])
{	
	// Retrieve index of CVARs Array
	new i = param[0]
	
	// Bad CVAR request
	if(strcmp(value, "Bad CVAR request") == 0)
		return ERROR
	
	if(g_type[i] == 0)
	{
		// Retrieving Default INT Value
		new cvar_int    = str_to_num(value)
		new int_value   = str_to_num(g_value[i])
		new int_default = str_to_num(g_default[i])	

		
		// If CVAR is detected as BAD
		if( (g_limit[i] == MB_EQUAL    && cvar_int != int_value) ||
			(g_limit[i] == MB_NOTEQUAL && cvar_int == int_value) ||
			(g_limit[i] == MB_SUPERIOR && cvar_int <  int_value) ||
			(g_limit[i] == MB_INFERIOR && cvar_int >  int_value) ||
			(g_limit[i] == MB_BOTH     && cvar_int != int_value && cvar_int != int_default))
		{			
			// Adding Detection
			g_detections[id][i] = true
			
			// Displaying Bad CVAR Detection
			display_detection(id, i, value)
			
		 }else {
		
			// Adding Detection
			g_detections[id][i] = false
		}
		
	} else {	
		
		// Retrieving Default FLOAT Value
		new Float:cvar_float    = str_to_float(value)
		new Float:float_value	= str_to_float(g_value[i])
		new Float:float_default	= str_to_float(g_default[i])

		// If CVAR is detected as BAD
		if( (g_limit[i] == MB_EQUAL    && cvar_float != float_value) ||
			(g_limit[i] == MB_NOTEQUAL && cvar_float == float_value) ||
			(g_limit[i] == MB_SUPERIOR && cvar_float <  float_value) ||
			(g_limit[i] == MB_INFERIOR && cvar_float >  float_value) ||
			(g_limit[i] == MB_BOTH     && cvar_float != float_value && cvar_float != float_default))
		{			
			// Adding Detection
			g_detections[id][i] = true
						
			// Displaying Bad CVAR Detection
			display_detection(id, i, value)
			
		} else {
		
			// Adding Detection
			g_detections[id][i] = false
			
		}
	}
	
	return NOERROR
}

// =================================================================================================
// Function that display detections
// =================================================================================================

public display_detection(id, cvar_id, const value[])
{
	// Test if the user is connected
	if(!is_user_connected(id))
		return ERROR
		
	// Retrieve Player Name
	new name[32], steamid[35]
	get_user_name(id, name, 31) 
	get_user_authid(id, steamid, 34) 
	
	// Display Bad CVAR Menu Detection to Detected Player
	if(!task_exists(TASK_ID + id + TASK_OFFSET2))
		set_task(2.0, "display_menuDetection", (TASK_ID + id + TASK_OFFSET2))
	
	// Displaying Bad CVAR Detection to All
	client_print(0, print_chat, "[DoD Antihax] %s <%s> %L %s=%s (%s)", name, steamid, LANG_PLAYER, "BAD_CVAR", g_cvars[cvar_id], value, g_default[cvar_id])
	
	// Log to File
	log_to_file(g_logFilename, "<%s> ^"%s^" Bad CVAR %s=%s (%s)", steamid, name, g_cvars[cvar_id], value, g_default[cvar_id]) 
	
	// Send CVAR Detection to Antihax Server
	//new buffer[8], url[256]
	//format(url, 255, "bad_cvar.php?port=%d&steamid=%s&nick=%s&cvar=%s&value=%s", SERVER_DIRECTORY, g_port, steamid, name, g_cvars[cvar_id], value)
	//get_onlineData(url, buffer, 7)
	
	return NOERROR
}

// =================================================================================================
// Function that show a Bad CVARs Menu to a player
// =================================================================================================

public display_menuDetection(func_id)
{
	// Retrieving ID
	new id = func_id - TASK_ID - TASK_OFFSET2
	new total = 0
	
	// Adding one more Warn to Player
	g_warns[id]++	
	
	// Controlling Max Warning
	if(g_warns[id] > MAX_WARNS)
	{		
		do_kickBan(id)
		return PLUGIN_CONTINUE
	}
	
	// Couting how many CVARs are Bad
	for(new i=0; i<MAX_CVARS; i++)
		total += (g_detections[id][i]) ? 1 : 0
	
	// Menu Body
	new menuBody[512];
	
	// Content of the Menu
	format(menuBody, 511, "%s%L", MENU_TITLE, id, "MENU_CONTENT", g_warns[id], MAX_WARNS, total, id, "MENU_1", id, "MENU_2", id, "MENU_3")
	
	// Display Menu
	show_menu(id, (MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_3), menuBody, -1)
	
	return PLUGIN_CONTINUE
}

// =================================================================================================
// Function that do Kick/Ban Action after MAX_WARNS warnings
// =================================================================================================

public do_kickBan(id)
{
	new steamid[35]
	get_user_authid(id, steamid, 34) 
	server_cmd("kick #%d ^"Use of forbidden CVARs (%s min)^";wait;banid ^"%s^" ^"%s^";wait;writeid", get_user_userid(id), g_banLength, g_banLength, steamid)
}

// =================================================================================================
// Function that control the key pressed in the Bad CVARs Menu
// =================================================================================================

public control_menuChoice(id, key)
{
	if(key == 0)
		fix_playerConfig(id)
	else if(key == 2)
		server_cmd("kick #%d", get_user_userid(id))
}

// =================================================================================================
// Function that fix the Player's Config
// =================================================================================================

public fix_playerConfig(id)
{
	// Fix all Bad CVARs Detection
	for(new i=0; i < MAX_CVARS; i++)
		if(g_detections[id][i])
			client_cmd(id, "%s %s", g_cvars[i], g_default[i]) 
}

// =================================================================================================
// Function called when a player join the server with a modified file
// =================================================================================================

public inconsistent_file(id, const filename[], reason[64])
{
	// Retrieve Nickname & STEAMID
	new name[32], steamid[35]
	get_user_name(id, name, 31) 
	get_user_authid(id, steamid, 34) 
	
	// Displaying Bad File Detection to All
	client_print(0, print_chat, "[DoD Antihax] %s <%s> %L : %s", name, steamid, id, "BAD_FILE", filename)
	
	// -------------------------------------
	// Send Bad File Detection to Antihax Server
	//new buffer[8], url[256]
	//format(url, 255, "bad_file.php?port=%d&steamid=%s&nick=%s&file=%s", g_port, steamid, name, filename)
	//get_onlineData(url, buffer, 7)	
	// -------------------------------------
	
	// Log to File
	log_to_file(g_logFilename, "<%s> %s Bad File %s", steamid, name, filename) 
}

// =================================================================================================
// Function that retrieve the Antihax Config Directory
// =================================================================================================

public get_antihaxConfigDirectory()
{
	// Retrive AMX Config Directory
	new amxConfigDirectory[64]
	get_configsdir(amxConfigDirectory, 63)
	
	// Building Antihax Config Directory
	format(g_antihaxCfgDirectory, 63, "%s/%s", amxConfigDirectory, CFG_DIRECTORY)
	
	// Testing if the Antihax Config Directory Exists
	if(dir_exists(g_antihaxCfgDirectory) == 0)
	{
		if(mkdir(g_antihaxCfgDirectory) != 0)
			log_amx("Error when creating DoD Antihax Config Directory %s", g_antihaxCfgDirectory)
		else
			log_amx("DoD Antihax Config Directory has been successfully created")
	}
}

// =================================================================================================
// Function that compare MD5 of .DAT file to the one on the Antihax Server
// =================================================================================================

public checking_datFile(const filename[])
{
	// Complete Local File Path
	new completeFilePath[64]	
	format(completeFilePath, 63, "%s/%s.dat", g_antihaxCfgDirectory, filename)
	
	// If the Local File Exists
	if(file_exists(completeFilePath))
	{
		// Retrieving MD5 of Local File
		new md5[34]
		md5_file(completeFilePath, md5) 
		
		// Comparing MD5 of Local File to MD5 of Antihax Server File
		if(check_fileOnline(filename, md5) == FILE_DIFFERENT)
		{			
			// Deleting Corrupted or non-updated Local File
			unlink(completeFilePath)
			
			// Downloading Antihax Server File
			get_onlineFile(filename)
		}
	} else {
		// File is missing
		log_amx("Antihax File %s is missing - Starting Download", completeFilePath)
		
		// Downloading Antihax Server File
		get_onlineFile(filename)
	}
}

// =================================================================================================
// Function that load in Array the Controlled CVARs in the specified file
// =================================================================================================

public load_cvarsFile(const filename[])
{	
	// Complete Path
	new completeCvarFilePath[64]
	format(completeCvarFilePath, 63, "%s/%s.dat", g_antihaxCfgDirectory, filename)
	
	// File Missing
	if(!file_exists(completeCvarFilePath))
	{
		log_amx("DoD Antihax Data File %s.dat is missing", filename)
		return ERROR
	}
	
	// Opening File
	new fileHandle = fopen(completeCvarFilePath, "r")
	
	// Error while opening File
	if(!fileHandle)
	{
		log_amx("Error while opening DoD Antihax Data File %s.dat", filename)
		return ERROR
	}
	
	// Reading File line per line
	new line[64], id = 0
	while (!feof(fileHandle))
	{		
		// Reading Line
		fgets(fileHandle, line, 63)
		
		// Dont read commented lines
		if(line[0] == '#')
			continue
		
		// Dont read empty lines
		if(strlen(line) < 5)
			continue
			
		// Variables
		new small_line[32], small_line2[32]
		new cvar[32], value[10], limit[2], defaut[10]
				
		// Retrieving Info (Parsing Data)
		strcat(small_line, line[2], 63)
		new pos = contain(small_line, ":")
		strcat(cvar, small_line, pos)
		strcat(limit, small_line[pos+1], 1)
		strcat(small_line2, small_line[pos+2], strlen(small_line)-pos-3)
		pos = contain(small_line2, ":")
		strcat(value, small_line2[0], pos)
		strcat(defaut, small_line2[pos+1], strlen(small_line2)-pos-1)		
			
		// Setting Type (0 = INT  -  1 = FLOAT)
		if(line[0] == '0')
			g_type[id] = 0
		else if(line[0] == '1')
			g_type[id] = 1
		else
			continue
		
		// Setting Limiter
		if(limit[0] == '=')
			g_limit[id] = MB_EQUAL
		else if(limit[0] == '!')
			g_limit[id] = MB_NOTEQUAL
		else if(limit[0] == '>')
			g_limit[id] = MB_SUPERIOR
		else if(limit[0] == '<')
			g_limit[id] = MB_INFERIOR
		else if(limit[0] == '@')
			g_limit[id] = MB_BOTH
		else
			continue
			
		// Inserting CVARs Infos in Array
		g_cvars[id] = cvar
		g_value[id] = value
		g_default[id] = defaut
		
		// Incrementing ID
		id++
	}
	
	// Close File
	fclose(fileHandle)
	
	// CVARs File Loaded
	if(id > 1)
	{
		g_totalCvars = id
		g_cvarsFileLoaded = true
	} else {
		log_amx("No CVARs found in Antihax File %s.dat", filename)
	}
	
	// No Error
	return NOERROR
}

// =================================================================================================
// Function that force file that are in the specified file
// =================================================================================================

public load_modelsFile(const filename[])
{
	// Complete Path
	new completeMdlFilePath[64]
	format(completeMdlFilePath, 63, "%s/%s.dat", g_antihaxCfgDirectory, filename)
	
	// File Missing
	if(!file_exists(completeMdlFilePath))
	{
		log_amx("DoD Antihax File %s.dat is missing", filename)
		return ERROR
	}
	
	// Opening File
	new fileHandle = fopen(completeMdlFilePath, "r")
	
	// Error while opening File
	if(!fileHandle)
	{
		log_amx("Error while opening DoD Antihax File %s.dat", filename)
		return ERROR
	}
	
	// Reading File line per line
	new line[128]
	while (!feof(fileHandle))
	{
		// Reading Line
		fgets(fileHandle, line, 127)
		
		// Dont read commented lines
		if(line[0] == '#')
			continue
			
		// Dont read empty lines
		if(strlen(line) < 5)
			continue
		
		// Removing the \n at the end of the line
		new model_File[128]
		strcat(model_File, line, strlen(line)-1)
					
		// Force only existing Files
		if(file_exists(model_File))		
			force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, model_File) 	
	}
	
	// Close File
	fclose(fileHandle)
	
	// If the file is DATAFILE_GENMODEL -> General Models File
	// Else -> Map Models Dependencies
	if(strcmp(filename, DATAFILE_GENMODEL) == 0)
		g_genModelsFileLoaded = true
	else
		g_mapModelsFileLoaded = true

	// No Error
	return NOERROR

}

// =================================================================================================
// Function that compare MD5 of local file to those on Antihax Server
// =================================================================================================

public check_fileOnline(const filename[], const md5_offline[])
{
	// Format URL
	new buffer[512], url[128]
	format(url, 127, "get_md5.php?file=%s.dat", filename)
	
	// Retrive Online Data
	if(!get_onlineData(url, buffer, 511))
		return ERROR
			
	// MD5 checksum must be 32 length
	if(contain(buffer, "Content-Length: 32") == -1)
	{
		log_amx("MD5 of %s.dat is corrupted on DoD Antihax Server", filename)
		return ERROR
	}
	
	// Getting position of MD5 data in the HTTP Response
	new md5_online[34]
	new pos = contain(buffer, "^r^n^r^n")
	strcat( md5_online, buffer[pos+4], 32)	
	
	// Comparing MD5
	if(strcmp(md5_online, md5_offline) == 0)
	{
		return FILE_SAME
	} else {
		log_amx("File %s.dat differs from the DoD Antihax Server - Starting Download", filename)
		return FILE_DIFFERENT
	}
	
	// Never Happened
	return ERROR
}

// =================================================================================================
// Function that check the last version of the Plugin
// =================================================================================================

public check_pluginVersion()
{
	// Retrieving Server Port
	g_port = get_cvar_num("port") 
	
	// Default Value
	g_pluginUpdated = true
	
	// Format URL
	new buffer[512], url[64]
	format(url, 63, "get_version.php?version=%s&port=%d", PLUGIN_VERSION, g_port)
	
	// Retrive Online Data
	if(!get_onlineData(url, buffer, 511))
		return ERROR
		
	// Plugin need an update
	if(contain(buffer, "# NEED UPDATE") != -1)
	{
		log_amx("There is a new version of the DoD Antihax Plugin, please download it")
		g_pluginUpdated = false
	}

	return NOERROR
}

// =================================================================================================
// Function that create file from downloaded Data
// =================================================================================================

public get_onlineFile(const filename[])
{
	// Format URL
	new buffer[2500], url[64]
	format(url, 63, "%s.dat", filename)
	
	// Retrive Online Data
	if(!get_onlineData(url, buffer, 2499))
		return ERROR
	
	// File always start with # dod_antihax File
	if(contain(buffer, "# dod_antihax File") == -1)
	{
		log_amx("File %s.dat is corrupted on DoD Antihax Server", filename)
		return ERROR
	}
	
	// Getting position of File data in the HTTP Response
	new pos = contain(buffer, "^r^n^r^n")
	format(buffer, 2499, "%s", buffer[pos+4])
	
	// Opening file
	new completeDLFilePath[64];
	format(completeDLFilePath, 63, "%s/%s.dat", g_antihaxCfgDirectory, filename)
	new handle = fopen(completeDLFilePath, "wb") 	
	
	// Error while opening file
	if(!handle)
	{
		log_amx("Error when creating DoD Antihax File %s.dat", filename)
		return ERROR
	}else{
		log_amx("File %s.dat has been sucessfully downloaded", filename)
	}
	
	// Writing data in the file
	fprintf(handle, buffer)
	fclose(handle)
		
	return NOERROR
}

// =================================================================================================
// Function that ask for file or send data to Antihax Server
// =================================================================================================

public bool:get_onlineData(const url[], buffer[0], size)
{
	// Socket
	new error
	new socket = socket_open(SERVER_HOST, 80, SOCKET_TCP, error)

	// Socket Error
	if(error != 0)
	{
		g_antihaxServerReachable = false
		return false
	}else{
		g_antihaxServerReachable = true
	}
	
	// HTTP Request
	new requete[256]
	format(requete, 255, "GET /%s/%s HTTP/1.0^r^nHost: %s^r^nConnection: close^r^n^r^n", SERVER_DIRECTORY, url, SERVER_HOST)
	
	// Sending Socket
	socket_send(socket, requete, 255)
	
	// Receiving Socket	
	socket_recv(socket, buffer, size)
	
	// Closing Socket
	socket_close(socket)
	
	// Error 404
	if(contain(buffer, "404 Not Found")!=-1)
	{
		log_amx("File is missing on DoD Antihax Server")
		return false
	}
		
	return true
}