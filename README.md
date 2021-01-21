# **Black ops II Mapvote Menu**
Developed by *@DoktorSAS*
Version 2.0.0

Multiple users want a mapvote, so I decided to accommodate them. This mapvote menu is very simple but you don't need programming knowledge to use it, practically everything is configurable by editing a .cfg file. Multiple users want a mapvote, so I decided to accommodate them. This mapvote menu is very simple but you don't need programming knowledge to use it, practically everything is configurable by editing a .cfg file. The menu has been tested on Sorex servers and Gunj 71rcon servers. This post is dedicated only to the released version of mapvote, if you find bugs or problems write under this post. While if you want things to be added or if you want to propose ideas go to the dedicated post for [suggestions](https://forum.plutonium.pw/topic/7426/new-black-ops-ii-mapvote).

## **Insallation Guide**
1. Download the [mapvote mod](https://forum.plutonium.pw) for github releases 
2. Copy the file *_killcam.gsc* and paste in your t6r\data\maps\mp\gametypes\ folder 
3. Add on your dedicated.cfg file all the this lines and configure your mapvote menu
4. Once loaded the written everything in the cfg and set everything you can start the server and play

```cfg

////////////////////////////////////////////////////////////////////////////////////////////////////
//  DoktorSAS Mapvote Menu
//  Twitter: @DoktorSAS
//  Report any bugs under the right post on the forum
////////////////////////////////////////////////////////////////////////////////////////////////////

set isMapvoteEnable 1 // 1 for Mapvote Enable and 0 for Mapvote Disable
set more_maps 1 // 1 for 5 maps style and 0 for 3 maps style
set no_current_mp 1 // The current map will not get chosed in the mapvote
set time_to_vote 25 // Time to vote
set votes_color "5" // Color of the number inside the [ ]

set blur 1.6 // Background blur strength 

set show_social 1 // 1 to show socials and 0 to don't show socials
set server_sentence "Thanks for Playing on this Server" // Sentence on bottom left screen
set social_name "Discord" // The name of the social of the server if you have it
set social_link "Discord.gg/Plutonium" // Link of the server social if you have it

/////////////////////////////////////////////////////
//                                                                    
// List of valid colors:                                      
//                                                                  
/////////////////////////////////////////////////////
//    1. "red"                                                 
//    2. "orange"                                            
//    3. "yellow"                                              
//    4. "purple"                                              
//    5. "pink"                                                
//    6. "cyan"                                                
//    7. "blue"                                                 
//    8. "light blue"                                     
//    9. "green"                                                
//    10. "light green"                                       
//    11. "black"    
//    12. "white"                                          
/////////////////////////////////////////////////////

set bg_color "cyan" // Image background color
set select_color "light green" // Select color
set scroll_color "purple" // Scroll color 
set arrow_color "white" // Arrows color

//////////////////////////////////////////////////
// Maps id List                                 //
// Write the rigth map id inside the dvar       //
// maps to make the mapvote working             //                        
//////////////////////////////////////////////////
//                                              //
// mp_la                - Aftermath             //
// mp_dockside          - Cargo                 //
// mp_carrier           - Carrier               //
// mp_drone             - Drone                 //
// mp_express           - Express               //
// mp_hijacked          - Hijacked              //
// mp_meltdown          - Meltdown              //
// mp_overflow          - Overflow              //
// mp_nightclub         - Plaza                 //
// mp_raid              - Raid                  //
// mp_slums             - Slums                 //
// mp_village           - Standoff              //
// mp_turbine           - Turbine               //
// mp_socotra           - Yemen                 //
//                                              //
// Bonus Map:                                   //
// mp_nuketown_2020     - Nuketown 2025         //
//                                              //
//////////////////////////////////////////////////
// REVOLUTION MAP PACK 1                        //
//////////////////////////////////////////////////
//                                              //
// mp_downhill          - Downhill              //
// mp_mirage            - Mirage                //
// mp_hydro             - Hydro                 //
// mp_skate             - Grind                 //
//                                              //
//////////////////////////////////////////////////
// UPRISING MAP PACK 2                          //
//////////////////////////////////////////////////
//                                              //
// mp_concert           - Encore                //
// mp_magma             - Magma                 //
// mp_vertigo           - Vertigo               //
// mp_studio            - Studio                //
//                                              //
//////////////////////////////////////////////////
// VENGEANCE MAP PACK 3                         //
//////////////////////////////////////////////////
//                                              //
// mp_uplink            - Uplink                //
// mp_bridge            - Detour                //
// mp_castaway          - Cove                  //
// mp_paintball         - Rush                  //
//                                              //
//////////////////////////////////////////////////
// APOCALYPSE MAP PACK 4                        //
//////////////////////////////////////////////////
//                                              //
// mp_dig               - Dig                   //
// mp_frostbite         - Frost                 //
// mp_pod               - Pod                   //
// mp_takeoff           - Takeoff               //
//                                              //
//////////////////////////////////////////////////

//set maps "mp_pod mp_carrier mp_studio mp_raid mp_slums mp_nuketown_2020" // Maps list, here you can write all maps you want in the mapvote
set maps "" // if the vause is "" all maps will show in the mapvote

```
# **Preview**
Here are some previews on how the mapvote will look like, in fact their design is very simple but easy to understand. The buttons remain the usual two buttons "Aim" and "Shoot" to change selection and "jump" to select the map. There is no possibility to change selection.
### Mapvote menu with 5 Maps
In the 5-map mapvote everything is positioned so as to occupy a large part of the screen. Everything has been positioned to create a minimalist design but also very nice.

![](https://forum.plutonium.pw/assets/uploads/files/1610914931203-357e3655-3df3-458c-8d89-577c1973236b-image.png)
### **Mapvote menu with 3 Maps**
In the 3-map mapvote everything is positioned so that it occupies the center of the screen. The design is very simple but very interesting at the same time.

![](https://forum.plutonium.pw/assets/uploads/files/1610914587706-5e32d05c-33d7-4063-a045-3fb49f4752e6-image.png)

# **Download**
You can download the file by pressing [this](), it will take you to the releases section. Download the latest release and remember to keep the mapvote always updated

# **Suggestions Implemented**
All proposed feature ideas modifiable via implemented cfg will be added to this list, with the name of the person who proposed it, a description is a la dvar.

| Suggest by| Suggestion                                             |     Dvar Name                                                    |
| ----------| -------------------------------------------------------| -----------------------------------------------------------------|
| gunji     | Change mapvote colors via cfg                          |     bg_color, select_color, scroll_color,arrow_color, votes_color|                    
| Xerxes    | Use dvar to control the strength of the background blur|     blur                                                         |
| Xerxes    | Use a dvar to remove the branding                      |     show_social                                                  |
| Xerxes    | Take the maps from a dvar                              |     Approved & Implemented                                       |
| DoktorSAS | Usa a dvar to enable the mapvote in a server           |     ismapvoteenable                                              |
| gunji     | Dvar to don't make vote the current map                |     no_current_mp                                                |
| DoktorSAS | Get server sentence from a dvar                        |     server_sentence                                              |
| DoktorSAS | Add a Social Link on the mapvote                       |     social_name, ssocial_link                                    |

social_link
# **Copyright:**
The script was created by DoktorSAS and no one else can say they created it. The script is free and accessible to everyone, it is not possible to sell the script. The script has been created to allow everyone to use it and I would like it to be used in the proper way.
