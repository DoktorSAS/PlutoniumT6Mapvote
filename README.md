# Black ops II Mapvote Menu
**Mapvote v1.2.0**
Developed by **DoktorSAS**

**How to add the mapvote to the server?**
1. Copy **_killcam.gsc** ( don't change the name of the file)
2. Put the file into **maps/mp/gametpyes**
3. Change the **sv_maprotation** to only one map *(exemple sv_maprotation "map mp_carrier")*
4. Add in your .cfg file **set server_name "Exemple Server Name"** to set the server name to show on the mapvote menu
5. Add in your .cfg file **set custom_gametype "exemple.cfg"** to set the the default gametype for the next map (If you do not change the gamemode you may not add it). If you want change the gamemode just overwrite the **custom_gametype** dvar (use setDvar("custom_gametype", "exemple.cfg")) in your mods and when map rotate players will play the new gamemode
6.  Add in your .cfg file **set time_to_vote {number} ** to set the the time to vote like **set time_to_vote 25** 

**Download v1.2.0**: https://github.com/DoktorSAS/mapvote/releases/tag/1.2.0
**Video Tutorial**: https://youtu.be/ji3BBYS1ISE

![8c10eea4-449f-4147-9e07-7ffb925649c2-image.png](/assets/uploads/files/1608033246340-8c10eea4-449f-4147-9e07-7ffb925649c2-image.png) 
###### V1.0.1
**Bug Fixed in v1.0.1**:
1. Fixed mapvote menu when game end with killcam and there no team winner

###### V1.0.2
**Bug Fixed in v1.0.2**:
1. Nothing

**Update in v1.0.2**:
1. Added a notification to show to the players wich map is the next
*Design 1:* 
![Version 1](https://forum.plutonium.pw/assets/uploads/files/1597148314270-252d462c-9d88-4e96-b05d-a07690be4503-image.png) 
*Design 2:*
![7421ac67-8df1-4a00-ade7-edbbcc3c6165-image.png](https://forum.plutonium.pw/assets/uploads/files/1608033246340-8c10eea4-449f-4147-9e07-7ffb925649c2-image.png)

###### V1.0.3
**Bug Fixed in v1.0.3**:
1. The camera no longer moves when you choose the map
2. Animation now are cleaner

###### V1.0.4
**Bug Fixed in v1.0.4**:
1. Now work on endgame with and without killcam 
2. Work also on S&D, Domination or any round gamemodes
3. Text in the middle screen hide when vote end

###### V1.1.0
**Bug Fixed in v1.1.0**:
1. Now maps should load correctly everytime
2. Some optimization 

**Update in v1.1.0**:
1. Deisgn Fixed
2. Configurable Server Name via dvar in .cfg
3. Configurable Gametype when map rotate

###### V1.2.0
**Update in v1.2.0**:
1. Configurable time to vote via dvar in .cfg
2. Added timer
3. Some design fix


**Copyright:** *The script was created by DoktorSAS and no one else can say they created it. The script is free and accessible to everyone, it is not possible to sell the script.*

# Social
<a href="https://twitter.com/DoktorSAS"> <img src="https://i.imgur.com/rcPkXtU.png" width="50" high = "50"/> <a href="https://twitter.com/DoktorSAS"> <img src="https://i.imgur.com/xAANm7S.png" width="50" high = "50"/> </a><a href="https://twitter.com/DoktorSAS"> <img src="https://i.imgur.com/XlctxvH.png" width="50" high = "50"/> </a><a href="https://discord.gg/nCP2y4J"> <img src="https://i.imgur.com/AoMmUW4.png" width="50" high = "50"/> </a>


