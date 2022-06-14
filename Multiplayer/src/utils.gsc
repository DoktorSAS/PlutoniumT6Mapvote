SetDvarIfNotInizialized(dvar, value)
{
	if (!IsInizialized(dvar))
		setDvar(dvar, value);
}
IsInizialized(dvar)
{
	result = getDvar(dvar);
	return !isDefined(result) || result != "";
}

gametypeToName(gametype)
{
	switch (tolower(gametype))
	{
	case "dm":
		return "Free for all";

	case "war":
		return "Team Deathmatch";

	case "sd":
		return "Search & Destroy";

	case "conf":
		return "Kill Confirmed";

	case "ctf":
		return "Capture the Flag";

	case "dom":
		return "Domination";

	case "dem":
		return "Demolition";

	case "gun":
		return "Gun Game";

	case "hq":
		return "Headquaters";

	case "koth":
		return "Hardpoint";

	case "oic":
		return "One in the chamber";

	case "oneflag":
		return "One-Flag CTF";

	case "sas":
		return "Sticks & Stones";

	case "shrp":
		return "Sharpshooter";

	}
	return "invalid";
}

getMapsData(mapsIDs)
{
	mapsdata = [];

	/*foreach(id in mapsIDs)
	{
		mapsdata[id] = spawnStruct();
	}*/

	mapsdata["mp_la"] = spawnStruct();
	mapsdata["mp_la"].mapname = "Aftermath";
	mapsdata["mp_la"].mapid = "mp_la";
	mapsdata["mp_la"].image = "loadscreen_mp_la";

	mapsdata["mp_meltdown"] = spawnStruct();
	mapsdata["mp_meltdown"].mapname = "Meltdown";
	mapsdata["mp_meltdown"].mapid = "mp_meltdown";
	mapsdata["mp_meltdown"].image = "loadscreen_mp_meltdown";

	mapsdata["mp_overflow"] = spawnStruct();
	mapsdata["mp_overflow"].mapname = "Overflow";
	mapsdata["mp_overflow"].mapid = "mp_overflow";
	mapsdata["mp_overflow"].image = "loadscreen_mp_overflow";

	mapsdata["mp_nightclub"] = spawnStruct();
	mapsdata["mp_nightclub"].mapname = "Plaza";
	mapsdata["mp_nightclub"].mapid = "mp_nightclub";
	mapsdata["mp_nightclub"].image = "loadscreen_mp_nightclub";

	mapsdata["mp_dockside"] = spawnStruct();
	mapsdata["mp_dockside"].mapname = "Cargo";
	mapsdata["mp_dockside"].mapid = "mp_dockside";
	mapsdata["mp_dockside"].image = "loadscreen_mp_dockside";

	mapsdata["mp_carrier"] = spawnStruct();
	mapsdata["mp_carrier"].mapname = "Carrier";
	mapsdata["mp_carrier"].mapid = "mp_carrier";
	mapsdata["mp_carrier"].image = "loadscreen_mp_carrier";

	mapsdata["mp_drone"] = spawnStruct();
	mapsdata["mp_drone"].mapname = "Drone";
	mapsdata["mp_drone"].mapid = "mp_drone";
	mapsdata["mp_drone"].image = "loadscreen_mp_drone";

	mapsdata["mp_express"] = spawnStruct();
	mapsdata["mp_express"].mapname = "Express";
	mapsdata["mp_express"].mapid = "mp_express";
	mapsdata["mp_express"].image = "loadscreen_mp_express";

	mapsdata["mp_hijacked"] = spawnStruct();
	mapsdata["mp_hijacked"].mapname = "Hijacked";
	mapsdata["mp_hijacked"].mapid = "mp_hijacked";
	mapsdata["mp_hijacked"].image = "loadscreen_mp_hijacked";

	mapsdata["mp_raid"] = spawnStruct();
	mapsdata["mp_raid"].mapname = "Raid";
	mapsdata["mp_raid"].mapid = "mp_raid";
	mapsdata["mp_raid"].image = "loadscreen_mp_raid";

	mapsdata["mp_slums"] = spawnStruct();
	mapsdata["mp_slums"].mapname = "Slums";
	mapsdata["mp_slums"].mapid = "mp_slums";
	mapsdata["mp_slums"].image = "loadscreen_mp_Slums";

	mapsdata["mp_village"] = spawnStruct();
	mapsdata["mp_village"].mapname = "Standoff";
	mapsdata["mp_village"].mapid = "mp_village";
	mapsdata["mp_village"].image = "loadscreen_mp_village";

	mapsdata["mp_turbine"] = spawnStruct();
	mapsdata["mp_turbine"].mapname = "Turbine";
	mapsdata["mp_turbine"].mapid = "mp_turbine";
	mapsdata["mp_turbine"].image = "loadscreen_mp_Turbine";

	mapsdata["mp_socotra"] = spawnStruct();
	mapsdata["mp_socotra"].mapname = "Yemen";
	mapsdata["mp_socotra"].mapid = "mp_socotra";
	mapsdata["mp_socotra"].image = "loadscreen_mp_socotra";

	mapsdata["mp_nuketown_2020"] = spawnStruct();
	mapsdata["mp_nuketown_2020"].mapname = "Nuketown 2025";
	mapsdata["mp_nuketown_2020"].mapid = "mp_nuketown_2020";
	mapsdata["mp_nuketown_2020"].image = "loadscreen_mp_nuketown_2020";

	mapsdata["mp_downhill"] = spawnStruct();
	mapsdata["mp_downhill"].mapname = "Downhill";
	mapsdata["mp_downhill"].mapid = "mp_downhill";
	mapsdata["mp_downhill"].image = "loadscreen_mp_downhill";

	mapsdata["mp_mirage"] = spawnStruct();
	mapsdata["mp_mirage"].mapname = "Mirage";
	mapsdata["mp_mirage"].mapid = "mp_mirage";
	mapsdata["mp_mirage"].image = "loadscreen_mp_Mirage";

	mapsdata["mp_hydro"] = spawnStruct();
	mapsdata["mp_hydro"].mapname = "Hydro";
	mapsdata["mp_hydro"].mapid = "mp_hydro";
	mapsdata["mp_hydro"].image = "loadscreen_mp_Hydro";

	mapsdata["mp_skate"] = spawnStruct();
	mapsdata["mp_skate"].mapname = "Grind";
	mapsdata["mp_skate"].mapid = "mp_skate";
	mapsdata["mp_skate"].image = "loadscreen_mp_skate";

	mapsdata["mp_concert"] = spawnStruct();
	mapsdata["mp_concert"].mapname = "Encore";
	mapsdata["mp_concert"].mapid = "mp_concert";
	mapsdata["mp_concert"].image = "loadscreen_mp_concert";

	mapsdata["mp_magma"] = spawnStruct();
	mapsdata["mp_magma"].mapname = "Magma";
	mapsdata["mp_magma"].mapid = "mp_magma";
	mapsdata["mp_magma"].image = "loadscreen_mp_Magma";

	mapsdata["mp_vertigo"] = spawnStruct();
	mapsdata["mp_vertigo"].mapname = "Vertigo";
	mapsdata["mp_vertigo"].mapid = "mp_vertigo";
	mapsdata["mp_vertigo"].image = "loadscreen_mp_Vertigo";

	mapsdata["mp_studio"] = spawnStruct();
	mapsdata["mp_studio"].mapname = "Studio";
	mapsdata["mp_studio"].mapid = "mp_studio";
	mapsdata["mp_studio"].image = "loadscreen_mp_Studio";

	mapsdata["mp_uplink"] = spawnStruct();
	mapsdata["mp_uplink"].mapname = "Uplink";
	mapsdata["mp_uplink"].mapid = "mp_uplink";
	mapsdata["mp_uplink"].image = "loadscreen_mp_Uplink";

	mapsdata["mp_bridge"] = spawnStruct();
	mapsdata["mp_bridge"].mapname = "Detour";
	mapsdata["mp_bridge"].mapid = "mp_bridge";
	mapsdata["mp_bridge"].image = "loadscreen_mp_bridge";

	mapsdata["mp_castaway"] = spawnStruct();
	mapsdata["mp_castaway"].mapname = "Cove";
	mapsdata["mp_castaway"].mapid = "mp_castaway";
	mapsdata["mp_castaway"].image = "loadscreen_mp_castaway";

	mapsdata["mp_dig"] = spawnStruct();
	mapsdata["mp_paintball"].mapname = "Rush";
	mapsdata["mp_paintball"].mapid = "mp_paintball";
	mapsdata["mp_paintball"].image = "loadscreen_mp_paintball";

	mapsdata["mp_dig"] = spawnStruct();
	mapsdata["mp_dig"].mapname = "Dig";
	mapsdata["mp_dig"].mapid = "mp_dig";
	mapsdata["mp_dig"].image = "loadscreen_mp_Dig";

	mapsdata["mp_frostbite"] = spawnStruct();
	mapsdata["mp_frostbite"].mapname = "Frost";
	mapsdata["mp_frostbite"].mapid = "mp_frostbite";
	mapsdata["mp_frostbite"].image = "loadscreen_mp_frostbite";

	mapsdata["mp_pod"] = spawnStruct();
	mapsdata["mp_pod"].mapname = "Pod";
	mapsdata["mp_pod"].mapid = "mp_pod";
	mapsdata["mp_pod"].image = "loadscreen_mp_Pod";

	mapsdata["mp_takeoff"] = spawnStruct();
	mapsdata["mp_takeoff"].mapname = "Takeoff";
	mapsdata["mp_takeoff"].mapid = "mp_takeoff";
	mapsdata["mp_takeoff"].image = "loadscreen_mp_Takeoff";

	mapsdata["mp_dockside"] = spawnStruct();
	mapsdata["mp_dockside"].mapname = "Cargo";
	mapsdata["mp_dockside"].mapid = "mp_dockside";
	mapsdata["mp_dockside"].image = "loadscreen_mp_dockside";
	return mapsdata;
}
isValidColor(value)
{
	return value == "0" || value == "1" || value == "2" || value == "3" || value == "4" || value == "5" || value == "6" || value == "7";
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