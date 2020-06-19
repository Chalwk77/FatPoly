local widget = require("widget")
local sidebar = {}
local group = display.newGroup()

local real_H = display.actualContentHeight
local real_W = display.actualContentWidth

local open_delay = 800
local close_delay = 800

local buttons = {
    [1] = {
        id = "scenes.pause",
        defaultFile = "images/buttons/menu.png",
        overFile = "images/buttons/menu-over.png",
        width = 42,
        height = 42,
    }
}

function sidebar:new()

    self.bar = display.newImage(group, "images/misc/sidebar/sidebar.png", true)
    self.bar.x = (real_W - (real_W - 30))
    self.bar.y = real_H * 0.5
    self.bar.width = 60
    self.bar.height = real_H
    group:insert(self.bar)

    self.pause_button = widget.newButton({
        defaultFile = "images/buttons/pause.png",
        overFile = "images/buttons/pause-over.png",
        width = 32,
        height = 32,
        onRelease = function()
            if (self.open) then
                return self:hide()
            end
            self:show()
        end
    })

    self.pause_button.x = real_W - real_W + 35
    self.pause_button.y = real_H - real_H + 35

    local spacing = 5
    local height_buffer = 5

    local button_group = display.newGroup()
    for i = 1, #buttons do
        local button = widget.newButton({
            defaultFile = buttons[i].defaultFile,
            overFile = buttons[i].overFile,
            width = buttons[i].width,
            height = buttons[i].height,
        })

        button.x = self.bar.x
        button.y = button_group.height + button.height - spacing
        button_group.y = button_group.y - height_buffer
        button_group:insert(button)
        group:insert(button)
    end

    group.y = 0
    group.x = -group.width

    return group
end

function sidebar:show()
    transition.to(group, {
        time = open_delay,
        alpha = 1,
        x = self.bar.x - 30,
        y = group.y,
        onComplete = function()
            self.open = true
        end
    })
    transition.to(self.pause_button, {
        time = open_delay,
        alpha = 1,
        x = self.bar.x + 55,
        y = real_H - real_H + 35
    })
end

function sidebar:hide()
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

function sidebar:Touch()
    if (self.open) then
        self:hide()
    end
end

return sidebar