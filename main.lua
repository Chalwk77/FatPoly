-- Entry point for Fat Poly, by Jericho Crosby

local json = require("json")
local composer = require('composer')
local sounds = require('libraries.sounds')

local path = system.pathForFile('stats.json', system.DocumentsDirectory)

local W = display.viewableContentWidth
local H = display.viewableContentHeight

local splash1 = display.newImageRect('/splash1.png', 836, 357)
splash1.x = W / 2
splash1.y = H / 2
splash1:scale(0.5, 0.5)
splash1.enabled = true

local splash2 = display.newImageRect('/splash2.png', 836, 357)
splash2.x = W / 2
splash2.y = H / 2
splash2:scale(0.5, 0.5)

game = { }
app_version = "1.0.0"

saveData = function()
    local file = assert(io.open(path, "w"))
    if (file) then
        file:write(json.prettify(game))
        io.close(file)
    end
end

local function Keys(event)
    local platform = system.getInfo("platformName")
    if (platform == "Android" or platform == "WinPhone" or platform == "Win") then
        if (event.phase == "down") then
            if (event.keyName == "escape" or event.keyName == "back") then
                sounds.play('onTap')
                native.showAlert("Confirm Exit", "Are you sure you want to exit?", { "Yes", "No" },
                        function(E)
                            if (E.action == 'clicked' and E.index == 1) then
                                native.requestExit()
                            end
                        end
                )
                return true
            elseif (event.keyName == 'f11') then
                if (native.getProperty('windowMode') == 'fullscreen') then
                    native.setProperty('windowMode', 'normal')
                else
                    native.setProperty('windowMode', 'fullscreen')
                end
                return true
            end
        end
    end
    return false
end

local function CheckFile()
    local F1 = io.open(path, "a")
    if (F1) then
        io.close(F1)
    end
    local content
    local F2 = io.open(path, "r")
    if (F2) then
        content = F2:read("*all")
        io.close(F2)
    end
    local F3 = assert(io.open(path, "w"))
    if (F3) then
        local data = json.decode(content)
        if (data == nil) then
            data = {
                color = "default_color",
                score = 0,
                highscore = 0,
                highscoretext = "N/A",
                levels = {
                    [1] = { true, 30, { 1, 2, 0.005 } },
                    [2] = { false, 60, { 1, 2, 0.010 } },
                    [3] = { false, 90, { 1, 2, 0.015 } },
                    [4] = { false, 120, { 1, 2, 0.025 } },
                    [5] = { false, 150, { 1, 2, 0.035 } },
                    [6] = { false, 180, { 1, 2, 0.045 } },
                    [7] = { false, 210, { 1, 2, 0.055 } },
                    [8] = { false, 240, { 1, 2, 0.070 } },
                    [9] = { false, 270, { 1, 2, 0.080 } },
                    [10] = { false, 300, { 1, 2, 0.100 } }
                }
            }
        end
        F3:write(json.prettify(data))
        io.close(F3)
        game = data
    end
end

local function Init()
    splash1:removeSelf()
    splash2:removeSelf()
    CheckFile()
    system.setIdleTimer(false)
    Runtime:addEventListener("key", Keys)
    display.setStatusBar(display.HiddenStatusBar)
    composer.gotoScene("scenes.menu")
end

if (not splash1.enabled) then
    Init()
else
    local time = 1500
    transition.to(splash2, {
        time = time,
        alpha = 0.1,
        onComplete = function(img)
            transition.to(img, {
                time = time,
                alpha = 1,
                onComplete = function()
                    Init()
                end
            })
        end
    })
end
