#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_hud_util;

/*
	Mod: Mapvote Menu
	Developed by DoktorSAS
	Version: 2.1.0

	2.0.1:
	- Ported new design
	- Timer fixed
	- Fixed UI animations
	- Removed usless functions
	- Fixed UI removing screen text
	- Added animations during vote
	- Fixed design issues
	
	2.0.2:
	- Fixed missing map
	- Fixed typo

	2.1.0:
	- Added support for 6 maps, it can be enable by setting the dvar mv_extramaps to 1
	- Code cleaned
	- Added easy way to support "custom maps"
*/

init()
{
	precacheStatusIcon("compassping_friendlyfiring_mp");
	precacheStatusIcon("compassping_enemy");
	precacheshader("white");
	precacheshader("ui_scrollbar_arrow_left");
	precacheshader("ui_scrollbar_arrow_right");
	precacheshader("menu_zm_popup");

	level thread OnPlayerConnected();

	mv_Config();
}

mv_Config()
{
	logPrint("mapvote//config");
	SetDvarIfNotInizialized("mv_enable", 1);
	if (getDvarInt("mv_enable") != 1) // Check if mapvote is enable
		return;						  // End if the mapvote its not enable

	level.__mapvote = [];
	SetDvarIfNotInizialized("mv_time", 20);
	level.__mapvote["time"] = getDvarInt("mv_time");
	SetDvarIfNotInizialized("mv_maps", "zm_tomb zm_buried zm_town zm_busdepot zm_farm zm_transit zm_prison zm_highrise zm_nuked");

	// PreCache maps images
	mapsIDs = [];
	mapsIDs = strTok(getDvar("mv_maps"), " ");
	mapsd = [];
	mapsd = buildmapsdata();

	foreach (map in mapsd)
	{
		preCacheShader(map.image);
	}

	// Setting default values if needed
	SetDvarIfNotInizialized("mv_credits", 1);
	SetDvarIfNotInizialized("mv_socials", 1);
	SetDvarIfNotInizialized("mv_extramaps", 1);
	SetDvarIfNotInizialized("mv_socialname", "Discord");
	SetDvarIfNotInizialized("mv_sociallink", "Discord.gg/^3Plutonium^7");
	SetDvarIfNotInizialized("mv_sentence", "Thanks for Playing by @DoktorSAS");
	SetDvarIfNotInizialized("mv_votecolor", "5");
	SetDvarIfNotInizialized("mv_arrowcolor", "white");
	SetDvarIfNotInizialized("mv_blur", "3");
	SetDvarIfNotInizialized("mv_scrollcolor", "cyan");
	SetDvarIfNotInizialized("mv_selectcolor", "lightgreen");
	SetDvarIfNotInizialized("mv_backgroundcolor", "grey");
	SetDvarIfNotInizialized("mv_gametype", "");
	setDvarIfNotInizialized("mv_excludedmaps", "");
}
main()
{
	replaceFunc(maps\mp\zombies\_zm::intermission, ::_intermission);
}

player_intermission()
{
	self closemenu();
	self closeingamemenu();

	level endon("stop_intermission");
	self endon("disconnect");
	self endon("death");

	self.score = self.score_total;

	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;
	points = getstructarray("intermission", "targetname");
	if (!isDefined(points) || points.size == 0)
	{
		points = getentarray("info_intermission", "classname");

		location = getDvar("ui_zm_mapstartlocation");
		for(i = 0;i < points.size;i++)
	    {
		    if(points[i].script_string == location)
		    {
			    points = points[i];
		    }
	    }

		if (points.size < 1)
		{
			return;
		}
	}
	if (isdefined(self.game_over_bg))
		self.game_over_bg destroy();
	org = undefined;
	while (1)
	{
		points = array_randomize(points);
		i = 0;
		while (i < points.size)
		{
			point = points[i];
			if (!isDefined(org))
			{
				self spawn(point.origin, point.angles);
			}
			if (isDefined(points[i].target))
			{
				if (!isDefined(org))
				{
					org = spawn("script_model", self.origin + vectorScale((0, 0, -1), 60));
					org setmodel("tag_origin");
				}
				org.origin = points[i].origin;
				org.angles = points[i].angles;
				j = 0;
				while (j < get_players().size)
				{
					player = get_players()[j];
					player camerasetposition(org);
					player camerasetlookat();
					player cameraactivate(1);
					j++;
				}
				speed = 20;
				if (isDefined(points[i].speed))
				{
					speed = points[i].speed;
				}
				target_point = getstruct(points[i].target, "targetname");
				dist = distance(points[i].origin, target_point.origin);
				time = dist / speed;
				q_time = time * 0.25;
				if (q_time > 1)
				{
					q_time = 1;
				}
				org moveto(target_point.origin, time, q_time, q_time);
				org rotateto(target_point.angles, time, q_time, q_time);
				wait(time - q_time);
				wait q_time;
				i++;
				continue;
			}
			i++;
		}
	}
}

_intermission()
{

	level.intermission = 1;
	level notify("intermission");

	for (i = 0; i < level.players.size; i++)
	{
		level.players[i] thread player_intermission();
		level.players[i] hide();
		level.players[i] setclientuivisibilityflag("hud_visible", 0);

		level.players[i] setclientthirdperson(0);
		level.players[i] resetfov();
		level.players[i].health = 100;
		level.players[i] stopsounds();
		level.players[i] stopsounds();
	}

	mv_Begin(); // Wait until mapvote is done

	for (i = 0; i < level.players.size; i++)
	{
		level.players[i] notify("_zombie_game_over");
		level.players[i].sessionstate = "intermission";
	}

	players = get_players();
	i = 0;
	while (i < players.size)
	{
		setclientsysstate("levelNotify", "zi", players[i]);
		// players[ i ] setclientthirdperson( 0 );
		// players[ i ] resetfov();
		// players[ i ].health = 100;
		// players[ i ] thread [[ level.custom_intermission ]]();
		// players[ i ] stopsounds();
		i++;
	}
	wait 0.25;
	players = get_players();
	i = 0;
	while (i < players.size)
	{
		setclientsysstate("lsm", "0", players[i]);
		i++;
	}
	level thread maps\mp\zombies\_zm::zombie_game_over_death();
}

OnPlayerConnected()
{
	level endon("end_game");
	for (;;)
	{
		level waittill("connected", player);
		player thread FixBlur();
	}
}
_sui()
{
	self suicide();
}
mv_BeginWrapper()
{

	level thread mv_Begin();
}
FixBlur() // Reset blur effect to 0
{
	level endon("end_game");
	self waittill("spawned_player");
	self setblur(0, 0);
}
