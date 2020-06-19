local gameIsOver
local rewardLabel
local penaltyLabel
local rewardBar
local penaltyBar
local scoreLabel
local highScoreLabel
local revolving_image
local levelLabel
local player

local starting_health = 30
local max_player_size = 65

local pW = 20
local pH = 20

local spawnConstraint = "no"
local speedFactor = 1
local speed = { }

local score = 0
local tPrevious = system.getTimer()

local borders = { }
local objects = { }
local health = { }
health.hearts = { }
health.bar = require('modules.healthbar')

local widget = require('widget')
local pause = require("modules.pause")
local json = require("libraries.json")
local physics = require("physics")
local sounds = require('libraries.sounds')
local colors = require('classes.colors-rgb')
local composer = require('composer')
local scene = composer.newScene()

local collision_dimensions = {
    { w = 191, h = 180 },
    { w = 203, h = 185 },
    { w = 196, h = 175 },
}

local health_params
local function initHealthParams()
    health_params = {
        [1] = { 25, 30, "health1", "black" },
        [2] = { 19, 24, "health2", "black" },
        [3] = { 13, 18, "health3", "black" },
        [4] = { 7, 12, "health4", "white" },
        [5] = { 1, 6, "health5", "white" },
        txt = "IIIIIIIIIIIIIIIIIIIIIIIIIIIIII"
    }
end

local lightning_effect = { }
local function LoadLightningEffects()
    local dir = 'images/particle effects/combo particles/'
    for i = 1, 3 do
        local p = display.newImageRect(dir .. i .. '.png', collision_dimensions[i].w, collision_dimensions[i].h)
        p.alpha = 0
        p.isVisible = false
        p:scale(0.5, 0.5)
        lightning_effect[i] = p
    end
end

--
-- COMMON SCREEN COORDINATES:
--
local ContentW = display.viewableContentWidth
local ContentH = display.viewableContentHeight

local function UpdateStats()
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

