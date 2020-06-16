local gameIsOver
local rewardLabel
local penaltyLabel
local rewardBar
local penaltyBar
local scoreLabel
local highScoreLabel
local player
local spawnConstraint = "no"
local speedFactor = 1

local score = 0
local highscore

local tPrevious = system.getTimer()

local objects = { }

local health = { }
health.hearts = { }
health.bar = require('modules.healthbar')

local json = require("libraries.json")
local physics = require("physics")
local sounds = require('libraries.sounds')
local colors = require('classes.colors-rgb')
local composer = require('composer')
local scene = composer.newScene()


--
-- COMMON SCREEN COORDINATES:
--
local ContentW = display.viewableContentWidth
local ContentH = display.viewableContentHeight

local function GetHighScore()
    local path = system.pathForFile(stats_file, system.DocumentsDirectory)

    local content
    local file = io.open(path, "r")
    if (file ~= nil) then
        content = file:read("*all")
        io.close(file)
    end

    return json:decode(content).highscore
end

local function SaveHighScore()
    local path = system.pathForFile(stats_file, system.DocumentsDirectory)

    local content
    local file = io.open(path, "r")
    if (file ~= nil) then
        content = file:read("*all")
        io.close(file)
    end

    local file = assert(io.open(path, "w"))
    if (file) then
        local data = json:decode(content)
        data.highscore = score
        file:write(json:encode_pretty(data))
        io.close(file)
    end
end

local function setUpDisplay(grp)

    display.setStatusBar(display.HiddenStatusBar)

    local background = display.newImage(grp, "images/backgrounds/background.png")
    background.xScale = (background.contentWidth / background.contentWidth)
    background.yScale = background.xScale
    background.x = display.contentWidth / 2
    background.y = display.contentHeight / 2
    background.alpha = 0.30
    background:addEventListener("touch", onTouch)
    grp:insert(background)

    rewardLabel = display.newText("penalty", 0, 0, native.systemFontBold, 20)
    rewardLabel.x = ContentW / 2
    rewardLabel.y = 95
    rewardLabel:setTextColor(0, 0, 0)
    rewardLabel.alpha = 0
    rewardLabel.isVisible = false
    grp:insert(rewardLabel)

    rewardBar = display.newRect(100, 80, 280, 30)
    rewardBar:setFillColor(0, 0, 0, 50)
    rewardBar.isVisible = false
    grp:insert(rewardBar)

    penaltyLabel = display.newText("penalty", 0, 0, native.systemFontBold, 20)
    penaltyLabel.x = ContentW / 2
    penaltyLabel.y = ContentH - 15 - 80
    penaltyLabel:setTextColor(0, 0, 255)
    penaltyLabel.alpha = 0
    penaltyLabel.isVisible = false
    grp:insert(penaltyLabel)

    penaltyBar = display.newRect(100, ContentH - 30 - 80, 280, 30)
    penaltyBar:setFillColor(0, 0, 255, 50)
    penaltyBar.isVisible = false
    grp:insert(penaltyBar)

    scoreLabel = display.newText(tostring(score), ContentW / 2, ContentH / 2, native.systemFontBold, 120)
    scoreLabel:setFillColor(colors.RGB("white"))
    scoreLabel.x = display.viewableContentWidth / 2
    scoreLabel.y = display.viewableContentHeight / 2
    scoreLabel.alpha = 0.20
    scoreLabel.isVisible = false
    grp:insert(scoreLabel)

    highscore = GetHighScore()
    highScoreLabel = display.newText("Highest Score: " .. tostring(highscore) or 0, ContentW / 2, ContentH / 2, native.systemFontBold, 15)
    highScoreLabel:setFillColor(colors.RGB("white"))
    highScoreLabel.x = ContentW / 2
    highScoreLabel.y = (ContentH / 2) - (ContentH / 2) + 10
    highScoreLabel.alpha = 0.20
    highScoreLabel.isVisible = false
    grp:insert(highScoreLabel)
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

        score = 0
        scoreLabel.text = tostring(score)
        gameIsOver = false

        player = createPlayer(ContentW / 2, ContentH / 2, 20, 20, 0, true)

        player.health = 100
        player.width = 20
        player.height = 20
        player.x = ContentW / 2
        player.y = ContentH / 2
        player.resize = true
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

        health.hearts[1].isVisible = true
        health.hearts.current = 1
        health.amount = 100

    elseif (phase == "did") then

        highscore = highscore or GetHighScore()

        Spawn("food", 0, randomSpeed())
        Spawn("food", 0, -randomSpeed())
        Spawn("food", randomSpeed(), 0)
        Spawn("food", -randomSpeed(), 0)
        Spawn("poison", 0, randomSpeed())
        Spawn("poison", 0, -randomSpeed())
        Spawn("poison", randomSpeed(), 0)
        Spawn("poison", -randomSpeed(), 0)
        Spawn("reward", randomSpeed(), 0)

        HeartsAnimation()

        scoreLabel.isVisible = true
        highScoreLabel.isVisible = true
        sounds.playStream('game_music')
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
    return math.random(1, 2) / 10 * speedFactor
end

local function calculateNewVelocity(t)
    for _, object in pairs(t) do
        object.xVelocity = object.xVelocity * speedFactor
        object.yVelocity = object.yVelocity * speedFactor
    end
end

