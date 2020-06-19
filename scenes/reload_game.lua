local composer = require('composer')
local scene = composer.newScene()

local relayout = require('libraries.relayout')
local reloadDelay = 500
local centerX = display.contentCenterX
local centerY = display.contentCenterY

local objects = { }

function scene:create()
    local _W, _H, _CX, _CY = relayout._W, relayout._H, relayout._CX, relayout._CY
    local group = self.view

    local background = display.newRect(group, _CX, _CY, _W, _H)
    background.fill = {
        type = 'gradient',
        color1 = { 0.2, 0.45, 0.8 },
        color2 = { 0.35, 0.4, 0.5 }
    }
    table.insert(objects, background)

    local label = display.newText({
        parent = group,
        text = 'LOADING LEVEL ' .. game.current_level .. " ...",
        x = centerX,
        y = centerY + 100,
        font = native.systemFontBold,
        fontSize = 24
    })

    table.insert(objects, label)
    local loadingIconGroup = display.newGroup()
    loadingIconGroup.x, loadingIconGroup.y = _CX, _CY
    loadingIconGroup:scale(0.7, 0.7)
    for i = 0, 2 do
        local loading = display.newImageRect(loadingIconGroup, 'images/misc/loading/loading.png', 64, 64)
        loading.x = 0
        loading.y = 0
        loading.anchorX = 5
        loading.anchorY = 10
        loading.rotation = 120 * i
        transition.to(loading, { time = 1500, rotation = 360, delta = true, iterations = -1 })
    end
    table.insert(objects, loadingIconGroup)
end

function scene:show(event)
    if (event.phase == "will") then
        for _, v in pairs(objects) do
            v.isVisible = true
        end
    elseif (event.phase == 'did') then
        local options = { effect = "crossFade", time = reloadDelay }
        timer.performWithDelay(reloadDelay, function()
            composer.gotoScene('scenes.play', options)
        end)
    end
end

function scene:hide(event)
    if (event.phase == 'will') then
        for _, v in pairs(objects) do
            v.isVisible = false
        end
    end
end

scene:addEventListener('create')
scene:addEventListener('show')
scene:addEventListener('hide')

return scene
