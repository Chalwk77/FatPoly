local mouse = { }

function mouse:Hover(event)
    mouse.x, mouse.y = event.x, event.y
end

function mouse:intersecting(mX, mY, pX, pY, W, H)
    if ((mX > pX) and (mX < pX + W) and (mY > pY) and (mY < pY + H)) then
        return true
    end
end

function mouse:OnTick(object)
    if (mouse.x and mouse.y) then
        local hovering = mouse:intersecting(mouse.x, mouse.y, object.x, object.y, object.width, object.height)
        if (hovering) then
            object:setStrokeColor(0 / 255, 255 / 255, 0 / 255)
        else
            object:setStrokeColor(colors.RGB("white"))
        end
    end

end

Runtime:addEventListener("enterFrame", mouse:OnTick())
Runtime:addEventListener("mouse", mouse:Hover())
return mouse