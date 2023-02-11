require 'colxtion'
require 'zipperz'
PathLib = require 'path/path'


TEMP_DIR_NAME = '.dat'


Mission = {}

function Mission:new(mission_path)
	--[[ An interaction class for the mission file.

	This class handles unzipping, altering, saving, and re-ziping of the mission file to let you focus on what you want to change in the mission file.

	A temporary file will be created along side the .miz file once opened. it's recommended that you place each .miz mission file in its own directory to keep these folders together.
	i.e. `<DCS_Saved_Games>/Missions/operationConjecture/opeationConjecture.miz`

	Arguments:
		mission_path: The filepath to the .miz file that contains the mission.

	Usage:
		A program to make sure all player/client planes are set to 'Client' to prevent issues on multiplayer, and to set all the client planes to use the same waypoints as the 'PINEAPPLE-1' group.
		``` lua
		require 'mission'
		local mission = Mission:new([[C:\Users\AleX\Saved Games\DCS.openbeta\Missions\operationConjecture\OperationConjecture.miz]=])
		mission:save([[C:\Users\AleX\Saved Games\DCS.openbeta\Missions\operationConjecture\OperationConjecturea.miz]=]
		mission:match_player_skill()
		mission:match_player_waypoints('blue', 'PINEAPPLE-1')
		mission:save([[C:\Users\AleX\Saved Games\DCS.openbeta\Missions\operationConjecture\OperationConjectureb.miz]=])
		```
	]]
	-- Checking if we've received our first argument
	if mission_path == nil then error('A mission file path is required to make a new mission. None was given (a nil value).') end

	-- Creating new table and setting metatable to this definition
	local new_mission = {}
	setmetatable(new_mission, self)
	self.__index = self

	-- Setting our working directory
	self.miz_path = mission_path
	-- Grabbing some path components for later
	self.mission_name, _ = PathLib.nameext(self.miz_path)
	self.open_timestamp = os.date('%y%m%d.%H%M')

	-- Grabbing references to our temporary folder, where the unpacked misison file will be, and the zip file.
	self.data_dir = PathLib.dir(self.miz_path) ..'\\'.. TEMP_DIR_NAME
	self.working_dir = self.data_dir ..'\\'.. self.open_timestamp
	self.mission_path = self.working_dir ..'\\'.. 'mission'
	self.zip_path = self.working_dir ..'\\'.. self.mission_name .. '.zip'

	-- Purging working directory. If this isn't empty then we may have issues later.
	os.execute('@RD /S /Q "' .. self.working_dir .. '"')

	-- Creating our temporary directory
	os.execute('if not exist "' .. self.data_dir .. '\" mkdir \"' .. self.data_dir .. '\"')
	os.execute('if not exist "' .. self.working_dir .. '\" mkdir \"' .. self.working_dir .. '\"')

	-- Unpacking our mission file for use
	Zipper.unpack(self.miz_path, self.zip_path, self.working_dir)

	-- Loading data from our file into memory
	self.data = self._open_mission(self.mission_path)
	self.groups = self:_get_groups()
	self.units = self:get_units_from_groups()

	-- Returning instance of our current mission file
	return new_mission
end


function Mission:save(destination_miz)
	--[[ Saves the mission object to a given miz file.

	More specifically, everything until this point has been in memory, so this writes to persistant storage, zips to a temporary zip file, then updates to a .miz.

	Arguments:
		destination_miz: The final destination of your mission file. Defaults to the original miz file with a timestamp on it (will not override original mission file by default).
			Will substitue the value `$ts` in a filepath with the timestamp that the original miz file was opened. Useful for writing the new miz in the same directory as the original without overriding it.
	]]
	-- Finding a miz file to write
	destination_miz = destination_miz or self.zip_path:gsub('.zip', '.miz')
	destination_miz = destination_miz:gsub('$ts', self.open_timestamp)

	-- Writing our mission file
	Mission._write_mission(self.mission_path, self.data)

	-- Unpacking our mission file for use
	Zipper.update(self.mission_path, self.zip_path, destination_miz)
end

