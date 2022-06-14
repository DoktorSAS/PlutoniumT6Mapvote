mv_Begin()
{
	if (getDvarInt("mv_enable") != 1) // Check if mapvote is enable
		return;						  // End if the mapvote its not enable

	if (!isDefined(level.mapvote_started))
	{
		level.mapvote_started = 1;
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
