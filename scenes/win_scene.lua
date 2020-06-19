local composer = require('composer')
local scene = composer.newScene()

local widget = require('widget')
local sounds = require('libraries.sounds')
local relayout = require('libraries.relayout')

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
        win_reset_bool = true
    end
    if sceneID == "scenes.nextgame" then
        gotoNextLevel = true
        win_reset_bool = true
    end
    character_bool.isVisible = false
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

    local logo_animationDelay = 450
    local logo_scaleFrom = 0.50
    local logo_scaleTo = 0.55
    local logo_alphaFrom = 0.50
    local logo_alphaTo = 1

    local displayLogo = display.newImageRect(grp, "images/backgrounds/you_win.png", 713, 85)
    displayLogo.x = centerX
    displayLogo.y = centerY - 100
    displayLogo:scale(0.6, 0.6)

    local _W, _H, _CX, _CY = relayout._W, relayout._H, relayout._CX, relayout._CY
    local titleGroup = display.newGroup()
    titleGroup.x, titleGroup.y = _CX, 128
    relayout.add(titleGroup)

    local title = "Particle Plex"
    local j = 1
    for i = -8, 4 do
        local character = display.newGroup()
        titleGroup:insert(character)
        local rect = display.newRect(character, 0, 0, 22, 22)
        rect.strokeWidth = 2
        rect:setFillColor(0.25)
        rect:setStrokeColor(0.15)
        rect.alpha = 30
        local text = display.newText({
            parent = character,
            text = title:sub(j, j),
            x = 0, y = 0,
            font = native.systemFontBold,
            fontSize = 22
        })
        local spacing = 30
        titleGroup.x = 300
        text:setFillColor(0.10, 1.5, 5.2)
        character.x, character.y = i * spacing, 0
        transition.from(character, { time = 500, delay = 200 * j, y = -_H, transition = easing.outExpo })
        j = j + 1
        character_bool = titleGroup
    end

    local spacing = 40
    local menuBtn = widget.newButton({ label = "Return to Menu", id = "scenes.menu", onRelease = switchScene })
    menuBtn.x = centerX
    menuBtn.y = centerX + centerY - 180
    menuBtn.width = 100
    menuBtn.height = 25
    grp:insert(menuBtn)

    local chooseLvlBtn = widget.newButton({ label = "Play Again", id = "scenes.chooselevel", onRelease = switchScene })
    chooseLvlBtn.x = centerX
    chooseLvlBtn.y = menuBtn.y + spacing
    chooseLvlBtn.width = 100
    chooseLvlBtn.height = 25
    grp:insert(chooseLvlBtn)

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
    local function chooseLvlBtnAnimation()
        local scaleUp = function()
            animate2 = transition.to(chooseLvlBtn, { time = animationDelay, alpha = alphaFrom, xScale = scaleFrom, yScale = scaleFrom, onComplete = chooseLvlBtnAnimation })
        end
        animate2 = transition.to(chooseLvlBtn, { time = animationDelay, alpha = alphaTo, xScale = scaleTo, yScale = scaleTo, onComplete = scaleUp })
    end
    chooseLvlBtnAnimation()
end

-- "scene:create()"
function scene:create(event)
    local sceneGroup = self.view
    setUpDisplay(sceneGroup)
    canSpawnItems = false
    removeHealhAnimation = true
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
