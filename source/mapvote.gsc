
mv_Begin()
{
	if(getDvarInt("mv_enable") != 1) // Check if mapvote is enable
		return; // End if the mapvote its not enable
	
	if(!isDefined(level.mapvote_started))
	{
		level.mapvote_started = 1;  
		level thread mv_Timer();
		//level thread mv_OverflowFix(); // Should be not needed anymore, but to be safe i leave it here
		mapslist = [];
		mapsIDs = [];
		mapsIDs = strTok(getDvar("mv_maps"), " "); 
		mapslist = mv_GetMapsThatCanBeVoted( mapsIDs ); // Remove blacklisted maps
		mapsd = [];
		mapsd = getMapsData( mapsIDs );

		mapschoosed = mv_GetRandomMaps( mapsIDs );

		level.__mapvote["map1"] = mapsd[ mapschoosed[0] ];
		level.__mapvote["map2"] = mapsd[ mapschoosed[1] ];
		level.__mapvote["map3"] = mapsd[ mapschoosed[2] ];
	


		level thread mv_ServerUI( );
		foreach(player in level.players) {
			if(!player is_bot())
				player thread mv_PlayerUI();
		}

		mv_VoteManager( );
	}
}

mv_GetMapsThatCanBeVoted( mapslist )
{
	if(getDvar("mv_excludedmaps") != "")
	{
		maps = [];
		maps = strTok(getDvar("mv_excludedmaps"), " ");
		foreach(map in maps) 
		{
			arrayremovevalue(mapslist, map);
		}
	}
	return mapslist;
}

