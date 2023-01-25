require 'tableExtension'

mission_io = {}

mission_io.read_mission = function(mission_file_path)
    -- read in the mission file
    local handle = io.open(mission_file_path,'rb')
	-- Checking for file errors or non-existing file
	if handle == nil then error('Mission file `' .. mission_file_path .. '` not found.') end
    local raw_data_str  = handle:read("*a")
    handle:close()
    local raw_data_lua = raw_data_str .. "\n return mission" 
    local mission_data = load(raw_data_lua)()
    return mission_data
end

-- main function to dump the updated mission.lua
mission_io.write_mission = function(filepath, mission_data)
    local file = io.open(filepath, "w+")
	-- Checking for file errors
	if file == nil then error('Cannot open mission file `' .. filepath .. '` for writing.') end
    file:write("mission = ")
    mission_io.serialize_inner(file, mission_data, "  ")
    io.close(file)
end

-- helper function to write out the mission.lua contents in "readable" form
mission_io.serialize_inner = function(file, o, indent)
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
            mission_io.serialize_inner(file, k, indent .. "  ")
            file:write("] = ")
            mission_io.serialize_inner(file, v, indent .. "  ")
            file:write(",\n")
        end
        file:write(indent)
        file:write("}\n")
    else
        file:write("<>")
        error("cannot serialize a " .. type(o))
    end
end


mission_io.get_groups = function(mission, coalition, country, unit_type)
	-- Checking optional parameters
	if mission.mission ~= nil then
		if type(mission.coalition) == 'string' then coalition = {mission.coalition} else coalition = mission.coalition end
		if type(mission.country) == 'string' then country = {mission.country} else country = mission.country end
		if type(mission.unit_type) == 'string' then unit_type = {mission.unit_type} else unit_type = mission.unit_type end
		mission = mission.mission
	end

	local groups = {}

	-- Filtering our coalition
	-- Iterating through our coalitions
	for _, group_coalition in pairs(mission.coalition) do

		-- Filtering out coalitions we didn't ask for
		if not table.contains(group_coalition.name, coalition or {'red', 'blue', 'neutrals'}, false) then
			goto continue_coalition
		end -- If we didn't filter, we want this group of units

		-- Iterating through each country
		for _, group_country in pairs(group_coalition.country) do

			-- Filtering out countries we didn't ask for
			if not table.contains(group_country.name, country or {'usa', 'russia'}, false) then
				goto continue_country
			end -- If we didn't filter, we want this country

			-- Iterating through all our units
			for group_type, group_table in pairs(group_country) do

				-- Since types are stored differe, we can look for the types requested instead of filtering them out
				if table.contains(group_type, unit_type or {'ship', 'plane', 'static'}, false) then

					-- Iterating through each unit in this group
					for _, group in pairs(group_table.group) do
						group.country = group_country.name
						group.coalition = group_coalition.name
						group.group_type = group_type

						-- Adding this unit to the units list
						table.insert(groups, group)
					end

				end

			end
			::continue_country::
		end
		::continue_coalition::
	end

	return groups
end


mission_io.get_units = function(mission, coalition, country, unit_type, group_name)
	-- Checking optional parameters
	if mission.mission ~= nil then
		if type(mission.coalition) == 'string' then coalition = {mission.coalition} else coalition = mission.coalition end
		if type(mission.country) == 'string' then country = {mission.country} else country = mission.country end
		if type(mission.unit_type) == 'string' then unit_type = {mission.unit_type} else unit_type = mission.unit_type end
		if type(mission.groupName) == 'string' then group_name = {mission.groupName} else group_name = mission.groupName end
		mission = mission.mission
	end

	local units = {}

	local groups = mission_io.get_groups(mission, coalition, country, unit_type)

	-- If we're not given a group list, then we'll return everything
	if not group_name then
		for _, group in pairs(groups) do
			for _, unit in pairs(group.units) do
				unit.coalition = group.coalition
				unit.country = group.country
				unit.unit_type = group.group_type
				table.insert(units, unit)
			end
		end
		return units
	end

	-- If we are asking for a specific group
	for _, group in pairs(groups) do
		-- Filtering out any groups we want
		if not (
				table.contains(group.name, group_name, false)
				  or
				table.contains(group.groupId, group_name, false)
			) then
			goto continue
		end -- If we didn't filter, we want this group

		for _, unit in pairs(group.units) do
			unit.coalition = group.coalition
			unit.country = group.country
			unit.unit_type = group.group_type
			table.insert(units, unit)
		end

		::continue::
	end
	return
end