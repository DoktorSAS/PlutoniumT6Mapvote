SetDvarIfNotInizialized(dvar, value)
{
	if (!IsInizialized(dvar))
		setDvar(dvar, value);
}
IsInizialized(dvar)
{
	result = getDvar(dvar);
	return result != undefined || result != "";
}
getMapsData(mapsIDs)
{
	mapsdata = [];
	mapsdata["zm_tomb"] = spawnStruct();
	mapsdata["zm_tomb"].mapname = "Origins";
	mapsdata["zm_tomb"].mapid = "exec zm_classic_tomb.cfg map zm_tomb";
	mapsdata["zm_tomb"].image = "loadscreen_zm_tomb_zclassic_tomb";

	mapsdata["zm_buried"] = spawnStruct();
	mapsdata["zm_buried"].mapname = "Buried";
	mapsdata["zm_buried"].mapid = "exec zm_classic_processing.cfg map zm_buried";
	mapsdata["zm_buried"].image = "loadscreen_zm_buried_zclassic_processing";

	mapsdata["zm_town"] = spawnStruct();
	mapsdata["zm_town"].mapname = "Town";
	mapsdata["zm_town"].mapid = "exec zm_standard_town.cfg map zm_transit";
	mapsdata["zm_town"].image = "loadscreen_zm_transit_zstandard_transit";

	mapsdata["zm_busdepot"] = spawnStruct();
	mapsdata["zm_busdepot"].mapname = "Bus Depot";
	mapsdata["zm_busdepot"].mapid = "exec zm_standard_transit.cfg map zm_transit";
	mapsdata["zm_busdepot"].image = "loadscreen_zm_transit_zstandard_transit";

	mapsdata["zm_farm"] = spawnStruct();
	mapsdata["zm_farm"].mapname = "Farm";
	mapsdata["zm_farm"].mapid = "exec zm_standard_farm.cfg map zm_transit";
	mapsdata["zm_farm"].image = "loadscreen_zm_transit_zstandard_farm";

	mapsdata["zm_transit"] = spawnStruct();
	mapsdata["zm_transit"].mapname = "Transit";
	mapsdata["zm_transit"].mapid = "exec zm_classic_transit.cfg map zm_transit";
	mapsdata["zm_transit"].image = "loadscreen_zm_transit_zclassic_transit";

	mapsdata["zm_prison"] = spawnStruct();
	mapsdata["zm_prison"].mapname = "Mob of the dead";
	mapsdata["zm_prison"].mapid = "exec zm_classic_prison.cfg map zm_prison";
	mapsdata["zm_prison"].image = "loadscreen_zm_prison_zclassic_prison";

	mapsdata["zm_highrise"] = spawnStruct();
	mapsdata["zm_highrise"].mapname = "Die rise";
	mapsdata["zm_highrise"].mapid = "exec zm_classic_rooftop.cfg map zm_highrise";
	mapsdata["zm_highrise"].image = "loadscreen_zm_highrise_zclassic_rooftop";

	mapsdata["zm_nuked"] = spawnStruct();
	mapsdata["zm_nuked"].mapname = "Nuketown";
	mapsdata["zm_nuked"].mapid = "exec zm_standard_nuked.cfg map zm_nuked";
	mapsdata["zm_nuked"].image = "loadscreen_zm_nuked_zstandard_nuked";

	mapsdata["zm_tomb_grief"] = spawnStruct();
	mapsdata["zm_tomb_grief"].mapname = "Origins";
	mapsdata["zm_tomb_grief"].mapid = "exec zm_grief_tomb.cfg map zm_tomb";
	mapsdata["zm_tomb_grief"].image = "loadscreen_zm_tomb_zclassic_tomb";

	mapsdata["zm_buried_grief"] = spawnStruct();
	mapsdata["zm_buried_grief"].mapname = "Buried";
	mapsdata["zm_buried_grief"].mapid = "exec zm_grief_processing.cfg map zm_buried";
	mapsdata["zm_buried_grief"].image = "loadscreen_zm_buried_zclassic_processing";

	mapsdata["zm_town_grief"] = spawnStruct();
	mapsdata["zm_town_grief"].mapname = "Town";
	mapsdata["zm_town_grief"].mapid = "exec zm_grief_town.cfg map zm_transit";
	mapsdata["zm_town_grief"].image = "loadscreen_zm_transit_zstandard_transit";

	mapsdata["zm_busdepot_grief"] = spawnStruct();
	mapsdata["zm_busdepot_grief"].mapname = "Bus Depot";
	mapsdata["zm_busdepot_grief"].mapid = "exec zm_grief_transit.cfg map zm_transit";
	mapsdata["zm_busdepot_grief"].image = "loadscreen_zm_transit_zstandard_transit";

	mapsdata["zm_farm_grief"] = spawnStruct();
	mapsdata["zm_farm_grief"].mapname = "Farm";
	mapsdata["zm_farm_grief"].mapid = "exec zm_grief_farm.cfg map zm_transit";
	mapsdata["zm_farm_grief"].image = "loadscreen_zm_transit_zstandard_farm";

	mapsdata["zm_transit_grief"] = spawnStruct();
	mapsdata["zm_transit_grief"].mapname = "Transit";
	mapsdata["zm_transit_grief"].mapid = "exec zm_grief_transit.cfg map zm_transit";
	mapsdata["zm_transit_grief"].image = "loadscreen_zm_transit_zclassic_transit";

	mapsdata["zm_prison_grief"] = spawnStruct();
	mapsdata["zm_prison_grief"].mapname = "Mob of the dead";
	mapsdata["zm_prison_grief"].mapid = "exec zm_grief_prison.cfg map zm_prison";
	mapsdata["zm_prison_grief"].image = "loadscreen_zm_prison_zclassic_prison";

	mapsdata["zm_cellblock_grief"] = spawnStruct();
	mapsdata["zm_cellblock_grief"].mapname = "Cellblock";
	mapsdata["zm_cellblock_grief"].mapid = "exec zm_grief_cellblock.cfg map zm_prison";
	mapsdata["zm_cellblock_grief"].image = "loadscreen_zm_prison_zgrief_cellblock";

	mapsdata["zm_highrise_grief"] = spawnStruct();
	mapsdata["zm_highrise_grief"].mapname = "Die rise";
	mapsdata["zm_highrise_grief"].mapid = "exec zm_grief_rooftop.cfg map zm_highrise";
	mapsdata["zm_highrise_grief"].image = "loadscreen_zm_highrise_zclassic_rooftop";

	mapsdata["zm_nuked_grief"] = spawnStruct();
	mapsdata["zm_nuked_grief"].mapname = "Nuketown";
	mapsdata["zm_nuked_grief"].mapid = "exec zm_grief_nuked.cfg map zm_nuked";
	mapsdata["zm_nuked_grief"].image = "loadscreen_zm_nuked_zstandard_nuked";

	mapsdata["zm_diner_borough"] = spawnStruct();
	mapsdata["zm_diner_borough"].mapname = "Borough Diner";
	mapsdata["zm_diner_borough"].mapid = "exec zm_cleansed_street.cfg map zm_buried";
	mapsdata["zm_diner_borough"].image = "loadscreen_zm_transit_dr_zcleansed_diner";

	return mapsdata;
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
// Drawing
CreateString(input, font, fontScale, align, relative, x, y, color, alpha, glowColor, glowAlpha, sort, isLevel, isValue)
{
	if (!isDefined(isLevel))
		hud = self createFontString(font, fontScale);
	else
		hud = level createServerFontString(font, fontScale);
	if (!isDefined(isValue))
		hud setText(input);
	else
		hud setValue(input);
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