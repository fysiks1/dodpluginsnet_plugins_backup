/* 	AMX Mod X
*  	Nextmap Chooser Extended Plugin v1.30
*
*  	by h0_noMan
*
************************************************************************************
*
*  	Changes for version 1.10 :
*
*	- Text can be changed in the #define
*	- The vote Order now contains categories name instead of numbers
*	- I added 2 CVARs (amx_extendmap_max + amx_extendmap_step)
*	- 2 New command ("say currentmap" + "say lastmap") 
*
*  	Changes for version 1.11 :
*
*	- Fixed a bug (menu wont be display after an extend)
*
*  	Changes for version 1.12 :
*
*	- Fixed a bug (lastmap wont work)
*
*	Changes for version 1.20 :
*
*	- Added an in-game menu that allow admin to modify the future nextmap Vote
*
*	Changes for version 1.21 :
*
*	- Fixed a bug in the mkey
*
*	Changes for version 1.30 :
*
*	- Added a new option to the in-game menu to add the possibility to make a vote of Type 2
*	- Type 2 is a vote with a new vote Order
*
*	CVARS :
*	amx_extendmap_max <minutes>  : Maximum time for extending a map
* 	amx_extendmap_step <minutes> : Step time for extending a map
*
*	COMMANDS:
*	say currentmap : Display the current map name
*   say lastmap    : Display the last map name
*
************************************************************************************
*
*  	THIS IS WHAT YOU CAN CHANGE :
* 
*  	MAPSFILE : Maps file (must be placed in the configs directory)
*  	NB_OF_CAT : Numbers of categories
*  	MAPS_PER_CAT : Maximum numbers of maps in one category
*  	NB_OF_CHOICE : Numbers of propositions (MUST BE BETWEEN 2 AND 7)
*  	VOTE_BEFORE : Time before the end of the map for displaying the Vote Menu
*
*  	g_catOrder : An array which contains the category wanted for the vote 
*  
*  	g_catOrder must contain NB_OF_CHOICE elements
*
*  	{"BEST","BEST","GOOD","MID","LOW"}		<== The category must fit with those in the maps file
*
*  	The 1st map of the vote will be picked in the category [BEST] (in the maps file)
*  	The 2nd map of the vote will be picked in the category [BEST]
*  	The 3rd map of the vote will be picked in the category [GOOD]
*  	The 4th map of the vote will be picked in the category [MID]
*  	The 5th map of the vote will be picked in the category [LOW]
*
************************************************************************************
*
*  	FORMAT OF THE MAPS FILE (Similar to INI FILES)
*
*  	[BEST]				<==  The file start with a category (you can change the name of the category - 32 chars)
*  	dod_mapcat1			<==  Maps for the category 1
*  	dod_mapcat1
*  	dod_mapcat1
*  	dod_mapcat1
*						<== A space between 2 categories (not obligatory)
*  	[GOOD]				<== The second category 
*  	dod_mapcat2			<== Maps of the 2nd category
*  	dod_mapcat2
*  	dod_mapcat2
*
*  	[MID]
*  	...
*
*/

#include <amxmodx>
#include <amxmisc>

// Variables
#define 	MAPSFILE			"maps_ext.ini"
#define 	NB_OF_CAT			4
#define 	MAPS_PER_CAT		100
#define 	VOTE_BEFORE			180.0
#define		VOTE_ORDER			{"BEST","GOOD","GOOD","MID","LOW"}
#define		VOTE_ORDER_T2		{"GOOD","GOOD","MID","MID","LOW"}
#define 	NB_OF_CHOICE		5

// Dont change this
#define 	charsof(%1) 		(sizeof(%1)-1)
#define 	LEN_MAPNAME			32
#define 	LEN_CATNAME			32
#define 	LEN_MAPFILENAME		64	
#define		TYPE_NORMAL			1
#define		TYPE_2				2

// Plugin Register
#define 	PLUGIN_NAME 		"Nextmap Chooser Extended"
#define 	PLUGIN_VERSION 		"1.30"
#define 	PLUGIN_AUTHOR 		"h0_noMan"

