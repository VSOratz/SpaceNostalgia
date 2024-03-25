local love = require("love")
local utf8 = require("utf8")
local _player = require("components/player")
local _enemy = require("components/enemy")

function love.load()
 
    _player.load()
    _enemy.load()
    love.keyboard.setKeyRepeat(true)

    shootSound = love.audio.newSource('sound/gun-sound.wav', 'static')
    failSound = love.audio.newSource('sound/fail.wav', 'static')
    bgSound = love.audio.newSource('sound/background.mp3', 'stream')

    bulletImg = love.graphics.newImage('img/Bullet.png')
    canShoot = true
    canShootTimeMax = 0.2
    canShootTime = canShootTimeMax
    bullets = {}

    createEnemyTimeMax = 1
    createEnemyTime = createEnemyTimeMax
    
    enemies = {}

    started = false
end


function love.update(dt)
    if love.keyboard.isDown("space") and not started and #_player.name > 3 then
        started = true        
    end
    if started then
        if _player.live then
            PlayGame(dt)
        end
    end

    if not _player.live and love.keyboard.isDown("a") then
        love.audio.stop(failSound)
        _player.x = love.graphics.getWidth() / 2
        _player.y = love.graphics.getHeight() - 100

        enemies = {}
        bullets = {}
        _player.live = true
        _player.score = 0
        createEnemyTimeMax = 1
        createEnemyTime = createEnemyTimeMax
    end
end

function love.draw()
    if started and _player.live then
        love.graphics.draw(_player.img, _player.x, _player.y)
        love.graphics.printf("Score: " .. _player.score, 50, 50, 200)

        for i, bullet in ipairs(bullets) do
            love.graphics.draw(bullet.img,bullet.x, bullet.y)
        end
        for i, enemy in ipairs(enemies) do
            love.graphics.draw(enemy.img, enemy.x, enemy.y, math.rad(180), 1, 1, enemy.img:getWidth(), enemy.img:getHeight())
        end

    elseif not started then
        love.graphics.printf("Welcome aboard! May I have the pleasure of knowing your name, Captain?\n" .. _player.name, 
        (love.graphics.getWidth() / 8 - 100), 
        (love.graphics.getHeight() / 2 - 100), 
        love.graphics.getWidth(), 
        "center")
        
        love.graphics.printf("Press 'Space' to start the game", 
        (love.graphics.getWidth() / 8 - 100), 
        (love.graphics.getHeight() / 2), 
        love.graphics.getWidth(), 
        "center")
    end

    if not _player.live then
        love.graphics.printf("You die with " .. _player.score .. " Points", (love.graphics.getWidth() / 2 - 100), (love.graphics.getHeight() / 2), 200, "center")
        love.graphics.printf("Press 'a' to play again", (love.graphics.getWidth() / 2 - 100), (love.graphics.getHeight() / 2 + 30), 200, "center")
    end
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end

function PlayGame(dt)
    love.audio.play(bgSound)
    _player.update(dt)

    canShootTime = canShootTime - (1 * dt)
    if canShootTime < 0 then
        canShoot = true
    end

    if love.keyboard.isDown("space") and canShoot and started then
        local newBullet = {
            x = _player.x + ((_player.img:getWidth() / 2) - 5),
            y = _player.y,
            img = bulletImg
        }
        table.insert(bullets, newBullet)
        canShoot = false
        canShootTime = canShootTimeMax
        love.audio.play(shootSound)
    end

    for i, bullet in ipairs(bullets) do
        bullet.y = bullet.y - (250 * dt)
        if bullet.y < 0 then
            table.remove(bullets, i)
        end
    end

    createEnemyTime = createEnemyTime - (1 * dt)
    if createEnemyTime < 0 then
        createEnemyTime = createEnemyTimeMax

        local randomNumber = math.random(0, love.graphics.getWidth() - _enemy.Img:getWidth())
        local enemy = {
            x = randomNumber,
            y = -10,
            img = _enemy.Img,
            speed = _enemy.speed
        }
        table.insert(enemies, enemy)
    end

    for i, enemy in ipairs(enemies) do
        enemy.y = enemy.y + (enemy.speed * dt)

        if enemy.y > love.graphics.getHeight() then
            table.remove(enemies, i)

            if _player.score > 0 then
                _player.score = _player.score - 25
            end
        end

        for j, bullet in ipairs(bullets) do
            if CheckCollision(bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight(), enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight()) then
                table.remove(bullets, j)
                table.remove(enemies, i)

                _player.score = _player.score + 50
                if _player.speed < 350 then
                    _player.speed = _player.speed + 10
                end

                if createEnemyTimeMax > 0.4 then
                    createEnemyTimeMax = createEnemyTimeMax - 0.04
                    enemy.speed = enemy.speed + 10
                end
            end
        end

        if CheckCollision(_player.x, _player.y, _player.img:getWidth(), _player.img:getHeight(), enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight()) then
            table.remove(enemies, i)

            _player.live = false
            love.audio.stop(bgSound)
            love.audio.play(failSound)
        end
    end
end

function love.textinput(t)
    _player.name = _player.name .. t
end

function love.keypressed(key)
    if key == "backspace" then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(_player.name, -1)

        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            _player.name = string.sub(_player.name, 1, byteoffset - 1)
        end
    end
end