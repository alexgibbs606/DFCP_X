-- USAGE
-- Don't mix SAM unit types (ie, 1 group should not have SA-10 AND SA-15)
-- When placing multi unit SAM sites, unit 1 in each SAM group should be the search radar (or tracking radar?)
-- EW needs to set the UNIT name, not the GROUP name
-- RELOAD THE SCRIPT FILE IN THE MISSION EDITOR EVERY TIME YOU CHANGE THIS FILE
-- My style guide: all unit/zone names are no_caps_with_underscores, trailing numbers use dashes instead to work with dcs copy logic

do
    redIADS = SkynetIADS:create('red')
    redIADS:addSAMSitesByPrefix('sam')
    redIADS:addEarlyWarningRadarsByPrefix('ew')

    -- power/command config
    local command_center = StaticObject.getByName("iads_cp")
    local power_zone1 = StaticObject.getByName("power_zone-1")
    -- local power_zone2 = StaticObject.getByName("power_zone2")


    redIADS:addCommandCenter(command_center):addPowerSource(power_zone1)


    -- Point Defence Configuration:
    -- redIADS:getSAMSiteByGroupName('SAM-SA-10-1'):addPowerSource(power_zone1)
    -- redIADS:getSAMSiteByGroupName('SAM-SA-10-1'):addPointDefence(redIADS:getSAMSiteByGroupName('SAM-SA-15-1'))

    redIADS:activate()
    -- redIADS:setupSAMSitesAndThenActivate()


    -- A2A Config
    -- TESTING MOOSE A2A CAP -- DOCUMENTATION: https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_A2A_Dispatcher.html
    -- Define a SET_GROUP object that builds a collection of groups that define the EWR network.
    DetectionSetGroup = SET_GROUP:New()

    -- Setup the detection and group targets to a 30km range!
    Detection = DETECTION_AREAS:New( DetectionSetGroup, 30000 )

    -- Setup the A2A dispatcher, and initialize it.
    A2ADispatcher = AI_A2A_DISPATCHER:New( Detection )

    -- Set 200km as the radius to engage any target by airborne friendlies.
    A2ADispatcher:SetEngageRadius(200000) -- 100000 is the default value.

    -- Set 200km as the radius to ground control intercept.
    A2ADispatcher:SetGciRadius(200000) -- 200000 is the default value.

    -- define borders using a late spawn helicopter named RED-BORDER, don't spawn the heli
    RedBorderZone = ZONE_POLYGON:New( "red_border", GROUP:FindByName( "red_border" ) )
    A2ADispatcher:SetBorderZone( RedBorderZone )

    A2ADispatcher:SetDefaultTakeoffFromRunway()
    A2ADispatcher:SetDefaultLandingAtRunway()


    -- squadrons configuration
        -- airbase names: https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Wrapper.Airbase.html##(AIRBASE).AirbaseName
    --                           variablename,     location,              , { "flight name"}, # available

    -- SetSquadron( "Kutaisi", AIRBASE.Caucasus.Kutaisi, { "Squadron red SU-27" }, 2 )
    -- SetSquadronGrouping( "squadname", group-size)

    speed_i_default = 900
    speed_i_m2000 = 900
    speed_i_mig21 = 900
    speed_i_mig29 = 900
    speed_i_f4 = 900
    speed_i_f5 = 900
    speed_i_f14 = 900

    speed_p_default = 600
    speed_p_m2000 = 600
    speed_p_mig21 = 600
    speed_p_mig29 = 600
    speed_p_f4 = 600
    speed_p_f5 = 600
    speed_p_f14 = 600




