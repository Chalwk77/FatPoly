-- Entry point for Fat Poly, by Jericho Crosby

local composer = require('composer')
local sounds = require('libraries.sounds')
local json = require("libraries.json")

game = { }
stats_file = "stats.json"
app_version = "1.0.0"

-- Global function to animate Power ups in the Menu/Play scenes
AnimatePowerUp = function(Obj)
    local scaleUp = function()
        transition.to(Obj, { time = 255, alpha = 1, xScale = 0.7, yScale = 0.7, onComplete = AnimatePowerUp })
    end
    transition.to(Obj, { time = 255, alpha = 1, xScale = 1, yScale = 1, onComplete = scaleUp })
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
                highscore = 0,
                levels = {
                    [1] = { enabled = true, requirements = { 30 } },
                    [2] = { enabled = false, requirements = { 60 } },
                    [3] = { enabled = false, requirements = { 90 } },
                    [4] = { enabled = false, requirements = { 120 } },
                    [5] = { enabled = false, requirements = { 150 } },
                    [6] = { enabled = false, requirements = { 180 } },
                    [7] = { enabled = false, requirements = { 210 } },
                    [8] = { enabled = false, requirements = { 240 } },
                    [9] = { enabled = false, requirements = { 270 } },
                    [10] = { enabled = false, requirements = { 300 } },
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
