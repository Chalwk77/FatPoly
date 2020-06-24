local composer = require('composer')
local scene = composer.newScene()

local widget = require('widget')
local toast = require('modules.toast')
local sounds = require('libraries.sounds')

local colors = require('libraries.colors-rgb')

local centerX = display.contentCenterX
local centerY = display.contentCenterY

local colorbox = { }
local group = display.newGroup()

local function switchScene(event)
    local sceneID = game.previousScene or event.target.id
    local options = { effect = "crossFade", time = 300 }
    composer.gotoScene(sceneID, options)
    sounds.play("onTap")
    game.previousScene = nil
end

local function setUpDisplay(grp)

    local width, height = (display.contentWidth / 2), (display.contentHeight / 2)

    local bg = display.newImage("images/color selection scene/background.png")
    bg.xScale = (bg.contentWidth / bg.contentWidth)
    bg.yScale = bg.xScale
    bg.x = centerX
    bg.y = centerY
    bg.alpha = 1
    bg:scale(1, 1)
    grp:insert(bg)

    local title_logo = display.newImage("images/color selection scene/title-logo.png")
    title_logo.xScale = (bg.contentWidth / bg.contentWidth)
    title_logo.yScale = bg.xScale
    title_logo.x = centerX
    title_logo.y = centerY - 110
    title_logo.alpha = 1
    title_logo:scale(0.23, 0.23)
    grp:insert(title_logo)

    --
    -- Back Button:
    --
    local backButton = widget.newButton({
        id = "scenes.options",
        defaultFile = "images/buttons/back.png",
        overFile = "images/buttons/back-over.png",
        onRelease = switchScene
    })
    backButton.x = width - width + 20
    backButton.y = height - height + 20
    backButton.alpha = 1
    backButton:scale(0.25, 0.25)
    grp:insert(backButton)
end

function ShowButtons()

    local real_H = display.actualContentHeight
    local real_W = display.actualContentWidth

    colorbox = {
        "red",
        "orange",
        "yellow",
        "lime",
        "green",
        "turquoise",
        "lightblue",
        "babyblue",
        "darkblue",
        "indigo",
        "hotpink",
        "pink",
    }

    group = display.newGroup()
    group.x, group.y = 0, real_H * 0.5 - 20

    local startX = group.x
    local size = 38
    local spacing = size
    local reset = true

    for i = 1, #colorbox do
        local button = widget.newButton({
            emboss = false,
            shape = "rect",
            width = size,
            height = size,
            cornerRadius = 0,
            fillColor = { default = { colors.RGB(colorbox[i]) }, over = { colors.RGB(colorbox[i]) } },
            strokeColor = { default = { 0 / 255, 0 / 255, 0 / 255 }, over = { 255 / 255, 255 / 255, 255 / 255 } },
            strokeWidth = 2,
            onEvent = function()
                game.color = colorbox[i]
                toast.new(colorbox[i], 750, "white", colorbox[i])
            end
        })

        if (i <= #colorbox / 2) then
            button.x = startX + spacing
        else
            if (reset) then
                reset = false
                spacing = size
            end
            button.y = button.y + (button.width * 2)
            button.x = startX + spacing
        end

        spacing = spacing + (button.width * 2)
        group:insert(button)

        transition.from(button, {
            time = 1000,
            delay = 100 * i,
            y = -real_W,
            transition = easing.outExpo
        })
    end
end

function scene:create(_)
    setUpDisplay(self.view)
end

function scene:show(event)
    local phase = event.phase
    if (phase == "will") then
        -- N/A
    elseif (phase == "did") then
        ShowButtons()
    end
end

function scene:hide(_)
    group:removeSelf()
end

-- -------------------------------------------------------------------------------
-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
-- -------------------------------------------------------------------------------

return scene
