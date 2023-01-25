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
mission_io.serialize_inner =function(file, o, indent)
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