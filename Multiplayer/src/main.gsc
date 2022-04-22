#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

/*
	Mod: Mapvote Menu
	Developed by DoktorSAS
	Version: v1.0.2
	Config:
	set mv_enable			1 						// Enable/Disable the mapvote
	set mv_maps				""						// Lits of maps that can be voted on the mapvote, leave empty for all maps
	set mv_excludedmaps		""						// Lis of maps you don't want to show in the mapvote
	set mv_time 			1 						// Time to vote
	set mv_socialname 		"SocialName" 			// Name of the server social such as Discord, Twitter, Website, etc
	set mv_sentence 		"Thanks for playing" 	// Thankfull sentence
	set mv_votecolor		"5" 					// Color of the Vote Number
	set mv_arrowcolor		"white"					// RGB Color of the arrows
	set mv_selectcolor 		"lighgreen"				// RGB Color when map get voted
	set mv_backgroundcolor 	"grey"					// RGB Color of map background
	set mv_blur 			"3"						// Blur effect power
	set mv_gametypes 		"dm;dm.cfg"					// This dvar can be used to have multiple gametypes with different maps, with this dvar you can load gamemode cfg files

	1.0.0:
	- 3 maps support
	- Credits, sentence and social on bottom left
	- Simple keyboard and controller button support
	- Better dvar organization
	- Code optimization
	- Redouce sharder variables to allow other mods to work as intended

	1.0.1:
	- Fixed client crash issue
	- mv_gametypes added to set g_gametype before map change

	1.0.2:
	- mv_gametypes now support also custom cfg files
*/

init()
{
	precacheStatusIcon("compassping_friendlyfiring_mp");
	precacheStatusIcon("compassping_enemy");
	precacheshader("white");
	precacheshader("ui_scrollbar_arrow_left");
	precacheshader("ui_scrollbar_arrow_right");
	level thread OnPlayerConnected();

	level thread mv_Config();
}

mv_Config()
{
	SetDvarIfNotInizialized("mv_enable", 1);
	if (getDvarInt("mv_enable") != 1) // Check if mapvote is enable
		return;						  // End if the mapvote its not enable

	level.__mapvote = [];
	SetDvarIfNotInizialized("mv_time", 20);
	level.__mapvote["time"] = getDvarInt("mv_time");
	SetDvarIfNotInizialized("mv_maps", "mp_la mp_dockside mp_carrier mp_drone mp_express mp_hijacked mp_meltdown mp_overflow mp_nightclub mp_raid mp_slums mp_village mp_turbine mp_socotra mp_nuketown_2020 mp_downhill mp_mirage mp_hydro mp_skate mp_concert mp_magma mp_vertigo mp_studio mp_uplink mp_bridge mp_castaway mp_paintball mp_dig mp_frostbite mp_pod mp_takeoff");

	// PreCache maps images
	mapsd = [];
	mapsd = getMapsData();

	foreach (map in mapsd)
	{
		preCacheShader(map.image);
	}

	// Setting default values if needed
	SetDvarIfNotInizialized("mv_credits", 1);
	SetDvarIfNotInizialized("mv_socials", 1);
	SetDvarIfNotInizialized("mv_socialname", "Discord");
	SetDvarIfNotInizialized("mv_sociallink", "Discord.gg/^3Plutonium^7");
	SetDvarIfNotInizialized("mv_sentence", "Thanks for Playing by @DoktorSAS");
	SetDvarIfNotInizialized("mv_votecolor", "5");
	SetDvarIfNotInizialized("mv_arrowcolor", "white");
	SetDvarIfNotInizialized("mv_blur", "3");
	SetDvarIfNotInizialized("mv_scrollcolor", "cyan");
	SetDvarIfNotInizialized("mv_selectcolor", "lightgreen");
	SetDvarIfNotInizialized("mv_backgroundcolor", "grey");
	SetDvarIfNotInizialized("mv_gametypes", "dm;dm.cfg war;tdm.cfg dm;dm.cfg war;tdm.cfg sd;sd.cfg sd;sd.cfg");
	setDvarIfNotInizialized("mv_excludedmaps", "");

	/*if( level.roundlimit == 1)
		maps\mp\gametypes\_globallogic_utils::registerpostroundevent(::mv_Begin);*/
}

main()
{
	replaceFunc(maps\mp\gametypes\_killcam::finalkillcamwaiter, ::mv_finalkillcamwaiter);
}
mv_finalkillcamwaiter()
{
	if (!isDefined(level.finalkillcam_winner))
	{
		return 0;
	}
	level waittill("final_killcam_done");
	if (waslastround())
		mv_Begin();

	return 1;
}

OnPlayerConnected()
{
	level endon("game_ended");
	for (;;)
	{
		level waittill("connected", player);
		player thread FixBlur();
	}
}
FixBlur() // Reset blur effect to 0
{
	self endon("disconnect");
	level endon("game_ended");
	self waittill("spawned_player");
	self setblur(0, 0);
}
