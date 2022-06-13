#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_hud_util;

/*
	Mod: Mapvote Menu
	Developed by DoktorSAS
	Version: 2.0.1

	2.0.1:
	- Ported new design
	- Timer fixed
	- Fixed UI animations
	- Removed usless functions
	- Fixed UI removing screen text
	- Added animations during vote
	- Fixed design issues
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
	SetDvarIfNotInizialized("mv_maps", "zm_tomb zm_buried zm_town zm_busdepot zm_farm zm_transit zm_prison zm_highrises zm_nuked");

	// PreCache maps images
	mapsIDs = [];
	mapsIDs = strTok(getDvar("mv_maps"), " ");
	mapsd = [];
	mapsd = getMapsData(mapsIDs);

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


mv_Begin()
{
	// logPrint("mapvote//before\n");
	if (getDvarInt("mv_enable") != 1) // Check if mapvote is enable
		return;						  // End if the mapvote its not enable
	// logPrint("mapvote//after\n");
	if (!isDefined(level.mapvote_started))
	{
		level.mapvote_started = 1;
		// level thread mv_OverflowFix(); // Should be not needed anymore, but to be safe i leave it here
		mapslist = [];
		mapsIDs = [];
		mapsIDs = strTok(getDvar("mv_maps"), " ");
		mapslist = mv_GetMapsThatCanBeVoted(mapsIDs); // Remove blacklisted maps
		mapsd = [];
		mapsd = getMapsData();

		mapschoosed = mv_GetRandomMaps(mapsIDs);
		level.__mapvote["map1"] = mapsd[mapschoosed[0]];
		level.__mapvote["map2"] = mapsd[mapschoosed[1]];
		level.__mapvote["map3"] = mapsd[mapschoosed[2]];

		// logPrint("mapvote//mapid//"+level.__mapvote["map1"].mapid+"//name//"+ level.__mapvote["map1"].mapname + "\n" );
		// logPrint("mapvote//mapid//"+level.__mapvote["map2"].mapid+"//name//"+ level.__mapvote["map2"].mapname + "\n" );
		// logPrint("mapvote//mapid//"+level.__mapvote["map3"].mapid+"//name//"+ level.__mapvote["map3"].mapname + "\n" );

		foreach (player in level.players)
		{
			if (!player is_bot())
				player thread mv_PlayerUI();
		}
		wait 0.2;
		level thread mv_ServerUI();

		mv_VoteManager();
	}
}

mv_GetMapsThatCanBeVoted(mapslist)
{
	if (getDvar("mv_excludedmaps") != "")
	{
		maps = [];
		maps = strTok(getDvar("mv_excludedmaps"), " ");
		foreach (map in maps)
		{
			arrayremovevalue(mapslist, map);
		}
	}
	return mapslist;
}

mv_GetRandomMaps(mapsIDs) // Select random map from the list
{
	mapschoosed = [];
	for (i = 0; i < 3; i++)
	{
		index = randomIntRange(0, mapsIDs.size);
		map = mapsIDs[index];
		// logPrint("map;"+map+";index;"+index+"\n");
		arrayremovevalue(mapsIDs, map);
		mapschoosed[i] = map;
	}

	return mapschoosed;
}

is_bot() // Check if a players is a bot
{
	return isDefined(self.pers["isBot"]) && self.pers["isBot"];
}

mv_PlayerUI()
{
	self setblur(getDvarFloat("mv_blur"), 1.5);

	precacheshader("menu_zm_popup");

	scroll_color = getColor(getDvar("mv_scrollcolor"));
	bg_color = getColor(getDvar("mv_backgroundcolor"));
	self FreezeControlsAllowLook(0);
	boxes = [];
	boxes[0] = self createRectangle("CENTER", "CENTER", -220, -50, 205, 131, scroll_color, "menu_zm_popup", 2, 0);
	boxes[1] = self createRectangle("CENTER", "CENTER", 0, -50, 205, 131, bg_color, "menu_zm_popup", 2, 0);
	boxes[2] = self createRectangle("CENTER", "CENTER", 220, -50, 205, 131, bg_color, "menu_zm_popup", 2, 0);

	boxes[0] affectElement("y", 1.2, -50);
	boxes[1] affectElement("y", 1.2, -50);
	boxes[2] affectElement("y", 1.2, -50);

	self thread mv_PlayerFixAngle();
	self thread destroyBoxes(boxes);

	self notifyonplayercommand("left", "+attack");
	self notifyonplayercommand("right", "+speed_throw");
	self notifyonplayercommand("left", "+moveright");
	self notifyonplayercommand("right", "+moveleft");
	self notifyonplayercommand("select", "+usereload");
	self notifyonplayercommand("select", "+activate");
	self notifyonplayercommand("select", "+gostand");

	self.statusicon = "compassping_enemy"; // Red dot
	level waittill("mv_start_vote");
	boxes[0] affectElement("alpha", 0.2, 1);
	boxes[1] affectElement("alpha", 0.2, 1);
	boxes[2] affectElement("alpha", 0.2, 1);
	index = 0;
	isVoting = 1;
	while (level.__mapvote["time"] > 0 && isVoting)
	{
		command = self waittill_any_return("left", "right", "select");
		if (command == "right")
		{
			index++;
			if (index == boxes.size)
				index = 0;
		}
		else if (command == "left")
		{
			index--;
			if (index < 0)
				index = boxes.size - 1;
		}

		if (command == "select")
		{
			isVoting = 0;
		}
		else
		{
			for (i = 0; i < boxes.size; i++)
			{
				if (i != index)
					boxes[i] affectElement("color", 0.2, bg_color);
				else
					boxes[i] affectElement("color", 0.2, scroll_color);
			}
		}
	}
	if (!isVoting)
	{
		self.statusicon = "compassping_friendlyfiring_mp"; // Green dot
		vote = "vote" + (index + 1);
		level notify(vote);
		select_color = getColor(getDvar("mv_selectcolor"));
		boxes[index] affectElement("color", 0.2, select_color);
		level waittill("mv_destroy_hud");
	}
}

destroyBoxes(boxes)
{
	// self endon("disconnect");
	level endon("game_ended");
	level waittill("mv_destroy_hud");
	foreach (box in boxes)
	{
		box affectElement("alpha", 0.5, 0);
	}
	/*wait 1.2;
	foreach(box in boxes)
	{
		box destroyElem();
	}*/
}

