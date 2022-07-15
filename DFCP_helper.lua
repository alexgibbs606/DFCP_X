------------------------------------------------------------------------------------------------------------
-- TABLES OF AIRCRAFT REFERENCE DATA------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

-- which aircraft are we supporting (keys for lookup)
local aircraft_list = {"default", "mig21", "mig29s", "mirage2000", "f4", "f5", "f14"} -- todo: fill this out







-- AIRCRAFT PATROL SPEEDS ----------------------------------------------------------------------------------
-- TODO: confirm what this speed is, we think it's "indicated", not "ground"
local patrol_reference_05k = {}
patrol_reference_05k["default"] = 605

local patrol_reference_10k = {}
patrol_reference_10k["default"] = 610

local patrol_reference_15k = {}
patrol_reference_15k["default"] = 615

local patrol_reference_20k = {}
patrol_reference_20k["default"] = 620

local patrol_reference_30k = {}
patrol_reference_30k["default"] = 630

local patrol_reference_40k = {}
patrol_reference_40k["default"] = 640







-- AIRCRAFT INTERCEPT SPEEDS -------------------------------------------------------------------------------
-- TODO: confirm what this speed is, we think it's "indicated", not "ground"
local intercept_reference_05k = {}
intercept_reference_05k["default"] = 905

local intercept_reference_10k = {}
intercept_reference_10k["default"] = 910

local intercept_reference_15k = {}
intercept_reference_15k["default"] = 915

local intercept_reference_20k = {}
intercept_reference_20k["default"] = 920

local intercept_reference_30k = {}
intercept_reference_30k["default"] = 930

local intercept_reference_40k = {}
intercept_reference_40k["default"] = 940






-- internal functions --------------------------------------------------------------------------------------

local function aircraft_check(query_aircraft)
    -- sanity check that the user provided a valid aircraft name
    for index, aircraft in ipairs(aircraft_list) do
        if aircraft == query_aircraft then
            return true
        end
    end
    return nil
end

local function get_speed(ref_altitude, aircraft, altitude_feet)
    -- helper function to get the intercept speed or the patrol speed in the same way
    -- check input
    assert(altitude_feet<50000, "choose an altitude below 50k")
    assert(aircraft_check(aircraft), "invalid aircraft")

    local chosen_table
    local min_diff = 1000000000
    for index, table_altitude in pairs(ref_altitude) do
        diff = altitude_feet - table_altitude[1]
        if diff < 0 then -- absolute value
            diff = diff * -1
        end
        if  diff < min_diff then
            min_diff = diff
            chosen_table = table_altitude[2]
        end
    end
    
    if chosen_table[aircraft] ~= nil then
        return chosen_table[aircraft]
    end
    return chosen_table["default"]
end







-- external helper functions --------------------------------------------------------------------------------------
-- shouldn't normally be needed, but nice helpers to have...
function feet_to_meters(feet)
    return feet * 0.3048
end

function knots_to_kph(knots)
    return 1.852 * knots
end

function get_patrol_speed(aircraft, altitude_feet)
    -- given an aircraft type, and altitude in feet, return our best guess at a good PATROL speed for that plane in KPH
    local ref_altitude = {patrol_reference_05k = {5000,  patrol_reference_05k}, -- this is an ugly hack because I don't know how tables work, wtf is this key
                          patrol_reference_10k = {10000, patrol_reference_10k},
                          patrol_reference_15k = {15000, patrol_reference_15k},
                          patrol_reference_20k = {20000, patrol_reference_20k},
                          patrol_reference_30k = {30000, patrol_reference_30k},
                          patrol_reference_40k = {40000, patrol_reference_40k},}
    return get_speed(ref_altitude, aircraft, altitude_feet)
end

function get_intercept_speed(aircraft, altitude_feet)
    -- given an aircraft type, and altitude in feet, return our best guess at a good INTERCEPT speed for that plane in KPH

    local ref_altitude = {intercept_reference_05k = {5000,  intercept_reference_05k}, -- this is an ugly hack because I don't know how tables work, wtf is this key
                          intercept_reference_10k = {10000, intercept_reference_10k},
                          intercept_reference_15k = {15000, intercept_reference_15k},
                          intercept_reference_20k = {20000, intercept_reference_20k},
                          intercept_reference_30k = {30000, intercept_reference_30k},
                          intercept_reference_40k = {40000, intercept_reference_40k},}
    return get_speed(ref_altitude, aircraft, altitude_feet)
end







-- external functions --------------------------------------------------------------------------------------
-- the real reason why we're learning LUA


function dfcp_create_interceptors(a2a_dispatcher, moose_name, dcs_unit_prefix, plane_type, airport, groups_of, stockpile_count)
    -- Create a stockpile of planes to be used as interceptors.
    -- Note: stockpile_count planes exist. Up to stockpile_count can be launched, simultaneously, if there are enough threatening planes
    --
    -- args:
    -- a2a_dispatcher: moose A2ADispatcher object
    -- moose_name: unique name moose will use to reference this group
    -- dcs_unit_prefix: prefix of the name of the unit(s) in the mission that moose will randomly clone to make this flight
    -- plane_type: name of the plane type in aircraft_list in this file(default, mig21, mirage2000, f14, etc.) -- used to automatically set speeds
    -- airport: moose airport object from https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Wrapper.Airbase.html##(AIRBASE).AirbaseName
    -- groups_of: how many will be launched as 1 flight
    -- stockpile_count: how many planes are available from this group
    
    
    a2a_dispatcher:SetSquadron(moose_name, airport, { dcs_unit_prefix }, stockpile_count )
    local intercept_speed = get_intercept_speed(plane_type, 15000)
    a2a_dispatcher:SetSquadronGci(moose_name, intercept_speed, intercept_speed)
    a2a_dispatcher:SetSquadronGrouping(moose_name, groups_of)
