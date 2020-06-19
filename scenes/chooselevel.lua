local composer = require('composer')
local scene = composer.newScene()

local widget = require('widget')
local sounds = require('libraries.sounds')
local colors = require('libraries.colors-rgb')

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local toast = require('modules.toast')
local group = display.newGroup()

local function switchScene(event)

    local options = { effect = "crossFade", time = 300 }
    local sceneID = event.target.id
    local level = event.target.levelNum

    sounds.play("onTap")

    if not (game.levels[level][1]) then
        toast.new("You haven't unlocked level " .. level, 1500, "red", "white")
        return
    end

    -- SET LEVEL:
    if (sceneID == "scenes.reload_game") then
        game.current_level = level
    end

    composer.gotoScene(sceneID, options)
end

local function setUpDisplay(grp)

    local width = (display.contentWidth / 2)
    local height = (display.contentHeight / 2)

    local bg = display.newImage("images/level select scene/background.png")
    bg.xScale = width / width
    bg.yScale = bg.xScale
    bg.x = centerX
    bg.y = centerY
    bg.alpha = 0.35
    bg:scale(0.5, 0.5)
    grp:insert(bg)

    local logo = display.newImage("images/level select scene/title-logo.png")
    logo.xScale = width / width
    logo.yScale = bg.xScale
    logo.x = centerX
    logo.y = centerY - 120
    logo:scale(0.6, 1)
    logo.alpha = 1
    grp:insert(logo)

    local toScale = math.random(0.1, 0.2)
    local i = 360
    if (math.random(1, 2) == 1) then
        i = -360
    end
    transition.to(logo, {
        time = math.random(100, 250),
        delta = true,
        iterations = 2,
        rotation = i,
        xScale = toScale,
        yScale = toScale,
        onComplete = function(object)
            object:scale(1, 1)
        end
    })

    local backButton = widget.newButton({
        defaultFile = "images/buttons/back.png",
        overFile = "images/buttons/back-over.png",
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

    local x, y = -2, 0
    local spacing = 100

    for i = 1, 10 do
        local levelBtn = widget.newButton({
            label = "Level " .. i,
            id = "scenes.reload_game",
            labelColor = { default = { colors.RGB("blue") }, over = { colors.RGB("green") } },
            font = native.systemFontBold,
            fontSize = 15,
            labelYOffset = -50,
            defaultFile = 'images/level select scene/level.png',
            overFile = 'images/level select scene/level-over.png',
            width = 64,
            height = 64,
            x = x * spacing + 240,
            y = 100 + y * spacing + 25,
            onRelease = switchScene,
        })
        levelBtn.levelNum = i
        levelBtn:scale(0.8, 0.9)
        grp:insert(levelBtn)
        x = x + 1
        if (x == 3) then
            x = -2
            y = y + 1
        end
    end
end

function scene:create(_)
    setUpDisplay(self.view)
end

function scene:show()
    local padlock
    local x, y = -2, 0
    local spacing = 100
    for i = 1, 10 do
        if (game.levels[i][1]) then
            padlock = display.newImage("images/level select scene/padlock-unlocked.png")
        else
            padlock = display.newImage("images/level select scene/padlock-locked.png")
        end
        padlock.x = x * spacing + 240
        padlock.y = 100 + y * spacing + 33
        padlock.alpha = 1
        padlock:scale(0.22, 0.22)
        group:insert(padlock)
        x = x + 1
        if (x == 3) then
            x = -2
            y = y + 1
        end
    end
end

function scene:hide(_)
    group:removeSelf()
    group = display.newGroup()
end

-- -------------------------------------------------------------------------------
-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)

-- -------------------------------------------------------------------------------

return scene
