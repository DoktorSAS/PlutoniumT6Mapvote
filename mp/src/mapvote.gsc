
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
		votes.votes affectElement("alpha", 0.5, 0);
	}

	mv_SetRotation(map.mapid, map.gametype);

	wait 0.5;

	foreach(vote in votes) 
	{
		votes.votes destroyElem();
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
