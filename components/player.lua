local player = {}

function player.load()
    player.x = love.graphics.getWidth() / 2 -- 200
    player.y = love.graphics.getHeight() - 100 -- 700
    player.score = 0
    player.live = true
    player.img = love.graphics.newImage('img/Aircraft.png')
    player.speed = 250
    player.name = ""
end

function player.update(dt)
    -- Lógica de movimento do jogador
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        if player.x > 0 then
            player.x = player.x - (player.speed * dt)
        end
    elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
            player.x = player.x + (player.speed * dt)
        end
    end
    
end

function player.draw()
    -- Desenhar jogador na tela
    love.graphics.draw(player.img, player.x, player.y)
    love.graphics.printf("Score: " .. player.score, 50, 50, 200)
end

return player