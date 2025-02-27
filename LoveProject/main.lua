function love.load()
    lovebpm = require("Libraries/lovebpm")
    functions = require("Libraries/functions")
    gpioFunctions = require("Libraries/gpioFunctions")
    GPIO = require('periphery').GPIO
    socket = require("socket")
    gameState = "Start"
    keypress = 0
    score = 40
    beatCounter = 0
    accuracy = " "
    maxCombo = 0
    movingNotes = {}
    noteVelocity = {}
    backgroundTiltY = -250
    playerTiltY = 100 
    noteOffset = 4
    backgroundPanX = -56
    titlePanX = -64
    keyHit = false
    lbHit = false
    rbHit = false
    rfidResponse = "waiting"
    myclient = socket.connect('localhost', 12345)
    spotlightX = -75

    functions.initSFX()

    SFX1 = drumHitSFX
    SFX2 = kickDrumSFX

    functions.initSprites()

    music = lovebpm.newTrack()
    :load("Music/just-my-size.mp3")
    :setBPM(140)
    --:setBPM(lovebpm.detectBPM("Music/loop.ogg"))
    :setLooping(false)
    totalBeats = music:getTotalBeats()
    functions.buildNoteMap(totalBeats)
    music:play()
    music:on("beat", function(n)
        local beat, subbeat = music:getBeat()
        if gameState == "playing" or gameState == "Turbo" then
            animate(guitarist)
            animate(drummer)
            animate(singer)
            animate(bassist)
            turboR = love.math.random(0.1,0.9)
            turboG = love.math.random(0.1,0.9)
            turboB = love.math.random(0.1,0.9)
            if accuracy == "Miss" then
                score = score - 1
            end
            if beatMap[beat + noteOffset] ~= "rest" then
                table.insert(movingNotes, (beat + noteOffset))
                table.insert(noteVelocity, (beat + noteOffset))
                movingNotes[beat + noteOffset] = 640
                noteVelocity[beat + noteOffset] = (635 * (14/360))/noteOffset
            else
                table.insert(movingNotes, (beat + noteOffset))
                table.insert(noteVelocity, (beat + noteOffset))
                movingNotes[beat + noteOffset] = 641
                noteVelocity[beat + noteOffset] = 0
            end
        end
    end)
    :setVolume(0.3)
end

function love.update(dt)
    music:update()
    local beat, subbeat = music:getBeat()
    subbeatInt = string.sub(subbeat, 1, 3)
    if subbeatInt == "0.4" then
        keyHit = false
    end
    if backgroundTiltY ~= -150 and gameState == "playing" then
        backgroundTiltY = backgroundTiltY + 1
        playerTiltY = playerTiltY + 1
    end

    if backgroundPanX <= -32 then
        backgroundPanX = backgroundPanX + 0.7
    end

    if titlePanX <= -32 then
        titlePanX = titlePanX + 0.9
    end

    for i = noteOffset,#movingNotes,1 do
        movingNotes[i] = movingNotes[i] - noteVelocity[i]
    end

    --functions.checkMiss(beatMap, beat, accuracy, keypress)
    if beatMap[beat - 1] == "rest" and beatMap[beat] == "rest" then
        accuracy = " "
    end

    if beatCounter + 1 < beat and gameState == "playing" and beatMap[beat] ~= "rest" then
        accuracy = "Miss"
        keypress = 0
    end
    if beatCounter + 1 < beat and gameState == "Turbo" and beatMap[beat] ~= "rest" then
        accuracy = "Miss"
        keypress = 0
    end

    if keypress > maxCombo then
        maxCombo = keypress
    end
    if score <= 0 then
        gameState = "Lose"
    end
    if score >= 100 then
        gameState = "Turbo"
    end
    if score <100 and score > 0 and gameState ~= "Start" and gameState ~= "RFID" then
        gameState = "playing"
    end

    if beatCounter + 1 >= totalBeats then
        gameState = "Win"
    end
    
    gpioFunctions.readLeftButton(GPIO)
    if lbValue == true then
        if gameState ~= "Lose" and gameState ~= "Win" and gameState ~= "Start" and gameState ~= "RFID" then
            if keyHit == false and lbHit == false then
                functions.scoreLeftNote(beatMap, beat, subbeat, keyHit, SFX1)
            end
        elseif gameState == "Lose" or gameState == "Win" or gameState == "Start" then
            gameState = "RFID"
        elseif gameState == "RFID" and rfidResponse ~= "waiting" then
            gameState = "playing"
            score = 40
            keypress = 0
            maxCombo = 0
            beatCounter = beat
            accuracy = "Perfect!"
            music:play(true)
        end
        keyHit = true
        lbHit = true
    end
    if lbValue == false then
        lbHit = false
    end
    gpioFunctions.readRightButton(GPIO)
    if rbValue == true and gameState ~= "Lose" and gameState ~= "Win" and gameState ~= "Start" then
        if keyHit == false and rbHit == false then
            functions.scoreRightNote(beatMap, beat, subbeat, keyHit, SFX2)
        end
        keyHit = true
        rbHit = true
    end
    if rbValue == false then
        rbHit = false
    end

    music:on("end", function()
        gameState = "Win"
        return gameState
    end)
end