mv_GetRandomMaps( mapsIDs ) // Select random map from the list
{
	mapschoosed = [];
	index = 0;
	map = "";
	for(i = 0; i < 3;i++)
	{
		index = randomIntRange(0,mapsIDs.size-1);
		map = mapsIDs[index];
		//logPrint("map;"+map+";index;"+index+"\n");
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
	level endon("game_ended");

	self setblur( getDvarFloat("mv_blur"), 1.5 );
	
	scroll_color = getColor( getDvar("mv_scrollcolor") );
	bg_color =  getColor( getDvar("mv_backgroundcolor") );
	self FreezeControlsAllowLook(0);
	boxes = [];
	boxes[0] = self createRectangle("CENTER", "CENTER", -220, -452, 205, 131, scroll_color, "white", 1, .7);	
	boxes[1] = self createRectangle("CENTER", "CENTER", 0, -452, 205, 131, bg_color, "white", 1, .7);
	boxes[2] = self createRectangle("CENTER", "CENTER", 220, -452, 205, 131, bg_color, "white", 1, .7);

	level waittill("mv_start_animation");
	boxes[0] affectElement("y", 1, -52);
	boxes[1] affectElement("y", 1, -52);
	boxes[2] affectElement("y", 1, -52);

	self thread mv_PlayerFixAngle();
	
	self notifyonplayercommand("left"	, "+attack"		);
    self notifyonplayercommand("right"	, "+speed_throw");
	self notifyonplayercommand("left"	, "+moveright"	);
    self notifyonplayercommand("right"	, "+moveleft"	);
    self notifyonplayercommand("select"	, "+usereload"	);
    self notifyonplayercommand("select"	, "+activate"	);
    self notifyonplayercommand("select"	, "+gostand"	);

	self.statusicon = "compassping_enemy";	// Red dot
	level waittill("mv_start_vote");
	index = 0;
	isVoting = 1;
	while(level.__mapvote["time"] > 0 && isVoting )
	{
		command = self waittill_any_return("left", "right", "select", "done");
		if(command == "right")
		{
			index++;
			if(index == boxes.size)
				index = 0;
		}
		else if(command == "left")
		{
			index--;
			if(index < 0)
				index = boxes.size-1;
		}
		
		if(command == "select")
		{
			self.statusicon = "compassping_friendlyfiring_mp"; // Green dot
			vote = "vote"+(index+1);
			level notify(vote);
			select_color = getColor( getDvar("mv_selectcolor") );
			boxes[index] affectElement("color", 0.2, select_color);
			isVoting = 0;
		}
		else
		{
			for(i = 0; i < boxes.size; i++) 
			{
				if(i != index)
					boxes[i] affectElement("color", 0.2, bg_color);
				else
					boxes[i] affectElement("color", 0.2, scroll_color);
			}
			//mv_PlayerUIUpdate(boxes, index);
		}
			
	}

	foreach(box in boxes) 
	{
		box affectElement("alpha", 0.5, 0);
	}
	wait 1.2;
	foreach(box in boxes) 
	{
		box destroyElem();
	}

	//mv_PlayerButtonsMonitor( boxes );
}

mv_PlayerFixAngle()
{
	level waittill("mv_start_vote");
	angles = self getPlayerAngles();

	self waittill_any("left", "right");
	if(self getPlayerAngles() != angles)
		self setPlayerAngles(angles);
}

/*mv_PlayerUIUpdate(boxes, index)
{
	scroll_color = getColor( getDvar("mv_scrollcolor") );
	bg_color =  getColor( getDvar("mv_backgroundcolor") );
	i = 0;
	foreach(box in boxes) 
	{
		if(i != index)
			box affectElement("color", 0.2, bg_color);
		else
			box affectElement("color", 0.2, scroll_color);
		i++;
	}
	
}*/
/*mv_PlayerButtonsMonitor( boxes )
{
	level endon("game_ended");
	self notifyonplayercommand("left"	, "+attack"		);
    self notifyonplayercommand("right"	, "+speed_throw");
	self notifyonplayercommand("left"	, "+moveright"	);
    self notifyonplayercommand("right"	, "+moveleft"	);
    self notifyonplayercommand("select"	, "+usereload"	);
    self notifyonplayercommand("select"	, "+activate"	);
    self notifyonplayercommand("select"	, "+gostand"	);

	self.statusicon = "compassping_enemy";	// Red dot
	level waittill("mv_start_vote");
	index = 0;
	isVoting = 1;
	while(level.__mapvote["time"] > 0 && isVoting )
	{
		command = self waittill_any_return("left", "right", "select");
		if(command == "right")
		{
			index++;
			if(index == boxes.size)
				index = 0;
		}
		else if(command == "left")
		{
			index--;
			if(index < 0)
				index = boxes.size-1;
		}
		
		if(command == "select")
		{
			isVoting = 0;
		}else
			mv_PlayerUIUpdate(boxes, index);
	}
	if(!isVoting)
	{
		self.statusicon = "compassping_friendlyfiring_mp"; // Green dot
		vote = "vote"+(index+1);
		level notify(vote);
		select_color = getColor( getDvar("mv_selectcolor") );
		boxes[index] affectElement("color", 0.2, select_color);
	}

	level waittill("mv_destroy_hud");
	foreach(box in boxes) 
	{
		box affectElement("alpha", 0.5, 0);
	}
	wait 1.2;
	foreach(box in boxes) 
	{
		box destroyElem();
	}
	
}*/

mv_VoteManager( )
{
	votes = [];
	votes[0] = spawnStruct(); 
	votes[0].votes = level createServerFontString("objective", 2);
 	votes[0].votes setPoint("CENTER", "CENTER", -165, -325);
	votes[0].votes.label = &"^" + getDvar("mv_votecolor");
	votes[0].votes.sort = 4;
	votes[0].value = 0;
	votes[0].map = level.__mapvote["map1"];

	votes[1] = spawnStruct(); 
	votes[1].votes = level createServerFontString("objective", 2);
 	votes[1].votes setPoint("CENTER", "CENTER", 55, -325);	
	votes[1].votes.label = &"^" + getDvar("mv_votecolor");
	votes[1].votes.sort = 4;
	votes[1].value = 0;
	votes[1].map = level.__mapvote["map2"];

	votes[2] = spawnStruct(); 
	votes[2].votes = level createServerFontString("objective", 2);
 	votes[2].votes setPoint("CENTER", "CENTER", 165+55+55, -325);
	votes[2].votes.label = &"^" + getDvar("mv_votecolor");
	votes[2].votes.sort = 4;
	votes[2].value = 0;
	votes[2].map = level.__mapvote["map3"];

	votes[0].votes setValue(0);
	votes[1].votes setValue(0);
	votes[2].votes setValue(0);
	
	votes[0].votes affectElement("y", 1, -4);
	votes[1].votes affectElement("y", 1, -4);
	votes[2].votes affectElement("y", 1, -4);

	votes[0].hideWhenInMenu = 1;
	votes[1].hideWhenInMenu = 1;
	votes[2].hideWhenInMenu = 1;
	
	//isInVote = 1;
	index = 0;
	while(1)
	{
		notify_value = level waittill_any_return("vote1", "vote2", "vote3", "mv_destroy_hud");
		
		if(notify_value == "mv_destroy_hud")
		{
			break;
		}
		else
		{
			switch(notify_value)
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
			votes[ index ].value++;
			votes[ index ].votes setValue( votes[ index ].value );
		}
		
	}

	winner = mv_GetMostVotedMap( votes );
	map = winner.map;
	mv_SetRotation(map.mapid);

	votes[0].votes affectElement("alpha", 0.5, 0);
	votes[1].votes affectElement("alpha", 0.5, 0);
	votes[2].votes affectElement("alpha", 0.5, 0);
	
	wait 1.2;
	
	votes[0].votes destroyElem();
	votes[1].votes destroyElem();
	votes[2].votes destroyElem();

	wait 5;
}

mv_GetMostVotedMap( votes )
{
	winner = votes[0];
	tie = [];
	for(i = 1; i < votes.size;i++)
	{
		//logPrint("map;"+i+";votes;"+votes[i-1].value+"\n");
		if(votes[i].value > winner.value)
		{
			winner = votes[i];
		}
	}
	
	return winner;

}
mv_SetRotation( mapid )
{
	setdvar( "sv_maprotation", getDvar("mv_gametype") + " map " + mapid );
	level notify("mv_ended");
}

mv_ServerUI( )
{
	/*mapsIDs = [];
	mapsIDs[0] = level.__mapvote["map1"];
	mapsIDs[1] = level.__mapvote["map2"];
	mapsIDs[2] = level.__mapvote["map3"];

	mapsdata = getMapsData( mapsIDs );

	preCacheShader(mapsdata[ level.__mapvote["map1"] ].image);
	preCacheShader(mapsdata[ level.__mapvote["map2"] ].image);
	preCacheShader(mapsdata[ level.__mapvote["map3"] ].image);*/

	wait 0.2;

    buttons = level createServerFontString("objective", 2);
	buttons setText( "^3[{+speed_throw}]              ^7Press ^3[{+gostand}] ^7or ^3[{+activate}] ^7to select              ^3[{+attack}]" );	
	buttons setPoint("CENTER", "CENTER", 0, 100);
	buttons.hideWhenInMenu = 0;

    mv_votecolor = getDvar("mv_votecolor");

    mapUI1 = level createString( "^7"+ level.__mapvote["map1"].mapname, "objective", 1.5, "CENTER", "CENTER", -220, -325, (1,1,1), 1, (0,0,0), 0.5, 5, 1);		
	mapUI2 = level createString( "^7"+ level.__mapvote["map2"].mapname, "objective", 1.5, "CENTER", "CENTER",    0, -325, (1,1,1), 1, (0,0,0), 0.5, 5, 1);		
	mapUI3 = level createString( "^7"+ level.__mapvote["map3"].mapname, "objective", 1.5, "CENTER", "CENTER",  220, -325, (1,1,1), 1, (0,0,0), 0.5, 5, 1);

	mapUIIMG1 = drawshader(level.__mapvote["map1"].image, -220, -310, 200, 127, ( 1, 1, 1 ), 1, 2, "LEFT", "CENTER", 1);
	mapUIIMG1 fadeovertime( 0.5 );
	mapUIIMG2 = drawshader(level.__mapvote["map2"].image, 0, -310, 200, 127, ( 1, 1, 1 ), 1, 2, "CENTER", "CENTER", 1);
	mapUIIMG2 fadeovertime( 0.5 );
	mapUIIMG3 = drawshader(level.__mapvote["map3"].image, 220, -310, 200, 127, ( 1, 1, 1 ), 1, 2, "RIGHT", "CENTER", 1);
	mapUIIMG3 fadeovertime( 0.5 );

	mapUIBTXT1 = drawshader( "black",  -220,  186, 200, 30, ( 1, 1, 1 ), 1, 3 , "LEFT", "CENTER", 1);
	mapUIBTXT2 = drawshader( "black", 	0,  186, 200, 30, ( 1, 1, 1 ), 1, 3 , "CENTER", "CENTER", 1);
	mapUIBTXT3 = drawshader( "black",   220,  186, 200, 30, ( 1, 1, 1 ), 1, 3 , "RIGHT", "CENTER", 1);
	mapUIBTXT1.alpha = 0;
	mapUIBTXT2.alpha = 0;
	mapUIBTXT3.alpha = 0;

	level notify("mv_start_animation");
    mapUI1 affectElement("y", 1, -4);
	mapUI2 affectElement("y", 1, -4);
	mapUI3 affectElement("y", 1, -4);
	mapUIIMG1 affectElement("y", 1, 89);
	mapUIIMG2 affectElement("y", 1, 89);
	mapUIIMG3 affectElement("y", 1, 89);
	mapUIBTXT1 affectElement("alpha", 1.5, 0.8);
	mapUIBTXT2 affectElement("alpha", 1.5, 0.8);
	mapUIBTXT3 affectElement("alpha", 1.5, 0.8);

    mv_arrowcolor = GetColor(getDvar("mv_arrowcolor"));

    arrow_right = drawshader( "ui_scrollbar_arrow_right", 200, 290, 25, 25, mv_arrowcolor, 100, 2 , "CENTER", "CENTER", 1);
	arrow_left  = drawshader( "ui_scrollbar_arrow_left", -200, 290, 25, 25, mv_arrowcolor, 100, 2 , "CENTER", "CENTER", 1);
	
	wait 1;
	level notify("mv_start_vote");

    level waittill("mv_destroy_hud");

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
	arrow_right affectElement("alpha", 0.5, 0);

	wait 1.2;

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
	arrow_left destroyElem();
}
mv_Timer()
{
    mv_credits = getDvarInt("mv_credits");

	if(mv_credits)
    {
        mv_sentence = getDvar("mv_sentence");
        mv_socialname = getDvar("mv_socialname");
        mv_sociallink = getDvar("mv_sociallink");
        credits = level createServerFontString("objective" , 1.2);
		credits setPoint("BOTTOM_LEFT", "BOTTOM_LEFT");
		credits setText(mv_sentence + "\nDeveloped by @^5DoktorSAS ^7\n" + mv_socialname + ": " + mv_sociallink);
    }

    timer = level createServerFontString("objective" , 2);
	timer setPoint("CENTER", "BOTTOM", "CENTER", "CENTER");
    timer.label = &"00:";
	
    while(level.__mapvote["time"] > 0)
	{
	    timer setValue(level.__mapvote["time"]);
		wait 1;
		level.__mapvote["time"]--;
	}
	level.__mapvote["time"] = 0;

	//logprint("vote time experied;\n");
	wait 1.2;

    credits affectElement("alpha", 0.5, 0);

	foreach(player in level.players) 
	{
		if(!player is_bot())
			player setblur( 0, 0 );
	}
    if(mv_credits)
        credits destroyElem();
    timer destroyElem();
	foreach(player in level.players) {
			if(!player is_bot())
				player notify("done");
		}
	level notify("mv_destroy_hud");
}