--[[
	PRIVATE CLASS UTILITY
]]
function Mission._open_mission(mission_file_path)
	-- Reading the mission file
	local file_handle = io.open(mission_file_path, 'rb')

	-- Checking for file errors or non-existing file
	if file_handle == nil then error('Mission file `' .. mission_file_path .. '` not found.') end

	-- Reading raw data from file and closing it
	local raw_data_str  = file_handle:read("*a")
	file_handle:close()

	-- Executing file as raw lua to return a value
	local mission_raw_lua = raw_data_str .. "\n return mission"
	local mission_data = load(mission_raw_lua)()
	return Colxtion:new(mission_data)
end


-- helper function to write out the mission.lua contents in "readable" form
function Mission._serialize_inner(file, o, indent)
	if type(o) == "number" then
		file:write(o)
	elseif type(o) == "string" then
		file:write(string.format("%q", o))
	elseif type(o) == "boolean" then
		if o == true then
			file:write("true")
		else
			file:write("false")
		end
	elseif type(o) == "table" then
		file:write("{\n")
		for k,v in pairs(o) do
			file:write(indent)
			file:write("  [")
			Mission._serialize_inner(file, k, indent .. "  ")
			file:write("] = ")
			Mission._serialize_inner(file, v, indent .. "  ")
			file:write(",\n")
		end
		file:write(indent)
		file:write("}")
	else
		file:write("<>")
		error("cannot serialize a " .. type(o))
	end
end


-- main function to dump the updated mission.lua
function Mission._write_mission(filepath, mission_data)
	-- Opening our file for writing
	local file = io.open(filepath, "w+")

	-- Checking for file errors
	if file == nil then error('Cannot open mission file `' .. filepath .. '` for writing.') end

	-- Writing our file as a lua file
	file:write("mission = ")
	Mission._serialize_inner(file, mission_data, "  ")
	io.close(file)
end


function Mission:_get_groups(mission_data)
	--[[ Returns a table with all unit groups in the mission. This is not filtered in any way.

	Will also collecct the following information from parent structures:
		- coalition
		- country
		- group type

	Arguments:
		mission_data: The mission data retrieved from a mission file.
			Use mission_io.read_mission to open a mission file.

	Returns a Colxtion of groups from the mission data.
	]]
	-- Default mission data
	mission_data = mission_data or self.data

	local groups = {}

	-- Iterating through our coalitions
	for _, group_coalition in pairs(mission_data.coalition) do

		-- Iterating through each country
		for _, group_country in pairs(group_coalition.country) do

			-- Iterating through all our units
			for group_type, data in pairs(group_country) do

				if type(data) ~= 'table' then goto continue end

				-- Iterating through each unit in this group
				for _, group in pairs(data.group) do
					-- Adding some information
					group.country = group_country.name
					group.coalition = group_coalition.name
					group.group_type = group_type

					-- Adding this unit to the units list
					table.insert(groups, group)

				end

				::continue::
			end
		end
	end
	return Colxtion:new(groups)
end


--[[
	GROUP AND UNIT ACCESSORS
]]
function Mission:get_units_from_groups(group_data)
	--[[ Unpacks all the groups and returns a table of all the units in the mission.

	Will also collecct the following information from parent structures:
		- coalition
		- country
		- groupId
		- group type
		- group name

	Arguments:
		group_data: The mission's group data retrieved from a mission file.
			Use mission_io.get_all_groups to open a mission file.

	Returns a Colxtion of unit tables from the given group data.
	]]
	-- Default group data
	group_data = group_data or self.groups

	local units = {}
	for _, group in ipairs(group_data) do
		for _, unit in ipairs(group.units) do
			unit.coalition = group.coalition
			unit.country = group.country
			unit.groupId = group.groupId
			unit.group_type = group.group_type
			unit.group_name = group.name
			unit.group_task = group.task
			table.insert(units, unit)
		end
	end
	return Colxtion:new(units)
end


