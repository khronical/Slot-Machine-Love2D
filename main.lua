function love.load()
    screen_width = 500
    screen_height = 500

    love.window.setTitle("bitslots")
    love.window.setMode(screen_width, screen_height)
    love.window.setVSync(true)

    background = love.graphics.newImage('assets/slotbackground.png')

    _G.gameStates = {
        score = 0;
    }
end

function love.update(dt)
    
end

function love.draw()
    love.graphics.draw(background, 0,0)

    love.graphics.print("0000", 0, 250)
end