--!strict

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Net"))
local CustomizationConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("CustomizationConfig"))
local Cleanup = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"):WaitForChild("Cleanup"))
local DataService = require(script.Parent.DataService)
local NotificationService = require(script.Parent.NotificationService)

local ClothingHandler = require(script.ClothingHandler)
local AppearanceHandler = require(script.AppearanceHandler)
local RaceHandler = require(script.RaceHandler)
local ColorHandler = require(script.ColorHandler)
local ProportionHandler = require(script.ProportionHandler)

local CustomizationMeshes = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("CustomizeMeshes")

local characterCleanups: { [Model]: any } = {}

local CustomizationService = {}

function CustomizationService:Init()
	RaceHandler.Init()
end

function CustomizationService:Start()
	Players.PlayerAdded:Connect(function(player)
		self:_onPlayerAdded(player)
	end)

	for _, player in Players:GetPlayers() do
		task.spawn(function()
			self:_onPlayerAdded(player)
		end)
	end

	Net.listen("CustomizeEvent", function(player: Player, params: any)
		self:_onCustomizeEvent(player, params)
	end)

	Net.listen("UpdateColorEvent", function(player: Player, params: any)
		self:_onUpdateColor(player, params)
	end)
end

function CustomizationService:_onPlayerAdded(player: Player)
	local data = DataService.WaitForData(player)
	if not data then
		return
	end

	local function onCharacterAdded(char: Model)
		self:_loadCharacter(player, char, data)
	end

	if player.Character then
		onCharacterAdded(player.Character)
	end
	player.CharacterAdded:Connect(onCharacterAdded)

	-- Set archivable on character
	player.CharacterAdded:Connect(function(char)
		char.Archivable = true
	end)

	-- Grant default clothing
	local defaults = ClothingHandler.GetDefaultClothingLists()
	for _, name in defaults.Shirt do
		ClothingHandler.UnlockItem(data, "Shirt", name)
	end
	for _, name in defaults.Pants do
		ClothingHandler.UnlockItem(data, "Pants", name)
	end
	for _, name in defaults.Accessory do
		ClothingHandler.UnlockItem(data, "Accessory", name)
	end
	for _, name in defaults.Shoes do
		ClothingHandler.UnlockItem(data, "Shoes", name)
	end
end

function CustomizationService:_loadCharacter(player: Player, char: Model, data: any)
	local oldCleanup = characterCleanups[char]
	if oldCleanup then
		oldCleanup:Destroy()
	end

	local cleanup = Cleanup.new()
	characterCleanups[char] = cleanup

	cleanup:Add(function()
		characterCleanups[char] = nil
	end)

	local charData = data.Data.CharacterData

	-- Ensure clothing folder exists
	local clothingFolder = char:FindFirstChild("Clothing") :: Folder?
	if not clothingFolder then
		-- Clone from a template folder or create structure
		local templateFolder = Instance.new("Folder")
		templateFolder.Name = "Clothing"
		local pantsF = Instance.new("Folder")
		pantsF.Name = "Pants"
		pantsF.Parent = templateFolder
		local shirtF = Instance.new("Folder")
		shirtF.Name = "Shirt"
		shirtF.Parent = templateFolder
		local shoesF = Instance.new("Folder")
		shoesF.Name = "Shoes"
		shoesF.Parent = templateFolder
		local accessoryF = Instance.new("Folder")
		accessoryF.Name = "Accessory"
		accessoryF.Parent = templateFolder
		templateFolder.Parent = char
		clothingFolder = templateFolder
	end

	-- Ensure race additions folder
	local raceAdditionsFolder = char:FindFirstChild("RaceAdditions")
	if not raceAdditionsFolder then
		raceAdditionsFolder = Instance.new("Folder")
		raceAdditionsFolder.Name = "RaceAdditions"
		raceAdditionsFolder.Parent = char
	end

	-- Apply all customization
	AppearanceHandler.RefreshHair(char, charData.Head.Hair)
	AppearanceHandler.RefreshFacial(char, charData.Head.Facial)
	AppearanceHandler.RefreshFace(char, charData.Head.Eyes, charData.Head.Mouth, charData.Head.Nose)
	AppearanceHandler.RefreshSkin(char, charData.Race.RaceType, charData.Body.SkinColor)
	RaceHandler.ApplyRaceAdditions(char, charData.Race.RaceType, charData.Race.BodyType)
	ProportionHandler.Apply(char, charData.Body.Width, charData.Body.Height, charData.Body.Depth)
	ClothingHandler.RefreshPants(char, charData.Clothes.Pants, clothingFolder :: Folder)
	ClothingHandler.RefreshShirt(char, charData.Clothes.Shirt, clothingFolder :: Folder)
	ClothingHandler.RefreshAccessory(char, charData.Clothes.Accessory, clothingFolder :: Folder)
	ClothingHandler.RefreshShoes(char, charData.Clothes.Shoes, clothingFolder :: Folder)
	ColorHandler.RefreshColors(char, charData.Color, false)
	AppearanceHandler.RefreshBuild(char, charData.Misc.Build)
	self:_refreshOrder(char)

	-- Cleanup on character removal
	cleanup:Add(char:GetPropertyChangedSignal("Parent"):Connect(function()
		if char.Parent == nil then
			cleanup:Destroy()
		end
	end))
