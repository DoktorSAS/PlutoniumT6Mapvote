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