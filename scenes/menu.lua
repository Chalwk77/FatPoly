local composer = require('composer')
local scene = composer.newScene()

local widget = require('widget')
local sounds = require('libraries.sounds')
local physics = require("physics")
local colors = require("libraries.colors-rgb")

local menu_tPrevious
local centerX = display.contentCenterX
local centerY = display.contentCenterY

local particles = { }
local spawn_particles

local buttons = { }

local function switchScene(event)

    local sceneID = event.target.id
    local options = {
        effect = "crossFade",
        time = 200,
        params = {
            title = event.target.id
        }
    }

    sounds.play("onTap")
    composer.gotoScene(sceneID, options)
end

local function setUpDisplay(grp)

    local real_H = display.actualContentHeight
    local real_W = display.actualContentWidth

    local borders = {
        strokeWidth = 8,
        alpha = 1,
        { 0, 0, real_W, 0, }, -- top
        { real_W, real_H, 0, real_H }, -- bottom
        { 0, real_H, 0, 0 }, -- left
        { real_W, 0, real_W, real_H }, -- right
    }

    for i = 1, #borders do
        local line = display.newLine(borders[i][1], borders[i][2], borders[i][3], borders[i][4])
        line:setStrokeColor(colors.RGB("lightskyblue"))
        line.strokeWidth = borders.strokeWidth
        line.alpha = borders.alpha
        grp:insert(line)
    end

    --
    -- RENDER BACKGROUND:
    --
    local background = display.newImage("images/menu scene/menu-background.png")
    background.xScale = (background.contentWidth * 0.5) / background.contentWidth
    background.yScale = background.xScale
    background.x = centerX
    background.y = centerY - 50
    background:scale(0.6, 0.6)
    background.alpha = 0.30
    grp:insert(background)

    --
    -- RENDER GAME ICON CUBE:
    --
    local icon = display.newImage("Icon.png")
    icon.x = real_W * 0.5 - 168
    icon.y = real_H * 0.5 + 89
    icon.rotation = 45
    icon.alpha = 0.50
    icon:scale(0.2, 0.2)
    grp:insert(icon)

    --
    -- RENDER GAME TITLE LOGO:
    --
    local logo = display.newImage("images/menu scene/logo.png")
    logo.x = centerX
    logo.y = centerY - 100
    logo.alpha = 1
    logo:scale(0.4, 0.4)
    grp:insert(logo)

    ------------------
    --- START BUTTON
    ------------------
    local startBtn = widget.newButton({
        id = "scenes.chooselevel",
        defaultFile = "images/buttons/start.png",
        overFile = "images/buttons/start-over.png",
        onRelease = switchScene
    })

    startBtn.x = centerX
    startBtn.y = centerY
    startBtn.alpha = 1
    startBtn:scale(5, 5)
    grp:insert(startBtn)

    local function StartButtonAnimate()
        local scale = function()
            transition.to(startBtn, { time = 450, alpha = 0.25, xScale = 0.4, yScale = 0.6, onComplete = StartButtonAnimate })
        end
        transition.to(startBtn, { time = 450, alpha = 1, xScale = 0.6, yScale = 0.6, onComplete = scale })
    end

    StartButtonAnimate()

    --------------------
    --- OPTIONS BUTTON
    --------------------
    local optionsBtn = widget.newButton({
        id = "scenes.options",
        defaultFile = "images/buttons/options.png",
        overFile = "images/buttons/options-over.png",
        onRelease = switchScene
    })

    optionsBtn.x = centerX
    optionsBtn.y = centerX + centerY - 180
    optionsBtn.alpha = 1
    optionsBtn:scale(1, 0.70)
    grp:insert(optionsBtn)
    buttons[#buttons + 1] = optionsBtn

    ------------------
    --- ABOUT BUTTON
    ------------------
    local aboutBtn = widget.newButton({
        id = "scenes.about",
        defaultFile = "images/buttons/about.png",
        overFile = "images/buttons/about-over.png",
        onRelease = switchScene
    })

    aboutBtn.x = centerX
    aboutBtn.y = optionsBtn.y + 45
    aboutBtn:scale(1, 0.70)
    grp:insert(aboutBtn)
    buttons[#buttons + 1] = aboutBtn

    for i = 1, #buttons do
        local x1 = buttons[i].x - buttons[i].width / 2
        local x2 = buttons[i].x + buttons[i].width / 2
        local offset = 17
        local height = buttons[i].y + offset
        local line = display.newLine(x1, height, x2, height)
        line:setStrokeColor(colors.RGB("white"))
        line.strokeWidth = 1
        line.isVisible = false
        buttons[i].line = line
    end
end

function scene:create()
    setUpDisplay(self.view)
    --sounds.playStream('menu_music')
end

function scene:show(event)

    local grp = self.view
    local phase = event.phase
    if (phase == "will") then
        CheckForUpdates(grp)
        spawn_particles = true
    elseif (phase == "did") then
        menu_tPrevious = system.getTimer()
        Runtime:addEventListener("mouse", Hover)
        Runtime:addEventListener("enterFrame", AnimateMenu)
        SpawnObject("food", 0, randomSpeed())
        SpawnObject("food", 0, -randomSpeed())
        SpawnObject("food", randomSpeed(), 0)
        SpawnObject("food", -randomSpeed(), 0)
        SpawnObject("poison", 0, randomSpeed())
        SpawnObject("poison", 0, -randomSpeed())
        SpawnObject("poison", randomSpeed(), 0)
        SpawnObject("poison", -randomSpeed(), 0)
        SpawnObject("reward", randomSpeed(), 0)
    end
end

function scene:hide(event)
    local phase = event.phase
    if (phase == "will") then
        spawn_particles = false

        for i = 1, #buttons do
            buttons[i].line.isVisible = false
        end
        for _, v in pairs(particles) do
            v:removeSelf()
        end
        particles = { }

        Runtime:removeEventListener("mouse", Hover)
        Runtime:removeEventListener("enterFrame", AnimateMenu)
    elseif (phase == "did") then
        -- N/A
    end
end

function Hover(m)
    for i = 1, #buttons do
        local dist = (m.x - buttons[i].x) ^ 2 + (m.y - buttons[i].y) ^ 2
        if (dist <= 500) then
            buttons[i].line.isVisible = true
        else
            buttons[i].line.isVisible = false
        end
    end
end

function randomSpeed()
    return math.random(1, 2) / 10 * 1
end

function SpawnObject(objectType, xVelocity, yVelocity)

    if (spawn_particles) then

        local Object
        local sizeXY = math.random(10, 20)
        local startX, startY

        if (xVelocity == 0) then
            startX = math.random(sizeXY, display.contentWidth - sizeXY)
        end
        if (xVelocity < 0) then
            startX = display.contentWidth
        end
        if (xVelocity > 0) then
            startX = -sizeXY
        end
        if (yVelocity == 0) then
            startY = math.random(sizeXY, display.contentHeight - sizeXY)
        end
        if (yVelocity < 0) then
            startY = display.contentHeight
        end
        if (yVelocity > 0) then
            startY = -sizeXY
        end

        if (objectType == "food") or (objectType == "poison") then
            Object = display.newRect(startX, startY, sizeXY, sizeXY)
            Object.sizeXY = sizeXY
        elseif (objectType == "reward" or objectType == "penalty") then
            Object = display.newCircle(startX, startY, 15)
            Object.sizeXY = 0
            AnimatePowerUp(Object)
        end

        if (objectType == "poison") then
            Object:setFillColor(colors.RGB("red"))
        elseif (objectType == "food") then
            Object:setFillColor(colors.RGB("green"))
        elseif (objectType == "reward") then
            Object:setFillColor(colors.RGB("purple"))
        end

        Object.x = startX
        Object.y = startY
        Object.alpha = 0.25
        Object.objectType = objectType
        Object.xVelocity = xVelocity
        Object.yVelocity = yVelocity
        Object.isFixedRotation = true

        Object:setStrokeColor(colors.RGB("white"))
        Object.strokeWidth = 1

        local collisionFilter = { categoryBits = 4, maskBits = 2 }
        local body = { filter = collisionFilter, isSensor = true }
        physics.addBody(Object, body)

        table.insert(particles, Object)
    end
end

function AnimateMenu(event)
    local delta_time = (event.time - menu_tPrevious)
    menu_tPrevious = event.time

    if (particles) then
        --
        for key, Object in pairs(particles) do

            local xDelta = Object.xVelocity * delta_time
            local yDelta = Object.yVelocity * delta_time
            local xPos = xDelta + Object.x
            local yPos = yDelta + Object.y
            Object:translate(xDelta, yDelta)

            -- Check if object is off screen:
            local off_screen = {
                yPos > display.contentHeight + Object.sizeXY, yPos < -Object.sizeXY,
                xPos > display.contentWidth + Object.sizeXY, xPos < -Object.sizeXY,
            }

            for i = 1, #off_screen do
                if (off_screen[i]) then
                    Object.isVisible = false
                end
            end

            if (not Object.isVisible) then

                local xVelocity, yVelocity = 0, 0
                if (Object.objectType == "food" or Object.objectType == "poison") then
                    --
                    if (Object.xVelocity < 0) then
                        xVelocity = -randomSpeed()
                    elseif (Object.xVelocity > 0) then
                        xVelocity = randomSpeed()
                    end
                    if (Object.yVelocity < 0) then
                        yVelocity = -randomSpeed()
                    elseif (Object.yVelocity > 0) then
                        yVelocity = randomSpeed()
                    end
                    SpawnObject(Object.objectType, xVelocity, yVelocity)
                else

                    local sign = { 1, -1 }
                    if (math.random(1, 2) == 1) then
                        xVelocity = randomSpeed() * sign[math.random(1, 2)]
                    else
                        yVelocity = randomSpeed() * sign[math.random(1, 2)]
                    end
                    local item
                    if (Object.objectType == "reward") then
                        item = "penalty"
                    else
                        item = "reward"
                    end
                    local Spawn = function()
                        return SpawnObject(item, xVelocity, yVelocity)
                    end
                    timer.performWithDelay(math.random(6, 12) * 1000, Spawn, 1)
                end

                Object:removeSelf()
                table.remove(particles, key)
            end
        end
    end
end

function AnimatePowerUp(Obj)
    local scaleUp = function()
        transition.to(Obj, { time = 255, alpha = 0.25, xScale = 0.7, yScale = 0.7, onComplete = AnimatePowerUp })
    end
    transition.to(Obj, { time = 255, alpha = 0.25, xScale = 1, yScale = 1, onComplete = scaleUp })
end

function CheckForUpdates(grp)
    local http = require("socket.http")
    local current_version = system.getInfo("appVersionString")
    if (current_version == "") then
        current_version = app_version
    end
    local latest_version, txt = http.request("https://pastebin.com/raw/Rw7GXN8z"), { }
    if (latest_version) then
        if (current_version == latest_version) then
            txt = { "Game update to date! Current Version: " .. current_version, false }
        elseif (current_version < latest_version) then
            txt = { "Game Update available [Current Version: " .. current_version .. "] - [Version Available: " .. latest_version .. "]", true }
        end
    end
    txt[1] = txt[1] or "Current Version: " .. current_version
    local game_version = display.newText(txt[1], display.viewableContentWidth / 2, display.viewableContentHeight / 2, native.systemFontBold, 10)
    game_version:setFillColor(1, 0.9, 0.5)
    game_version.x = display.contentCenterX
    game_version.y = display.contentCenterX + display.contentCenterY - 90
    game_version.alpha = 0.50

    grp:insert(game_version)

    if (txt[2]) then
        local function onTextClick(event)
            if (event.phase == "began") then
                sounds.play('onTap')
                native.showAlert("Download Latest Update", "Would you like to download the latest update?", { "Yes", "No" },
                        function(e)
                            if (e.action == 'clicked' and e.index == 1) then
                                system.openURL("https://play.google.com/store/apps/details?id=com.gmail.crosby227.jericho.ParticlePlex&hl=en")
                            end
                        end
                )
            end
            return true
        end
        game_version:addEventListener("touch", onTextClick)
    end
end

---------------------------------------------------------------
-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)

physics.start()
physics.setScale(60)
physics.setGravity(0, 0)

return scene