

-- to make this work
-- extract the *.miz/mission file
-- rename mission to mission.lua
-- make the change
-- write out the file
-- repack into a *.miz file


--ARGS
-- TODO: arg parser, python wrapper?
local mission_file_path = "C:\\Users\\Chris\\Saved Games\\DCS\\Missions\\scripts\\DFCP-ME\\waypoint_copy\\mission.lua"
local out_file_path = "C:\\Users\\Chris\\Saved Games\\DCS\\Missions\\scripts\\DFCP-ME\\waypoint_copy\\mission.updated.lua"
local coalition = "blue" -- or red
local src = "PIRATE" -- group name to copy waypoints from
local dst_all = {"ORPHAN", "ORPHAN-FR", "PIRATE", "PATCH", "PATCH_AUS"} -- group name to copy waypoints to






--- read in the mission file
local handle = io.open(mission_file_path,'rb')
local raw_data_str  = handle:read("*a")
handle:close()
raw_data_lua = raw_data_str .. "\n return mission" 

local mission_data = load(raw_data_lua)()

function serialize(filepath, o)
    file = io.open(filepath, "w+")
    -- file:write("mission = {\n")
    file:write("mission = ")
    serialize_inner(file, o, "  ")
    -- file:write("}")
    io.close(file)
end

-- function to write out the data
function serialize_inner (file, o, indent)
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
            serialize_inner(file, k, indent .. "  ")
            file:write("] = ")
            serialize_inner(file, v, indent .. "  ")
            file:write(",\n")
        end
        file:write(indent)
        file:write("}\n")
    else
        file:write("<>")
        error("cannot serialize a " .. type(o))
    end
end

local copy_source = nil
local spinnybois = {} -- helicopters [country_id, group_number, name, route]
local pointybois = {} -- planes


-- read in the waypoint data
for country_id, unit_table in ipairs(mission_data["coalition"][coalition]["country"]) do
    -- if the country has spinnybois, go get all their waypoints
    if unit_table["helicopter"] ~= nil then
        print(unit_table["name"] .. "(" ..country_id ..") helicopters:")
        for group_index, group_data in ipairs(unit_table["helicopter"]["group"]) do
            print(group_index .. " - " .. group_data["name"])
            spinnybois[#spinnybois+1] = {country_id, group_index, group_data["name"], group_data["route"]}
            if group_data["name"] == src then
                copy_source = group_data["route"]
            end
        end
    end

    -- if the country has pointybois, go get all their waypoints
    if unit_table["plane"] ~= nil then
        print(unit_table["name"] .. "(" ..country_id ..") planes:")
        for group_index, group_data in ipairs(unit_table["plane"]["group"]) do
            print(group_index .. " - " .. group_data["name"])
            pointybois[#pointybois+1] = {country_id, group_index, group_data["name"], group_data["route"]}
            if group_data["name"] == src then
                copy_source = group_data["route"]
            end
        end
    end
end

assert(copy_source, "did not find '" .. src .. "' in the mission.")




-- build a lookup table for flights we'll modify
local dst_lookup = {}
for i, v in ipairs(dst_all) do
    dst_lookup[v] = true
end



-- modify the spinnybois 
for index, data in ipairs(spinnybois) do
    local country_id = data[1]
    local group_index = data[2]
    local group_name = data[3]

    if dst_lookup[group_name] then
        for i, idata in ipairs(copy_source["points"]) do
            if i > 1 then -- skip wp0
                mission_data["coalition"][coalition]["country"][country_id]["helicopter"]["group"][group_index]["route"]["points"][i] = idata
            end
        end
    end
end

-- modify the pointybois
for index, data in ipairs(pointybois) do
    local country_id = data[1]
    local group_index = data[2]
    local group_name = data[3]

    if dst_lookup[group_name] then
        for i, idata in ipairs(copy_source["points"]) do
            if i > 1 then -- skip wp0
                mission_data["coalition"][coalition]["country"][country_id]["plane"]["group"][group_index]["route"]["points"][i] = idata
            end
        end
    end
end

serialize(out_file_path, mission_data)
