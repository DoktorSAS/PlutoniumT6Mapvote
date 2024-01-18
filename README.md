
<div id="header" align="center">
  <h1>Call of Dutuy: Black ops II mapvote</h1>

  [![Build Badge](https://img.shields.io/badge/Developed_by-DoktorSAS-brightgreen?style=for-the-badge&logo=x)](https://twitter.com/DoktorSAS)
  [![License](https://img.shields.io/badge/LICENSE-GPL--3.0-blue?style=for-the-badge&logo=appveyor)](LICENSE)





Special thanks to [@ZECxR3ap3r](https://twitter.com/ZECxR3ap3r) & [@JezuzLizard](https://forum.plutonium.pw/user/jezuzlizard) for their contributions to the development. Additional thanks to [@John Kramer](https://forum.plutonium.pw/user/john-kramer) for image editing.

</div>

This project, initiated in March 2020, enables players to vote for the next map and/or game mode in upcoming matches. The project does not provide compiled files; if needed, compile the file using the [gsc-tool](https://github.com/xensik/gsc-tool).

## Support
- **Multiplayer** *(Call of Duty: Black Ops II Multiplayer)*: `PC`, `XBOX`, `PS3`
- **Zombies** *(Call of Duty: Black Ops II Zombies)*: `PC`

## Installation

### **Zombies (ZM)**

1. **Compile the Script:**
   Compile the `mapvote.gsc` file using a GSC Compiler. This step is not required if you are working with the plutonium client.

2. **Place the Compiled File:**
   Copy the file into your directory `%localappdata%\Plutonium\storage\t6\scripts\zm\`.

3. **Configure Server File:**
   Copy the content of `mapvote.cfg` into your server configuration file (e.g., `server.cfg`, `dedicated_zm.cfg`, `dedicated.cfg`, etc.) that manages the Zombies server.

4. **Edit Dvars for Aesthetic Parameters:**
   - Set the Dvar `mv_maps` to specify the maps shown in the mapvote. For example:
     ```
     set mv_maps "zm_tomb zm_buried zm_town zm_busdepot zm_farm zm_transit zm_prison zm_highrise zm_nuked"
     ```
   - Set the Dvar `mv_enable` to 1 to activate the mapvote on your Zombies server.

5. **Run the Server:**
   Start the server and enjoy the map voting experience. You're done!

### **Multiplayer (MP)**

1. **Compile the Script:**
   Compile the `mapvote.gsc` file using a GSC Compiler. This step is not required if you are working with the plutonium client.

2. **Place the Compiled File:**
   Copy the compiled file into your directory `%localappdata%\Plutonium\storage\t6\scripts\mp\`.

3. **Configure Server File:**
   Copy the content of `mapvote.cfg` into your server configuration file (e.g., `server.cfg`, `dedicated_mp.cfg`, `dedicated.cfg`, etc.) that manages the Multiplayer server.

4. **Edit Dvars for Aesthetic Parameters:**
   - Set the Dvar `mv_maps` to specify the maps shown in the mapvote. For example:
     ```
     set mv_maps "mp_studio mp_nuketown_2020 mp_carrier mp_drone mp_slums"
     ```
   - Set the Dvar `mv_enable` to 1 to activate the mapvote on your Multiplayer server.
   - For random gametypes, set the Dvar `mv_gametypes` specifying the gametype ID (dm, war, sd, etc.) and the file to run if necessary. For example:
     ```
     set mv_gametypes "dm@freeforall.cfg war@mycustomtdm.cfg"
     ```

5. **Run the Server:**
   Start the server and immerse yourself in the map voting experience. You're done!


## Disclaimer
These scripts were created for academic research purposes. Project maintainers are not responsible for misuse of the software. Use responsibly. The project is protected by a GNU license, allowing free usage as long as the code remains open source and is not sold.
