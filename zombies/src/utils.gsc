SetDvarIfNotInizialized(dvar, value)
{
	if (!IsInizialized(dvar))
		setDvar(dvar, value);
}
IsInizialized(dvar)
{
	result = getDvar(dvar);
	return result != "";
}

insertMap(key, displayname3, displayname6, image, mapid)
{
	level.mapsdata[key] = spawnStruct();
	if(getDvarInt("mv_extramaps") == 1)
	{
		level.mapsdata[key].mapname = displayname6;
	}
	else
	{
		level.mapsdata[key].mapname = displayname3;
	}
	
	level.mapsdata[key].mapid = mapid;
	level.mapsdata[key].image = image;
}

buildmapsdata()
{
	level.mapsdata = [];
	insertMap("zm_tomb", &"Origins",  &"Origins - ", "loadscreen_zm_tomb_zclassic_tomb", "exec zm_classic_tomb.cfg map zm_tomb");
	insertMap("zm_buried", &"Buried",  &"Buried - ", "loadscreen_zm_buried_zclassic_processing", "exec zm_classic_processing.cfg map zm_buried");
	insertMap("zm_town", &"Town",  &"Town - ", "loadscreen_zm_transit_zstandard_transit", "exec zm_standard_town.cfg map zm_transit");
	insertMap("zm_busdepot", &"Bus Depot",  &"Bus Depot - ", "loadscreen_zm_transit_zstandard_farm", "exec zm_standard_transit.cfg map zm_transit");
	insertMap("zm_farm", &"Farm",  &"Farm - ", "loadscreen_zm_transit_zclassic_transit", "exec zm_standard_farm.cfg map zm_transit");
	insertMap("zm_transit", &"Transit",  &"Transit - ", "loadscreen_zm_transit_zclassic_transit", "exec zm_classic_transit.cfg map zm_transit");
	insertMap("zm_prison", &"Mob of the dead",  &"Mob of the dead - ", "loadscreen_zm_prison_zclassic_prison", "exec zm_classic_prison.cfg map zm_prison");
	insertMap("zm_highrise", &"Die rise",  &"Die rise - ", "loadscreen_zm_highrise_zclassic_rooftop", "exec zm_classic_rooftop.cfg map zm_highrise");
	insertMap("zm_nuked", &"Nuketown",  &"Nuketown - ", "loadscreen_zm_nuked_zstandard_nuked", "exec zm_standard_nuked.cfg map zm_nuked");

	insertMap("zm_tomb_grief", &"Origins",  &"Origins - ", "loadscreen_zm_tomb_zclassic_tomb", "exec zm_grief_tomb.cfg map zm_tomb");
	insertMap("zm_buried_grief", &"Buried",  &"Buried - ", "loadscreen_zm_buried_zclassic_processing", "exec zm_grief_processing.cfg map zm_buried");
	insertMap("zm_town_grief", &"Town",  &"Town - ", "loadscreen_zm_transit_zstandard_transit", "exec zm_grief_town.cfg map zm_transit");
	insertMap("zm_busdepot_grief", &"Bus Depot",  &"Bus Depot - ", "loadscreen_zm_transit_zstandard_transit", "exec zm_grief_transit.cfg map zm_transit");
	insertMap("zm_farm_grief", &"Farm",  &"Farm - ", "loadscreen_zm_transit_zstandard_farm", "exec zm_grief_farm.cfg map zm_transit");
	insertMap("zm_transit_grief", &"Transit",  &"Transit - ", "loadscreen_zm_transit_zclassic_transit", "exec zm_grief_transit.cfg map zm_transit");
	insertMap("zm_prison_grief", &"Mob of the dead",  &"Mob of the dead - ", "loadscreen_zm_prison_zclassic_prison", "exec zm_grief_prison.cfg map zm_prison");
	insertMap("zm_cellblock_grief", &"Cellblock",  &"Cellblock - ", "loadscreen_zm_prison_zgrief_cellblock", "exec zm_grief_cellblock.cfg map zm_prison");
	insertMap("zm_highrise_grief", &"Die rise",  &"Die rise - ", "loadscreen_zm_highrise_zclassic_rooftop", "exec zm_grief_rooftop.cfg map zm_highrise");
	insertMap("zm_nuked_grief", &"Nuketown",  &"Nuketown - ", "loadscreen_zm_nuked_zstandard_nuked", "exec zm_cleansed_street.cfg map zm_buried");
	insertMap("zm_diner_borough", &"Borough Diner",  &"Borough Diner - ", "loadscreen_zm_transit_dr_zcleansed_diner", "exec zm_cleansed_street.cfg map zm_buried");
	
	/*
		To add a new map to the mapvote you need to edit this function called buildmapsdata.
		How to do it? 
		1. Copy insertMap("", &"",  &" - ", "", ""); and paste it under level.mapsdata = [];
		2. Compile the empty spaces, the arguments in ordare are:
			1) Map custom id: Is an id that you can use in your mv_maps dvar to identify this specific map
			2) Map UI name for 3 maps versio: It display this one if the dvar mv_extramaps is set to 0
			3) Map UI name for 6 maps versio: It display this one if the dvar mv_extramaps is set to 1
			4) Map preview: Is the image to display on the mapvote
			5) Map config: This is the code that get executed once the map rotate to the winning map on the mapvote
		Let's make an exemple, i want to add a map called "Home depot" so i'll add this code:
			insertMap("zm_homedepot", &"Home depot",  &"Home depot - ", "loadscreen_zm_transit_dr_zcleansed_diner", "exec homedepot.cfg map zm_transit");
			
	*/

	return level.mapsdata;
}
isValidColor(value)
{
	return value == "0" || value == "1" || value == "2" || value == "3" || value == "4" || value == "5" || value == "6" || value == "7";
}
// CMD not working on zombies
addCmd(cmd, function)
{
	self notifyOnPlayerCommand(cmd + "_cmd", cmd);
	self thread cmdManager(cmd + "_cmd", function);
}
cmdManager(cmd, function)
{
	self endon("disconnect");
	self endon("round_ended");
	level endon("game_ended");
	level endon("round_end_finished");
	for (;;)
	{
		self waittill(cmd);
		self [[function]] ();
	}
}
GetColor(color)
{
	switch (tolower(color))
	{
	case "red":
		return (0.960, 0.180, 0.180);

	case "black":
		return (0, 0, 0);

	case "grey":
		return (0.035, 0.059, 0.063);

	case "purple":
		return (1, 0.282, 1);

	case "pink":
		return (1, 0.623, 0.811);

	case "green":
		return (0, 0.69, 0.15);

	case "blue":
		return (0, 0, 1);

	case "lightblue":
	case "light blue":
		return (0.152, 0329, 0.929);

	case "lightgreen":
	case "light green":
		return (0.09, 1, 0.09);

	case "orange":
		return (1, 0662, 0.035);

	case "yellow":
		return (0.968, 0.992, 0.043);

	case "brown":
		return (0.501, 0.250, 0);

	case "cyan":
		return (0, 1, 1);

	case "white":
		return (1, 1, 1);

	}
}
// Drawing
CreateString(input, font, fontScale, align, relative, x, y, color, alpha, glowColor, glowAlpha, sort, isValue)
{
	if (self != level)
	{
		hud = self createFontString(font, fontScale);
	}
	else
	{
		hud = level createServerFontString(font, fontScale);
	}

	if (!isDefined(isValue))
	{
		hud setText(input);
	}
	else
	{
		hud setValue(int(input));
	}
		
	hud setPoint(align, relative, x, y);
	hud.color = color;
	hud.alpha = alpha;
	hud.glowColor = glowColor;
	hud.glowAlpha = glowAlpha;
	hud.sort = sort;
	hud.alpha = alpha;
	hud.archived = 0;
	hud.hideWhenInMenu = 0;
	return hud;
}
CreateRectangle(align, relative, x, y, width, height, color, shader, sort, alpha)
{
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
	boxElem.hidden = 0;
	boxElem setPoint(align, relative, x, y);
	boxElem.hideWhenInMenu = 0;
	boxElem.archived = 0;
	return boxElem;
}
CreateNewsBar(align, relative, x, y, width, height, color, shader, sort, alpha)
{ // Not mine
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
	barElemBG.hidden = 0;
	barElemBG setPoint(align, relative, x, y);
	barElemBG.hideWhenInMenu = 0;
	barElemBG.archived = 0;
	return barElemBG;
}
DrawText(text, font, fontscale, x, y, color, alpha, glowcolor, glowalpha, sort)
{
	hud = self createfontstring(font, fontscale);
	hud setText(text);
	hud.x = x;
	hud.y = y;
	hud.color = color;
	hud.alpha = alpha;
	hud.glowcolor = glowcolor;
	hud.glowalpha = glowalpha;
	hud.sort = sort;
	hud.alpha = alpha;
	hud.hideWhenInMenu = 0;
	hud.archived = 0;
	return hud;
}
DrawShader(shader, x, y, width, height, color, alpha, sort, align, relative, isLevel)
{
	if (isDefined(isLevel))
		hud = newhudelem();
	else
		hud = newclienthudelem(self);
	hud.elemtype = "icon";
	hud.color = color;
	hud.alpha = alpha;
	hud.sort = sort;
	hud.children = [];
	if (isDefined(align))
		hud.align = align;
	if (isDefined(relative))
		hud.relative = relative;
	hud setparent(level.uiparent);
	hud.x = x;
	hud.y = y;
	hud setshader(shader, width, height);
	hud.hideWhenInMenu = 0;
	hud.archived = 0;
	return hud;
}
// Animations
affectElement(type, time, value)
{
	if (type == "x" || type == "y")
		self moveOverTime(time);
	else
		self fadeOverTime(time);
	if (type == "x")
		self.x = value;
	if (type == "y")
		self.y = value;
	if (type == "alpha")
		self.alpha = value;
	if (type == "color")
		self.color = value;
}
// Just for testing
empty() {}