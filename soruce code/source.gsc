
#include maps/mp/gametypes/_globallogic_spawn;
#include maps/mp/gametypes/_spectating;
#include maps/mp/_tacticalinsertion;
#include maps/mp/_challenges;
#include maps/mp/gametypes/_globallogic;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/_utility;
#include common_scripts/utility;

/*
	Developer: DoktorSAS
	Discord: https://discord.gg/nCP2y4J
	Mod: Mapvote Menu
	Sorex: https://github.com/DoktorSAS/Sorex/blob/main/README.md
	Description: Mapvote menu on end Game
	
	Copyright: The script was created by DoktorSAS and no one else can 
			   say they created it. The script is free and accessible to 
			   everyone, it is not possible to sell the script.
*/

init(){
    precacheStatusIcon("compassping_friendlyfiring_mp");
    precacheStatusIcon("compassping_enemy");

   	precachestring( &"PLATFORM_PRESS_TO_SKIP" );
	precachestring( &"PLATFORM_PRESS_TO_RESPAWN" );
	
	precacheshader( "white" );
	
	precacheshader( "ui_scrollbar_arrow_left" );
	precacheshader( "ui_scrollbar_arrow_right" );
	
	level.killcam = getgametypesetting( "allowKillcam" );
	level.finalkillcam = getgametypesetting( "allowFinalKillcam" );
	initfinalkillcam();
	level thread OnPlayerConnected();
	mapvoteinit();
}
OnPlayerConnected(){
	level endon("game_ended");
	for(;;){
		level waittill("connected", player);
		player thread FixBlur();
	}
}
FixBlur(){
	level endon("game_ended");
	self waittill("spawned_player");
	self setblur( 0, 0);
}

initfinalkillcam()
{
    level.finalkillcamsettings = [];
    initfinalkillcamteam( "none" );
    _a23 = level.teams;
    _k23 = getFirstArrayKey( _a23 );
    while ( isDefined( _k23 ) )
    {
        team = _a23[ _k23 ];
        initfinalkillcamteam( team );
        _k23 = getNextArrayKey( _a23, _k23 );
    }
    level.finalkillcam_winner = undefined;
}

initfinalkillcamteam( team )
{
    level.finalkillcamsettings[ team ] = spawnstruct();
    clearfinalkillcamteam( team );
}

clearfinalkillcamteam( team )
{
    level.finalkillcamsettings[ team ].spectatorclient = undefined;
    level.finalkillcamsettings[ team ].weapon = undefined;
    level.finalkillcamsettings[ team ].deathtime = undefined;
    level.finalkillcamsettings[ team ].deathtimeoffset = undefined;
    level.finalkillcamsettings[ team ].offsettime = undefined;
    level.finalkillcamsettings[ team ].entityindex = undefined;
    level.finalkillcamsettings[ team ].targetentityindex = undefined;
    level.finalkillcamsettings[ team ].entitystarttime = undefined;
    level.finalkillcamsettings[ team ].perks = undefined;
    level.finalkillcamsettings[ team ].killstreaks = undefined;
    level.finalkillcamsettings[ team ].attacker = undefined;
}

recordkillcamsettings( spectatorclient, targetentityindex, sweapon, deathtime, deathtimeoffset, offsettime, entityindex, entitystarttime, perks, killstreaks, attacker )
{
    if ( level.teambased && isDefined( attacker.team ) && isDefined( level.teams[ attacker.team ] ) )
    {
        team = attacker.team;
        level.finalkillcamsettings[ team ].spectatorclient = spectatorclient;
        level.finalkillcamsettings[ team ].weapon = sweapon;
        level.finalkillcamsettings[ team ].deathtime = deathtime;
        level.finalkillcamsettings[ team ].deathtimeoffset = deathtimeoffset;
        level.finalkillcamsettings[ team ].offsettime = offsettime;
        level.finalkillcamsettings[ team ].entityindex = entityindex;
        level.finalkillcamsettings[ team ].targetentityindex = targetentityindex;
        level.finalkillcamsettings[ team ].entitystarttime = entitystarttime;
        level.finalkillcamsettings[ team ].perks = perks;
        level.finalkillcamsettings[ team ].killstreaks = killstreaks;
        level.finalkillcamsettings[ team ].attacker = attacker;
    }
    level.finalkillcamsettings[ "none" ].spectatorclient = spectatorclient;
    level.finalkillcamsettings[ "none" ].weapon = sweapon;
    level.finalkillcamsettings[ "none" ].deathtime = deathtime;
    level.finalkillcamsettings[ "none" ].deathtimeoffset = deathtimeoffset;
    level.finalkillcamsettings[ "none" ].offsettime = offsettime;
    level.finalkillcamsettings[ "none" ].entityindex = entityindex;
    level.finalkillcamsettings[ "none" ].targetentityindex = targetentityindex;
    level.finalkillcamsettings[ "none" ].entitystarttime = entitystarttime;
    level.finalkillcamsettings[ "none" ].perks = perks;
    level.finalkillcamsettings[ "none" ].killstreaks = killstreaks;
    level.finalkillcamsettings[ "none" ].attacker = attacker;
}

erasefinalkillcam()
{
    clearfinalkillcamteam( "none" );
    _a89 = level.teams;
    _k89 = getFirstArrayKey( _a89 );
    while ( isDefined( _k89 ) )
    {
        team = _a89[ _k89 ];
        clearfinalkillcamteam( team );
        _k89 = getNextArrayKey( _a89, _k89 );
    }
    level.finalkillcam_winner = undefined;
}

finalkillcamwaiter()
{
    if ( !isDefined( level.finalkillcam_winner ) )
    {
        return 0;
    }
    level waittill( "final_killcam_done" );
    wait 0.02;
    return 1;
}

postroundfinalkillcam()
{
    if ( isDefined( level.sidebet ) && level.sidebet )
    {
        return;
    }
    level notify( "play_final_killcam" );
    maps/mp/gametypes/_globallogic::resetoutcomeforallplayers();
    finalkillcamwaiter();
}
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

