-- Notes: I haven't tested this with more than 1 tanker, so there may be some bugs to squash.

-- configure these settings to match the unit names for the carrier, tanker, and awacs you placed in the mission
local carrier_name = "washington"
local tanker_name = "texaco" -- doesn't actually set the radio callsign to texaco 1-1
local awacs_name = "overlord" -- doesn't actually set the radio callsign to overlord 1-1

-- common options:
local tanker_channel = 268 -- AM
local tanker_tacan = 10
local tanker_tacan_text = "TKR"

local awacs_channel = 270 -- AM



-- THE ACTUAL CODE:



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



-- Spawn things
recovery_tanker:Start()
awacs:Start()