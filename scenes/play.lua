local composer = require('composer')
local widget = require('widget')
local physics = require("physics")
local sounds = require('libraries.sounds')
local colors = require('classes.colors-rgb')
local relayout = require('libraries.relayout')
local scene = composer.newScene()

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenLeft = display.screenOriginX
local screenTop = display.screenOriginY

local spawnConstraint = "no"
local player
local tPrevious = system.getTimer()
local speedFactor = 1

local particles = { }

-------------------------------
-- default health --
local healthRemaining = 100
local createPlayer
local calculateNewVelocity

local gameSpecial
local OnTick
local randomSpeed

local rewardLabel
local rewardBar
local penaltyLabel
local penaltyBar

function randomSpeed()
    return math.random(1, 2) / 10 * 1
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
    physics.addBody(player, "dynamic", playerBodyElement)
    return player
end

function calculateNewVelocity(t)
    for _, object in pairs(t) do
        object.xVelocity = object.xVelocity * speedFactor
        object.yVelocity = object.yVelocity * speedFactor
    end
end

-- Forces the object (player) to stay within the visible screen bounds.
function ConstrainToScreen(object)
    if (object.x < object.width) then
        object.x = object.width
    end
    if (object.x > display.viewableContentWidth - object.width) then
        object.x = display.viewableContentWidth - object.width
    end
    if (object.y < object.height) then
        object.y = object.height
    end
    if (object.y > display.viewableContentHeight - object.height) then
        object.y = display.viewableContentHeight - object.height
    end
end

function onTouch(event)
    if (event.phase == "began") then
        player.isFocus = true
        player.x0 = event.x - player.x
        player.y0 = event.y - player.y
    elseif player.isFocus then
        if (event.phase == "moved") then
            player.x = event.x - player.x0
            player.y = event.y - player.y0
            ConstrainToScreen(player)
        elseif (event.phase == "ended" or event.phase == "cancelled") then
            player.isFocus = false
        end
    end
    return true
end

function SpawnObject(Type, xVelocity, yVelocity)

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

    if (Type == "food") or (Type == "poison") then
        Object = display.newRect(startX, startY, sizeXY, sizeXY)
        Object.sizeXY = sizeXY
    elseif (Type == "reward" or Type == "penalty") then
        Object = display.newCircle(startX, startY, 15) -- Start obj.x, Start obj.y (radius)
        Object.sizeXY = 0
        AnimatePowerUp(Object)
    end

    if (Type == "poison") then
        Object:setFillColor(colors.RGB("red"))
    elseif (Type == "food") then
        Object:setFillColor(colors.RGB("green"))
    elseif (Type == "reward") then
        Object:setFillColor(colors.RGB("purple"))
    end

    Object.x = startX
    Object.y = startY
    Object.alpha = 1
    Object.objectType = Type
    Object.xVelocity = xVelocity
    Object.yVelocity = yVelocity
    Object.isFixedRotation = true

    local collisionFilter = { categoryBits = 4, maskBits = 2 }
    local body = { filter = collisionFilter, isSensor = true }
    physics.addBody(Object, body)

    table.insert(particles, Object)
end