function Mission:units_where(...)
	--[[ Returns all units in this mission that match the search fields provided.

	This function CAN NOT search for booleans.

	Arguments: See Colxtion:where()

	Unit Fields:
		category: Type of unit i.e. 'Ships', 'Personnel'
		coalition: Coalition of unit i.e. 'blue', 'red', 'neutral'
		country: Which country the unit is registered to i.e. 'USA', 'Russia'
		groupId: The unique ID for the group this unit belongs to i.e. 246
		group_name: The name of the group this unit belongs to i.e. 'MUSCLE-1'
		group_type: The type of units that are in this group i.e. 'Plane', 'static'
		onboard_num: The number that displays on the wingtip for the aircraft i.e. '161'
		skill: The skill that this unit is set to. i.e. 'Average', 'Good', 'High', 'Excellent', 'Random', 'Client', or 'Player'

	]]
	-- Handling default arguments
	return self.units:where(...)
end


function Mission:groups_where(...)
	--[[ Returns all sub-tables that match the search fields provided.

	This function CAN NOT search for booleans.

	Arguments: See Colxtion:where()

	Group Fields:
		coalition: Coalition of unit i.e. 'blue', 'red', 'neutral'
		country: Which country the unit is registered to i.e. 'USA', 'Russia'
		groupId: The unique ID for the group this unit belongs to i.e. 246
		group_name: The name of the group this unit belongs to i.e. 'MUSCLE-1'
		group_type: The type of units that are in this group i.e. 'Plane', 'static'
		task: The task assigned to the group i.e. 'CAP', 'CAS', 'SEAD', 'Intercept'
		type: The type of unit i.e. 'FA-18C_hornet'
		unitId: Unique identifier for this unit i.e. 10

	]]
	-- Handling default arguments
	return self.groups:where(...)
end


function Mission:get_client_groups(coalition)
	--[[ Returns all groups that are registered as clients
	]]
	-- Default coalition argument
	coalition = coalition or {'blue', 'red', 'neutral'}

	-- Getting all units that are controled by the client
	local client_planes = self.units:where({
		coalition = coalition,
		group_type = 'plane',
		skill = {'player', 'client'}
	})

	-- Iterating through our client planes to get all the groups they belong to
	local client_group_names = Colxtion:new()
	for _, unit in ipairs(client_planes) do
		if not client_group_names:contains(unit.group_name) then
			client_group_names:insert(unit.group_name)
		end
	end

	-- Now getting our groups that contain client controlled planes
	return self.groups:where({
		coalition = coalition,
		group_type = 'plane',
		name = client_group_names
	})
end


--[[
	FULL-SERVICE METHODS
]]
function Mission:match_player_skill()
	--[[ Finds all planes that are 'Player' skill and makes them 'Client'
	]]
	self.units:where({
		coalition = 'blue',
		skill = 'player'
	}):update({
		skill = 'Client'
	})
end


function Mission:match_player_waypoints(coalition, source_group_name, dest_group_names, blacklist_group_names)
	--[[ This copies a field from the source group name or id to all other player/client groups.

	Arguments:
		coalition: The coalition to handle our fields. Either 'red' or 'blue'. nil value will copy to all coalitions.
		source_group: The group name or id of your source group. Can also search by GroupID
		dest_group: The destination group names for the waypoints. If this is nil, this will copy to all groups.
		blacklist_groups: A list of names that acts as a blacklist. This is processed after the dest_group. nil values will remove nothing.
	]]
	-- Grabbing our source waypoints
	local source_group = self.groups:where{
		coalition = coalition,
		name = source_group_name,
	}
	local source_waypoints = source_group[1].route.points

	-- Grabbing all player groups. This will start as a base list of groups to update their waypoints. If there are no requested filters, this will fill to all groups.
	local player_groups = self:get_client_groups(coalition):where{
		name = dest_group_names
	}:exclude{
		name = blacklist_group_names
	}

	-- Iterating through our groups to place
	for _, group in ipairs(player_groups) do
		-- Copy our waypoints to a new instance
		local waypoints = {table.unpack(source_waypoints)}
		-- First point is spawn point, we don't want to alter that.
		waypoints[1] = group.route.points[1]
		-- Setting our new waypoints
		group.route.points = waypoints
	end
end