function love.draw()  

    love.graphics.setFont(love.graphics.newFont(25))

    if gameState == "playing" then
        love.graphics.draw(background, -350, backgroundTiltY, 0, 3, 3)
        love.graphics.setColor(0.2,0.2,0.2, 0.5)
        love.graphics.rectangle("fill", 0, 0, 640, 480)
        love.graphics.setColor(1,1,1)
        love.graphics.draw(spotlight, spotlightX, backgroundTiltY, 0, 4, 4)
        progressX = 5.9 * score
    end

    if gameState == "Turbo" then
        love.graphics.draw(background, -350, -150, 0, 3, 3)
        love.graphics.draw(spotlight, spotlightX, backgroundTiltY, 0, 4, 4)
        love.graphics.setColor(turboR,turboG,turboB, 0.5)
        love.graphics.rectangle("fill", 0, 0, 640, 480)
        love.graphics.setColor(1,1,1)
        progressX = 590
    end

    if gameState == "playing" or gameState == "Turbo" then

        love.graphics.draw(guitarist.currentFrame, 20, playerTiltY, 0, 3, 3)
        love.graphics.draw(drummer.currentFrame, 450, playerTiltY + 20, 0, 3, 3)
        love.graphics.draw(bassist.currentFrame, 300, playerTiltY + 20, 0, 2.7, 2.7)
        love.graphics.draw(singer.currentFrame, 170, playerTiltY + 20, 0, 2.7, 2.7)

        love.graphics.rectangle("line", 30, 430, 590, 30)

        love.graphics.rectangle("fill", 30, 430, progressX, 30)

        
        love.graphics.setColor(0.5,0.5,0.5)
        love.graphics.rectangle("fill", 50, 30, 640, 64)
        love.graphics.setColor(0.21,0.21,0.21)
        love.graphics.setLineWidth(5)
        love.graphics.rectangle("line", 50, 30, 660, 64)
        love.graphics.setColor(1,1,1)

        love.graphics.draw(noteTarget, (5), (62-45), 0, 2, 2)

        local beat, subbeat = music:getBeat()
        love.graphics.print("Combo: " .. keypress, 10, 130)
        love.graphics.print(accuracy, 300, 10)
        love.graphics.print("Max Combo: " .. maxCombo, 400, 100)

    
        for i = noteOffset,#movingNotes,1 do
            if movingNotes[i] < 641 and movingNotes[i] > 20 then
                if beatMap[i] == "left" then
                    love.graphics.draw(leftNote, movingNotes[i], 30, 0, 2, 2)
                elseif beatMap[i] == "right" then
                    love.graphics.draw(rightNote, movingNotes[i], 30, 0, 2, 2)
                end
            end
        end
    end


    if gameState == "Lose" then
        music:stop()
        love.graphics.clear()
        love.graphics.print("You lose.", 150, 10)
        love.graphics.print("Press L to play again!", 150, 150)
    end
    if gameState == "Win" then
        music:stop()
        love.graphics.clear()
        love.graphics.print("You Win!", 150, 10)
        love.graphics.print("Press L to play again!", 150, 150)
    end
    
    if gameState == "Start" then
        music:stop()
        love.graphics.draw(splashScreen.background, backgroundPanX, 0, 0, 1.1, 1.1)
        love.graphics.draw(splashScreen.girls, titlePanX, 0, 0, 1.1, 1.1)
        if titlePanX >= -32 then
            love.graphics.draw(startButton, 192, 300, 0, 3, 3)
        end
    end

    if gameState == "RFID" then
        if rfidResponse == "waiting" then
            love.graphics.clear()
            love.graphics.print("Scan RFID now!", 150, 350)
            love.graphics.print(rfidResponse, 150, 200)
            love.graphics.present()
            myclient:send("RFID\n")
		    rfidResponse = myclient:receive('*l')
            return rfidResponse
        end
        if rfidResponse ~= "waiting" then
            love.graphics.clear()
            love.graphics.print(rfidResponse, 20, 20)
            love.graphics.print("Press L to continue!", 20, 50)
            if string.find(rfidResponse, "Nina") then
                SFX1 = guitarASFX
                SFX2 = guitarESFX
                spotlightX = -210
                love.graphics.draw(guitarist.currentFrame, 100, 100, 0, 5, 5)
            elseif string.find(rfidResponse, "Susan") then
                SFX1 = bassASFX
                SFX2 = bassESFX
                spotlightX = 100
                love.graphics.draw(bassist.currentFrame, 100, 100, 0, 5, 5)
            elseif string.find(rfidResponse, "Alex") then
                SFX1 = drumHitSFX
                SFX2 = kickDrumSFX
                spotlightX = 260
                love.graphics.draw(drummer.currentFrame, 100, 100, 0, 5, 5)
            elseif string.find(rfidResponse, "Erika") then
                spotlightX = -75
                love.graphics.draw(singer.currentFrame, 100, 200, 0, 5, 5)
            end
            myclient:close()
        end
    end
end


function animate(character)
    if character.currentFrame == character.frame0 then
        character.currentFrame = character.frame1
    else
        character.currentFrame = character.frame0
    end
end

function love.keypressed(k)
    local beat, subbeat = music:getBeat()
    if k == "1" then
      -- Toggle pause
      paused = not paused
      if paused then
        music:pause()
      else
        music:play()
      end
    end

    if k == "f" and gameState ~= "Lose" and gameState ~= "Win" and gameState ~= "Start" then
        functions.scoreLeftNote(beatMap, beat, subbeat, keyHit, SFX1)
        keyHit = true
    end

    if k == "j" and gameState ~= "Lose" and gameState ~= "Win" and gameState ~= "Start" then
        functions.scoreRightNote(beatMap, beat, subbeat, keyHit, SFX2)
        keyHit = true
    end

    if k == "f" then
        if gameState == "Lose" or gameState == "Win" or gameState == "Start" then
            gameState = "playing"
            score = 40
            keypress = 0
            maxCombo = 0
            beatCounter = 0
            restart = true
            music:play(true)
        end
    end
end