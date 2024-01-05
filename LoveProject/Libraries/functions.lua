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
        functions.generateNotes(i, 3, 6.5)
    end
    for i = ((2*numBeats)/3),numBeats,1 do
        functions.generateNotes(i, 2, 6)
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



function functions.initSprites()
    background = love.graphics.newImage("Sprites/projects-background.png")
    background:setFilter("linear", "nearest")

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

return functions