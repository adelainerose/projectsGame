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

function functions.checkNoteFront(beat, subbeat, beatCounter)
    if subbeat < .1 then
        if beatCounter ~= beat then
            keypress = keypress + 1
            score = score + 1
            accuracy = "Perfect!"
        end
    elseif subbeat < .4 then
        if beatCounter ~= beat then
            keypress = keypress + 1
            score = score + 1
            accuracy = "Great!"
        end
    end
    return keypress, score, accuracy
end

function functions.checkNoteEnd(beat, subbeat, beatCounter)
    if subbeat > .9 then
        if beatCounter ~= beat then
            keypress = keypress + 1
            score = score + 1
            accuracy = "Perfect!"
        end
    elseif subbeat > .6 then
        if beatCounter ~= beat then
            keypress = keypress + 1
            score = score + 1
            accuracy = "Great!"
        end
    elseif subbeat <= 0.6 and subbeat >= 0.4 then
        keypress = 0
        accuracy = "Bad."
        score = score - 1
    end
end

 return functions