# Plutonium: Black ops II Mapvote
Developed by [@DoktorSAS](https://twitter.com/DoktorSAS)

Special thanks to [@ZECxR3ap3r](https://twitter.com/ZECxR3ap3r) & [@JezuzLizard](https://forum.plutonium.pw/user/jezuzlizard) for the development
Special thanks to [@John Kramer](https://forum.plutonium.pw/user/john-kramer) for the images photo edit

## Zombies 

![Preview](https://pbs.twimg.com/media/FPwGOL5VcAIgWvk?format=jpg&name=large)

### Requirements

- The script can only run on Server, It will not work in private games.
- Server must be hosted on Plutonium client, the script works only on Plutonium client.

#### How to setup the mapvote step by step 
 1) Compile the file mapvote.gsc with a GSC Compiler.
 2) Copy the Compiled file in your Directory %localappdata%\Plutonium\storage\t6\scripts\zm\
 3) Copy the Content of the mapvote.cfg in your .cfg (Exemple: server.cfg, dedicated_zm.cfg, dedicated.cfg, etc ) file that manages the Server.
 4) Edit the Dvars to setup the Server, many Dvars are only for Aesthetic Parameters.
    - set the Dvar mv_maps to decide the maps that will be shown in mapvote, Example:
        - set mv_maps "zm_tomb zm_buried zm_town zm_busdepot zm_farm zm_transit zm_prison zm_highrise zm_nuked"
    - set the dvar mv_enable to 1 if you want have it active on your server.
 5) Run the Server and have fun. Done!