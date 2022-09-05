-- Notes:
    -- I haven't tested this with more than 1 tanker/awacs/carrier so there may be bugs, but it should* work, just make copies of this script
    -- the only airboss usage i've tested is the "other > airboss > kneeboard > skipper" functionality to control the carrier
    -- each section (TANKER/AWACS/AIRBOSS) should be safe to comment out if you don't need it

-- configure these settings to match the unit names for the carrier, tanker, and awacs you placed in the mission
-- ###########
-- #Settings #
-- ###########
local carrier_name = "washington"
local carrier_tacan_channel = 73
local carrier_tacan_mode = "X"
local carrier_tacan_name = "GWA"
local carrier_icls_channel = 3
local single_carrier = true -- set this to false if you're configuring multiple carriers *with moose airboss scripts*

local tanker_name = "texaco" -- doesn't actually set the radio callsign to texaco 1-1
local tanker_channel = 268 -- AM
local tanker_tacan = 10
local tanker_tacan_text = "TKR"

local awacs_name = "overlord" -- doesn't actually set the radio callsign to overlord 1-1
local awacs_channel = 270 -- AM
-- ###########


-- ########
-- #TANKER#
-- ########
local recovery_tanker = RECOVERYTANKER:New(UNIT:FindByName(carrier_name), tanker_name)
recovery_tanker:SetTakeoffAir() -- other options SetTakeoffCold() SetTakeoffHot()

--optional options
recovery_tanker:SetAltitude(5000)
recovery_tanker:SetSpeed(270)
recovery_tanker:SetRacetrackDistances(10, 4) -- set waypoints 10nm off the front of the boat, and 4nm off the back
recovery_tanker:SetTACAN(tanker_tacan, tanker_tacan_text) -- moose defaults to 1Y "TKR"
recovery_tanker:SetRadio(tanker_channel)
recovery_tanker:Start()
-- ########


-- ########
-- #AWACS #
-- ########
local awacs = RECOVERYTANKER:New(carrier_name, awacs_name)
awacs:SetAWACS()
awacs:SetCallsign(CALLSIGN.AWACS.Overlord, 1)
awacs:SetTakeoffAir()
awacs:SetRacetrackDistances(15, 9)
awacs:SetAltitude(20000)
awacs:SetRadio(awacs_channel)
awacs:Start()
-- ########


-- ##########
-- #AIRBOSS #
-- ##########
local airboss=AIRBOSS:New(carrier_name, carrier_name)
local recovery_time = 20
local recovery_wind_speed = 25
local return_to_recovery_start_point = true
local holding_pattern_offset_degs = 10
airboss:SetMenuRecovery(recovery_time, recovery_wind_speed, return_to_recovery_start_point, holding_pattern_offset_degs)
airboss:SetTACAN(carrier_tacan_channel, carrier_tacan_mode, carrier_tacan_name)
airboss:SetICLS(carrier_icls_channel, carrier_tacan_name)

airboss:SetMenuSmokeZones(false)
airboss:SetMenuMarkZones(false)
airboss:SetPatrolAdInfinitum(true)
-- airboss:SetHandleAIOFF(true) -- don't try to force ai flights into marshall stack -- not sure what this will do to awacs/refuel
airboss:SetWelcomePlayers(false)

if single_carrier == true then
    airboss:SetMenuSingleCarrier(true)
end
airboss:Start()
-- ##########