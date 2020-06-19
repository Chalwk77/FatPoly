local composer = require('composer')
local scene = composer.newScene()

local sounds = require('libraries.sounds')
local widget = require('widget')

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenLeft = display.screenOriginX
local screenWidth = display.viewableContentWidth - screenLeft * 2
local screenRight = screenLeft + screenWidth
local screenTop = display.screenOriginY
local screenHeight = display.viewableContentHeight - screenTop * 2
local screenBottom = screenTop + screenHeight

local function switchScene(event)
    local sceneID = event.target.id
    local options = { effect = "crossFade", time = 200, params = { title = event.target.id } }
    composer.gotoScene(sceneID, options)
    sounds.play("onTap")
    if sceneID == "scenes.play" then
        canSpawnItems = true
        gameresumed = true
    end
    if (optionsBtn ~= nil) and (optionsBtn ~= nil) then
        optionsBtn.isVisible = false
        aboutBtn.isVisible = false
    end
    --pauseShade.alpha = 0
    resumeLogo:removeSelf()
end

local function setUpDisplay(grp)

    local spacing = 100

    local pauseText = display.newText(grp, "GAME PAUSED", 0, 0, native.systemFontBold, 24)
    pauseText.x = centerX
    pauseText.y = centerY
    pauseText:setFillColor(colorsRGB.RGB("white"))
    pauseText.alpha = 1

    resumeLogo = widget.newButton {
        defaultFile = 'images/backgrounds/resume.png',
        overFile = 'images/backgrounds/resume.png',
        width = 213, height = 35,
        id = "scenes.play",
        x = pauseText.x, y = pauseText.y + spacing,
        onRelease = switchScene,
    }
    local function animation()
        local scaleUp = function()
            if gameIsPaused then
                startButtonTween = transition.to(resumeLogo, { time = 450, alpha = 0.80, xScale = 0.8, yScale = 0.8, onComplete = animation })
            end
        end
        if gameIsPaused then
            startButtonTween = transition.to(resumeLogo, { time = 450, alpha = 1, xScale = 0.6, yScale = 0.6, onComplete = scaleUp })
        end
    end
    animation()
    -- pauseShade = display.newRect( 0, 0, display.viewableContentWidth - 100, display.viewableContentHeight - 200)
    -- pauseShade.x = display.viewableContentWidth / 2
    -- pauseShade.y = display.viewableContentHeight / 2
    -- pauseShade:setFillColor ( 0, 0, 0, (gameIsOver and 20 or 255) )
    -- pauseShade.alpha = 0.10
end

-- "scene:create()"
function scene:create(event)

    local sceneGroup = self.view

    setUpDisplay(sceneGroup)
end

-- "scene:show()"
function scene:show(event)

    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        gameIsPaused = true
        Runtime:removeEventListener("enterFrame", function()
            player.rotation = player.rotation - 10;
        end)
        Runtime:removeEventListener("enterFrame", animate);
        for _, object in pairs(objects) do
            object.isVisible = false
        end
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif (phase == "did") then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
        gameHasStarted = false
    end
end

-- "scene:hide()"
function scene:hide(event)

    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        if sceneGroup == "scenes.play" then
            print("yes")
        end
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
    elseif (phase == "did") then
        -- Called immediately after scene goes off screen.
    end
end

-- "scene:destroy()"
function scene:destroy(event)

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
end

function showMenuButtons()
    if (optionsBtn ~= nil) and (aboutBtn ~= nil) then
        optionsBtn.isVisible = true
        aboutBtn.isVisible = true
    end
end

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