local function setUpDisplay(grp)

    display.setStatusBar(display.HiddenStatusBar)
    pause:new()
    LoadLightningEffects()

    local background = display.newImage(grp, "images/backgrounds/background.png")
    background.xScale = (background.contentWidth / background.contentWidth)
    background.yScale = background.xScale
    background.x = display.contentWidth / 2
    background.y = display.contentHeight / 2
    background.alpha = 0.30
    background:addEventListener("touch", onTouch)
    grp:insert(background)

    local CX = ContentW / 2
    local CY = (ContentH / 2)

    local RePen = { 
        x = CX,
        y = CY + CY - 28,
        strokeWidth = 2,
        strokeColor = colors.RGB("green")
    }
    
    revolving_image = display.newImageRect('images/loading/loading2.png', 64, 64)
    revolving_image.x = 0
    revolving_image.y = 0
    revolving_image.alpha = 0.50
    revolving_image.isVisible = false
    grp:insert(revolving_image)

    rewardLabel = display.newText("reward", CX, CY, native.systemFontBold, 18)
    rewardLabel:setTextColor(colors.RGB("green"))
    rewardLabel.x = RePen.x
    rewardLabel.y = RePen.y
    rewardLabel.alpha = 1
    rewardLabel.isVisible = false
    grp:insert(rewardLabel)

    rewardBar = display.newRect(100, CX, CY, 30)
    rewardBar:setFillColor(colors.RGB("white"))
    rewardBar.x = RePen.x
    rewardBar.y = RePen.y
    rewardBar.alpha = 0.20
    rewardBar.strokeWidth = RePen.strokeWidth
    rewardBar:setStrokeColor(RePen.strokeColor)
    rewardBar.isVisible = false
    grp:insert(rewardBar)

    penaltyLabel = display.newText("penalty", CX, CY, native.systemFontBold, 18)
    penaltyLabel:setTextColor(colors.RGB("red"))
    penaltyLabel.x = RePen.x
    penaltyLabel.y = RePen.y
    penaltyLabel.alpha = 1
    penaltyLabel.isVisible = false
    grp:insert(penaltyLabel)

    penaltyBar = display.newRect(100, CX, CY, 30)
    penaltyBar:setFillColor(colors.RGB("white"))
    penaltyBar.x = RePen.x
    penaltyBar.y = RePen.y
    penaltyBar.alpha = 0.20
    penaltyBar.strokeWidth = RePen.strokeWidth
    penaltyBar:setStrokeColor(RePen.strokeColor)
    penaltyBar.isVisible = false
    grp:insert(penaltyBar)

    scoreLabel = display.newText(tostring(score), CX, CY, native.systemFontBold, 120)
    scoreLabel:setFillColor(colors.RGB("white"))
    scoreLabel.x = CX
    scoreLabel.y = CY
    scoreLabel.alpha = 0.20
    scoreLabel.isVisible = false
    grp:insert(scoreLabel)

    highScoreLabel = display.newText("Highest Score: " .. tostring(game.highscore), CX, CY, native.systemFontBold, 15)
    highScoreLabel:setFillColor(colors.RGB("white"))
    highScoreLabel.x = CX
    highScoreLabel.y = CY - CY + 20
    highScoreLabel.alpha = 0.20
    highScoreLabel.isVisible = false
    grp:insert(highScoreLabel)

    levelLabel = display.newText("", ContentW / 2, ContentH / 2, native.systemFontBold, 24)
    levelLabel:setFillColor(colors.RGB("white"))
    levelLabel.x = CX + CX - 70
    levelLabel.y = CY - 70
    levelLabel.alpha = 0.20
    levelLabel.isVisible = false
    grp:insert(levelLabel)

    local topY = display.screenOriginY
    local bottomY = (display.contentHeight - display.screenOriginY)
    local leftX = display.screenOriginX
    local rightX = (display.contentWidth - display.screenOriginX)
    local screenW = (rightX - leftX)

    local border = {
        top = { leftX + screenW, topY, rightX - screenW, topY },
        bottom = { leftX + screenW, bottomY, rightX - screenW, bottomY },
        left = { 0, topY, 0, bottomY },
        right = { leftX + screenW, topY, leftX + screenW, bottomY }
    }

    local i = 1
    for k, _ in pairs(border) do
        local line = display.newLine(border[k][1], border[k][2], border[k][3], border[k][4])
        line.strokeWidth = 15
        line.alpha = 0.50
        line:setStrokeColor(colors.RGB("red"))
        grp:insert(line)
        borders[i] = line
        i = i + 1
    end
end

function scene:create(event)
    physics.start()
    physics.setScale(60)
    physics.setGravity(0, 0)
    setUpDisplay(self.view)
end

function scene:show(event)
    local phase = event.phase
    if (phase == "will") then

        SetLevelSpeed()
        initHealthParams()

        score = 0
        scoreLabel.text = tostring(score)
        gameIsOver = false

        -- Create a new player:
        player = createPlayer(ContentW / 2, ContentH / 2, pW, pH, 0, true)
        speedFactor = 1

        local rate = 500
        for i = 1, 5 do
            health.hearts[i] = display.newImageRect("images/backgrounds/heart" .. tostring(i) .. ".png", 12, 12)
            health.hearts[i].x = ContentW / 2 + 170
            health.hearts[i].y = ContentH / 2 - 120
            health.hearts[i].alpha = 0.75
            health.hearts[i].isVisible = false
            health.hearts[i].rate = rate
            rate = rate - 100
        end

        -- Initial player health:
        health.amount = starting_health

    elseif (phase == "did") then

        -- Spawn initial food objects
        Spawn("food", 0, randomSpeed())
        Spawn("food", 0, -randomSpeed())
        Spawn("food", randomSpeed(), 0)
        Spawn("food", -randomSpeed(), 0)
        Spawn("poison", 0, randomSpeed())
        Spawn("poison", 0, -randomSpeed())
        Spawn("poison", randomSpeed(), 0)
        Spawn("poison", -randomSpeed(), 0)
        Spawn("reward", randomSpeed(), 0)

        -- Start hearts animation:
        HeartsAnimation()

        -- Show Score labels:
        scoreLabel.isVisible = true
        levelLabel.isVisible = true
        highScoreLabel.isVisible = true

        -- Play Background music: (loop)
        --sounds.playStream('game_music')
    end
