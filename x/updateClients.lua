require 'mission'

local mission = Mission:new([[C:\Users\AleX\Saved Games\DCS.openbeta\Missions\playerTest\playerTest.miz]])

local player_planes = mission.units:where({
	coalition = 'blue',
	skill = {'player'}
})

for _, plane in ipairs(player_planes) do
	plane.skill = 'Client'
end

mission:save()