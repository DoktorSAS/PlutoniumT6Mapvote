#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

/*
	Mod: Mapvote Menu
	Developed by DoktorSAS
	Version: v1.1.1
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

	1.1.1:
	- Implemented mv_allowchangevote dvar to allow or not the player to change his vote when time is still running
	- Massive code reorganization for better readability
	- Optimized of resources
	- Implemented mv_minplayerstovote dvar to set the minimum number of players required to start the mapvote
*/

init()
{
	precacheStatusIcon("compassping_friendlyfiring_mp");
	precacheStatusIcon("compassping_enemy");
	precacheshader("white");
	precacheshader("ui_scrollbar_arrow_left");
	precacheshader("ui_scrollbar_arrow_right");

	level thread OnPlayerConnected();
	MapvoteConfig();
	
	if (!isDefined(level.mapvote_started))
	{
		level.mapvote_started = 1;

		mapsIDsList  = [];
		mapsIDsList  = strTok(getDvar("mv_maps"), " ");

		times = 3;
		if(getDvarInt("mv_extramaps") == 1)
		{
			times = 5;
		}
			
		mapschoosed = MapvoteChooseRandomMapsSelection(mapsIDsList , times);
		gametypes = strTok(getDvar("mv_gametypes"), " ");
		
		level.mapvotedata["firstmap"] = spawnStruct();
		level.mapvotedata["secondmap"] = spawnStruct();
		level.mapvotedata["thirdmap"] = spawnStruct();

		level.mapvotedata["firstmap"].mapid = mapschoosed[0];
		level.mapvotedata["secondmap"].mapid = mapschoosed[1];
		level.mapvotedata["thirdmap"].mapid = mapschoosed[2];

		level.mapvotedata["firstmap"].mapname = mapToDisplayName(mapschoosed[0]);
		level.mapvotedata["secondmap"].mapname = mapToDisplayName(mapschoosed[1]);
		level.mapvotedata["thirdmap"].mapname = mapToDisplayName(mapschoosed[2]);
		
		level.mapvotedata["firstmap"].gametype = gametypes[randomIntRange(0, gametypes.size)];
		level.mapvotedata["secondmap"].gametype = gametypes[randomIntRange(0, gametypes.size)];
		level.mapvotedata["thirdmap"].gametype = gametypes[randomIntRange(0, gametypes.size)];

		level.mapvotedata["firstmap"].loadscreen = mapToLoadscreen(mapschoosed[0]);
		level.mapvotedata["secondmap"].loadscreen = mapToLoadscreen(mapschoosed[1]);
		level.mapvotedata["thirdmap"].loadscreen = mapToLoadscreen(mapschoosed[2]);

		if(getDvarInt("mv_extramaps") == 1)
		{
			level.mapvotedata["fourthmap"] = spawnStruct();
			level.mapvotedata["fifthmap"] = spawnStruct();

			level.mapvotedata["fourthmap"].mapid = mapschoosed[3];
			level.mapvotedata["fifthmap"].mapid = mapschoosed[4];
			
			level.mapvotedata["fourthmap"].mapname = mapToDisplayName(mapschoosed[3]);
			level.mapvotedata["fifthmap"].mapname = mapToDisplayName(mapschoosed[4]);

			level.mapvotedata["fourthmap"].gametype = gametypes[randomIntRange(0, gametypes.size)];
			level.mapvotedata["fifthmap"].gametype = gametypes[randomIntRange(0, gametypes.size)];

			level.mapvotedata["fourthmap"].loadscreen = mapToLoadscreen(mapschoosed[3]);
			level.mapvotedata["fifthmap"].loadscreen = mapToLoadscreen(mapschoosed[4]);

			precacheShader(level.mapvotedata["fourthmap"].loadscreen);
			precacheShader(level.mapvotedata["fifthmap"].loadscreen);
		}

		precacheShader(level.mapvotedata["firstmap"].loadscreen);
		precacheShader(level.mapvotedata["secondmap"].loadscreen);
		precacheShader(level.mapvotedata["thirdmap"].loadscreen);
	}
}

main()
{
	replaceFunc(maps\mp\gametypes\_killcam::finalkillcamwaiter, ::finalkillcamwaiter);
}

