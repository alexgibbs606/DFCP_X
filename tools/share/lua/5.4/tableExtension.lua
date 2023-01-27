local inspect = require 'inspect'


table.contains = function(refTable, searchField, caseSensitive)
	-- If our reftable is empty, we return false
	if refTable == nil then return false end

	-- By default we're case sensitive
	caseSensitive = caseSensitive or true

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
