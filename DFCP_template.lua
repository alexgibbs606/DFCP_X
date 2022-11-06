-- MISSION EDITOR INSTRUCTIONS
DFCP_DEBUG = 1
-- DEBUGGING:
    -- Set this to 0 and reload the script file in the mission editor before running your mission for real!
    -- If things aren't working, open powershell, and run this command (with your user name filled in):
        --  Get-Content "C:\Users\your_user_name\Saved Games\DCS\Logs\dcs.log" -Wait -Tail 30
        -- check for error messages after loading the mission has finished (but typically before you press "fly")

-- REQUIRED STEPS IN THE MISSION EDITOR:
-- 1. Place a delayed-spawn helicopter named "red-border", give it waypoints that draw out a boundary.
        -- everywhere inside of this boundary, blue aircraft can be engaged, outside of this boundary, they are safe.
-- 2. Place single "delayed spawn" planes to serve as templates for MOOSE, name them "mig21", "f14", etc. and set their loadouts!
        -- you can have multiple templates to randomly shuffle, ex: "mig21-1", "mig21-2", etc.
-- 3. Place enemy EW or AWACS radars (EWR 1L13, EWR 55G6, A-50)
        -- only add one unit per group
        -- set the group name for each to start with "ew" ex: "ew-kobuleti", "ew-2", etc.
        -- only blue units that can be detected by these will have units scrambled to meet them




-- IADS SETUP -- TO DISABLE IADS, remove this section
---------------------------------------------------------------------------------------------------------------------------
-- IADS Steps                                                                                                            --
    -- 1. make a static object named "iads-cp", this command post object will coordinate your sam sites and EW radars.   --
    -- 2. make a static object named "iads-cp-power", this object powers your command post                               --
    -- 3. place long range SAMs                                                                                          --
        -- start the group name with "sam-"                                                                              --
        -- the first unit in the group must be the search radar (if it has one) or the tracking radar                    --
        -- one type of SAM per group                                                                                     --
    -- 4. place short range SAM/AAA                                                                                      --
        -- do not name these groups starting with "sam-", they will operate independent of IADS                          --
    -- 5. place point defense (SA-15)                                                                                    --
        -- don't name these groups starting with "sam-", they will operate independent of IADS                           --
        -- TODO: instructions for making these participate in IADS                                                       --
dfcp_create_default_iads()                                                                                               -- 
-- perform any additional setup (advanced)                                                                               --
-- TODO: advanced instructions                                                                                           --
dfcp_start_iads(DFCP_DEBUG)                                                                                              --
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------



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


-- GROUND UNIT SPAWNING
-- Reference the DFCP_template_example.miz for how these are used. (it was generated with these lines not commented out)
-- dfcp_unit_spawner("red-spawner-1", -- a group whose waypoints are copied to every spawned group
--                   {"red-1", "red-2", "red-3"}, -- groups that will be randomly selected from to spawn
--                   {"red-spawn-1", "red-spawn-2", "red-spawn-3"}, -- names of zones that groups will be randomly spawned in
--                   30, -- max *units* alive at once from this spawner
--                   0, -- number of groups that can be spawned (0 = infinite)
--                   0, -- randomize waypoints by this many meters
--                   90, -- compass heading of the group when spawned
--                   30) -- number of seconds (+/-50%) between spawning groups
-- dfcp_unit_spawner("blue-spawner-1", {"blue-1", "blue-2", "blue-3"}, {"blue-spawn-1", "blue-spawn-2", "blue-spawn-3"}, 30, 0, 0, 90, 30)

-- dfcp_unit_spawner("red-emplacement", {"red-emplacement-1", "red-emplacement-2"}, {"east-facing", }, 1000, 4, 0, 90, 1)
-- dfcp_unit_spawner("blue-emplacement", {"blue-emplacement-1", "blue-emplacement-2"}, {"west-facing", }, 1000, 4, 0, 270, 1)