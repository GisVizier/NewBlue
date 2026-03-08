--!strict

local function deepFreeze(t: { [any]: any }, seen: { [any]: boolean })
	if seen[t] then
		return
	end
	seen[t] = true

	for _, v in t do
		if type(v) == "table" then
			deepFreeze(v, seen)
		end
	end

	if not table.isfrozen(t) then
		table.freeze(t)
	end
end

return function<T>(t: T): T
	if type(t) == "table" then
		deepFreeze(t, {})
	end
	return t
end
