//
// AMX Mod X Script
//
// Developed by The AMX Mod X DoD Community
// http://www.dodplugins.net
//
// Author: FeuerSturm
//
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
//
//
//
// 
// USAGE:
// ======
//
// say_team # <message here>   =    displays a message only from/to users with
//                                  the defined ACCESS_LEVEL
//
//
//
//
// DESCRIPTION:
// ============
//
// - I wrote this plugin for my servers as i don't want to give
//   all of my members the ability to use the adminchat features
//   as people tend to only use hudmessages for everything they
//   say. furthermore trainees aren't always supposed to see
//   what the admins talk.
//   Basically this plugin gives all of your members the ability
//   to chat with other members without public players being
//   able to read it. You can set the ACCESS_LEVEL to whatever
//   you like.
//
//
// Example 1:
//
// The ACCESS_LEVEL is set to ADMIN_RESERVATION and the player
// "hEaDcRaCkEr" has a reserved slot and types
// "# when will the clan match be today?" into the teamchat.
// The result will be:
// "[MemberChat] hEaDcRaCkEr:  when will the clan match be today?"
// This will be displayed in the chat area and only players that
// have a reserved slot as well will see it.
//
// Example 2:
//
// The ACCESS_LEVEL is set to ADMIN_KICK and the player
// "hEaDcRaCkEr" only has a reserved slot and types
// "# when will the clan match be today?" into the teamchat.
// The result will be:
// "You can't use [MemberChat], hEaDcRaCkEr"
// This will be displayed in the chat area and only hEaDcRaCkEr
// will see it.
//
//
// "[MemberChat] <name>" will be in the color of the player's team,
//  while the message itself will be normal chat color.
//
// "You can't use [MemberChat], <name>" will be displayed completely
//  in the color of the player's team that tried to use the feature.
//
//
//
// CHANGELOG:
// ==========
//
// - 31.08.2005 Version 0.5beta
//   Initial Release
//
// - 02.07.2007 Version 0.6
//   - added global tracking cvar
//

#include <amxmodx>


// Change ADMIN_RESERVATION in the following
// line to whatever fits your needs!

#define ACCESS_LEVEL ADMIN_RESERVATION

// DON'T edit anything from here on,
// unless you really know what you are doing!



public plugin_init()
{
	register_plugin("DoD MemberChat","0.6","AMXX DoD Team")
	register_cvar("dod_memberchat_plugin", "Version 0.6 by FeuerSturm | www.dodplugins.net", FCVAR_SERVER|FCVAR_SPONLY)
	register_clcmd("say_team","member_chat")
}

public member_chat(id)
{
	new check[3]
	read_argv(1,check,2)
	if(equal(check,"# ") == 1)
	{
		if(get_user_flags(id)&ACCESS_LEVEL)
		{
			new adminname[32]
			get_user_name(id,adminname,31)
			new membermessage[192]
			read_args(membermessage,191)
			new newfront[32]
			format(newfront,31,"[MemberChat] %s: ",adminname)
			replace(membermessage,191,"#",newfront)
			remove_quotes(membermessage)				
			new members[32],membersnum
			get_players(members,membersnum)
			for(new i=0; i<membersnum; i++){
				new member = members[i]
				if(is_user_connected(member) == 1 && (get_user_flags(member)&ACCESS_LEVEL))
				{
					message_begin(MSG_ONE,get_user_msgid("SayText"),{0,0,0},member)
					write_byte(id)
					write_string(membermessage)
					message_end()
				}
			}
			return PLUGIN_HANDLED
		}
		else
		{
			new notauthed[32]
			get_user_name(id,notauthed,31)
			new notauthedmsg[65]
			format(notauthedmsg,64,"You can't use [MemberChat], %s",notauthed)
			message_begin(MSG_ONE,get_user_msgid("SayText"),{0,0,0},id)
			write_byte(id)
			write_string(notauthedmsg)
			message_end()
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
