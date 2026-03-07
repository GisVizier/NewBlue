--!strict

local Enums = {}

Enums.NotificationType = {
	Positive = "Positive",
	Negative = "Negative",
	Normal = "Normal",
	Warning = "Warning",
	Rainbow = "Rainbow",
}

Enums.CustomizeAction = {
	Left = "Left",
	Right = "Right",
	SelectClothing = "SelectClothing",
	Purchase = "Purchase",
}

Enums.ClothingCategory = {
	Shirt = "Shirt",
	Pants = "Pants",
	Shoes = "Shoes",
	Accessory = "Accessory",
}

Enums.RealmAction = {
	Generate = "Generate",
	Ban = "Ban",
	Revoke = "Revoke",
	Join = "Join",
}

return Enums