/* LANGUAGE FRENCH
#define		MENU_TITLE			"\yChoisir la prochaine carte :^n"
#define		MENU_EXTEND			"Prolonger la carte"
#define		MENU_QUIT			"Quitter"
#define		DSPL_CURRENT		"[Nextmap] La carte actuelle est %s."
#define		DSPL_LAST			"[Nextmap] La precedente carte etait %s."
#define		DSPL_TIME			"[Nextmap] Choisissez la prochaine carte."
#define		DSPL_CHOICE			"[Nextmap] %s a chosi %s."
#define		DSPL_EXT_NAME		"de prolonger la carte"
#define		DSPL_EXTEND			"[Nextmap] Vote termine. La carte sera prolonge de %.0f minutes."
#define		DSPL_MAP			"[Nextmap] Vote termine. La prochaine carte sera %s."
#define		TEST_MENU_TITLE		"\yLe prochain vote sera :^n"
#define		TEST_QUIT			"Quitter"
#define		TEST_NEW			"Nouveau vote"
#define		TEST_NEW_T2			"Nouveau vote Type 2"
#define		TEST_TXT_NEW		"[Nextmap] Demande de nouveau vote."
*/

// LANGUAGE ENGLISH
#define		MENU_TITLE			"\yChoose the Nextmap :^n"
#define		MENU_EXTEND			"Extend the map"
#define		MENU_QUIT			"Exit"
#define		DSPL_CURRENT		"[Nextmap] The current map is %s."
#define		DSPL_LAST			"[Nextmap] The previous map was %s."
#define		DSPL_TIME			"[Nextmap] Choose the nextmap."
#define		DSPL_CHOICE			"[Nextmap] %s chose %s."
#define		DSPL_EXT_NAME		"extending the map"
#define		DSPL_EXTEND			"[Nextmap] Choosing finished. The map will be extended to %.0f minutes."
#define		DSPL_MAP			"[Nextmap] Choosing finished. The next map will be %s."
#define		TEST_MENU_TITLE		"\yThe next Choice :^n"
#define		TEST_QUIT			"Exit"
#define		TEST_NEW			"New Classic Choice"
#define		TEST_NEW_T2			"New Type 2 Choice"
#define		TEST_TXT_NEW		"[Nextmap] New choice validated."


// Vote Order
new g_catOrder[NB_OF_CHOICE][LEN_CATNAME] = VOTE_ORDER ;
new g_catOrder_t2[NB_OF_CHOICE][LEN_CATNAME] = VOTE_ORDER_T2 ;
new g_voteOrder[NB_OF_CHOICE] ;
new g_voteOrder_t2[NB_OF_CHOICE] ;

// Array of MAPS per CAT
new g_MapCatName[NB_OF_CAT][LEN_CATNAME];
new g_MapCat[NB_OF_CAT][MAPS_PER_CAT][LEN_MAPNAME];
new g_NbMapPerCat[NB_OF_CAT];

// Maps File
new g_maps_file[LEN_MAPFILENAME]

// Choice Array
new g_choice[NB_OF_CHOICE][LEN_MAPNAME];
new g_votes[8];

