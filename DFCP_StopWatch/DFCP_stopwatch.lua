------------------------------------------------------------------------------------------------------------
-- Stopwatch class - adapted from code by Geigerkind -------------------------------------------------------
-- https://github.com/Geigerkind/StopWatch/blob/master/StopWatch.lua ---------------------------------------
------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------
-- Model
------------------------------------------------------------------------------------------------------------
--
-- Stopwatches = {
--     "race_pilot 1-1" = {
--         startTime: number - number of milliseconds from lua start - return from getClock()
--         penalty: number - number of seconds penalized for breaking rules
--         penaltyCount: number - total number of penalties for breaking rules
--         pendingPenalty: number - number of seconds to penalize on the current lap
--         pendingPenaltyCount : number - total number of penalties on the current lap
--         endTime: number - number of milliseconds from lua start - return from getClock()
--         laps: {
--             {
--                 lapStart: number - getClock() of the start of the lap - if no other laps exist when this
--                                    is called, it is equal to the startTime of the Stopwatch for the
--                                    unitName when it was created, else it is equal to the last lap's lapEnd
--                 lapPenalty: number - number of seconds penalized this lap for breaking rules
--                 lapPenaltyCount: number - the total number of penalites for breaking rules
--                 lapEnd: number - getClock() value when the Lap function is called
--                 lapTime: number - total milliseconds between lapStart and lapEnd
--                 display: string - friendly display of the lapTime HH:MM:SS:mm
--             }
--             ...
--         }
--         duration: number - number of milliseconds between startTime and endTime
--         display: string - friendly display of duration or "DNF" if the status is requested before the
--                           stop watch is stopped
--     },
--     ...
-- }
--
------------------------------------------------------------------------------------------------------------
StopwatchVersion = 1


------------------------------------------------------------------------------------------------------------
-- Global Variables
------------------------------------------------------------------------------------------------------------
Stopwatch = {}
Stopwatches = {}

if env then
    if os then
        env.info("DFCP_stopwatch - os is available!")
    else
        env.error("DFCP_stopwatch - os is not available and clock times cannot not be retrieved")
        env.error("-- comment out the `sanitizeModule('os')` line in the server's MissionScripting.lua file")
    end
end

function getClock()
    if os then
        return os.clock()
    end
    
    return 0
end


------------------------------------------------------------------------------------------------------------
-- START
--
-- Create and start, or reset and start a stopwatch for the specified unitName. If a stop watch already exists
-- for the unitName provided, it will be reset to an initialized state and started, else the stop watch will
-- be started
--
-- Parameters:
--     unitName - string - the identifier of the unit the stop watch is being started for
--
-- Return:
--     string - friendly message displaying the creation of the stop watch
------------------------------------------------------------------------------------------------------------
function Stopwatch:Start(unitName)
    Stopwatches[unitName] = {
        startTime = getClock(),
        penalty = 0,
        penaltyCount = 0,
        pendingPenalty = 0,
        pendingPenaltyCount = 0,
        laps = {},
        endTime = 0,
        duration = 0,
        display = "DNF"
    }
    
    print("Stop watch created for " .. unitName)
    print(Stopwatches[unitName].startTime)
    
    return unitName .. " | " .. "Stop watch started"
end