mv_PlayerFixAngle()
{
	self endon("disconnect");
	level endon("end_game");
	level waittill("mv_start_vote");
	angles = self getPlayerAngles();

	self waittill_any("left", "right");
	if (self getPlayerAngles() != angles)
		self setPlayerAngles(angles);
}

mv_VoteManager()
{
	votes = [];
	votes[0] = spawnStruct();
	votes[0].votes = level createServerFontString("objective", 1.6);
	votes[0].votes setPoint("LEFT", "CENTER", -165 + 15, -325);
	votes[0].votes.label = &"^" + getDvarInt("mv_votecolor");
	votes[0].votes.sort = 4;
	votes[0].value = 0;
	votes[0].map = level.__mapvote["map1"];

	votes[1] = spawnStruct();
	votes[1].votes = level createServerFontString("objective", 1.6);
	votes[1].votes setPoint("CENTER", "CENTER", 55 + 15, -325);
	votes[1].votes.label = &"^" + getDvarInt("mv_votecolor");
	votes[1].votes.sort = 4;
	votes[1].value = 0;
	votes[1].map = level.__mapvote["map2"];

	votes[2] = spawnStruct();
	votes[2].votes = level createServerFontString("objective", 1.6);
	votes[2].votes setPoint("RIGHT", "CENTER", 165 + 55 + 55 + 15, -325);
	votes[2].votes.label = &"^" + getDvarInt("mv_votecolor");
	votes[2].votes.sort = 4;
	votes[2].value = 0;
	votes[2].map = level.__mapvote["map3"];

	votes[0].votes setValue(0);
	votes[1].votes setValue(0);
	votes[2].votes setValue(0);

	votes[0].votes affectElement("y", 1.2, -14);
	votes[1].votes affectElement("y", 1.2, -14);
	votes[2].votes affectElement("y", 1.2, -14);

	votes[0].hideWhenInMenu = 1;
	votes[1].hideWhenInMenu = 1;
	votes[2].hideWhenInMenu = 1;

	isInVote = 1;
	while (isInVote)
	{
		notify_value = level waittill_any_return("vote1", "vote2", "vote3", "mv_destroy_hud");

		if (notify_value == "mv_destroy_hud")
		{
			break;
		}
		else
		{
			switch (notify_value)
			{
			case "vote1":
				index = 0;
				break;
			case "vote2":
				index = 1;
				break;
			case "vote3":
				index = 2;
				break;
			}
			votes[index].value++;
			votes[index].votes setValue(votes[index].value);
		}
	}

	winner = mv_GetMostVotedMap(votes);
	map = winner.map;

	votes[0].votes affectElement("alpha", 0.5, 0);
	votes[1].votes affectElement("alpha", 0.5, 0);
	votes[2].votes affectElement("alpha", 0.5, 0);

	mv_SetRotation(map.mapid);

	wait 1.2;

	/*votes[0].votes destroyElem();
	votes[1].votes destroyElem();
	votes[2].votes destroyElem();

	wait 5;*/
}

