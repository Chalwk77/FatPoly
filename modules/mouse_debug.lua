local colors = require("libraries.colors-rgb")

local mouse = { }

local centerX = display.contentCenterX
local centerY = display.contentCenterY

local o = display.newRect(centerX, centerY, 64, 64)

function Hover(event)
    mouse.x, mouse.y = event.x, event.y
end

function intersecting(mx, my, x, y, w, h)
    local dist = (mx - x) ^ 2 + (my - y) ^ 2
    if (dist <= 1000) then
        return true, print('true')
    end
end

function OnTick()
    if (mouse.x and mouse.y) then
        local hovering = intersecting(mouse.x, mouse.y, o.x, o.y, o.width, o.height)
        if (hovering) then
            o:setStrokeColor(colors.RGB("green"))
            o.strokeWidth = 5
        else
            o:setStrokeColor(colors.RGB("red"))
            o.strokeWidth = 5
        end
    end
end

Runtime:addEventListener("enterFrame", OnTick)
Runtime:addEventListener("mouse", Hover)
return mouse