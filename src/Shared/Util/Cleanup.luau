--!strict

local Cleanup = {}
Cleanup.__index = Cleanup

function Cleanup.new()
	local self = setmetatable({}, Cleanup)
	self._items = {} :: { any }
	return self
end

function Cleanup:Add(item: any)
	table.insert(self._items, item)
	return item
end

function Cleanup:Destroy()
	for _, item in self._items do
		if typeof(item) == "RBXScriptConnection" then
			item:Disconnect()
		elseif typeof(item) == "Instance" then
			item:Destroy()
		elseif type(item) == "function" then
			item()
		elseif type(item) == "table" and type(item.Destroy) == "function" then
			item:Destroy()
		end
	end
	table.clear(self._items)
end

return Cleanup
