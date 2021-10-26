#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

/*
	Mod: Mapvote Menu
	Developed by DoktorSAS
	Version: Rebirth 1.0.0 -> 4.0.0

	Config:
	set mv_enable			1 						// Enable/Disable the mapvote
	set mv_maps				""						// Lits of maps that can be voted on the mapvote, leave empty for all maps
	set mv_excludedmaps		""						// Lis of maps you don't want to show in the mapvote
	set mv_time 			1 						// Time to vote
	set mv_credits 			1 						// Enable/Disable credits of the mod creator
	set mv_socialname 		"SocialName" 			// Name of the server social such as Discord, Twitter, Website, etc
	set mv_sentence 		"Thanks for playing" 	// Thankfull sentence
	set mv_votecolor		"5" 					// Color of the Vote Number
	set mv_arrowcolor		"white"					// RGB Color of the arrows
	set mv_selectcolor 		"lighgreen"				// RGB Color when map get voted
	set mv_backgroundcolor 	"grey"					// RGB Color of map background
	set mv_blur 			"3"						// Blur effect power
	set mv_gametype 		""						// This dvar can be used to have multiple gametypes with different maps, with this dvar you can load gamemode
*/

init()
{

    precacheStatusIcon("compassping_friendlyfiring_mp");
    precacheStatusIcon("compassping_enemy");
	precacheshader( "white" );
	precacheshader( "ui_scrollbar_arrow_left" );
	precacheshader( "ui_scrollbar_arrow_right" );
    level thread OnPlayerConnected();

	mv_Config();
}

mv_Config()
{
    SetDvarIfNotInizialized("mv_enable", 1);
	if(getDvarInt("mv_enable") != 1) // Check if mapvote is enable
		return; // End if the mapvote its not enable

	level.__mapvote = [];
    SetDvarIfNotInizialized("mv_time", 20);
    level.__mapvote["time"] = getDvarInt("mv_time");
	SetDvarIfNotInizialized("mv_maps", "mp_la mp_dockside mp_carrier mp_drone mp_express mp_hijacked mp_meltdown mp_overflow mp_nightclub mp_raid mp_slums mp_village mp_turbine mp_socotra mp_nuketown_2020 mp_downhill mp_mirage mp_hydro mp_skate mp_concert mp_magma mp_vertigo mp_studio mp_uplink mp_bridge mp_castaway mp_paintball mp_dig mp_frostbite mp_pod mp_takeoff");
	
	// PreCache maps images
	mapsIDs = [];
    mapsIDs = strTok(getDvar("mv_maps"), " "); 
    mapsd = [];
	mapsd = getMapsData( mapsIDs );

	foreach(map in mapsd) 
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

	/*if( level.roundlimit == 1)
		maps\mp\gametypes\_globallogic_utils::registerpostroundevent(::mv_Begin);*/
}

main()
{
	replaceFunc( maps\mp\gametypes\_killcam::finalkillcamwaiter, ::mv_finalkillcamwaiter);
}
mv_finalkillcamwaiter()
{
    if ( !isDefined( level.finalkillcam_winner ) )
    {
        return 0;
    }
    level waittill( "final_killcam_done" );
	if( waslastround() )
		mv_Begin();

    wait 0.02;
    return 1;
}


OnPlayerConnected()
{
	level endon("game_ended");
	for(;;)
    {
		level waittill("connected", player);
		player thread FixBlur();
	}
}
FixBlur() // Reset blur effect to 0
{
	level endon("game_ended");
	self waittill("spawned_player");
	self setblur( 0, 0 );
}

