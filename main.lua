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
                    [1] = { enabled = true, params = { pts = 30, border_color = "red" } },
                    [2] = { enabled = false, params = { pts = 60, border_color = "orange" } },
                    [3] = { enabled = false, params = { pts = 90, border_color = "yellow" } },
                    [4] = { enabled = false, params = { pts = 120, border_color = "green" } },
                    [5] = { enabled = false, params = { pts = 150, border_color = "blue" } },
                    [6] = { enabled = false, params = { pts = 180, border_color = "indigo" } },
                    [7] = { enabled = false, params = { pts = 210, border_color = "violet" } },
                    [8] = { enabled = false, params = { pts = 240, border_color = "teal" } },
                    [9] = { enabled = false, params = { pts = 270, border_color = "purple" } },
                    [10] = { enabled = false, params = { pts = 300, border_color = "pink" } },
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
