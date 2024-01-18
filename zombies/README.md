# Plutonium: Black ops II Mapvote
![Preview](https://pbs.twimg.com/media/FPwGOL5VcAIgWvk?format=jpg&name=large)

### Requirements

The mapvote will work as intended only on server side or where is implemented map rotation. 

#### How to setup the mapvote step by step 
1. **Compile the Script:**
   Compile the `mapvote.gsc` file using a GSC Compiler. This step is not required if you are working with the plutonium client.

2. **Place the Compiled File:**
   Copy the file into your directory `%localappdata%\Plutonium\storage\t6\scripts\zm\`.

3. **Configure Server File:**
   Copy the content of `mapvote.cfg` into your server configuration file (e.g., `server.cfg`, `dedicated_zm.cfg`, `dedicated.cfg`, etc.) that manages the Zombies server.

4. **Edit Dvars on your configuration file:**
   - Set the Dvar `mv_maps` to specify the maps shown in the mapvote. For example:
     ```
     set mv_maps "zm_tomb zm_buried zm_town zm_busdepot zm_farm zm_transit zm_prison zm_highrise zm_nuked"
     ```
   - Set the Dvar `mv_enable` to 1 to activate the mapvote on your Zombies server.

5. **Run the Server:**
   Start the server and enjoy the map voting experience. You're done!