end

function scene:hide(event)

end

function scene:destroy(event)

end

local function switchScene(Scene)
    local options = { effect = "crossFade", time = 200, params = { title = Scene } }
    composer.gotoScene(Scene, options)
end

function createPlayer(x, y, width, height, rotation, visible)
    local playerCollisionFilter = { categoryBits = 2, maskBits = 5 }
    local playerBodyElement = { filter = playerCollisionFilter }
    local player = display.newRect(x, y, width, height)
    player.isBullet = true
    player.objectType = "player"
    player.rotation = rotation
    player.isVisible = visible
    player.resize = false
    player.isSleepingAllowed = false
    player.x = x
    player.y = y
    player.anchorX = 0.5
    player.anchorY = 0.5
    player:setFillColor(colors.RGB(game.color))
    player:setStrokeColor(colors.RGB("white"))
    player.strokeWidth = 1.2
    physics.addBody(player, "dynamic", playerBodyElement)
    return player
end

local function randomSpeed()
    local S = math.random(speed.min, speed.max)
    return (S / 10) * speedFactor + (speed.offset)
end

local function calculateNewVelocity(t)
    for _, object in pairs(t) do
        object.xVelocity = object.xVelocity * speedFactor
        object.yVelocity = object.yVelocity * speedFactor
    end
end

local function gameOver()
    gameIsOver = true

    -- Hide Reward|Penalty (bars & text)
    rewardBar.isVisible = false
    rewardLabel.isVisible = false
    penaltyBar.isVisible = false
    penaltyLabel.isVisible = false

    player.isVisible = false

    -- HIDE: health bar & hearts --
    health.bar.isVisible = false
    for i = 1, 5 do
        health.hearts[i].isVisible = false
    end

    -- Remove objects:
    for _, v in pairs(objects) do
        v:removeSelf()
    end
    objects = { }

    -- Update scores:
    if (score > game.highscore) then
        game.highscore = score
        sounds.play("onWin")
    else
        sounds.play("onFailed")
    end

    UpdateStats()

    -- Switch to GAME OVER SCENE:
    switchScene("scenes.gameover")
end

function ConstrainToScreen(object)
    if object.x < object.width - object.width / 2 then
        object.x = (object.width / 2)
    end
    if object.x > ContentW - object.width + object.width / 2 then
        object.x = (ContentW - object.width / 2)
    end
    if object.y < object.height - object.height / 2 then
        object.y = (object.height / 2)
    end
    if object.y > ContentH - object.height + object.height / 2 then
        object.y = (ContentH - object.height / 2)
    end
end

local mouse = { }
local function MouseOver(event)
    if (gameIsOver) then
        return
    end
    mouse.x, mouse.y = event.x, event.y
end

function intersecting(mX, mY, pX, pY)
    local w, h = player.width, player.height
    if ((mX > pX) and (mX < pX + w) and (mY > pY) and (mY < pY + h)) then
        return true
    end
end

function onTouch(event)
    if (gameIsOver) then
        return
    elseif (event.phase == "began") then
        player.isFocus = true
        player.x0 = event.x - player.x
        player.y0 = event.y - player.y
    elseif (player.isFocus) then
        if (event.phase == "moved") then
            player.x = event.x - player.x0
            player.y = event.y - player.y0
            ConstrainToScreen(player)
        elseif (phase == "ended") or (phase == "cancelled") then
            player.isFocus = false
        end
    end
    return true
end

function Spawn(objectType, xVelocity, yVelocity)
    if (gameIsOver) then
        return
    end

    local Object
    local sizeXY = math.random(5, 20)
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
        local Size = math.random(10, 15)
        Object = display.newCircle(startX, startY, Size)
        Object.sizeXY = 0
    end

    if (Object) then

        if (objectType == "poison") then
            Object:setFillColor(colors.RGB("red"))
        elseif (objectType == "food") then
            Object:setFillColor(colors.RGB("green"))
        elseif (objectType == "reward") then
            Object:setFillColor(colors.RGB("purple"))
        end

        Object.x = startX
        Object.y = startY
        Object.alpha = (gameIsOver and 20 or 255)
        Object.objectType = objectType
        Object.xVelocity = xVelocity
        Object.yVelocity = yVelocity
        Object.isFixedRotation = true

        Object.strokeWidth = 1
        Object:setStrokeColor(colors.RGB("white"))

        local collisionFilter = { categoryBits = 4, maskBits = 2 }
        local body = { filter = collisionFilter, isSensor = true }
        physics.addBody(Object, body)

        table.insert(objects, Object)
    end