mv_Begin()
{
	if(getDvarInt("mv_enable") != 1) // Check if mapvote is enable
		return; // End if the mapvote its not enable
	
	if(!isDefined(level.mapvote_started))
	{
		level.mapvote_started = 1;  
		level thread mv_Timer();
		level thread mv_OverflowFix(); // Should be not needed anymore, but to be safe i leave it here
		mapslist = [];
		mapsIDs = [];
		mapsIDs = strTok(getDvar("mv_maps"), " "); 
		mapslist = mv_GetMapsThatCanBeVoted( mapsIDs ); // Remove blacklisted maps
		mapsd = [];
		mapsd = getMapsData( mapsIDs );

		mapschoosed = mv_GetRandomMaps( mapsIDs ) ;
		map1 = mapsd[ mapschoosed[0] ];
		map2 = mapsd[ mapschoosed[1] ];
		map3 = mapsd[ mapschoosed[2] ];

		level thread mv_ServerUI( map1, map2, map3 );
		foreach(player in level.players) {
			//if(!player is_bot())
				player thread mv_PlayerUI();
		}

		mv_VoteManager( map1, map2, map3 );
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
	for(i = 0; i < 3;i++)
	{
		index = randomIntRange(0,mapsIDs.size-1);
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
	self setblur( getDvarFloat("mv_blur"), 1.5 );
	
	scroll_color = getColor( getDvar("mv_scrollcolor") );
	bg_color =  getColor( getDvar("mv_backgroundcolor") );
	self FreezeControlsAllowLook(0);
	boxes = [];
	boxes[0] = self createRectangle("CENTER", "CENTER", -220, -452, 205, 131, scroll_color, "white", 1, .7);	
	boxes[1] = self createRectangle("CENTER", "CENTER", 0, -452, 205, 131, bg_color, "white", 1, .7);
	boxes[2] = self createRectangle("CENTER", "CENTER", 220, -452, 205, 131, bg_color, "white", 1, .7);

	boxes[0] affectElement("y", 1, -52);
	boxes[1] affectElement("y", 1, -52);
	boxes[2] affectElement("y", 1, -52);

	self thread mv_PlayerFixAngle();
	mv_PlayerButtonsMonitor( boxes );
}

mv_PlayerFixAngle()
{
	level waittill("mv_start_vote");
	angles = self getPlayerAngles();

	self waittill_any("left", "right");
	if(self getPlayerAngles() != angles)
		self setPlayerAngles(angles);
}

mv_PlayerUIUpdate(boxes, index)
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
	
}
mv_PlayerButtonsMonitor( boxes )
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
		box DestroyElement();
	}
	
}
mv_VoteManager( map1, map2, map3 )
{
	votes = [];
	votes[0] = spawnStruct(); 
	votes[0].votes = level createServerFontString("hudsmall", 2);
 	votes[0].votes setPoint("CENTER", "CENTER", -165, -325);
	votes[0].votes.label = &"^" + getDvarInt("mv_votecolor");
	votes[0].votes.sort = 4;
	votes[0].value = 0;
	votes[0].map = map1;

	votes[1] = spawnStruct(); 
	votes[1].votes = level createServerFontString("hudsmall", 2);
 	votes[1].votes setPoint("CENTER", "CENTER", 55, -325);	
	votes[1].votes.label = &"^" + getDvarInt("mv_votecolor");
	votes[1].votes.sort = 4;
	votes[1].value = 0;
	votes[1].map = map2;

	votes[2] = spawnStruct(); 
	votes[2].votes = level createServerFontString("hudsmall", 2);
 	votes[2].votes setPoint("CENTER", "CENTER", 165, -325);
	votes[2].votes.label = &"^" + getDvarInt("mv_votecolor");
	votes[2].votes.sort = 4;
	votes[2].value = 0;
	votes[2].map = map3;

	votes[0].votes setValue(0);
	votes[1].votes setValue(0);
	votes[2].votes setValue(0);
	
	votes[0].votes affectElement("y", 1, -4);
	votes[1].votes affectElement("y", 1, -4);
	votes[2].votes affectElement("y", 1, -4);

	votes[0].hideWhenInMenu = 1;
	votes[1].hideWhenInMenu = 1;
	votes[2].hideWhenInMenu = 1;
	
	isInVote = 1;
	while(isInVote)
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
		winner = mv_GetMostVotedMap( votes );
		map = winner.map;
		mv_SetRotation(map.mapid);
		logPrint("inside the loop map set to " + map.mapid + "\n");
	}

	votes[0].votes affectElement("alpha", 0.5, 0);
	votes[1].votes affectElement("alpha", 0.5, 0);
	votes[2].votes affectElement("alpha", 0.5, 0);
	

	wait 1.2;
	
	
	votes[0].votes DestroyElement();
	votes[1].votes DestroyElement();
	votes[2].votes DestroyElement();

	wait 5;
}

