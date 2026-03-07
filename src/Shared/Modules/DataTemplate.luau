--!strict

local DEFAULT_COLOR_ENTRY = {
	Primary = { R = 255, G = 255, B = 255 },
	Secondary = { R = 255, G = 255, B = 255 },
	Tertiary = { R = 255, G = 255, B = 255 },
}

local DataTemplate = {
	_version = 1,
	Data = {
		Currency = {
			Money = 0,
		},
		CharacterData = {
			Body = {
				Width = 3,
				Height = 3,
				Depth = 3,
				SkinColor = 1,
			},
			Clothes = {
				Pants = 1,
				Shirt = 1,
				Accessory = 1,
				Shoes = 1,
			},
			Head = {
				Hair = 1,
				Facial = 1,
				Eyes = 1,
				Mouth = 1,
				Nose = 1,
			},
			Race = {
				RaceType = "Human",
				BodyType = 0,
			},
			Color = {
				Hair = table.clone(DEFAULT_COLOR_ENTRY),
				Facial = table.clone(DEFAULT_COLOR_ENTRY),
				Shirt = table.clone(DEFAULT_COLOR_ENTRY),
				Pants = table.clone(DEFAULT_COLOR_ENTRY),
				Shoes = table.clone(DEFAULT_COLOR_ENTRY),
				Accessory = table.clone(DEFAULT_COLOR_ENTRY),
			},
			Misc = {
				Build = 1,
			},
			UnlockedClothing = {
				Shirt = {},
				Pants = {},
				Shoes = {},
				Accessory = {},
			},
		},
	},
	GamePasses = {
		Products = {
			Realm = {
				DatePurchased = 0,
				RealmCode = "",
			},
			RaceSpins = 0,
		},
	},
}

return DataTemplate