end



local known_cap_zones = {}

function dfcp_create_cap(a2a_dispatcher, moose_name, dcs_unit_prefix, plane_type, airport, cap_zone, altitude_ft, groups_of, stockpile_count )
    -- Create a CAP flight that can replenish losses or RTB's, used for CAP *only*!
    -- NOTE: every CAP flight created can launch simultaneously, regardless of detected threat!
    --
    -- args:
    -- a2a_dispatcher: moose A2ADispatcher object
    -- moose_name: unique name moose will use to reference this group
    -- dcs_unit_prefix: prefix of the name of the unit(s) in the mission that moose will randomly clone to make this flight
    -- plane_type: name of the plane type in aircraft_list in this file(default, mig21, mirage2000, f14, etc.) -- used to automatically set speeds
    -- airport: moose airport object from https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Wrapper.Airbase.html##(AIRBASE).AirbaseName
    -- cap_zone: name of the dcs mission editor zone to patrol within
    -- altitude_ft: patrol altitude in feet
    -- groups_of: how many will be launched as 1 flight
    -- stockpile_count: how many planes are available from this group
    
    -- get the cap zone
    current_zone = known_cap_zones[zone_name]
    if current_zone == nil then
        known_cap_zones[zone_name] = ZONE:New(zone_name)
        current_zone = known_cap_zones[zone_name]
    end
    
    a2a_dispatcher:SetSquadron(moose_name, airport, { dcs_unit_prefix }, stockpile_count )
    local intercept_speed = get_intercept_speed(plane_type, altitude_ft)
    local patrol_speed = get_patrol_speed(plane_type, altitude_ft)
    local altitude_m = feet_to_meters(altitude_ft)
    A2ADispatcher:SetSquadronCap(moose_name, cap_zone,
                                 altitude_m, altitude_m, -- min/max patrol altitude (m)
                                 patrol_speed, patrol_speed, -- min/max patrol speed (kmh)
                                 intercept_speed, intercept_speed, -- min/max intercept speed (kmh) 
                                 "BARO") -- "RADIO" altitude, or "BARO" altitude
    a2a_dispatcher:SetSquadronGrouping(moose_name, groups_of)
end




function dfcp_create_default_iads(red_iads)
    red_iads:addSAMSitesByPrefix('sam')
    red_iads:addEarlyWarningRadarsByPrefix('ew')
end




function dfcp_create_default_dispatcher(spawn_overhead)
    -- set up a default dispatcher that can integrate with IADS
    --
    -- args: 
    -- spawn_overhead: if true planes will spawn above the runway (improves scramble time)


    -- Setup the detection to group targets to a 30km range (planes within 30km of eachother are considered 1 "group")
    -- engagement decisions are based on the number of "groups" detected.
    DetectionSetGroup = SET_GROUP:New()
    Detection = DETECTION_AREAS:New( DetectionSetGroup, 30000 )

    -- Setup the A2A dispatcher, CAP will engage anything within 200km, interceptors will scramble to anything within 200km of the airport
    A2ADispatcher = AI_A2A_DISPATCHER:New( Detection )
    A2ADispatcher:SetEngageRadius(200000) -- CAP range
    A2ADispatcher:SetGciRadius(200000) -- Intercept range

    -- define borders using a late spawn helicopter named RED-BORDER, don't spawn the heli
    RedBorderZone = ZONE_POLYGON:New( "red_border", GROUP:FindByName( "red_border" ) )
    A2ADispatcher:SetBorderZone( RedBorderZone )

    if spawn_overhead == true then
        A2ADispatcher:SetSquadronTakeoffInAir()
    else
        A2ADispatcher:SetDefaultTakeoffFromRunway()
    end
    A2ADispatcher:SetDefaultLandingAtRunway()
end




function dfcp_start_mission(red_iads, a2a_dispatcher, debug)
    -- helper to handle debug settings, etc.
    if debug == 1 then -- DEBUG MISSION START
        red_iads.activate()
            -- IADS debug info config
            -- TODO: find a good template of what to enable here.
            local iadsDebug = red_iads:getDebugSettings()
            iadsDebug.IADSStatus = true
            iadsDebug.radarWentDark = true
            iadsDebug.contacts = true
            iadsDebug.radarWentLive = true
            iadsDebug.noWorkingCommmandCenter = true
            iadsDebug.ewRadarNoConnection = true
            iadsDebug.samNoConnection = true
            iadsDebug.jammerProbability = true
            iadsDebug.addedEWRadar = true
            iadsDebug.hasNoPower = false
            iadsDebug.harmDefence = true
            iadsDebug.samSiteStatusEnvOutput = true
            iadsDebug.earlyWarningRadarStatusEnvOutput = true
            iadsDebug.commandCenterStatusEnvOutput = true
        
            -- MOOSE:A2ADispatcher debug
            a2a_dispatcher:SetTacticalDisplay(true)
        
            -- test to see which groups are added and removed to the SET_GROUP at runtime by Skynet:
            function outputNames()
                env.info("IADS Radar Groups added by Skynet:")
                env.info(DetectionSetGroup:GetObjectNames())
            end
            mist.scheduleFunction(outputNames, self, 1, 2)
    
    else -- NORMAL MISSION START
        red_iads.setupSAMSitesAndThenActivate()
    end
end