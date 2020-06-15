module(..., package.seeall)
local colors = require('classes.colors-rgb')

local trueDestroy
local destroy

function trueDestroy(health)
    health:removeSelf();
    health = nil;
end

local actualContent = {
    height = display.actualContentHeight,
    top = (display.contentHeight - display.actualContentHeight) / 2,
    moreHeight = display.actualContentHeight - display.contentHeight,
}

function newhealth(pText, pTime)
    local pText = pText or nil
    local pTime = pTime or 3000;
    local health = display.newGroup();
    health.text = display.newText(health, pText, 0, 0, native.systemFont, 7);
    health.text:setTextColor(1, 1, 1)
    health.background = display.newRect(health, 0, 0, health.text.width + 20, health.text.height);
    health.background.strokeWidth = 1
    health.background:setStrokeColor(0, 0, 0)
    health.text:toFront();
    health.alpha = 0;
    health.transition = transition.to(health, { time = 250, alpha = 1 });
    if pTime ~= nil then
        timer.performWithDelay(pTime, function()
            destroy(health)
        end);
    end
    -- position on screen --
    health.x = display.contentWidth * .5 + 170
    health.y = actualContent.height * .8 - 195
    if healthRemaining == 100 then
        health.background:setFillColor(colorsRGB.RGB("health1"))
        health.text:setFillColor(colorsRGB.RGB("black"))
    elseif healthRemaining == 75 then
        health.background:setFillColor(colorsRGB.RGB("health2"))
        health.text:setFillColor(colorsRGB.RGB("black"))
    elseif healthRemaining == 50 then
        health.background:setFillColor(colorsRGB.RGB("health3"))
        health.text:setFillColor(colorsRGB.RGB("white"))
    elseif healthRemaining == 25 then
        health.background:setFillColor(colorsRGB.RGB("health4"))
        health.text:setFillColor(colorsRGB.RGB("white"))
    elseif healthRemaining == 0 then
        health.background:setFillColor(colorsRGB.RGB("health5"))
        health.text:setFillColor(colorsRGB.RGB("white"))
    end
    return health;
end

function new(pText, pTime)
    newhealth(pText, pTime)
end

destroy = function(health)
    health.transition = transition.to(health, { time = 250, alpha = 0, onComplete = function()
        trueDestroy(health)
    end });
end




