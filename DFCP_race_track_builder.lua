-- local track_penalty_seconds = 2
local race_name = ''
local track_start_line = nil
local track_finish_line = nil
local track_lap_count = 1
local track_racers = {}
-- local track_zone_list = {}
-- local check_inside_track_zones = true

-- local race_track_scheduler = nil
-- local out_of_bounds_scheduler = nil



--[[----------------------------------------------------------------------------------------------------------
dfcp_race_track

Create a race track from a specified startZone, the number of laps, and any trackZones

Parameters:
    track_name - string - name of the race track
    start_zone - string - name of the zone that makes up the start line
    laps - number - the number of laps in the race, if nil 1 is assumed
    track_zones - table - array of ZONE objects that denote the track. If provided any racer that leaves these
                         zones will receive a penalty
    check_inside - boolean - default true, if true then penalize racers when they go OUTSIDE
                             of the track_zones
    race_penalty - number - number of seconds of penalty incurred for leaving track_zones
------------------------------------------------------------------------------------------------------------]]
-- function dfcp_race_track(start_zone, laps, track_zones, check_inside, race_penalty)
function dfcp_race_track(track_name, start_zone, laps)
    
    race_track_name = track_name
    
    print("DFCP - dfcp_race_track - attempting to build track "..race_track_name)
    dfcp_logger("DFCP - dfcp_race_track - attempting to build track "..race_track_name)
    
    -- if race_penalty then
    --     print("DFCP - dfcp_race_track - race penalty updated")
    --     dfcp_logger("DFCP - dfcp_race_track - attempting to build track")
        
    --     track_penalty_seconds = race_penalty
    -- end
    
    track_start_line = ZONE:FindByName(start_zone)
    print("DFCP - dfcp_race_track - start-finish line zone identified")
    dfcp_logger("DFCP - dfcp_race_track - start-finish line zone identified")
    
    track_lap_count = laps
    
    -- track_zone_list = track_zones
    -- if check_inside == false and check_inside ~= nil then
    --     check_inside_track_zones = false
    -- end
    
    -- if track_zone_list ~= nil then
    --     dfcp_start_out_of_bounds_checks()
    -- end
    
    race_track_scheduler = SCHEDULER:New(nil,
        function()
            
            local player_units = _DATABASE:GetPlayers()
            for player_name, unit_name in pairs(player_units) do
                
                pcall(function ()
                
                    -- mist.message.add({
                    --     text = player_name .. " | " .. unit_name,
                    --     displayTime = 15,
                    --     msgFor = {coa={'all'}}
                    -- })
                    
                    -- The person has spawned in but hasn't started the race
                    if track_racers[player_name] == nil then
                        dfcp_logger("DFCP - dfcp_race_track - SCHEDULER - new racer " .. player_name)
                        
                        mist.message.add({
                            text = "New racer identified! Welcome " .. player_name .. '!',
                            displayTime = 15,
                            msgFor = {units={unit_name}}
                        })
                        
                        track_racers[player_name] = {
                            player_name = player_name,
                            progress_flag = 0,
                            lap = 0,
                            finished = false
                        }
                        
                    elseif track_racers[player_name].finished == false and UNIT:FindByName(unit_name):IsInZone(track_start_line) then
                        -- Once the racer crosses the start line for the first time, kick it off for them
                        
                        dfcp_logger("DFCP - dfcp_race_track - SCHEDULER - " .. player_name .. " in zone")
                        
                        if track_racers[player_name].progress_flag == 0 then
                            track_racers[player_name].progress_flag = 1
                            track_racers[player_name].lap = 1
                            
                            dfcp_logger("DFCP - dfcp_race_track - SCHEDULER - " .. player_name .. " start!")
                            
                            local start_msg = Stopwatch:Start(player_name)
                            
                            dfcp_logger(start_msg)
                            net.send_chat(start_msg)
                            
                            mist.message.add({
                                text = 'GO!',
                                displayTime = 5,
                                msgFor = {units={unit_name}}
                            })
                            
                            
                        elseif math.fmod(track_racers[player_name].progress_flag, 2) == 0 then
                            -- When the racer enters the start line, check to see if they're completing a lap
                            
                            track_racers[player_name].progress_flag = track_racers[player_name].progress_flag + 1
                            track_racers[player_name].lap = track_racers[player_name].lap + 1
                            
                            local lap_msg = Stopwatch:Lap(player_name)
                            
                            dfcp_logger(lap_msg)
                            net.send_chat(lap_msg)
                            -- mist.message.add({
                            --     text = lap_msg,
                            --     displayTime = 15,
                            --     msgFor = {coa={'all'}}
                            -- })
                            
                            if track_racers[player_name].lap > track_lap_count then
                                track_racers[player_name].finished = true
                                
                                local stop_msg = Stopwatch:Stop(player_name)
                                
                                dfcp_logger(stop_msg)
                                net.send_chat(stop_msg)
                                
                                mist.message.add({
                                    text = 'Finish! ' .. stop_msg,
                                    displayTime = 30,
                                    msgFor = {units={unit_name}}
                                })
                                
                                pcall(function () 
                                    BotSay(race_track_name.."|"..Stopwatch:GetStopwatchExportString(player_name))
                                end)
                                
                            end
                        end
                    
                    elseif UNIT:FindByName(unit_name):IsNotInZone(track_start_line) then
                        -- When they leave the start zone allow them to trigger the next lap
                        
                        if math.fmod(track_racers[player_name].progress_flag, 2) == 1 then
                            track_racers[player_name].progress_flag = track_racers[player_name].progress_flag + 1
                        end
                        
                        if track_racers[player_name].finished == true then
                            track_racers[player_name] = {
                                player_name = player_name,
                                unit = unit,
                                progress_flag = 0,
                                lap = 0,
                                finished = false
                            }
                        end
                    end
                end)
                
            end
        end,
    {}, 0, 0.5)
    
