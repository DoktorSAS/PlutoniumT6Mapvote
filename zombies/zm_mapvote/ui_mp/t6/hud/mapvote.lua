CoD.MapVote = {
    hovercolor =  {
        [1] = "1",
        [2] = "1",
        [3] = "1"
    },
    focusIndex = 1,
    votedIndex = nil,
    maxOptions = 3
}

Engine.SetDvar("lui_mv_time", 20000)
Engine.SetDvar("lui_mv_maps", "Unknonw Map;Unknonw Map;Unknonw Map")
Engine.SetDvar("lui_mv_gametypes", ";;")
Engine.SetDvar("lui_mv_loadscreens", "white;white;white")
Engine.SetDvar("lui_mv_hovercolor", "1;1;1")
Engine.SetDvar("mv_allowchangevote", 1)

function strsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

LUI.createMenu.MapVote = function (LocalClientIndex) -- LUI.createMenu.TheaterLobby = function (LocalClientIndex, f1_arg1)
    local LuiMapvote = CoD.InGameMenu.NewFromState("MapVote", {
		leftAnchor = true,
		rightAnchor = true,
		left = 0,
		right = 0,
		topAnchor = true,
		bottomAnchor = true,
		top = 0,
		bottom = 0,
	})
    LuiMapvote:setOwner(LocalClientIndex)

    local lui_mv_hovercolor = strsplit( UIExpression.DvarString(nil, "lui_mv_hovercolor") , ";")
    
    CoD.MapVote.hovercolor = {
        [1] = lui_mv_hovercolor[1],
        [2] = lui_mv_hovercolor[2],
        [3] = lui_mv_hovercolor[3]
    }

    local allowchangevote = UIExpression.DvarInt(nil, "mv_allowchangevote")

    local maps = strsplit( UIExpression.DvarString(nil, "lui_mv_maps") , ";")
    local gametypes = strsplit( UIExpression.DvarString(nil, "lui_mv_gametypes") , ";" )
    local loadscreens = strsplit( UIExpression.DvarString(nil, "lui_mv_loadscreens") , ";" )

    if #maps > 6 then
        --return
    end

   

    --[[
        MAP VOTING IN PROGRESS                0:00
        --------------------------------------------

        MAP NAME        MAP NAME        MAP NAME
        MAP GAMETYPE    MAP GAMETYPE    MAP GAMETYPE
        VOTES           VOTES           VOTES

        --------------------------------------------
    ]]--

    LuiMapvote.title = LUI.UIText.new()
    LuiMapvote.title:setLeftRight(false, false, -457, 175)
	LuiMapvote.title:setTopBottom(true, false, 122, 166)
    LuiMapvote.title:setText(UIExpression.ToUpper(nil, Engine.Localize("MPUI_MAPVOTINGPROGRESS")))
    LuiMapvote.title:setFont(CoD.fonts.Morris)
    LuiMapvote.title:setAlignment(LUI.Alignment.Left)

    LuiMapvote.subtitle = LUI.UIText.new()
    LuiMapvote.subtitle:setLeftRight(false, false, -457, 175)
	LuiMapvote.subtitle:setTopBottom(true, false, 166, 180)
    LuiMapvote.subtitle:setText("Developed by @DoktorSAS")
    LuiMapvote.subtitle:setFont(CoD.fonts.Morris)
    LuiMapvote.subtitle:setAlpha(0.8)
    LuiMapvote.subtitle:setAlignment(LUI.Alignment.Left)

    LuiMapvote.timer = LUI.UIText.new()
    LuiMapvote.timer:setLeftRight(false, false, 175, 457)
	LuiMapvote.timer:setTopBottom(true, false, 122, 166)
	LuiMapvote.timer:setFont(CoD.fonts.Morris)
	LuiMapvote.timer:setAlignment(LUI.Alignment.Right)
	CoD.CountdownTimer.Setup(LuiMapvote.timer, 0, true)
	LuiMapvote.timer:setTimeLeft(tonumber(UIExpression.DvarInt(nil, "lui_mv_time")))

    LuiMapvote:addElement(LuiMapvote.title)
    LuiMapvote:addElement(LuiMapvote.subtitle)
    LuiMapvote:addElement(LuiMapvote.timer)

    if #maps == 3 then
        LuiMapvote.buttons =  {
            [1] = CreateMapvoteOption(LuiMapvote, "mapvoteoption1", 1,  432, 200, maps[1], gametypes[1], loadscreens[1], -457);
            [2] = CreateMapvoteOption(LuiMapvote, "mapvoteoption2", 2,  432, 200, maps[2], gametypes[2], loadscreens[2], -141);
            [3] = CreateMapvoteOption(LuiMapvote, "mapvoteoption3", 3,  432, 200, maps[3], gametypes[3], loadscreens[3], 175);
        }
        LuiMapvote:addElement(LuiMapvote.buttons[1])
        LuiMapvote:addElement(LuiMapvote.buttons[2])
        LuiMapvote:addElement(LuiMapvote.buttons[3])
    else 
        CoD.MapVote.maxOptions = 6
        LuiMapvote.buttons =  {
            [1] = CreateMapvoteOption(LuiMapvote, "mapvoteoption1", 1, 200, 200, maps[1], gametypes[1], loadscreens[1], -457);
            [2] = CreateMapvoteOption(LuiMapvote, "mapvoteoption2", 2, 200, 200, maps[2], gametypes[2], loadscreens[2], -141);
            [3] = CreateMapvoteOption(LuiMapvote, "mapvoteoption3", 3, 200, 200, maps[3], gametypes[3], loadscreens[3], 175);
            [4] = CreateMapvoteOption(LuiMapvote, "mapvoteoption4", 4, 200, 432, maps[4], gametypes[4], loadscreens[4], -457);
            [5] = CreateMapvoteOption(LuiMapvote, "mapvoteoption5", 5, 200, 432, maps[5], gametypes[5], loadscreens[5], -141);
            [6] = CreateMapvoteOption(LuiMapvote, "mapvoteoption6", 6, 200, 432, maps[6], gametypes[6], loadscreens[6], 175);
        }
        LuiMapvote:addElement(LuiMapvote.buttons[1])
        LuiMapvote:addElement(LuiMapvote.buttons[2])
        LuiMapvote:addElement(LuiMapvote.buttons[3])
        LuiMapvote:addElement(LuiMapvote.buttons[4])
        LuiMapvote:addElement(LuiMapvote.buttons[5])
        LuiMapvote:addElement(LuiMapvote.buttons[6])
    end
    
    LuiMapvote.buttons[1]:processEvent({name = "button_over"}) -- force focus the first button
    LuiMapvote:registerEventHandler("gamepad_button", GamepadHandle)
    LuiMapvote:registerEventHandler("update_votes", UpdateVotes)
    LuiMapvote:registerEventHandler("mapvote_close", MapvoteClose)
    return LuiMapvote
