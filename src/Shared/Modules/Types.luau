--!strict

export type BodyData = {
	Width: number,
	Height: number,
	Depth: number,
	SkinColor: number,
}

export type ClothesData = {
	Pants: number,
	Shirt: number,
	Accessory: number,
	Shoes: number,
}

export type HeadData = {
	Hair: number,
	Facial: number,
	Eyes: number,
	Mouth: number,
	Nose: number,
}

export type RaceData = {
	RaceType: string,
	BodyType: number,
}

export type ColorEntry = {
	Primary: { R: number, G: number, B: number },
	Secondary: { R: number, G: number, B: number },
	Tertiary: { R: number, G: number, B: number },
}

export type ColorData = {
	Hair: ColorEntry,
	Facial: ColorEntry,
	Shirt: ColorEntry,
	Pants: ColorEntry,
	Shoes: ColorEntry,
	Accessory: ColorEntry,
}

export type MiscData = {
	Build: number,
}

export type UnlockedClothingData = {
	Shirt: { [string]: string },
	Pants: { [string]: string },
	Shoes: { [string]: string },
	Accessory: { [string]: string },
}

export type CharacterData = {
	Body: BodyData,
	Clothes: ClothesData,
	Head: HeadData,
	Race: RaceData,
	Color: ColorData,
	Misc: MiscData,
	UnlockedClothing: UnlockedClothingData,
}

export type CurrencyData = {
	Money: number,
}

export type RealmProduct = {
	DatePurchased: number,
	RealmCode: string,
}

export type ProductsData = {
	Realm: RealmProduct,
	RaceSpins: number,
}

export type GamePassBlock = {
	Products: ProductsData,
}

export type DataBlock = {
	Currency: CurrencyData,
	CharacterData: CharacterData,
}

export type PlayerData = {
	_version: number,
	Data: DataBlock,
	GamePasses: GamePassBlock,
}

export type ClothingCategory = "Shirt" | "Pants" | "Shoes" | "Accessory"

export type RaceType =
	"Human"
	| "Kamado"
	| "Uchiha"
	| "Vampire"
	| "Saiyan"
	| "Fishman"
	| "Hyuga"
	| "Mink"
	| "Ymir's Subject"
	| "Pyrokinetic"
	| "BleachThing"

export type NotificationType = "Positive" | "Negative" | "Normal" | "Warning" | "Rainbow"

export type CustomizeAction = "Left" | "Right" | "SelectClothing" | "Purchase"

return nil