timer_manager(){
	level endon("game_ended");
	m = 0;
	if(level.show_social == 1){
		credits = createServerFontString("hudsmall" , 1.2);
		credits setPoint("BOTTOM_LEFT", "BOTTOM_LEFT");
		credits SetElementText(level.server_sentence + "\nDeveloped by @^5DoktorSAS ^7\n" + level.social_name + ": " +  level.social_link);
	}
	level.timer = createServerFontString("hudsmall" , 2);
	level.timer setPoint("CENTER", "BOTTOM", "CENTER", "BOTTOM");
	if(level.time_to_vote < 60)
		level.timer.label = &"00:";
	else {
		m = level.time_to_vote/60;
		if(m < 10){
			while(level.isInOverflow) wait 0.01;
			level.timer.label = &"0"+m+":";
		}else{
			while(level.isInOverflow) wait 0.01;
			level.timer SetValue(m+":");
		}
	}
	m_counter = 0;
	while(level.time_to_vote > 0){
		if(m_counter == 60){
			m_counter = 0;
			m--;
			if(m > 10 && m <= 60){
				level.timer SetElementText(m+":");
			}else if(m < 10 && m > 0)
				level.timer SetElementText("0"+m+":");
			else{
				level.timer SetElementText("00:");
			}
		}
		level.timer setValue(level.time_to_vote);
		wait 1;
		level.time_to_vote--;
	}
	
	level notify("destroy_hud");
	
	level.timer DestroyElement();
	if(level.show_social == 1)
		credits DestroyElement();
	
}
mapvote_texts(){
	level.buttons = level createServerFontString("hudsmall", 2);
	level.buttons SetElementText( "^7 ^3[{+speed_throw}]                ^7Press ^3[{+gostand}] ^7to select                ^3[{+attack}] ^7" );	
	level.textMAP1 = createString( "^7[ ^" + level.votes_color   + level.maptovote["vote"][0] + " ^7] ^7"+ level.maptovote["mapname"][0], "hudsmall", 1.2, "CENTER", "CENTER", -220, -325, (1,1,1), 1, (0,0,0), 0.5, 5, true);		
	level.textMAP2 = createString( "^7[ ^" + level.votes_color   + level.maptovote["vote"][1] + " ^7] ^7"+ level.maptovote["mapname"][1], "hudsmall", 1.2, "CENTER", "CENTER", 0, -325, (1,1,1), 1, (0,0,0), 0.5, 5, true);		
	level.textMAP3 = createString( "^7[ ^" + level.votes_color   + level.maptovote["vote"][2] + " ^7] ^7"+ level.maptovote["mapname"][2], "hudsmall", 1.2, "CENTER", "CENTER", 220, -325, (1,1,1), 1, (0,0,0), 0.5, 5, true);
	level.map1 = level drawshader( level.maptovote["image"][0], -220, -310, 200, 127, ( 1, 1, 1 ), 100, 2 , "CENTER", "CENTER", true);
	level.map1 fadeovertime( 0.3 );
	level.map1.alpha = 0.65;
	level.map2 = level drawshader( level.maptovote["image"][1], 0, -310, 200, 127, ( 1, 1, 1 ), 100, 2 , "CENTER", "CENTER", true);
	level.map2 fadeovertime( 0.3 );
	level.map2.alpha = 0.65;
	level.map3 = level drawshader( level.maptovote["image"][2], 220, -310, 200, 127, ( 1, 1, 1 ), 100, 2 , "RIGHT", "CENTER", true);
	level.map3 fadeovertime( 0.3 );
	level.map3.alpha = 0.65;
	if(level.more_maps == 1){
		level.arrow_right = level drawshader( "ui_scrollbar_arrow_right", 200, 340, 25, 25, level.arrow_color, 100, 2 , "CENTER", "bottom", true);
		level.arrow_left = level drawshader( "ui_scrollbar_arrow_left", -200, 340, 25, 25, level.arrow_color, 100, 2 , "CENTER", "bottom", true);
		level.buttons setPoint("center", "bottom", 0, 150);
		level.textMAP4 = createString( "^7[ ^" + level.votes_color   + level.maptovote["vote"][3] + " ^7] ^7"+ level.maptovote["mapname"][3], "hudsmall", 1.2, "CENTER", "CENTER", -600, 54, (1,1,1), 1, (0,0,0), 0.5, 5, true);		
		level.textMAP5 = createString( "^7[ ^" + level.votes_color   + level.maptovote["vote"][4] + " ^7] ^7"+ level.maptovote["mapname"][4], "hudsmall", 1.2, "CENTER", "CENTER", 600, 54, (1,1,1), 1, (0,0,0), 0.5, 5, true);	
		level.map4 = drawshader( level.maptovote["image"][3], -600, 141, 200, 127, ( 1, 1, 1 ), 100, 2 , "CENTER", "CENTER", true);
		level.map4 fadeovertime( 0.3 );
		level.map4.alpha = 0.65;
		level.map5 = drawshader( level.maptovote["image"][4], 600,  141, 200, 127, ( 1, 1, 1 ), 100, 2 , "CENTER", "CENTER", true);
		level.map5 fadeovertime( 0.3 );
		level.map5.alpha = 0.65;
		level.map1 affectElement("y", 1, -11);
		level.map2 affectElement("y", 1, -11);
		level.map3 affectElement("y", 1, -11);
		level.map4 affectElement("x", 1, -120);
		level.map5 affectElement("x", 1, 120);
		level.textMAP1 affectElement("y", 1, -97);
		level.textMAP2 affectElement("y", 1, -97);
		level.textMAP3 affectElement("y", 1, -97);
		level.textMAP4 affectElement("x", 1, -120);
		level.textMAP5 affectElement("x", 1, 120);
		level waittill("destroy_hud");
		level.buttons DestroyElement();
		level.textMAP1 DestroyElement();
		level.textMAP2 DestroyElement();
		level.textMAP3 DestroyElement();
		level.textMAP4 DestroyElement();
		level.textMAP5 DestroyElement();
		level.map1 DestroyElement();
		level.map2 DestroyElement();
		level.map3 DestroyElement();
		level.map4 DestroyElement();
		level.map5 DestroyElement();
		level.arrow_right DestroyElement();
		level.arrow_left DestroyElement();
	}else{
		level.arrow_right   = self drawshader( "ui_scrollbar_arrow_right", 200, 290, 25, 25, level.arrow_color, 100, 2 , "CENTER", "CENTER", true);
		level.arrow_left = self drawshader( "ui_scrollbar_arrow_left", -200, 290, 25, 25, level.arrow_color, 100, 2 , "CENTER", "CENTER", true);
		level.buttons setPoint("center", "center", 0, 100);
		level.textMAP1 affectElement("y", 1, 24);
		level.textMAP2 affectElement("y", 1, 24);
		level.textMAP3 affectElement("y", 1, 24);
		level.map1 affectElement("y", 1, 89);
		level.map2 affectElement("y", 1, 89);
		level.map3 affectElement("y", 1, 89);
		level waittill("destroy_hud");
		level.buttons DestroyElement();
		level.textMAP1 DestroyElement();
		level.textMAP2 DestroyElement();
		level.textMAP3 DestroyElement();
		level.map1 DestroyElement();
		level.map2 DestroyElement();
		level.map3 DestroyElement();
		level.arrow_right DestroyElement();
		level.arrow_left DestroyElement();
	}
}
dofinalkillcam()
{
    level waittill( "play_final_killcam" );
    level.infinalkillcam = 1;
    winner = "none";
    if ( isDefined( level.finalkillcam_winner ) )
    {
        winner = level.finalkillcam_winner;
    }
    if ( !isDefined( level.finalkillcamsettings[ winner ].targetentityindex ) )
    {
        level.infinalkillcam = 0;
        visionsetnaked( getDvar( "mapname" ), 0 );
    		players = level.players;
    		index = 0;
    		while ( index < players.size )
    		{
        		player = players[ index ];
        		player closemenu();
       			player closeingamemenu();
        		index++;
    		}
        if(waslastround()){
    		if(level.isMapvoteEnable == 1){
    			
		    	level.mapvote_started = true;
		    	level thread timer_manager();
		   	 	level thread OverflowFix_mapvote();
	   	 		level thread mapvote_texts();
	   			level thread updateVote();
		   		thread updateVote();
		    	foreach(player in level.players){
		    		player thread selectmap();
		   		}
		    	wait level.time_to_vote; //This is autoclose menu wait, change it to have more or less time to vote
		    	thread gameended();
		    	wait 0.05;
		    	text = "The next map is ^5" + level.maptovote["mapname"][level.map_index];
				foreach(player in level.players){
					player thread closemenumapmenu();
					player thread notification( text );
					player setblur(0, 4.0);
				}
				wait 5;	
				level.mapvote_started = false;
			}
		}
        level notify( "final_killcam_done" );
        return;
    }
    if ( isDefined( level.finalkillcamsettings[ winner ].attacker ) )
    {
        maps/mp/_challenges::getfinalkill( level.finalkillcamsettings[ winner ].attacker );
    }
    visionsetnaked( getDvar( "mapname" ), 0 );
    players = level.players;
    index = 0;
    while ( index < players.size )
    {
        player = players[ index ];
        player closemenu();
        player closeingamemenu();
        player thread finalkillcam( winner );
        index++;
    }
    wait 0.1;
    while ( areanyplayerswatchingthekillcam() )
    {
        wait 0.05;
    }
    if(waslastround()){
    	if (level.isMapvoteEnable == 1){
    		level.mapvote_started = true;
	    	level thread timer_manager();
	   	 	level thread OverflowFix_mapvote();
	   	 	level thread mapvote_texts();
	   		level thread updateVote();
	    	foreach(player in level.players){
	    		player thread selectmap();
	   		}
	    	wait level.time_to_vote; //This is autoclose menu wait, change it to have more or less time to vote
	    	thread gameended();
	    	text = "The next map is ^5" + level.maptovote["mapname"][level.map_index];
			foreach(player in level.players){
				player thread closemenumapmenu();
				player thread notification( text );
			}
			wait 5;
			level.mapvote_started = false;
    	}
	}
	level notify("show_ranks");
	if (level.isMapvoteEnable == 1)
		wait level.wait_time;
    level notify( "final_killcam_done" );
    level.infinalkillcam = 0;
}
startlastkillcam()
{
}

areanyplayerswatchingthekillcam()
{
    players = level.players;
    index = 0;
    while ( index < players.size )
    {
        player = players[ index ];
        if ( isDefined( player.killcam ) )
        {
            return 1;
        }
        index++;
    }
    return 0;
}

