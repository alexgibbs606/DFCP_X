-- require 'tableExtension'

local inspect = require 'inspect'

Colxtion = {}


function Colxtion:new(source_table)
	-- Creating new table and setting metatable to this definition
	return setmetatable(source_table or {}, {
		__index = self,
		__tostring = self.dump
	})
end

function Colxtion:contains(search_field, case_sensitive)
	-- Default arguments
	case_sensitive = case_sensitive or true

	-- If our reftable is empty, we return false
	if self == nil then return false end
	-- Confirming our refTable is a table
	if type(self) ~= 'table' then self = {self} end

	-- If we're case sensitive, we'll run this piece of code
	if type(search_field) == 'string' and case_sensitive then
		-- Lower once here to improve performance
		search_field = string.lower(search_field)

		for _, value in pairs(self) do
			-- We process our return here to increase performance
			if search_field == string.lower(value) then
				return true
			end
		end
		return false
	end

	-- If we've gotten here, we're not wanting case sensitive check
	return self[search_field] ~= nil
end

function Colxtion:dump(depth)
	-- Default depth is 2
	if #self < 2 then depth = depth or 1 else depth = depth or 2 end
	return inspect(self, {depth = depth})
end

function Colxtion:where(search_fields, case_sensitive)
	--[[ Returns all sub-tables that match the search fields provided.

	This function CAN NOT search for booleans.

	Arguments:
		search_fields: A table mapping fields to values. The field is a table key and the values is a table or value to search for.
		caseSensitive: Determines if our comparison for values is case sensitive. Defaults to false.
	--]]
	-- Handling default arguments
	case_sensitive = case_sensitive or false

	-- If no search fields, we return untouched data
	if search_fields == nil then return self end

	local out_data = {}

	-- Iterate our data tables, we take it one table at a time
	for _, data in pairs(self) do
		for field, values in pairs(search_fields) do
			-- 	Confiming that our value is a table, if it's not, we make it a table
			local field_value = data[field]

			-- Filtering out data that doesn't match our search params
			-- Checking for empty check value
			if field_value == nil then
				goto failed
			end

			-- Custom match function
			if not self.contains(values, field_value, case_sensitive) then
				goto failed
			end

		end -- end field/value in search fields
		-- if we got here, we haven't failed on any field/value pairs
		table.insert(out_data, data)
		::failed::
	end
	return out_data
end

	-- dup_field = function(self, source_, destination_search_fields, fields_to_copy)
	-- 	--[[ Duplicates the values of
	-- 	--]]
	-- end,
