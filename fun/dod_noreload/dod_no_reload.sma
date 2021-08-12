/*=================================================================================================
DoD No Reload v1.001

This plugin keeps all weapons full of bullets negating the need to reload.

===========================
v1.001 Changes
===========================
- Moved check for entity validity before any entity functions are performed. It was throwing errors
  on entities no longer existing. Owned again by the obvious. I'll blame it on lack of sleep this 
  time. Thanks Diamond Optic for spotting it. :D

===========================
CVARs
===========================
no_reload | 0 = off | 1 = on
- Enables or disables the no_reload plugin. Default off.

===========================
Installation
===========================
- Compile the .sma file | An online compiler can be found here:
  http:www.amxmodx.org/webcompiler.cgi
- Copy the compiled .amxx file into your addons\amxmodx\plugins folder
- Add the name of the compiled .amxx to the bottom of your addons\amxmodx\configs\plugins.ini

===========================
Support
===========================
Visit the AMXMODX Plugins section of the forums @ 
http:www.dodplugins.net or http:www.rivurs.com

===========================
License
===========================
DoD No Reload
Copyright (C) 2012 Synthetic

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=================================================================================================*/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

// =================================================================================================
// Declare global variables and values
// =================================================================================================
new p_reload

// =================================================================================================
// Plugin init
// =================================================================================================
public plugin_init() {
	register_cvar("dod_no_reload", "v1.001 by Synthetic",FCVAR_SERVER|FCVAR_SPONLY)
	register_plugin("DoD No Reload","1.001","Synthetic")
	p_reload = register_cvar("no_reload","0")
	register_forward(FM_AddToFullPack,"func_full_pack")
}

//=========================================================
// Constantly fill up current clip in gun
//=========================================================
public func_full_pack(nil,nil2,id) {
	if(get_pcvar_num(p_reload) && pev_valid(id))
	{
		new class_name[32]
		pev(id,pev_classname,class_name,sizeof class_name - 1)
		if(contain(class_name,"weapon_") > -1)
		{
			set_pdata_int(id,108,5,4)
		}
	}
}
