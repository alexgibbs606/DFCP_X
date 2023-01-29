-- Depricated for ./colxtion.lua


local inspect = require 'inspect'

table.contains = function(refTable, searchField, caseSensitive)
    -- Default arguments
    caseSensitive = caseSensitive or true

    -- If our reftable is empty, we return false
    if refTable == nil then return false end
    -- Confirming our refTable is a table
    if type(refTable) ~= 'table' then refTable = {refTable} end

    -- If we're case sensitive, we'll run this piece of code
    if type(searchField) == 'string' and caseSensitive then
        -- Lower once here to improve performance
        searchField = string.lower(searchField)

        for _, value in pairs(refTable) do
            -- We process our return here to increase performance
            if searchField == string.lower(value) then
                return true
            end
        end
        return false
    end

    -- If we've gotten here, we're not wanting case sensitive check
    return refTable[searchField] ~= nil
end


table.dump = function(refTable, depth)
	-- Default depth is 1
	depth = depth or 1
	return inspect(refTable, {depth = depth})
end


table.where = function(table_data, search_fields, caseSensitive)
    --[[ Returns all sub-tables that match the search fields provided.

    This function CAN NOT search for booleans.

    Arguments:
        table_data: A table that contains tables of data. i.e. a list of tables with accessable data.
        search_fields: A table mapping fields to values. The field is a table key and the values is a table or value to search for.
        caseSensitive: Determines if our comparison for values is case sensitive. Defaults to false.
    --]]
    -- Handling default arguments
    caseSensitive = caseSensitive or false

    local out_data = {}

    -- Iterate our data tables, we take it one table at a time
    for _, data in pairs(table_data) do
        for field, values in pairs(search_fields) do
            -- 	Confiming that our value is a table, if it's not, we make it a table
            local field_value = data[field]

            -- Filtering out data that doesn't match our search params
            -- Checking for empty check value
            if field_value == nil then
                goto failed
            end

            -- Custom match function
            if not table.contains(values, field_value, caseSensitive) then
                goto failed
            end

        end -- end field/value in search fields
        -- if we got here, we haven't failed on any field/value pairs
        table.insert(out_data, data)
        ::failed::
    end
    return out_data
end
