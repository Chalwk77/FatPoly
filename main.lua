-- Entry point for Fat Poly, by Jericho Crosby

local composer = require('composer')
local sounds = require('libraries.sounds')
local json = require("libraries.json")

local stats_file = "stats.json"

game = { }
app_version = "1.0.0"

-- Global function to animate Power ups in the Menu/Play scenes
AnimatePowerUp = function(Obj)
    local scaleUp = function()
        transition.to(Obj, { time = 255, alpha = 1, xScale = 0.7, yScale = 0.7, onComplete = AnimatePowerUp })
    end
    transition.to(Obj, { time = 255, alpha = 1, xScale = 1, yScale = 1, onComplete = scaleUp })
end

loadStats = function()
    local path = system.pathForFile(stats_file, system.DocumentsDirectory)
    local content
    local file = io.open(path, "r")
    if (file ~= nil) then
        content = file:read("*all")
        io.close(file)
    end
    return json:decode(content)
end

UpdateStats = function()
    local path = system.pathForFile(stats_file, system.DocumentsDirectory)
    local content
    local file = io.open(path, "r")
    if (file ~= nil) then
        content = file:read("*all")
        io.close(file)
    end
    local file = assert(io.open(path, "w"))
    if (file) then
        file:write(json:encode_pretty(game))
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
                        function(event)
                            if (event.action == 'clicked' and event.index == 1) then
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

function CheckFile()
    local path = system.pathForFile(stats_file, system.DocumentsDirectory)
    local file = io.open(path, "a")
    if (file ~= nil) then
        io.close(file)
    end
    local content
    local file = io.open(path, "r")
    if (file ~= nil) then
        content = file:read("*all")
        io.close(file)
    end
    local file = assert(io.open(path, "w"))
    if (file) then
        local data = json:decode(content)
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
        file:write(json:encode_pretty(data))
        io.close(file)
    end
end

CheckFile()

system.setIdleTimer(false)
Runtime:addEventListener("key", Keys)
display.setStatusBar(display.HiddenStatusBar)

composer.gotoScene("scenes.menu")
