#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_hud_util;

/*
	Mod: Mapvote Menu
	Developed by DoktorSAS
	Version: v1.1.1
	Config:
	//////////////////////////////////////////////////////////////////
	// Black ops II Zombies mapvote                                 //
	//                                      Developed by @DoktorSAS //
	//////////////////////////////////////////////////////////////////
	// Valid Maps:                                                  //
	// Zombies use same maps with different rules to decide the     //
	// playing area. To make this work in the dvar mv_maps you      //
	// have to write the map listed in this list                    //
	//////////////////////////////////////////////////////////////////
	// Standard:                                                    //
	// zm_tomb     - Origins                                        //
	// zm_buried   - Buried                                         //
	// zm_nuked    - Nuketown                                       //
	// zm_prison   - Mob of the dead                                //
	// zm_highrise - Die Rise                                       //
	// zm_transit  - Transit                                        //
	// zm_town     - Town                                           //
	// zm_farm     - Farm                                           //
	// zm_busdepot - Bus Depot                                      //
	// Grief:                                                       //
	// zm_tomb_grief      - Origins                                 //
	// zm_buried_grief    - Buried                                  //
	// zm_nuked_grief     - Nuketown                                //
	// zm_prison_grief    - Mob of the dead  #1                     //
	// zm_cellblock_grief - Mob of the dead  #2                     //
	// zm_highrise_grief  - Die Rise                                //
	// zm_transit_grief   - Transit                                 //
	// zm_town_grief      - Town                                    //
	// zm_farm_grief      - Farm                                    //
	// zm_busdepot_grief  - Bus Depot                               //
	//////////////////////////////////////////////////////////////////

	set mv_enable			1 						// Enable/Disable the mapvote
	set mv_maps				""						// Lits of maps that can be voted on the mapvote, leave empty for all maps
	set mv_excludedmaps		""						// Lis of maps you don't want to show in the mapvote
	set mv_time 			1 						// Time to vote
	set mv_socialname 		"SocialName" 			// Name of the server social such as Discord, Twitter, Website, etc
	set mv_sentence 		"Thanks for playing" 	// Thankfull sentence
	set mv_votecolor		"5" 					// Color of the Vote Number
	set mv_arrowcolor		"white"					// RGB Color of the arrows
	set mv_selectcolor 		"lighgreen"				// RGB Color when map get voted
	set mv_backgroundcolor 	"orange"				// RGB Color of map background
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
	
	1.1.0:
	- Addes support for 5 maps, it can be enable by setting the dvar mv_extramaps to 1

	1.1.1:
	- Implemented mv_allowchangevote dvar to allow or not the player to change his vote when time is still running
	- Massive code reorganization for better readability
	- Optimized of resources

	1.1.2:
	- WIP LUA/LUI UI support for mod support with controller support
	- Implemented mv_randomoption dvar that will not display which map and which gametype the last option will be (Random)
	- Implemented mv_minplayerstovote dvar to set the minimum number of players required to start the mapvote
*/

