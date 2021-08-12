//////////////////////////////////////////////////////////////////////////////////
//
//	DoD Random Skymap
//		- Version 1.2
//		- 08.06.2006
//		- diamond-optic
//
//////////////////////////////////////////////////////////////////////////////////
//
// Information:
//
//	- Will select a random skymap at the start of each map
//	- Selects from the 12 defualt dod skymaps
//
//	- ** Requires AMXX 1.75 or higher **
//
// CVARS:
//
//	  dod_random_skymap "1" //Turn on(1)/off(0)
//
// Extra:
//
//	- By looking at the code, you'll see its very easy to edit
//	  it to include any custom skymaps you want to use...
//
// Changelog:
//
//	- 06.15.2006 Version 1.0
//		Initial release
//
//	- 07.01.2006 Version 1.1
//		Removed ENGINE module (requires amxx 1.75+)
//
//	- 08.06.2006 Version 1.2
//		Changed the returns in the precache function
//
//////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>

public plugin_init()
{
	register_plugin("DoD Random Skymap", "1.2", "AMXX DoD Team")
	register_cvar("dod_random_skymap", "1")
}

public plugin_precache()
{	
	if(get_cvar_num("dod_random_skymap") != 1)
		return PLUGIN_CONTINUE

	switch(random_num(1, 12))
		{
		case 1:	{
			server_cmd("sv_skyname ava")
			precache_generic("gfx/env/avart.tga")
			precache_generic("gfx/env/avalf.tga")
			precache_generic("gfx/env/avaft.tga")
			precache_generic("gfx/env/avadn.tga")
			precache_generic("gfx/env/avabk.tga")
			precache_generic("gfx/env/avaup.tga")
			}
		case 2: {
			server_cmd("sv_skyname dashnight256")
			precache_generic("gfx/env/dashnight256rt.tga")
			precache_generic("gfx/env/dashnight256lf.tga")
			precache_generic("gfx/env/dashnight256ft.tga")
			precache_generic("gfx/env/dashnight256dn.tga")
			precache_generic("gfx/env/dashnight256bk.tga")
			precache_generic("gfx/env/dashnight256up.tga")
			}
		case 3: {
			server_cmd("sv_skyname jagd")
			precache_generic("gfx/env/jagdrt.tga")
			precache_generic("gfx/env/jagdlf.tga")
			precache_generic("gfx/env/jagdft.tga")
			precache_generic("gfx/env/jagddn.tga")
			precache_generic("gfx/env/jagdbk.tga")
			precache_generic("gfx/env/jagdup.tga")
			}
		case 4: {
			server_cmd("sv_skyname dmcw")
			precache_generic("gfx/env/dmcwrt.tga")
			precache_generic("gfx/env/dmcwlf.tga")
			precache_generic("gfx/env/dmcwft.tga")
			precache_generic("gfx/env/dmcwdn.tga")
			precache_generic("gfx/env/dmcwbk.tga")
			precache_generic("gfx/env/dmcwup.tga")
			}
		case 5: {
			server_cmd("sv_skyname rubble")
			precache_generic("gfx/env/rubblert.tga")
			precache_generic("gfx/env/rubblelf.tga")
			precache_generic("gfx/env/rubbleft.tga")
			precache_generic("gfx/env/rubbledn.tga")
			precache_generic("gfx/env/rubblebk.tga")
			precache_generic("gfx/env/rubbleup.tga")
			}
		case 6: {
			server_cmd("sv_skyname sildom2")
			precache_generic("gfx/env/sildom2rt.tga")
			precache_generic("gfx/env/sildom2lf.tga")
			precache_generic("gfx/env/sildom2ft.tga")
			precache_generic("gfx/env/sildom2dn.tga")
			precache_generic("gfx/env/sildom2bk.tga")
			precache_generic("gfx/env/sildom2up.tga")
			}
		case 7: {
			server_cmd("sv_skyname snowcliff")
			precache_generic("gfx/env/snowcliffrt.tga")
			precache_generic("gfx/env/snowclifflf.tga")
			precache_generic("gfx/env/snowcliffft.tga")
			precache_generic("gfx/env/snowcliffdn.tga")
			precache_generic("gfx/env/snowcliffbk.tga")
			precache_generic("gfx/env/snowcliffup.tga")
			}
		case 8: {
			server_cmd("sv_skyname grnplsnt")
			precache_generic("gfx/env/grnplsntrt.tga")
			precache_generic("gfx/env/grnplsntlf.tga")
			precache_generic("gfx/env/grnplsntft.tga")
			precache_generic("gfx/env/grnplsntdn.tga")
			precache_generic("gfx/env/grnplsntbk.tga")
			precache_generic("gfx/env/grnplsntup.tga")
			}
		case 9: {
			server_cmd("sv_skyname killertomato")
			precache_generic("gfx/env/killertomatort.tga")
			precache_generic("gfx/env/killertomatolf.tga")
			precache_generic("gfx/env/killertomatoft.tga")
			precache_generic("gfx/env/killertomatodn.tga")
			precache_generic("gfx/env/killertomatobk.tga")
			precache_generic("gfx/env/killertomatoup.tga")
			}
		case 10:{
			server_cmd("sv_skyname kraftstoff")
			precache_generic("gfx/env/kraftstoffrt.tga")
			precache_generic("gfx/env/kraftstofflf.tga")
			precache_generic("gfx/env/kraftstoffft.tga")
			precache_generic("gfx/env/kraftstoffdn.tga")
			precache_generic("gfx/env/kraftstoffbk.tga")
			precache_generic("gfx/env/kraftstoffup.tga")
			}
		case 11:{
			server_cmd("sv_skyname morningdew")
			precache_generic("gfx/env/morningdewrt.tga")
			precache_generic("gfx/env/morningdewlf.tga")
			precache_generic("gfx/env/morningdewft.tga")
			precache_generic("gfx/env/morningdewdn.tga")
			precache_generic("gfx/env/morningdewbk.tga")
			precache_generic("gfx/env/morningdewup.tga")
			}
		case 12:{
			server_cmd("sv_skyname st")
			precache_generic("gfx/env/strt.tga")
			precache_generic("gfx/env/stlf.tga")
			precache_generic("gfx/env/stft.tga")
			precache_generic("gfx/env/stdn.tga")
			precache_generic("gfx/env/stbk.tga")
			precache_generic("gfx/env/stup.tga")
			}
		}
	return PLUGIN_CONTINUE
}