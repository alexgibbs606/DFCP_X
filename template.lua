DEBUG = 0

-- MISSION EDITOR INSTRUCTIONS
-- In the mission editor, place a delayed-spawn helicopter named "red-border", give it waypoints that draw out a boundary.
-- everywhere inside of this boundary, blue players can be engaged, outside of this boundary, they are safe.

-- IADS SETUP
redIADS = SkynetIADS:create('red')
dfcp_create_default_iads(redIADS)


-- A2A SETUP
local air_spawns = false
A2ADispatcher = dfcp_create_default_dispatcher(air_spawns)

dfcp_create_interceptors(A2ADispatcher, "i1", "mig21", "mig21", AIRBASE.Syria.Aleppo, 2, 8)
dfcp_create_cap(A2ADispatcher, "cap1", "mig29s", "mig29s", AIRBASE.Syria.Aleppo, "cap-zone-1", 15000, 2, 8)

dfcp_start_mission(redIADS, A2ADispatcher, DEBUG)