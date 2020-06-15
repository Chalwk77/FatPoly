local widget = require("widget")
local sounds = require('libraries.sounds')

local slide_menu = {}
local group = display.newGroup()
local onTouch

local _W = display.contentWidth
local _H = display.contentHeight
local real_H = display.actualContentHeight
local real_x0 = (_H - real_H) * 0.5

function slide_menu:new(params)
    local button_group = display.newGroup()
    local params = params or {}
    local id = params.id or nil
    local default = params.default or nil
    local over = params.over or nil
    local text = params.text or nil
    local menu_event = params.event or nil
    local bg = params.bg or nil
    local back_image = params.back_image or nil
    local back_image_press = params.back_image_press or nil
    local background, slideBackButton2
    if bg then
        background = display.newImage(group, bg, true)
        background.x = display.contentWidth - background.width * 0.12
        background.y = real_H * 0.5
        background.width = 40
        background.height = display.contentHeight
    end
    local function back_event(e)
        local target = e.target
        if ("ended" == e.phase) then
            sounds.play('onTap')
            slide_menu:hide_slide_menu()
        end
    end
    local function scrollViewTouchHandler(event)
        if event.phase == "ended" then
            if gameHasStarted and slideMenuOpen and not colorUpdated then
                slide_menu:hide_slide_menu()
            end
        elseif event.phase == "moved" then
            if gameHasStarted and slideMenuOpen and not colorUpdated then
                slide_menu:hide_slide_menu()
            end
        end
        return true
    end
    sidebarScrollView = widget.newScrollView {
        top = 0,
        left = 0,
        height = real_H + 120,
        horizontalScrollDisabled = true,
        hideBackground = true,
        scrollHeight = 8000,
    }
    for i = 1, #text do
        buttons = widget.newButton({
            defaultFile = type(default) == "table" and default[i] or default,
            overFile = type(over) == "table" and over[i] or over,
            left = 0,
            top = 0,
            onRelease = function()
                if (i == 1) then
                    colorId = 1
                elseif (i == 2) then
                    colorId = 2
                elseif (i == 3) then
                    colorId = 3
                elseif (i == 4) then
                    colorId = 4
                elseif (i == 5) then
                    colorId = 5
                elseif (i == 6) then
                    colorId = 6
                elseif (i == 7) then
                    colorId = 7
                elseif (i == 8) then
                    colorId = 8
                elseif (i == 9) then
                    colorId = 9
                end
                sounds.play('onColorPick')
                colorUpdated = true
                menu_event()
            end
        })
        button_group:insert(buttons)
        buttons.x = _W * 0.483
        buttons.y = button_group.height + buttons.height * 0.2
        buttons.width = 22
        buttons.height = 22
    end
    sidebarScrollView:insert(button_group)
    sidebarScrollView.x = _W - button_group.width * 0.450
    sidebarScrollView.y = 75
    group:insert(sidebarScrollView)
    group.y = 0
    group.x = 0
    return group
end

function slide_menu:hide_slide_menu()
    slideMenuOpen = false
    transition.to(group, { time = 300, alpha = 1, x = group.width, y = group.y })
end

function slide_menu:show_slide_menu()
    colorUpdated = false
    slideMenuOpen = true
    transition.to(group, { time = 300, alpha = 1, x = 0, y = group.y })
end

return slide_menu