finalkillcamwaiter()
{
	if (!isDefined(level.finalkillcam_winner))
	{
		return 0;
	}
	level waittill("final_killcam_done");
	if (waslastround())
	{
		ExecuteMapvote();
	}

	return 1;
}

/**
 * Initializes the map vote configuration.
 */
MapvoteConfig()
{
	SetDvarIfNotInizialized("mv_enable", 1);
	if (getDvarInt("mv_enable") != 1) // Check if mapvote is enable
		return;						  // End if the mapvote its not enable

	level.mapvotedata = [];
	SetDvarIfNotInizialized("mv_time", 20);
	level.mapvotedata["time"] = getDvarInt("mv_time");
	SetDvarIfNotInizialized("mv_maps", "mp_la mp_dockside mp_carrier mp_drone mp_express mp_hijacked mp_meltdown mp_overflow mp_nightclub mp_raid mp_slums mp_village mp_turbine mp_socotra mp_nuketown_2020 mp_downhill mp_mirage mp_hydro mp_skate mp_concert mp_magma mp_vertigo mp_studio mp_uplink mp_bridge mp_castaway mp_paintball mp_dig mp_frostbite mp_pod mp_takeoff");

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
	setDvarIfNotInizialized("mv_allowchangevote", 1);
	setDvarIfNotInizialized("mv_minplayerstovote", 1);
	
	/*if( level.roundlimit == 1)
		maps\mp\gametypes\_globallogic_utils::registerpostroundevent(::ExecuteMapvote);*/
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
/**
 * Resets the blur effect to 0.
 */
FixBlur() // Reset blur effect to 0
{
	self endon("disconnect");
	level endon("game_ended");
	self waittill("spawned_player");
	self setblur(0, 0);
}

/**
 * Executes the map vote functionality.
 */
ExecuteMapvote()
{
	level endon("mv_ended");
	if (getDvarInt("mv_enable") != 1) // Check if mapvote is enable
		return;						  // End if the mapvote its not enable

	if(_countPlayers() >= getDvarInt("mv_minplayerstovote"))
	{
		foreach (player in level.players)
		{
			if (!is_bot(player))
				player thread MapvotePlayerUI();
		}

		waittillframeend;

		level thread MapvoteServerUI();
		MapvoteHandler();
	}
}

/**
 * Removes a specified element from an array and returns a new array without the element.
 * 
 * @param array The array from which to remove the element.
 * @param todelete The element to be removed from the array.
 * @return The new array without the specified element.
 */
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

/**
 * Selects random maps from the given list.
 *
 * @param mapsIDsList - The list of map IDs to choose from.
 * @param times - The number of maps to select.
 * @return An array containing the randomly selected maps.
 */
MapvoteChooseRandomMapsSelection(mapsIDsList , times) // Select random map from the list
{
	mapschoosed = [];
	for (i = 0; i < times; i++)
	{
		index = randomIntRange(0, mapsIDsList .size);
		map = mapsIDsList [index];
		mapschoosed[i] = map;
		logPrint("map;"+map+";index;"+index+"\n");
		mapsIDsList  = ArrayRemoveElement(mapsIDsList , map);
		//arrayremovevalue(mapsIDsList , map);
	}

	return mapschoosed;
}

/**
 * Checks if a player is a bot.
 *
 * @param entity The entity to check.
 * @return true if the entity is a bot, false otherwise.
 */
is_bot(entity) // Check if a players is a bot
{
	return isDefined(entity.pers["isBot"]) && entity.pers["isBot"];
}

/**
 * Initializes the MapvotePlayerUI.
 */
MapvotePlayerUI()
{
	self endon("disconnect");
	//level endon("game_ended");

	self setblur(getDvarFloat("mv_blur"), 1.5);

	scrollcolor = getColor(getDvar("mv_scrollcolor"));
	bgcolor = getColor(getDvar("mv_backgroundcolor"));
	self FreezeControlsAllowLook(0);
	boxes = [];
	boxes[0] = self CreateRectangle("CENTER", "CENTER", -220, -452, 205, 133, scrollcolor, "white", 1, 0);
	boxes[1] = self CreateRectangle("CENTER", "CENTER", 0, -452, 205, 133, bgcolor, "white", 1, 0);
	boxes[2] = self CreateRectangle("CENTER", "CENTER", 220, -452, 205, 133, bgcolor, "white", 1, 0);

	self thread MapvoteForceFixedAngle();

	level waittill("mapvote_animate");

	if(getDvarInt("mv_extramaps") == 1)
	{
		dynamic_position = 100;
		boxes[3] = self CreateRectangle("CENTER", "CENTER", -120, -452, 205, 133, bgcolor, "white", 1, 0);
		boxes[4] = self CreateRectangle("CENTER", "CENTER", 120, -452, 205, 133, bgcolor, "white", 1, 0);
		//boxes[5] = self CreateRectangle("CENTER", "CENTER", 220, -452, 205, 133, bgcolor, "white", 2, 0);
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
	level waittill("mapvote_start");

	foreach(box in boxes) 
	{
		box affectElement("alpha", 0.2, 1);
	}

	index = 0;
	previuesindex = -1;
	voting = true;
	while (level.mapvotedata["time"] > 0 && voting)
	{
		command = self waittill_any_return("left", "right", "select", "mapvote_end");
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
			if(previuesindex >= 0)
			{
				select_color = getColor(getDvar("mv_selectcolor"));
				boxes[previuesindex] affectElement("color", 0.2, bgcolor);
				level notify("vote", previuesindex, -1);
			}
			waittillframeend; // DO NOT REMOVE THIS LINE: IF REMOVED IT WILL CAUSE THE SECOND NOTIFY TO FAIL
			level notify("vote", index, 1);
			previuesindex = index;

			select_color = getColor(getDvar("mv_selectcolor"));
			boxes[index] affectElement("color", 0.2, select_color);
			if(GetDvarInt("mv_allowchangevote") == 0)
			{
				voting = 0;
			}
		}
		else
		{
			for (i = 0; i < boxes.size; i++)
			{
				if (i != index)
					boxes[i] affectElement("color", 0.2, bgcolor);
				else
					boxes[i] affectElement("color", 0.2, scrollcolor);
			}
		}
	}
}

destroyBoxes(boxes)
{
	level endon("game_ended");
	level waittill("mapvote_end");
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

MapvoteForceFixedAngle()
{
	self endon("disconnect");
	level endon("game_ended");
	level waittill("mapvote_start");
	angles = self getPlayerAngles();

	self waittill_any("left", "right");
	if (self getPlayerAngles() != angles)
		self setPlayerAngles(angles);
}

/**
 * Creates a vote display area at the specified coordinates.
 * 
 * @param x The x-coordinate of the display area.
 * @param y The y-coordinate of the display area.
 * @return The created display area.
 */
CreateVoteDisplay(x, y)
{
	displayarea = createServerFontString("objective", 2);
	displayarea setPoint("center", "center", x, y);
	displayarea.label = &"^" + getDvar("mv_votecolor");
	displayarea.sort = 4;
	displayarea.alpha = 1;
	displayarea.hideWhenInMenu = 0;
	displayarea setValue(0);
	return displayarea;
}
/**
 * Creates a vote display object with the specified coordinates and map.
 * 
 * @param x The x-coordinate of the display object.
 * @param y The y-coordinate of the display object.
 * @param map The map associated with the display object.
 * @return The created vote display object.
 */
CreateVoteDisplayObject(x, y, map)
{
	displayobject = spawnStruct();
	displayobject.displayarea = CreateVoteDisplay(x, y);
	displayobject.value = 0;
	displayobject.map = map;
	return displayobject;
}

MapvoteHandler()
{
	level endon("game_ended");
	votes = [];

	votes[0] = level CreateVoteDisplayObject(-150, -325, level.mapvotedata["firstmap"]);
	votes[1] = level CreateVoteDisplayObject(75, -325, level.mapvotedata["secondmap"]);
	votes[2] = level CreateVoteDisplayObject(290, -325, level.mapvotedata["thirdmap"]);

	if(getDvarInt("mv_extramaps") == 1)
	{
		votes[3] = level CreateVoteDisplayObject(-50, -325, level.mapvotedata["fourthmap"]);
		votes[4] = level CreateVoteDisplayObject(190, -325, level.mapvotedata["fifthmap"]);
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
		vote.displayarea.alpha = 0;
		vote.displayarea.y = 1 + dynamic_position;
		vote.displayarea affectElement("alpha", 1.6, 1);
	}

	voting = true;
	index = 0;
	while (voting)
	{
		level waittill("vote", index, value);

		if(index == -1) 
		{
			voting = false;

			foreach(vote in votes) 
			{
				vote.votes affectElement("alpha", 0.5, 0);
			}
			break;
		}
		else
		{
			votes[index].value += value;
			votes[index].displayarea setValue(votes[index].value);
		}

	}

	winner = MapvoteGetMostVotedMap(votes);
	map = winner.map;

	MapvoteSetRotation(map.mapid, map.gametype);

	wait 0.5;

	foreach(vote in votes) 
	{
		vote.displayarea destroyElem();
	}

}

/**
 * Returns the most voted map from the given array of votes.
 *
 * @param votes The array of votes.
 * @return The map with the highest number of votes.
 */
MapvoteGetMostVotedMap(votes)
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

/**
 * Sets the rotation for the map vote.
 *
 * @param mapid The ID of the map to be added to the rotation.
 * @param gametype The game type associated with the map.
 */
MapvoteSetRotation(mapid, gametype)
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

/**
 * Initializes the map voting user interface on the server.
 */
MapvoteServerUI()
{
	//level endon("game_ended");

	mv_arrowcolor = GetColor(getDvar("mv_arrowcolor"));
	mv_votecolor = getDvar("mv_votecolor");

	buttons = level createServerFontString("objective", 2);
	buttons setText("^3[{+speed_throw}]              ^7Press ^3[{+gostand}] ^7or ^3[{+activate}] ^7to select              ^3[{+attack}]");
	buttons.hideWhenInMenu = 0;

	mapsHUDComponents = [];
	mapsHUDComponents[0] = spawnStruct();
	mapsHUDComponents[1] = spawnStruct();
	mapsHUDComponents[2] = spawnStruct();

	mapsHUDComponents[0].textline = level CreateString("^7" + level.mapvotedata["firstmap"].mapname + "\n" + gametypeToName(strTok(level.mapvotedata["firstmap"].gametype, ";")[0]), "objective", 1.2, "CENTER", "CENTER", -220, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
	mapsHUDComponents[1].textline = level CreateString("^7" + level.mapvotedata["secondmap"].mapname + "\n" + gametypeToName(strTok(level.mapvotedata["secondmap"].gametype, ";")[0]), "objective", 1.2, "CENTER", "CENTER", 0, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
	mapsHUDComponents[2].textline = level CreateString("^7" + level.mapvotedata["thirdmap"].mapname + "\n" + gametypeToName(strTok(level.mapvotedata["thirdmap"].gametype, ";")[0]), "objective", 1.2, "CENTER", "CENTER", 220, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
	
	mapsHUDComponents[0].image = level DrawShader(level.mapvotedata["firstmap"].loadscreen, -220, -310, 200, 129, (1, 1, 1), 1, 2, "LEFT", "CENTER", 1);
	mapsHUDComponents[0].image fadeovertime(0.5);
	mapsHUDComponents[1].image = level DrawShader(level.mapvotedata["secondmap"].loadscreen, 0, -310, 200, 129, (1, 1, 1), 1, 2, "CENTER", "CENTER", 1);
	mapsHUDComponents[1].image fadeovertime(0.5);
	mapsHUDComponents[2].image = level DrawShader(level.mapvotedata["thirdmap"].loadscreen, 220, -310, 200, 129, (1, 1, 1), 1, 2, "RIGHT", "CENTER", 1);
	mapsHUDComponents[2].image fadeovertime(0.5);

	arrow_right = undefined;
	arrow_left = undefined;

	if(getDvarInt("mv_extramaps") == 1)
	{
		buttons setPoint("CENTER", "CENTER", 0, 150);
		arrow_right = level DrawShader("ui_scrollbar_arrow_right", 200, 290 + 50, 25, 25, mv_arrowcolor, 100, 2, "CENTER", "CENTER", 1);
		arrow_left = level DrawShader("ui_scrollbar_arrow_left", -200, 290 + 50, 25, 25, mv_arrowcolor, 100, 2, "CENTER", "CENTER", 1);
		mapsHUDComponents[3] = spawnStruct();
		mapsHUDComponents[4] = spawnStruct();

		mapsHUDComponents[3].textline = level CreateString("^7" + level.mapvotedata["fourthmap"].mapname + "\n" + gametypeToName(strTok(level.mapvotedata["fourthmap"].gametype, ";")[0]), "objective", 1.2, "CENTER", "CENTER", -120, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
		mapsHUDComponents[4].textline = level CreateString("^7" + level.mapvotedata["fifthmap"].mapname + "\n" + gametypeToName(strTok(level.mapvotedata["fifthmap"].gametype, ";")[0]), "objective", 1.2, "CENTER", "CENTER", 120, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);

		mapsHUDComponents[3].image = level DrawShader(level.mapvotedata["fourthmap"].loadscreen, -120, -310, 200, 129, (1, 1, 1), 1, 2, "LEFT", "CENTER", 1);
		mapsHUDComponents[3].image fadeovertime(0.5);
		mapsHUDComponents[4].image = level DrawShader(level.mapvotedata["fifthmap"].loadscreen, 120, -310, 200, 129, (1, 1, 1), 1, 2, "RIGHT", "CENTER", 1);
		mapsHUDComponents[4].image fadeovertime(0.5);

		// map name background - NOT WORKING BECAUSE OF HUD LIMITS
		//mapsHUDComponents[3].textbg = level DrawShader("black", -220, 186, 200, 32, (1, 1, 1), 1, 3, "LEFT", "CENTER", 1);
		//mapsHUDComponents[4].textbg = level DrawShader("black", 0, 186, 200, 32, (1, 1, 1), 1, 3, "CENTER", "CENTER", 1);
		//mapsHUDComponents[5].textbg = level DrawShader("black", 220, 186, 200, 32, (1, 1, 1), 1, 3, "RIGHT", "CENTER", 1);
	}
	else
	{
		buttons setPoint("CENTER", "CENTER", 0, 100);
		arrow_right = level DrawShader("ui_scrollbar_arrow_right", 200, 290, 25, 25, mv_arrowcolor, 100, 2, "CENTER", "CENTER", 1);
		arrow_left = level DrawShader("ui_scrollbar_arrow_left", -200, 290, 25, 25, mv_arrowcolor, 100, 2, "CENTER", "CENTER", 1);

		mapsHUDComponents[0].textbg = level DrawShader("black", -220, 186, 200, 32, (1, 1, 1), 1, 3, "LEFT", "CENTER", 1);
		mapsHUDComponents[1].textbg = level DrawShader("black", 0, 186, 200, 32, (1, 1, 1), 1, 3, "CENTER", "CENTER", 1);
		mapsHUDComponents[2].textbg = level DrawShader("black", 220, 186, 200, 32, (1, 1, 1), 1, 3, "RIGHT", "CENTER", 1);
	}

	level notify("mapvote_animate");

	mv_sentence = getDvar("mv_sentence");
	mv_socialname = getDvar("mv_socialname");
	mv_sociallink = getDvar("mv_sociallink");
	credits = level createServerFontString("objective", 1.2);
	credits setPoint("BOTTOM_LEFT", "BOTTOM_LEFT");
	credits setText(mv_sentence + "\nDeveloped by @^5DoktorSAS ^7\n" + mv_socialname + ": " + mv_sociallink);

	for(i = 0; i < mapsHUDComponents.size; i++) 
	{
		map = mapsHUDComponents[i];
		dynamic_position = 0;
		if(mapsHUDComponents.size > 3 && i < 3)
		{
			dynamic_position = -50;	
		}
		else if(mapsHUDComponents.size > 3 && i > 2)
		{
			dynamic_position = 100;
		}
		map.textline.alpha = 0;
		map.textline affectElement("alpha", 1.6, 1);
		map.textline.y = -9 + dynamic_position;
		if(isDefined(map.textbg))
		{
			map.textbg.y = 186 + dynamic_position;
		}
		map.image affectElement("y", 1.2, 89 + dynamic_position);
	}

	wait 1;
	level notify("mapvote_start");

	timer = level createServerFontString("objective", 2);
	timer setPoint("CENTER", "BOTTOM", "CENTER", "CENTER");
	timer setTimer(level.mapvotedata["time"]);
	wait level.mapvotedata["time"];
	level notify("mapvote_end");
	level notify("vote", -1);
	
	foreach(map in mapsHUDComponents) 
	{
		map.textline affectElement("alpha", 0.4, 0);
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

	foreach (player in level.players)
	{
		player notify("mapvote_end");
		player setblur(0, 0);
	}

}
/**
 * Sets the value of a dvar if it is not already initialized.
 * @param dvar The name of the dvar.
 * @param value The value to set for the dvar.
 */
SetDvarIfNotInizialized(dvar, value)
{
	if (!IsInizialized(dvar))
		setDvar(dvar, value);
}

/**
 * Checks if a dvar is initialized.
 * @param dvar The name of the dvar.
 * @returns True if the dvar is initialized, false otherwise.
 */
IsInizialized(dvar)
{
	result = getDvar(dvar);
	return result != "";
}

/**
 * Converts a game type abbreviation to its corresponding full name.
 * 
 * @param {string} gametype - The abbreviation of the game type.
 * @returns {string} - The full name of the game type.
 */
gametypeToName(gametype)
{
	switch (tolower(gametype))
	{
		case "dm": return "Free for all";
		case "tdm": return "Team Deathmatch";
		case "sd": return "Search & Destroy";
		case "conf": return "Kill Confirmed";
		case "ctf": return "Capture the Flag";
		case "dom": return "Domination";
		case "dem": return "Demolition";
		case "gun": return "Gun Game";
		case "hq": return "Headquaters";
		case "koth": return "Hardpoint";
		case "oic": return "One in the chamber";
		case "oneflag": return "One-Flag CTF";
		case "sas": return "Sticks & Stones";
		case "shrp": return "Sharpshooter";
		default:
			return "Unknown Gametype";
	}
	return "Unknown Gametype";
}

/**
 * Converts a map ID to its corresponding display name.
 * @param {string} mapid - The map ID to convert.
 * @returns {string} - The display name of the map.
 */
mapToDisplayName(mapid) {
	mapid = tolower(mapid);
	switch (mapid) {
		case "mp_la": return "Aftermath";
		case "mp_meltdown": return "Meltdown";
		case "mp_overflow": return "Overflow";
		case "mp_nightclub": return "Plaza";
		case "mp_dockside": return "Cargo";
		case "mp_carrier": return "Carrier";
		case "mp_drone": return "Drone";
		case "mp_express": return "Express";
		case "mp_hijacked": return "Hijacked";
		case "mp_raid": return "Raid";
		case "mp_slums": return "Slums";
		case "mp_village": return "Standoff";
		case "mp_turbine": return "Turbine";
		case "mp_socotra": return "Yemen";
		case "mp_nuketown_2020": return "Nuketown 2025";
		case "mp_downhill": return "Downhill";
		case "mp_mirage": return "Mirage";
		case "mp_hydro": return "Hydro";
		case "mp_skate": return "Grind";
		case "mp_concert": return "Encore";
		case "mp_magma": return "Magma";
		case "mp_vertigo": return "Vertigo";
		case "mp_studio": return "Studio";
		case "mp_uplink": return "Uplink";
		case "mp_bridge": return "Detour";
		case "mp_castaway": return "Cove";
		case "mp_paintball": return "Rush";
		case "mp_dig": return "Dig";
		case "mp_frostbite": return "Frost";
		case "mp_pod": return "Pod";
		case "mp_takeoff": return "Takeoff";
		default:
			return "Unknown Map";
	}
}

/**
 * Returns the corresponding loadscreen image for a given map ID.
 * @param {string} mapid - The map ID.
 * @returns {string} - The loadscreen image name.
 */
mapToLoadscreen(mapid) {
	mapid = tolower(mapid);
	switch (mapid) {
		// List of map IDs and their corresponding loadscreen image names
		case "mp_la": return "loadscreen_mp_la";
		case "mp_meltdown": return "loadscreen_mp_meltdown";
		case "mp_overflow": return "loadscreen_mp_overflow";
		case "mp_nightclub": return "loadscreen_mp_nightclub";
		case "mp_dockside": return "loadscreen_mp_dockside";
		case "mp_carrier": return "loadscreen_mp_carrier";
		case "mp_drone": return "loadscreen_mp_drone";
		case "mp_express": return "loadscreen_mp_express";
		case "mp_hijacked": return "loadscreen_mp_hijacked";
		case "mp_raid": return "loadscreen_mp_raid";
		case "mp_slums": return "loadscreen_mp_Slums";
		case "mp_village":  return "loadscreen_mp_village";
		case "mp_turbine": return "loadscreen_mp_Turbine";
		case "mp_socotra": return "loadscreen_mp_socotra";
		case "mp_nuketown_2020":  return "loadscreen_mp_nuketown_2020";
		case "mp_downhill":  return "loadscreen_mp_downhill";
		case "mp_mirage": return "loadscreen_mp_Mirage";
		case "mp_hydro": return "loadscreen_mp_Hydro";
		case "mp_skate": return "loadscreen_mp_skate";
		case "mp_concert":  return "loadscreen_mp_concert";
		case "mp_magma": return "loadscreen_mp_Magma";
		case "mp_vertigo": return "loadscreen_mp_Vertigo";
		case "mp_studio": return "loadscreen_mp_Studio";
		case "mp_uplink": return "loadscreen_mp_Uplink";
		case "mp_bridge":  return "loadscreen_mp_bridge";
		case "mp_castaway": return "loadscreen_mp_castaway";
		case "mp_paintball": return "loadscreen_mp_paintball";
		case "mp_dig": return "loadscreen_mp_Dig";
		case "mp_frostbite": return "loadscreen_mp_frostbite";
		case "mp_pod": return "loadscreen_mp_Pod";
		case "mp_takeoff": return "loadscreen_mp_Takeoff";
		default:
			return "Unknown Image";
	}
}


_countPlayers() {
	count = 0;
	foreach (player in level.players) {
		if (!is_bot(player)) {
			count++;
		}
	}
	return count;
}

/**
 * Checks if the given value is a valid color.
 * A valid color is represented by a string value that is either "0", "1", "2", "3", "4", "5", "6", or "7".
 * 
 * @param value - The value to check.
 * @returns true if the value is a valid color, false otherwise.
 */
isValidColor(value)
{
	return value == "0" || value == "1" || value == "2" || value == "3" || value == "4" || value == "5" || value == "6" || value == "7";
}

/**
 * GetColor function returns the RGB values of a specified color.
 * 
 * @param {string} color - The color name.
 * @returns {array} - An array containing the RGB values of the specified color.
 */
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
/**
 * Creates a font string and sets its properties.
 *
 * @param {string} input - The text or value to be displayed in the font string.
 * @param {string} font - The font style of the font string.
 * @param {float} fontScale - The scale of the font string.
 * @param {int} align - The alignment of the font string.
 * @param {bool} relative - Determines if the font string's position is relative to its parent.
 * @param {float} x - The x-coordinate of the font string's position.
 * @param {float} y - The y-coordinate of the font string's position.
 * @param {vector} color - The color of the font string.
 * @param {float} alpha - The transparency of the font string.
 * @param {vector} glowColor - The color of the font string's glow effect.
 * @param {float} glowAlpha - The transparency of the font string's glow effect.
 * @param {int} sort - The sorting order of the font string.
 * @param {bool} isValue - Determines if the input is a value instead of text.
 * @returns {fontString} - The created font string.
 */
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
/**
 * Creates a rectangle HUD element with the specified properties.
 *
 * @param align The alignment of the rectangle.
 * @param relative The relative position of the rectangle.
 * @param x The x-coordinate of the rectangle.
 * @param y The y-coordinate of the rectangle.
 * @param width The width of the rectangle.
 * @param height The height of the rectangle.
 * @param color The color of the rectangle.
 * @param shader The shader of the rectangle.
 * @param sort The sorting order of the rectangle.
 * @param alpha The transparency of the rectangle.
 * @return The created rectangle HUD element.
 */
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
/**
 * Draws a shader on the screen at the specified position with the given dimensions, color, and alpha.
 * 
 * @param shader The shader to be drawn.
 * @param x The x-coordinate of the top-left corner of the shader.
 * @param y The y-coordinate of the top-left corner of the shader.
 * @param width The width of the shader.
 * @param height The height of the shader.
 * @param color The color of the shader.
 * @param alpha The alpha value of the shader.
 * @param sort The sorting order of the shader.
 * @param align The alignment of the shader.
 * @param relative Specifies whether the shader's position is relative to the screen or the level.
 * @param isLevel Specifies whether the shader is a level shader or a client shader.
 * @return The created hudelem object representing the drawn shader.
 */
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
/**
 * A function that affects the specified element over time.
 * @param {string} type - The type of element to affect ("x", "y", "alpha", "color").
 * @param {number} time - The duration of the effect in milliseconds.
 * @param {number} value - The new value for the specified element.
 */
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
