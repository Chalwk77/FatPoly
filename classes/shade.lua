local relayout = require('libraries.relayout')

local _M = {}

function _M.newShade(group)
    local shade = display.newRect(group, relayout._CX, relayout._CY, relayout._W, relayout._H)
    shade:setFillColor(0)
    shade.alpha = 0
    transition.to(shade, { time = 200, alpha = 0.5 })
    function shade:tap()
        return true
    end
    shade:addEventListener('tap')
    function shade:touch()
        return true
    end
    shade:addEventListener('touch')
    function shade:hide()
        transition.to(self, { time = 200, alpha = 0, onComplete = function(object)
            object:removeSelf()
        end })
    end
    relayout.add(shade)
    return shade
end

return _M
