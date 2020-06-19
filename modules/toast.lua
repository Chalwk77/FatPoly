module(..., package.seeall)
local trueDestroy
local destroy

local colors = require('libraries.colors-rgb')
function trueDestroy(toast)
    toast:removeSelf();
    toast = nil;
end

local actualContent = {
    height = display.actualContentHeight,
    top = (display.contentHeight - display.actualContentHeight) / 2,
    moreHeight = display.actualContentHeight - display.contentHeight,
}

function destroy(toast)
    toast.transition = transition.to(toast, { time = 250, alpha = 0, onComplete = function()
        trueDestroy(toast)
    end });
end

local function newToast(pText, pTime, TxtColor, BGColor)

    local pText = pText or nil
    local pTime = pTime or 3000;
    local TxtColor = TxtColor or "white"
    local BGColor = BGColor or "black"

    local toast = display.newGroup();
    toast.text = display.newText(toast, pText, 0, 0, native.systemFont, 24);
    toast.text:setTextColor(colors.RGB(TxtColor))

    toast.background = display.newRoundedRect(toast, 0, 0, toast.text.width + 24, toast.text.height + 24, 16);
    toast.background.strokeWidth = 4
    toast.background:setFillColor(colors.RGB(BGColor))
    toast.background:setStrokeColor(0, 0, 0)

    toast.text:toFront();
    toast.alpha = 0;
    toast.transition = transition.to(toast, { time = 250, alpha = 1 });
    if (pTime ~= ni) then
        timer.performWithDelay(pTime, function()
            destroy(toast)
        end);
    end
    toast.x = display.contentWidth * .5
    toast.y = actualContent.height * .8
    return toast;
end

function new(pText, pTime, TxtColor, BGColor)
    newToast(pText, pTime, TxtColor, BGColor)
end