function love.load()
    lovebpm = require("Libraries/lovebpm")

    gameState = "playing"
    keypress = 0
    score = 35
    beatCounter = 0
    accuracy = " "
    maxCombo = 0
    movingNotes = {}
    noteVelocity = {}

    kickDrumSFX = love.audio.newSource("Sound/Drummer/kick-drum.mp3", "static")
    kickDrumSFX:setVolume(8)
    --snareDrumSFX = love.audio.newSource("Sound/Drummer/snare-drum.mp3", "static")
    --snareDrumSFX:setVolume(8)
    kickDrumSFX = love.audio.newSource("Sound/Drummer/kick-drum.mp3", "static")
    kickDrumSFX:setVolume(8)
    drumHitSFX = love.audio.newSource("Sound/Drummer/drum-hit.mp3", "static")
    drumHitSFX:setVolume(8)

    guitarist = {}
    guitarist.frame0 = love.graphics.newImage("Sprites/guitarist/sprite_0.png")
    guitarist.frame0:setFilter("linear", "nearest")
    guitarist.frame1 = love.graphics.newImage("Sprites/guitarist/sprite_1.png")
    guitarist.frame1:setFilter("linear", "nearest")
    guitarist.currentFrame = guitarist.frame1

    drummer = {}
    drummer.frame0 = love.graphics.newImage("Sprites/drummer/sprite_0.png")
    drummer.frame0:setFilter("linear", "nearest")
    drummer.frame1 = love.graphics.newImage("Sprites/drummer/sprite_1.png")
    drummer.frame1:setFilter("linear", "nearest")
    drummer.currentFrame = drummer.frame1

    leftNote = love.graphics.newImage("Sprites/UI/notes/left-note.png")
    leftNote:setFilter("linear", "nearest")
    rightNote = love.graphics.newImage("Sprites/UI/notes/right-note.png")
    rightNote:setFilter("linear", "nearest")
    noteTarget = love.graphics.newImage("Sprites/UI/note-target.png")
    noteTarget:setFilter("linear", "nearest")

    music = lovebpm.newTrack()
    :load("Music/just-my-size.mp3")
    :setBPM(140)
    --:setBPM(lovebpm.detectBPM("Music/loop.ogg"))
    :setLooping(false)
    totalBeats = music:getTotalBeats()
    buildNoteMap(totalBeats)
    music:play()
    music:on("beat", function(n)
        local beat, subbeat = music:getBeat()
        animate(guitarist)
        animate(drummer)
        if accuracy == "Miss" then
            score = score - 1
        end
        if gameState == "Turbo" then
            love.graphics.setBackgroundColor(love.math.random(0.1,0.9),love.math.random(0.1,0.9),love.math.random(0.1,0.9))
        end
        if beatMap[beat + 4] ~= "rest" then
            table.insert(movingNotes, (beat + 4))
            table.insert(noteVelocity, (beat + 4))
            movingNotes[beat + 4] = 640
            noteVelocity[beat + 4] = (635 * (14/360))/4
        else
            table.insert(movingNotes, (beat + 4))
            table.insert(noteVelocity, (beat + 4))
            movingNotes[beat + 4] = 641
            noteVelocity[beat + 4] = 0
        end
    end)
    :setVolume(0.3)
end

function love.update(dt)
    music:update()
    local beat, subbeat = music:getBeat()

    for i = 4,#movingNotes,1 do
        movingNotes[i] = movingNotes[i] - noteVelocity[i]
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
    if score <100 and score > 0 then
        gameState = "playing"
    end

    if beatCounter + 1 >= totalBeats then
        gameState = "Win"
    end

    music:on("end", function()
        gameState = "Win"
        return gameState
    end)
end

function love.draw()    
    if gameState == "playing" then
        love.graphics.setBackgroundColor(.17,.31,.51)
        progressX = 5.9 * score
    end
    love.graphics.draw(guitarist.currentFrame, 60, 200, 0, 3, 3)
    love.graphics.draw(drummer.currentFrame, 400, 220, 0, 3, 3)

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
    --love.graphics.print(beat, 500, 10)
    love.graphics.setFont(love.graphics.newFont(25))
    love.graphics.print("Combo: " .. keypress, 10, 130)
    love.graphics.print(accuracy, 300, 10)
    love.graphics.print("Max Combo: " .. maxCombo, 400, 100)
    love.graphics.print(beatMap[beat], 300, 300)
 
    for i = 4,#movingNotes,1 do
        if movingNotes[i] < 641 and movingNotes[i] > 20 then
            if beatMap[i] == "left" then
                love.graphics.draw(leftNote, movingNotes[i], 30, 0, 2, 2)
            elseif beatMap[i] == "right" then
                love.graphics.draw(rightNote, movingNotes[i], 30, 0, 2, 2)
            end
            --love.graphics.circle("fill", movingNotes[i], 30, 20)
        end
    end


    if gameState == "Lose" then
        music:stop()
        love.graphics.clear()
        love.graphics.print("You lose.", 150, 10)
        love.graphics.print("Press space to play again!", 150, 150)
    end
    if gameState == "Turbo" then
        progressX = 590
    end
    if gameState == "Win" then
        music:stop()
        love.graphics.clear()
        love.graphics.print("You Win!", 150, 10)
        love.graphics.print("Press space to play again!", 150, 150)
    end
end

function animate(character)
    if character.currentFrame == character.frame0 then
        character.currentFrame = character.frame1
    else
        character.currentFrame = character.frame0
    end
end

function playSound(sound1, sound2)
    soundContainer = love.math.random(1,9)
    if soundContainer <= 3 then
        sound1:play()
    elseif soundContainer > 3 then
        sound2:play()
    end
end

function buildNoteMap(numBeats)
    beatMap = {}
    for i = 0,4,1 do
        beatMap[i] = "rest"
    end
    for i = 5,numBeats,1 do
        randomBeat = love.math.random(0,10)
        if randomBeat < 3 then
            beatMap[i] = "rest"
        elseif randomBeat >= 3 and randomBeat < 6 then
            beatMap[i] = "right"
        elseif randomBeat >= 6 then
            beatMap[i] = "left"
        end
    end
    return beatMap
end


function love.keypressed(k)
    if k == "1" then
      -- Toggle pause
      paused = not paused
      if paused then
        music:pause()
      else
        music:play()
      end
    end
    if k == "space" and gameState == "playing" or gameState == "Turbo" then
      local beat, subbeat = music:getBeat()
      playSound(kickDrumSFX, drumHitSFX)
      if subbeat < .2 or subbeat > .8 then
        if beatCounter ~= beat then
          keypress = keypress + 1
          score = score + 1
          beatCounter = beat
          accuracy = "Perfect!"
        end
      elseif subbeat < .4 or subbeat > .6 then
        if beatCounter ~= beat then
          keypress = keypress + 1
          score = score + 1
          beatCounter = beat
          accuracy = "Great!"
        end
      else
        beatCounter = beat
        keypress = 0
        accuracy = "Bad."
        score = score - 1
      end
    end
    if k == "space" then
        if gameState == "Lose" or gameState == "Win" then
            gameState = "playing"
            score = 35
            keypress = 0
            maxCombo = 0
            beatCounter = 0
            restart = true
            music:play(true)
        end
    end
end


