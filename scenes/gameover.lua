local composer = require('composer')
local scene = composer.newScene()

local widget = require('widget')
local sounds = require('libraries.sounds')
local colors = require("libraries.colors-rgb")

local CX = display.contentCenterX
local CY = display.contentCenterY
local real_w = display.actualContentWidth
local real_h = display.actualContentHeight

local scoreLabel
local highScoreLabel

local function switchScene(event)
    local sceneID = event.target.id
    local options = { effect = "crossFade", time = 200, params = { title = event.target.id } }
    composer.gotoScene(sceneID, options)
    sounds.play("onTap")
end

local function setUpDisplay(grp)

    local background = display.newRect(grp, CX, CY, real_w, real_h)
    local gradient_options = {
        type = "gradient",
        color1 = { 0 / 255, 0 / 255, 10 / 255 },
        color2 = { 0 / 255, 0 / 255, 100 / 255 },
        direction = "up"
    }
    background:setFillColor(gradient_options)
    grp:insert(background)

    local title_logo = display.newImageRect(grp, "images/gameover scene/gameover.png", 713, 85)
    title_logo.x = CX
    title_logo.y = CY - 100
    title_logo:scale(0.6, 0.6)
    grp:insert(title_logo)

    scoreLabel = display.newText("", CX, CY, native.systemFontBold, 15)
    scoreLabel:setTextColor(colors.RGB("red"))
    scoreLabel.x = CX
    scoreLabel.y = CY
    scoreLabel.alpha = 1
    scoreLabel.isVisible = false
    grp:insert(scoreLabel)

    highScoreLabel = display.newText("", CX, CY, native.systemFontBold, 15)
    highScoreLabel:setTextColor(colors.RGB("red"))
    highScoreLabel.x = scoreLabel.x
    highScoreLabel.y = scoreLabel.y + 30
    highScoreLabel.alpha = 1
    highScoreLabel.isVisible = false
    grp:insert(highScoreLabel)
end

function scene:create(_)
    setUpDisplay(self.view)
end

function scene:show(event)

    local phase = event.phase
    if (phase == "will") then
        -- N/A
        scoreLabel.text = "Score: " .. tostring(game.score)
        highScoreLabel.text = game.highscoretext
        scoreLabel.isVisible = true
        highScoreLabel.isVisible = true

    elseif (phase == "did") then
        UpdateStats()
    end
end

function scene:hide(_)
    scoreLabel.isVisible = false
    highScoreLabel.isVisible = false
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
