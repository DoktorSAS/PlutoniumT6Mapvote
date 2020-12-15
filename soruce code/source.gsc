#include common_scripts/utility;
#include maps/mp/gametypes/_hud_util;

#include maps/mp/_utility;
#include maps/mp/_challenges;
#include maps/mp/_medals;
#include maps/mp/_scoreevents;
#include maps/mp/_tacticalinsertion;
#include maps/mp/_demo;
#include maps/mp/_popups;

#include maps/mp/gametypes/_globallogic_spawn;
#include maps/mp/gametypes/_globallogic_audio;
#include maps/mp/gametypes/_globallogic_score;
#include maps/mp/gametypes/_globallogic_utils;
#include maps/mp/gametypes/_globallogic_audio;
#include maps/mp/gametypes/_globallogic_score;
#include maps/mp/gametypes/_globallogic_player;

#include maps/mp/gametypes/_spectating;
#include maps/mp/gametypes/_hud;
#include maps/mp/gametypes/_rank;
#include maps/mp/gametypes/_spawnlogic;
#include maps/mp/gametypes/_globallogic;
#include maps/mp/gametypes/_globallogic_ui;
#include maps/mp/gametypes/_globallogic_utils;
#include maps/mp/gametypes/_spawning;
#include maps/mp/gametypes/_spawnlogic;
#include maps/mp/gametypes/_hostmigration;
#include maps/mp/gametypes/_battlechatter_mp;
#include maps/mp/gametypes/_spawnlogic;
#include maps/mp/gametypes/_spawning;
#include maps/mp/gametypes/_rank;
#include maps/mp/gametypes/_globallogic_defaults;

#include maps/mp/killstreaks/_killstreaks;


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
	level.map_index = -1;
	
	if(!isDefined(getDvar("time_to_vote")) ||  getDvar("time_to_vote") == ""){
		setDvar("time_to_vote", 25);
		level.time_to_vote = getDvarInt("time_to_vote");
	}else
		level.time_to_vote = getDvarInt("time_to_vote");
		

	level.infinalkillcam = 0;
	level.mapvote_started = false;
    precachestring( &"PLATFORM_PRESS_TO_SKIP" );
    precachestring( &"PLATFORM_PRESS_TO_RESPAWN" );
    precacheshader( "white" );
    level.killcam = getgametypesetting( "allowKillcam" );
    level.finalkillcam = getgametypesetting( "allowFinalKillcam" );
    mapvote();
    if(!isDefined(getDvar("server_name")) || getDvar("server_name") == "")
    	setDvar("server_name", "@DoktorSAS is the Mapvote Creator");
    if(!isDefined(getDvar("server_name")) || getDvar("custom_gametype") == "")
    	setDvar("custom_gametype", "");
    else
    	setDvar("custom_gametype", "exec " + getDvar("custom_gametype"));
    /*	
    	level thread ontimelimit();
    	Is not needed anymore
    */
    initfinalkillcam();   
}

/*ontimelimit()
{
	thread OverflowFix();
    thread updateVote();
    foreach(player in level.players){
    	player thread selectmap();
   	}
    wait 5; //This is autoclose menu wiat, change it to have more or less time to vote
    gameended();
    text = "The next map is ^5" + level.maptovote["map"][level.map_index];
	foreach(player in level.players){
		player thread closemenumapmenu();
		player thread notification( text );
	}
    if ( level.teambased )
    {
        maps/mp/gametypes/sd::sd_endgame( game[ "defenders" ], game[ "strings" ][ "time_limit_reached" ] );
    }
    else
    {
        maps/mp/gametypes/sd::sd_endgame( undefined, game[ "strings" ][ "time_limit_reached" ] );
    }
}


ontimelimit(){
	level waittill( "game_ended" );
	wait 1;
	if(!getTeamWinner() && !getKills() && level.teambased && waslastround()){
    	thread OverflowFix();
    	thread updateVote();
    	foreach(player in level.players){
    		player thread selectmap();
   		}
    	wait 5; //This is autoclose menu wait, change it to have more or less time to vote
    	gameended();
    	text = "The next map is ^5" + level.maptovote["map"][level.map_index];
		foreach(player in level.players){
			player thread closemenumapmenu();
			player thread notification( text );
		}
	}
	
	if(!getWinner() && !getKills() && !level.teambased){
    	thread OverflowFix();
    	thread updateVote();
    	foreach(player in level.players){
    		player thread selectmap();
   		}
    	wait 5; //This is autoclose menu wiat, change it to have more or less time to vote
    	gameended();
    	text = "The next map is ^5" + level.maptovote["map"][level.map_index];
		foreach(player in level.players){
			player thread closemenumapmenu();
			player thread notification( text );
		}
    	
	}
}*/

