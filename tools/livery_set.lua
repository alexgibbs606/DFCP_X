-- holy shit this is a hacky relative import. there must be a better way??? this just works for testing the file directly
-- local filename = "livery_set.lua" -- fragile, but I hate regex
-- local module_path = arg[0] -- only works if we're executing *this* file, but for tools this should be ok
-- module_path = string.sub(module_path, 0, string.len(module_path)-string.len(filename))
-- package.path = module_path .. "/lib/?.lua;" .. package.path



--ARGS: ./lua54.exe livery_set.lua "<full path to DFCP-ME/tools/lib>" "<full_path_to_file_to_modify>" [desert|winter]
local LIB_PATH = arg[1] -- TODO: how can we find our library path in lua and avoid this ugly hack??
local FILEPATH = arg[2]
local LIVERY = arg[3]

package.path = LIB_PATH .. "/?.lua;" .. package.path
require("mission_io")

-- Warning: unit names AND skin names don't match what you see in the editor. You have to open the mission file to find these.

local FORCE_OVERWRITE = true -- TODO: I'm pretty sure setting these values to something invalid is totally okay. If so, then we only need to add the "custom" cases
-- TODO: make sure we support going back to default skins
-- TODO: support statics


local desert = {} -- best "desert" skin for each known unit
desert["Leclerc"] = "desert"
desert["Ural-375"] = "desert"
desert["BMP-1"] = "desert"
desert["BTR-80"] = "desert"
desert["M1043 HMMWV Armament"] = "desert"
desert["Hummer"] = "desert"
desert["SA-11 Buk SR 9S18M1"] = "desert"
desert["SA-11 Buk CC 9S470M1"] = "desert"
desert["SA-11 Buk LN 9A310M1"] = "desert"
desert["S-60_Type59_Artillery"] = "SYR"


desert["M1097 Avenger"] = "default"
desert["Cobra"] = "default"
desert["M 818"] = "default"


local winter = {} -- best "winter" skin for each known unit
winter["Ural-375"] = "winter"
winter["BMP-1"] = "winter"
winter["BTR-80"] = "winter"
winter["M1043 HMMWV Armament"] = "winter"
winter["Hummer"] = "winter"
winter["M 818"] = "winter"
winter["SA-11 Buk SR 9S18M1"] = "winter"
winter["SA-11 Buk CC 9S470M1"] = "winter"

winter["M1097 Avenger"] = "default"
winter["Cobra"] = "default"
winter["SA-11 Buk LN 9A310M1"] = "default"



local lookup_tables = {}
lookup_tables["desert"] = desert
lookup_tables["winter"] = winter
local chosen_table = lookup_tables[LIVERY]
assert(chosen_table ~= nil)

mission_data = mission_io.read_mission(FILEPATH)




for i, coalition in ipairs{"red", "blue"} do
    local unknown_list = {} -- used to only send log messages once per unit type
    local unavailable_list = {} -- used to only send log messages once per unit type
    for country_id, unit_table in ipairs(mission_data["coalition"][coalition]["country"]) do -- for each country on red/blue
        if unit_table["vehicle"] ~= nil then
            for group_index, group_data in ipairs(unit_table["vehicle"]["group"]) do
                for unit_index, unit_data in ipairs (group_data["units"]) do
                    local unit_type = unit_data["type"]
                    local unit_name = unit_data["name"]
                    local unit_livery = "default"
                    if unit_data["livery_id"] ~= nil then
                        unit_livery = unit_data["livery_id"]
                    end
                    if chosen_table[unit_type] == nil then -- unit is not in our lookup table for the selected LIVERY
                        if unknown_list[unit_type] == nil then
                            if FORCE_OVERWRITE then
                                unit_data["livery_id"] = LIVERY
                                print("FORCING - " .. unit_type .. " - " .. unit_name .. " - " .. unit_livery .. " -> " .. chosen_livery)    
                            else
                                unknown_list[unit_type] = true
                                print("UNKNOWN - " .. unit_type .. " - " .. unit_name)
                            end
                        end
                    elseif chosen_table[unit_type] ~= nil then -- unit is in our lookup table, and it has a relevant skin
                        local chosen_livery = chosen_table[unit_type]
                        if unit_livery ~= chosen_livery then 
                            unit_data["livery_id"] = chosen_livery 
                            print("UPDATED - " .. unit_type .. " - " .. unit_name .. " - " .. unit_livery .. " -> " .. chosen_livery)
                    end
                    else -- unit is in our lookup table, but we think the default is the best option
                        if unavailable_list[unit_type] == nil then
                            unavailable_list[unit_type] = true
                            print("NO-SKIN - " .. unit_type .. " - " .. unit_name)
                        end
                    end
                end
            end
        end
    end
end

mission_io.write_mission(FILEPATH, mission_data)