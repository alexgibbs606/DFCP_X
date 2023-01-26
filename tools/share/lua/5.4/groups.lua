require 'mission_io'

groups = {}

groups.updateFrequency = function(mission, newFrequency, taskBlacklist, groupBlacklist, taskWhitelist, groupWhitelist, caseSensitive)
	--[[ Updates the default radio frequency for all plane groups in blule coalition

	If a group matches any blacklist, nothing will be changed. We side on the option to NOT change data.

	Arguments:
		mission: Mission reference. Open with mission_io
		newFrequency: The new frequency for all blue planes. Beward that not all planes have the same range. This can cause an issue. Defaults to 269.
		taskBlacklist: Will only update the frequency if this ISN'T the task that the airframe group has been given. Defaults to {'awacs'}.
		groupBlacklist: Will only update the frequency if the group ISN'T labeled this.
		taskWhitelist: Will only update the frequency if this IS the task that the airframe group has been given.
		groupWhitelist: Will only update the frequency if the group IS labeled this.
		caseSensitive: If the whitelists and blacklists are case sensitive. Defaults to false.
	--]]

	-- Handling keyword arguments
	if mission.mission ~= nil then
		if type(mission.newFrequency) == 'string' then newFrequency = {mission.newFrequency} else newFrequency = mission.newFrequency end
		if type(mission.taskBlacklist) == 'string' then taskBlacklist = {mission.taskBlacklist} else taskBlacklist = mission.taskBlacklist end
		if type(mission.groupBlacklist) == 'string' then groupBlacklist = {mission.groupBlacklist} else groupBlacklist = mission.groupBlacklist end
		if type(mission.taskWhitelist) == 'string' then taskWhitelist = {mission.taskWhitelist} else taskWhitelist = mission.taskWhitelist end
		if type(mission.caseSensitive) == 'string' then groupWhitelist = {mission.caseSensitive} else groupWhitelist = mission.caseSensitive end
		if type(mission.caseSensitive) == 'string' then caseSensitive = {mission.caseSensitive} else caseSensitive = mission.caseSensitive end
		mission = mission.mission
	end

	-- Default arguments
	taskBlacklist = taskBlacklist or {'awacs'}
	newFrequency = newFrequency or 269
	caseSensitive = caseSensitive or false

	-- Gathering the groups from our mission
	local groups = mission_io.get_groups{mission=mission, coalition='blue', unit_type='plane'}

	-- If our blacklist is empty, we don't process it
	local blacklistEmpty = taskBlacklist == nil and groupBlacklist == nil
	local whitelistEmpty = taskWhitelist == nil and groupWhitelist == nil

	-- Iterate through our groups to filter them out
	for _, group in pairs(groups) do
		-- Blacklist checks
		if blacklistEmpty
			or table.contains(taskBlacklist, group.task, caseSensitive)
			or table.contains(groupBlacklist, group.name, caseSensitive)
		then
			-- if we receive a blacklist match at all, we don't update the frequency
			goto blacklist
		end

		-- Whitelist checks
		if whitelistEmpty
			or table.contains(taskWhitelist, group.task, caseSensitive)
			or table.contains(groupWhitelist, group.name, caseSensitive)
		then
			group.frequency = newFrequency
		end

		::blacklist::
	end
end