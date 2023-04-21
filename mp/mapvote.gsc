#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

/*
	Mod: Mapvote Menu
	Developed by DoktorSAS
	Version: v1.1.0
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
	set mv_gametypes 		"dm;dm.cfg"				// This dvar can be used to have multiple gametypes with different maps, with this dvar you can load gamemode cfg files

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

	1.0.3:
	- mv_gametypes now work with @ instead of ;

	1.0.4:
	- mv_gametypes now work with ; instead of @ since the issue was not caused by the symbol

	1.1.0:
	- Addes support for 5 maps, it can be enable by setting the dvar mv_extramaps to 1
	- Code cleaned
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
	SetDvarIfNotInizialized("mv_gametypes", "dm;dm.cfg tdm;tdm.cfg dm;dm.cfg tdm;tdm.cfg sd;sd.cfg sd;sd.cfg");
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
	{
		mv_Begin();
	}

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

mv_Begin()
{
	level endon("mv_ended");
	if (getDvarInt("mv_enable") != 1) // Check if mapvote is enable
		return;						  // End if the mapvote its not enable

	if (!isDefined(level.mapvote_started))
	{
		level.mapvote_started = 1;

		mapslist = [];
		mapsIDs = [];
		mapsIDs = strTok(getDvar("mv_maps"), " ");
		//mapslist = mv_GetMapsThatCanBeVoted(mapsIDs); // Remove blacklisted maps
		mapsd = [];
		mapsd = level.mapsdata;
		times = 3;
		if(getDvarInt("mv_extramaps") == 1)
		{
			times = 5;
		}
			
		mapschoosed = mv_GetRandomMaps(mapsIDs, times);
		gametypes = strTok(getDvar("mv_gametypes"), " ");

		level.__mapvote["map1"] = mapsd[mapschoosed[0]];
		level.__mapvote["map2"] = mapsd[mapschoosed[1]];
		level.__mapvote["map3"] = mapsd[mapschoosed[2]];
		
		level.__mapvote["map1"].gametype = gametypes[randomIntRange(0, gametypes.size)];
		level.__mapvote["map2"].gametype = gametypes[randomIntRange(0, gametypes.size)];
		level.__mapvote["map3"].gametype = gametypes[randomIntRange(0, gametypes.size)];

		if(getDvarInt("mv_extramaps") == 1)
		{
			level.__mapvote["map4"] = mapsd[mapschoosed[3]];
			level.__mapvote["map5"] = mapsd[mapschoosed[4]];
			level.__mapvote["map4"].gametype = gametypes[randomIntRange(0, gametypes.size)];
			level.__mapvote["map5"].gametype = gametypes[randomIntRange(0, gametypes.size)];
		}
		

		//array1 = strTok(level.__mapvote["map1"].gametype, ";");
		//array2 = strTok(level.__mapvote["map2"].gametype, ";");
		//array3 = strTok(level.__mapvote["map3"].gametype, ";");

		foreach (player in level.players)
		{
			if (!is_bot(player))
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

ArrayRemoveElement(array, todelete)
{
	newarray = [];
	foreach(element in array) 
	{
		if(element != todelete)
		{
			newarray[newarray.size] = element;
		}
	}
	return newarray;
}
mv_GetRandomMaps(mapsIDs, times) // Select random map from the list
{
	mapschoosed = [];
	for (i = 0; i < times; i++)
	{
		index = randomIntRange(0, mapsIDs.size);
		map = mapsIDs[index];
		mapschoosed[i] = map;
		logPrint("map;"+map+";index;"+index+"\n");
		mapsIDs = ArrayRemoveElement(mapsIDs, map);
		//arrayremovevalue(mapsIDs, map);
	}

	return mapschoosed;
}

is_bot(entity) // Check if a players is a bot
{
	return isDefined(entity.pers["isBot"]) && entity.pers["isBot"];
}

mv_PlayerUI()
{
	// self endon("disconnect");
	level endon("game_ended");

	self setblur(getDvarFloat("mv_blur"), 1.5);

	scroll_color = getColor(getDvar("mv_scrollcolor"));
	bg_color = getColor(getDvar("mv_backgroundcolor"));
	self FreezeControlsAllowLook(0);
	boxes = [];
	boxes[0] = self CreateRectangle("CENTER", "CENTER", -220, -452, 205, 133, scroll_color, "white", 1, 0);
	boxes[1] = self CreateRectangle("CENTER", "CENTER", 0, -452, 205, 133, bg_color, "white", 1, 0);
	boxes[2] = self CreateRectangle("CENTER", "CENTER", 220, -452, 205, 133, bg_color, "white", 1, 0);

	self thread mv_PlayerFixAngle();

	level waittill("mv_start_animation");

	if(getDvarInt("mv_extramaps") == 1)
	{
		dynamic_position = 100;
		boxes[3] = self CreateRectangle("CENTER", "CENTER", -120, -452, 205, 133, bg_color, "white", 1, 0);
		boxes[4] = self CreateRectangle("CENTER", "CENTER", 120, -452, 205, 133, bg_color, "white", 1, 0);
		//boxes[5] = self CreateRectangle("CENTER", "CENTER", 220, -452, 205, 133, bg_color, "white", 2, 0);
		boxes[3] affectElement("y", 1.2, -50 + dynamic_position);
		boxes[4] affectElement("y", 1.2, -50 + dynamic_position);
		//boxes[5] affectElement("y", 1.2, -50 + dynamic_position);
		boxes[0] affectElement("y", 1.2, -100);
		boxes[1] affectElement("y", 1.2, -100);
		boxes[2] affectElement("y", 1.2, -100);
	}
	else
	{
		boxes[0] affectElement("y", 1.2, -50);
		boxes[1] affectElement("y", 1.2, -50);
		boxes[2] affectElement("y", 1.2, -50);
	}
	
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

	foreach(box in boxes) 
	{
		box affectElement("alpha", 0.2, 1);
	}

	index = 0;
	isVoting = 1;
	while (level.__mapvote["time"] > 0 && isVoting)
	{
		command = self waittill_any_return("left", "right", "select", "done");
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
			self.statusicon = "compassping_friendlyfiring_mp"; // Green dot
			vote = "vote" + (index + 1);
			level notify(vote);
			select_color = getColor(getDvar("mv_selectcolor"));
			boxes[index] affectElement("color", 0.2, select_color);
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
}

destroyBoxes(boxes)
{
	level endon("game_ended");
	level waittill("mv_destroy_hud");
	foreach (box in boxes)
	{
		box affectElement("alpha", 0.5, 0);
	}
	wait 0.5;
	foreach(box in boxes)
	{
		box destroyElem();
	}
}

mv_PlayerFixAngle()
{
	self endon("disconnect");
	level endon("game_ended");
	level waittill("mv_start_vote");
	angles = self getPlayerAngles();

	self waittill_any("left", "right");
	if (self getPlayerAngles() != angles)
		self setPlayerAngles(angles);
}

mv_VoteManager()
{
	level endon("game_ended");
	votes = [];
	votes[0] = spawnStruct();
	votes[1] = spawnStruct();
	votes[2] = spawnStruct();
	votes[0].votes = level CreateString(0, "objective", 1.5, "LEFT", "CENTER", -150, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
	votes[0].votes.label = "^" + getDvarInt("mv_votecolor");
	votes[0].map = level.__mapvote["map1"];

	votes[1].votes = level CreateString(0, "objective", 1.5, "CENTER", "CENTER", 75, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
	votes[1].votes.label = "^" + getDvarInt("mv_votecolor");
	votes[1].map = level.__mapvote["map2"];

	votes[2].votes = level CreateString(0, "objective", 1.5, "RIGHT", "CENTER", 290, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
	votes[2].votes.label = "^" + getDvarInt("mv_votecolor");
	votes[2].map = level.__mapvote["map3"];
	if(getDvarInt("mv_extramaps") == 1)
	{
		votes[3] = spawnStruct();
		votes[4] = spawnStruct();
		votes[5] = spawnStruct();
		votes[3].votes = level CreateString(0, "objective", 1.5, "LEFT", "CENTER", -50, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
		votes[3].votes.label = "^" + getDvarInt("mv_votecolor");
		votes[3].map = level.__mapvote["map4"];

		votes[4].votes = level CreateString(0, "objective", 1.5, "RIGHT", "CENTER", 190, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
		votes[4].votes.label = "^" + getDvarInt("mv_votecolor");
		votes[4].map = level.__mapvote["map5"];
	}

	for(i = 0; i < votes.size; i++) 
	{
		vote = votes[i];
		dynamic_position = 0;
		if(votes.size > 3 && i < 3)
		{
			dynamic_position = -50;	
		}
		else if(votes.size > 3 && i > 2)
		{
			dynamic_position = 100;
		}
		vote.value = 0;
		vote.votes.alpha = 0;
		vote.votes.y = 1 + dynamic_position;
		vote.votes affectElement("alpha", 1.6, 1);
	}


	isInVote = 1;
	index = 0;
	while (isInVote)
	{
		notify_value = level waittill_any_return("vote1", "vote2", "vote3", "vote4", "vote5", "mv_destroy_hud");

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
			case "vote4":
				index = 3;
				break;
			case "vote5":
				index = 4;
				break;
			}
			votes[index].value++;
			votes[index].votes setValue(votes[index].value);
		}
	}

	winner = mv_GetMostVotedMap(votes);
	map = winner.map;

	foreach(vote in votes) 
	{
		vote.votes affectElement("alpha", 0.5, 0);
	}

	mv_SetRotation(map.mapid, map.gametype);

	wait 0.5;

	foreach(vote in votes) 
	{
		vote.votes destroyElem();
	}

	/*votes[0].votes destroyElem();
	votes[1].votes destroyElem();
	votes[2].votes destroyElem();

	wait 5;*/
}