------------------------------------------------------------------------------------------------------------
-- Lap
--
-- Record a new lap time for the specified unitName. A new lap object will be added each time the function
-- is called as long as the stop watch for the specified unitName exists and hasn't been stopped.
--
-- Parameters:
--     unitName - string - the identifier of the unit the stop watch belongs to
--
-- Return:
--     string - friendly message displaying the duration of the lap
------------------------------------------------------------------------------------------------------------
function Stopwatch:Lap(unitName)
    
    if Stopwatches[unitName] == nil then
        return
    else
        if Stopwatches[unitName].endTime == 0 then
            
            local lap = {
                lapPenalty = Stopwatches[unitName].pendingPenalty,
                lapPenaltyCount = Stopwatches[unitName].pendingPenaltyCount,
                lapEnd = getClock() + Stopwatches[unitName].pendingPenalty
            }
            
            Stopwatches[unitName].pendingPenalty = 0
            Stopwatches[unitName].pendingPenaltyCount = 0
            
            if next(Stopwatches[unitName].laps) == nil then
                lap.lapStart = Stopwatches[unitName].startTime
            else
                lap.lapStart = Stopwatches[unitName].laps[#Stopwatches[unitName].laps].lapEnd
            end
            
            lap.lapTime = lap.lapEnd - lap.lapStart
            lap.display = Stopwatch:TimeFormat(lap.lapTime)
            
            table.insert(Stopwatches[unitName].laps, lap)
            
            print("Lap created for " .. unitName)
            print(unitName .. " | Lap " .. #Stopwatches[unitName].laps .. " | " .. lap.lapStart .. " | " .. lap.lapEnd .. " | " .. lap.lapTime .. " | " .. lap.display .. " | " .. lap.lapPenalty .. " | " .. lap.lapPenaltyCount)
            
            if lap.lapPenaltyCount > 0 then
                return unitName .. " | Lap " .. #Stopwatches[unitName].laps .. " | " .. lap.display .. " | " .. lap.lapPenalty .. " second penalty"
            else
                return unitName .. " | Lap " .. #Stopwatches[unitName].laps .. " | " .. lap.display
            end
        end
    end
    
end


------------------------------------------------------------------------------------------------------------
-- Penalty
--
-- Effectively add the specified number of seconds to the specified unitName's lap time and overall time
--
-- Parameters:
--     unitName - string - the identifier of the unit the stop watch belongs to
--     seconds - number - the number of seconds to penalize the specified unitName
--
-- Return:
--     string - friendly message displaying the penalty
------------------------------------------------------------------------------------------------------------
function Stopwatch:Penalty(unitName, seconds, reason)
    
    if Stopwatches[unitName] == nil then
        return
    else
        if Stopwatches[unitName].endTime == 0 then
            
            Stopwatches[unitName].penalty = Stopwatches[unitName].penalty + seconds
            Stopwatches[unitName].penaltyCount = Stopwatches[unitName].penaltyCount + 1
            
            Stopwatches[unitName].pendingPenalty = Stopwatches[unitName].pendingPenalty + seconds
            Stopwatches[unitName].pendingPenaltyCount = Stopwatches[unitName].pendingPenaltyCount + 1
            
            if reason then
                return unitName .. " | Penalty | " .. seconds .. " | Reason: " .. reason
            else
                return unitName .. " | Penalty | " .. seconds
            end
        end
    end
end



------------------------------------------------------------------------------------------------------------
-- Stop
--
-- Stop the stop watch for the specified unitName if it exists. If it doesn't exist, do nothing.
--
-- Parameters:
--     unitName - string - the identifier of the unit the stop watch belongs to
--
-- Return:
--     string - friendly message displaying the total duration of the stop watch
------------------------------------------------------------------------------------------------------------
function Stopwatch:Stop(unitName, closeLap)
    
    if Stopwatches[unitName] == nil then
        return
    else
        if Stopwatches[unitName].endTime == 0 then
            
            Stopwatches[unitName].endTime = getClock()
            Stopwatches[unitName].duration = Stopwatches[unitName].endTime - Stopwatches[unitName].startTime + Stopwatches[unitName].penalty
            Stopwatches[unitName].display = Stopwatch:TimeFormat(Stopwatches[unitName].duration)
            
            print("Stop watch stopped for " .. unitName)
            print(unitName .. " | " .. Stopwatches[unitName].startTime .. " | " .. Stopwatches[unitName].endTime .. " | " .. Stopwatches[unitName].duration .. " | " .. Stopwatches[unitName].display .. " | " .. Stopwatches[unitName].penalty .. " | " .. Stopwatches[unitName].penaltyCount)
            
            if Stopwatches[unitName].penaltyCount > 0 then
                return unitName .. " | Total Time | " .. Stopwatches[unitName].display .. " | including " .. Stopwatches[unitName].penalty .. " seconds in penalties"
            else
                return unitName .. " | Total Time | " .. Stopwatches[unitName].display
            end
        end
    end
end


------------------------------------------------------------------------------------------------------------
-- Reset
--
-- Same as calling Stopwatch:Start
--
-- Parameters:
--     unitName - string - the identifier of the unit the stop watch belongs to
------------------------------------------------------------------------------------------------------------
function Stopwatch:Reset(unitName)
    Stopwatch:Start(unitName)
end


------------------------------------------------------------------------------------------------------------
-- TimeFormat
--
-- Parse a number into a friendly time format.
--
-- Parameters:
--     time - number - a number of milliseconds needed to be parsed into a firendly time
--
-- Return:
--     string - friendly, readable display of the milliseconds number provided in the format: HH:MM:SS:mm
------------------------------------------------------------------------------------------------------------
function Stopwatch:TimeFormat(time)
    local hour, minutes, seconds, mili = 0, 0, 0, 0
    local hour_s, minutes_s, seconds_s, mili_s = '', '', '', ''
    
    hour = math.floor(time / 3600)
    if hour < 10 then
        hour_s = "0" .. hour
    else
        hour_s = hour .. ''
    end
    
    minutes = math.floor((time - math.floor(time / 3600) * 3600) / 60)
    if minutes < 10 then
        minutes_s = "0" .. minutes
    else
        minutes_s = minutes .. ''
    end
    
    seconds = math.floor(time - math.floor(time / 3600) * 3600 - math.floor((time - math.floor(time / 3600) * 3600) / 60) * 60)
    if seconds < 10 then
        seconds_s = "0" .. seconds
    else
        seconds_s = seconds .. ''
    end
    
    mili = math.floor((
        time - math.floor(time / 3600) * 3600 - math.floor((time - math.floor(time / 3600) * 3600) / 60) * 60 -
        math.floor(time - math.floor(time / 3600) * 3600 - math.floor((time - math.floor(time / 3600) * 3600) / 60) * 60)) * 100)
    if mili < 10 then
        mili_s = "0" .. mili
    else
        mili_s = mili .. ''
    end
    return hour_s .. ":" .. minutes_s .. ":" .. seconds_s .. ":" .. mili_s
end


------------------------------------------------------------------------------------------------------------
-- GetStopwatch
--
-- Returns the stop watch object for the specifed unitName if it exists
--
-- Parameters:
--     unitName - string - the identifier of the unit the stop watch belongs to
--
-- Return:
--     StopwatchObject | {} - the whole stop watch object associated to the specified unitName
------------------------------------------------------------------------------------------------------------
function Stopwatch:GetStopwatch(unitName)
    if next(Stopwatches, unitName) == nil then
        return {}
    else
        return Stopwatches[unitName]
    end
end


------------------------------------------------------------------------------------------------------------
-- GetStopwatchStatus
--
-- Returns the status of the stop watch 
--
-- Parameters:
--     unitName - string - the identifier of the unit the stop watch belongs to
--
-- Return:
--     string - "DNF" if the stop watch does not exist or is not yet stopped or a friendly message with the
--              total time duration of the stop watch
------------------------------------------------------------------------------------------------------------
function Stopwatch:GetStopwatchStatus(unitName)
    if next(Stopwatches, unitName) == nil then
        return "DNF"
    else
        if Stopwatches[unitName].endTime == 0 then
            return unitName .. " | Total Time | DNF"
        else
            return unitName .. " | Total Time | " .. Stopwatches[unitName].display
        end
    end
end

if env then
    env.info(('DFCP_Stopwatch version ' .. StopwatchVersion .. ' loaded.'))
end