end

local function gameSpecial(objectType)
    local r = math.random(1, 4)
    
    revolving_image.rotation = 0
    
    if (objectType == "reward") then
        if (r == 1) then
            player.width = (player.width / 2)
            player.height = (player.height / 2)
            if (player.width < pW) and (player.height < pH) then
                player.width = pW
                player.height = pH
            end
            player.resize = true
            rewardLabel.text = "weight loss"
            rewardLabel.isVisible = true
            local Hide = function()
                rewardLabel.isVisible = false
            end
            transition.to(rewardLabel, { time = 1000, delay = 2000, onComplete = Hide })
            local oW = player.width
            local oH = player.height
            transition.to(player, {
                time = 3000, 
                delay = 3000,
                width = (oW - oW/2), 
                height = (oH - oH/2), 
                onComplete = function(p)
                    p.width = oW
                    p.height = oH
                end
            })
        elseif (r == 2) then
            rewardLabel.text = "all you can eat"
            spawnConstraint = "allyoucaneat"
            rewardBar.isVisible = true
            rewardLabel.isVisible = true
            revolving_image.isVisible = true
            local closure = function()
                spawnConstraint = "no"
                rewardBar.width = 280
                rewardBar.isVisible = false
                rewardLabel.isVisible = false
                revolving_image.isVisible = false
            end
            transition.to(rewardBar, { time = 5000, width = 0, onComplete = closure })
            transition.to(revolving_image, { time = 5000, rotation = 360 })
        elseif (r == 3) then
            if (speedFactor ~= 1) then
                return
            end
            rewardLabel.text = "traffic jam"
            rewardBar.isVisible = true
            rewardLabel.isVisible = true
            revolving_image.isVisible = true
            transition.to(rewardLabel, { time = 500, delay = 4500 })
            speedFactor = 0.5
            calculateNewVelocity(objects)
            local closure = function()
                speedFactor = 2
                calculateNewVelocity(objects)
                speedFactor = 1
                rewardBar.width = 280
                rewardBar.isVisible = false
                rewardLabel.isVisible = false
                revolving_image.isVisible = false
            end
            transition.to(rewardBar, { time = 5000, width = 0, onComplete = closure })
            transition.to(revolving_image, { time = 5000, rotation = 360 })
        elseif (r == 4) then
            rewardLabel.txt = "+25 health"
            rewardLabel.isVisible = true
            health.amount = health.amount + 5
            if (health.amount > starting_health) then
                health.amount = starting_health
            end
            local Hide = function()
                rewardLabel.isVisible = false
            end
            transition.to(rewardLabel, { time = 1000, delay = 3000, onComplete = Hide })
        end
    elseif (objectType == "penalty") then
        if (r == 1) then
            player.width = (player.width + player.width / 3)
            player.height = (player.height + player.height / 3)
            if (player.width > max_player_size and player.height > max_player_size) then
                player.width = max_player_size
                player.height = max_player_size
            end
            player.resize = true
            penaltyLabel.text = "weight gain"
            penaltyLabel.isVisible = true
            local Hide = function()
                penaltyLabel.isVisible = false
            end
            transition.to(penaltyLabel, { time = 1000, delay = 3000, onComplete = Hide })
            local oW = player.width
            local oH = player.height
            transition.to(player, {
                time = 3000, 
                delay = 3000,
                width = (oW + oW/2), 
                height = (oH + oH/2), 
                onComplete = function(p)
                    p.width = oW
                    p.height = oH
                end
            })
        elseif (r == 2) then
            penaltyLabel.text = "food contaminated"
            transition.to(penaltyLabel, { time = 500, delay = 4500 })
            penaltyBar.isVisible = true
            penaltyLabel.isVisible = true
            revolving_image.isVisible = true
            spawnConstraint = "foodcontaminated"
            local closure = function()
                spawnConstraint = "no"
                penaltyBar.width = 280
                penaltyBar.isVisible = false
                penaltyLabel.isVisible = false
                revolving_image.isVisible = false
            end
            transition.to(penaltyBar, { time = 5000, width = 0, onComplete = closure })
            transition.to(revolving_image, { time = 5000, rotation = 360 })
        else
            if (speedFactor ~= 1) then
                return
            end
            penaltyLabel.text = "rush hour"
            transition.to(penaltyLabel, { time = 500, delay = 4500 })
            speedFactor = 2
            calculateNewVelocity(objects)
            penaltyBar.isVisible = true
            revolving_image.isVisible = true
            penaltyLabel.isVisible = true
            local closure = function()
                speedFactor = 0.5
                calculateNewVelocity(objects)
                speedFactor = 1
                penaltyBar.width = 280
                penaltyBar.isVisible = false
                penaltyLabel.isVisible = false
                revolving_image.isVisible = false
            end
            transition.to(penaltyBar, { time = 5000, width = 0, onComplete = closure })
            transition.to(revolving_image, { time = 5000, rotation = 360 })
        end
    end
