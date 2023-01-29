require 'colxtion'


LUA_EXE = arg[-1]
LUA_EXE_FILENAME = 'lua54.exe'
UNPACK_MIZ = LUA_EXE:gsub(LUA_EXE_FILENAME, 'unpackMiz.ps1')
PACK_MIZ = LUA_EXE:gsub(LUA_EXE_FILENAME, 'packMiz.ps1')


Mission = {
    miz = '',
    working_dir = '',
    data = '',
    groups = '',
    units = '',

    new = function(self, mission_path)
        -- Creating new table and setting metatable to this definition
        local newMission = {}
        setmetatable(newMission, self)
        self.__index = self

        -- Setting our working directory
        self.miz = mission_path
        self.working_dir = mission_path:sub(1, -5) .. '-' .. os.date('%y%m%d.%H%M')
        self.mission_file = self.working_dir .. '/mission'

        -- Unpacking our mission file for use
        os.execute('powershell -file "' .. UNPACK_MIZ ..
            '" -miz_file_path "' .. self.miz ..
            '" -destination_path "' .. self.working_dir .. '"'
        )

        -- Loading data from our file into memory
        self.data = self:_open_mission(self.mission_file)
        self.groups = Colxtion:new(self:_get_groups(self.data))
        self.units = Colxtion:new(self:get_units_from_groups(self.groups))

        -- Returning instance of our current mission file
        return newMission
    end,


    _open_mission = function(_, mission_file_path)
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
        return mission_data
    end,

    -- helper function to write out the mission.lua contents in "readable" form
    _serialize_inner = function(file, o, indent)
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
            file:write("}\n")
        else
            file:write("<>")
            error("cannot serialize a " .. type(o))
        end
    end,

    -- main function to dump the updated mission.lua
    _write_mission = function(filepath, mission_data)
        -- Opening our file for writing
        local file = io.open(filepath, "w+")

        -- Checking for file errors
        if file == nil then error('Cannot open mission file `' .. filepath .. '` for writing.') end

        -- Writing our file as a lua file
        file:write("mission = ")
        Mission._serialize_inner(file, mission_data, "  ")
        io.close(file)
    end,

    _get_groups = function(_, mission_data)
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
    end,

    get_units_from_groups = function(_, group_data)
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
        return units
    end,

    save = function(self, destination_miz)
        -- Finding a miz file to write
        destination_miz = destination_miz or self.working_dir .. '.miz'

        -- Writing our mission file
        Mission._write_mission(self.mission_file, self.data)

        -- Unpacking our mission file for use
        os.execute('powershell -file "' .. PACK_MIZ ..
            '" -mission_file_dir "' .. self.working_dir ..
            '\\*" -destination_miz "' .. destination_miz .. '"'
        )

    end,

    units_where = function(self, ...)
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

        --]]
        -- Handling default arguments
        return self.units:where(...)
    end,

    groups_where = function(self, ...)
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

        --]]
        -- Handling default arguments
        return self.groups:where(...)
    end,

    get_client_planes = function(self)
        --[[ Returns all groups that are registered as clients
        --]]
        return self.groups:where({
            coalition = 'blue',
            group_type = 'plane',
            skill = {'player', 'client'}
        })
    end,

    -- copy_field = function(self, source_group, destination_groups)
    --     --[[ Copyins waypoints from the source group to destination groups.

    --     Arguments:
    --         source_group: A table representing the search table for the source group. i.e. {name = 'MUSCLE-1-1'} or {'groupID' = 584}. See self.groups_where()
    --         destination_groups: The search_terms for the destination groups. i.e. {name = 'MUSCLE-1-1'} or {'groupID' = 584}. See self.groups_where()
    --     --]]

    --     -- Finding our source group
    --     local source_groups = self:groups_where(source_group)

    --     -- Checking if we have more than one source group
    --     if #source_groups > 1 then
    --         error('More than one source group found to copy waypoints from')
    --     end

    --     local source_route = source_group[1].route



    --     for _, group in self.mission_groups do

    --     end
    -- end,


}
