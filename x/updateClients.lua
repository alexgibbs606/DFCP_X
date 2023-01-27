require 'mission_io'
require 'tableExtension'
require 'groups'

--[[ Replaces all 'player' planes on blue to 'Client' planes. This replaces the mission file in-line
    --]]


-- local mission = mission_io.read_mission(arg[1])
local mission = mission_io.read_mission(arg[1])

local mission_groups = mission_io.get_all_groups(mission)
local mission_units = mission_io.get_units_from_groups(mission_groups)
local foo = table.where(mission_units, {
    coalition = 'blue',
    group_type = 'plane',
    skill = {'player'}
}, false)

for _, unit in pairs(foo) do
    unit.skill = 'Client'
end

mission_io.write_mission(arg[1], mission)