end

function MapvoteClose(menu, _)
    CoD.Menu.animateOutAndGoBack(menu)
end

function UpdateVotes(menu, _)
    local index = _.data[1]
    local votes = _.data[2]

    menu.buttons[index].votes:setText(votes)
end

function CreateMapvoteOption(menu, event, index, hight, start_x, displayMapname, displayGametype, loadscreen, unitFromXstartPoint)
    local button = LUI.UIButton.new(menu, event)
    button.left = unitFromXstartPoint

	button:setLeftRight(false, false, unitFromXstartPoint, unitFromXstartPoint + 292) -- 282 is the width from point y to point y + width
    local lower_y = start_x + hight;
    button:setTopBottom(true, false, start_x, lower_y) -- handle the width of the whole component, all elements included. 200 is the x starting point and 4 is the x ending point. The differnece rapresent the max height of the component

    button.imageStencil = LUI.UIElement.new()
    button.imageStencil:setLeftRight(true, true, 0, 0)
    button.imageStencil:setTopBottom(true, true, 0, 0)
    button.imageStencil:setUseStencil(true)
    button:addElement(button.imageStencil)

    button.image = LUI.UIImage.new()
    
    if CoD.MapVote.maxOptions == 3 then
        button.image:setLeftRight(true, false, -256, 512)
	    button.image:setTopBottom(true, false, 0, 432)
    else
        button.image:setLeftRight(true, false, 0, 292)
    button.image:setTopBottom(true, false, 0, hight)
    end
    

    button.image:setImage(RegisterMaterial(loadscreen))
    button.imageStencil:addElement(button.image)

    button.displayMapnameBackground = LUI.UIImage.new()
    button.displayMapnameBackground:setLeftRight(true, true, 0, 0)
	button.displayMapnameBackground:setTopBottom(false, true, -66, 0)
    button.displayMapnameBackground:setRGB(0, 0, 0)
    button.displayMapnameBackground:setAlpha(0.8)
    button:addElement(button.displayMapnameBackground)

    local MPUI_RANDOM_CAPS = Engine.Localize( "MPUI_RANDOM_CAPS" ) 
	local MENU_MODE_CLASSIFIED_CAPS = Engine.Localize( "MENU_MODE_CLASSIFIED_CAPS")
    local MENU_MAP_CLASSIFIED_CAPS = Engine.Localize( "MENU_MAP_CLASSIFIED_CAPS" )

    if displayGametype ~= nill or displayGametype ~= "" then

        button.votesBackgroundOutline = LUI.UIImage.new()
        button.votesBackgroundOutline:setLeftRight(true, true, 9, -239)
        button.votesBackgroundOutline:setTopBottom(false, true, -89, -67)
        button.votesBackgroundOutline:setRGB(1, 1, 1, 0)
        button.votesBackgroundOutline:setAlpha(1)
        button:addElement(button.votesBackgroundOutline)
        button.votesBackground = LUI.UIImage.new()
        button.votesBackground:setLeftRight(true, true, 10, -240)
        button.votesBackground:setTopBottom(false, true, -88, -68)
        button.votesBackground:setRGB(0, 0, 0, 0)
        button.votesBackground:setAlpha(1)
        button:addElement(button.votesBackground)
        button.votes = LUI.UIText.new()
        button.votes:setLeftRight(true, true, 10, -240)
        button.votes:setTopBottom(false, true, -88, -68)
        button.votes:setFont(CoD.fonts.Morris)
        button.votes:setText("0")
        button:addElement(button.votes)
        
        button.displayMapname = LUI.UIText.new()
        button.displayMapname:setLeftRight(true, true, 0, 0)
        button.displayMapname:setTopBottom(false, true, -66, -22)
        button.displayMapname:setFont(CoD.fonts.Morris)
        button.displayMapname:setText(displayMapname)
        button:addElement(button.displayMapname)
    
        button.gametype = LUI.UIText.new()
        button.gametype:setLeftRight(true, true, 0, 0)
        button.gametype:setTopBottom(false, true, -26, -2)
        button.gametype:setFont(CoD.fonts.Morris)
        button.gametype:setText(displayGametype)
        button:addElement(button.gametype)

        if displayGametype == "Random" then
            button.displayMapname:setText(MENU_MAP_CLASSIFIED_CAPS)
            button.gametype:setText(MENU_MODE_CLASSIFIED_CAPS)
        end
    else
        button.displayMapname = LUI.UIText.new()
        button.displayMapname:setLeftRight(true, true, 0, 0)
        button.displayMapname:setTopBottom(false, true, -46, -2)
        button.displayMapname:setFont(CoD.fonts.Morris)
        button.displayMapname:setText(displayMapname)
        button:addElement(button.displayMapname)  
        if displayGametype == "Random" then
            button.displayMapname:setText(MENU_MAP_CLASSIFIED_CAPS)
        end 
    end 

	button.border = CoD.Border.new(1, CoD.MapVote.hovercolor[1], CoD.MapVote.hovercolor[2], CoD.MapVote.hovercolor[3], 0)
	button:addElement(button.border)

    button.highlight = CoD.Border.new(1, CoD.MapVote.hovercolor[1], CoD.MapVote.hovercolor[2], CoD.MapVote.hovercolor[3], 0)
	button:addElement(button.highlight)

    button.blackout = LUI.UIImage.new()
    button.blackout:setLeftRight(true, true, 0, 0)
    button.blackout:setTopBottom(true, true, 0, 0)
    button.blackout:setRGB(0, 0, 0)
    button.blackout:setAlpha(0)
    button:addElement(button.blackout)

    button.identifier = index
    button.luiMapvote = menu

    button:registerEventHandler("button_over", OptionFocus)
    button:registerEventHandler("button_up", OptionUnfocus)
    button:registerEventHandler("button_action", OptionSelect)

    return button