local function gameOver()
    gameIsOver = true

    rewardBar.isVisible = false
    penaltyLabel.alpha = 0
    penaltyBar.isVisible = false

    player.isVisible = false

    -- HIDE: health bar & hearts --
    health.bar.isVisible = false
    for i = 1, 5 do
        health.hearts[i].isVisible = false
    end
    --

    -- Remove objects:
    for _, v in pairs(objects) do
        v:removeSelf()
    end
    objects = { }

    -- Update scores:
    if (score > highscore) then
        highscore = score
        sounds.play("onWin")
        SaveHighScore()
    else
        sounds.play("onFailed")
    end
    highscore = nil

    -- Switch to GAME OVER SCENE:
    switchScene("scenes.gameover")
end

function ConstrainToScreen(object)
    local screen_offset = 1
    if (object.x < object.width) then
        object.x = object.width / screen_offset
    end
    if (object.x > ContentW - object.width) then
        object.x = ContentW - object.width / screen_offset
    end
    if (object.y < object.height) then
        object.y = object.height / screen_offset
    end
    if (object.y > ContentH - object.height) then
        object.y = ContentH - object.height / screen_offset
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
    else
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
end

local function gameSpecial(objectType)
    local r = math.random(1, 3)

    if (objectType == "reward") then
        if (r == 1) then
            player.width = 15
            player.height = 15
            player.resize = true
            rewardLabel.text = "weight loss"
            rewardLabel.alpha = 0.25
            transition.to(rewardLabel, { time = 1000, alpha = 0, delay = 3000 })
        elseif (r == 2) then
            rewardLabel.text = "all you can eat"
            rewardLabel.alpha = 0.25
            transition.to(rewardLabel, { time = 500, alpha = 0, delay = 4500 })
            rewardBar.isVisible = true
            spawnConstraint = "allyoucaneat"
            local closure = function()
                spawnConstraint = "no"
                rewardBar.width = 280
                rewardBar.isVisible = false
            end
            transition.to(rewardBar, { time = 5000, width = 0, onComplete = closure })
        elseif (r == 3) then
            if (speedFactor ~= 1) then
                return
            end
            rewardLabel.text = "traffic jam"
            rewardLabel.alpha = 0.25
            transition.to(rewardLabel, { time = 500, alpha = 0, delay = 4500 })
            speedFactor = 0.5
            calculateNewVelocity(objects)
            rewardBar.isVisible = true
            local closure = function()
                speedFactor = 2
                calculateNewVelocity(objects)
                speedFactor = 1
                rewardBar.width = 280
                rewardBar.isVisible = false
            end
            transition.to(rewardBar, { time = 5000, width = 0, onComplete = closure })
        end
    elseif (objectType == "penalty") then
        if (r == 1) then
            player.width = 50
            player.height = 50
            player.resize = true
            penaltyLabel.text = "weight gain"
            penaltyLabel.alpha = 0.25
            transition.to(penaltyLabel, { time = 1000, alpha = 0, delay = 3000 })
        elseif (r == 2) then
            penaltyLabel.text = "food contaminated"
            penaltyLabel.alpha = 0.25
            transition.to(penaltyLabel, { time = 500, alpha = 0, delay = 4500 })
            penaltyBar.isVisible = true
            spawnConstraint = "foodcontaminated"
            local closure = function()
                spawnConstraint = "no"
                penaltyBar.width = 280
                penaltyBar.isVisible = false;
            end
            transition.to(penaltyBar, { time = 5000, width = 0, onComplete = closure })
        elseif (r == 3) then
            if (speedFactor ~= 1) then
                return
            end
            penaltyLabel.text = "rush hour"
            penaltyLabel.alpha = 0.25
            transition.to(penaltyLabel, { time = 500, alpha = 0, delay = 4500 })
            speedFactor = 2
            calculateNewVelocity(objects)
            penaltyBar.isVisible = true
            local closure = function()
                speedFactor = 0.5
                calculateNewVelocity(objects)
                speedFactor = 1
                penaltyBar.width = 280
                penaltyBar.isVisible = false;
            end
            transition.to(penaltyBar, { time = 5000, width = 0, onComplete = closure })
        end
    end
    rewardLabel.x = ContentW / 2
    penaltyLabel.x = ContentW / 2
end

local function OnTick(event)
    if (gameIsOver) then
        return
    end

    if (player) then

        if (player.resize) then
            local player2 = createPlayer(player.x, player.y, player.width, player.height, player.rotation, player.isVisible)
            if (player.isFocus) then
                player2.isFocus = player.isFocus
                player2.x0 = player.x0
                player2.y0 = player.y0
            end
            player2.resize = false
            player:removeSelf()
            player = player2
        end

        -- Display Health Bar:
        health.bar.new(health.amount)
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
            yPos > display.contentHeight + object.sizeXY, yPos < -object.sizeXY,
            xPos > display.contentWidth + object.sizeXY, xPos < -object.sizeXY,
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
                    bombshell = "reward"
                end
                local closure = function()
                    return Spawn(Item, xVelocity, yVelocity)
                end
                timer.performWithDelay(math.random(6, 12) * 1000, closure, 1)
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
            if player.width < 50 then
                player.width = player.width + 1
                player.height = player.height + 1
                player.resize = true
            end
            o.isVisible = false
        elseif (ot == "poison") or (spawnConstraint == "foodcontaminated") then
            sounds.play("onDamage")
            health.amount = health.amount - 25
            health.hearts[health.hearts.current].isVisible = false
            health.hearts.current = health.hearts.current + 1
            if (health.hearts.current > 5) then
                health.hearts.current = 5
            end
            health.hearts[health.hearts.current].isVisible = true
            if (health.amount <= -25) then
                gameOver()
            end
        elseif (ot == "reward") or (ot == "penalty") then
            sounds.play("onPowerup")
            o.isVisible = false
            gameSpecial(ot)
        end
    end
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

Runtime:addEventListener("collision", onCollision)
Runtime:addEventListener("enterFrame", OnTick)

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene