--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Tag = require(ReplicatedStorage.Shared.Utility.Tag)
local Util = require(script.Parent.Util)

local DEBUG = false
local BAD_TAGS = {
	Tag.Enum.Hitstun,
	Tag.Enum.Attacking,
	Tag.Enum.Blocking,
	Tag.Enum.EndLag,
	Tag.Enum.Ragdoll,
	Tag.Enum.Dashing,
	Tag.Enum.Airborne,
	Tag.Enum.PerformingAbility,
}

-- guarantees root and hum
local function canAct(char: Model, excludeList: { string }?, includeList: { string }?): boolean
	if not Util.isLive(char) or not Util.isAlive(char) or not Util.getRoot(char) then
		return false
	end

	local tags = table.clone(BAD_TAGS)

	if includeList and #includeList > 0 then
		table.move(includeList, 1, #includeList, #tags + 1, tags)
	end

	if excludeList and #excludeList > 0 then
		for _, tag in excludeList do
			local index = table.find(tags, tag)
			if index then
				table.remove(tags, index)
			end
		end
	end

	for _, tag in tags do
		if Tag.has(char, tag) then
			if DEBUG then
				Util.logWarn(script.Name, `{char.Name} cannot act due to '{tag}' tag`)
			end
			return false
		end
	end

	return true
end

return canAct
