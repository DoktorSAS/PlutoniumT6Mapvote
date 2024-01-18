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

gametypeToName(gametype)
{
	switch (tolower(gametype))
	{
	case "dm":
		return "Free for all";

	case "tdm":
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

buildmapsdata()
{
	level.mapsdata = [];

	/*foreach(id in mapsIDs)
	{
		mapsdata[id] = spawnStruct();
	}*/

	level.mapsdata["mp_la"] = spawnStruct();
	level.mapsdata["mp_la"].mapname = "Aftermath";
	level.mapsdata["mp_la"].mapid = "mp_la";
	level.mapsdata["mp_la"].image = "loadscreen_mp_la";

	level.mapsdata["mp_meltdown"] = spawnStruct();
	level.mapsdata["mp_meltdown"].mapname = "Meltdown";
	level.mapsdata["mp_meltdown"].mapid = "mp_meltdown";
	level.mapsdata["mp_meltdown"].image = "loadscreen_mp_meltdown";

	level.mapsdata["mp_overflow"] = spawnStruct();
	level.mapsdata["mp_overflow"].mapname = "Overflow";
	level.mapsdata["mp_overflow"].mapid = "mp_overflow";
	level.mapsdata["mp_overflow"].image = "loadscreen_mp_overflow";

	level.mapsdata["mp_nightclub"] = spawnStruct();
	level.mapsdata["mp_nightclub"].mapname = "Plaza";
	level.mapsdata["mp_nightclub"].mapid = "mp_nightclub";
	level.mapsdata["mp_nightclub"].image = "loadscreen_mp_nightclub";

	level.mapsdata["mp_dockside"] = spawnStruct();
	level.mapsdata["mp_dockside"].mapname = "Cargo";
	level.mapsdata["mp_dockside"].mapid = "mp_dockside";
	level.mapsdata["mp_dockside"].image = "loadscreen_mp_dockside";

	level.mapsdata["mp_carrier"] = spawnStruct();
	level.mapsdata["mp_carrier"].mapname = "Carrier";
	level.mapsdata["mp_carrier"].mapid = "mp_carrier";
	level.mapsdata["mp_carrier"].image = "loadscreen_mp_carrier";

	level.mapsdata["mp_drone"] = spawnStruct();
	level.mapsdata["mp_drone"].mapname = "Drone";
	level.mapsdata["mp_drone"].mapid = "mp_drone";
	level.mapsdata["mp_drone"].image = "loadscreen_mp_drone";

	level.mapsdata["mp_express"] = spawnStruct();
	level.mapsdata["mp_express"].mapname = "Express";
	level.mapsdata["mp_express"].mapid = "mp_express";
	level.mapsdata["mp_express"].image = "loadscreen_mp_express";

	level.mapsdata["mp_hijacked"] = spawnStruct();
	level.mapsdata["mp_hijacked"].mapname = "Hijacked";
	level.mapsdata["mp_hijacked"].mapid = "mp_hijacked";
	level.mapsdata["mp_hijacked"].image = "loadscreen_mp_hijacked";

	level.mapsdata["mp_raid"] = spawnStruct();
	level.mapsdata["mp_raid"].mapname = "Raid";
	level.mapsdata["mp_raid"].mapid = "mp_raid";
	level.mapsdata["mp_raid"].image = "loadscreen_mp_raid";

	level.mapsdata["mp_slums"] = spawnStruct();
	level.mapsdata["mp_slums"].mapname = "Slums";
	level.mapsdata["mp_slums"].mapid = "mp_slums";
	level.mapsdata["mp_slums"].image = "loadscreen_mp_Slums";

	level.mapsdata["mp_village"] = spawnStruct();
	level.mapsdata["mp_village"].mapname = "Standoff";
	level.mapsdata["mp_village"].mapid = "mp_village";
	level.mapsdata["mp_village"].image = "loadscreen_mp_village";

	level.mapsdata["mp_turbine"] = spawnStruct();
	level.mapsdata["mp_turbine"].mapname = "Turbine";
	level.mapsdata["mp_turbine"].mapid = "mp_turbine";
	level.mapsdata["mp_turbine"].image = "loadscreen_mp_Turbine";

	level.mapsdata["mp_socotra"] = spawnStruct();
	level.mapsdata["mp_socotra"].mapname = "Yemen";
	level.mapsdata["mp_socotra"].mapid = "mp_socotra";
	level.mapsdata["mp_socotra"].image = "loadscreen_mp_socotra";

	level.mapsdata["mp_nuketown_2020"] = spawnStruct();
	level.mapsdata["mp_nuketown_2020"].mapname = "Nuketown 2025";
	level.mapsdata["mp_nuketown_2020"].mapid = "mp_nuketown_2020";
	level.mapsdata["mp_nuketown_2020"].image = "loadscreen_mp_nuketown_2020";

	level.mapsdata["mp_downhill"] = spawnStruct();
	level.mapsdata["mp_downhill"].mapname = "Downhill";
	level.mapsdata["mp_downhill"].mapid = "mp_downhill";
	level.mapsdata["mp_downhill"].image = "loadscreen_mp_downhill";

	level.mapsdata["mp_mirage"] = spawnStruct();
	level.mapsdata["mp_mirage"].mapname = "Mirage";
	level.mapsdata["mp_mirage"].mapid = "mp_mirage";
	level.mapsdata["mp_mirage"].image = "loadscreen_mp_Mirage";

	level.mapsdata["mp_hydro"] = spawnStruct();
	level.mapsdata["mp_hydro"].mapname = "Hydro";
	level.mapsdata["mp_hydro"].mapid = "mp_hydro";
	level.mapsdata["mp_hydro"].image = "loadscreen_mp_Hydro";

	level.mapsdata["mp_skate"] = spawnStruct();
	level.mapsdata["mp_skate"].mapname = "Grind";
	level.mapsdata["mp_skate"].mapid = "mp_skate";
	level.mapsdata["mp_skate"].image = "loadscreen_mp_skate";

	level.mapsdata["mp_concert"] = spawnStruct();
	level.mapsdata["mp_concert"].mapname = "Encore";
	level.mapsdata["mp_concert"].mapid = "mp_concert";
	level.mapsdata["mp_concert"].image = "loadscreen_mp_concert";

	level.mapsdata["mp_magma"] = spawnStruct();
	level.mapsdata["mp_magma"].mapname = "Magma";
	level.mapsdata["mp_magma"].mapid = "mp_magma";
	level.mapsdata["mp_magma"].image = "loadscreen_mp_Magma";

	level.mapsdata["mp_vertigo"] = spawnStruct();
	level.mapsdata["mp_vertigo"].mapname = "Vertigo";
	level.mapsdata["mp_vertigo"].mapid = "mp_vertigo";
	level.mapsdata["mp_vertigo"].image = "loadscreen_mp_Vertigo";

	level.mapsdata["mp_studio"] = spawnStruct();
	level.mapsdata["mp_studio"].mapname = "Studio";
	level.mapsdata["mp_studio"].mapid = "mp_studio";
	level.mapsdata["mp_studio"].image = "loadscreen_mp_Studio";

	level.mapsdata["mp_uplink"] = spawnStruct();
	level.mapsdata["mp_uplink"].mapname = "Uplink";
	level.mapsdata["mp_uplink"].mapid = "mp_uplink";
	level.mapsdata["mp_uplink"].image = "loadscreen_mp_Uplink";

	level.mapsdata["mp_bridge"] = spawnStruct();
	level.mapsdata["mp_bridge"].mapname = "Detour";
	level.mapsdata["mp_bridge"].mapid = "mp_bridge";
	level.mapsdata["mp_bridge"].image = "loadscreen_mp_bridge";

	level.mapsdata["mp_castaway"] = spawnStruct();
	level.mapsdata["mp_castaway"].mapname = "Cove";
	level.mapsdata["mp_castaway"].mapid = "mp_castaway";
	level.mapsdata["mp_castaway"].image = "loadscreen_mp_castaway";

	level.mapsdata["mp_dig"] = spawnStruct();
	level.mapsdata["mp_paintball"].mapname = "Rush";
	level.mapsdata["mp_paintball"].mapid = "mp_paintball";
	level.mapsdata["mp_paintball"].image = "loadscreen_mp_paintball";

	level.mapsdata["mp_dig"] = spawnStruct();
	level.mapsdata["mp_dig"].mapname = "Dig";
	level.mapsdata["mp_dig"].mapid = "mp_dig";
	level.mapsdata["mp_dig"].image = "loadscreen_mp_Dig";

	level.mapsdata["mp_frostbite"] = spawnStruct();
	level.mapsdata["mp_frostbite"].mapname = "Frost";
	level.mapsdata["mp_frostbite"].mapid = "mp_frostbite";
	level.mapsdata["mp_frostbite"].image = "loadscreen_mp_frostbite";

	level.mapsdata["mp_pod"] = spawnStruct();
	level.mapsdata["mp_pod"].mapname = "Pod";
	level.mapsdata["mp_pod"].mapid = "mp_pod";
	level.mapsdata["mp_pod"].image = "loadscreen_mp_Pod";

	level.mapsdata["mp_takeoff"] = spawnStruct();
	level.mapsdata["mp_takeoff"].mapname = "Takeoff";
	level.mapsdata["mp_takeoff"].mapid = "mp_takeoff";
	level.mapsdata["mp_takeoff"].image = "loadscreen_mp_Takeoff";

	level.mapsdata["mp_dockside"] = spawnStruct();
	level.mapsdata["mp_dockside"].mapname = "Cargo";
	level.mapsdata["mp_dockside"].mapid = "mp_dockside";
	level.mapsdata["mp_dockside"].image = "loadscreen_mp_dockside";
	return level.mapsdata;
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
	boxElem.elemType = "icon";
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