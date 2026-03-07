--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local WeldAndScale = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"):WaitForChild("WeldAndScale"))
local CustomizationConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("CustomizationConfig"))

local CustomizationMeshes = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("CustomizeMeshes")

local ClothingHandler = {}

function ClothingHandler.GetDefaultClothingLists(): { Shirt: { string }, Pants: { string }, Shoes: { string }, Accessory: { string } }
	local shirts = table.clone(CustomizationConfig.DefaultShirts)
	local pants = table.clone(CustomizationConfig.DefaultPants)
	local shoes = table.clone(CustomizationConfig.DefaultShoes)
	local accessories = table.clone(CustomizationConfig.DefaultAccessories)

	for _, v in CustomizationMeshes.Clothing.Pants:GetDescendants() do
		if v:IsA("Configuration") then
			table.insert(pants, v.Name)
		end
	end
	for _, v in CustomizationMeshes.Clothing.Shirt:GetDescendants() do
		if v:IsA("Configuration") then
			table.insert(shirts, v.Name)
		end
	end
	for _, v in CustomizationMeshes.Clothing.Shoes:GetDescendants() do
		if v:IsA("Configuration") then
			table.insert(shoes, v.Name)
		end
	end

	return { Shirt = shirts, Pants = pants, Shoes = shoes, Accessory = accessories }
end

function ClothingHandler.RefreshPants(char: Model, pantsId: any, clothingFolder: Folder)
	local charPantsFolder = clothingFolder:WaitForChild("Pants")
	for _, v in charPantsFolder:GetChildren() do
		if v.Name == "Pants" then
			v:Destroy()
		end
	end
	local findPants = CustomizationMeshes:WaitForChild("Clothing"):WaitForChild("Pants"):FindFirstChild(tostring(pantsId), true)
	if findPants then
		local model = findPants:FindFirstChildOfClass("Model")
		if model then
			WeldAndScale.WeldAndScale({ Char = char, WeldReference = model, Parent = charPantsFolder, Name = "Pants" })
		end
	end
end

function ClothingHandler.RefreshShirt(char: Model, shirtId: any, clothingFolder: Folder)
	local charShirtFolder = clothingFolder:WaitForChild("Shirt")
	for _, v in charShirtFolder:GetChildren() do
		if v.Name == "Shirt" then
			v:Destroy()
		end
	end
	local findShirt = CustomizationMeshes:WaitForChild("Clothing"):WaitForChild("Shirt"):FindFirstChild(tostring(shirtId), true)
	if findShirt then
		local model = findShirt:FindFirstChildOfClass("Model")
		if model then
			WeldAndScale.WeldAndScale({ Char = char, WeldReference = model, Parent = charShirtFolder, Name = "Shirt" })
		end
	end
end

function ClothingHandler.RefreshShoes(char: Model, shoesId: any, clothingFolder: Folder)
	local charShoesFolder = clothingFolder:WaitForChild("Shoes")
	for _, v in charShoesFolder:GetChildren() do
		if v.Name == "Shoes" then
			v:Destroy()
		end
	end
	local findShoes = CustomizationMeshes:WaitForChild("Clothing"):WaitForChild("Shoes"):FindFirstChild(tostring(shoesId), true)
	if findShoes then
		local model = findShoes:FindFirstChildOfClass("Model")
		if model then
			WeldAndScale.WeldAndScale({ Char = char, WeldReference = model, Parent = charShoesFolder, Name = "Shoes" })
		end
	end
end

function ClothingHandler.RefreshAccessory(char: Model, accessoryId: any, clothingFolder: Folder)
	local charAccessoryFolder = clothingFolder:WaitForChild("Accessory")
	for _, v in charAccessoryFolder:GetChildren() do
		if v.Name == "Accessory" then
			v:Destroy()
		end
	end
	local findAccessory = CustomizationMeshes:WaitForChild("Clothing"):WaitForChild("Accessory"):FindFirstChild(tostring(accessoryId), true)
	if findAccessory then
		local model = findAccessory:FindFirstChildOfClass("Model")
		if model then
			WeldAndScale.WeldAndScale({ Char = char, WeldReference = model, Parent = charAccessoryFolder, Name = "Accessory" })
		end
	end
end

function ClothingHandler.UnlockItem(data: any, category: string, itemName: string)
	local unlocked = data.Data.CharacterData.UnlockedClothing
	if not unlocked[category] then
		unlocked[category] = {}
	end
	if not unlocked[category][itemName] then
		unlocked[category][itemName] = itemName
	end
end

function ClothingHandler.IsItemUnlocked(data: any, category: string, itemName: string): boolean
	local unlocked = data.Data.CharacterData.UnlockedClothing
	if not unlocked[category] then
		return false
	end
	for _, v in pairs(unlocked[category]) do
		if v == itemName then
			return true
		end
	end
	return false
end

return ClothingHandler
