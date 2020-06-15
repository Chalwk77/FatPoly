local composer = require('composer')
local sounds = require('libraries.sounds')
local widget = require('widget')
widget.setTheme('widget_theme_ios')
local relayout = require('libraries.relayout')
local scene = composer.newScene()

-- most commonly used screen coordinates
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
    if (optionsBtn ~= nil) and (optionsBtn ~= nil) then
        optionsBtn.isVisible = false
        aboutBtn.isVisible = false
    end
    if (lastScoreLabel ~= nil) and (highScoreLabel ~= nil) then
        lastScoreLabel.isVisible = false
        highScoreLabel.isVisible = false
    end
    if sceneID == "scenes.reload_game" then
        levelNum = current_level
    end
    if sceneID == "scenes.nextgame" then
        gotoNextLevel = true
    end
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

    local displayLogo = display.newImageRect(grp, "images/backgrounds/gameover.png", 713, 85)
    displayLogo.x = centerX
    displayLogo.y = centerY - 100
    displayLogo:scale(0.6, 0.6)

    local spacing = 40
    local menuBtn = widget.newButton({ label = "Menu", id = "scenes.menu", onRelease = switchScene })
    menuBtn.x = centerX
    menuBtn.y = centerX + centerY - 180
    menuBtn.width = 100
    menuBtn.height = 25
    grp:insert(menuBtn)

    local replyBtn = widget.newButton({ label = "Replay", id = "scenes.reload_game", onRelease = switchScene })
    replyBtn.x = centerX
    replyBtn.y = menuBtn.y + spacing
    replyBtn.width = 100
    replyBtn.height = 25
    grp:insert(replyBtn)

    --levelNum = composer.getVariable( "levelNum")

    -- as long as their level is between 1-9, create a Continue button
    if (levelNum ~= #level) then
        continueBtn = widget.newButton({ label = "Next", id = "scenes.nextgame", onRelease = switchScene })
        continueBtn.x = centerX
        continueBtn.y = replyBtn.y + spacing
        continueBtn.width = 100
        continueBtn.height = 25
        grp:insert(continueBtn)
    end

    local animationDelay = 450
    local scaleFrom = 0.50
    local scaleTo = 0.55
    local alphaFrom = 0.50
    local alphaTo = 1

    local function menuBtnAnimation()
        local scaleUp = function()
            animate1 = transition.to(menuBtn, { time = animationDelay, alpha = alphaFrom, xScale = scaleFrom, yScale = scaleFrom, onComplete = menuBtnAnimation })
        end
        animate1 = transition.to(menuBtn, { time = animationDelay, alpha = alphaTo, xScale = scaleTo, yScale = scaleTo, onComplete = scaleUp })
    end
    menuBtnAnimation()
    local function replyBtnAnimation()
        local scaleUp = function()
            animate2 = transition.to(replyBtn, { time = animationDelay, alpha = alphaFrom, xScale = scaleFrom, yScale = scaleFrom, onComplete = replyBtnAnimation })
        end
        animate2 = transition.to(replyBtn, { time = animationDelay, alpha = alphaTo, xScale = scaleTo, yScale = scaleTo, onComplete = scaleUp })
    end
    replyBtnAnimation()
    local function continueBtnAnimation()
        local scaleUp = function()
            animate3 = transition.to(continueBtn, { time = animationDelay, alpha = alphaFrom, xScale = scaleFrom, yScale = scaleFrom, onComplete = continueBtnAnimation })
        end
        animate3 = transition.to(continueBtn, { time = animationDelay, alpha = alphaTo, xScale = scaleTo, yScale = scaleTo, onComplete = scaleUp })
    end
    continueBtnAnimation()
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
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif (phase == "did") then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
        --gameHasStarted = false
    end
end

-- "scene:hide()"
function scene:hide(event)

    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
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