end

function OptionSelect(button, _)
    Engine.PlaySound( "uin_map_chosen" ) -- Do not play and idk why
    --[[
        As separetor between the mapname and the 
        index of the option selected and the we need to use something
        different from ' ' and ';' because ' SendMenuResponse will
        treat them as "badchar" and it will remove it or not display after it.
    ]]--

    local votefor = CoD.MapVote.focusIndex .. ",1"
    if allowchangevote == 0 then
        for i = 1, #button.luiMapvote.buttons do
            --button.luiMapvote.buttons[i].processEvent({name = "disable"})
            button.luiMapvote.buttons[i].m_focusable = nil
        end
        if CoD.MapVote.votedIndex == nil then
            CoD.MapVote.votedIndex = votefor
            Engine.SendMenuResponse(0, "mapvote", votefor)
        end
    else
        if CoD.MapVote.votedIndex == nil then
            CoD.MapVote.votedIndex = CoD.MapVote.focusIndex
            Engine.SendMenuResponse(0, "mapvote", votefor)
        elseif CoD.MapVote.votedIndex ~= CoD.MapVote.focusIndex then
            local removevotefor = CoD.MapVote.votedIndex .. ",-1"
            Engine.SendMenuResponse(0, "mapvote", removevotefor)
            CoD.MapVote.votedIndex = CoD.MapVote.focusIndex
            Engine.SendMenuResponse(0, "mapvote", votefor)
        end
    end
end

