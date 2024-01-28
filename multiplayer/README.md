## Multiplayer

![Preview](https://pbs.twimg.com/media/FN-E1BcXwAsWQS4?format=jpg&name=large)

### Requirements

The mapvote will work as intended only on server side or where is implemented map rotation. 

#### How to setup the mapvote step by step 

1. **Compile the Script:**
   Compile the `mapvote.gsc` file using a GSC Compiler. This step is not required if you are working with the plutonium client.

2. **Place the Compiled File:**
   Copy the compiled file into your directory `%localappdata%\Plutonium\storage\t6\scripts\mp\`.

3. **Configure Server File:**
   Copy the content of `mapvote.cfg` into your server configuration file (e.g., `server.cfg`, `dedicated_mp.cfg`, `dedicated.cfg`, etc.) that manages the Multiplayer server.

4. **Edit Dvars on your configuration file:**
   - Set the Dvar `mv_maps` to specify the maps shown in the mapvote. For example:
     ```
     set mv_maps "mp_studio mp_nuketown_2020 mp_carrier mp_drone mp_slums"
     ```
   - Set the Dvar `mv_enable` to 1 to activate the mapvote on your Multiplayer server.
   - For random gametypes, set the Dvar `mv_gametypes` specifying the gametype ID (dm, war, sd, etc.) and the file to run if necessary. For example:
     ```
     set mv_gametypes "dm@freeforall.cfg war@mycustomtdm.cfg"
     ```
5. (Plutonium ONLY) LUI UI with mod support:
   - Take the content of the folder `T6Mapvote` and place it in your folder `%localappdata%\Plutonium\storage\t6\mods\`
   - Set the dvar `fs_game` in your server configuration file (e.g., `server.cfg`, `dedicated_zm.cfg`, `dedicated.cfg`, etc.)
   - Set the dvar `mv_lui` to in your server configuration file (e.g., `server.cfg`, `dedicated_zm.cfg`, `dedicated.cfg`, etc.)

5. **Run the Server:**
   Start the server and immerse yourself in the map voting experience. You're done!

## Dvars

| Dvar                 | Default Value | Description                                                |
|----------------------|---------------|------------------------------------------------------------|
| `mv_enable`          | 1             | Enable/Disable the mapvote (1 for enable, 0 for disable).  |
| `mv_maps`            | ""            | List of maps that can be voted on the mapvote; leave empty for all maps. |
| `mv_time`            | 20            | Time (in seconds) allotted for voting.                      |
| `mv_credits`         | 1             | Enable/Disable credits of the mod creator.                  |
| `mv_socialname`      | "SocialName"  | Name of the server's social platform (Discord, Twitter, Website, etc.). |
| `mv_sentence`        | "Thanks for playing" | Thankful sentence displayed.                            |
| `mv_votecolor`       | "5"           | Color of the vote number.                                   |
| `mv_arrowcolor`      | "white"       | RGB color of the arrows.                                    |
| `mv_selectcolor`     | "lighgreen"   | RGB color when a map gets voted.                            |
| `mv_backgroundcolor` | "grey"        | RGB color of the map background.                            |
| `mv_blur`            | "3"           | Blur effect power.                                         |
| `mv_gametypes`       | ""            | Dvar to have multiple gametypes with different maps. Specify gametype IDs and associated files. |
| `mv_extramaps`       | 0             | Enable 6 maps mapvote when set to 1.                        |
| `mv_allowchangevote` | 1             | Enable/Disable the possibility to change vote while the time is still running (1 for enable, 0 for disable). |
| `mv_randomoption`    | 1             | If set to 1 it will not display which map and which gametype the last option will be (Random) |
| `mv_minplayerstovote`| 1             | Set the minimum number of players required to start the mapvote  |
| `mv_lui`             | 1             |  If set to 1 it will use the LUA/LUI ui interface (It required the mod support and the lua files) |