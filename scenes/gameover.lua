local composer = require('composer')
local sounds = require('libraries.sounds')
local widget = require('widget')
local colors = require("classes.colors-rgb")
local scene = composer.newScene()

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenLeft = display.screenOriginX
local screenWidth = display.viewableContentWidth - screenLeft * 2
local screenTop = display.screenOriginY
local screenHeight = display.viewableContentHeight - screenTop * 2

local function switchScene(event)
    local sceneID = event.target.id
    local options = { effect = "crossFade", time = 200, params = { title = event.target.id } }
    composer.gotoScene(sceneID, options)
    sounds.play("onTap")
end

local function setUpDisplay(grp)

    local background = display.newRect(grp, centerX, centerY, screenWidth, screenHeight)
    local gradient_options = {
        type = "gradient",
        color1 = { 0 / 255, 0 / 255, 10 / 255 },
        color2 = { 0 / 255, 0 / 255, 100 / 255 },
        direction = "up"
    }
    background:setFillColor(gradient_options)
    grp:insert(background)

    local title_logo = display.newImageRect(grp, "images/backgrounds/gameover.png", 713, 85)
    title_logo.x = centerX
    title_logo.y = centerY - 100
    title_logo:scale(0.6, 0.6)
    grp:insert(title_logo)

    local spacing = 40
    local menuBtn = widget.newButton({
        label = "RETURN TO MENU",
        id = "scenes.menu",
        onRelease = switchScene,
        labelColor = { default = { colors.RGB("blue") }, over = { colors.RGB("green") } },
        font = native.systemFontBold,
        fontSize = 50,
    })

    menuBtn.x = centerX
    menuBtn.y = centerX + centerY - 180
    menuBtn.width = 100
    menuBtn.height = 25
    grp:insert(menuBtn)
end

function scene:create(_)
    setUpDisplay(self.view)
end

function scene:show(_)
    -- N/A
end

function scene:hide(_)
    -- N/A
end

function scene:destroy(_)
    -- N/A
end

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
