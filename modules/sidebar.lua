local widget = require("widget")
local sidebar = {}
local group = display.newGroup()

local real_H = display.actualContentHeight
local real_W = display.actualContentWidth

local params = {
    [1] = {
        id = "scenes.pause",
        defaultFile = "images/buttons/pause.png",
        overFile = "images/buttons/pause-over.png",
        width = 42,
        height = 42,
    },
    [2] = {
        id = "scenes.menu",
        defaultFile = "images/buttons/menu.png",
        overFile = "images/buttons/menu-over.png",
        width = 42,
        height = 44,
    }
}

function sidebar:new()
    local button_group = display.newGroup()

    self.bg = display.newImage(group, "images/backgrounds/sidebar.png", true)
    self.bg.x = (real_W - (real_W - 30))
    self.bg.y = real_H * 0.5
    self.bg.width = 60
    self.bg.height = real_H
    group:insert(self.bg)

    local spacing = 5
    local height_buffer = 20

    for i = 1, #params do
        local button = widget.newButton({
            defaultFile = params[i].defaultFile,
            overFile = params[i].overFile,
            width = params[i].width,
            height = params[i].height,
        })

        button_group:insert(button)
        button.x = self.bg.x
        button.y = button_group.height + button.height - spacing
        button_group.y = button_group.y - height_buffer
    end

    group.y = 0
    group.x = 0

    return group
end

function sidebar:hide()
    self.open = false
    transition.to(group, { time = 800, alpha = 0, x = -group.width, y = group.y })
end

function sidebar:show()
    self.open = true
    transition.to(group, { time = 800, alpha = 1, x = self.bg.x - 20, y = group.y })
end

-- todo: finish this:
function sidebar:Touch()
    if (self.open) then
        self:hide()
    end
end

return sidebar
