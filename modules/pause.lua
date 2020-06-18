local widget = require("widget")
local pause = {}
local group = display.newGroup()

local real_H = display.actualContentHeight
local real_W = display.actualContentWidth

local open_delay = 800
local close_delay = 800

function pause:new()

    local params = {
        [2] = {
            id = "scenes.reload",
            defaultFile = "images/pause/restart.png",
            overFile = "images/pause/restart-over.png",
            width = 42,
            height = 44,
        }
    }

    --self.bg = display.newImage(group, "images/pause/bg.png", true)
    --self.bg.x = real_W * 0.5
    --self.bg.y = real_H * 0.5
    --self.bg:scale(0.450, 0.450)
    --group:insert(self.bg)
    --
    local button_group = display.newGroup()
    self.pause_button = widget.newButton({
        id = "scenes.menu",
        defaultFile = "images/pause/pause.png",
        overFile = "images/pause/pause-over.png",
        width = 44,
        height = 44,
        onRelease = function()
            if (self.open) then
                return self:hide()
            end
            self:show()
        end
    })
    self.pause_button.x = real_W - real_W + 35
    self.pause_button.y = real_H - real_H + 35
    button_group:insert(self.pause_button)
    --
    --local buffer = 0
    --local spacing = - 25 -- in pixels
    --local pos = self.pause_button.y
    --
    --for i = 1, #params do
    --    local button = widget.newButton({
    --        defaultFile = params[i].defaultFile,
    --        overFile = params[i].overFile,
    --        width = params[i].width,
    --        height = params[i].height,
    --    })
    --    button.x = self.bg.x
    --    button.y = pos + buffer
    --    buffer = pos + (button_group.height + spacing)
    --    button_group:insert(button)
    --    group:insert(button)
    --end
    --
    --group.y = 0
    --group.x = -group.width

    return group
end

function pause:show()
    transition.to(group, {
        time = open_delay,
        alpha = 1,
        x = self.bg.x - 30,
        y = group.y,
        onComplete = function()
            self.open = true
        end
    })
    transition.to(self.pause_button, {
        time = open_delay,
        alpha = 1,
        x = self.pause_button.x + 50,
        y = self.pause_button.y,
    })
end

function pause:hide()
    transition.to(group, {
        time = close_delay,
        alpha = 0,
        x = -group.width,
        y = group.y,
        onComplete = function()
            self.open = false
        end
    })
    transition.to(self.pause_button, {
        time = close_delay,
        alpha = 1,
        x = real_W - real_W + 35,
        y = real_H - real_H + 35,
    })
end

-- todo: finish this:
function pause:Touch()
    if (self.open) then
        self:hide()
    end
end

return pause
