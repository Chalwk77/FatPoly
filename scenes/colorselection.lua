local composer = require('composer')
local sounds = require('libraries.sounds')
local toast = require('modules.toast')
local scene = composer.newScene()
local widget = require('widget')

local centerX = display.contentCenterX
local centerY = display.contentCenterY

local function switchScene(event)
    local sceneID = event.target.id
    local options = { effect = "crossFade", time = 300 }
    composer.gotoScene(sceneID, options)
    sounds.play("onTap")
end

local function setUpDisplay(grp)

    local width, height = (display.contentWidth / 2), (display.contentHeight / 2)

    local bg = display.newImage("images/backgrounds/colorselectbg.png")
    bg.xScale = (bg.contentWidth / bg.contentWidth)
    bg.yScale = bg.xScale
    bg.x = centerX
    bg.y = centerY
    bg.alpha = 1
    bg:scale(1, 1)
    grp:insert(bg)

    local title_logo = display.newImage("images/backgrounds/colorselect.png")
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
        defaultFile = "images/buttons/backbutton.png",
        overFile = "images/buttons/backbutton-over.png",
        onRelease = switchScene
    })
    backButton.x = width - width + 20
    backButton.y = height - height + 20
    backButton.alpha = 1
    backButton:scale(0.30, 0.30)
    grp:insert(backButton)

    local x, y = -2, 0
    local spacing = 100
    for i = 1, 9 do

        local COLOR = widget.newButton({
            defaultFile = 'images/color data/slide_menu' .. i .. '.png',
            overFile = 'images/color data/slide_menu' .. i .. '_press.png',
            width = 64, height = 64,
            x = x * spacing + 240,
            y = 100 + y * spacing + 25,
            onRelease = function()
                if (i == 1) then
                    game.color = "red"
                elseif (i == 2) then
                    game.color = "yellow"
                elseif (i == 3) then
                    game.color = "pink"
                elseif (i == 4) then
                    game.color = "green"
                elseif (i == 5) then
                    game.color = "purple"
                elseif (i == 6) then
                    game.color = "orange"
                elseif (i == 7) then
                    game.color = "blue"
                elseif (i == 8) then
                    game.color = "white"
                elseif (i == 9) then
                    game.color = "black"
                end
                if (game.color == "white") then
                    toast.new(game.color, 750, "white", "black")
                elseif (game.color == "black") then
                    toast.new(game.color, 750, "black", "white")
                else
                    toast.new(game.color, 750, "white", game.color)
                end
            end
        })
        COLOR:scale(0.5, 0.5)
        grp:insert(COLOR)
        x = x + 1
        if x == 3 then
            x = -2
            y = y + 1
        end
    end
end

function scene:create(_)
    setUpDisplay(self.view)
end

function scene:show(_)
    -- N/A
end

function scene:hide(event)
    -- N/A
end

-- -------------------------------------------------------------------------------
-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
-- -------------------------------------------------------------------------------

return scene