init()
{

	precachestatusicon("compassping_friendlyfiring_mp");
	precachestatusicon("compassping_enemy");
	precacheshader("white");
	precacheshader("ui_scrollbar_arrow_left");
	precacheshader("ui_scrollbar_arrow_right");
	precacheshader("gradient");

	level thread OnPlayerConnected();
	MapvoteConfig();

	if (GetDvarInt("mv_lui") == 1)
	{
		precachemenu("mapvote");
		precachestring(&"update_votes");
		precachestring(&"mapvote_close");

		setDvar("lui_mv_maps", "ERROR;ERROER;ERROR");
		setDvar("lui_mv_gametypes", "ERROR;ERROER;ERROR");
		setDvar("lui_mv_loadscreens", "ERROR;ERROER;ERROR");
		setDvar("lui_mv_time", getDvarInt("mv_time") * 1000);

		mv_backgroundcolor = getColor(getDvar("mv_backgroundcolor"));
		lui_mv_hovercolor = mv_backgroundcolor[0] + ";" + mv_backgroundcolor[1] + ";" + mv_backgroundcolor[2];
		setDvar("lui_mv_hovercolor", lui_mv_hovercolor);
	}

	if (!isDefined(level.mapvote_started))
	{
		level.mapvote_started = 1;

		mapsIDsList = [];
		mapsIDsList = strTok(getDvar("mv_maps"), " ");

		times = 3;
		if (getDvarInt("mv_extramaps") == 1)
		{
			times = 6; // Because of the HUD limits, the maximum number of maps that can be displayed is 5 with the GSC mapvote design
			if (GetDvarInt("mv_lui") == 1)
			{
				times = 6; // With LUI the limit can be more then 5, i choosed 6 but could be more if the code support it
			}
		}

		mapschoosed = MapvoteChooseRandomMapsSelection(mapsIDsList, times);
		gametypes = strTok(getDvar("mv_gametypes"), " ");

		level.mapvotedata["firstmap"] = spawnStruct();
		level.mapvotedata["secondmap"] = spawnStruct();
		level.mapvotedata["thirdmap"] = spawnStruct();

		level.mapvotedata["firstmap"].mapid = mapCustomIDtoExecuteString(mapschoosed[0]);
		level.mapvotedata["secondmap"].mapid = mapCustomIDtoExecuteString(mapschoosed[1]);
		level.mapvotedata["thirdmap"].mapid = mapCustomIDtoExecuteString(mapschoosed[2]);

		level.mapvotedata["firstmap"].mapname = mapToDisplayName(mapschoosed[0]);
		level.mapvotedata["secondmap"].mapname = mapToDisplayName(mapschoosed[1]);
		level.mapvotedata["thirdmap"].mapname = mapToDisplayName(mapschoosed[2]);

		level.mapvotedata["firstmap"].gametypename = issubstr("grief", mapschoosed[0]) ? "" : "Grief";
		level.mapvotedata["secondmap"].gametypename = issubstr("grief", mapschoosed[1]) ? "" : "Grief";
		level.mapvotedata["thirdmap"].gametypename = issubstr("grief", mapschoosed[2]) ? "" : "Grief";

		level.mapvotedata["firstmap"].loadscreen = mapToLoadscreen(mapschoosed[0]);
		level.mapvotedata["secondmap"].loadscreen = mapToLoadscreen(mapschoosed[1]);
		level.mapvotedata["thirdmap"].loadscreen = mapToLoadscreen(mapschoosed[2]);

		precacheShader(level.mapvotedata["firstmap"].loadscreen);
		precacheShader(level.mapvotedata["secondmap"].loadscreen);
		precacheShader(level.mapvotedata["thirdmap"].loadscreen);

		if (getDvarInt("mv_extramaps") == 1)
		{
			level.mapvotedata["fourthmap"] = spawnStruct();
			level.mapvotedata["fifthmap"] = spawnStruct();

			level.mapvotedata["fourthmap"].mapid = mapCustomIDtoExecuteString(mapschoosed[3]);
			level.mapvotedata["fifthmap"].mapid = mapCustomIDtoExecuteString(mapschoosed[4]);

			level.mapvotedata["fourthmap"].mapname = mapToDisplayName(mapschoosed[3]);
			level.mapvotedata["fifthmap"].mapname = mapToDisplayName(mapschoosed[4]);

			level.mapvotedata["fourthmap"].gametypename = issubstr("grief", mapschoosed[3]) ? "Grief" : "";
			level.mapvotedata["fifthmap"].gametypename = issubstr("grief", mapschoosed[4]) ? "Grief" : "";

			level.mapvotedata["fourthmap"].loadscreen = mapToLoadscreen(mapschoosed[3]);
			level.mapvotedata["fifthmap"].loadscreen = mapToLoadscreen(mapschoosed[4]);

			precacheShader(level.mapvotedata["fourthmap"].loadscreen);
			precacheShader(level.mapvotedata["fifthmap"].loadscreen);

			if (getDvarInt("mv_lui") == 1)
			{
				level.mapvotedata["sixthmap"] = spawnStruct();

				level.mapvotedata["sixthmap"].mapid = mapCustomIDtoExecuteString(mapschoosed[5]);

				level.mapvotedata["sixthmap"].mapname = mapToDisplayName(mapschoosed[5]);

				level.mapvotedata["sixthmap"].gametypename = issubstr("grief", mapschoosed[5]) ? "Grief" : "";

				level.mapvotedata["sixthmap"].loadscreen = mapToLoadscreen(mapschoosed[5]);

				precacheShader(level.mapvotedata["sixthmap"].loadscreen);
			}
		}

		if (GetDvarInt("mv_randomoption") == 1)
		{
			if (GetDvarInt("mv_extramaps") == 1)
			{
				level.mapvotedata["sixthmap"].mapname = "Random";
				level.mapvotedata["sixthmap"].gametypename = "Random";
				level.mapvotedata["sixthmap"].loadscreen = "gradient";
			}
			else
			{
				level.mapvotedata["thirdmap"].mapname = "Random";
				level.mapvotedata["thirdmap"].gametypename = "Random";
				level.mapvotedata["thirdmap"].loadscreen = "gradient";
			}
		}

		if (getDvar("mv_lui") == 1)
		{
			lui_mv_maps = level.mapvotedata["firstmap"].mapname + ";" + level.mapvotedata["secondmap"].mapname + ";" + level.mapvotedata["thirdmap"].mapname;
			lui_mv_gametypes = level.mapvotedata["firstmap"].gametypename + ";" + level.mapvotedata["secondmap"].gametypename + ";" + level.mapvotedata["thirdmap"].gametypename;
			lui_mv_loadscreens = level.mapvotedata["firstmap"].loadscreen + ";" + level.mapvotedata["secondmap"].loadscreen + ";" + level.mapvotedata["thirdmap"].loadscreen;

			if (getDvarInt("mv_extramaps") == 1)
			{
				lui_mv_maps = lui_mv_maps + ";" + level.mapvotedata["fourthmap"].mapname + ";" + level.mapvotedata["fifthmap"].mapname + ";" + level.mapvotedata["sixthmap"].mapname;
				lui_mv_gametypes = lui_mv_gametypes + ";" + level.mapvotedata["fourthmap"].gametypename + ";" + level.mapvotedata["fifthmap"].gametypename + ";" + level.mapvotedata["sixthmap"].gametypename;
				lui_mv_loadscreens = lui_mv_loadscreens + ";" + level.mapvotedata["fourthmap"].loadscreen + ";" + level.mapvotedata["fifthmap"].loadscreen + ";" + level.mapvotedata["sixthmap"].loadscreen;
				setDvar("lui_mv_maps", lui_mv_maps);
				setDvar("lui_mv_gametypes", lui_mv_gametypes);
				setDvar("lui_mv_loadscreens", lui_mv_loadscreens);
			}
		}
	}
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
		for (i = 0; i < points.size; i++)
		{
			if (points[i].script_string == location)
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

	ExecuteMapvote(); // Wait until mapvote is done

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

/**
 * Initializes the map vote configuration.
 */
MapvoteConfig()
{
	SetDvarIfNotInizialized("mv_enable", 1);
	if (getDvarInt("mv_enable") != 1) // Check if mapvote is enable
		return;						  // End if the mapvote its not enable
	setDvarIfNotInizialized("mv_lui", 0);

	level.mapvotedata = [];
	SetDvarIfNotInizialized("mv_time", 20);
	level.mapvotedata["time"] = getDvarInt("mv_time");
	SetDvarIfNotInizialized("mv_maps", "zm_tomb_grief zm_town_grief zm_farm_grief zm_tomb zm_buried");

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
	if (GetDvarInt("mv_lui") == 1)
	{
		SetDvarIfNotInizialized("mv_backgroundcolor", "orange");
	}
	else
	{
		SetDvarIfNotInizialized("mv_backgroundcolor", "grey");
	}

	SetDvarIfNotInizialized("mv_gametypes", "dm;dm.cfg tdm;tdm.cfg dm;dm.cfg tdm;tdm.cfg sd;sd.cfg sd;sd.cfg");
	setDvarIfNotInizialized("mv_excludedmaps", "");
	setDvarIfNotInizialized("mv_allowchangevote", 1);
	setDvarIfNotInizialized("mv_minplayerstovote", 1);
	setDvarIfNotInizialized("mv_randomoption", 1);

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
	wait 1;
	self LUIPlayerMapvote();
}

LUIPlayerMapvote()
{
	// self endon("disconnect");
	// level endon("game_ended");

	self closemenu();
	self closeingamemenu();

	self setClientDvar("lui_mv_time", getDvarInt("lui_mv_time"));
	self setClientDvar("lui_mv_hovercolor", getDvar("lui_mv_hovercolor"));
	waittillframeend;

	print("mapnames: " + level.mapvotedata["firstmap"].mapname + ";" + level.mapvotedata["secondmap"].mapname + ";" + level.mapvotedata["thirdmap"].mapname);

	waittillframeend;

	self setClientDvar("lui_mv_maps", getDvar("lui_mv_maps"));
	self setClientDvar("lui_mv_gametypes", getDvar("lui_mv_gametypes"));
	self setClientDvar("lui_mv_loadscreens", getDvar("lui_mv_loadscreens"));

	level waittill("mapvote_start");
	self openMenu("mapvote");

	while (true)
	{
		self waittill("menuresponse", menu, response);
		// print("menu: " + menu + " response: " + response);
		if (menu == "mapvote" && isDefined(response))
		{
			data = strTok(response, ",");
			luiindex = int(data[0]);
			arrayindex = luiindex - 1;
			level notify("vote", arrayindex, luiindex, int(data[1]));
		}
	}
}

/**
 * Executes the map vote functionality.
 */
ExecuteMapvote()
{
	level endon("mv_ended");
	if (getDvarInt("mv_enable") != 1) // Check if mapvote is enable
		return;						  // End if the mapvote its not enable

	if (_countPlayers() >= getDvarInt("mv_minplayerstovote"))
	{
		if (getDvarInt("mv_lui") == 1)
		{
			level thread MapvoteHandler();
			foreach (player in level.players)
			{
				if (!is_bot(player))
				{
					player thread LUIPlayerMapvote();
				}
			}

			wait 2;

			level notify("mapvote_start");
			wait getDvarInt("mv_time");
			// print("wait getDvarInt(mv_time);");
			foreach (player in level.players)
			{
				if (!is_bot(player))
				{
					// print("player thread LUICloseMapvoteMenu();");
					player thread LUICloseMapvoteMenu();
					// player closemenu();
					// player closeingamemenu();
				}
			}

			level notify("vote", -1);
		}
		else
		{
			foreach (player in level.players)
			{
				if (!is_bot(player))
				{
					player thread MapvotePlayerUI();
				}
			}

			level thread MapvoteServerUI();
			MapvoteHandler();
		}
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
	foreach (element in array)
	{
		if (element != todelete)
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
MapvoteChooseRandomMapsSelection(mapsIDsList, times) // Select random map from the list
{
	mapschoosed = [];
	for (i = 0; i < times; i++)
	{
		index = randomIntRange(0, mapsIDsList.size);
		map = mapsIDsList[index];
		mapschoosed[i] = map;
		logPrint("map;" + map + ";index;" + index + "\n");
		mapsIDsList = ArrayRemoveElement(mapsIDsList, map);
		// arrayremovevalue(mapsIDsList , map);
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
	// level endon("game_ended");
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

	if (getDvarInt("mv_extramaps") == 1)
	{
		dynamic_position = 100;
		boxes[3] = self CreateRectangle("CENTER", "CENTER", -120, -452, 205, 133, bgcolor, "white", 1, 0);
		boxes[4] = self CreateRectangle("CENTER", "CENTER", 120, -452, 205, 133, bgcolor, "white", 1, 0);
		// boxes[5] = self CreateRectangle("CENTER", "CENTER", 220, -452, 205, 133, bgcolor, "white", 2, 0);
		boxes[3] affectElement("y", 1.2, -50 + dynamic_position);
		boxes[4] affectElement("y", 1.2, -50 + dynamic_position);
		// boxes[5] affectElement("y", 1.2, -50 + dynamic_position);
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

	foreach (box in boxes)
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
			if (previuesindex >= 0)
			{
				select_color = getColor(getDvar("mv_selectcolor"));
				boxes[previuesindex] affectElement("color", 0.2, bgcolor);
				level notify("vote", previuesindex, -1);
			}
			wait 0.05; // DO NOT REMOVE THIS LINE: IF REMOVED IT WILL CAUSE THE SECOND NOTIFY TO FAIL
			level notify("vote", index, 1);
			previuesindex = index;

			select_color = getColor(getDvar("mv_selectcolor"));
			boxes[index] affectElement("color", 0.2, select_color);
			if (GetDvarInt("mv_allowchangevote") == 0)
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
	foreach (box in boxes)
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
CreateVoteDisplayObject(map, x, y)
{
	displayobject = spawnStruct();
	if (isDefined(x))
	{
		displayobject.displayarea = CreateVoteDisplay(x, y);
	}
	displayobject.value = 0;
	displayobject.map = map;
	return displayobject;
}

/**
 * Updates the votes for a specific LUI index.
 *
 * @param {int} luiindex - The index of the LUI mapvote option.
 * @param {int} value - The new value of the votes.
 */
LUIUpdateVotes(luiindex, value)
{
	self luiNotifyEvent(&"update_votes", 2, luiindex, value);
}

/**
 * Closes the map vote menu.
 */
LUICloseMapvoteMenu()
{
	// print("LUICloseMapvoteMenu()");
	self luiNotifyEvent(&"mapvote_close");
}

MapvoteHandler()
{
	// level endon("game_ended");
	votes = [];

	if (getDvarInt("mv_lui") == 1)
	{
		votes = [];
		votes[0] = level CreateVoteDisplayObject(level.mapvotedata["firstmap"]);
		votes[1] = level CreateVoteDisplayObject(level.mapvotedata["secondmap"]);
		votes[2] = level CreateVoteDisplayObject(level.mapvotedata["thirdmap"]);

		if (getDvarInt("mv_extramaps") == 1)
		{
			votes[3] = level CreateVoteDisplayObject(level.mapvotedata["fourthmap"]);
			votes[4] = level CreateVoteDisplayObject(level.mapvotedata["fifthmap"]);
			votes[5] = level CreateVoteDisplayObject(level.mapvotedata["sixthmap"]);
		}

		voting = true;
		index = 0;
		while (voting)
		{
			level waittill("vote", arrayindex, luiindex, value);
			// print("vote//" + arrayindex + "//" + value);
			if (arrayindex == -1)
			{
				voting = false;
				break;
			}
			else
			{
				votes[arrayindex].value += value;
				foreach (player in level.players)
				{
					if (!is_bot(player))
					{
						player thread LUIUpdateVotes(luiindex, votes[arrayindex].value);
					}
				}
			}
		}

		winner = MapvoteGetMostVotedMap(votes);
		map = winner.map;

		MapvoteSetRotation(map.mapid);
	}
	else
	{
		votes[0] = level CreateVoteDisplayObject(level.mapvotedata["firstmap"], -150, -325);
		votes[1] = level CreateVoteDisplayObject(level.mapvotedata["secondmap"], 75, -325);
		votes[2] = level CreateVoteDisplayObject(level.mapvotedata["thirdmap"], 290, -325);

		if (getDvarInt("mv_extramaps") == 1)
		{
			votes[3] = level CreateVoteDisplayObject(level.mapvotedata["fourthmap"], -50, -325);
			votes[4] = level CreateVoteDisplayObject(level.mapvotedata["fifthmap"], 190, -325);
		}

		for (i = 0; i < votes.size; i++)
		{
			vote = votes[i];
			dynamic_position = 0;
			if (votes.size > 3 && i < 3)
			{
				dynamic_position = -50;
			}
			else if (votes.size > 3 && i > 2)
			{
				dynamic_position = 100;
			}
			vote.value = 0;
			vote.displayarea.alpha = 0;
			vote.displayarea.y = 1 + dynamic_position;
			vote.displayarea affectElement("alpha", 1.32, 1);
		}

		voting = true;
		index = 0;
		while (voting)
		{
			level waittill("vote", index, value);

			if (index == -1)
			{
				voting = false;

				foreach (vote in votes)
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

		foreach (vote in votes)
		{
			vote.displayarea destroyElem();
		}
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
	logPrint("mapvote//gametype//" + mapid);
	//setdvar("g_gametype", mapid);
	setdvar("sv_maprotationcurrent", mapid);
	setdvar("sv_maprotation", mapid);
	level notify("mv_ended");
}

/**
 * Initializes the map voting user interface on the server.
 */
MapvoteServerUI()
{
	// level endon("game_ended");

	mv_arrowcolor = GetColor(getDvar("mv_arrowcolor"));
	mv_votecolor = getDvar("mv_votecolor");

	buttons = level createServerFontString("objective", 2);
	buttons setText("^3[{+speed_throw}]              ^7Press ^3[{+gostand}] ^7or ^3[{+activate}] ^7to select              ^3[{+attack}]");
	buttons.hideWhenInMenu = 0;

	mapsHUDComponents = [];
	mapsHUDComponents[0] = spawnStruct();
	mapsHUDComponents[1] = spawnStruct();
	mapsHUDComponents[2] = spawnStruct();

	mapsHUDComponents[0].textline = level CreateString("^7" + level.mapvotedata["firstmap"].mapname + "\n" + level.mapvotedata["firstmap"].gametypename, "objective", 1.32, "CENTER", "CENTER", -220, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
	mapsHUDComponents[1].textline = level CreateString("^7" + level.mapvotedata["secondmap"].mapname + "\n" + level.mapvotedata["secondmap"].gametypename, "objective", 1.32, "CENTER", "CENTER", 0, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
	mapsHUDComponents[2].textline = level CreateString("^7" + level.mapvotedata["thirdmap"].mapname + "\n" + level.mapvotedata["thirdmap"].gametypename, "objective", 1.32, "CENTER", "CENTER", 220, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);

	mapsHUDComponents[0].image = level DrawShader(level.mapvotedata["firstmap"].loadscreen, -220, -310, 200, 129, (1, 1, 1), 1, 2, "LEFT", "CENTER", 1);
	mapsHUDComponents[0].image fadeovertime(0.5);
	mapsHUDComponents[1].image = level DrawShader(level.mapvotedata["secondmap"].loadscreen, 0, -310, 200, 129, (1, 1, 1), 1, 2, "CENTER", "CENTER", 1);
	mapsHUDComponents[1].image fadeovertime(0.5);
	mapsHUDComponents[2].image = level DrawShader(level.mapvotedata["thirdmap"].loadscreen, 220, -310, 200, 129, (1, 1, 1), 1, 2, "RIGHT", "CENTER", 1);
	mapsHUDComponents[2].image fadeovertime(0.5);

	print("mapnames: " + level.mapvotedata["firstmap"].mapname + ";" + level.mapvotedata["secondmap"].mapname + ";" + level.mapvotedata["thirdmap"].mapname);

	arrow_right = undefined;
	arrow_left = undefined;

	if (getDvarInt("mv_extramaps") == 1)
	{
		buttons setPoint("CENTER", "CENTER", 0, 150);
		arrow_right = level DrawShader("ui_scrollbar_arrow_right", 200, 290 + 50, 25, 25, mv_arrowcolor, 100, 2, "CENTER", "CENTER", 1);
		arrow_left = level DrawShader("ui_scrollbar_arrow_left", -200, 290 + 50, 25, 25, mv_arrowcolor, 100, 2, "CENTER", "CENTER", 1);
		mapsHUDComponents[3] = spawnStruct();
		mapsHUDComponents[4] = spawnStruct();

		mapsHUDComponents[3].textline = level CreateString("^7" + level.mapvotedata["fourthmap"].mapname + "\n" + level.mapvotedata["fourthmap"].gametypename, "objective", 1.32, "CENTER", "CENTER", -120, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
		mapsHUDComponents[4].textline = level CreateString("^7" + level.mapvotedata["fifthmap"].mapname + "\n" + level.mapvotedata["fifthmap"].gametypename, "objective", 1.32, "CENTER", "CENTER", 120, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);

		mapsHUDComponents[3].image = level DrawShader(level.mapvotedata["fourthmap"].loadscreen, -120, -310, 200, 129, (1, 1, 1), 1, 2, "LEFT", "CENTER", 1);
		mapsHUDComponents[3].image fadeovertime(0.5);
		mapsHUDComponents[4].image = level DrawShader(level.mapvotedata["fifthmap"].loadscreen, 120, -310, 200, 129, (1, 1, 1), 1, 2, "RIGHT", "CENTER", 1);
		mapsHUDComponents[4].image fadeovertime(0.5);

		// map name background - NOT WORKING BECAUSE OF HUD LIMITS
		// mapsHUDComponents[3].textbg = level DrawShader("black", -220, 186, 200, 32, (1, 1, 1), 1, 3, "LEFT", "CENTER", 1);
		// mapsHUDComponents[4].textbg = level DrawShader("black", 0, 186, 200, 32, (1, 1, 1), 1, 3, "CENTER", "CENTER", 1);
		// mapsHUDComponents[5].textbg = level DrawShader("black", 220, 186, 200, 32, (1, 1, 1), 1, 3, "RIGHT", "CENTER", 1);
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

	for (i = 0; i < mapsHUDComponents.size; i++)
	{
		map = mapsHUDComponents[i];
		dynamic_position = 0;
		if (mapsHUDComponents.size > 3 && i < 3)
		{
			dynamic_position = -50;
		}
		else if (mapsHUDComponents.size > 3 && i > 2)
		{
			dynamic_position = 100;
		}
		map.textline.alpha = 0;
		map.textline affectElement("alpha", 1.32, 1);
		map.textline.y = -9 + dynamic_position;
		if (isDefined(map.textbg))
		{
			map.textbg.y = 186 + dynamic_position;
		}
		map.image affectElement("y", 1.2, 89 + dynamic_position);
	}
	print("after animation");
	wait 1;
	level notify("mapvote_start");

	timer = level createServerFontString("objective", 2);
	timer setPoint("CENTER", "BOTTOM", "CENTER", "CENTER");
	timer setTimer(level.mapvotedata["time"]);
	wait level.mapvotedata["time"];
	level notify("mapvote_end");
	level notify("vote", -1);

	foreach (map in mapsHUDComponents)
	{
		map.textline affectElement("alpha", 0.4, 0);
		if (isDefined(map.textbg))
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
	default:
		return gametypeToName(getDvar("g_gametype"));
	}
	return gametypeToName(getDvar("g_gametype"));
}

/**
 * Converts a map ID to its corresponding display name.
 * @param {string} mapid - The map ID to convert.
 * @returns {string} - The display name of the map.
 */
mapToDisplayName(mapid)
{
	mapid = tolower(mapid);
	switch (mapid)
	{
	case "zm_tomb":
	case "zm_tomb_grief":
		return "Origins";
	case "zm_buried":
	case "zm_buried_grief":
		return "Buried";
	case "zm_town":
	case "zm_town_grief":
		return "Town";
	case "zm_busdepot":
	case "zm_busdepot_grief":
		return "Bus Depot";
	case "zm_farm":
	case "zm_farm_grief":
		return "Farm";
	case "zm_transit":
	case "zm_transit_grief":
		return "Transit";
	case "zm_prison":
	case "zm_prison_grief":
		return "Mob of the dead";
	case "zm_highrise":
	case "zm_highrise_grief":
		return "Die rise";
	case "zm_nuked":
	case "zm_nuked_grief":
		return "Nuketown";
	case "zm_cellblock_grief":
		return "Cell Block";
	case "zm_diner_borough":
		return "Borough Diner";
	/*
		Insert a new case to add the translation from mapid to map display name.
		Exemple: case "zm_minecraft": return "Minecraft";
	*/
	default:
		return "Unknown Map";
	}
}

/**
 * Returns the corresponding loadscreen image for a given map ID.
 * @param {string} mapid - The map ID.
 * @returns {string} - The loadscreen image name.
 */
mapToLoadscreen(mapid)
{
	mapid = tolower(mapid);
	switch (mapid)
	{
	// List of map IDs and their corresponding loadscreen image names
	case "zm_tomb":
	case "zm_tomb_grief":
		return "loadscreen_zm_tomb_zclassic_tomb";
	case "zm_buried":
	case "zm_buried_grief":
		return "loadscreen_zm_buried_zclassic_processing";
	case "zm_town":
	case "zm_town_grief":
		return "loadscreen_zm_transit_zstandard_transit";
	case "zm_busdepot":
		return "loadscreen_zm_transit_zclassic_transit";
	case "zm_busdepot_grief":
		return "loadscreen_zm_transit_zclassic_transit";
	case "zm_farm":
	case "zm_farm_grief":
		return "loadscreen_zm_transit_zstandard_farm";
	case "zm_transit":
	case "zm_transit_grief":
		return "loadscreen_zm_transit_zclassic_transit";
	case "zm_prison":
	case "zm_prison_grief":
		return "loadscreen_zm_prison_zclassic_prison";
	case "zm_highrise":
	case "zm_highrise_grief":
		return "loadscreen_zm_highrise_zclassic_rooftop";
	case "zm_nuked":
	case "zm_nuked_grief":
		return "loadscreen_zm_nuked_zstandard_nuked";
	case "zm_cellblock_grief":
		return "loadscreen_zm_prison_zgrief_cellblock";
	case "zm_diner_borough":
		return "loadscreen_zm_transit_dr_zcleansed_diner";
	/*
		Insert a new case to add the loadscreen from mapid.
		Exemple: case "zm_minecraft": return "loadscreen_zm_minecraft";
	*/
	default:
		return "Unknown Image";
	}
}

mapCustomIDtoExecuteString(mapid)
{
	mapid = tolower(mapid);
	switch (mapid)
	{
	// List of map IDs and their corresponding loadscreen image names
	case "zm_tomb":
		return "execgts zm_classic_tomb.cfg map zm_tomb";
	case "zm_tomb_grief":
		return "execgts zm_grief_tomb.cfg map zm_tomb";
	case "zm_buried":
		return "execgts zm_classic_processing.cfg map zm_buried";
	case "zm_buried_grief":
		return "execgts zm_grief_processing.cfg map zm_buried";
	case "zm_town":
		return "execgts zm_standard_town.cfg map zm_transit";
	case "zm_town_grief":
		return "execgts zm_grief_town.cfg map zm_transit";
	case "zm_busdepot":
		return "execgts zm_standard_transit.cfg map zm_transit";
	case "zm_busdepot_grief":
		return "execgts zm_grief_transit.cfg map zm_transit";
	case "zm_farm":
		return "execgts zm_standard_farm.cfg map zm_transit";
	case "zm_farm_grief":
		return "execgts zm_grief_farm.cfg map zm_transit";
	case "zm_transit":
		return "execgts zm_classic_transit.cfg map zm_transit";
	case "zm_transit_grief":
		return "execgts zm_grief_transit.cfg map zm_transit";
	case "zm_prison":
		return "execgts zm_classic_prison.cfg map zm_prison";
	case "zm_prison_grief":
		return "execgts zm_grief_prison.cfg map zm_prison";
	case "zm_highrise":
		return "execgts zm_classic_rooftop.cfg map zm_highrise";
	case "zm_highrise_grief":
		return "execgts zm_grief_rooftop.cfg map zm_highrise";
	case "zm_nuked":
		return "execgts zm_standard_nuked.cfg map zm_nuked";
	case "zm_nuked_grief":
		return "execgts zm_cleansed_street.cfg map zm_buried";
	case "zm_cellblock_grief":
		return "execgts zm_grief_cellblock.cfg map zm_prison";
	case "zm_diner_borough":
		return "execgts zm_cleansed_street.cfg map zm_buried";
	/*
		Insert a new case to add the execution string from the custom map id
		Exemple: case "zm_minecraft": return "execgts zm_minecraft.cfg map zm_minecraft";
	*/
	default:
		return "Unknown Map";
	}
}

_countPlayers()
{
	count = 0;
	foreach (player in level.players)
	{
		if (!is_bot(player))
		{
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
		return (0.152, 0.329, 0.929);

	case "lightgreen":
	case "light green":
		return (0.09, 1, 0.09);

	case "orange":
		return (1, 0.662, 0.035);

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
