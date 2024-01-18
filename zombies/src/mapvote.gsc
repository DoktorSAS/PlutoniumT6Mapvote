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
		mapsd = level.mapsdata;
		times = 3;
		if(getDvarInt("mv_extramaps") == 1)
		{
			times = 6;
		}
			
		mapschoosed = mv_GetRandomMaps(mapsIDs, times);
		level.__mapvote["map1"] = mapsd[mapschoosed[0]];
		level.__mapvote["map2"] = mapsd[mapschoosed[1]];
		level.__mapvote["map3"] = mapsd[mapschoosed[2]];
		if(getDvarInt("mv_extramaps") == 1)
		{
			level.__mapvote["map4"] = mapsd[mapschoosed[3]];
			level.__mapvote["map5"] = mapsd[mapschoosed[4]];
			level.__mapvote["map6"] = mapsd[mapschoosed[5]];
		}

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

mv_GetRandomMaps(mapsIDs, times) // Select random map from the list
{
	mapschoosed = [];
	for (i = 0; i < times; i++)
	{
		index = randomIntRange(0, mapsIDs.size);
		map = mapsIDs[index];
		logPrint("map;"+map+";index;"+index+"\n");
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

	scroll_color = getColor(getDvar("mv_scrollcolor"));
	bg_color = getColor(getDvar("mv_backgroundcolor"));
	self FreezeControlsAllowLook(0);
	boxes = [];
	boxes[0] = self CreateRectangle("CENTER", "CENTER", -220, -50, 205, 131, scroll_color, "menu_zm_popup", 2, 0);
	boxes[1] = self CreateRectangle("CENTER", "CENTER", 0, -50, 205, 131, bg_color, "menu_zm_popup", 2, 0);
	boxes[2] = self CreateRectangle("CENTER", "CENTER", 220, -50, 205, 131, bg_color, "menu_zm_popup", 2, 0);

	if(getDvarInt("mv_extramaps") == 1)
	{
		dynamic_position = 100;
		boxes[3] = self CreateRectangle("CENTER", "CENTER", -220, -50, 205, 131, bg_color, "menu_zm_popup", 2, 0);
		boxes[4] = self CreateRectangle("CENTER", "CENTER", 0, -50, 205, 131, bg_color, "menu_zm_popup", 2, 0);
		boxes[5] = self CreateRectangle("CENTER", "CENTER", 220, -50, 205, 131, bg_color, "menu_zm_popup", 2, 0);
		boxes[3] affectElement("y", 1.2, -50 + dynamic_position);
		boxes[4] affectElement("y", 1.2, -50 + dynamic_position);
		boxes[5] affectElement("y", 1.2, -50 + dynamic_position);
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
	if(boxes.size > 3)
	{
		boxes[3] affectElement("alpha", 0.2, 1);
		boxes[4] affectElement("alpha", 0.2, 1);
		boxes[5] affectElement("alpha", 0.2, 1);
	}
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
	votes[1] = spawnStruct();
	votes[2] = spawnStruct();
	if(getDvarInt("mv_extramaps") == 1)
	{
		votes[3] = spawnStruct();
		votes[4] = spawnStruct();
		votes[5] = spawnStruct();

		votes[0].votes = level.__mapvote["map1"].uistring;
		votes[0].map = level.__mapvote["map1"];

		votes[1].votes = level.__mapvote["map2"].uistring;
		votes[1].map = level.__mapvote["map2"];

		votes[2].votes = level.__mapvote["map3"].uistring;
		votes[2].map = level.__mapvote["map3"];

		votes[3].votes = level.__mapvote["map4"].uistring;
		votes[3].map = level.__mapvote["map4"];

		votes[4].votes = level.__mapvote["map5"].uistring;
		votes[4].map = level.__mapvote["map5"];

		votes[5].votes = level.__mapvote["map6"].uistring;
		votes[5].map = level.__mapvote["map6"];

		for(i = 0; i < votes.size; i++) 
		{
			vote = votes[i];
			vote.value = 0;
			vote.votes setValue(0);
		}
	}
	else
	{
		votes[0].votes = level CreateString(0, "objective", 1.5, "LEFT", "CENTER", -150, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
		votes[0].votes.label = "^" + getDvarInt("mv_votecolor");
		votes[0].map = level.__mapvote["map1"];

		votes[1].votes = level CreateString(0, "objective", 1.5, "CENTER", "CENTER", 75, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
		votes[1].votes.label = "^" + getDvarInt("mv_votecolor");
		votes[1].map = level.__mapvote["map2"];

		votes[2].votes = level CreateString(0, "objective", 1.5, "RIGHT", "CENTER", 290, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 0);
		votes[2].votes.label = "^" + getDvarInt("mv_votecolor");
		votes[2].map = level.__mapvote["map3"];

		for(i = 0; i < votes.size; i++) 
		{
			vote = votes[i];
			vote.value = 0;
			vote.votes setValue(0);
			vote.votes affectElement("y", 1.2, -14);
		}
	}

	

	isInVote = 1;
	while (isInVote)
	{
		notify_value = level waittill_any_return("vote1", "vote2", "vote3", "vote4", "vote5", "vote6", "mv_destroy_hud");

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
			case "vote6":
				index = 5;
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

	if(isDefined(level.__mapvote["map4"]))
	{
		preCacheShader(level.__mapvote["map4"].shader);
		preCacheShader(level.__mapvote["map5"].shader);
		preCacheShader(level.__mapvote["map6"].shader);
	}
	

	mv_arrowcolor = GetColor(getDvar("mv_arrowcolor"));
	mv_votecolor = getDvar("mv_votecolor");

	buttons = level createServerFontString("objective", 2);
	buttons setText("^7 ^3[{+speed_throw}]              ^7Press ^3[{+gostand}] ^7or ^3[{+activate}] ^7to select              ^3[{+attack}] ^7");
	buttons.alpha = 0;
	buttons.hideWhenInMenu = 1;
	arrow_left = undefined;
	arrow_right = undefined;

	mapsUI = [];
	mapsUI[0] = spawnStruct();
	mapsUI[1] = spawnStruct();
	mapsUI[2] = spawnStruct();

	// map name
	mapsUI[0].mapname = level CreateString(&"", "objective", 1.5, "CENTER", "CENTER", -220, -14, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
	mapsUI[1].mapname = level CreateString(&"", "objective", 1.5, "CENTER", "CENTER", 0, -14, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
	mapsUI[2].mapname = level CreateString(&"", "objective", 1.5, "CENTER", "CENTER", 220, -14, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
	mapsUI[0].mapname.label = level.__mapvote["map1"].mapname;
	mapsUI[1].mapname.label = level.__mapvote["map2"].mapname;
	mapsUI[2].mapname.label = level.__mapvote["map3"].mapname;

	// map preview
	mapsUI[0].image = level DrawShader(level.__mapvote["map1"].image, -220, -310, 200, 117, (1, 1, 1), 1, 1, "LEFT", "CENTER", 1);
	mapsUI[0].image fadeovertime(0.5);
	mapsUI[1].image = level DrawShader(level.__mapvote["map2"].image, 0, -310, 200, 117, (1, 1, 1), 1, 1, "CENTER", "CENTER", 1);
	mapsUI[1].image fadeovertime(0.5);
	mapsUI[2].image = level DrawShader(level.__mapvote["map3"].image, 220, -310, 200, 117, (1, 1, 1), 1, 1, "RIGHT", "CENTER", 1);
	mapsUI[2].image fadeovertime(0.5);
	
	if(getDvarInt("mv_extramaps") == 1)
	{
		buttons setPoint("CENTER", "CENTER", 0, 150);
		arrow_right = level DrawShader("ui_scrollbar_arrow_right", 200, 290 + 50, 25, 25, mv_arrowcolor, 100, 2, "CENTER", "CENTER", 1);
		arrow_left = level DrawShader("ui_scrollbar_arrow_left", -200, 290 + 50, 25, 25, mv_arrowcolor, 100, 2, "CENTER", "CENTER", 1);
		mapsUI[3] = spawnStruct();
		mapsUI[4] = spawnStruct();
		mapsUI[5] = spawnStruct();
		
		// map name
		mapsUI[3].mapname = level CreateString(&"", "objective", 1.5, "CENTER", "CENTER", -220, -14, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
		mapsUI[4].mapname = level CreateString(&"", "objective", 1.5, "CENTER", "CENTER", 0, -14, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);
		mapsUI[5].mapname = level CreateString(&"", "objective", 1.5, "CENTER", "CENTER", 220, -14, (1, 1, 1), 1, (0, 0, 0), 0.5, 5);

		mapsUI[3].mapname.label = level.__mapvote["map4"].mapname;
		mapsUI[4].mapname.label = level.__mapvote["map5"].mapname;
		mapsUI[5].mapname.label = level.__mapvote["map6"].mapname;

		// map preview
		mapsUI[3].image = level DrawShader(level.__mapvote["map4"].image, -220, -310, 200, 117, (1, 1, 1), 1, 1, "LEFT", "CENTER", 1);
		mapsUI[3].image fadeovertime(0.5);
		mapsUI[4].image = level DrawShader(level.__mapvote["map5"].image, 0, -310, 200, 117, (1, 1, 1), 1, 1, "CENTER", "CENTER", 1);
		mapsUI[4].image fadeovertime(0.5);
		mapsUI[5].image = level DrawShader(level.__mapvote["map6"].image, 220, -310, 200, 117, (1, 1, 1), 1, 1, "RIGHT", "CENTER", 1);
		mapsUI[5].image fadeovertime(0.5);

		level.__mapvote["map1"].uistring = mapsUI[0].mapname;
		level.__mapvote["map2"].uistring = mapsUI[1].mapname;
		level.__mapvote["map3"].uistring = mapsUI[2].mapname;
		level.__mapvote["map4"].uistring = mapsUI[3].mapname;
		level.__mapvote["map5"].uistring = mapsUI[4].mapname;
		level.__mapvote["map6"].uistring = mapsUI[5].mapname;


		// map name background - NOT WORKING BECAUSE OF HUD LIMITS
		//mapsUI[3].textbg = level DrawShader("black", -220, -325, 194, 30, (1, 1, 1), 0.7, 4, "LEFT", "CENTER", 1);
		//mapsUI[4].textbg = level DrawShader("black", 0, -325, 194, 30, (1, 1, 1), 0.7, 4, "CENTER", "CENTER", 1);
		//mapsUI[5].textbg = level DrawShader("black", 220, -325, 194, 30, (1, 1, 1), 0.7, 4, "RIGHT", "CENTER", 1);
	}
	else
	{
		// map name background
		mapsUI[0].textbg = level DrawShader("black", -220, -325, 194, 30, (1, 1, 1), 0.7, 4, "LEFT", "CENTER", 1);
		mapsUI[1].textbg = level DrawShader("black", 0, -325, 194, 30, (1, 1, 1), 0.7, 4, "CENTER", "CENTER", 1);
		mapsUI[2].textbg = level DrawShader("black", 220, -325, 194, 30, (1, 1, 1), 0.7, 4, "RIGHT", "CENTER", 1);

		buttons setPoint("CENTER", "CENTER", 0, 100);
		arrow_right = level DrawShader("ui_scrollbar_arrow_right", 200, 290, 25, 25, mv_arrowcolor, 100, 2, "CENTER", "CENTER", 1);
		arrow_left = level DrawShader("ui_scrollbar_arrow_left", -200, 290, 25, 25, mv_arrowcolor, 100, 2, "CENTER", "CENTER", 1);
	}

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
		map.mapname.y = -14 + dynamic_position;
		if(isDefined(map.textbg))
		{
			map.textbg affectElement("y", 1.2, 176 + dynamic_position);
		}
		map.image affectElement("y", 1.2, 89 + dynamic_position);
	}
	
	buttons affectElement("alpha", 1.5, 0.8);

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