function gameSpecial(Type)
    local random_powerup = math.random(1, 4)

    local removeLoadingIcon = function()
        revolving_loading.isVisible = false
    end

    if (Type == "reward") then
        objectWasReward = true
        -- Decide which reward we are playing
        if (random_powerup == 1) then
            -- Play weight loss - small player
            player.width = 15
            player.height = 15
            player.resize = true
            rewardLabel.text = "weight loss"
            rewardLabel.alpha = 0.75
            Time = 1000
            transition.to(rewardLabel, { time = Time, alpha = 0, delay = 3000 })
        elseif (random_powerup == 2) then
            -- Play all you can eat - all enemies will turn into food
            rewardLabel.text = "all you can eat"
            rewardLabel.alpha = 0.75
            transition.to(rewardLabel, { time = 1500, alpha = 0, delay = 4500 })
            rewardBar.isVisible = true
            spawnConstraint = "allyoucaneat"
            local closure = function()
                spawnConstraint = "no"
                rewardBar.width = 280
                rewardBar.isVisible = false
            end
            Time = 5000
            transition.to(rewardBar, { time = Time, width = 0, onComplete = closure })
        elseif (random_powerup == 3) then
            -- Play traffic jam - all objects move with half the speed
            if speedFactor ~= 1 then
                -- Skip this special, because rush hour seems to be running
                return
            end
            rewardLabel.text = "traffic jam"
            rewardLabel.alpha = 0.75
            transition.to(rewardLabel, { time = 500, alpha = 0, delay = 4500 })
            speedFactor = 0.5
            calculateNewVelocity(particles)
            rewardBar.isVisible = true
            local closure = function()
                speedFactor = 2
                calculateNewVelocity(particles)
                speedFactor = 1
                rewardBar.width = 280
                rewardBar.isVisible = false
            end
            Time = 5000
            transition.to(rewardBar, { time = Time, width = 0, onComplete = closure })
        else
            if healthRemaining < 100 then
                -- Give Extra Health
                local healthbonus = 25
                healthRemaining = healthRemaining + 25
                rewardLabel.text = "+" .. tostring(healthbonus) .. " health"
                rewardLabel.alpha = 0.75
                Time = 1000
                transition.to(rewardLabel, { time = Time, alpha = 0, delay = 3000 })
            end
        end
    elseif "penalty" == objectType then
        -- Decide which penalty we are playing
        if (random_powerup == 1) then
            -- Play weight gain - big player
            player.width = 50
            player.height = 50
            player.resize = true
            penaltyLabel.text = "weight gain"
            penaltyLabel.alpha = 0.75
            Time = 1000
            transition.to(penaltyLabel, { time = Time, alpha = 0, delay = 3000 })
        elseif (random_powerup == 2) then
            -- Play food contaminated - all food will turn into enemies
            penaltyLabel.text = "food contaminated"
            penaltyLabel.alpha = 0.75
            penaltyLabel.time = settings["FoodContaminatedTime"]
            transition.to(penaltyLabel, { time = 500, alpha = 0, delay = 4500 })
            penaltyBar.isVisible = true
            spawnConstraint = "foodcontaminated"
            local closure = function()
                spawnConstraint = "no"
                penaltyBar.width = 280
                penaltyBar.isVisible = false;
            end
            Time = settings["FoodContaminatedTime"]
            transition.to(penaltyBar, { time = Time, width = 0, onComplete = closure })
        else
            -- Play rush hour - all objects move with double speed
            if speedFactor ~= 1 then
                -- Skip this special, because traffic jam seems to be running
                return
            end
            penaltyLabel.text = "sugar rush!"
            penaltyLabel.alpha = 0.75
            transition.to(penaltyLabel, { time = 500, alpha = 0, delay = 4500 })
            speedFactor = 2
            calculateNewVelocity(particles)
            penaltyBar.isVisible = true
            local closure = function()
                speedFactor = 0.5
                calculateNewVelocity(particles)
                speedFactor = 1
                penaltyBar.width = 280
                penaltyBar.isVisible = false;
            end
            Time = 5000
            transition.to(penaltyBar, { time = Time, width = 0, onComplete = closure })
        end
    end
    local loadingIconGroup = display.newGroup()
    loadingIconGroup.x = rewardBar.x
    loadingIconGroup.y = rewardBar.y
    relayout.add(loadingIconGroup)
    for i = 1, 1 do
        revolving_loading = display.newImageRect(loadingIconGroup, 'images/loading/loading2.png', 64, 64)
        revolving_loading.x = 0
        revolving_loading.y = 0
        revolving_loading.anchorX = 0.5
        revolving_loading.anchorY = 0.5
        revolving_loading.rotation = 120 * i
        revolving_loading.alpha = 0.15
        transition.to(revolving_loading, { time = Time, rotation = 360, delta = true, onComplete = removeLoadingIcon })
    end
    rewardLabel.x = display.viewableContentWidth / 2
    rewardLabel.y = display.viewableContentHeight / 2 - 75
end

function onCollision(event)
    if (event.phase == "began") then
        local ot, o

        if (event.object1.objectTyp == "player") then
            o = event.object2
            ot = event.object2.objectType
        else
            o = event.object1
            ot = event.object1.objectType
        end

        if (ot == "food" and spawnConstraint == "no") or (spawnConstraint == "allyoucaneat") then
            sounds.play("onPickup")
            if (player.width < 50) then
                player.width = player.width + 1
                player.height = player.height + 1
                player.resize = true
            end
            o.isVisible = false
        elseif (ot == "poison") or (spawnConstraint == "foodcontaminated") then
            healthRemaining = healthRemaining - 25
            if healthRemaining <= -25 then
                -- game over
            elseif healthRemaining >= 0 then
                sounds.play("onDamage")
                -- on damage?
            end
        elseif (ot == "reward" or ot == "penalty") then
            sounds.play("onPickup")
            o.isVisible = false
            -- gameSpecial(ot)
        end
    end
end

function OnTick(event)
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
    ConstrainToScreen(player)

    local delta_time = (event.time - tPrevious)
    tPrevious = event.time

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

local function setUpDisplay(grp)
    local background = display.newImage(grp, "images/backgrounds/background.png")
    background.xScale = (background.contentWidth / background.contentWidth)
    background.yScale = background.xScale
    background.x = display.contentWidth / 2
    background.y = display.contentHeight / 2
    background.alpha = 0.30
    background:addEventListener("touch", onTouch)
end

function scene:create(event)
    setUpDisplay(self.view)
    sounds.playStream('game_music')
end

function scene:show(event)
    local phase = event.phase
    if (phase == "did") then
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
    -- NB/A
end

physics.start()
physics.setScale(60)
physics.setGravity(0, 0)

player = createPlayer(display.viewableContentWidth / 2, display.viewableContentHeight / 2, 20, 20, 0, true)

Runtime:addEventListener("enterFrame", OnTick)
Runtime:addEventListener("collision", onCollision)

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
