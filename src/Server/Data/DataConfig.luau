--[[
    Data store configuration for VastBlue.
    Bump StoreVersion when making breaking schema changes (invalidates old profiles).
]]

return {
	DataStore = {
		StoreVersion = 1,
		Disabled = false, -- Set true for Studio testing without DataStore
	},
}