function GamepadHandle(luiMapvote, _)

    local buttonPressed = _.button
    if _.down ~= nil and _.down == false then
        buttonPressed = buttonPressed .. "_straight"
    end

    --print(buttonPressed)
    --print(tprint(_))

    if buttonPressed == "left_straight" or buttonPressed == "right_straight" then
        for i = 1, #luiMapvote.buttons do
            luiMapvote.buttons[i].border:setAlpha(0)
            luiMapvote.buttons[i].displayMapnameBackground:setLeftRight(true, true, 0, 0)
        end

        if buttonPressed == "left_straight" then
            CoD.MapVote.focusIndex = CoD.MapVote.focusIndex - 1
            if CoD.MapVote.focusIndex < 1 then
                CoD.MapVote.focusIndex = #luiMapvote.buttons
            end
        elseif buttonPressed == "right_straight" then
            CoD.MapVote.focusIndex = CoD.MapVote.focusIndex + 1
            if CoD.MapVote.focusIndex > #luiMapvote.buttons then
                CoD.MapVote.focusIndex = 1
            end
        end

        if CoD.MapVote.focusIndex ~= 0 then
            luiMapvote.buttons[CoD.MapVote.focusIndex]:processEvent({name = "button_over"})
        end
    elseif #luiMapvote.buttons == 6 and (buttonPressed == "down_straight" or buttonPressed == "up_straight") then
        for i = 1, #luiMapvote.buttons do
            luiMapvote.buttons[i].border:setAlpha(0)
            luiMapvote.buttons[i].displayMapnameBackground:setLeftRight(true, true, 0, 0)
        end

        if buttonPressed == "up_straight" then
            if CoD.MapVote.focusIndex == 1 then
                CoD.MapVote.focusIndex = 4
            elseif CoD.MapVote.focusIndex == 2 then
                CoD.MapVote.focusIndex = 5
            elseif CoD.MapVote.focusIndex == 3 then
                CoD.MapVote.focusIndex = 6
            elseif CoD.MapVote.focusIndex == 4 then
                CoD.MapVote.focusIndex = 1
            elseif CoD.MapVote.focusIndex == 5 then
                CoD.MapVote.focusIndex = 2
            elseif CoD.MapVote.focusIndex == 6 then
                CoD.MapVote.focusIndex = 3
            end
        elseif buttonPressed == "down_straight" then
            CoD.MapVote.focusIndex = CoD.MapVote.focusIndex + 3
            if CoD.MapVote.focusIndex > 6 then
                CoD.MapVote.focusIndex = CoD.MapVote.focusIndex - 6
            end
            if CoD.MapVote.focusIndex > #luiMapvote.buttons then
                CoD.MapVote.focusIndex = 1
            end
        end

        if CoD.MapVote.focusIndex ~= 0 then
            luiMapvote.buttons[CoD.MapVote.focusIndex]:processEvent({name = "button_over"})
        end
    elseif buttonPressed == "primary" then
        luiMapvote.buttons[CoD.MapVote.focusIndex]:processEvent({name = "button_action"})
    end
end

function OptionFocus(button, _)
    Engine.PlaySound( "uin_navigation_vote" )
    button.luiMapvote.buttons[CoD.MapVote.focusIndex].border:setAlpha(0)
    button.luiMapvote.buttons[CoD.MapVote.focusIndex].displayMapnameBackground:setLeftRight(true, true, 0, 0)
    button.luiMapvote.buttons[CoD.MapVote.focusIndex].votesBackgroundOutline:setRGB(1, 1, 1, 0)

    button.border:setAlpha(0.8)
    button.displayMapnameBackground:setLeftRight(true, true, 2, -2)
    button.votesBackgroundOutline:setRGB(CoD.MapVote.hovercolor[1], CoD.MapVote.hovercolor[2], CoD.MapVote.hovercolor[3], 0)
    CoD.MapVote.focusIndex = button.identifier
end

function OptionUnfocus(button, _)
    button.border:setAlpha(0)
    button.displayMapnameBackground:setLeftRight(true, true, 0, 0)
    button.votesBackgroundOutline:setRGB(1, 1, 1, 0)
end


--[[
    This function is used to print a table in a readable way
    It's not used in the code, but it's useful for debugging
    
    source: https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
]]
function tprint (tbl, indent)
    if not indent then indent = 0 end
    
    local toprint = string.rep(" ", indent) .. "{\r\n"
    indent = indent + 2 
    for k, v in pairs(tbl) do
      toprint = toprint .. string.rep(" ", indent)
      if (type(k) == "number") then
        toprint = toprint .. "[" .. k .. "] = "
      elseif (type(k) == "string") then
        toprint = toprint  .. k ..  "= "   
      end
      if (type(v) == "number") then
        toprint = toprint .. v .. ",\r\n"
      elseif (type(v) == "string") then
        toprint = toprint .. "\"" .. v .. "\",\r\n"
      elseif (type(v) == "table") then
        toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
      else
        toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
      end
    end
    toprint = toprint .. string.rep(" ", indent-2) .. "}"
    return toprint
  end