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

function newhealth(CurrentHealth)

    local txt = ""
    if (CurrentHealth == 100) then
        txt = "IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII"
    elseif (CurrentHealth == 75) then
        txt = "IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII"
    elseif (CurrentHealth == 50) then
        txt = "IIIIIIIIIIIIIIIIIIII"
    elseif (CurrentHealth == 25) then
        txt = "IIIII"
    elseif (CurrentHealth == 0) then
        txt = "I"
    end

    local health = display.newGroup();
    health.text = display.newText(health, txt, 0, 0, native.systemFont, 7);
    health.text:setTextColor(1, 1, 1)
    health.background = display.newRect(health, 0, 0, health.text.width + 20, health.text.height);
    health.background.strokeWidth = 1
    health.background:setStrokeColor(0, 0, 0)
    health.text:toFront();
    health.alpha = 0;
    health.transition = transition.to(health, { time = 250, alpha = 1 });
    timer.performWithDelay(100, function()
        destroy(health)
    end);

    health.x = display.contentWidth * .5 + 170
    health.y = actualContent.height * .8 - 195

    if (CurrentHealth == 100) then
        health.background:setFillColor(colors.RGB("health1"))
        health.text:setFillColor(colors.RGB("black"))
    elseif (CurrentHealth == 75) then
        health.background:setFillColor(colors.RGB("health2"))
        health.text:setFillColor(colors.RGB("black"))
    elseif (CurrentHealth == 50) then
        health.background:setFillColor(colors.RGB("health3"))
        health.text:setFillColor(colors.RGB("white"))
    elseif (CurrentHealth == 25) then
        health.background:setFillColor(colors.RGB("health4"))
        health.text:setFillColor(colors.RGB("white"))
    elseif (CurrentHealth == 0) then
        health.background:setFillColor(colors.RGB("health5"))
        health.text:setFillColor(colors.RGB("white"))
    end
    return health;
end

function new(CurrentHealth)
    newhealth(CurrentHealth)
end

destroy = function(health)
    health.transition = transition.to(health, { time = 250, alpha = 0, onComplete = function()
        trueDestroy(health)
    end });
end