killcam( attackernum, targetnum, killcamentity, killcamentityindex, killcamentitystarttime, sweapon, deathtime, deathtimeoffset, offsettime, respawn, maxtime, perks, killstreaks, attacker )
{
    self endon( "disconnect" );
    self endon( "spawned" );
    level endon( "game_ended" );
    if ( attackernum < 0 )
    {
        return;
    }
    postdeathdelay = ( getTime() - deathtime ) / 1000;
    predelay = postdeathdelay + deathtimeoffset;
    camtime = calckillcamtime( sweapon, killcamentitystarttime, predelay, respawn, maxtime );
    postdelay = calcpostdelay();
    killcamlength = camtime + postdelay;
    if ( isDefined( maxtime ) && killcamlength > maxtime )
    {
        if ( maxtime < 2 )
        {
            return;
        }
        if ( ( maxtime - camtime ) >= 1 )
        {
            postdelay = maxtime - camtime;
        }
        else
        {
            postdelay = 1;
            camtime = maxtime - 1;
        }
        killcamlength = camtime + postdelay;
    }
    killcamoffset = camtime + predelay;
    self notify( "begin_killcam" );
    killcamstarttime = getTime() - ( killcamoffset * 1000 );
    self.sessionstate = "spectator";
    self.spectatorclient = attackernum;
    self.killcamentity = -1;
    if ( killcamentityindex >= 0 )
    {
        self thread setkillcamentity( killcamentityindex, killcamentitystarttime - killcamstarttime - 100 );
    }
    self.killcamtargetentity = targetnum;
    self.archivetime = killcamoffset;
    self.killcamlength = killcamlength;
    self.psoffsettime = offsettime;
    recordkillcamsettings( attackernum, targetnum, sweapon, deathtime, deathtimeoffset, offsettime, killcamentityindex, killcamentitystarttime, perks, killstreaks, attacker );
    _a268 = level.teams;
    _k268 = getFirstArrayKey( _a268 );
    while ( isDefined( _k268 ) )
    {
        team = _a268[ _k268 ];
        self allowspectateteam( team, 1 );
        _k268 = getNextArrayKey( _a268, _k268 );
    }
    self allowspectateteam( "freelook", 1 );
    self allowspectateteam( "none", 1 );
    self thread endedkillcamcleanup();
    wait 0.05;
    if ( self.archivetime <= predelay )
    {
        self.sessionstate = "dead";
        self.spectatorclient = -1;
        self.killcamentity = -1;
        self.archivetime = 0;
        self.psoffsettime = 0;
        self notify( "end_killcam" );
        return;
    }
    self thread checkforabruptkillcamend();
    self.killcam = 1;
    self addkillcamskiptext( respawn );
    if ( !self issplitscreen() && level.perksenabled == 1 )
    {
        self addkillcamtimer( camtime );
        self maps/mp/gametypes/_hud_util::showperks();
    }
    self thread spawnedkillcamcleanup();
    self thread waitskipkillcambutton();
    self thread waitteamchangeendkillcam();
    self thread waitkillcamtime();
    self thread maps/mp/_tacticalinsertion::cancel_button_think();
    self waittill( "end_killcam" );
    self endkillcam( 0 );
    self.sessionstate = "dead";
    self.spectatorclient = -1;
    self.killcamentity = -1;
    self.archivetime = 0;
    self.psoffsettime = 0;
}

setkillcamentity( killcamentityindex, delayms )
{
    self endon( "disconnect" );
    self endon( "end_killcam" );
    self endon( "spawned" );
    if ( delayms > 0 )
    {
        wait ( delayms / 1000 );
    }
    self.killcamentity = killcamentityindex;
}

waitkillcamtime()
{
    self endon( "disconnect" );
    self endon( "end_killcam" );
    wait ( self.killcamlength - 0.05 );
    self notify( "end_killcam" );
}

waitfinalkillcamslowdown( deathtime, starttime )
{
    self endon( "disconnect" );
    self endon( "end_killcam" );
    secondsuntildeath = ( deathtime - starttime ) / 1000;
    deathtime = getTime() + ( secondsuntildeath * 1000 );
    waitbeforedeath = 2;
    maps/mp/_utility::setclientsysstate( "levelNotify", "fkcb" );
    wait max( 0, secondsuntildeath - waitbeforedeath );
    setslowmotion( 1, 0.25, waitbeforedeath );
    wait ( waitbeforedeath + 0.5 );
    setslowmotion( 0.25, 1, 1 );
    wait 0.5;
    maps/mp/_utility::setclientsysstate( "levelNotify", "fkce" );
}

waitskipkillcambutton()
{
    self endon( "disconnect" );
    self endon( "end_killcam" );
    while ( self usebuttonpressed() )
    {
        wait 0.05;
    }
    while ( !self usebuttonpressed() )
    {
        wait 0.05;
    }
    self notify( "end_killcam" );
    self clientnotify( "fkce" );
}

waitteamchangeendkillcam()
{
    self endon( "disconnect" );
    self endon( "end_killcam" );
    self waittill( "changed_class" );
    endkillcam( 0 );
}

waitskipkillcamsafespawnbutton()
{
    self endon( "disconnect" );
    self endon( "end_killcam" );
    while ( self fragbuttonpressed() )
    {
        wait 0.05;
    }
    while ( !self fragbuttonpressed() )
    {
        wait 0.05;
    }
    self.wantsafespawn = 1;
    self notify( "end_killcam" );
}

endkillcam( final )
{
    if ( isDefined( self.kc_skiptext ) )
    {
        self.kc_skiptext.alpha = 0;
    }
    if ( isDefined( self.kc_timer ) )
    {
        self.kc_timer.alpha = 0;
    }
    self.killcam = undefined;
    if ( !self issplitscreen() )
    {
        self hideallperks();
    }
    self thread maps/mp/gametypes/_spectating::setspectatepermissions();
}

checkforabruptkillcamend()
{
    self endon( "disconnect" );
    self endon( "end_killcam" );
    while ( 1 )
    {
        if ( self.archivetime <= 0 )
        {
            break;
        }
        else
        {
            wait 0.05;
        }
    }
    self notify( "end_killcam" );
}

spawnedkillcamcleanup()
{
    self endon( "end_killcam" );
    self endon( "disconnect" );
    self waittill( "spawned" );
    self endkillcam( 0 );
}

spectatorkillcamcleanup( attacker )
{
    self endon( "end_killcam" );
    self endon( "disconnect" );
    attacker endon( "disconnect" );
    attacker waittill( "begin_killcam", attackerkcstarttime );
    waittime = max( 0, attackerkcstarttime - self.deathtime - 50 );
    wait waittime;
    self endkillcam( 0 );
}

endedkillcamcleanup()
{
    self endon( "end_killcam" );
    self endon( "disconnect" );
    level waittill( "game_ended" );
    self endkillcam( 0 );
}

endedfinalkillcamcleanup()
{
    self endon( "end_killcam" );
    self endon( "disconnect" );
    level waittill( "game_ended" );
    self endkillcam( 1 );
}

cancelkillcamusebutton()
{
    return self usebuttonpressed();
}

cancelkillcamsafespawnbutton()
{
    return self fragbuttonpressed();
}

cancelkillcamcallback()
{
    self.cancelkillcam = 1;
}

cancelkillcamsafespawncallback()
{
    self.cancelkillcam = 1;
    self.wantsafespawn = 1;
}

cancelkillcamonuse()
{
    self thread cancelkillcamonuse_specificbutton( ::cancelkillcamusebutton, ::cancelkillcamcallback );
}

