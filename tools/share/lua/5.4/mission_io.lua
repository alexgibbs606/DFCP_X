-- Depricated for ./mission.lua


require 'tableExtension'

-- Getting this files location
print(debug.getinfo(1).source:match("@?(.*/)"))



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


mission_io.get_all_groups = function(mission_data)
    --[[ Returns a table with all unit groups in the mission. This is not filtered in any way.

    Will also collecct the following information from parent structures:
        - coalition
        - country
        - group type

    Arguments:
        mission_data: The mission data retrieved from a mission file.
            Use mission_io.read_mission to open a mission file.
    --]]
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
    return groups
end


mission_io.get_units_from_groups = function(group_data)
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
        --]]
    local units = {}
    for _, group in pairs(group_data) do
        for _, unit in pairs(group.units) do
            unit.coalition = group.coalition
            unit.country = group.country
            unit.groupId = group.groupId
            unit.group_type = group.group_type
            unit.group_name = group.name
            table.insert(units, unit)
        end
    end
    return units
end
