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
local hovercolor =  {
    [1] = "1",
    [2] = "1",
    [3] = "1"
}
local focusIndex = 1
local votedIndex = nil
local maxOptions = 3

LUI.createMenu.mapvote = function (_) 
    local lui_mv_hovercolor = strsplit( UIExpression.DvarString(nil, "lui_mv_hovercolor") , ";")
    hovercolor = {
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

    local luiMapvote = CoD.Menu.NewFromState("mapvote", LUI.UIElement.ContainerState)
    luiMapvote:setBackOutSFX("cac_cmn_backout")
    
    --[[
        MAP VOTING IN PROGRESS                0:00
        --------------------------------------------

        MAP NAME        MAP NAME        MAP NAME
        MAP GAMETYPE    MAP GAMETYPE    MAP GAMETYPE
        VOTES           VOTES           VOTES

        --------------------------------------------
    ]]--

    luiMapvote.title = LUI.UIText.new()
    luiMapvote.title:setLeftRight(false, false, -457, 175)
	luiMapvote.title:setTopBottom(true, false, 122, 166)
    luiMapvote.title:setText(UIExpression.ToUpper(nil, Engine.Localize("MPUI_MAPVOTINGPROGRESS")))
    luiMapvote.title:setFont(CoD.fonts.Morris)
    luiMapvote.title:setAlignment(LUI.Alignment.Left)

    luiMapvote.subtitle = LUI.UIText.new()
    luiMapvote.subtitle:setLeftRight(false, false, -457, 175)
	luiMapvote.subtitle:setTopBottom(true, false, 166, 180)
    luiMapvote.subtitle:setText("Developed by @DoktorSAS")
    luiMapvote.subtitle:setFont(CoD.fonts.Morris)
    luiMapvote.subtitle:setAlpha(0.8)
    luiMapvote.subtitle:setAlignment(LUI.Alignment.Left)

    luiMapvote.timer = LUI.UIText.new()
    luiMapvote.timer:setLeftRight(false, false, 175, 457)
	luiMapvote.timer:setTopBottom(true, false, 122, 166)
	luiMapvote.timer:setFont(CoD.fonts.Morris)
	luiMapvote.timer:setAlignment(LUI.Alignment.Right)
	CoD.CountdownTimer.Setup(luiMapvote.timer, 0, true)
	luiMapvote.timer:setTimeLeft(tonumber(UIExpression.DvarInt(nil, "lui_mv_time")))

    luiMapvote:addElement(luiMapvote.title)
    luiMapvote:addElement(luiMapvote.subtitle)
    luiMapvote:addElement(luiMapvote.timer)

    if #maps == 3 then
        luiMapvote.buttons =  {
            [1] = CreateMapvoteOption(luiMapvote, "mapvoteoption1", 1,  432, 200, maps[1], gametypes[1], loadscreens[1], -457);
            [2] = CreateMapvoteOption(luiMapvote, "mapvoteoption2", 2,  432, 200, maps[2], gametypes[2], loadscreens[2], -141);
            [3] = CreateMapvoteOption(luiMapvote, "mapvoteoption3", 3,  432, 200, maps[3], gametypes[3], loadscreens[3], 175);
        }
        luiMapvote:addElement(luiMapvote.buttons[1])
        luiMapvote:addElement(luiMapvote.buttons[2])
        luiMapvote:addElement(luiMapvote.buttons[3])
    else 
        maxOptions = 6
        luiMapvote.buttons =  {
            [1] = CreateMapvoteOption(luiMapvote, "mapvoteoption1", 1, 200, 200, maps[1], gametypes[1], loadscreens[1], -457);
            [2] = CreateMapvoteOption(luiMapvote, "mapvoteoption2", 2, 200, 200, maps[2], gametypes[2], loadscreens[2], -141);
            [3] = CreateMapvoteOption(luiMapvote, "mapvoteoption3", 3, 200, 200, maps[3], gametypes[3], loadscreens[3], 175);
            [4] = CreateMapvoteOption(luiMapvote, "mapvoteoption4", 4, 200, 432, maps[4], gametypes[4], loadscreens[4], -457);
            [5] = CreateMapvoteOption(luiMapvote, "mapvoteoption5", 5, 200, 432, maps[5], gametypes[5], loadscreens[5], -141);
            [6] = CreateMapvoteOption(luiMapvote, "mapvoteoption6", 6, 200, 432, maps[6], gametypes[6], loadscreens[6], 175);
        }
        luiMapvote:addElement(luiMapvote.buttons[1])
        luiMapvote:addElement(luiMapvote.buttons[2])
        luiMapvote:addElement(luiMapvote.buttons[3])
        luiMapvote:addElement(luiMapvote.buttons[4])
        luiMapvote:addElement(luiMapvote.buttons[5])
        luiMapvote:addElement(luiMapvote.buttons[6])
    end
    
    luiMapvote.buttons[1]:processEvent({name = "button_over"}) -- force focus the first button
    luiMapvote:registerEventHandler("gamepad_button", GamepadHandle)
    luiMapvote:registerEventHandler("update_votes", UpdateVotes)
    luiMapvote:registerEventHandler("mapvote_close", MapvoteClose)
    return luiMapvote
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
    
    if maxOptions == 3 then
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

	button.border = CoD.Border.new(1, hovercolor[1], hovercolor[2], hovercolor[3], 0)
	button:addElement(button.border)

    button.highlight = CoD.Border.new(1, hovercolor[1], hovercolor[2], hovercolor[3], 0)
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

    local votefor = focusIndex .. ",1"
    if allowchangevote == 0 then
        for i = 1, #button.luiMapvote.buttons do
            --button.luiMapvote.buttons[i].processEvent({name = "disable"})
            button.luiMapvote.buttons[i].m_focusable = nil
        end
        if votedIndex == nil then
            votedIndex = votefor
            Engine.SendMenuResponse(0, "mapvote", votefor)
        end
    else
        if votedIndex == nil then
            votedIndex = focusIndex
            Engine.SendMenuResponse(0, "mapvote", votefor)
        elseif votedIndex ~= focusIndex then
            local removevotefor = votedIndex .. ",-1"
            Engine.SendMenuResponse(0, "mapvote", removevotefor)
            votedIndex = focusIndex
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
            focusIndex = focusIndex - 1
            if focusIndex < 1 then
                focusIndex = #luiMapvote.buttons
            end
        elseif buttonPressed == "right_straight" then
            focusIndex = focusIndex + 1
            if focusIndex > #luiMapvote.buttons then
                focusIndex = 1
            end
        end

        if focusIndex ~= 0 then
            luiMapvote.buttons[focusIndex]:processEvent({name = "button_over"})
        end
    elseif #luiMapvote.buttons == 6 and (buttonPressed == "down_straight" or buttonPressed == "up_straight") then
        for i = 1, #luiMapvote.buttons do
            luiMapvote.buttons[i].border:setAlpha(0)
            luiMapvote.buttons[i].displayMapnameBackground:setLeftRight(true, true, 0, 0)
        end

        if buttonPressed == "up_straight" then
            if focusIndex == 1 then
                focusIndex = 4
            elseif focusIndex == 2 then
                focusIndex = 5
            elseif focusIndex == 3 then
                focusIndex = 6
            elseif focusIndex == 4 then
                focusIndex = 1
            elseif focusIndex == 5 then
                focusIndex = 2
            elseif focusIndex == 6 then
                focusIndex = 3
            end
        elseif buttonPressed == "down_straight" then
            focusIndex = focusIndex + 3
            if focusIndex > 6 then
                focusIndex = focusIndex - 6
            end
            if focusIndex > #luiMapvote.buttons then
                focusIndex = 1
            end
        end

        if focusIndex ~= 0 then
            luiMapvote.buttons[focusIndex]:processEvent({name = "button_over"})
        end
    elseif buttonPressed == "primary" then
        luiMapvote.buttons[focusIndex]:processEvent({name = "button_action"})
    end
end

function OptionFocus(button, _)
    Engine.PlaySound( "uin_navigation_vote" )
    button.luiMapvote.buttons[focusIndex].border:setAlpha(0)
    button.luiMapvote.buttons[focusIndex].displayMapnameBackground:setLeftRight(true, true, 0, 0)
    button.luiMapvote.buttons[focusIndex].votesBackgroundOutline:setRGB(1, 1, 1, 0)

    button.border:setAlpha(0.8)
    button.displayMapnameBackground:setLeftRight(true, true, 2, -2)
    button.votesBackgroundOutline:setRGB(hovercolor[1], hovercolor[2], hovercolor[3], 0)
    focusIndex = button.identifier
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