-- mirage
-- mig21
-- mig29
-- f4
-- f5
-- f14

    -- far NE
    -- kerman: ~36 total
    A2ADispatcher:SetSquadron( "kerman-mirage", AIRBASE.PersianGulf.Kerman_Airport, { "mirage" }, 0 ) -- 4 reserve
    A2ADispatcher:SetSquadronGci( "kerman-mirage", speed_i_default, speed_i_default)
    A2ADispatcher:SetSquadronGrouping( "kerman-mirage", 2 )

    A2ADispatcher:SetSquadron( "kerman-f4", AIRBASE.PersianGulf.Kerman_Airport, { "f4" }, 0 ) -- 8 reserve
    A2ADispatcher:SetSquadronGci( "kerman-f4", speed_i_default, speed_i_default)
    A2ADispatcher:SetSquadronGrouping( "kerman-f4", 2 )

    A2ADispatcher:SetSquadron( "kerman-f5", AIRBASE.PersianGulf.Kerman_Airport, { "f5" }, 0 ) -- 8 reserve
    A2ADispatcher:SetSquadronGci( "kerman-f5", speed_i_default, speed_i_default)
    A2ADispatcher:SetSquadronGrouping( "kerman-f5", 2 )

    A2ADispatcher:SetSquadron( "kerman-f14", AIRBASE.PersianGulf.Kerman_Airport, { "f14" }, 4 ) -- 0 reserve
    A2ADispatcher:SetSquadronGci( "kerman-f14", speed_i_default, speed_i_default)
    A2ADispatcher:SetSquadronGrouping( "kerman-f14", 2 )

    A2ADispatcher:SetSquadron( "kerman-mig21", AIRBASE.PersianGulf.Kerman_Airport, { "mig21" }, 0 ) -- 12 reserve
    A2ADispatcher:SetSquadronGci( "kerman-mig21", speed_i_default, speed_i_default)
    A2ADispatcher:SetSquadronGrouping( "kerman-mig21", 2 )

    -- Jiroft: ~3 total
    A2ADispatcher:SetSquadron( "jiroft-f14", AIRBASE.PersianGulf.Jiroft_Airport, { "f14" }, 3 ) -- 0 reserve
    A2ADispatcher:SetSquadronGci( "jiroft-f14", speed_i_default, speed_i_default)
    A2ADispatcher:SetSquadronGrouping( "jiroft-f14", 2 )

    -- NW, disabled
    -- AIRBASE.PersianGulf.Shiraz_International_Airport
    

    -- Gulf
    -- tunb: 4 total
    A2ADispatcher:SetSquadron( "tunb-mig21", AIRBASE.PersianGulf.Tunb_Island_AFB, { "mig21" }, 4 ) -- 0 reserve
    A2ADispatcher:SetSquadronGci( "tunb-mig21", speed_i_default, speed_i_default)
    A2ADispatcher:SetSquadronGrouping( "tunb-mig21", 2 )

    -- civ
    A2ADispatcher:SetSquadron( "qeshm-f5", AIRBASE.PersianGulf.Qeshm_Island, { "f5" }, 4 ) -- 0 reserve
    A2ADispatcher:SetSquadronGci( "qeshm-f5", speed_i_default, speed_i_default)
    A2ADispatcher:SetSquadronGrouping( "qeshm-f5", 2 )

    -- far SE, 4 small fighters
    A2ADispatcher:SetSquadron( "jask-f4", AIRBASE.PersianGulf.Bandar_e_Jask_airfield, { "f4" }, 4 ) -- 0 reserve
    A2ADispatcher:SetSquadronGci( "jask-f4", speed_i_default, speed_i_default)
    A2ADispatcher:SetSquadronGrouping( "jask-f4", 2 )

    -- main gulf
    -- abbas: ~14
    A2ADispatcher:SetSquadron( "abbas-f14", AIRBASE.PersianGulf.Bandar_Abbas_Intl, { "f14" }, 4 ) -- 0 reserve
    A2ADispatcher:SetSquadronGci( "abbas-f14", speed_i_default, speed_i_default)
    A2ADispatcher:SetSquadronGrouping( "abbas-f14", 2 )
    
    A2ADispatcher:SetSquadron( "abbas-f4", AIRBASE.PersianGulf.Bandar_Abbas_Intl, { "f4" }, 4 ) -- 0 reserve
    A2ADispatcher:SetSquadronGci( "abbas-f4", speed_i_default, speed_i_default)
    A2ADispatcher:SetSquadronGrouping( "abbas-f4", 2 )
    
    A2ADispatcher:SetSquadron( "abbas-f5", AIRBASE.PersianGulf.Bandar_Abbas_Intl, { "f5" }, 8 ) -- 0 reserve
    A2ADispatcher:SetSquadronGci( "abbas-f5", speed_i_default, speed_i_default)
    A2ADispatcher:SetSquadronGrouping( "abbas-f5", 2 )

    --havadarya: ~8
    A2ADispatcher:SetSquadron( "havadarya-mig29", AIRBASE.PersianGulf.Havadarya, { "mig29" }, 8 ) -- 0 reserve
    A2ADispatcher:SetSquadronGci( "havadarya-mig29", speed_i_default, speed_i_default)
    A2ADispatcher:SetSquadronGrouping( "havadarya-mig29", 2 )


    -- GCI CONFIG


    -- create a cap zone
    local CAPZone1 = ZONE:New( "cap_zone-1")
    local CAPZone2 = ZONE:New( "cap_zone-2")
    local CAPZone3 = ZONE:New( "cap_zone-3")

    --  Feet -- Meters
    --  500     150
    --  1000    300
    --  2500    760
    --  5000    1525
    --  7500    2300
    -- 10000    3050
    -- 12500    3800
    -- 15000    4575
    -- 17500    5300
    -- 20000    6100
    -- 25000    7625
    -- 30000    9150
    -- 35000    10700
    -- 40000    12200

    A2ADispatcher:SetSquadronCap("havadarya-mig29", CAPZone1, 9000, 10000, speed_p_default, speed_p_default, speed_i_default, speed_i_default, "RADIO")
    

    -- TODO: Limit the CAP spawns, because right now its a LOT (all?)
    A2ADispatcher:SetSquadronCap("abbas-f4", CAPZone2, 7600, 7600, speed_p_default, speed_p_default, speed_i_default, speed_i_default, "RADIO")
    A2ADispatcher:SetSquadronCap("kerman-mig21", CAPZone2, 7600, 7600, speed_p_default, speed_p_default, speed_i_default, speed_i_default, "RADIO")
    A2ADispatcher:SetSquadronCap("kerman-f4", CAPZone2, 7600, 7600, speed_p_default, speed_p_default, speed_i_default, speed_i_default, "RADIO")
    A2ADispatcher:SetSquadronCap("kerman-f5", CAPZone2, 7600, 7600, speed_p_default, speed_p_default, speed_i_default, speed_i_default, "RADIO")
    A2ADispatcher:SetSquadronCap("kerman-f14", CAPZone2, 7600, 7600, speed_p_default, speed_p_default, speed_i_default, speed_i_default, "RADIO")


    A2ADispatcher:SetSquadronCap("kerman-mirage", CAPZone3, 8000, 9000, speed_p_default, speed_p_default, speed_i_default, speed_i_default, "RADIO")


    -- A2ADispatcher:SetDefaultCapTimeInterval(300, 1200)
    A2ADispatcher:SetDefaultCapTimeInterval(10, 30) -- DEBUG SPAWN RATE
    
    A2ADispatcher:Start()
    redIADS:addMooseSetGroup(DetectionSetGroup)



    -- IADDS debug info, comment out for mission:
    -- local iadsDebug = redIADS:getDebugSettings()
    -- iadsDebug.IADSStatus = true
    -- iadsDebug.radarWentDark = true
    -- iadsDebug.contacts = true
    -- iadsDebug.radarWentLive = true
    -- iadsDebug.noWorkingCommmandCenter = true
    -- iadsDebug.ewRadarNoConnection = true
    -- iadsDebug.samNoConnection = true
    -- iadsDebug.jammerProbability = true
    -- iadsDebug.addedEWRadar = true
    -- iadsDebug.hasNoPower = false
    -- iadsDebug.harmDefence = true
    -- iadsDebug.samSiteStatusEnvOutput = true
    -- iadsDebug.earlyWarningRadarStatusEnvOutput = true
    -- iadsDebug.commandCenterStatusEnvOutput = true

    -- a2adispatcher debug
    -- A2ADispatcher:SetTacticalDisplay(true)

    -- --test to see which groups are added and removed to the SET_GROUP at runtime by Skynet:
    -- function outputNames()
    --     env.info("IADS Radar Groups added by Skynet:")
    --     env.info(DetectionSetGroup:GetObjectNames())
    -- end

    -- mist.scheduleFunction(outputNames, self, 1, 2)

    -- END DEBUG INFO
end