mv_GetMostVotedMap(votes)
{
	winner = votes[0];
	for (i = 1; i < votes.size; i++)
	{
		if (isDefined(votes[i]) && votes[i].value > winner.value)
		{
			winner = votes[i];
		}
	}

	return winner;
}

mv_SetRotation(mapid, gametype)
{
	array = strTok(gametype, ";");
	str = "";
	if (array.size > 1)
	{
		str = "exec " + array[1];
	}
	logPrint("mapvote//gametype//" + array[0] + "//executing//" + str + "\n");
	setdvar("g_gametype", array[0]);
	setdvar("sv_maprotationcurrent", str + " map " + mapid);
	setdvar("sv_maprotation", str + " map " + mapid);
	level notify("mv_ended");
}

mv_ServerUI()
{
	level endon("game_ended");

	mv_arrowcolor = GetColor(getDvar("mv_arrowcolor"));
	mv_votecolor = getDvar("mv_votecolor");

	buttons = level createServerFontString("objective", 2);
	buttons setText("^3[{+speed_throw}]              ^7Press ^3[{+gostand}] ^7or ^3[{+activate}] ^7to select              ^3[{+attack}]");
	buttons.hideWhenInMenu = 0;

	mapsUI = [];
	mapsUI[0] = spawnStruct();
	mapsUI[1] = spawnStruct();
	mapsUI[2] = spawnStruct();

	mapsUI[0].mapname = level CreateString("^7" + level.__mapvote["map1"].mapname + "\n" + gametypeToName(strTok(level.__mapvote["map1"].gametype, ";")[0]), "objective", 1.2, "CENTER", "CENTER", -220, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
	mapsUI[1].mapname = level CreateString("^7" + level.__mapvote["map2"].mapname + "\n" + gametypeToName(strTok(level.__mapvote["map2"].gametype, ";")[0]), "objective", 1.2, "CENTER", "CENTER", 0, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
	mapsUI[2].mapname = level CreateString("^7" + level.__mapvote["map3"].mapname + "\n" + gametypeToName(strTok(level.__mapvote["map3"].gametype, ";")[0]), "objective", 1.2, "CENTER", "CENTER", 220, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
	
	mapsUI[0].image = level DrawShader(level.__mapvote["map1"].image, -220, -310, 200, 129, (1, 1, 1), 1, 2, "LEFT", "CENTER", 1);
	mapsUI[0].image fadeovertime(0.5);
	mapsUI[1].image = level DrawShader(level.__mapvote["map2"].image, 0, -310, 200, 129, (1, 1, 1), 1, 2, "CENTER", "CENTER", 1);
	mapsUI[1].image fadeovertime(0.5);
	mapsUI[2].image = level DrawShader(level.__mapvote["map3"].image, 220, -310, 200, 129, (1, 1, 1), 1, 2, "RIGHT", "CENTER", 1);
	mapsUI[2].image fadeovertime(0.5);

	if(getDvarInt("mv_extramaps") == 1)
	{
		buttons setPoint("CENTER", "CENTER", 0, 150);
		arrow_right = level DrawShader("ui_scrollbar_arrow_right", 200, 290 + 50, 25, 25, mv_arrowcolor, 100, 2, "CENTER", "CENTER", 1);
		arrow_left = level DrawShader("ui_scrollbar_arrow_left", -200, 290 + 50, 25, 25, mv_arrowcolor, 100, 2, "CENTER", "CENTER", 1);
		mapsUI[3] = spawnStruct();
		mapsUI[4] = spawnStruct();

		mapsUI[3].mapname = level CreateString("^7" + level.__mapvote["map4"].mapname + "\n" + gametypeToName(strTok(level.__mapvote["map4"].gametype, ";")[0]), "objective", 1.2, "CENTER", "CENTER", -120, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
		mapsUI[4].mapname = level CreateString("^7" + level.__mapvote["map5"].mapname + "\n" + gametypeToName(strTok(level.__mapvote["map5"].gametype, ";")[0]), "objective", 1.2, "CENTER", "CENTER", 120, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);

		mapsUI[3].image = level DrawShader(level.__mapvote["map4"].image, -120, -310, 200, 129, (1, 1, 1), 1, 2, "LEFT", "CENTER", 1);
		mapsUI[3].image fadeovertime(0.5);
		mapsUI[4].image = level DrawShader(level.__mapvote["map5"].image, 120, -310, 200, 129, (1, 1, 1), 1, 2, "RIGHT", "CENTER", 1);
		mapsUI[4].image fadeovertime(0.5);

		// map name background - NOT WORKING BECAUSE OF HUD LIMITS
		//mapsUI[3].textbg = level DrawShader("black", -220, 186, 200, 32, (1, 1, 1), 1, 3, "LEFT", "CENTER", 1);
		//mapsUI[4].textbg = level DrawShader("black", 0, 186, 200, 32, (1, 1, 1), 1, 3, "CENTER", "CENTER", 1);
		//mapsUI[5].textbg = level DrawShader("black", 220, 186, 200, 32, (1, 1, 1), 1, 3, "RIGHT", "CENTER", 1);
	}
	else
	{
		buttons setPoint("CENTER", "CENTER", 0, 100);
		arrow_right = level DrawShader("ui_scrollbar_arrow_right", 200, 290, 25, 25, mv_arrowcolor, 100, 2, "CENTER", "CENTER", 1);
		arrow_left = level DrawShader("ui_scrollbar_arrow_left", -200, 290, 25, 25, mv_arrowcolor, 100, 2, "CENTER", "CENTER", 1);

		mapsUI[0].textbg = level DrawShader("black", -220, 186, 200, 32, (1, 1, 1), 1, 3, "LEFT", "CENTER", 1);
		mapsUI[1].textbg = level DrawShader("black", 0, 186, 200, 32, (1, 1, 1), 1, 3, "CENTER", "CENTER", 1);
		mapsUI[2].textbg = level DrawShader("black", 220, 186, 200, 32, (1, 1, 1), 1, 3, "RIGHT", "CENTER", 1);
	}

	level notify("mv_start_animation");

	for(i = 0; i < mapsUI.size; i++) 
	{
		map = mapsUI[i];
		dynamic_position = 0;
		if(mapsUI.size > 3 && i < 3)
		{
			dynamic_position = -50;	
		}
		else if(mapsUI.size > 3 && i > 2)
		{
			dynamic_position = 100;
		}
		map.mapname.alpha = 0;
		map.mapname affectElement("alpha", 1.6, 1);
		map.mapname.y = -9 + dynamic_position;
		if(isDefined(map.textbg))
		{
			map.textbg.y = 186 + dynamic_position;
		}
		map.image affectElement("y", 1.2, 89 + dynamic_position);
	}

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

	/*credits affectElement("alpha", 0.5, 0);
	buttons affectElement("alpha", 0.5, 0);
	mapUI1 affectElement("alpha", 0.5, 0);
	mapUI2 affectElement("alpha", 0.5, 0);
	mapUI3 affectElement("alpha", 0.5, 0);
	mapUIIMG1 affectElement("alpha", 0.5, 0);
	mapUIIMG2 affectElement("alpha", 0.5, 0);
	mapUIIMG3 affectElement("alpha", 0.5, 0);
	mapUIBTXT1 affectElement("alpha", 0.5, 0);
	mapUIBTXT2 affectElement("alpha", 0.5, 0);
	mapUIBTXT3 affectElement("alpha", 0.5, 0);
	arrow_right affectElement("alpha", 0.5, 0);
	arrow_left affectElement("alpha", 0.5, 0);*/

	foreach(map in mapsUI) 
	{
		map.mapname affectElement("alpha", 0.4, 0);
		if(isDefined(map.textbg))
		{
			map.textbg affectElement("alpha", 0.4, 0);
		}
		map.image affectElement("alpha", 0.4, 0);
	}

	credits affectElement("alpha", 0.5, 0);
	timer affectElement("alpha", 0.5, 0);

	buttons affectElement("alpha", 0.4, 0);
	arrow_right affectElement("alpha", 0.4, 0);
	arrow_left affectElement("alpha", 0.4, 0);
	// timer destroyElem();

	foreach (player in level.players)
	{
		player notify("done");
		player setblur(0, 0);
	}

	/*wait 1.2;

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
	return result != "";
}

gametypeToName(gametype)
{
	switch (tolower(gametype))
	{
	case "dm":
		return "Free for all";

	case "tdm":
		return "Team Deathmatch";

	case "sd":
		return "Search & Destroy";

	case "conf":
		return "Kill Confirmed";

	case "ctf":
		return "Capture the Flag";

	case "dom":
		return "Domination";

	case "dem":
		return "Demolition";

	case "gun":
		return "Gun Game";

	case "hq":
		return "Headquaters";

	case "koth":
		return "Hardpoint";

	case "oic":
		return "One in the chamber";

	case "oneflag":
		return "One-Flag CTF";

	case "sas":
		return "Sticks & Stones";

	case "shrp":
		return "Sharpshooter";

	}
	return "invalid";
}

buildmapsdata()
{
	level.mapsdata = [];

	/*foreach(id in mapsIDs)
	{
		mapsdata[id] = spawnStruct();
	}*/

	level.mapsdata["mp_la"] = spawnStruct();
	level.mapsdata["mp_la"].mapname = "Aftermath";
	level.mapsdata["mp_la"].mapid = "mp_la";
	level.mapsdata["mp_la"].image = "loadscreen_mp_la";

	level.mapsdata["mp_meltdown"] = spawnStruct();
	level.mapsdata["mp_meltdown"].mapname = "Meltdown";
	level.mapsdata["mp_meltdown"].mapid = "mp_meltdown";
	level.mapsdata["mp_meltdown"].image = "loadscreen_mp_meltdown";

	level.mapsdata["mp_overflow"] = spawnStruct();
	level.mapsdata["mp_overflow"].mapname = "Overflow";
	level.mapsdata["mp_overflow"].mapid = "mp_overflow";
	level.mapsdata["mp_overflow"].image = "loadscreen_mp_overflow";

	level.mapsdata["mp_nightclub"] = spawnStruct();
	level.mapsdata["mp_nightclub"].mapname = "Plaza";
	level.mapsdata["mp_nightclub"].mapid = "mp_nightclub";
	level.mapsdata["mp_nightclub"].image = "loadscreen_mp_nightclub";

	level.mapsdata["mp_dockside"] = spawnStruct();
	level.mapsdata["mp_dockside"].mapname = "Cargo";
	level.mapsdata["mp_dockside"].mapid = "mp_dockside";
	level.mapsdata["mp_dockside"].image = "loadscreen_mp_dockside";

	level.mapsdata["mp_carrier"] = spawnStruct();
	level.mapsdata["mp_carrier"].mapname = "Carrier";
	level.mapsdata["mp_carrier"].mapid = "mp_carrier";
	level.mapsdata["mp_carrier"].image = "loadscreen_mp_carrier";

	level.mapsdata["mp_drone"] = spawnStruct();
	level.mapsdata["mp_drone"].mapname = "Drone";
	level.mapsdata["mp_drone"].mapid = "mp_drone";
	level.mapsdata["mp_drone"].image = "loadscreen_mp_drone";

	level.mapsdata["mp_express"] = spawnStruct();
	level.mapsdata["mp_express"].mapname = "Express";
	level.mapsdata["mp_express"].mapid = "mp_express";
	level.mapsdata["mp_express"].image = "loadscreen_mp_express";

	level.mapsdata["mp_hijacked"] = spawnStruct();
	level.mapsdata["mp_hijacked"].mapname = "Hijacked";
	level.mapsdata["mp_hijacked"].mapid = "mp_hijacked";
	level.mapsdata["mp_hijacked"].image = "loadscreen_mp_hijacked";

	level.mapsdata["mp_raid"] = spawnStruct();
	level.mapsdata["mp_raid"].mapname = "Raid";
	level.mapsdata["mp_raid"].mapid = "mp_raid";
	level.mapsdata["mp_raid"].image = "loadscreen_mp_raid";

	level.mapsdata["mp_slums"] = spawnStruct();
	level.mapsdata["mp_slums"].mapname = "Slums";
	level.mapsdata["mp_slums"].mapid = "mp_slums";
	level.mapsdata["mp_slums"].image = "loadscreen_mp_Slums";

	level.mapsdata["mp_village"] = spawnStruct();
	level.mapsdata["mp_village"].mapname = "Standoff";
	level.mapsdata["mp_village"].mapid = "mp_village";
	level.mapsdata["mp_village"].image = "loadscreen_mp_village";

	level.mapsdata["mp_turbine"] = spawnStruct();
	level.mapsdata["mp_turbine"].mapname = "Turbine";
	level.mapsdata["mp_turbine"].mapid = "mp_turbine";
	level.mapsdata["mp_turbine"].image = "loadscreen_mp_Turbine";

	level.mapsdata["mp_socotra"] = spawnStruct();
	level.mapsdata["mp_socotra"].mapname = "Yemen";
	level.mapsdata["mp_socotra"].mapid = "mp_socotra";
	level.mapsdata["mp_socotra"].image = "loadscreen_mp_socotra";

	level.mapsdata["mp_nuketown_2020"] = spawnStruct();
	level.mapsdata["mp_nuketown_2020"].mapname = "Nuketown 2025";
	level.mapsdata["mp_nuketown_2020"].mapid = "mp_nuketown_2020";
	level.mapsdata["mp_nuketown_2020"].image = "loadscreen_mp_nuketown_2020";

	level.mapsdata["mp_downhill"] = spawnStruct();
	level.mapsdata["mp_downhill"].mapname = "Downhill";
	level.mapsdata["mp_downhill"].mapid = "mp_downhill";
	level.mapsdata["mp_downhill"].image = "loadscreen_mp_downhill";

	level.mapsdata["mp_mirage"] = spawnStruct();
	level.mapsdata["mp_mirage"].mapname = "Mirage";
	level.mapsdata["mp_mirage"].mapid = "mp_mirage";
	level.mapsdata["mp_mirage"].image = "loadscreen_mp_Mirage";

	level.mapsdata["mp_hydro"] = spawnStruct();
	level.mapsdata["mp_hydro"].mapname = "Hydro";
	level.mapsdata["mp_hydro"].mapid = "mp_hydro";
	level.mapsdata["mp_hydro"].image = "loadscreen_mp_Hydro";

	level.mapsdata["mp_skate"] = spawnStruct();
	level.mapsdata["mp_skate"].mapname = "Grind";
	level.mapsdata["mp_skate"].mapid = "mp_skate";
	level.mapsdata["mp_skate"].image = "loadscreen_mp_skate";

	level.mapsdata["mp_concert"] = spawnStruct();
	level.mapsdata["mp_concert"].mapname = "Encore";
	level.mapsdata["mp_concert"].mapid = "mp_concert";
	level.mapsdata["mp_concert"].image = "loadscreen_mp_concert";

	level.mapsdata["mp_magma"] = spawnStruct();
	level.mapsdata["mp_magma"].mapname = "Magma";
	level.mapsdata["mp_magma"].mapid = "mp_magma";
	level.mapsdata["mp_magma"].image = "loadscreen_mp_Magma";

	level.mapsdata["mp_vertigo"] = spawnStruct();
	level.mapsdata["mp_vertigo"].mapname = "Vertigo";
	level.mapsdata["mp_vertigo"].mapid = "mp_vertigo";
	level.mapsdata["mp_vertigo"].image = "loadscreen_mp_Vertigo";

	level.mapsdata["mp_studio"] = spawnStruct();
	level.mapsdata["mp_studio"].mapname = "Studio";
	level.mapsdata["mp_studio"].mapid = "mp_studio";
	level.mapsdata["mp_studio"].image = "loadscreen_mp_Studio";

	level.mapsdata["mp_uplink"] = spawnStruct();
	level.mapsdata["mp_uplink"].mapname = "Uplink";
	level.mapsdata["mp_uplink"].mapid = "mp_uplink";
	level.mapsdata["mp_uplink"].image = "loadscreen_mp_Uplink";

	level.mapsdata["mp_bridge"] = spawnStruct();
	level.mapsdata["mp_bridge"].mapname = "Detour";
	level.mapsdata["mp_bridge"].mapid = "mp_bridge";
	level.mapsdata["mp_bridge"].image = "loadscreen_mp_bridge";

	level.mapsdata["mp_castaway"] = spawnStruct();
	level.mapsdata["mp_castaway"].mapname = "Cove";
	level.mapsdata["mp_castaway"].mapid = "mp_castaway";
	level.mapsdata["mp_castaway"].image = "loadscreen_mp_castaway";

	level.mapsdata["mp_dig"] = spawnStruct();
	level.mapsdata["mp_paintball"].mapname = "Rush";
	level.mapsdata["mp_paintball"].mapid = "mp_paintball";
	level.mapsdata["mp_paintball"].image = "loadscreen_mp_paintball";

	level.mapsdata["mp_dig"] = spawnStruct();
	level.mapsdata["mp_dig"].mapname = "Dig";
	level.mapsdata["mp_dig"].mapid = "mp_dig";
	level.mapsdata["mp_dig"].image = "loadscreen_mp_Dig";

	level.mapsdata["mp_frostbite"] = spawnStruct();
	level.mapsdata["mp_frostbite"].mapname = "Frost";
	level.mapsdata["mp_frostbite"].mapid = "mp_frostbite";
	level.mapsdata["mp_frostbite"].image = "loadscreen_mp_frostbite";

	level.mapsdata["mp_pod"] = spawnStruct();
	level.mapsdata["mp_pod"].mapname = "Pod";
	level.mapsdata["mp_pod"].mapid = "mp_pod";
	level.mapsdata["mp_pod"].image = "loadscreen_mp_Pod";

	level.mapsdata["mp_takeoff"] = spawnStruct();
	level.mapsdata["mp_takeoff"].mapname = "Takeoff";
	level.mapsdata["mp_takeoff"].mapid = "mp_takeoff";
	level.mapsdata["mp_takeoff"].image = "loadscreen_mp_Takeoff";

	level.mapsdata["mp_dockside"] = spawnStruct();
	level.mapsdata["mp_dockside"].mapname = "Cargo";
	level.mapsdata["mp_dockside"].mapid = "mp_dockside";
	level.mapsdata["mp_dockside"].image = "loadscreen_mp_dockside";
	return level.mapsdata;
}
isValidColor(value)
{
	return value == "0" || value == "1" || value == "2" || value == "3" || value == "4" || value == "5" || value == "6" || value == "7";
}
GetColor(color)
{
	switch (tolower(color))
	{
	case "red":
		return (0.960, 0.180, 0.180);

	case "black":
		return (0, 0, 0);

	case "grey":
		return (0.035, 0.059, 0.063);

	case "purple":
		return (1, 0.282, 1);

	case "pink":
		return (1, 0.623, 0.811);

	case "green":
		return (0, 0.69, 0.15);

	case "blue":
		return (0, 0, 1);

	case "lightblue":
	case "light blue":
		return (0.152, 0329, 0.929);

	case "lightgreen":
	case "light green":
		return (0.09, 1, 0.09);

	case "orange":
		return (1, 0662, 0.035);

	case "yellow":
		return (0.968, 0.992, 0.043);

	case "brown":
		return (0.501, 0.250, 0);

	case "cyan":
		return (0, 1, 1);

	case "white":
		return (1, 1, 1);

	}
}
// Drawing
CreateString(input, font, fontScale, align, relative, x, y, color, alpha, glowColor, glowAlpha, sort, isValue)
{
	if (self != level)
	{
		hud = self createFontString(font, fontScale);
	}
	else
	{
		hud = level createServerFontString(font, fontScale);
	}

	if (!isDefined(isValue))
	{
		hud setText(input);
	}
	else
	{
		hud setValue(int(input));
	}

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
	boxElem.elemType = "icon";
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