end



--[[----------------------------------------------------------------------------------------------------------
dfcp_race_point_to_point

Create a race track from a specified startZone to a specified endZone, the number of laps, and any trackZones

Parameters:
    track_name - string - name of the race track
    start_zone - string - name of the zone that makes up the start line
    end_zone - string - name of the zone that makes up the finish line
    track_zones - table - array of ZONE objects that denote the track. If provided any racer that leaves these
                         zones will receive a penalty
    check_inside - boolean - default true, if true then penalize racers when they go OUTSIDE
                             of the track_zones
    race_penalty - number - number of seconds of penalty incurred for leaving track_zones
------------------------------------------------------------------------------------------------------------]]
-- function dfcp_race_point_to_point(start_zone, end_zone, track_zones, check_inside, race_penalty)
function dfcp_race_point_to_point(track_name, start_zone, end_zone)
    
    race_track_name = track_name
    
    print("DFCP - dfcp_race_point_to_point - attempting to build track "..race_track_name)
    dfcp_logger("DFCP - dfcp_race_point_to_point - attempting to build track "..race_track_name)
    
    -- if race_penalty then
    --     print("DFCP - dfcp_race_point_to_point - race penalty updated")
    --     dfcp_logger("DFCP - dfcp_race_point_to_point - attempting to build track")
        
    --     track_penalty_seconds = race_penalty
    -- end
    
    track_start_line = ZONE:FindByName(start_zone)
    if track_start_line ~= nil then
        print("DFCP - dfcp_race_point_to_point - start line zone identified")
        dfcp_logger("DFCP - dfcp_race_point_to_point - start line zone identified")
    else
        print("DFCP - dfcp_race_point_to_point - ERROR - start line zone could not be identified")
        dfcp_logger("DFCP - dfcp_race_point_to_point - ERROR - start line zone could not be identified")
        return
    end
    
    track_finish_line = ZONE:FindByName(end_zone)
    if track_finish_line ~= nil then
        print("DFCP - dfcp_race_point_to_point - finish line zone identified")
        dfcp_logger("DFCP - dfcp_race_point_to_point - finish line zone identified")
    else
        print("DFCP - dfcp_race_point_to_point - ERROR - start line zone could not be identified")
        dfcp_logger("DFCP - dfcp_race_point_to_point - ERROR - start line zone could not be identified")
        return
    end
    
    -- track_zone_list = track_zones
    -- if check_inside == false and check_inside ~= nil then
    --     check_inside_track_zones = false
    -- end
    
    -- if track_zone_list ~= nil then
    --     dfcp_start_out_of_bounds_checks()
    -- end
    
    race_track_scheduler = SCHEDULER:New(nil,
        function()
            
            local player_units = _DATABASE:GetPlayers()
            for player_name, unit_name in pairs(player_units) do
                
                
                pcall(function ()
                    
                    -- mist.message.add({
                    --     text = player_name .. " | " .. unit_name,
                    --     displayTime = 1,
                    --     msgFor = {coa={'all'}}
                    -- })
                    
                    -- The person has spawned in but hasn't started the race
                    if track_racers[player_name] == nil then
                        dfcp_logger("DFCP - dfcp_race_point_to_point - SCHEDULER - new racer " .. player_name)
                        
                        mist.message.add({
                            text = "New racer identified! Welcome " .. player_name .. '!',
                            displayTime = 15,
                            msgFor = {units={unit_name}}
                        })
                        
                        track_racers[player_name] = {
                            progress_flag = 0
                        }
                    -- else
                    --     mist.message.add({
                    --         text = player_name .. " | " .. track_racers[player_name].progress_flag,
                    --         displayTime = 1,
                    --         msgFor = {coa={'all'}}
                    --     })
                    
                    elseif (track_racers[player_name].progress_flag == 0 or track_racers[player_name].progress_flag == 2) and UNIT:FindByName(unit_name):IsInZone(track_start_line) then
                        dfcp_logger("DFCP - dfcp_race_point_to_point - SCHEDULER - " .. player_name .. " in start zone")
                        
                        -- Once the racer crosses the start line for the first time, kick it off for them
                        if track_racers[player_name].progress_flag == 0 or track_racers[player_name].progress_flag == 2 then
                            track_racers[player_name].progress_flag = 1
                            
                            dfcp_logger("DFCP - dfcp_race_point_to_point - SCHEDULER - " .. player_name .. " start!")
                            
                            local start_msg = Stopwatch:Start(player_name)
                            
                            dfcp_logger(start_msg)
                            net.send_chat(start_msg)
                            
                            mist.message.add({
                                text = 'GO!',
                                displayTime = 5,
                                msgFor = {units={unit_name}}
                            })
                            
                        end
                        
                        -- When they leave the start zone allow them to trigger the finish
                    elseif track_racers[player_name].progress_flag == 1 and UNIT:FindByName(unit_name):IsNotInZone(track_start_line) then
                        dfcp_logger("DFCP - dfcp_race_point_to_point - SCHEDULER - " .. player_name .. " left start zone")
                        track_racers[player_name].progress_flag = track_racers[player_name].progress_flag + 1
                        
                        -- Check for the racer in the finish zone
                    elseif track_racers[player_name].progress_flag == 2 and UNIT:FindByName(unit_name):IsInZone(track_finish_line) then
                        dfcp_logger("DFCP - dfcp_race_point_to_point - SCHEDULER - " .. player_name .. " in finish zone")
                        
                        local stop_msg = Stopwatch:Stop(player_name)
                        
                        dfcp_logger(stop_msg)
                        net.send_chat(stop_msg)
                        
                        -- mist.message.add({
                        --     text = stop_msg,
                        --     displayTime = 15,
                        --     msgFor = {coa={'all'}}
                        -- })
                        -- mist.message.add({
                        --     text = Stopwatch:GetStopwatchExportString(player_name),
                        --     displayTime = 15,
                        --     msgFor = {coa={'all'}}
                        -- })
                        
                        mist.message.add({
                            text = 'Finish! ' .. stop_msg,
                            displayTime = 30,
                            msgFor = {units={unit_name}}
                        })
                        
                        pcall(function () 
                            BotSay(race_track_name .. "|" .. Stopwatch:GetStopwatchExportString(player_name))
                        end)
                        
                        track_racers[player_name].progress_flag = track_racers[player_name].progress_flag + 1
                        
                        -- When they leave the finish zone reset them
                    elseif track_racers[player_name].progress_flag == 3 and UNIT:FindByName(unit_name):IsNotInZone(track_finish_line) then
                        dfcp_logger("DFCP - dfcp_race_point_to_point - SCHEDULER - " .. player_name .. " left finish zone")
                        track_racers[player_name] = {
                            progress_flag = 0
                        }
                    end
                end)
                
            end
        end,
    {}, 0, 0.5)

end



--[[----------------------------------------------------------------------------------------------------------
dfcp_start_out_of_bounds_checks

Check for any racers either in or outside of the track zones

Parameters:
    track_zones - table - array of strings that denote the track. If provided any racer that leaves these
                          zones will receive a penalty
------------------------------------------------------------------------------------------------------------]]
-- function dfcp_start_out_of_bounds_checks()
    
--     dfcp_logger("DFCP - dfcp_start_out_of_bounds_checks - starting out of bounds checks")
    
--     out_of_bounds_scheduler = SCHEDULER:New(nil,
--         function()
--             for racer in track_racers do
--                 for zone in track_zone_list do
--                     if racer.unit:IsInZone(zone) then
--                         dfcp_logger("DFCP - dfcp_start_out_of_bounds_checks - SCHEDULER - racer "..racer.player_name.." out of bounds")
--                         Stopwatch:Penalty(racer.player_name, track_penalty_seconds, 'Out of bounds: '..zone:GetName())
--                     end
--                 end
--             end
--         end,
--     {}, 0, 0.5)
    
-- end
