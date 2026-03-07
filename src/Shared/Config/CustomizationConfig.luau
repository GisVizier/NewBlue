--!strict

local CustomizationConfig = {
	WidthTable = { 0.77, 0.81, 0.835, 0.86, 0.89 },
	HeightTable = { 0.9, 0.95, 1, 1.04, 1.08 },
	DepthTable = { 0.81, 0.83, 0.87, 0.91, 0.95 },

	WrapOrders = {
		Pants = 1,
		Shirt = 2,
		Accessory = 3,
	},

	DefaultShirts = { "1", "2", "3", "4", "5", "6", "7", "8", "9" },
	DefaultPants = { "1", "2", "3", "4", "5", "6", "7", "8", "9" },
	DefaultShoes = { "1", "2", "3", "4", "5", "6", "7", "8", "9" },
	DefaultAccessories = { "1" },

	SmartBoneDefaults = {
		Stiffness = 0.4,
		Inertia = 0.8,
		Dampning = 1,
		Gravity = Vector3.new(0, 20, 0),
		Elasticity = 1,
	},

	MAX_BODY_VALUE = 5,
	MAX_SKIN_COLOR = 14,
}

return CustomizationConfig
