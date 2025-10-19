local function calculateWinnings(first, second, third, multiplier) -- // Handles the adding of credits when you win in the slot machine. It also technically detects if you won.
    local score = 0
    if first == second and second == third then -- // Checks for a Jackpot

        if first == tostring(assets.icons[1]) then -- // Checks for a Hello Kitty Jackpot
            score = 100 * multiplier -- / awards 100 points that is then multiplied by the multiplier if it is a hello kitty jackpot
        else
            score = 50 * multiplier -- / awards 50 points that is then multiplied by the multiplier as the default for any jackpot
        end

        return score
    end
    if first == third then -- // Checks if the first and third icons match
        score = 5 * multiplier -- / awards 5 points multiplied by the multiplier for a match
        return score
    end
    return score -- / returns no points if none of the winning conditions are met
end

function love.load()
    local conf = require("modules.conf")

    love.window.setTitle(conf.title)
    love.window.setMode(conf.screen_width, conf.screen_height, conf.flags)

    _G.GameStates = {
        screen = 1,
        score = 30,
        multiplier = 1,

        rolling = false,
        rollTimer = 0,
        rollDuration = 3,
        rolled = {},
    }

    _G.savedstate = {}

    _G.assets = {
        background = love.graphics.newImage('assets/background.png'),
        button = love.graphics.newImage('assets/buttontest.png'),
        addmultiplier = love.graphics.newImage('assets/addmultiplier.png'),
        icons = {
            love.graphics.newImage('assets/hellokitty.png'),
            love.graphics.newImage('assets/redapple.png'),
            love.graphics.newImage('assets/goldapple.png'),
            love.graphics.newImage('assets/cherry.png'),
            love.graphics.newImage('assets/soccerball.png'),
        },
    }
end

function love.update(dt)

    -- // Handle rolling visual
    if GameStates.rolling then
        GameStates.rollTimer = GameStates.rollTimer - dt -- // Decrease timer (cuz I forget with my bad memory ahh)

        print("Rolling", GameStates.rollTimer, #savedstate)

        -- // Change slots at a rapid interval (every 0.1s)
        if math.floor(GameStates.rollTimer * 10) % 2 >= 0 then
            local slot1 = math.random(5)
            local slot2 = math.random(5)
            local slot3 = math.random(5)

            if GameStates.rollTimer > GameStates.rollDuration * (2/3) then -- // if the timer is less than 2 thirds of the way done
                GameStates.rolled = {
                    assets.icons[slot1],
                    assets.icons[slot2],
                    assets.icons[slot3],
                }
            elseif GameStates.rollTimer > GameStates.rollDuration * (1/3) then -- // if the timer is less than 1 thirds of the way done
                if not savedstate[1] then
                    table.insert(savedstate, GameStates.rolled[1])
                end
                GameStates.rolled = {
                    savedstate[1],
                    assets.icons[slot2],
                    assets.icons[slot3],
                }
            else  -- // if the timer is less than 1 third of the way done
                if not savedstate[2] then
                    table.insert(savedstate, GameStates.rolled[2])
                end
                GameStates.rolled = {
                    savedstate[1],
                    savedstate[2],
                    assets.icons[slot3],
                }
            end
        end

        if GameStates.rollTimer <= 0 then -- // Once the rolling ends, it resets the variables for rolling and ensures it has stopped.  It also adds the score using the calculateWinnings() function
            savedstate = {}
            GameStates.rolling = false
            GameStates.score = GameStates.score + calculateWinnings(tostring(GameStates.rolled[1]), tostring(GameStates.rolled[2]), tostring(GameStates.rolled[3]), GameStates.multiplier)

            print("Current Score:", GameStates.score) 
        end
    end
end

function love.mousepressed(x, y, button, ...) -- // Detects mouseclicks on sprites by using the x y coordinates, and sprite size as the hitbox
    if button == 1 then
        local buttonWidth, buttonHeight = assets.button:getWidth(), assets.button:getHeight()

        if x >= 141 and x <= 141 + buttonWidth and y >= 300 and y <= 300 + buttonHeight then -- // Bet Max Button
            if not GameStates.rolling and GameStates.score > 0 then
                GameStates.rolling = true
                GameStates.rollTimer = GameStates.rollDuration
                GameStates.score = GameStates.score - 1
            end
        end

        if x >= 141 and x <= 141 + buttonWidth and y >= 375 and y <= 375 + buttonHeight then -- // Add Multiplier Button
            if GameStates.score > GameStates.multiplier then
                GameStates.score = GameStates.score - GameStates.multiplier
                GameStates.multiplier = GameStates.multiplier + 1
            end
        end
    end
end

function love.draw() -- // Love2D framework drawer, is in charge of the graphics aspect of the slot machine.
    if GameStates.screen == 1 then
        love.graphics.draw(assets.background, 0, 0)

        love.graphics.draw(assets.button, 141, 300)
        love.graphics.draw(assets.addmultiplier, 141, 375)

        love.graphics.print('Credits :'.. GameStates.score, 200, 270)
        love.graphics.print('Multiplier :' .. GameStates.multiplier, 200, 440)

        if #GameStates.rolled > 0 then
            love.graphics.draw(GameStates.rolled[1], 65, 125)
            love.graphics.draw(GameStates.rolled[2], 200, 125)
            love.graphics.draw(GameStates.rolled[3], 330, 125)
        end
    end
end
