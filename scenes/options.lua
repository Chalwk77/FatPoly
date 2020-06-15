local composer = require('composer')
local scene = composer.newScene()
local widget = require('widget')
local sounds = require('libraries.sounds')
local databox = require('libraries.databox')
local colors = require('classes.colors-rgb')

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenLeft = display.screenOriginX
local screenWidth = display.viewableContentWidth - screenLeft * 2
local screenTop = display.screenOriginY
local screenHeight = display.viewableContentHeight - screenTop * 2

local function switchScene(event)
    local sceneID = event.target.id
    local options = { effect = "crossFade", time = 300, params = { title = event.target.id } }
    composer.gotoScene(sceneID, options)
    sounds.play("onTap")
end

local function setUpDisplay(grp)

    local width, height = (display.contentWidth / 2), (display.contentHeight / 2)

    --
    -- Scene Background:
    --
    local background = display.newRect(centerX, centerY, screenWidth, screenHeight)
    local gradient_options = {
        type = "gradient",
        color1 = { 0 / 255, 0 / 255, 0 / 255 },
        color2 = { 50 / 255, 50 / 255, 50 / 255 },
        direction = "up"
    }
    background:setFillColor(gradient_options)
    grp:insert(background)


    --
    -- Scene Title Logo:
    --
    local title_logo = display.newImageRect("images/backgrounds/options2.png", 636, 208)
    title_logo.x = centerX
    title_logo.y = centerY - 80
    title_logo:scale(0.6, 0.6)
    grp:insert(title_logo)

    local toScale = math.random(0.1, 0.2)
    local random_sise = math.random(1, 2)
    local rotation
    if random_sise == 1 then
        rotation = 360
    else
        rotation = -360
    end
    transition.to(title_logo, { time = math.random(100, 250), delta = true, iterations = 2, rotation = rotation, xScale = toScale, yScale = toScale, onComplete = function(object)
        object:scale(1, 1)
    end })


    --
    -- Back Button:
    --
    local backButton = widget.newButton({
        id = "scenes.menu",
        defaultFile = "images/buttons/backbutton.png",
        overFile = "images/buttons/backbutton-over.png",
        onRelease = switchScene
    })
    backButton.x = width - width + 20
    backButton.y = height - height + 20
    backButton.alpha = 1
    backButton:scale(0.30, 0.30)
    grp:insert(backButton)


    --
    -- Sound ON Button
    --
    local SoundOn = widget.newButton({
        label = "Turn sound Off",
        labelColor = { default = { colors.RGB("red") }, over = { colors.RGB("blue") } },
        fontSize = 32,
        font = native.systemFontBold,
        onRelease = function()
            sounds.isSoundOn = false
            updateDataboxAndVisibility()
        end
    })
    SoundOn.x = centerX
    SoundOn.y = centerX + centerY - 180
    SoundOn.width = 100
    SoundOn.height = 25
    grp:insert(SoundOn)


    --
    -- Sound OFF Button
    --
    local SoundOff = widget.newButton({
        label = "Turn sound On",
        labelColor = { default = { colors.RGB("blue") }, over = { colors.RGB("red") } },
        font = native.systemFontBold,
        fontSize = 32,
        onRelease = function()
            audio.stop()
            sounds.isSoundOn = true
            updateDataboxAndVisibility()
        end
    })
    SoundOff.x = SoundOn.x
    SoundOff.y = SoundOn.y
    SoundOff.width = 100
    SoundOff.height = 25
    grp:insert(SoundOff)


    --
    -- Color Selection Menu Button:
    --
    local colorSelection = widget.newButton({
        label = "Color Selection",
        id = "scenes.colorselection",
        fontSize = 32,
        labelColor = { default = { colors.RGB("blue") }, over = { colors.RGB("green") } },
        onRelease = switchScene,
    })
    colorSelection.x = SoundOff.x
    colorSelection.y = SoundOff.y + 30
    colorSelection.width = 100
    colorSelection.height = 25
    grp:insert(colorSelection)


    --
    -- Update Sound State:
    --
    function updateDataboxAndVisibility()
        databox.isSoundOn = sounds.isSoundOn
        SoundOn.isVisible = false
        SoundOff.isVisible = false
        if (databox.isSoundOn) then
            SoundOn.isVisible = true
        else
            SoundOff.isVisible = true
        end
    end
    updateDataboxAndVisibility()
end

function scene:create(_)
    setUpDisplay(self.view)
end

function scene:show(grp)

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