mv_GetMostVotedMap(votes)
{
	winner = votes[0];
	tie = [];
	for (i = 1; i < votes.size; i++)
	{
		// logPrint("map;"+i+";votes;"+votes[i-1].value+"\n");
		if (votes[i].value > winner.value)
		{
			winner = votes[i];
		}
	}

	return winner;
}
mv_SetRotation(mapid)
{
	setdvar( "sv_maprotationcurrent", mapid );
	setdvar( "sv_maprotation", mapid );
	level notify("mv_ended");
}

mv_ServerUI()
{
	preCacheShader(level.__mapvote["map1"].shader);
	preCacheShader(level.__mapvote["map2"].shader);
	preCacheShader(level.__mapvote["map3"].shader);

	// logPrint("mapvote//mv_ServerUI " + getTime()/1000 + "\n");

	buttons = level createServerFontString("objective", 2);
	buttons setText("^7 ^3[{+speed_throw}]              ^7Press ^3[{+gostand}] ^7or ^3[{+activate}] ^7to select              ^3[{+attack}] ^7");
	buttons setPoint("CENTER", "CENTER", 0, 100);
	mapUIBTXT3.alpha = 0;
	buttons.hideWhenInMenu = 1;

	mv_votecolor = getDvar("mv_votecolor");

	mapUI1 = level createString("^7" + level.__mapvote["map1"].mapname, "objective", 1.5, "CENTER", "CENTER", -220, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 1);
	mapUI2 = level createString("^7" + level.__mapvote["map2"].mapname, "objective", 1.5, "CENTER", "CENTER", 0, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 1);
	mapUI3 = level createString("^7" + level.__mapvote["map3"].mapname, "objective", 1.5, "CENTER", "CENTER", 220, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 1);

	mapUIIMG1 = level drawshader(level.__mapvote["map1"].image, -220, -310, 200, 117, (1, 1, 1), 1, 1, "LEFT", "CENTER", 1);
	mapUIIMG1 fadeovertime(0.5);
	mapUIIMG2 = level drawshader(level.__mapvote["map2"].image, 0, -310, 200, 117, (1, 1, 1), 1, 1, "CENTER", "CENTER", 1);
	mapUIIMG2 fadeovertime(0.5);
	mapUIIMG3 = level drawshader(level.__mapvote["map3"].image, 220, -310, 200, 117, (1, 1, 1), 1, 1, "RIGHT", "CENTER", 1);
	mapUIIMG3 fadeovertime(0.5);

	mapUIBTXT1 = level drawshader("black", -220, -325, 194, 30, (1, 1, 1), 0.7, 2, "LEFT", "CENTER", 1);
	mapUIBTXT2 = level drawshader("black", 0, -325, 194, 30, (1, 1, 1), 0.7, 2, "CENTER", "CENTER", 1);
	mapUIBTXT3 = level drawshader("black", 220, -325, 194, 30, (1, 1, 1), 0.7, 2, "RIGHT", "CENTER", 1);

	mapUI1 affectElement("y", 1.2, -14);
	mapUI2 affectElement("y", 1.2, -14);
	mapUI3 affectElement("y", 1.2, -14);
	mapUIIMG1 affectElement("y", 1.2, 89);
	mapUIIMG2 affectElement("y", 1.2, 89);
	mapUIIMG3 affectElement("y", 1.2, 89);

	mapUIBTXT1 affectElement("y", 1.2, 176);
	mapUIBTXT2 affectElement("y", 1.2, 176);
	mapUIBTXT3 affectElement("y", 1.2, 176);
	
	buttons affectElement("alpha", 1.5, 0.8);

	mv_arrowcolor = GetColor(getDvar("mv_arrowcolor"));

	arrow_right = drawshader("ui_scrollbar_arrow_right", 200, 290, 25, 25, mv_arrowcolor, 100, 2, "CENTER", "CENTER", 1);
	arrow_left = drawshader("ui_scrollbar_arrow_left", -200, 290, 25, 25, mv_arrowcolor, 100, 2, "CENTER", "CENTER", 1);

	wait 1;
	level notify("mv_start_vote");

	mv_sentence = getDvar("mv_sentence");
	mv_socialname = getDvar("mv_socialname");
	mv_sociallink = getDvar("mv_sociallink");
	credits = level createServerFontString("objective", 1.2);
	credits setPoint("BOTTOM_LEFT", "BOTTOM_LEFT");
	credits setText(mv_sentence + "\nDeveloped by @^5DoktorSAS ^7\n" + mv_socialname + ": " + mv_sociallink);

	timer = level createServerFontString("objective", 2);
	timer setPoint("CENTER", "BOTTOM", "CENTER", "CENTER");
	timer setTimer(level.__mapvote["time"]);
	wait level.__mapvote["time"];
	level notify("mv_destroy_hud");
	// logPrint("mapvote//mv_ServerUI " + getTime()/1000 + "\n");

	mapUIIMG1 affectElement("alpha", 0.4, 0);
	mapUIIMG2 affectElement("alpha", 0.4, 0);
	mapUIIMG3 affectElement("alpha", 0.4, 0);

	mapUI1 affectElement("alpha", 0.5, 0);
	mapUI2 affectElement("alpha", 0.5, 0);
	mapUI3 affectElement("alpha", 0.5, 0);

	mapUIBTXT1 affectElement("alpha", 0.4, 0);
	mapUIBTXT2 affectElement("alpha", 0.4, 0);
	mapUIBTXT3 affectElement("alpha", 0.4, 0);

	credits affectElement("alpha", 0.5, 0);
	timer affectElement("alpha", 0.5, 0);

	buttons affectElement("alpha", 0.4, 0);
	arrow_right affectElement("alpha", 0.4, 0);
	arrow_left affectElement("alpha", 0.4, 0);

	foreach (player in level.players)
	{
		player notify("done");
		player setblur(0, 0);
	}

	/*if(mv_credits)
		credits destroyElem();
	timer destroyElem();

	buttons destroyElem();
	mapUI1 destroyElem();
	mapUI2 destroyElem();
	mapUI3 destroyElem();
	mapUIIMG1 destroyElem();
	mapUIIMG2 destroyElem();
	mapUIIMG3 destroyElem();
	mapUIBTXT1 destroyElem();
	mapUIBTXT2 destroyElem();
	mapUIBTXT3 destroyElem();
	arrow_right destroyElem();
	arrow_left destroyElem();*/
}
SetDvarIfNotInizialized(dvar, value)
{
	if (!IsInizialized(dvar))
		setDvar(dvar, value);
}
IsInizialized(dvar)
{
	result = getDvar(dvar);
	return result != undefined || result != "";
}
getMapsData(mapsIDs)
{
	mapsdata = [];

	foreach (id in mapsIDs)
	{
		mapsdata[id] = spawnStruct();
	}

	mapsdata["zm_tomb"] = spawnStruct();
	mapsdata["zm_tomb"].mapname = "Origins";
	mapsdata["zm_tomb"].mapid = "exec zm_classic_tomb.cfg map zm_tomb";
	mapsdata["zm_tomb"].image = "loadscreen_zm_tomb_zclassic_tomb";

	mapsdata["zm_buried"] = spawnStruct();
	mapsdata["zm_buried"].mapname = "Buried";
	mapsdata["zm_buried"].mapid = "exec zm_classic_processing.cfg map zm_buried";
	mapsdata["zm_buried"].image = "loadscreen_zm_buried_zclassic_processing";

	mapsdata["zm_town"] = spawnStruct();
	mapsdata["zm_town"].mapname = "Town";
	mapsdata["zm_town"].mapid = "exec zm_standard_town.cfg map zm_transit";
	mapsdata["zm_town"].image = "loadscreen_zm_transit_zstandard_transit";

	mapsdata["zm_busdepot"] = spawnStruct();
	mapsdata["zm_busdepot"].mapname = "Bus Depot";
	mapsdata["zm_busdepot"].mapid = "exec zm_standard_transit.cfg map zm_transit";
	mapsdata["zm_busdepot"].image = "loadscreen_zm_transit_zstandard_transit";

	mapsdata["zm_farm"] = spawnStruct();
	mapsdata["zm_farm"].mapname = "Farm";
	mapsdata["zm_farm"].mapid = "exec zm_standard_farm.cfg map zm_transit";
	mapsdata["zm_farm"].image = "loadscreen_zm_transit_zstandard_farm";

	mapsdata["zm_transit"] = spawnStruct();
	mapsdata["zm_transit"].mapname = "Transit";
	mapsdata["zm_transit"].mapid = "exec zm_classic_transit.cfg map zm_transit";
	mapsdata["zm_transit"].image = "loadscreen_zm_transit_zclassic_transit";

	mapsdata["zm_prison"] = spawnStruct();
	mapsdata["zm_prison"].mapname = "Mob of the dead";
	mapsdata["zm_prison"].mapid = "exec zm_classic_prison.cfg map zm_prison";
	mapsdata["zm_prison"].image = "loadscreen_zm_prison_zclassic_prison";

	mapsdata["zm_highrises"] = spawnStruct();
	mapsdata["zm_highrises"].mapname = "Die rise";
	mapsdata["zm_highrises"].mapid = "exec zm_classic_rooftop.cfg map zm_highrise";
	mapsdata["zm_highrises"].image = "loadscreen_zm_highrise_zclassic_rooftop";

	mapsdata["zm_nuked"] = spawnStruct();
	mapsdata["zm_nuked"].mapname = "Nuketown";
	mapsdata["zm_nuked"].mapid = "exec zm_standard_nuked.cfg map zm_nuked";
	mapsdata["zm_nuked"].image = "loadscreen_zm_nuked_zstandard_nuked";

	mapsdata["zm_tomb_grief"] = spawnStruct();
	mapsdata["zm_tomb_grief"].mapname = "Origins";
	mapsdata["zm_tomb_grief"].mapid = "exec zm_grief_tomb.cfg map zm_tomb";
	mapsdata["zm_tomb_grief"].image = "loadscreen_zm_tomb_zclassic_tomb";

	mapsdata["zm_buried_grief"] = spawnStruct();
	mapsdata["zm_buried_grief"].mapname = "Buried";
	mapsdata["zm_buried_grief"].mapid = "exec zm_grief_processing.cfg map zm_buried";
	mapsdata["zm_buried_grief"].image = "loadscreen_zm_buried_zclassic_processing";

	mapsdata["zm_town_grief"] = spawnStruct();
	mapsdata["zm_town_grief"].mapname = "Town";
	mapsdata["zm_town_grief"].mapid = "exec zm_grief_town.cfg map zm_transit";
	mapsdata["zm_town_grief"].image = "loadscreen_zm_transit_zstandard_transit";

	mapsdata["zm_busdepot_grief"] = spawnStruct();
	mapsdata["zm_busdepot_grief"].mapname = "Bus Depot";
	mapsdata["zm_busdepot_grief"].mapid = "exec zm_grief_transit.cfg map zm_transit";
	mapsdata["zm_busdepot_grief"].image = "loadscreen_zm_transit_zstandard_transit";

	mapsdata["zm_farm_grief"] = spawnStruct();
	mapsdata["zm_farm_grief"].mapname = "Farm";
	mapsdata["zm_farm_grief"].mapid = "exec zm_grief_farm.cfg map zm_transit";
	mapsdata["zm_farm_grief"].image = "loadscreen_zm_transit_zstandard_farm";

	mapsdata["zm_transit_grief"] = spawnStruct();
	mapsdata["zm_transit_grief"].mapname = "Transit";
	mapsdata["zm_transit_grief"].mapid = "exec zm_grief_transit.cfg map zm_transit";
	mapsdata["zm_transit_grief"].image = "loadscreen_zm_transit_zclassic_transit";

	mapsdata["zm_prison_grief"] = spawnStruct();
	mapsdata["zm_prison_grief"].mapname = "Mob of the dead";
	mapsdata["zm_prison_grief"].mapid = "exec zm_grief_prison.cfg map zm_prison";
	mapsdata["zm_prison_grief"].image = "loadscreen_zm_prison_zclassic_prison";

	mapsdata["zm_cellblock_grief"] = spawnStruct();
	mapsdata["zm_cellblock_grief"].mapname = "Cellblock";
	mapsdata["zm_cellblock_grief"].mapid = "exec zm_grief_cellblock.cfg map zm_prison";
	mapsdata["zm_cellblock_grief"].image = "loadscreen_zm_prison_zgrief_cellblock";

	mapsdata["zm_highrises_grief"] = spawnStruct();
	mapsdata["zm_highrises_grief"].mapname = "Die rise";
	mapsdata["zm_highrises_grief"].mapid = "exec zm_grief_rooftop.cfg map zm_highrise";
	mapsdata["zm_highrises_grief"].image = "loadscreen_zm_highrise_zclassic_rooftop";

	mapsdata["zm_nuked_grief"] = spawnStruct();
	mapsdata["zm_nuked_grief"].mapname = "Nuketown";
	mapsdata["zm_nuked_grief"].mapid = "exec zm_grief_nuked.cfg map zm_nuked";
	mapsdata["zm_nuked_grief"].image = "loadscreen_zm_nuked_zstandard_nuked";

	mapsdata["zm_diner_borough"] = spawnStruct();
	mapsdata["zm_diner_borough"].mapname = "Borough Diner";
	mapsdata["zm_diner_borough"].mapid = "exec zm_cleansed_street.cfg map zm_buried";
	mapsdata["zm_diner_borough"].image = "loadscreen_zm_transit_dr_zcleansed_diner";

	return mapsdata;
}
isValidColor(value)
{
	return value == "0" || value == "1" || value == "2" || value == "3" || value == "4" || value == "5" || value == "6" || value == "7";
}
// CMD not working on zombies
addCmd(cmd, function)
{
	self notifyOnPlayerCommand(cmd + "_cmd", cmd);
	self thread cmdManager(cmd + "_cmd", function);
}
cmdManager(cmd, function)
{
	self endon("disconnect");
	self endon("round_ended");
	level endon("game_ended");
	level endon("round_end_finished");
	for (;;)
	{
		self waittill(cmd);
		self [[function]] ();
	}
}
GetColor(color)
{
	switch (tolower(color))
	{
	case "red":
		return (0.960, 0.180, 0.180);
		break;
	case "black":
		return (0, 0, 0);
		break;
	case "grey":
		return (0.035, 0.059, 0.063);
		break;
	case "purple":
		return (1, 0.282, 1);
		break;
	case "pink":
		return (1, 0.623, 0.811);
		break;
	case "green":
		return (0, 0.69, 0.15);
		break;
	case "blue":
		return (0, 0, 1);
		break;
	case "lightblue":
	case "light blue":
		return (0.152, 0329, 0.929);
		break;
	case "lightgreen":
	case "light green":
		return (0.09, 1, 0.09);
		break;
	case "orange":
		return (1, 0662, 0.035);
		break;
	case "yellow":
		return (0.968, 0.992, 0.043);
		break;
	case "brown":
		return (0.501, 0.250, 0);
		break;
	case "cyan":
		return (0, 1, 1);
		break;
	case "white":
		return (1, 1, 1);
		break;
	}
}
// Drawing
// Drawing
CreateString(input, font, fontScale, align, relative, x, y, color, alpha, glowColor, glowAlpha, sort, isLevel, isValue)
{
	if (!isDefined(isLevel))
		hud = self createFontString(font, fontScale);
	else
		hud = level createServerFontString(font, fontScale);
	if (!isDefined(isValue))
		hud setText(input);
	else
		hud setValue(input);
	hud setPoint(align, relative, x, y);
	hud.color = color;
	hud.alpha = alpha;
	hud.glowColor = glowColor;
	hud.glowAlpha = glowAlpha;
	hud.sort = sort;
	hud.alpha = alpha;
	hud.archived = 0;
	hud.hideWhenInMenu = 0;
	return hud;
}
CreateRectangle(align, relative, x, y, width, height, color, shader, sort, alpha)
{
	boxElem = newClientHudElem(self);
	boxElem.elemType = "bar";
	boxElem.width = width;
	boxElem.height = height;
	boxElem.align = align;
	boxElem.relative = relative;
	boxElem.xOffset = 0;
	boxElem.yOffset = 0;
	boxElem.children = [];
	boxElem.sort = sort;
	boxElem.color = color;
	boxElem.alpha = alpha;
	boxElem setParent(level.uiParent);
	boxElem setShader(shader, width, height);
	boxElem.hidden = 0;
	boxElem setPoint(align, relative, x, y);
	boxElem.hideWhenInMenu = 0;
	boxElem.archived = 0;
	return boxElem;
}
CreateNewsBar(align, relative, x, y, width, height, color, shader, sort, alpha)
{ // Not mine
	barElemBG = newClientHudElem(self);
	barElemBG.elemType = "bar";
	barElemBG.width = width;
	barElemBG.height = height;
	barElemBG.align = align;
	barElemBG.relative = relative;
	barElemBG.xOffset = 0;
	barElemBG.yOffset = 0;
	barElemBG.children = [];
	barElemBG.sort = sort;
	barElemBG.color = color;
	barElemBG.alpha = alpha;
	barElemBG setParent(level.uiParent);
	barElemBG setShader(shader, width, height);
	barElemBG.hidden = 0;
	barElemBG setPoint(align, relative, x, y);
	barElemBG.hideWhenInMenu = 0;
	barElemBG.archived = 0;
	return barElemBG;
}
DrawText(text, font, fontscale, x, y, color, alpha, glowcolor, glowalpha, sort)
{
	hud = self createfontstring(font, fontscale);
	hud setText(text);
	hud.x = x;
	hud.y = y;
	hud.color = color;
	hud.alpha = alpha;
	hud.glowcolor = glowcolor;
	hud.glowalpha = glowalpha;
	hud.sort = sort;
	hud.alpha = alpha;
	hud.hideWhenInMenu = 0;
	hud.archived = 0;
	return hud;
}
DrawShader(shader, x, y, width, height, color, alpha, sort, align, relative, isLevel)
{
	if (isDefined(isLevel))
		hud = newhudelem();
	else
		hud = newclienthudelem(self);
	hud.elemtype = "icon";
	hud.color = color;
	hud.alpha = alpha;
	hud.sort = sort;
	hud.children = [];
	if (isDefined(align))
		hud.align = align;
	if (isDefined(relative))
		hud.relative = relative;
	hud setparent(level.uiparent);
	hud.x = x;
	hud.y = y;
	hud setshader(shader, width, height);
	hud.hideWhenInMenu = 0;
	hud.archived = 0;
	return hud;
}
// Animations
affectElement(type, time, value)
{
	if (type == "x" || type == "y")
		self moveOverTime(time);
	else
		self fadeOverTime(time);
	if (type == "x")
		self.x = value;
	if (type == "y")
		self.y = value;
	if (type == "alpha")
		self.alpha = value;
	if (type == "color")
		self.color = value;
}
// Just for testing
empty() {}
