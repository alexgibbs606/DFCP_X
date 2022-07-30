-- INSTRUCTIONS
--  1. Create a backup copy of your miz file
--  2. Open your miz file in 7zip "open archive"
--  3. Drag the "mission" file out of the zip, and into a folder
--  4. Update the ARGS below these instructions:
--       - working_directory should match the file path where you put the mission file
--       - choose coalition, and flight names in your mission
--  5. Run the lua script
--  6. Drag your output file back into 7zip
--  7. remove "mission" from the file in 7zip, rename "mission.updated.lua" to "mission"
--  8. Open the miz in DCS, it *should* work :)


--ARGS
local working_directory = [[C:\Users\Chris\Saved Games\DCS\Missions\scripts\DFCP-ME\tools\]] -- make sure this ends with "\"
-- choose the coalition/flights to copy
local src = "CONTACT" -- group name to copy waypoints from
local dst_all = {"ORPHAN", "BONK", "DESKPOP", "ENYA", "FURRY", "PIRATE"} -- group names to copy waypoints to
-- END OF ARGS


local mission_file_name = "mission" -- file must be present in the above working_directory folder
local out_file_name = "mission.updated.lua" -- file will be created in the above working_directory folder

-- TODO: arg parser, python wrapper?


-- build a helper lookup table for flights we'll modify
local dst_lookup = {}
for i, v in ipairs(dst_all) do
    dst_lookup[v] = true
end



-- main function to dump the updated mission.lua
function serialize(filepath, o)
    file = io.open(filepath, "w+")
    file:write("mission = ")
    serialize_inner(file, o, "  ")
    io.close(file)
end

-- helper function to write out the mission.lua contents in "readable" form
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


-- read in the mission file
local mission_file_path = working_directory .. mission_file_name
local handle = io.open(mission_file_path,'rb')
local raw_data_str  = handle:read("*a")
handle:close()
local raw_data_lua = raw_data_str .. "\n return mission" 
local mission_data = load(raw_data_lua)()



-- find the waypoint data for *all* aircraft
local copy_source = nil -- the waypoints we'll copy into the target flights
local spinnybois = {} -- helicopters [coalition, country_id, group_number, name, route]
local pointybois = {} -- planes [coalition, country_id, group_number, name, route]

for i, coalition in ipairs{"red", "blue"} do
    for country_id, unit_table in ipairs(mission_data["coalition"][coalition]["country"]) do -- for each country on red/blue
        -- if the country has spinnybois, go get all their waypoints
        if unit_table["helicopter"] ~= nil then
            print(unit_table["name"] .. "(" ..country_id ..") helicopters:")
            for group_index, group_data in ipairs(unit_table["helicopter"]["group"]) do
                print(group_index .. " - " .. group_data["name"])
                spinnybois[#spinnybois+1] = {coalition, country_id, group_index, group_data["name"], group_data["route"]}
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
                pointybois[#pointybois+1] = {coalition, country_id, group_index, group_data["name"], group_data["route"]}
                if group_data["name"] == src then
                    copy_source = group_data["route"]
                end
            end
        end
    end
end

assert(copy_source, "did not find '" .. src .. "' in the mission.")





-- update the spinnybois waypoints
for index, data in ipairs(spinnybois) do
    local coalition = data[1]
    local country_id = data[2]
    local group_index = data[3]
    local group_name = data[4]

    if dst_lookup[group_name] then -- only update groups that we were asked to
        for i, idata in ipairs(copy_source["points"]) do
            if i > 1 then -- skip wp0
                -- write the waypoint to the miz file stored in memory
                mission_data["coalition"][coalition]["country"][country_id]["helicopter"]["group"][group_index]["route"]["points"][i] = idata
            end
        end
    end
end

-- update the pointybois waypoints
for index, data in ipairs(pointybois) do
    local coalition = data[1]
    local country_id = data[2]
    local group_index = data[3]
    local group_name = data[4]

    if dst_lookup[group_name] then -- only update groups that we were asked to
        for i, idata in ipairs(copy_source["points"]) do
            if i > 1 then -- skip wp0
                -- write the waypoint to the miz file stored in memory
                mission_data["coalition"][coalition]["country"][country_id]["plane"]["group"][group_index]["route"]["points"][i] = idata
            end
        end
    end
end

-- write the miz file in memory out to disk
local out_file_path = working_directory .. out_file_name
serialize(out_file_path, mission_data)
