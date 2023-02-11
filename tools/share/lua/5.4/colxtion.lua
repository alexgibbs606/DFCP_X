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

		for _, value in ipairs(self) do
			-- We process our return here to increase performance
			if type(value) == 'string' and search_field == string.lower(value) then
				return true
			end
		end
		return false

	else
		for _, value in ipairs(self) do
			if value == search_field then
				return true
			end
		end
		return false

	end
	-- If we've gotten here, we're not wanting case sensitive check
	return self[search_field] ~= nil
end


function Colxtion:insert(...)
	table.insert(self, ...)
end


function Colxtion:set(values)
	--[[ Sets the given fields in the collection.

	Arguments:
		values: A table of key/values to set in our table.

	Usage:
		Can set all fields to a specific value:
			foo = Colxtion:new({...})
			foo:set({
				bar = 'foobar'
			})

		This can also be used with :where to make SQL-like set statements:
			foo = Colxtion:new({...})
			foo:where({
				skill = 'player'
			}):set({
				skill = 'Client'
			})
	]]
    for _, sub_table in ipairs(self) do
		for key, value in values do
			sub_table[key] = value
		end
    end
end


function Colxtion:update(updates)
	--[[ Updates the given fields in the collection.

	Opposed to Colxtion:set, this will only change the field if it exists in the Colxtion already.

	Arguments:
		update: A table of key/values to update in our table.

	Usage:
		Can update all fields to a specific value:
			foo = Colxtion:new({...})
			foo:update({
				bar = 'foobar'
			})

		This can also be used with :where to make SQL-like update statements:
			foo = Colxtion:new({...})
			foo:where({
				skill = 'player'
			}):update({
				skill = 'Client'
			})
	]]
    for _, sub_table in ipairs(self) do
		for key, value in pairs(updates) do
			if sub_table[key] ~= nil then
				sub_table[key] = value
			end
		end
    end
end


function Colxtion:dump(depth)
	-- Default depth is 2
	if #self == 0 then depth = depth or 1 else depth = depth or 2 end
	return inspect(self, {depth = depth})
end

function Colxtion:where(search_fields, case_sensitive)
	--[[ Returns all sub-tables that match the search fields provided.

	Arguments:
		search_fields: A table mapping fields to values. The field is a table key and the values is a table or value to search for.
		caseSensitive: Determines if our comparison for values is case sensitive. Defaults to false.
	]]
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
	return Colxtion:new(out_data)
end

function Colxtion:exclude(search_fields, case_sensitive)
	--[[ Returns all sub-tables that match the search fields provided.

	Arguments:
		search_fields: A table mapping fields to values. The field is a table key and the values is a table or value to search for.
		caseSensitive: Determines if our comparison for values is case sensitive. Defaults to false.
	]]
	-- Handling default arguments
	case_sensitive = case_sensitive or false

	-- If no search fields, we return untouched data
	if search_fields == nil then return self end

	local out_data = {}

	-- Iterate our data tables, we take it one table at a time
	for _, data in ipairs(self) do
		for field, values in pairs(search_fields) do
			-- 	Confiming that our value is a table, if it's not, we make it a table
			local field_value = data[field]

			-- Custom match function
			if field_value ~= nil and self.contains(values, field_value, case_sensitive) then
				goto failed
			end

		end -- end field/value in search fields
		-- if we got here, we haven't failed on any field/value pairs
		table.insert(out_data, data)
		::failed::
	end
	return Colxtion:new(out_data)
end

function Colxtion:dup_field(source_search_fields, destination_search_fields, fields_to_copy)
	--[[ Duplicates the values of requested fields from the field of the source results to the fields of the destination results.

	Arguments:
		source_search_fields: a Colxtion where field to find a single table in our Colxtion.
		desination_search_fields: A Colxtion where field to find the destination tables.
		fields_to_copy: A list of fields to copy from the source table to the destination tables.

	Returns true if the alteration was sucessful or false if it wasn't.
	]]
	-- Making sure our fields_to_copy is a table, if not we make it a table
	if type(fields_to_copy) ~= 'table' then fields_to_copy = {fields_to_copy} end

	-- Finding our source sub-table
	local source_table = self:where(source_search_fields)

	-- Checking if we only have one result and that the result is a table
	if #source_table > 1 and type(source_table[1]) == 'table' then return false end
	source_table = Colxtion:new(source_table[1])
	-- Also checking that our source_table has all the keys that we're expecting
	for _, field in ipairs(fields_to_copy) do
		if not source_table:contains(field) then return false end
	end

	-- Finding our desination tables
	local dest_tables = self:where(destination_search_fields)

	-- Making sure that we have atleast one destination field and it's a table
	if #dest_tables < 1 and type(dest_tables[1]) == 'table' then return false end

	-- Iterating our desination tables and setting our fields
	for _, sub_table in ipairs(dest_tables) do
		for field in fields_to_copy do
			sub_table[field] = source_table[field]
		end
	end

	-- If we've gotten here, looks like we've successfully copied our fields over
	return true
end
