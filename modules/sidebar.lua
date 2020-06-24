local widget = require("widget")
local sidebar = {}

local composer = require('composer')
local databox = require('libraries.databox')
local sounds = require('libraries.sounds')

local group = display.newGroup()

local real_H = display.actualContentHeight
local real_W = display.actualContentWidth

local open_delay = 200
local close_delay = 200
local SoundOn, SoundOff

local buttons = {
    [1] = {
        defaultFile = "images/buttons/menu.png",
        overFile = "images/buttons/menu-over.png",
        width = 32,
        height = 32,
        onRelease = function()
            composer.gotoScene("scenes.menu", { effect = "crossFade", time = 300 })
        end
    },

    [2] = {
        defaultFile = "images/buttons/restart.png",
        overFile = "images/buttons/restart-over.png",
        width = 32,
        height = 32,
        onRelease = function()
            composer.gotoScene("scenes.reload_game", { effect = "crossFade", time = 300 })
        end
    },

    [3] = {
        defaultFile = "images/buttons/colorSelection.png",
        overFile = "images/buttons/colorSelection-over.png",
        width = 32,
        height = 32,
        onRelease = function()
            composer.gotoScene("scenes.colorselection", { effect = "crossFade", time = 300 })
        end
    },

    [4] = {
        {
            defaultFile = "images/buttons/sounds_on.png",
            overFile = "images/buttons/sounds_on-over.png",
            width = 32,
            height = 32,
            onRelease = function()
                sounds.isSoundOn = false
                databox.isSoundOn = sounds.isSoundOn

                SoundOn.isVisible = false
                SoundOff.isVisible = true
            end
        },
        {
            defaultFile = "images/buttons/sounds_off.png",
            overFile = "images/buttons/sounds_off-over.png",
            width = 32,
            height = 32,
            onRelease = function()
                sounds.isSoundOn = true
                databox.isSoundOn = sounds.isSoundOn

                SoundOn.isVisible = true
                SoundOff.isVisible = false
            end
        }
    },

    [5] = {
        defaultFile = "images/buttons/exit.png",
        overFile = "images/buttons/exit-over.png",
        width = 32,
        height = 32,
        onRelease = function()
            native.showAlert("Confirm Exit", "Are you sure you want to exit?", { "Yes", "No" },
                    function(e)
                        if (e.action == 'clicked' and e.index == 1) then
                            native.requestExit()
                        end
                    end)
        end
    },

    [6] = {
        defaultFile = "images/buttons/help.png",
        overFile = "images/buttons/help-over.png",
        width = 32,
        height = 32,
        onRelease = function()
            composer.gotoScene("scenes.about", { effect = "crossFade", time = 300 })
        end
    }
}

function sidebar:new()
    self.bar = display.newImage(group, "images/misc/sidebar/sidebar.png", true)
    self.bar.x = (real_W - (real_W - 30))
    self.bar.y = real_H * 0.5
    self.bar.width = 60
    self.bar.height = real_H - 7
    group:insert(self.bar)

    self.title = display.newImage(group, "images/misc/pause/paused.png", true)
    self.title.x = real_W * 0.5
    self.title.y = real_H * 0.5
    self.title:scale(0.5, 0.5)
    group:insert(self.title)

    self.pause_button = widget.newButton({
        defaultFile = "images/buttons/pause.png",
        overFile = "images/buttons/pause-over.png",
        width = 32,
        height = 32,
        x = real_W - real_W + 35,
        y = real_H - real_H + 35,
        onRelease = function()
            if (self.open) then
                return self:hide()
            end
            self:show()
        end
    })
    self.resume_button = widget.newButton({
        defaultFile = "images/buttons/resume.png",
        overFile = "images/buttons/resume-over.png",
        width = 32,
        height = 32,
        x = real_W - real_W + 35,
        y = real_H - real_H + 35,
        onRelease = function()
            if (self.open) then
                return self:hide()
            end
        end
    })
    self.resume_button.isVisible = false

    local button_group = display.newGroup()
    local startY = (real_H - real_H + 35)
    local offset = 3
    local spacing = startY

    for i = 1, #buttons do

        if (i == 4) then
            SoundOn = widget.newButton({
                defaultFile = buttons[i][1].defaultFile,
                overFile = buttons[i][1].overFile,
                width = buttons[i][1].width,
                height = buttons[i][1].height,
                onRelease = buttons[i][1].onRelease
            })

            SoundOff = widget.newButton({
                defaultFile = buttons[i][2].defaultFile,
                overFile = buttons[i][2].overFile,
                width = buttons[i][2].width,
                height = buttons[i][2].height,
                onRelease = buttons[i][2].onRelease
            })

            SoundOn.x = self.bar.x
            SoundOn.y = startY + button_group.height + SoundOn.height - spacing + offset
            SoundOff.x = SoundOn.x
            SoundOff.y = SoundOn.y

            SoundOn.isVisible = true
            SoundOff.isVisible = false

            spacing = spacing - SoundOn.height - 17

            button_group:insert(SoundOn)
            button_group:insert(SoundOff)
            group:insert(SoundOn)
            group:insert(SoundOff)

        else

            local button = widget.newButton({
                defaultFile = buttons[i].defaultFile,
                overFile = buttons[i].overFile,
                width = buttons[i].width,
                height = buttons[i].height,
                onRelease = buttons[i].onRelease
            })

            button.x = self.bar.x
            button.y = startY + button_group.height + button.height - spacing + offset
            spacing = spacing - button.height - 17

            button_group:insert(button)
            group:insert(button)
        end
    end

    group.y = 0
    group.x = -group.width

    return group
end

function sidebar:show()

    self.title.isVisible = true
    transition.to(group, {
        time = open_delay,
        alpha = 1,
        x = self.bar.x - 30,
        y = group.y,
        onComplete = function()
            self.open = true
        end
    })
    transition.to(self.resume_button, {
        time = open_delay,
        alpha = 1,
        x = self.bar.x + 55,
        y = real_H - real_H + 35
    })
    transition.to(self.pause_button, {
        time = open_delay,
        alpha = 1,
        x = self.bar.x + 55,
        y = real_H - real_H + 35
    })

    self.resume_button.isVisible = true
    self.pause_button.isVisible = false
end

function sidebar:hide()

    if (self.open) then

        transition.to(group, {
            time = close_delay,
            alpha = 0,
            x = -group.width,
            y = group.y,
            onComplete = function()
                self.title.isVisible = false
                self.open = false
            end
        })
        transition.to(self.resume_button, {
            time = close_delay,
            alpha = 1,
            x = real_W - real_W + 35,
            y = real_H - real_H + 35,
        })
        transition.to(self.pause_button, {
            time = close_delay,
            alpha = 1,
            x = real_W - real_W + 35,
            y = real_H - real_H + 35,
        })

        self.resume_button.isVisible = false
        self.pause_button.isVisible = true
    end
end

function sidebar:Touch()
    if (self.open) then
        self:hide()
    end
end

return sidebar