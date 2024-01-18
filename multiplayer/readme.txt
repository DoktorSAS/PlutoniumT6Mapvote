----------------------------------------

        BLACK OPS II PLUTONIUM                 
          MULTIPLAYER MAPVOTE

        Developed by @DoktorSAS
        
----------------------------------------

 × Requirements
 × How to setup the mapvote step by step

----------------------------------------

 × Requirements

 The mapvote will work as intended only on server side or where is implemented map rotation. 

----------------------------------------

 × How to setup the mapvote step by step

 1) Compile the `mapvote.gsc` file using a GSC Compiler. This step is not required if you are working with the plutonium client.
 2) Copy the compiled file into your directory `%localappdata%\Plutonium\storage\t6\scripts\mp\`.
 3) Copy the Content of the mapvote.cfg in your .cfg (Exemple: server.cfg, dedicated_mp.cfg, dedicated.cfg, etc ) file that manages the Server.
 4) Edit Dvars on your configuration file;
    set the Dvar mv_maps to decide the maps that will be shown in mapvote, Example:
        set mv_maps "mp_studio mp_nuketown_2020 mp_carrier mp_drone mp_slums"
    set the dvar mv_enable to 1 if you want have it active on your server.
    If you want random gametypes you have to set the dvar mp_gametypes specifying the gametype id (dm, war, sd, etc) and the file to run if necessary. Exemple:
        set mv_gametypes "dm;freeforall.cfg war;mycustomtdm.cfg"
 5) Run the Server and have fun. Done!

----------------------------------------