mv_GetMostVotedMap( votes )
{
	winner = votes[0];
	tie = [];
	for(i = 1; i < votes.size;i++)
	{
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

mv_ServerUI( map1, map2, map3 )
{
	preCacheShader(map1.shader);
	preCacheShader(map2.shader);
	preCacheShader(map3.shader);

    buttons = level createServerFontString("hudsmall", 2);
	buttons SetElementText( "^7 ^3[{+speed_throw}]              ^7Press ^3[{+gostand}] ^7or ^3[{+activate}] ^7to select              ^3[{+attack}] ^7" + "\n^7  ^3[{+moveleft}]                                                                                 ^3[{+moveright}]^7" );	
	buttons setPoint("CENTER", "CENTER", 0, 100);
	buttons.hideWhenInMenu = 1;

    mv_votecolor = getDvar("mv_votecolor");

    mapUI1 = level createString( "^7"+ map1.mapname, "hudsmall", 1.5, "CENTER", "CENTER", -220, -325, (1,1,1), 1, (0,0,0), 0.5, 5, true);		
	mapUI2 = level createString( "^7"+ map2.mapname, "hudsmall", 1.5, "CENTER", "CENTER",    0, -325, (1,1,1), 1, (0,0,0), 0.5, 5, true);		
	mapUI3 = level createString( "^7"+ map3.mapname, "hudsmall", 1.5, "CENTER", "CENTER",  220, -325, (1,1,1), 1, (0,0,0), 0.5, 5, true);

	mapUIIMG1 = level drawshader( map1.image, -220, -310, 200, 127, ( 1, 1, 1 ), 1, 2, "LEFT", "CENTER", true);
	mapUIIMG1 fadeovertime( 0.5 );
	mapUIIMG2 = level drawshader( map2.image, 0, -310, 200, 127, ( 1, 1, 1 ), 1, 2, "CENTER", "CENTER", true);
	mapUIIMG2 fadeovertime( 0.5 );
	mapUIIMG3 = level drawshader( map3.image, 220, -310, 200, 127, ( 1, 1, 1 ), 1, 2, "RIGHT", "CENTER", true);
	mapUIIMG3 fadeovertime( 0.5 );

	mapUIBTXT1 = level drawshader( "black",  -220,  186, 200, 30, ( 1, 1, 1 ), 1, 3 , "LEFT", "CENTER", true);
	mapUIBTXT2 = level drawshader( "black", 	0,  186, 200, 30, ( 1, 1, 1 ), 1, 3 , "CENTER", "CENTER", true);
	mapUIBTXT3 = level drawshader( "black",   220,  186, 200, 30, ( 1, 1, 1 ), 1, 3 , "RIGHT", "CENTER", true);
	mapUIBTXT1.alpha = 0;
	mapUIBTXT2.alpha = 0;
	mapUIBTXT3.alpha = 0;

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

    arrow_right = drawshader( "ui_scrollbar_arrow_right", 200, 290, 25, 25, mv_arrowcolor, 100, 2 , "CENTER", "CENTER", true);
	arrow_left  = drawshader( "ui_scrollbar_arrow_left", -200, 290, 25, 25, mv_arrowcolor, 100, 2 , "CENTER", "CENTER", true);
	
	wait 1;
	level notify("mv_start_vote");

    level waittill("mv_destroy_hud");

	mapUI1 affectElement("alpha", 0.5, 0);
	mapUI2 affectElement("alpha", 0.5, 0);
	mapUI3 affectElement("alpha", 0.5, 0);
	mapUIIMG1 affectElement("alpha", 0.5, 0);
	mapUIIMG2 affectElement("alpha", 0.5, 0);
	mapUIIMG3 affectElement("alpha", 0.5, 0);
	mapUIBTXT1 affectElement("alpha", 0.5, 0);
	mapUIBTXT2 affectElement("alpha", 0.5, 0);
	mapUIBTXT3 affectElement("alpha", 0.5, 0);

	wait 1.2;

    buttons DestroyElement();
    mapUI1 DestroyElement();
	mapUI2 DestroyElement();
	mapUI3 DestroyElement();
	mapUIIMG1 DestroyElement();
	mapUIIMG2 DestroyElement();
	mapUIIMG3 DestroyElement();
	mapUIBTXT1 DestroyElement();
	mapUIBTXT2 DestroyElement();
	mapUIBTXT3 DestroyElement();
	arrow_right DestroyElement();
	arrow_left DestroyElement();

}
mv_Timer()
{
    mv_credits = getDvarInt("mv_credits");

	if(mv_credits)
    {
        mv_sentence = getDvar("mv_sentence");
        mv_socialname = getDvar("mv_socialname");
        mv_sociallink = getDvar("mv_sociallink");
        credits = level createServerFontString("hudsmall" , 1.2);
		credits setPoint("BOTTOM_LEFT", "BOTTOM_LEFT");
		credits setElementText(mv_sentence + "\nDeveloped by @^5DoktorSAS ^7\n" + mv_socialname + ": " + mv_sociallink);
    }

    timer = level createServerFontString("hudsmall" , 2);
	timer setPoint("CENTER", "BOTTOM", "CENTER", "CENTER");
    timer.label = &"00:";
	
    while(level.__mapvote["time"] > 0)
	{
	    timer setValue(level.__mapvote["time"]);
		wait 1;
		level.__mapvote["time"]--;
	}
	level.__mapvote["time"] = 0;
	level notify("mv_destroy_hud");
	logprint("time gone!");
	wait 1.2;
    
	foreach(player in level.players) 
	{
		player setblur( 0, 0 );
	}
    if(mv_credits)
        credits DestroyElement();
    timer DestroyElement();
}


SetDvarIfNotInizialized(dvar, value)
{
	if(!IsInizialized(dvar))
		setDvar(dvar, value);
}
IsInizialized(dvar)
{
	result = getDvar(dvar);
	return result != undefined || result != "";
} 
getMapsData( mapsIDs )
{
	mapsdata = [];

	foreach(id in mapsIDs)
	{
		mapsdata[id] = spawnStruct();
	}

	mapsdata["mp_la"].mapname = "Aftermath";
	mapsdata["mp_la"].mapid = "mp_la";
	mapsdata["mp_la"].image = "loadscreen_mp_la";
	mapsdata["mp_meltdown"].mapname = "Meltdown";
	mapsdata["mp_meltdown"].mapid = "mp_meltdown";
	mapsdata["mp_meltdown"].image = "loadscreen_mp_meltdown";
	mapsdata["mp_overflow"].mapname = "Overflow";
	mapsdata["mp_overflow"].mapid = "mp_overflow";
	mapsdata["mp_overflow"].image = "loadscreen_mp_overflow";
	mapsdata["mp_nightclub"].mapname = "Plaza";
	mapsdata["mp_nightclub"].mapid = "mp_nightclub";
	mapsdata["mp_nightclub"].image = "loadscreen_mp_nightclub";
	mapsdata["mp_dockside"].mapname = "Cargo";
	mapsdata["mp_dockside"].mapid = "mp_dockside";
	mapsdata["mp_dockside"].image = "loadscreen_mp_dockside";
	mapsdata["mp_carrier"].mapname = "Carrier";
	mapsdata["mp_carrier"].mapid = "mp_carrier";
	mapsdata["mp_carrier"].image = "loadscreen_mp_carrier";
	mapsdata["mp_drone"].mapname = "Drone";
	mapsdata["mp_drone"].mapid = "mp_drone";
	mapsdata["mp_drone"].image = "loadscreen_mp_drone";
	mapsdata["mp_express"].mapname = "Express";
	mapsdata["mp_express"].mapid = "mp_express";
	mapsdata["mp_express"].image = "loadscreen_mp_express";
	mapsdata["mp_hijacked"].mapname = "Hijacked";
	mapsdata["mp_hijacked"].mapid = "mp_hijacked";
	mapsdata["mp_hijacked"].image = "loadscreen_mp_hijacked";
	mapsdata["mp_raid"].mapname = "Raid";
	mapsdata["mp_raid"].mapid = "mp_raid";
	mapsdata["mp_raid"].image = "loadscreen_mp_raid";
	mapsdata["mp_slums"].mapname = "Slums";
	mapsdata["mp_slums"].mapid = "mp_slums";
	mapsdata["mp_slums"].image = "loadscreen_mp_Slums";
	mapsdata["mp_village"].mapname = "Standoff";
	mapsdata["mp_village"].mapid = "mp_village";
	mapsdata["mp_village"].image = "loadscreen_mp_village";
	mapsdata["mp_turbine"].mapname = "Turbine";
	mapsdata["mp_turbine"].mapid = "mp_turbine";
	mapsdata["mp_turbine"].image = "loadscreen_mp_Turbine";
	mapsdata["mp_socotra"].mapname = "Yemen";
	mapsdata["mp_socotra"].mapid = "mp_socotra";
	mapsdata["mp_socotra"].image = "loadscreen_mp_socotra";
	mapsdata["mp_nuketown_2020"].mapname = "Nuketown 2025";
	mapsdata["mp_nuketown_2020"].mapid = "mp_nuketown_2020";
	mapsdata["mp_nuketown_2020"].image = "loadscreen_mp_nuketown_2020";
	mapsdata["mp_downhill"].mapname = "Downhill";
	mapsdata["mp_downhill"].mapid = "mp_downhill";
	mapsdata["mp_downhill"].image = "loadscreen_mp_downhill";
	mapsdata["mp_mirage"].mapname = "Mirage";
	mapsdata["mp_mirage"].mapid = "mp_mirage";
	mapsdata["mp_mirage"].image = "loadscreen_mp_Mirage";
	mapsdata["mp_hydro"].mapname = "Hydro";
	mapsdata["mp_hydro"].mapid = "mp_hydro";
	mapsdata["mp_hydro"].image = "loadscreen_mp_Hydro";
	mapsdata["mp_skate"].mapname = "Grind";
	mapsdata["mp_skate"].mapid = "mp_skate";
	mapsdata["mp_skate"].image = "loadscreen_mp_skate";
	mapsdata["mp_concert"].mapname = "Encore";
	mapsdata["mp_concert"].mapid = "mp_concert";
	mapsdata["mp_concert"].image = "loadscreen_mp_concert";
	mapsdata["mp_magma"].mapname = "Magma";
	mapsdata["mp_magma"].mapid = "mp_magma";
	mapsdata["mp_magma"].image = "loadscreen_mp_Magma";
	mapsdata["mp_vertigo"].mapname = "Vertigo";
	mapsdata["mp_vertigo"].mapid = "mp_vertigo";
	mapsdata["mp_vertigo"].image = "loadscreen_mp_Vertigo";
	mapsdata["mp_studio"].mapname = "Studio";
	mapsdata["mp_studio"].mapid = "mp_studio";
	mapsdata["mp_studio"].image = "loadscreen_mp_Studio";
	mapsdata["mp_uplink"].mapname = "Uplink";
	mapsdata["mp_uplink"].mapid = "mp_uplink";
	mapsdata["mp_uplink"].image = "loadscreen_mp_Uplink";
	mapsdata["mp_bridge"].mapname = "Detour";
	mapsdata["mp_bridge"].mapid = "mp_bridge";
	mapsdata["mp_bridge"].image = "loadscreen_mp_bridge";
	mapsdata["mp_castaway"].mapname = "Cove";
	mapsdata["mp_castaway"].mapid = "mp_castaway";
	mapsdata["mp_castaway"].image = "loadscreen_mp_castaway";
	mapsdata["mp_paintball"].mapname = "Rush";
	mapsdata["mp_paintball"].mapid = "mp_paintball";
	mapsdata["mp_paintball"].image = "loadscreen_mp_paintball";
	mapsdata["mp_dig"].mapname = "Dig";
	mapsdata["mp_dig"].mapid = "mp_dig";
	mapsdata["mp_dig"].image = "loadscreen_mp_Dig";
	mapsdata["mp_frostbite"].mapname = "Frost";
	mapsdata["mp_frostbite"].mapid = "mp_frostbite";
	mapsdata["mp_frostbite"].image = "loadscreen_mp_frostbite";
	mapsdata["mp_pod"].mapname = "Pod";
	mapsdata["mp_pod"].mapid = "mp_pod";
	mapsdata["mp_pod"].image = "loadscreen_mp_Pod";
	mapsdata["mp_takeoff"].mapname = "Takeoff";
	mapsdata["mp_takeoff"].mapid = "mp_takeoff";
	mapsdata["mp_takeoff"].image = "loadscreen_mp_Takeoff";
	mapsdata["mp_dockside"].mapname = "Cargo";
	mapsdata["mp_dockside"].mapid = "mp_dockside";
	mapsdata["mp_dockside"].image = "loadscreen_mp_dockside";
    return mapsdata;
}
isValidColor( value ){
	return value == "0" || value == "1" || value == "2" || value == "3" || value == "4" || value == "5" || value == "6" || value == "7" ;
}
addCmd(cmd, function)
{
	self notifyOnPlayerCommand( cmd + "_cmd", cmd);
	self thread cmdManager(cmd + "_cmd", function);
}
cmdManager(cmd, function)
{
	self endon("disconnect");
	self endon("round_ended");
	level endon("game_ended");
	level endon("round_end_finished");
	for(;;)
	{
		self waittill( cmd );
		self [[function]]();
	}	
}
GetColor( color ){
	switch(tolower(color)){
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
    		return  (1, 0.623, 0.811);
    	break;
    	case "green":
    		return  (0, 0.69, 0.15);
    	break;
    	case "blue":
    		return  (0, 0, 1);
    	break;
    	case "lightblue":
    	case "light blue":
    		return  (0.152, 0329, 0.929);
    	break;
    	case "lightgreen":
    	case "light green":
    		return  (0.09, 1, 0.09);
    	break;
    	case "orange":
    		return  (1, 0662, 0.035);
    	break;
    	case "yellow":
    		return (0.968, 0.992, 0.043);
    	break;
    	case "brown":
    		return (0.501, 0.250, 0);
    	break;
    	case "cyan":
    		return  (0, 1, 1);
    	break;
    	case "white":
    		return  (1, 1, 1);
    	break;
		
    }
}
// Drawing
CreateString(input, font, fontScale, align, relative, x, y, color, alpha, glowColor, glowAlpha, sort, isLevel, isValue){
 	if(!isDefined(isLevel))
  		hud = self createFontString(font, fontScale);
 	else
  		hud = level createServerFontString(font, fontScale);
    if(!isDefined(isValue))
  		hud SetElementText(input);
 	else
  		hud SetElementValueText(input);
    hud setPoint(align, relative, x, y);
 	hud.color = color;
 	hud.alpha = alpha;
 	hud.glowColor = glowColor;
 	hud.glowAlpha = glowAlpha;
 	hud.sort = sort;
 	hud.alpha = alpha;
	hud.archived = 0;
	hud.hideWhenInMenu = true;
	return hud;
}
CreateRectangle(align, relative, x, y, width, height, color, shader, sort, alpha){ 
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
    boxElem.hidden = false;
    boxElem setPoint(align, relative, x, y);
    boxElem.hideWhenInMenu = true;
    boxElem.archived = 0;
    return boxElem;
}
CreateNewsBar(align,relative,x,y,width,height,color,shader,sort,alpha){ //Not mine
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
    barElemBG.hidden = false;
    barElemBG setPoint(align,relative,x,y);
    barElemBG.hideWhenInMenu = true;
    barElemBG.archived = 0;
    return barElemBG;
}
DrawText( text, font, fontscale, x, y, color, alpha, glowcolor, glowalpha, sort ){
	hud = self createfontstring( font, fontscale );
	hud SetElementText( text );
	hud.x = x;
	hud.y = y;
	hud.color = color;
	hud.alpha = alpha;
	hud.glowcolor = glowcolor;
	hud.glowalpha = glowalpha;
	hud.sort = sort;
	hud.alpha = alpha;
	hud.hideWhenInMenu = true;
	hud.archived = 0;
	return hud;
}
DrawShader( shader, x, y, width, height, color, alpha, sort, align, relative, isLevel){
	if(isDefined(isLevel))
		hud = newhudelem( );
	else
		hud = newclienthudelem( self );
	hud.elemtype = "icon";
	hud.color = color;
	hud.alpha = alpha;
	hud.sort = sort;
	hud.children = [];
	if(isDefined(align))
   		hud.align = align;
   	if(isDefined(relative))
   		hud.relative = relative;
   	hud setparent( level.uiparent );
   	hud.x = x;
	hud.y = y;
	hud setshader( shader, width, height );
	hud.hideWhenInMenu = true;
	hud.archived = 0;
	return hud;
}
// Animations
affectElement(type, time, value){
    if(type == "x" || type == "y")
        self moveOverTime(time);
    else
        self fadeOverTime(time);
    if(type == "x")
        self.x = value;
    if(type == "y")
        self.y = value;
    if(type == "alpha")
        self.alpha = value;
    if(type == "color")
        self.color = value;
}
// Text Manager
mv_OverflowFix(){
	level endon("mv_destroy_hud");
    textanchor = CreateServerFontString("default", 1);
    textanchor SetElementText("Anchor");
    textanchor.alpha = 0; 
    level.isInOverflow = false;
    if (GetDvar("g_gametype") == "tdm" || GetDvar("g_gametype") == "hctdm")
        limit = 54;

    if (GetDvar("g_gametype") == "dm" || GetDvar("g_gametype") == "hcdm")
        limit = 54;

    if (GetDvar("g_gametype") == "dom" || GetDvar("g_gametype") == "hcdom")
        limit = 38;

    if (GetDvar("g_gametype") == "dem" || GetDvar("g_gametype") == "hcdem")
        limit = 41;

    if (GetDvar("g_gametype") == "conf" || GetDvar("g_gametype") == "hcconf")
        limit = 53;

    if (GetDvar("g_gametype") == "koth" || GetDvar("g_gametype") == "hckoth")
        limit = 41;

    if (GetDvar("g_gametype") == "hq" || GetDvar("g_gametype") == "hchq")
        limit = 43;

    if (GetDvar("g_gametype") == "ctf" || GetDvar("g_gametype") == "hcctf")
        limit = 32;

    if (GetDvar("g_gametype") == "sd" || GetDvar("g_gametype") == "hcsd")
        limit = 38;

    if (GetDvar("g_gametype") == "oneflag" || GetDvar("g_gametype") == "hconeflag")
        limit = 25;

    if (GetDvar("g_gametype") == "gun")
        limit = 48;

    if (GetDvar("g_gametype") == "oic")
        limit = 51;

    if (GetDvar("g_gametype") == "shrp")
        limit = 48;

    if (GetDvar("g_gametype") == "sas")
        limit = 50;

    if (IsDefined(level.stringoptimization))
        limit += 172;

    while (true){      
        if (IsDefined(level.stringoptimization) && level.stringtable.size >= 100 && !IsDefined(textanchor2)){
            textanchor2 = CreateServerFontString("default", 1);
            textanchor2 SetElementText("Anchor2");                
            textanchor2.alpha = 0; 
        }
        if (level.stringtable.size >= limit){
        	level.isInOverflow = true;
            if (IsDefined(textanchor2)){
                textanchor2 ClearAllTextAfterHudElem();
                textanchor2 DestroyElement();
            } 
            textanchor ClearAllTextAfterHudElem();
            level.stringtable = [];           

            foreach (textelement in level.textelementtable){
                if (!IsDefined(self.label))
                    textelement SetElementText(textelement.text);
                else
                    textelement SetElementValueText(textelement.text);
            }
            level.isInOverflow = false;
        }            
       wait 0.05;
    }
}
SetElementText(text)
{
    self SetText(text);
    if (self.text != text)
        self.text = text;
    if (!IsInArray(level.stringtable, text))
        level.stringtable[level.stringtable.size] = text;
    if (!IsInArray(level.textelementtable, self))
        level.textelementtable[level.textelementtable.size] = self;
}
SetElementValueText(text)
{
    self.label = &"" + text;  
    if (self.text != text)
        self.text = text;
    if (!IsInArray(level.stringtable, text))
        level.stringtable[level.stringtable.size] = text;
    if (!IsInArray(level.textelementtable, self))
        level.textelementtable[level.textelementtable.size] = self;
}
DestroyElement()
{
    if (IsInArray(level.textelementtable, self))
        ArrayRemoveValue(level.textelementtable, self);
    if (IsDefined(self.elemtype))
	{
        self.frame Destroy();
        self.bar Destroy();
        self.barframe Destroy();
    }       
    self Destroy();
}
