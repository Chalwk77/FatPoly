module(..., package.seeall)
local colors = require('libraries.colors-rgb')

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

function newhealth(Text, Tab)
    
    local health = display.newGroup();
    health.text = display.newText(health, Text, 0, 0, native.systemFont, 7);
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

    health.background:setFillColor(colors.RGB(Tab[3]))
    health.text:setFillColor(colors.RGB(Tab[4]))
    return health;
end

function new(Text, Tab)
    newhealth(Text, Tab)
end

destroy = function(health)
    health.transition = transition.to(health, { time = 250, alpha = 0, onComplete = function()
        trueDestroy(health)
    end });
end