end

function CustomizationService:_refreshOrder(char: Model)
	for _, v in char:GetChildren() do
		if CustomizationConfig.WrapOrders[v.Name] then
			for _, e in v:GetDescendants() do
				if e:IsA("WrapLayer") then
					e.Order = CustomizationConfig.WrapOrders[v.Name]
				end
			end
		end
	end
end

function CustomizationService:_onCustomizeEvent(player: Player, params: any)
	if type(params) ~= "table" then
		return
	end

	local data = DataService.GetData(player)
	if not data then
		return
	end

	local char = player.Character
	if not char then
		return
	end

	local action = params.Action
	local item = params.Item
	local category = params.Category
	local shop = params.Shop
	local charData = data.Data.CharacterData
	local clothingFolder = char:FindFirstChild("Clothing") :: Folder?

	if action == "Left" or action == "Right" then
		local increment = if action == "Left" then -1 else 1

		-- Check body values
		local bodyFields = { "Width", "Height", "Depth" }
		for _, field in bodyFields do
			if item == field then
				charData.Body[field] = math.clamp(charData.Body[field] + increment, 1, CustomizationConfig.MAX_BODY_VALUE)
				ProportionHandler.Apply(char, charData.Body.Width, charData.Body.Height, charData.Body.Depth)
				if clothingFolder then
					ClothingHandler.RefreshPants(char, charData.Clothes.Pants, clothingFolder)
					ClothingHandler.RefreshShirt(char, charData.Clothes.Shirt, clothingFolder)
					ClothingHandler.RefreshAccessory(char, charData.Clothes.Accessory, clothingFolder)
					ClothingHandler.RefreshShoes(char, charData.Clothes.Shoes, clothingFolder)
				end
				ColorHandler.RefreshColors(char, charData.Color, true)
				return
			end
		end

		-- Check head values
		local headFields = { Hair = "Hair", Facial = "Beard", Eyes = "Eyes", Mouth = "Mouth", Nose = "Nose" }
		for field, meshName in pairs(headFields) do
			if item == field then
				local meshFolder = CustomizationMeshes:FindFirstChild(meshName, true)
					or CustomizationMeshes:WaitForChild("FaceDecals"):FindFirstChild(meshName)
				if meshFolder then
					charData.Head[field] = math.clamp(charData.Head[field] + increment, 1, #meshFolder:GetChildren())
				end
				if field == "Hair" then
					AppearanceHandler.RefreshHair(char, charData.Head.Hair)
				elseif field == "Facial" then
					AppearanceHandler.RefreshFacial(char, charData.Head.Facial)
				else
					AppearanceHandler.RefreshFace(char, charData.Head.Eyes, charData.Head.Mouth, charData.Head.Nose)
				end
				ColorHandler.RefreshColors(char, charData.Color, true)
				return
			end
		end

		-- Check misc values
		if item == "Build" then
			local buildFolder = CustomizationMeshes:WaitForChild("Build")
			charData.Misc.Build = math.clamp(charData.Misc.Build + increment, 1, #buildFolder:GetChildren())
			AppearanceHandler.RefreshBuild(char, charData.Misc.Build)
			return
		end
	end

	if item == "SkinColor" then
		local skinVal = tonumber(action)
		if skinVal and skinVal >= 1 and skinVal <= CustomizationConfig.MAX_SKIN_COLOR then
			charData.Body.SkinColor = skinVal
			AppearanceHandler.RefreshSkin(char, charData.Race.RaceType, charData.Body.SkinColor)
		end
		return
	end

	if action == "SelectClothing" then
		if type(category) ~= "string" or type(item) ~= "string" then
			return
		end
		local validCategories = { Shirt = true, Pants = true, Shoes = true, Accessory = true }
		if not validCategories[category] then
			return
		end

		local findClothes = CustomizationMeshes:WaitForChild("Clothing"):WaitForChild(category):FindFirstChild(tostring(item), true)
		if not findClothes then
			return
		end

		local unlocked = ClothingHandler.IsItemUnlocked(data, category, item)

		-- Check gamepass override
		local gamepassFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("ClothingShopData"):WaitForChild("Gamepasses")
		local gamepass = gamepassFolder:FindFirstChild(findClothes.Parent.Name)
		if gamepass then
			local owns = false
			pcall(function()
				owns = MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepass.Value)
			end)
			unlocked = owns
		end

		if unlocked then
			charData.Clothes[category] = item
			if clothingFolder then
				if category == "Pants" then
					ClothingHandler.RefreshPants(char, item, clothingFolder)
				elseif category == "Shirt" then
					ClothingHandler.RefreshShirt(char, item, clothingFolder)
				elseif category == "Shoes" then
					ClothingHandler.RefreshShoes(char, item, clothingFolder)
				elseif category == "Accessory" then
					ClothingHandler.RefreshAccessory(char, item, clothingFolder)
				end
			end
			ColorHandler.RefreshColors(char, charData.Color, true)
		end
		return
	end

	if action == "Purchase" then
		if type(category) ~= "string" or type(shop) ~= "string" then
			return
		end
		local findShop = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("ClothingShopData"):FindFirstChild(shop)
		if not findShop then
			return
		end
		local findCategory = findShop:FindFirstChild(category)
		if not findCategory then
			return
		end
		local findItem = findCategory:FindFirstChild(item)
		if not findItem then
			return
		end

		local price = findItem.Value
		local money = data.Data.Currency.Money
		if money >= price then
			data.Data.Currency.Money = money - price
			ClothingHandler.UnlockItem(data, findCategory.Name, item)
			NotificationService.Send(player, "Successful Purchase", "Positive", nil, "Sound1")
		else
			NotificationService.Send(player, "Not enough Veli", "Warning", nil, "Attention")
		end
		return
	end
end

function CustomizationService:_onUpdateColor(player: Player, params: any)
	if type(params) ~= "table" then
		return
	end

	local data = DataService.GetData(player)
	if not data then
		return
	end

	local r = tonumber(params.R)
	local g = tonumber(params.G)
	local b = tonumber(params.B)
	local item = params.Item
	local colorType = params.Type

	if not r or not g or not b or type(item) ~= "string" or type(colorType) ~= "string" then
		return
	end

	ColorHandler.SetColor(data, item, colorType, r, g, b)

	local char = player.Character
	if char then
		ColorHandler.RefreshColors(char, data.Data.CharacterData.Color, true)
	end
end

return CustomizationService