end

local function OnTick(event)

    if (gameIsOver) then
        return
    end

    if (player) then
        if (player.resize) then

            local weight_percentage = 1.900
            local X, Y = player.x, player.y
            local W = (player.width - weight_percentage)
            local H = (player.height - weight_percentage)
            local player2 = createPlayer(X, Y, W, H, player.rotation, player.isVisible)
            if (player.isFocus) then
                player2.isFocus = player.isFocus
                player2.x0 = player.x0
                player2.y0 = player.y0
            end
            player2.resize = false
            player:removeSelf()
            player = player2
        end


        --[[
        -- Call mouse intersect collision function:
        --
        if (mouse.x and mouse.y) then
            local hovering = intersecting(mouse.x, mouse.y, player.x, player.y)
            if (hovering) then
                player:setStrokeColor(0/255, 255/255, 0/255)
            else
                player:setStrokeColor(colors.RGB("white"))
            end
        end
        --
        --]]


        --
        -- Display Health Bar:
        --
        for i = 1, #health_params do
            local min = health_params[i][1]
            local max = health_params[i][2]
            if (health.amount >= min) and (health.amount <= max) then
                health.hearts[i].isVisible = true
                health.hearts.current = i
            else
                health.hearts[i].isVisible = false
            end
        end
        local txt = health_params.txt
        local Tab = health_params[health.hearts.current]
        health.bar.new(txt, Tab)

        --
        -- Display Level Label:
        --
        local lvl = game.current_level
        local required = game.levels[lvl][2]
        levelLabel.text = "Level: " .. lvl .. "/" .. required
        
        if (revolving_image.isVisible) then
            revolving_image.x = player.x
            revolving_image.y = player.y
        end
    end

    local tDelta = event.time - tPrevious
    tPrevious = event.time

    for key, object in pairs(objects) do

        local xDelta = object.xVelocity * tDelta
        local yDelta = object.yVelocity * tDelta
        local xPos = xDelta + object.x
        local yPos = yDelta + object.y
        object:translate(xDelta, yDelta)

        local off_screen = {
            yPos > (display.contentHeight + object.sizeXY),
            yPos < -object.sizeXY,
            xPos > (display.contentWidth + object.sizeXY),
            xPos < -object.sizeXY,
        }

        for i = 1, #off_screen do
            if (off_screen[i]) then
                object.isVisible = false
            end
        end

        if (not object.isVisible) then
            local xVelocity = 0
            local yVelocity = 0
            if (object.objectType == "food") or (object.objectType == "poison") then
                if (object.xVelocity < 0) then
                    xVelocity = -randomSpeed()
                elseif (object.xVelocity > 0) then
                    xVelocity = randomSpeed()
                end
                if (object.yVelocity < 0) then
                    yVelocity = -randomSpeed()
                elseif (object.yVelocity > 0) then
                    yVelocity = randomSpeed()
                end
                Spawn(object.objectType, xVelocity, yVelocity)
            else
                local sign = { 1, -1 }
                if (math.random(1, 2) == 1) then
                    xVelocity = randomSpeed() * sign[math.random(1, 2)]
                else
                    yVelocity = randomSpeed() * sign[math.random(1, 2)]
                end
                local Item
                if (object.objectType == "reward") then
                    Item = "penalty"
                else
                    Item = "reward"
                end
                local SpawnBonus = function()
                    return Spawn(Item, xVelocity, yVelocity)
                end
                timer.performWithDelay(math.random(6, 12) * 1000, SpawnBonus, 1)
            end
            object:removeSelf()
            table.remove(objects, key)
        end
    end