cancelkillcamonuse_specificbutton( pressingbuttonfunc, finishedfunc )
{
    self endon( "death_delay_finished" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    for ( ;; )
    {
        if ( !( self [[ pressingbuttonfunc ]]() ) )
        {
            wait 0.05;
            continue;
        }
        else buttontime = 0;
        while ( self [[ pressingbuttonfunc ]]() )
        {
            buttontime += 0.05;
            wait 0.05;
        }
        if ( buttontime >= 0.5 )
        {
            continue;
        }
        else buttontime = 0;
        while ( !( self [[ pressingbuttonfunc ]]() ) && buttontime < 0.5 )
        {
            buttontime += 0.05;
            wait 0.05;
        }
        if ( buttontime >= 0.5 )
        {
            continue;
        }
        else
        {
            self [[ finishedfunc ]]();
            return;
        }
    }
}

finalkillcam( winner )
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    if ( waslastround() )
    {
        setmatchflag( "final_killcam", 1 );
        setmatchflag( "round_end_killcam", 0 );
    }
    else
    {
        setmatchflag( "final_killcam", 0 );
        setmatchflag( "round_end_killcam", 1 );
    }
    if ( getDvarInt( "scr_force_finalkillcam" ) == 1 )
    {
        setmatchflag( "final_killcam", 1 );
        setmatchflag( "round_end_killcam", 0 );
    }
    if ( level.console )
    {
        self maps/mp/gametypes/_globallogic_spawn::setthirdperson( 0 );
    }
    killcamsettings = level.finalkillcamsettings[ winner ];
    postdeathdelay = ( getTime() - killcamsettings.deathtime ) / 1000;
    predelay = postdeathdelay + killcamsettings.deathtimeoffset;
    camtime = calckillcamtime( killcamsettings.weapon, killcamsettings.entitystarttime, predelay, 0, undefined );
    postdelay = calcpostdelay();
    killcamoffset = camtime + predelay;
    killcamlength = ( camtime + postdelay ) - 0.05;
    killcamstarttime = getTime() - ( killcamoffset * 1000 );
    self notify( "begin_killcam" );
    self.sessionstate = "spectator";
    self.spectatorclient = killcamsettings.spectatorclient;
    self.killcamentity = -1;
    if ( killcamsettings.entityindex >= 0 )
    {
        self thread setkillcamentity( killcamsettings.entityindex, killcamsettings.entitystarttime - killcamstarttime - 100 );
    }
    self.killcamtargetentity = killcamsettings.targetentityindex;
    self.archivetime = killcamoffset;
    self.killcamlength = killcamlength;
    self.psoffsettime = killcamsettings.offsettime;
    _a613 = level.teams;
    _k613 = getFirstArrayKey( _a613 );
    while ( isDefined( _k613 ) )
    {
        team = _a613[ _k613 ];
        self allowspectateteam( team, 1 );
        _k613 = getNextArrayKey( _a613, _k613 );
    }
    self allowspectateteam( "freelook", 1 );
    self allowspectateteam( "none", 1 );
    self thread endedfinalkillcamcleanup();
    wait 0.05;
    if ( self.archivetime <= predelay )
    {
        self.sessionstate = "dead";
        self.spectatorclient = -1;
        self.killcamentity = -1;
        self.archivetime = 0;
        self.psoffsettime = 0;
        self notify( "end_killcam" );
        return;
    }
    self thread checkforabruptkillcamend();
    self.killcam = 1;
    if ( !self issplitscreen() )
    {
        self addkillcamtimer( camtime );
    }
    self thread waitkillcamtime();
    self thread waitfinalkillcamslowdown( level.finalkillcamsettings[ winner ].deathtime, killcamstarttime );
    self waittill( "end_killcam" );
    self endkillcam( 1 );
    setmatchflag( "final_killcam", 0 );
    setmatchflag( "round_end_killcam", 0 );
    self spawnendoffinalkillcam();
}

spawnendoffinalkillcam()
{
    [[ level.spawnspectator ]]();
    self freezecontrols( 1 );
}

iskillcamentityweapon( sweapon )
{
    if ( sweapon == "planemortar_mp" )
    {
        return 1;
    }
    return 0;
}

iskillcamgrenadeweapon( sweapon )
{
    if ( sweapon == "frag_grenade_mp" )
    {
        return 1;
    }
    else
    {
        if ( sweapon == "frag_grenade_short_mp" )
        {
            return 1;
        }
        else
        {
            if ( sweapon == "sticky_grenade_mp" )
            {
                return 1;
            }
            else
            {
                if ( sweapon == "tabun_gas_mp" )
                {
                    return 1;
                }
            }
        }
    }
    return 0;
}

