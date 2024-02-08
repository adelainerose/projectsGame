local functions = {}

function functions.generateNotes(i, rest, left)
    randomBeat = love.math.random(0,10)
        if randomBeat < rest then
            beatMap[i] = "rest"
        elseif randomBeat >= rest and randomBeat < left then
            beatMap[i] = "left"
        elseif randomBeat >= left then
            beatMap[i] = "right"
        end
    return beatMap[i]
 end

function functions.buildNoteMap(numBeats)
    beatMap = {}
    for i = 0, noteOffset, 1 do
        beatMap[i] = "rest"
    end
    for i = noteOffset, (numBeats/3), 1 do
        functions.generateNotes(i, 6, 7.5)
    end
    for i = (numBeats/3), (2*numBeats)/3, 1 do
        functions.generateNotes(i, 4, 7)
    end
    for i = ((2*numBeats)/3),numBeats,1 do
        functions.generateNotes(i, 3, 6.5)
    end
    return beatMap
end

function functions.checkNoteFront(beat, subbeat, keyHit)
    if subbeat < .2 then
        if keyHit == false then
            keypress = keypress + 1
            score = score + 1
            accuracy = "Perfect!"
        end
    elseif subbeat < .6 then
        if keyHit == false then
            keypress = keypress + 1
            score = score + 1
            accuracy = "Great!"
        end
    elseif subbeat >= .6 then
        beatCounter = beat
        keypress = 0
        accuracy = "Miss"
        score = score - 1
    end
end

function functions.checkNoteEnd(beat, subbeat, keyHit)
    if subbeat > .9 then
        if keyHit == false then
            keypress = keypress + 1
            score = score + 1
            accuracy = "Perfect!"
        end
    elseif subbeat > 0.7 then
        if keyHit == false then
            keypress = keypress + 1
            score = score + 1
            accuracy = "Great!"
        end
    elseif subbeat <= 0.7 then
        beatCounter = beat
        keypress = 0
        accuracy = "Miss"
        score = score - 1
    end
end

function functions.checkFullNote(beat, subbeat, keyHit)
    if subbeat < .2 then
        if keyHit == false then
            keypress = keypress + 1
            score = score + 1
            accuracy = "Perfect!"
        end
    elseif subbeat < .6 then
        if keyHit == false then
            keypress = keypress + 1
            score = score + 1
            accuracy = "Great!"
        end
    elseif subbeat > .9 then
        if keyHit == false then
            keypress = keypress + 1
            score = score + 1
            accuracy = "Perfect!"
        end
    elseif subbeat > .7 then
        if keyHit == false then
            keypress = keypress + 1
            score = score + 1
            accuracy = "Great!"
        end
    else
        beatCounter = beat
        keypress = 0
        accuracy = "Miss"
        score = score - 1
    end
end

function functions.scoreLeftNote(beatMap, beat, subbeat, keyHit, SFX1)
    SFX1:stop()
    SFX1:play()
    if beatMap[beat] == "left" and beatMap[beat + 1] == "left" then
        functions.checkFullNote(beat, subbeat, keyHit)
    elseif beatMap[beat] == "left" and beatMap[beat + 1] ~= "left" then
        functions.checkNoteFront(beat, subbeat, keyHit)
    elseif beatMap[beat] == "right" and beatMap[beat + 1] == "left" then
        functions.checkNoteEnd(beat, subbeat, keyHit)
    elseif beatMap[beat] == "rest" and beatMap[beat + 1] == "left" then
        functions.checkNoteEnd(beat, subbeat, keyHit)
    else
        beatCounter = beat
        keypress = 0
        accuracy = "Miss"
        score = score - 1
    end
    beatCounter = beat
end

function functions.scoreRightNote(beatMap, beat, subbeat, keyHit, SFX2)
    SFX2:stop()
    SFX2:play()
    if beatMap[beat] == "right" and beatMap[beat + 1] == "right" then
        functions.checkFullNote(beat, subbeat, keyHit)
    elseif beatMap[beat] == "right" and beatMap[beat + 1] ~= "right" then
        functions.checkNoteFront(beat, subbeat, keyHit)
    elseif beatMap[beat] == "left" and beatMap[beat + 1] == "right" then
        functions.checkNoteEnd(beat, subbeat, keyHit)
    elseif beatMap[beat] == "rest" and beatMap[beat + 1] == "right" then
        functions.checkNoteEnd(beat, subbeat, keyHit)
    else
        beatCounter = beat
        keypress = 0
        accuracy = "Miss"
        score = score - 1
    end
    beatCounter = beat
end

function functions.checkMiss(beatMap, beat, accuracy, keypress)
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
    return accuracy, keypress
end

function functions.initSprites()
    background = love.graphics.newImage("Sprites/projects-background.png")
    background:setFilter("linear", "nearest")

    spotlight = love.graphics.newImage("Sprites/UI/projects-spotlight-transparent.png")
    spotlight:setFilter("linear", "nearest")

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

    bassist = {}
    bassist.frame0 = love.graphics.newImage("Sprites/bassist/sprite_0.png")
    bassist.frame0:setFilter("linear", "nearest")
    bassist.frame1 = love.graphics.newImage("Sprites/bassist/sprite_1.png")
    bassist.frame1:setFilter("linear", "nearest")
    bassist.currentFrame = bassist.frame1

    singer = {}
    singer.frame0 = love.graphics.newImage("Sprites/singer/sprite_0.png")
    singer.frame0:setFilter("linear", "nearest")
    singer.frame1 = love.graphics.newImage("Sprites/singer/sprite_1.png")
    singer.frame1:setFilter("linear", "nearest")
    singer.currentFrame = singer.frame1

    splashScreen = {}
    splashScreen.background = love.graphics.newImage("Sprites/Title/title-background.png")
    splashScreen.background:setFilter("linear", "nearest")
    splashScreen.girls = love.graphics.newImage("Sprites/Title/title-girls.png")
    splashScreen.girls:setFilter("linear", "nearest")

    leftNote = love.graphics.newImage("Sprites/UI/notes/left-note.png")
    leftNote:setFilter("linear", "nearest")
    rightNote = love.graphics.newImage("Sprites/UI/notes/right-note.png")
    rightNote:setFilter("linear", "nearest")
    noteTarget = love.graphics.newImage("Sprites/UI/note-target.png")
    noteTarget:setFilter("linear", "nearest")

    startButton = love.graphics.newImage("Sprites/UI/start-button.png")
    startButton:setFilter("linear", "nearest")

end

function functions.initSFX()
    kickDrumSFX = love.audio.newSource("Sound/Drummer/kick-drum.mp3", "static")
    kickDrumSFX:setVolume(8)
    drumHitSFX = love.audio.newSource("Sound/Drummer/drum-hit.mp3", "static")
    drumHitSFX:setVolume(8)
    guitarASFX = love.audio.newSource("Sound/Guitarist/guitar-A.mp3", "static")
    guitarASFX:setVolume(.5)
    guitarESFX = love.audio.newSource("Sound/Guitarist/guitar-E.mp3", "static")
    guitarESFX:setVolume(.5)
    bassASFX = love.audio.newSource("Sound/Bassist/bass-A.mp3", "static")
    bassASFX:setVolume(5)
    bassESFX = love.audio.newSource("Sound/Bassist/bass-E.mp3", "static")
    bassESFX:setVolume(5)
end

return functions