end

local function onCollision(event)

    if (gameIsOver) then
        return
    end
    if (event.phase == "began") then
        local ot, o
        if (event.object1.objectType == "player") then
            o = event.object2
            ot = event.object2.objectType
        else
            o = event.object1
            ot = event.object1.objectType
        end
        if ("food" == ot and spawnConstraint == "no") or (spawnConstraint == "allyoucaneat") then
            sounds.play("onPickup")
            score = score + 1
            scoreLabel.text = tostring(score)
            if (player.width < max_player_size) then
                player.resize = true
            end
            o.isVisible = false

            local R = math.random(0, 255)
            local G = math.random(0, 255)
            local B = math.random(0, 255)
            for i = 1, 4 do
                borders[i]:setStrokeColor(R / 255, G / 255, B / 255, 1)
            end

            local current_level = game.current_level
            local required = game.levels[current_level][2]

            if (score == required) then

                -- Update level:
                local new_level = current_level + 1
                if (new_level == #game.levels) then
                    new_level = #game.levels
                end
                game.current_level = new_level
                game.levels[new_level][1] = true
                --

                -- Play level-up sound effect:
                sounds.play("onLevelup")
                --

                -- Update food speed:
                SetLevelSpeed()
                --

                -- Show lightning effect:
                ShowLightning(player.x, player.y)
                --
            end

        elseif (ot == "poison") or (spawnConstraint == "foodcontaminated") then
            sounds.play("onDamage")
            health.amount = health.amount - 1

            local txt = health_params.txt
            local chars = {}
            for i = 1, string.len(txt) do
                chars[i] = string.sub(txt, i, i)
            end

            local replacement = ""
            for i = 1, #chars do
                if (i < #chars) then
                    replacement = replacement .. chars[i]
                end
            end
            health_params.txt = replacement

            if (health.amount < 1) then
                gameOver()
            end
        elseif (ot == "reward") or (ot == "penalty") then
            sounds.play("onPowerup")
            o.isVisible = false
            gameSpecial(ot)
        end
    end
end

function SetLevelSpeed()
    local lvl = game.current_level
    local T = game.levels[lvl][3]
    speed.min, speed.max = T[1], T[2]
    speed.offset = T[3]
end

function HeartsAnimation()
    local obj = health.hearts[health.hearts.current]
    local scaleUp = function()
        transition.to(obj, {
            time = obj.rate,
            alpha = 0.20,
            xScale = 1,
            yScale = 1,
            onComplete = HeartsAnimation
        })
    end
    transition.to(obj, {
        time = 100,
        alpha = 1,
        xScale = 2,
        yScale = 2,
        onComplete = scaleUp
    })
end

function ShowLightning(x, y)
    local i = math.random(1, 3)
    lightning_effect[i].isVisible = true
    lightning_effect[i].x = x
    lightning_effect[i].y = y
    lightning_effect[i].alpha = 1
    transition.to(lightning_effect[i], {
        time = 50, xScale = 1, yScale = 1, alpha = 0,
        onComplete = function(object)
            object.isVisible = false
        end
    })
end

Runtime:addEventListener("collision", onCollision)
Runtime:addEventListener("enterFrame", OnTick)

--
-- todo: Finish trig calculations for screen coordinates:
--Runtime:addEventListener("mouse", MouseOver)
--------------------------------------------------------

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
