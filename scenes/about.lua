local composer = require("composer")
local scene = composer.newScene()
local widget = require('widget')
local sounds = require('libraries.sounds')
local colors = require('classes.colors-rgb')

local function setUpDisplay(grp)

    local width = (display.contentWidth / 2)
    local height = (display.contentHeight / 2)

    --
    -- Background:
    --
    local background = display.newImageRect("images/backgrounds/background.png", display.contentWidth + 550, display.contentHeight + 1000)
    background.alpha = 0.50
    grp:insert(background)

    --
    -- About Info:
    --
    local info = display.newImage("images/backgrounds/about_information.png")
    info.xScale = (0.5 * background.contentWidth) / background.contentWidth
    info.yScale = info.xScale
    info.x = display.contentCenterX
    info.y = display.contentCenterY
    info:scale(0.55, 0.55)
    info.alpha = 1
    grp:insert(info)

    --
    -- Copyright Notice
    --
    local txt = "Copyright © 2020, Particle Plex, Jericho Crosby <jericho.crosby227@gmail.com>"
    local copyright = display.newText(txt, 0, 0, native.systemFontBold, 8)
    copyright.x = width
    copyright.y = (height + height) - 5
    copyright:setFillColor(colors.RGB("white"))
    copyright:scale(0.5, 0.5)
    grp:insert(copyright)

    --
    -- Back Button:
    --
    local backButton = widget.newButton({
        defaultFile = "images/buttons/backbutton.png",
        overFile = "images/buttons/backbutton-over.png",
        onRelease = function()
            sounds.play("onTap")
            composer.gotoScene("scenes.menu", { effect = "crossFade", time = 300 })
        end
    })
    backButton.x = width - width + 20
    backButton.y = height - height + 20
    backButton.alpha = 1
    backButton:scale(0.30, 0.30)
    grp:insert(backButton)
end

function scene:create()
    setUpDisplay(self.view)
end

function scene:show(_)

end

function scene:hide(_)

end

-- -------------------------------------------------------------------------------
-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
-- -------------------------------------------------------------------------------
return scene