/*
	Some utilities
*/
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

//Print To All
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
	level.timer = createServerFontString("hudsmall" , 2);
	level.timer setPoint("CENTER", "BOTTOM", "CENTER", "BOTTOM");
	if(level.time_to_vote < 60)
		level.timer.label = &"00:";
	else {
		m = level.time_to_vote/60;
		if(m < 10)
			level.timer SetElementText("0"+m+":");
		else
			level.timer SetElementText(m+":");
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
        if(waslastround()){
        	visionsetnaked( getDvar( "mapname" ), 0 );
    		players = level.players;
    		index = 0;
    		while ( index < players.size )
    		{
        		player = players[ index ];
        		player closemenu();
       			player closeingamemenu();
       			player.sessionstate = "dead";
    			player.spectatorclient = -1;
        		index++;
    		}
	    	level.mapvote_started = true;
	    	level thread timer_manager();
	   	 	thread OverflowFix();
	   		thread updateVote();
	    	foreach(player in level.players){
	    		player thread selectmap();
	   		}
	    	wait level.time_to_vote; //This is autoclose menu wait, change it to have more or less time to vote
	    	thread gameended();
	    	text = "The next map is ^5" + level.maptovote["map"][level.map_index];
			foreach(player in level.players){
				player thread closemenumapmenu();
				player thread notification( text );
			}
			wait 5;	
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
    	level.mapvote_started = true;
    	level thread timer_manager();
   	 	thread OverflowFix();
   		thread updateVote();
    	foreach(player in level.players){
    		player thread selectmap();
   		}
    	wait level.time_to_vote; //This is autoclose menu wait, change it to have more or less time to vote
    	thread gameended();
    	text = "The next map is ^5" + level.maptovote["map"][level.map_index];
		foreach(player in level.players){
			player thread closemenumapmenu();
			player thread notification( text );
		}
		wait 5;	
	}
	level notify("show_ranks");
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
updateVote(){ 
	for(;;){
		level waittill("updateVote");
		wait 0.01;
		foreach(player in level.players){
			if(player.mapvotemenu){
				if(player.mapvoted_index == 0)
					player.textMAP1 SetElementText( "^7Vote: [^6 " + level.maptovote["vote"][0] + " ^7]\n^7Map: ^5"+ level.maptovote["map"][0] );		
				if(player.mapvoted_index == 1)
					player.textMAP2 SetElementText( "^7Vote: [^6 " + level.maptovote["vote"][1] + " ^7]\n^7Map: ^5"+ level.maptovote["map"][1] );	
				if(player.mapvoted_index == 2)
					player.textMAP3 SetElementText(" ^7Vote: [^6 " + level.maptovote["vote"][2] + " ^7]\n^7Map: ^5"+ level.maptovote["map"][2] );
			}
		}
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
	if(level.maptovote["vote"][0] == level.maptovote["vote"][1] && level.maptovote["vote"][2] <= level.maptovote["vote"][0]){
		setmap(randomintrange(0,1));
	}else if(level.maptovote["vote"][2] <= level.maptovote["vote"][0] && level.maptovote["vote"][0] == level.maptovote["vote"][2]){
		setmap(randomintrange(1,2));
	}else if(level.maptovote["vote"][0] == level.maptovote["vote"][1] && level.maptovote["vote"][0] == level.maptovote["vote"][2]){
		setmap(randomintrange(0,2));
	}else if(level.maptovote["vote"][0] > level.maptovote["vote"][1] && level.maptovote["vote"][0] > level.maptovote["vote"][2]){
		setmap(0);
	}else if(level.maptovote["vote"][1] >= level.maptovote["vote"][0] && level.maptovote["vote"][1] >= level.maptovote["vote"][2]){
		setmap(1);
	}else{
		setmap(2);
	}	
	
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
	setdvar( "sv_maprotation", getDvar("custom_gametype") + " map " + level.maptovote["name"][index] );
	//This is a dubug print -> printboldToAll("The next map is ^5" + level.maptovote["map"][index] ); 
}
printboldToAll(str){
	foreach(player in level.players){
		player iprintlnbold(str);
	}
}
printToAllMapVoted(str){
	if(!level.gameended){
		foreach(player in level.players){
			if(player != self)
				player iprintln(str);
		}
	}
}
mapvote(){
	 level.maptovote["map"] = [];
	 level.maptovote["name"] = [];
	 level.maptovote["image"] = [];
	 level.maptovote["vote"] = [];
	 
	 level.maptovote["vote"][0] = 0;
	 level.maptovote["vote"][1] = 0;
	 level.maptovote["vote"][2] = 0;
	 
	 level.maptovote["map"][0] = "Default";
	 level.maptovote["map"][1] = "Default";
	 level.maptovote["map"][2] = "Default";
	
	 level.maptovote["name"][0] = "mp_default";
	 level.maptovote["name"][1] = "mp_default";
	 level.maptovote["name"][2] = "mp_default";
	 
	 randommapbyindex(0);
	 randommapbyindex(1);
	 randommapbyindex(2);
}
randommapbyindex( index ){
	level endon("mapnotvalid");
	isValid = true;
	if(index == 0){
		i = randomintrange( 0, 11 );
		mapdata(i, index);
		if(level.maptovote["name"][index] == getDvar("mapname")){
			randommapbyindex(index);
			isValid = false;
		}
	}else if(index == 1){
		i = randomintrange( 11, 20 );
		mapdata(i, index);
		if(level.maptovote["name"][index] == getDvar("mapname") && level.maptovote["name"][index] == level.maptovote["name"][0]){
			randommapbyindex(index);
			isValid = false;
		}
	}else if(index == 2){
		i = randomintrange( 20, 30 );
		mapdata(i, index);
		if(level.maptovote["name"][index] == getDvar("mapname") && level.maptovote["name"][index] == level.maptovote["name"][0] && level.maptovote["name"][index] == level.maptovote["name"][1]){
			randommapbyindex(index);
			isValid = false;
		}
	}
	if(isValid)
		precacheshader( level.maptovote["image"][index] );
}
mapdata( i, index ){ //Map Parser
	/*
		This area convert a number i to a map with all information
		about the maps.
		 # Game Name
		 # map mp
		 # Map image
	*/
	switch( i ){
		//Base MAP
		case 0:
		level.maptovote["map"][index] = "Aftermath";
	 	level.maptovote["name"][index] = "mp_la";
	    level.maptovote["image"][index] = "loadscreen_mp_la";
		break;
		case 1:
		level.maptovote["map"][index] = "Cargo";
	 	level.maptovote["name"][index] = "mp_dockside";
	    level.maptovote["image"][index] = "loadscreen_mp_dockside";
		break;
		case 2:
		level.maptovote["map"][index] = "Carrier";
	 	level.maptovote["name"][index] = "mp_carrier";
	    level.maptovote["image"][index] = "loadscreen_mp_carrier";
		break;
		case 3:
		level.maptovote["map"][index] = "Drone";
	 	level.maptovote["name"][index] = "mp_drone";
	    level.maptovote["image"][index] = "loadscreen_mp_drone";
		break;
		case 4:
		level.maptovote["map"][index] = "Express";
	 	level.maptovote["name"][index] = "mp_express";
	    level.maptovote["image"][index] = "loadscreen_mp_express";
		break;
		case 5:
		level.maptovote["map"][index] = "Hijacked";
	 	level.maptovote["name"][index] = "mp_Hijacked";
	    level.maptovote["image"][index] = "loadscreen_mp_hijacked";
		break;
		case 6:
		level.maptovote["map"][index] = "Meltdown";
	 	level.maptovote["name"][index] = "mp_Meltdown";
	    level.maptovote["image"][index] = "loadscreen_mp_meltdown";
		case 7:
		level.maptovote["map"][index] = "Overflow";
	 	level.maptovote["name"][index] = "mp_Overflow";
	    level.maptovote["image"][index] = "loadscreen_mp_overflow";
		break;
		case 8:
		level.maptovote["map"][index] = "Plaza";
	 	level.maptovote["name"][index] = "mp_nightclub";
	    level.maptovote["image"][index] = "loadscreen_mp_nightclub";
		break;
		case 9:
		level.maptovote["map"][index] = "Raid";
	 	level.maptovote["name"][index] = "mp_raid";
	    level.maptovote["image"][index] = "loadscreen_mp_raid";
		break;
		case 10:
		level.maptovote["map"][index] = "Slums";
	 	level.maptovote["name"][index] = "mp_Slums";
	    level.maptovote["image"][index] = "loadscreen_mp_Slums";
		break;
		case 11:
		level.maptovote["map"][index] = "Standoff";
	 	level.maptovote["name"][index] = "mp_village";
	    level.maptovote["image"][index] = "loadscreen_mp_village";
		break;
		case 12:
		level.maptovote["map"][index] = "Turbine";
	 	level.maptovote["name"][index] = "mp_Turbine";
	    level.maptovote["image"][index] = "loadscreen_mp_Turbine";
		break;
		case 13:
		level.maptovote["map"][index] = "Yemen";
	 	level.maptovote["name"][index] = "mp_socotra";
	    level.maptovote["image"][index] = "loadscreen_mp_socotra";
		break;
		//Bouns MAP
		case 14:
		level.maptovote["map"][index] = "Nuketown 2025";
	 	level.maptovote["name"][index] = "mp_nuketown_2020";
	    level.maptovote["image"][index] = "loadscreen_mp_nuketown_2020";
		break;
		//DLC MAP 1 Revolution
		case 15:
		level.maptovote["map"][index] = "Downhill";
	 	level.maptovote["name"][index] = "mp_downhill";
	    level.maptovote["image"][index] = "loadscreen_mp_downhill";
		break;
		case 16:
		level.maptovote["map"][index] = "Mirage";
	 	level.maptovote["name"][index] = "mp_mirage";
	    level.maptovote["image"][index] = "loadscreen_mp_Mirage";
		break;
		case 17:
		level.maptovote["map"][index] = "Hydro";
	 	level.maptovote["name"][index] = "mp_Hydro";
	    level.maptovote["image"][index] = "loadscreen_mp_Hydro";
		break;
		case 18:
		level.maptovote["map"][index] = "Grind";
	 	level.maptovote["name"][index] = "mp_skate";
	    level.maptovote["image"][index] = "loadscreen_mp_skate";
		break;
		//DLC MAP 2 Uprising
		case 19:
		level.maptovote["map"][index] = "Encore";
	 	level.maptovote["name"][index] = "mp_concert";
	    level.maptovote["image"][index] = "loadscreen_mp_concert";
		break;
		case 20:
		level.maptovote["map"][index] = "Magma";
	 	level.maptovote["name"][index] = "mp_Magma";
	    level.maptovote["image"][index] = "loadscreen_mp_Magma";
		break;
		case 21:
		level.maptovote["map"][index] = "Vertigo";
	 	level.maptovote["name"][index] = "mp_Vertigo";
	    level.maptovote["image"][index] = "loadscreen_mp_Vertigo";
		break;
	    case 22:
		level.maptovote["map"][index] = "Studio";
	 	level.maptovote["name"][index] = "mp_Studio";
	    level.maptovote["image"][index] = "loadscreen_mp_Studio";
		break;
		//DLC MAP 3 Vengeance
		case 23:
		level.maptovote["map"][index] = "Uplink";
	 	level.maptovote["name"][index] = "mp_Uplink";
	    level.maptovote["image"][index] = "loadscreen_mp_Uplink";
		break;
		case 24:
		level.maptovote["map"][index] = "Detour";
	 	level.maptovote["name"][index] = "mp_bridge";
	    level.maptovote["image"][index] = "loadscreen_mp_bridge";
		break;
		case 25:
		level.maptovote["map"][index] = "Cove";
	 	level.maptovote["name"][index] = "mp_castaway";
	    level.maptovote["image"][index] = "loadscreen_mp_castaway";
		break;
		case 26:
		level.maptovote["map"][index] = "Rush";
	 	level.maptovote["name"][index] = "mp_paintball";
	    level.maptovote["image"][index] = "loadscreen_mp_paintball";
		break;
		//DLLC MAP 4 Apocalypse 
		case 27:
		level.maptovote["map"][index] = "Dig";
	 	level.maptovote["name"][index] = "mp_Dig";
	    level.maptovote["image"][index] = "loadscreen_mp_Dig";
		break;
		case 28:
		level.maptovote["map"][index] = "Frost";
	 	level.maptovote["name"][index] = "mp_frostbite";
	    level.maptovote["image"][index] = "loadscreen_mp_frostbite";
		break;
		case 29:
		level.maptovote["map"][index] = "Pod";
	 	level.maptovote["name"][index] = "mp_Pod";
	    level.maptovote["image"][index] = "loadscreen_mp_Pod";
		break;
		case 30:
		level.maptovote["map"][index] = "Takeoff";
	 	level.maptovote["name"][index] = "mp_Takeoff";
	    level.maptovote["image"][index] = "loadscreen_mp_Takeoff";
		break;
		/*case def:
		level.maptovote["map"][index] = "";
	 	level.maptovote["name"][index] = "mp_";
	    level.maptovote["image"][index] = "loadscreen_mp_";
		break;*/
	}
}
selectmap(){ 
	self thread fixAngles( self getPlayerAngles() );
	self.mapvotemenu = true;
	self freezeControlsallowlook(true);
	self setClientUiVisibilityFlag("hud_visible", false);
	self.welcome = self createFontString("hudsmall",1.4);
	self.welcome setPoint("CENTER","CENTER",0,0);
	self.welcome setText("Thanks for playing "+getDvar("server_name")+"^7\nMapvote Developed by @^5DoktorSAS");	
	//self thread AnimatedTextCENTERScrolling("Welcome To ^5SorexFFA^7\nMapvote Menu Developed by ^5DoktorSAS");
	AnimatedVoteAndMapsIN();
	self.buttons = self createFontString("hudsmall", 1.2);
	self.buttons setPoint("CENTER", "CENTER", 0, -25);
	self.buttons SetElementText( "Press ^5Aim/Scope Button ^7 to switch Map | Press ^5F^7 on PC or ^5Reload Button ^7on Controller to select" );	
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
	/*Text Element*/
	self.textMAP1 = self createFontString("hudsmall", 1.5);
	self.textMAP1 setPoint("CENTER", "CENTER", -220, -325);
	self.textMAP2 = self createFontString("hudsmall", 1.5);
	self.textMAP2 setPoint("CENTER", "CENTER", 0, -325);
	self.textMAP3 = self createFontString("hudsmall", 1.5);
	self.textMAP3 setPoint("CENTER", "CENTER", 220, -325); 
	self.textMAP1 SetElementText( "^7Vote: [^5 " + level.maptovote["vote"][0] + " ^7]\n^7Map: ^5"+ level.maptovote["map"][0] );		
	self.textMAP2 SetElementText( "^7Vote: [^5 " + level.maptovote["vote"][1] + " ^7]\n^7Map: ^5"+ level.maptovote["map"][1] );		
	self.textMAP3 SetElementText( "^7Vote: [^5 " + level.maptovote["vote"][2] + " ^7]\n^7Map: ^5"+ level.maptovote["map"][2] );
	/*Maps Image*/
	self.map1 = self drawshader( level.maptovote["image"][0], -220, -310, 200, 126, ( 1, 1, 1 ), 100, 2 );
	self.map1 fadeovertime( 0.3 );
	self.map1.alpha = 0.65;
	self.map2 = self drawshader( level.maptovote["image"][1], 0, -310, 200, 126, ( 1, 1, 1 ), 100, 2 );
	self.map2 fadeovertime( 0.3 );
	self.map2.alpha = 0.65;
	self.map3 = self drawshader( level.maptovote["image"][2], 220, -310, 200, 126, ( 1, 1, 1 ), 100, 2 );
	self.map3 fadeovertime( 0.3 );
	self.map3.alpha = 0.65;
	/*Bakground*/
	self.box1 = self createRectangle("CENTER", "CENTER", -220, -452, 210, 136, (0.502, 0, 1), "white", 1, .7);	
	self.box2 = self createRectangle("CENTER", "CENTER", 0, -452, 210, 136, (0, 1, 1), "white", 1, .7);
	self.box3 = self createRectangle("CENTER", "CENTER", 220, -452, 210, 136, (0, 1, 1), "white", 1, .7);
	/*Animations*/
	self.textMAP1 affectElement("y", 1, -75);
	self.textMAP2 affectElement("y", 1, -75);
	self.textMAP3 affectElement("y", 1, -75);
	self.map1 affectElement("y", 1, -10);
	self.map2 affectElement("y", 1, -10);
	self.map3 affectElement("y", 1, -10);
	self.box1 affectElement("y", 1, -152);
	self.box2 affectElement("y", 1, -152);
	self.box3 affectElement("y", 1, -152);
}
/*
	Is possibile to find a lot of cool code on my github https://github.com/DoktorSAS
	Developer: DoktorSAS
	Discord: https://discord.gg/nCP2y4J
	Mod: Mapvote Menu
	Sorex: https://github.com/DoktorSAS/Sorex/blob/main/README.md
	Description: Mapvote menu on end Game
	
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
baseText(){
	self.textMAP1 SetElementText( "^7Vote: [^5 " + level.maptovote["vote"][0] + " ^7]\n^7Map: ^5"+ level.maptovote["map"][0] );		
	self.textMAP2 SetElementText( "^7Vote: [^5 " + level.maptovote["vote"][1] + " ^7]\n^7Map: ^5"+ level.maptovote["map"][1] );		
	self.textMAP3 SetElementText( "^7Vote: [^5 " + level.maptovote["vote"][2] + " ^7]\n^7Map: ^5"+ level.maptovote["map"][2]  );
	self.box1 DestroyElement();
	self.box2 DestroyElement();
	self.box3 DestroyElement();
	self.box1 = self createRectangle("CENTER", "CENTER", -220, -152, 210, 136, (0, 1, 1), "white", 1, .7);
	self.box2 = self createRectangle("CENTER", "CENTER", 0, -152, 210, 136, (0, 1, 1), "white", 1, .7);
	self.box3 = self createRectangle("CENTER", "CENTER", 220, -152, 210, 136, (0, 1, 1), "white", 1, .7);
}
buttonsmonitor(){ //Manage buttons
	self endon("closemapmenu");
	i = 0;
	for(;;){
		wait 0.05;
		if(self adsbuttonpressed()){ //Go on next map
			if(i == 2){
				i = 0;
			}else i = i + 1;
			baseText(); //Texts, map images and boxes reset
			if(i == 0){
				self.box1 DestroyElement();
				self.box1 = self createRectangle("CENTER", "CENTER", -220, -152, 210, 136, (0.502, 0, 1), "white", 1, .7); //See selection Map1
			}else if(i == 1){
				self.box2 DestroyElement();
				self.box2 = self createRectangle("CENTER", "CENTER", 0, -152, 210, 136, (0.502, 0, 1), "white", 1, .7); //See selection Map2
			}else if(i == 2){
				self.box3 DestroyElement();
				self.box3 = self createRectangle("CENTER", "CENTER", 220, -152, 210, 136, (0.502, 0, 1), "white", 1, .7); //See selection Map3
			}
			wait 0.1; //Don't remove this
		}else if(self usebuttonpressed()){
			level.maptovote["vote"][i] = level.maptovote["vote"][i] + 1;
			self.mapvoted_index = i;
			wait 0.02;
			if(i == 0){
				self.box1 DestroyElement();
				self.box1 = self createRectangle("CENTER", "CENTER", -220, -152, 210, 136, (0, 1, 0), "white", 1, .7);	//See selection Map1
			}else if(i == 1){
				self.box2 DestroyElement();
				self.box2 = self createRectangle("CENTER", "CENTER", 0, -152, 210, 136, (0, 1, 0), "white", 1, .7); //See selection Map2	
			}else if(i == 2){
				self.box3 DestroyElement();
				self.box3 = self createRectangle("CENTER", "CENTER", 220, -152, 210, 136, (0, 1, 0), "white", 1, .7); //See selection Map3
			}
			//self thread printToAllMapVoted("^5" + self.name + " voted for ^5" + level.maptovote["map"][i] + "\n^7MAP: ^5" + level.maptovote["map"][0] + "^7 | VOTE: ^5"+ level.maptovote["vote"][0] + "\n^7MAP: ^5" + level.maptovote["map"][1] + "^7 | VOTE: ^5"+ level.maptovote["vote"][1] + "\n^7MAP: ^5" + level.maptovote["map"][2] + "^7 | VOTE: ^5"+ level.maptovote["vote"][2]);
			level notify("updateVote");
			self notify("closemapmenu");
		}
	}
}
closemenumapmenu(){ //This function is do destory and remove all menu text, box and map images 
	self.buttons DestroyElement();
	self.welcome DestroyElement();
	self.textMAP1 DestroyElement();self.textMAP2 DestroyElement();self.textMAP3 DestroyElement();
	self.box1 DestroyElement();self.box2 DestroyElement();self.box3 DestroyElement();
	self.map1 DestroyElement();self.map2 DestroyElement();self.map3 DestroyElement();
	self setClientUiVisibilityFlag("hud_visible", true);
	self freezeControlsallowlook(false);
}

/*
	Utilities functions, is possibile to find this functions on some forum.
	Just google GSC menu tutorial/guide
*/
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
	return hud;
}
drawshader( shader, x, y, width, height, color, alpha, sort ){
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
}
/*
	Developer: DoktorSAS
	Discord: Discord.io/Sorex
	Mod: All Maps - Map Vote
	Website: sorexproject.webflow.io
	Description: Mapvote menu on end Game
	
	Copyright: The script was created by DoktorSAS and no one else can 
			   say they created it. The script is free and accessible to 
			   everyone, it is not possible to sell the script.
			   
	The OverFlow fix is a fixed based on AIO Menu overflow fix
*/
OverflowFix(){
    level.stringtable = [];
    level.textelementtable = [];
    textanchor = CreateServerFontString("default", 1);
    textanchor SetElementText("Anchor");
    textanchor.alpha = 0; 

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

    while (!level.gameended)    {      
        if (IsDefined(level.stringoptimization) && level.stringtable.size >= 100 && !IsDefined(textanchor2)){
            textanchor2 = CreateServerFontString("default", 1);
            textanchor2 SetElementText("Anchor2");                
            textanchor2.alpha = 0; 
        }
        if (level.stringtable.size >= limit){
            if (IsDefined(textanchor2)){
                textanchor2 ClearAllTextAfterHudElem();
                textanchor2 DestroyElement();
            } 
			foreach(player in level.players){
				player.bad SetElementText("Thanks to ^5DoktorSAS");
				if(player.mapvotemenu){
					if(player.mapvoted_index == 0)
						player.textMAP1 SetElementText( "^7Vote: [^6 " + level.maptovote["vote"][0] + " ^7]\n^7Map: ^5"+ level.maptovote["map"][0] );		
					if(player.mapvoted_index == 1)
						player.textMAP2 SetElementText( "^7Vote: [^6 " + level.maptovote["vote"][1] + " ^7]\n^7Map: ^5"+ level.maptovote["map"][1] );	
					if(player.mapvoted_index == 2)
						player.textMAP3 SetElementText(" ^7Vote: [^6 " + level.maptovote["vote"][2] + " ^7]\n^7Map: ^5"+ level.maptovote["map"][2] );
				}
			}
            textanchor ClearAllTextAfterHudElem();
            level.stringtable = [];           

            foreach (textelement in level.textelementtable){
                if (!IsDefined(self.label))
                    textelement SetElementText(textelement.text);
                else
                    textelement SetElementValueText(textelement.text);
            }
        }            
        wait 0.01;
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
	return hud;
}
drawshader( shader, x, y, width, height, color, alpha, sort ){
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
}
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