// Current and lastmap
new g_currentMap[LEN_MAPNAME];
new g_lastMap[10][LEN_MAPNAME];


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
public plugin_init()
{
	// Plugin Registration
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	// Registration of the Menu
	register_menucmd(register_menuid(MENU_TITLE), 1023, "countVote");
	register_menucmd(register_menuid(TEST_MENU_TITLE), 1023, "validFuture");
	
	// Command for displaying current and lastmap
	register_clcmd("say currentmap", "displayCurrentMap", -1, "Display the current Map Name");
	register_clcmd("say lastmap", "displayLastMap", -1, "Display the last Map Name");
	register_clcmd("showvotemap", "showVoteMap", ADMIN_MAP, "Change the future VoteMap");
	
	// CVARs
	register_cvar("amx_extendmap_max", "90")
	register_cvar("amx_extendmap_step", "15")
	
	// LASTMAP
	register_cvar("nm_lastmap1","")
	register_cvar("nm_lastmap2","")
	register_cvar("nm_lastmap3","")
	register_cvar("nm_lastmap4","")
	register_cvar("nm_lastmap5","")
	register_cvar("nm_lastmap6","")
	register_cvar("nm_lastmap7","")
	register_cvar("nm_lastmap8","")
	register_cvar("nm_lastmap9","")
	register_cvar("nm_lastmap10","")
	
	// On recupere les lastmaps
	get_lastmap()
	
	// Path of the Maps File
	get_configsdir(g_maps_file, LEN_MAPFILENAME-1);
	format(g_maps_file, LEN_MAPFILENAME-1, "%s/%s", g_maps_file, MAPSFILE);
		
	if (!file_exists(g_maps_file))
		return PLUGIN_CONTINUE;
		
	// Loading Maps
	loadMapFile(g_maps_file);
	
	// Link CATNAME to CATNUMBER
	linkCatName();
	
	// Build of the Random Array
	makeRandomArray(TYPE_NORMAL)
		
	// Task for displaying the Menu VOTE_BEFORE minutes before end of map
	set_task(VOTE_BEFORE, "showVote", 987456, "", 0, "d");

	return PLUGIN_CONTINUE;
}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
public displayCurrentMap()
{
	client_print(0, print_chat, DSPL_CURRENT, g_currentMap);
}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
public displayLastMap()
{
	client_print(0, print_chat, DSPL_LAST, g_lastMap[0]);
}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
public showVote()
{
	new szMenuBody[512], i = 0, mkeys = (1<<NB_OF_CHOICE) -1 ;
	
	// Body of the Menu
	new nLen = format( szMenuBody, 255, MENU_TITLE );
	
	// Adding Maps to the Body
	for(i=0;i<NB_OF_CHOICE;i++)
		nLen += format( szMenuBody[nLen], 511, "^n\w%d. %s",i+1,g_choice[i]) ;		
	
	// An empty line after the Maps
	nLen += format( szMenuBody[nLen], 511, "^n");
	
	// Adding Extend Option
	if ( get_cvar_float("mp_timelimit") < get_cvar_float("amx_extendmap_max") )
	{
		nLen += format( szMenuBody[nLen], 511, "^n\w8. %s", MENU_EXTEND);
		mkeys |= (1<<7);
	}
	
	// Adding Exit Option
	nLen += format( szMenuBody[nLen], 255-nLen, "^n\w9. %s", MENU_QUIT) ;	
	mkeys |= (1<<8);	
	
	// Display of the Menu for 25 seconds
	show_menu( 0, mkeys, szMenuBody, 25);	
	
	// Vote Checking 26 seconds after the display of the Menu
	set_task(26.0, "checkVotes");
	
	// Display + LOG + Voice
	client_print(0, print_chat, DSPL_TIME);
	client_cmd(0, "spk Gman/Gman_Choose2");
	log_amx("Vote: Voting for the nextmap started")
	
	return PLUGIN_CONTINUE;	
}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
public showVoteMap(id)
{
	new szMenuBody_2[512], i = 0, mkeys_2 = (1) | (1<<1) | (1<<2);
	
	// Body of the Menu
	new nLen_2 = format( szMenuBody_2, 255, TEST_MENU_TITLE );
	
	// Adding Maps to the Body
	for(i=0;i<NB_OF_CHOICE;i++)
	{
		if(!equali(g_choice[i],""))
			nLen_2 += format( szMenuBody_2[nLen_2], 511, "^n\wChoix %d. %s",i+1,g_choice[i]) ;
		else
			mkeys_2 |= 0<<(i+7)
	}
		
	// An empty line after the Maps
	nLen_2 += format( szMenuBody_2[nLen_2], 511, "^n");
	
	// Make a new vote
	nLen_2 += format( szMenuBody_2[nLen_2], 511, "^n\w1. %s", TEST_NEW);
	
	// Make a new vote Type 2
	nLen_2 += format( szMenuBody_2[nLen_2], 511, "^n\w2. %s", TEST_NEW_T2);
	
	// Quit the vote
	nLen_2 += format( szMenuBody_2[nLen_2], 511, "^n^n\w3. %s", TEST_QUIT);
	
	// Display of the Menu for 25 seconds
	show_menu( id, mkeys_2, szMenuBody_2, 25);
	
	return PLUGIN_CONTINUE;
	
}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
public countVote(id, key)
{	
	new name[32], mapname[LEN_MAPNAME];
	get_user_name(id, name, 31);
	
	mapname = (key == 7) ? DSPL_EXT_NAME : g_choice[key] ;
	
	client_print(0, print_chat, DSPL_CHOICE, name, mapname) ;	
	
	// Increase the vote for the given map
	g_votes[key]++;
   
	return PLUGIN_HANDLED
}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
public validFuture(id, key)
{
	if(key==0)
	{
		client_print(id, print_chat, TEST_TXT_NEW)	
		
		// Build of the Random Array
		makeRandomArray(TYPE_NORMAL)
		
		// Display the Menu again to validate
		showVoteMap(id)	
		
	}else if(key==1){
	
		client_print(id, print_chat, TEST_TXT_NEW)	
		
		// Build of the Random Array
		makeRandomArray(TYPE_2)
		
		// Display the Menu again to validate
		showVoteMap(id)	
	}
	
	return PLUGIN_HANDLED
}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
public checkVotes()
{
	new b = 0 ;
	
	for(new a = 0 ; a < 8 ; a++)
		if(g_votes[a] > g_votes[b])
			b = a ;	

	// EXTEND
	if(b == 7)
	{
		// Adding etend step to timelimit
		new Float:steptime = get_cvar_float("amx_extendmap_step");
		set_cvar_float("mp_timelimit", get_cvar_float("mp_timelimit") + steptime);
		
		// Affichage + LOG
		client_print(0, print_chat, DSPL_EXTEND,steptime);
		log_amx("Vote: Voting for the nextmap finished. Map will be extended to next %.0f minutes", steptime);
		
		// On recree un nouveau vote
		makeRandomArray(TYPE_NORMAL);
		
		// On reprepare un vote
		set_task(VOTE_BEFORE, "showVote", 987456, "", 0, "d");

		// LEAVE
		return 0;
	}
	
	// Nextmap change
	set_cvar_string("amx_nextmap", g_choice[b]);
	
	// Display + LOG
	client_print(0, print_chat, DSPL_MAP, g_choice[b]);
	log_amx("Vote: Voting for the nextmap finished. The nextmap will be %s", g_choice[b]);
	
	return PLUGIN_CONTINUE;
}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
public linkCatName()
{
	for(new i=0; i<NB_OF_CHOICE; i++)
	{
		for(new j=0; j<NB_OF_CAT; j++)
		{
			if(equal(g_MapCatName[j],g_catOrder[i]))
				g_voteOrder[i] = j ;
			
			if(equal(g_MapCatName[j],g_catOrder_t2[i]))
				g_voteOrder_t2[i] = j ;
		}			
	}
}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
public bool:makeRandomArray(type)
{
	for(new i=0;i<NB_OF_CHOICE;i++)
	{
		if(type==TYPE_NORMAL)
		{
			// No maps in the given category
			if(g_NbMapPerCat[g_voteOrder[i]] == 0)
				return false;
			
			// Add a random map from the given gategory to the random array
			g_choice[i] = g_MapCat[g_voteOrder[i]][random(g_NbMapPerCat[g_voteOrder[i]])];
			
			// Check for duplicated maps
			for(new j=0;j<i;j++)
			{
				while(equal(g_choice[i],g_choice[j]))
					g_choice[i] = g_MapCat[g_voteOrder[i]][random(g_NbMapPerCat[g_voteOrder[i]])];
			}
		}else if(type==TYPE_2){
		
			// No maps in the given category
			if(g_NbMapPerCat[g_voteOrder_t2[i]] == 0)
				return false;
			
			// Add a random map from the given gategory to the random array
			g_choice[i] = g_MapCat[g_voteOrder_t2[i]][random(g_NbMapPerCat[g_voteOrder_t2[i]])];
			
			// Check for duplicated maps
			for(new j=0;j<i;j++)
			{
				while(equal(g_choice[i],g_choice[j]))
					g_choice[i] = g_MapCat[g_voteOrder_t2[i]][random(g_NbMapPerCat[g_voteOrder_t2[i]])];
			}		
		}
	}

	return true;	
}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
public loadMapFile(maps_file[])
{
	new buff[256];
	new szText[LEN_MAPNAME];
	
	new currentCat = -1 ;	
	new fp = fopen(maps_file,"r");
	
	while (!feof(fp))
	{
		// Buffer erasing
		buff[0]='^0';
		szText[0]='^0';
			
		// Read of the file line per line
		fgets(fp, buff, charsof(buff));				
		parse(buff, szText, charsof(szText));
		
		// If it starts with [ then it is a category
		if (szText[0] == '[')
		{	
			// New category
			currentCat++;	
			
			// Initialisation of number of map for this category
			g_NbMapPerCat[currentCat] = -1;
			
			// Name of the category (in the file) for a future improvment
			g_MapCatName[currentCat] = szText;
			
			// Deleting the brackets [ and ]
			replace(g_MapCatName[currentCat],LEN_MAPNAME-1,"[","");
			replace(g_MapCatName[currentCat],LEN_MAPNAME-1,"]","");
		}
		
		// Maps with a ; before will be ignored
		// Maps wont be the same than the current or the last
		// Empty line are ignored
		if (szText[0] != ';' && szText[0] != '[' && ValidMap(szText) && strlen(szText) !=0 && !mapPlayed(szText) )
		{
			
			// Numbers of maps in the category increased
			g_NbMapPerCat[currentCat]++;
			
			// Adding map to the random Array
			g_MapCat[currentCat][g_NbMapPerCat[currentCat]] = szText;
		}		
	}
	
	fclose(fp);	
	
	return PLUGIN_CONTINUE
}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
public get_lastmap()
{
	// Get LASTMAP
	get_mapname(g_currentMap, 31)
	get_cvar_string("nm_lastmap1",g_lastMap[0],31)
	get_cvar_string("nm_lastmap2",g_lastMap[1],31)
	get_cvar_string("nm_lastmap3",g_lastMap[2],31)
	get_cvar_string("nm_lastmap4",g_lastMap[3],31)
	get_cvar_string("nm_lastmap5",g_lastMap[4],31)
	get_cvar_string("nm_lastmap6",g_lastMap[5],31)
	get_cvar_string("nm_lastmap7",g_lastMap[6],31)
	get_cvar_string("nm_lastmap8",g_lastMap[7],31)
	get_cvar_string("nm_lastmap9",g_lastMap[8],31)
	get_cvar_string("nm_lastmap10",g_lastMap[9],31)
}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
public plugin_end()
{
	// Set LASTMAP
	set_cvar_string("nm_lastmap1",g_currentMap)
	set_cvar_string("nm_lastmap2",g_lastMap[0])
	set_cvar_string("nm_lastmap3",g_lastMap[1])
	set_cvar_string("nm_lastmap4",g_lastMap[2])
	set_cvar_string("nm_lastmap5",g_lastMap[3])
	set_cvar_string("nm_lastmap6",g_lastMap[4])
	set_cvar_string("nm_lastmap7",g_lastMap[5])
	set_cvar_string("nm_lastmap8",g_lastMap[6])
	set_cvar_string("nm_lastmap9",g_lastMap[7])
	set_cvar_string("nm_lastmap10",g_lastMap[8])
}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
public bool:mapPlayed(mapname[])
{
	// Test if mapname was played before
	for(new i=0;i<10;i++)
	{
		if(equali(mapname, g_lastMap[i]))
		return true
	}
	
	// Test if mapname is not the same than current map
	if(equali(mapname, g_currentMap))
		return true
	
	return false
}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
stock bool:ValidMap(mapname[])
{
	if ( is_map_valid(mapname) )
		return true;

	new len = strlen(mapname) - 4;
	
	if (len < 0)
		return false;

	if ( equali(mapname[len], ".bsp") )
	{
		mapname[len] = '^0';
		
		if ( is_map_valid(mapname) )
			return true;
	}
	
	return false;
}
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////