calckillcamtime( sweapon, entitystarttime, predelay, respawn, maxtime )
{
    camtime = 0;
    if ( getDvar( #"C45D9077" ) == "" )
    {
        if ( iskillcamentityweapon( sweapon ) )
        {
            camtime = ( ( getTime() - entitystarttime ) / 1000 ) - predelay - 0.1;
        }
        else if ( !respawn )
        {
            camtime = 5;
        }
        else if ( iskillcamgrenadeweapon( sweapon ) )
        {
            camtime = 4.25;
        }
        else
        {
            camtime = 2.5;
        }
    }
    else
    {
        camtime = getDvarFloat( #"C45D9077" );
    }
    if ( isDefined( maxtime ) )
    {
        if ( camtime > maxtime )
        {
            camtime = maxtime;
        }
        if ( camtime < 0.05 )
        {
            camtime = 0.05;
        }
    }
    return camtime;
}

calcpostdelay()
{
    postdelay = 0;
    if ( getDvar( #"0D34D95D" ) == "" )
    {
        postdelay = 2;
    }
    else
    {
        postdelay = getDvarFloat( #"0D34D95D" );
        if ( postdelay < 0.05 )
        {
            postdelay = 0.05;
        }
    }
    return postdelay;
}

addkillcamskiptext( respawn )
{
    if ( !isDefined( self.kc_skiptext ) )
    {
        self.kc_skiptext = newclienthudelem( self );
        self.kc_skiptext.archived = 0;
        self.kc_skiptext.x = 0;
        self.kc_skiptext.alignx = "center";
        self.kc_skiptext.aligny = "middle";
        self.kc_skiptext.horzalign = "center";
        self.kc_skiptext.vertalign = "bottom";
        self.kc_skiptext.sort = 1;
        self.kc_skiptext.font = "objective";
    }
    if ( self issplitscreen() )
    {
        self.kc_skiptext.y = -100;
        self.kc_skiptext.fontscale = 1.4;
    }
    else
    {
        self.kc_skiptext.y = -120;
        self.kc_skiptext.fontscale = 2;
    }
    if ( respawn )
    {
        self.kc_skiptext settext( &"PLATFORM_PRESS_TO_RESPAWN" );
    }
    else
    {
        self.kc_skiptext settext( &"PLATFORM_PRESS_TO_SKIP" );
    }
    self.kc_skiptext.alpha = 1;
}

addkillcamtimer( camtime )
{
}

initkcelements()
{
    if ( !isDefined( self.kc_skiptext ) )
    {
        self.kc_skiptext = newclienthudelem( self );
        self.kc_skiptext.archived = 0;
        self.kc_skiptext.x = 0;
        self.kc_skiptext.alignx = "center";
        self.kc_skiptext.aligny = "top";
        self.kc_skiptext.horzalign = "center_adjustable";
        self.kc_skiptext.vertalign = "top_adjustable";
        self.kc_skiptext.sort = 1;
        self.kc_skiptext.font = "default";
        self.kc_skiptext.foreground = 1;
        self.kc_skiptext.hidewheninmenu = 1;
        if ( self issplitscreen() )
        {
            self.kc_skiptext.y = 20;
            self.kc_skiptext.fontscale = 1.2;
        }
        else
        {
            self.kc_skiptext.y = 32;
            self.kc_skiptext.fontscale = 1.8;
        }
    }
    if ( !isDefined( self.kc_othertext ) )
    {
        self.kc_othertext = newclienthudelem( self );
        self.kc_othertext.archived = 0;
        self.kc_othertext.y = 48;
        self.kc_othertext.alignx = "left";
        self.kc_othertext.aligny = "top";
        self.kc_othertext.horzalign = "center";
        self.kc_othertext.vertalign = "middle";
        self.kc_othertext.sort = 10;
        self.kc_othertext.font = "small";
        self.kc_othertext.foreground = 1;
        self.kc_othertext.hidewheninmenu = 1;
        if ( self issplitscreen() )
        {
            self.kc_othertext.x = 16;
            self.kc_othertext.fontscale = 1.2;
        }
        else
        {
            self.kc_othertext.x = 32;
            self.kc_othertext.fontscale = 1.6;
        }
    }
    if ( !isDefined( self.kc_icon ) )
    {
        self.kc_icon = newclienthudelem( self );
        self.kc_icon.archived = 0;
        self.kc_icon.x = 16;
        self.kc_icon.y = 16;
        self.kc_icon.alignx = "left";
        self.kc_icon.aligny = "top";
        self.kc_icon.horzalign = "center";
        self.kc_icon.vertalign = "middle";
        self.kc_icon.sort = 1;
        self.kc_icon.foreground = 1;
        self.kc_icon.hidewheninmenu = 1;
    }
    if ( !self issplitscreen() )
    {
        if ( !isDefined( self.kc_timer ) )
        {
            self.kc_timer = createfontstring( "hudbig", 1 );
            self.kc_timer.archived = 0;
            self.kc_timer.x = 0;
            self.kc_timer.alignx = "center";
            self.kc_timer.aligny = "middle";
            self.kc_timer.horzalign = "center_safearea";
            self.kc_timer.vertalign = "top_adjustable";
            self.kc_timer.y = 42;
            self.kc_timer.sort = 1;
            self.kc_timer.font = "hudbig";
            self.kc_timer.foreground = 1;
            self.kc_timer.color = vectorScale( ( 1, 1, 1 ), 0.85 );
            self.kc_timer.hidewheninmenu = 1;
        }
    }
}
/*
	Developer: DoktorSAS
	Discord: https://discord.gg/nCP2y4J
	Mod: Mapvote Menu
	Sorex: https://github.com/DoktorSAS/Sorex/blob/main/README.md
	Description: Mapvote menu on end Game
	
	Copyright: The script was created by DoktorSAS and no one else can 
			   say they created it. The script is free and accessible to 
			   everyone, it is not possible to sell the script.
*/
ThreadVoteFix(){
	level endon("game_ended");
	while(level.isInOverflow) wait 0.01;
	level.textMAP1 SetElementText( "^7[ ^" + level.votes_color   + level.maptovote["vote"][0] + " ^7] ^7"+ level.maptovote["mapname"][0] );	
	while(level.isInOverflow) wait 0.01;
	level.textMAP2 SetElementText( "^7[ ^" + level.votes_color   + level.maptovote["vote"][1] + " ^7] ^7"+ level.maptovote["mapname"][1] );
	while(level.isInOverflow) wait 0.01;
	level.textMAP3 SetElementText( "^7[ ^" + level.votes_color   + level.maptovote["vote"][2] + " ^7] ^7"+ level.maptovote["mapname"][2] );
	while(level.isInOverflow) wait 0.01;
	level.textMAP4 SetElementText( "^7[ ^" + level.votes_color   + level.maptovote["vote"][3] + " ^7] ^7"+ level.maptovote["mapname"][3] );	
	while(level.isInOverflow) wait 0.01;
	level.textMAP5 SetElementText( "^7[ ^" + level.votes_color   + level.maptovote["vote"][4] + " ^7] ^7"+ level.maptovote["mapname"][4] );
}
updateVote(){ 
	level endon("game_ended");
	for(;;){
		level waittill("updateVote");
		level thread ThreadVoteFix();
	}
}
playerSetText(player){
	player.textMAP1 SetElementText( "^7[ ^" + level.votes_color   + level.maptovote["vote"][0] + " ^7] ^7"+ level.maptovote["mapname"][0] );	
	player.textMAP2 SetElementText( "^7[ ^" + level.votes_color   + level.maptovote["vote"][1] + " ^7] ^7"+ level.maptovote["mapname"][1] );
	player.textMAP3 SetElementText( "^7[ ^" + level.votes_color   + level.maptovote["vote"][2] + " ^7] ^7"+ level.maptovote["mapname"][2] );
	player.textMAP4 SetElementText( "^7[ ^" + level.votes_color   + level.maptovote["vote"][3] + " ^7] ^7"+ level.maptovote["mapname"][3] );	
	player.textMAP5 SetElementText( "^7[ ^" + level.votes_color   + level.maptovote["vote"][4] + " ^7] ^7"+ level.maptovote["mapname"][4] );
}

most_voted_map( vector ){
	logprint("mapvote;mapindex;" + 0 + ";votes;" +  vector[0] + "\n");
	result = 0;
	size = 0;
	same_votes = 0;
	map_with_same_votes = [];
	for(i = result+1; i < vector.size; i++){
		logprint("mapvote;mapindex;" + i + ";votes;" +  vector[i] + "\n");
		if(vector[result] < vector[i])
			result = i;
		else if(vector[result] == vector[i]){
			same_votes = i;
			map_with_same_votes[size] = i;
			size++;
		}
		logprint("mapvote;result;" + result + ";votes;" +  vector[result] + "\n");
	}
	if(vector[result] < vector[same_votes] && size >= 2){
		result = randomintrange(0, size-1);
		logprint("mapvote;finalresultvector;" + result + ";votes;" +  vector[result] + "\n");
		return result;
	}else{
		logprint("mapvote;finalresult;" + result + ";votes;" +  vector[result] + "\n");
		return result;
	}
}

gameended(){
  	/*
  		When the game end the the mapvote menu will be closed automaticaly and the map 
  		will be chosed by the system
  	*/
  	foreach(player in level.players){
    	if(player.mapvotemenu){
    		player thread closemenumapmenu();
    		player.mapvotemenu = false;
    	}
    }
    r = most_voted_map( level.maptovote["vote"] );
    logprint("mapvote;finalresult;" + r + "\n");
    setmap( r );
}
notification( text ){
	precacheshader( "gradient");
	/*First style of Notification Background*/
	notifiy = self createRectangle("CENTER", "CENTER", 0, 300, 200, 60, (0, 0, 0), "white", 0, 0.9); 
	/*Second style of Notification Background*/
	/*notifiy = self drawshader( "gradient", 0, -300, 200, 60, ( 0, 0, 0 ), 100, 1 );
	notifiy fadeovertime( 0.3 );
	notifiy.alpha = 0.65;*/
	map = createString(text, "small", 1.5, "CENTER", "CENTER", 0, 300, (1,1,1), 1, (0,0,0), 1, 5);
	notifiy affectElement("y", .5, 160);
	map affectElement("y", .5, 160);
}
setmap( index ){
	level.map_index = index;
	setdvar( "sv_maprotation", getDvar("custom_gametype") + " map " + level.maptovote["mapid"][index] );
}
printToAllMapVoted(str){
	if(!level.gameended){
		foreach(player in level.players){
			if(player != self)
				player iprintln(str);
		}
	}
}
mapvoteinit(){
	level.map_index = 1;
	level.mapvote_started = false;
	
	SetDvarIfNotInizialized("time_to_vote", 25);
    SetDvarIfNotInizialized("server_sentence", "Thanks for Playing by @DoktorSAS");
    SetDvarIfNotInizialized("custom_gametype", "");
    SetDvarIfNotInizialized("social_name", "Discord");
    SetDvarIfNotInizialized("social_link", "https://discord.gg/nCP2y4J");
    SetDvarIfNotInizialized("more_maps", 1);	
    SetDvarIfNotInizialized("blur", 1.6);
    SetDvarIfNotInizialized("isMapvoteEnable", 0);
    SetDvarIfNotInizialized("no_current_map", 1);
    SetDvarIfNotInizialized("show_social", 1);
    SetDvarIfNotInizialized("arrow_color", "white");
	level.time_to_vote = getDvarInt("time_to_vote");
	level.show_social = getDvarInt("show_social");
	level.server_sentence = getDvar("server_sentence");
	level.social_name = getDvar("social_name");
	level.social_link = getDvar("social_link");
	level.more_maps = getDvarInt("more_maps");
	level.blur =  getDvarInt("blur");
	level.isMapvoteEnable = getDvarInt("isMapvoteEnable");
	level.no_current_map = getDvarInt("no_current_map");
	level.arrow_color = getColor(getDvar("arrow_color"));
    	
    level.bg_color = GetColor( getDvar("bg_color") );
    level.select_color = GetColor( getDvar("select_color") ); 
    level.scroll_color = GetColor( getDvar("scroll_color") );
    if(isValidColor( getDvar("votes_color") ))
    	level.votes_color = getDvar("votes_color") ;
    else
    	level.votes_color = 5;
    
    level.maps_list = undefined;
    if(getDvar("maps") != ""){
    	level.allmaps = [];
    	logprint("mapvote:"+IsInizialized(getDvar("maps")) + ";value;" + getDvar("maps") + "\n");
    	level.maps_list = [];
    	level.maps_list = strTok(getDvar("maps"), " ");
    	if(level.no_current_map == 1){
    		current_map = getDvar("mapname");
    		maps = "";
    		for(i = 0; i < level.maps_list.size; i++){
    			m = level.maps_list[i];
    			level.allmaps[ m ] = spawnStruct();
    			if(level.maps_list[i] != current_map){
    				logprint("mapvote:value;" + level.maps_list[i] + "\n");
    				maps = maps + level.maps_list[i] + " ";
    			}
    		}
    		level.maps_list = [];
    		level.maps_list = strTok(maps, " ");
    	}
    	if(level.maps_list.size >= 3 && level.more_maps == 0)
    		SetupMapList();
    	else if(level.maps_list.size >= 4 && level.more_maps == 1)
    		SetupMapList();
    	else{
    		logprint("mapvote error;not defined the right numbers of maps\n");
    		setDvar("maps","");
    	}
    }else{
      
    }
    
    level.mapnames = [];
	level.mapnames = strTok("Aftermath-Cargo-Carrier-Drone-Express-Hijacked-Meltdown-Overflow-Plaza-Raid-Slums-Standoff-Turbine-Yemen-Nuketown 2025-Downhill-Mirage-Hydro-Grind-Encore-Magma-Vertigo-Studio-Uplink-Detour-Cove-Rush-Dig-Frost-Pod-Takeoff", "-");
	level.mapids = [];
	level.mapids= strTok("mp_la-mp_dockside-mp_carrier-mp_drone-mp_express-mp_hijacked-mp_meltdown-mp_overflow-mp_nightclub-mp_raid-mp_slums-mp_village-mp_turbine-mp_socotra-mp_nuketown_2020-mp_downhill-mp_mirage-mp_hydro-mp_skate-mp_concert-mp_magma-mp_vertigo-mp_studio-mp_uplink-mp_bridge-mp_castaway-mp_paintball-mp_dig-mp_frostbite-mp_pod-mp_takeoff", "-"); 
		
	level.maptovote["mapname"] = [];
	level.maptovote["mapid"] = [];
	level.maptovote["image"] = [];
	level.maptovote["vote"] = [];
	 
	level.maptovote["vote"][0] = 0;
	level.maptovote["vote"][1] = 0;
	level.maptovote["vote"][2] = 0;
	level.maptovote["vote"][3] = 0;
	level.maptovote["vote"][4] = 0;
	 
	level.maptovote["mapname"][0] = "Default";
	level.maptovote["mapname"][1] = "Default";
	level.maptovote["mapname"][2] = "Default";
	level.maptovote["mapname"][3] = "Default";
	level.maptovote["mapname"][4] = "Default";
	
	level.maptovote["mapid"][0] = "mp_raid";
	level.maptovote["mapid"][1] = "mp_raid";
	level.maptovote["mapid"][2] = "mp_raid";
	level.maptovote["mapid"][3] = "mp_raid";
	level.maptovote["mapid"][4] = "mp_raid";
	 
	level.maptovote["image"][0] = "loadscreen_mp_raid";
	level.maptovote["image"][1] = "loadscreen_mp_raid";
	level.maptovote["image"][2] = "loadscreen_mp_raid";
	level.maptovote["image"][3] = "loadscreen_mp_raid";
	level.maptovote["image"][4] = "loadscreen_mp_raid";
	precacheshader( "loadscreen_mp_raid" );
	
	if(level.more_maps == 0)
		randommapbyindex( 3 );
	else
		randommapbyindex( 5 );
	 
}
randommapbyindex( maps ){
	level endon("mapnotvalid");
	max = maps;
	index = maps;
	if(getDvar("maps") == ""){
		range = int(30/maps);
	}else{
		float_range = (level.maps_list.size/maps);
		range = int(float_range);
	}
	start_range = 0;
	while( maps > 0){
		index = max - maps; 
		start_range = range*index; 
		end_range = start_range+range;
		if(index == 4 && getDvar("maps") != "")
			i = randomintrange( start_range, level.maps_list.size); 
		else
			i = randomintrange( start_range, end_range); 
		logPrint("mapvote:start_range;" + start_range + ";end_range;" +  end_range + ";index;" + index + "\n");
		logPrint("mapvote:" + isDefined(level.maps_list) + ";mapdata;" +  i + " " + level.maps_list[i] + ";size;"+ level.maps_list.size  +  "\n");
		if(getDvar("maps") == ""){
			mapdata(i, index);
			if(level.no_current_map == 1){
				while(level.maptovote["mapid"][index] == getDvar("mapname")){
					if(index == 4)
						i = randomintrange( start_range, 30); 
					else
						i = randomintrange( start_range, end_range); 
					mapdata(i, index);
					wait 0.01;
				}
			}
		}else{
			SetMapData(index, level.maps_list[i]);
		}
			
		precacheshader( level.maptovote["image"][index] );
		maps--;
	}
	
}

SetMapData(index, map){
	level.maptovote["mapname"][index] = level.allmaps[ map ].mapname;
	level.maptovote["mapid"][index] = level.allmaps[ map ].mapid;
	level.maptovote["image"][index] = level.allmaps[ map ].image;
}
	
mapdata( i, index ){ 
	level.maptovote["mapname"][index] = level.mapnames[i];
	level.maptovote["mapid"][index] = level.mapids[i];
	level.maptovote["image"][index] = "loadscreen_" + level.mapids[i];
}
selectmap(){ 
	self.mapvotemenu = true;
	self thread AnimatedVoteAndMapsIN();
	self thread fixAngles( self getPlayerAngles() );
	self thread buttonsmonitor();
}
fixAngles( angles ){
	level endon("game_ended");
	self endon("disconnect");
	for(;;){
		if(self getPlayerAngles() != angles)
			self setPlayerAngles( angles );
		wait 0.00001;
	}
}
AnimatedVoteAndMapsIN(){
	self.isOM = false;
	self setblur( level.blur, 1.5 );
	/*Bakgrounds*/
	self.box1 = self createRectangle("CENTER", "CENTER", -220, -452, 210, 136, level.scroll_color, "white", 1, .7);	
	self.box2 = self createRectangle("CENTER", "CENTER", 0, -452, 210, 136, level.bg_color, "white", 1, .7);
	self.box3 = self createRectangle("CENTER", "CENTER", 220, -452, 210, 136, level.bg_color, "white", 1, .7);
	/*Animations*/
	if(level.more_maps == 1){	
		self.box4 = self createRectangle("CENTER", "CENTER",  -600, 0, 210, 136, level.bg_color, "white", 1, .7);	
		self.box5 = self createRectangle("CENTER", "CENTER", 600,  0, 210, 136, level.bg_color, "white", 1, .7);
		self.box1 affectElement("y", 1, -152);
		self.box2 affectElement("y", 1, -152);
		self.box3 affectElement("y", 1, -152);
		self.box4 affectElement("x", 1, -120);
		self.box5 affectElement("x", 1, 120);
	}else{
		self.arrow_right   = self drawshader( "ui_scrollbar_arrow_right", 200, 290, 25, 25, level.arrow_color, 100, 2 , "CENTER", "CENTER");
		self.arrow_left = self drawshader( "ui_scrollbar_arrow_left", -200, 290, 25, 25, level.arrow_color, 100, 2 , "CENTER", "CENTER");
		self.box1 affectElement("y", 1, -52);
		self.box2 affectElement("y", 1, -52);
		self.box3 affectElement("y", 1, -52);
	}
	
	
} 
/*
	Is possibile to find a lot of cool code on my github https://github.com/DoktorSAS
	Developer: DoktorSAS
	Discord: https://discord.gg/nCP2y4J
	Mod: Mapvote Menu
	Sorex: https://github.com/DoktorSAS/Sorex/blob/main/README.md
	Description: Mapvote menu on End Game
	
	Copyright: The script was created by DoktorSAS and no one else can 
			   say they created it. The script is free and accessible to 
			   everyone, it is not possible to sell the script.
*/
AnimatedTextCENTERScrolling(text){ //Made by DoktorSAS
	self.welcome = self createFontString("objective",2);
	self.welcome setPoint("CENTER","CENTER",-300,0);
	self.welcome setText("");	
	for(pos=-300;pos<=600;pos = pos + 1){
		self.welcome setPoint("CENTER","CENTER",pos,0);
		self.welcome setText(text);
		wait 0.000001;
	}
	self.welcome setText("");
}
reset_all( ){
	/*self.textMAP1 SetElementText( "^7[ ^" + level.votes_color + level.maptovote["vote"][0] + " ^7] ^7"+ level.maptovote["mapname"][0] );		
	self.textMAP2 SetElementText( "^7[ ^" + level.votes_color + level.maptovote["vote"][1] + " ^7] ^7"+ level.maptovote["mapname"][1] );		
	self.textMAP3 SetElementText( "^7[ ^" + level.votes_color + level.maptovote["vote"][2] + " ^7] ^7"+ level.maptovote["mapname"][2]  );*/
	self.box1.color = level.bg_color;
	self.box2.color = level.bg_color;
	self.box3.color = level.bg_color;
}

reset_all_5_maps( ){ 
	/*self.textMAP1 SetElementText( "^7[ ^" + level.votes_color + level.maptovote["vote"][0] + " ^7] ^7"+ level.maptovote["mapname"][0] );		
	self.textMAP2 SetElementText( "^7[ ^" + level.votes_color + level.maptovote["vote"][1] + " ^7] ^7"+ level.maptovote["mapname"][1] );		
	self.textMAP3 SetElementText( "^7[ ^" + level.votes_color + level.maptovote["vote"][2] + " ^7] ^7"+ level.maptovote["mapname"][2] );
	self.textMAP4 SetElementText( "^7[ ^" + level.votes_color + level.maptovote["vote"][3] + " ^7] ^7"+ level.maptovote["mapname"][3] );		
	self.textMAP5 SetElementText( "^7[ ^" + level.votes_color + level.maptovote["vote"][4] + " ^7] ^7"+ level.maptovote["mapname"][4] );*/
	self.box1.color = level.bg_color;
	self.box2.color = level.bg_color;
	self.box3.color = level.bg_color;
	self.box4.color = level.bg_color;
	self.box5.color = level.bg_color;
}

buttonsmonitor(){ //Manage buttons
	level endon("game_ended");
	self endon("disconnect");
	self endon("closemapmenu");
	//self freeze_player_controls( 0 );
	//self freezecontrols( 0 );
	mapvote_refresh = ::reset_all;
	more_maps = level.more_maps;
	if(more_maps == 1)
		mapvote_refresh = ::reset_all_5_maps;
	i = 0;
	for(;;){
		if(self.statusicon != "compassping_enemy" || self.statusicon != "compassping_friendlyfiring_mp")
			self.statusicon = "compassping_enemy";
		wait 0.05;
		if(self attackbuttonpressed()){ //Go on next map
			if(i == 2 && more_maps == 0){
				i = 0;
			}else if(i == 4 && more_maps == 1){
				i = 0;
			}else i = i + 1;
			self [[mapvote_refresh]]( ); //Texts, map images and boxes reset
			if(more_maps == 0){
				if(i == 0){
					self.box1 affectElement("color", 0.2, level.scroll_color);
				}else if(i == 1){
					self.box2 affectElement("color", 0.2, level.scroll_color);
				}else if(i == 2){
					self.box3 affectElement("color", 0.2, level.scroll_color);
				}
			}else{
				if(i == 0){
					self.box1 affectElement("color", 0.2, level.scroll_color);
				}else if(i == 1){
					self.box2 affectElement("color", 0.2, level.scroll_color);
				}else if(i == 2){
					self.box3 affectElement("color", 0.2, level.scroll_color);
				}else if(i == 3){
					self.box4 affectElement("color", 0.2, level.scroll_color);
				}else if(i == 4){
					self.box5 affectElement("color", 0.2, level.scroll_color);
				}
			}
			
			wait 0.1; //Don't remove this
		}else if(self adsbuttonpressed()){ //Go on next map
			if(i == 0 && more_maps == 0){
				i = 2;
			}else if(i == 0 && more_maps == 1){
				i = 4;
			}else i = i - 1;
			self [[mapvote_refresh]]( ); //Texts, map images and boxes reset
			if(more_maps == 0){
				if(i == 0){
					self.box1 affectElement("color", 0.2, level.scroll_color);
				}else if(i == 1){
					self.box2 affectElement("color", 0.2, level.scroll_color);
				}else if(i == 2){
					self.box3 affectElement("color", 0.2, level.scroll_color);
				}
			}else{
				if(i == 0){
					self.box1 affectElement("color", 0.2, level.scroll_color);
				}else if(i == 1){
					self.box2 affectElement("color", 0.2, level.scroll_color);
				}else if(i == 2){
					self.box3 affectElement("color", 0.2, level.scroll_color);
				}else if(i == 3){
					self.box4 affectElement("color", 0.2, level.scroll_color);
				}else if(i == 4){
					self.box5 affectElement("color", 0.2, level.scroll_color);
				}
			}
			
			wait 0.1; //Don't remove this
		}else if(self jumpbuttonpressed()){
			self.mapvoted_index = i;
			level.maptovote["vote"][i] = level.maptovote["vote"][i] + 1;
			wait 0.02;
			if(more_maps == 0){
				if(i == 0){
					self.box1 affectElement("color", 0.2, level.select_color);
				}else if(i == 1){
					self.box2 affectElement("color", 0.2, level.select_color);
				}else if(i == 2){
					self.box3 affectElement("color", 0.2, level.select_color);
				}
			}else{
				if(i == 0){
					self.box1 affectElement("color", 0.5, level.select_color);
				}else if(i == 1){
					self.box2 affectElement("color", 0.5, level.select_color);
				}else if(i == 2){
					self.box3 affectElement("color", 0.5, level.select_color);
				}else if(i == 3){
					self.box4 affectElement("color", 0.5, level.select_color);
				}else if(i == 4){
					self.box5 affectElement("color", 0.5, level.select_color);
				}
			}
			self.statusicon = "compassping_friendlyfiring_mp";
			//self thread printToAllMapVoted("^5" + self.name + " voted for ^5" + level.maptovote["mapname"][i] + "\n^7MAP: ^5" + level.maptovote["mapname"][0] + "^7 | VOTE: ^5"+ level.maptovote["vote"][0] + "\n^7MAP: ^5" + level.maptovote["mapname"][1] + "^7 | VOTE: ^5"+ level.maptovote["vote"][1] + "\n^7MAP: ^5" + level.maptovote["mapname"][2] + "^7 | VOTE: ^5"+ level.maptovote["vote"][2]);
			level notify("updateVote");
			self notify("closemapmenu");
		}
	}
}
closemenumapmenu(){ //This function is do destory and remove all menu text, box and map images 
	self.box1 DestroyElement();self.box2 DestroyElement();self.box3 DestroyElement();
	self.box4 DestroyElement();self.box5 DestroyElement();
}
/*
	Developer: DoktorSAS
	Discord: https://discord.gg/nCP2y4J
	Mod: Mapvote Menu
	Sorex: https://github.com/DoktorSAS/Sorex/blob/main/README.md
	Description: Mapvote menu on end Game
	
	Copyright: The script was created by DoktorSAS and no one else can 
			   say they created it. The script is free and accessible to 
			   everyone, it is not possible to sell the script.
*/
OverflowFix_mapvote(){
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
        wait 0.00000001;
    }
}
SetElementText(text){
    self SetText(text);
    if (self.text != text)
        self.text = text;
    if (!IsInArray(level.stringtable, text))
        level.stringtable[level.stringtable.size] = text;
    if (!IsInArray(level.textelementtable, self))
        level.textelementtable[level.textelementtable.size] = self;
}
SetElementValueText(text){
    self.label = &"" + text;  
    if (self.text != text)
        self.text = text;
    if (!IsInArray(level.stringtable, text))
        level.stringtable[level.stringtable.size] = text;
    if (!IsInArray(level.textelementtable, self))
        level.textelementtable[level.textelementtable.size] = self;
}
DestroyElement(){
    if (IsInArray(level.textelementtable, self))
        ArrayRemoveValue(level.textelementtable, self);
    if (IsDefined(self.elemtype)){
        self.frame Destroy();
        self.bar Destroy();
        self.barframe Destroy();
    }       
    self Destroy();
}
/*
	Utilities functions, is possibile to find this functions on some forum.
	Just google GSC menu tutorial/guide
*/
printToAll(str){
	foreach(player in level.players){
		 if(isDefined(player.pers["isBot"]) && player.pers["isBot"]){	
  		}else player iprintln(str);
	}
}
printboldToAll(str){
	foreach(player in level.players){
		if(isDefined(player.pers["isBot"]) && player.pers["isBot"]){	
  		}else player iprintlnbold(str);
	}
}
/*drawtext( text, font, fontscale, x, y, color, alpha, glowcolor, glowalpha, sort ){
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
	return hud;
}*/
/*drawshader( shader, x, y, width, height, color, alpha, sort ){
	hud = newclienthudelem( self );
	hud.elemtype = "icon";
	hud.color = color;
	hud.alpha = alpha;
	hud.sort = sort;
	hud.children = [];
	hud setparent( level.uiparent );
	hud setshader( shader, width, height );
	hud.x = x;
	hud.y = y;
	return hud;
}*/
createString(input, font, fontScale, align, relative, x, y, color, alpha, glowColor, glowAlpha, sort, isLevel, isValue){
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
	hud.archived = false;
	hud.hideWhenInMenu = true;
	return hud;
}
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
createRectangle(align, relative, x, y, width, height, color, shader, sort, alpha){ 
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
    return boxElem;
}
createNewsBar(align,relative,x,y,width,height,color,shader,sort,alpha){ //Not mine
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
}
drawtext( text, font, fontscale, x, y, color, alpha, glowcolor, glowalpha, sort ){
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
	return hud;
}
drawshader( shader, x, y, width, height, color, alpha, sort, align, relative, isLevel){
	if(isDefined(isLevel))
		hud = newhudelem( ); // Fix for level shader
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
	return hud;
}
ThereKillcam(){
	thereKillcam = false;
	foreach(player in level.players){
    	if(player.pers["kills"] > 0)
    		thereKillcam = true;
   	}
   	return thereKillcam;
}
ThereaWinner(){
	thereWinner = false;
	foreach(player in level.players){
    	if(player.pers["pointstowin"] == level.scorelimit)
    		thereWinner = true;
   	}  	
   	return thereWinner;
}
ThereTeamWinner(){
	return [[level._getteamscore]]( "axis" ) == level.scorelimit || [[level._getteamscore]]( "allies" ) == level.scorelimit;
}


SetDvarIfNotInizialized(dvar, value){ // DoktorSAS Dvar utilities
	if(!IsInizialized(dvar))
		setDvar(dvar, value);
}
IsInizialized(dvar){ // DoktorSAS Dvar utilities
	result = getDvar(dvar);
	return result != undefined || result != "";
} 
GetColor( color ){ // DoktorSAS Dvar utilities
	switch(tolower(color)){
    	case "red":
    		return (0.960, 0.180, 0.180);
    	break;
    	case "black":
    		return (0, 0, 0);
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

SetupMapList( )
{
		level.allmaps["mp_la"].mapname = "Aftermath";
		level.allmaps["mp_la"].mapid = "mp_la";
		level.allmaps["mp_la"].image = "loadscreen_mp_la";
		level.allmaps["mp_meltdown"].mapname = "Meltdown";
		level.allmaps["mp_meltdown"].mapid = "mp_meltdown";
		level.allmaps["mp_meltdown"].image = "loadscreen_mp_meltdown";
		level.allmaps["mp_overflow"].mapname = "Overflow";
		level.allmaps["mp_overflow"].mapid = "mp_overflow";
		level.allmaps["mp_overflow"].image = "loadscreen_mp_overflow";
		level.allmaps["mp_nightclub"].mapname = "Plaza";
		level.allmaps["mp_nightclub"].mapid = "mp_nightclub";
		level.allmaps["mp_nightclub"].image = "loadscreen_mp_nightclub";
		level.allmaps["mp_dockside"].mapname = "Cargo";
		level.allmaps["mp_dockside"].mapid = "mp_dockside";
		level.allmaps["mp_dockside"].image = "loadscreen_mp_dockside";
		level.allmaps["mp_carrier"].mapname = "Carrier";
		level.allmaps["mp_carrier"].mapid = "mp_carrier";
		level.allmaps["mp_carrier"].image = "loadscreen_mp_carrier";
		level.allmaps["mp_drone"].mapname = "Drone";
		level.allmaps["mp_drone"].mapid = "mp_drone";
		level.allmaps["mp_drone"].image = "loadscreen_mp_drone";
		level.allmaps["mp_express"].mapname = "Express";
		level.allmaps["mp_express"].mapid = "mp_express";
		level.allmaps["mp_express"].image = "loadscreen_mp_express";
		level.allmaps["mp_hijacked"].mapname = "Hijacked";
		level.allmaps["mp_hijacked"].mapid = "mp_hijacked";
		level.allmaps["mp_hijacked"].image = "loadscreen_mp_hijacked";
		level.allmaps["mp_raid"].mapname = "Raid";
		level.allmaps["mp_raid"].mapid = "mp_raid";
		level.allmaps["mp_raid"].image = "loadscreen_mp_raid";
		level.allmaps["mp_slums"].mapname = "Slums";
		level.allmaps["mp_slums"].mapid = "mp_slums";
		level.allmaps["mp_slums"].image = "loadscreen_mp_Slums";
		level.allmaps["mp_village"].mapname = "Standoff";
		level.allmaps["mp_village"].mapid = "mp_village";
		level.allmaps["mp_village"].image = "loadscreen_mp_village";
		level.allmaps["mp_turbine"].mapname = "Turbine";
		level.allmaps["mp_turbine"].mapid = "mp_turbine";
		level.allmaps["mp_turbine"].image = "loadscreen_mp_Turbine";
		level.allmaps["mp_socotra"].mapname = "Yemen";
		level.allmaps["mp_socotra"].mapid = "mp_socotra";
		level.allmaps["mp_socotra"].image = "loadscreen_mp_socotra";
		level.allmaps["mp_nuketown_2020"].mapname = "Nuketown 2025";
		level.allmaps["mp_nuketown_2020"].mapid = "mp_nuketown_2020";
		level.allmaps["mp_nuketown_2020"].image = "loadscreen_mp_nuketown_2020";
		level.allmaps["mp_downhill"].mapname = "Downhill";
		level.allmaps["mp_downhill"].mapid = "mp_downhill";
		level.allmaps["mp_downhill"].image = "loadscreen_mp_downhill";
		level.allmaps["mp_mirage"].mapname = "Mirage";
		level.allmaps["mp_mirage"].mapid = "mp_mirage";
		level.allmaps["mp_mirage"].image = "loadscreen_mp_Mirage";
		level.allmaps["mp_hydro"].mapname = "Hydro";
		level.allmaps["mp_hydro"].mapid = "mp_hydro";
		level.allmaps["mp_hydro"].image = "loadscreen_mp_Hydro";
		level.allmaps["mp_skate"].mapname = "Grind";
		level.allmaps["mp_skate"].mapid = "mp_skate";
		level.allmaps["mp_skate"].image = "loadscreen_mp_skate";
		level.allmaps["mp_concert"].mapname = "Encore";
		level.allmaps["mp_concert"].mapid = "mp_concert";
		level.allmaps["mp_concert"].image = "loadscreen_mp_concert";
		level.allmaps["mp_magma"].mapname = "Magma";
		level.allmaps["mp_magma"].mapid = "mp_magma";
		level.allmaps["mp_magma"].image = "loadscreen_mp_Magma";
		level.allmaps["mp_vertigo"].mapname = "Vertigo";
		level.allmaps["mp_vertigo"].mapid = "mp_vertigo";
		level.allmaps["mp_vertigo"].image = "loadscreen_mp_Vertigo";
		level.allmaps["mp_studio"].mapname = "Studio";
		level.allmaps["mp_studio"].mapid = "mp_studio";
		level.allmaps["mp_studio"].image = "loadscreen_mp_Studio";
		level.allmaps["mp_uplink"].mapname = "Uplink";
		level.allmaps["mp_uplink"].mapid = "mp_uplink";
		level.allmaps["mp_uplink"].image = "loadscreen_mp_Uplink";
		level.allmaps["mp_bridge"].mapname = "Detour";
		level.allmaps["mp_bridge"].mapid = "mp_bridge";
		level.allmaps["mp_bridge"].image = "loadscreen_mp_bridge";
		level.allmaps["mp_castaway"].mapname = "Cove";
		level.allmaps["mp_castaway"].mapid = "mp_castaway";
		level.allmaps["mp_castaway"].image = "loadscreen_mp_castaway";
		level.allmaps["mp_paintball"].mapname = "Rush";
		level.allmaps["mp_paintball"].mapid = "mp_paintball";
		level.allmaps["mp_paintball"].image = "loadscreen_mp_paintball";
		level.allmaps["mp_dig"].mapname = "Dig";
		level.allmaps["mp_dig"].mapid = "mp_dig";
		level.allmaps["mp_dig"].image = "loadscreen_mp_Dig";
		level.allmaps["mp_frostbite"].mapname = "Frost";
		level.allmaps["mp_frostbite"].mapid = "mp_frostbite";
		level.allmaps["mp_frostbite"].image = "loadscreen_mp_frostbite";
		level.allmaps["mp_pod"].mapname = "Pod";
		level.allmaps["mp_pod"].mapid = "mp_pod";
		level.allmaps["mp_pod"].image = "loadscreen_mp_Pod";
		level.allmaps["mp_takeoff"].mapname = "Takeoff";
		level.allmaps["mp_takeoff"].mapid = "mp_takeoff";
		level.allmaps["mp_takeoff"].image = "loadscreen_mp_Takeoff";
		level.allmaps["mp_dockside"].mapname = "Cargo";
		level.allmaps["mp_dockside"].mapid = "mp_dockside";
		level.allmaps["mp_dockside"].image = "loadscreen_mp_dockside";
}
isValidColor( value ){ // DoktorSAS Dvar utilities
	return value == "0" || value == "1" || value == "2" || value == "3" || value == "4" || value == "5" || value == "6" || value == "7" ;
}



