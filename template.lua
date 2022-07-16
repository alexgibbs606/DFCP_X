-- MISSION EDITOR INSTRUCTIONS
DFCP_DEBUG = 1 -- Set this to zero and reload the script file in the mission editor before running your mission for real!
-- In the mission editor, place a delayed-spawn helicopter named "red-border", give it waypoints that draw out a boundary.
-- everywhere inside of this boundary, blue players can be engaged, outside of this boundary, they are safe.

-- IADS Steps
    -- 1. make a static object named "iads-cp", this command post object will coordinate your sam sites and EW radars.
    -- 2. make a static object named "iads-cp-power", this object powers your command post
    -- 3. place EW radars, or AWACS units
        -- start the group name with "ew-"
    -- 4. place long range SAMs
        -- start the group name with "sam-"
        -- the first unit in the group must be the search radar (if it has one) or the tracking radar
        -- one type of SAM per group
    -- 5. place short range SAM/AAA
        -- do not name these groups starting with "sam-", they will operate independent of IADS
    -- 6. place point defense (SA-15)
        -- don't name these groups starting with "sam-", they will operate independent of IADS
        -- TODO: instructions for making these participate in IADS

-- A2A Steps
    -- place single "delayed spawn" planes to serve as templates for MOOSE, name them "mig21", "f14", etc. and set their loadouts!
            -- you can have multiple templates to randomly shuffle, ex: "mig21-1", "mig21-2", etc.
    --

-- DEBUG TIP
-- If things aren't working, open powershell, and run this command (with your user name filled in):
--  Get-Content "C:\Users\your_user_name\Saved Games\DCS\Logs\dcs.log" -Wait -Tail 30
-- check for error messages after loading the mission has finished (but typically before you press "fly")


-- IADS SETUP
dfcp_create_default_iads()
-- perform any additional setup (advanced)
-- TODO: advanced instructions
dfcp_start_iads(DFCP_DEBUG)


-- A2A SETUP
dfcp_create_default_dispatcher()


----------------------------------------------------------------------------------------------------------------------------------------
-- configure enemy flights
-- Airport Names: https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Wrapper.Airbase.html##(AIRBASE).AirbaseName

-- station 8 mig21 interceptors at aleppo, launch them in flights of 2
dfcp_interceptors_create_simple("mig21", AIRBASE.Syria.Aleppo, 2, 8)

-- launch 1 flight of 2 cap mig29s from Kuweires to patrol at 15K ft inside the "cap-zone-1" zone created in the mission editor
-- Three additional waves of 2 can be launched (8 planes total), but only one wave can be in combat at once.
dfcp_cap_create_simple("mig29s", AIRBASE.Syria.Kuweires , "cap-zone-1", 15000, 2, 8)

----------------------------------------------------------------------------------------------------------------------------------------

-- kick it all off
dfcp_start_mission()