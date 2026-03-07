local CS =game:GetService("CollectionService")

local WeldAndScale = require(game:GetService("ServerStorage"):WaitForChild("Modules"):WaitForChild("UtilityModules"):WaitForChild("WeldAndScale"))
local CustomizationMeshes =game:GetService("ReplicatedStorage"):WaitForChild("CustomizeMeshes")
local CustomizeEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CustomizeEvent")
local RaceAdditions = CustomizationMeshes:WaitForChild("RaceAdditions")

local WidthTable = {
	0.77;
	0.81;
	0.835;
	0.86;
	0.89;
}

local HeightTable = {
	0.9;
	0.95;
	1;
	1.04;
	1.08;

}

local DepthTable = {
	0.81;
	0.83;
	0.87;
	0.91;
	0.95;

}

local DefaultShirts = {
	[1] = "1";
	[2] = "2";
	[3] = "3";
	[4] = "4";
	[5] = "5";
	[6] = "6";
	[7] = "7";
	[8] = "8";
	[9] = "9";

}

local DefaultPants = {
	[1] = "1";
	[2] = "2";
	[3] = "3";
	[4] = "4";
	[5] = "5";
	[6] = "6";
	[7] = "7";
	[8] = "8";
	[9] = "9";

}


local DefaultShoes = {
	[1] = "1";
	[2] = "2";
	[3] = "3";
	[4] = "4";
	[5] = "5";
	[6] = "6";
	[7] = "7";
	[8] = "8";
	[9] = "9";

}



for i,v in pairs(CustomizationMeshes.Clothing.Pants:GetDescendants())do
	if v:IsA("Configuration") then
		table.insert(DefaultPants,v.Name)
	end
end

for i,v in pairs(CustomizationMeshes.Clothing.Shirt:GetDescendants())do
	if v:IsA("Configuration") then
		table.insert(DefaultShirts,v.Name)
	end
end

for i,v in pairs(CustomizationMeshes.Clothing.Shoes:GetDescendants())do
	if v:IsA("Configuration") then
		table.insert(DefaultShoes,v.Name)
	end
end

local DefaultAccessories = {
	[1] = "1"
}


local WrapOrders= {
	["Pants"] = 1;
	["Shirt"] = 2;
	["Accessory"] = 3;
}

local function LoadCustomization(Params)
	
	local Char = Params.Char
	local hum = Char:WaitForChild("Humanoid")
	
	local Pants = Params.Pants
	local Shirt = Params.Shirt
	local Accessory = Params.Accessory
	local Shoes = Params.Shoes
	
	local Facial = Params.Facial
	local Eyes = Params.Eyes
	local Hair = Params.Hair
	local Mouth = Params.Mouth
	local Nose = Params.Nose
	
	local Build = Params.Build
	
	local RaceType = Params.RaceType
	local BodyType = Params.BodyType
	
	local Depth = Params.Depth
	local Height = Params.Height
	local Width = Params.Width
	local SkinColor = Params.SkinColor
	
	local ColorData = Params.ColorData
	
	
	local CharacterClothingFolder = Char:FindFirstChild("Clothing")
	if not CharacterClothingFolder then
		CharacterClothingFolder = script.Clothing:Clone()
		CharacterClothingFolder.Parent = Char
	end
	
	local CharacterRaceAdditions = Char:FindFirstChild("RaceAdditions")
	if not CharacterRaceAdditions then
		CharacterRaceAdditions = Instance.new("Folder")
		CharacterRaceAdditions.Name = "RaceAdditions"
		CharacterRaceAdditions.Parent = Char
	end

	
--Color
	local function RefreshColors(Params)
		local Tween = true
		
		local HairColor = ColorData.Hair.Primary.Value
		local Hair = Char:FindFirstChild("Hair")
		if Hair then

            for i,v in pairs(Char.Head:GetDescendants())do
                if v:IsA('Decal') and  v.Name == "Eyebrows" then
                    if Tween then
                        game:GetService("TweenService"):Create(v,TweenInfo.new(0.3,Enum.EasingStyle.Sine),{Color3 = HairColor}):Play()

                    else
                        v.Color = HairColor
                    end
                end	
            end

            for i,v in pairs(Hair:GetDescendants())do
                if v:IsA('BasePart') then
                if v.Name == "DONTCHANGE" then return end
					if Tween then
						game:GetService("TweenService"):Create(v,TweenInfo.new(0.3,Enum.EasingStyle.Sine),{Color = HairColor}):Play()

					else
						v.Color = HairColor
					end
				end	
			end
		end

        local BeardColor = ColorData.Facial.Primary.Value
        local Beard = Char:FindFirstChild("Beard")

        if Beard then
            for i,v in pairs(Beard:GetDescendants())do
                if v:IsA('BasePart') then
                    if Tween then
                        game:GetService("TweenService"):Create(v,TweenInfo.new(0.3,Enum.EasingStyle.Sine),{Color = BeardColor}):Play()

                    else
                        v.Color = BeardColor
                    end
                end	
            end
        end
		
		--[[
		local FinalIndex = {}
		for i,v in CharacterClothingFolder:GetChildren() do if v.Name ~= "CrewClothes" then table.insert(FinalIndex,v) end end
		for i,v in CharacterRaceAdditions:GetChildren() do table.insert(FinalIndex,v) end

		for i,v in pairs(FinalIndex)do
			local FindColorData
			if v:IsDescendantOf(CharacterRaceAdditions) then
				FindColorData = ColorData.Shirt
			else
				FindColorData = ColorData[v.Name]
			end
			

			local Primary = FindColorData.Primary.Value
			local Secondary = FindColorData.Secondary.Value
			local Tertiary = FindColorData.Tertiary.value
			


			for _,e in pairs(v:GetDescendants())do
				if e:IsA("BasePart") then
					if e.Name == "Fin" then
					end
					local FinalColor

					if e.Name == "Secondary" or e:FindFirstChild("Secondary") or e.Parent.Name == "Secondary" then
						FinalColor = Secondary
					elseif e.Name == "Tertiary" or e:FindFirstChild("Tertiary") or e.Parent.Name == "Tertiary" then
						FinalColor = Tertiary
						
					elseif e.Name == "KeepSkinColor" or e:FindFirstChild("KeepSkinColor") or e.Parent.Name == "KeepSkinColor" then
						FinalColor = Char.PrimaryPart.Color
					elseif e.Name == "KeepHairColor" or e:FindFirstChild("KeepHairColor") or e.Parent.Name == "KeepHairColor" then
						FinalColor = HairColor
					else
						FinalColor = Primary
					end

					if Tween then
						game:GetService("TweenService"):Create(e,TweenInfo.new(0.3,Enum.EasingStyle.Sine),{Color = FinalColor}):Play()
					else
						e.Color = FinalColor
					end
				end
			end
			
			
		
		end
		--]]

	

	end

	RefreshColors({})
	
	
	--Order

	local function RefreshOrder()
		for i,v in pairs(Char:GetChildren())do
			if WrapOrders[v.Name] then
				for _,e in pairs(v:GetDescendants())do
					if e:IsA("WrapLayer") then
						e.Order = WrapOrders[v.Name]
					end
				end
			end
		end
	end
	
	--Clothing
	local CharPantsFolder = CharacterClothingFolder:WaitForChild('Pants')
	local function RefreshPants()
		for i,v in pairs(CharPantsFolder:GetChildren()) do if v.Name == "Pants" then v:Destroy() end  end
		local FindPants = CustomizationMeshes:WaitForChild("Clothing"):WaitForChild("Pants"):FindFirstChild(Pants.Value,true)
		if FindPants then
			FindPants = FindPants:FindFirstChildOfClass("Model")
			WeldAndScale.WeldAndScale({Char = Char,WeldReference = FindPants,Parent = CharPantsFolder,Name = "Pants"})	
		end
		RefreshColors({})

	end
	
	local CharShirtFolder = CharacterClothingFolder:WaitForChild('Shirt')
	local function RefreshShirt()
		for i,v in pairs(CharShirtFolder:GetChildren()) do if v.Name == "Shirt" then v:Destroy() end  end
		local FindShirt= CustomizationMeshes:WaitForChild("Clothing"):WaitForChild("Shirt"):FindFirstChild(Shirt.Value,true)
		if FindShirt then
			FindShirt = FindShirt:FindFirstChildOfClass("Model")
			WeldAndScale.WeldAndScale({Char = Char,WeldReference = FindShirt,Parent = CharShirtFolder,Name = "Shirt"})
		end
		RefreshColors({})
	end
	
	local CharShoesFolder = CharacterClothingFolder:WaitForChild('Shoes')
	local function RefreshShoes()
		for i,v in pairs(CharShoesFolder:GetChildren()) do if v.Name == "Shoes" then v:Destroy() end  end
		local FindShoes= CustomizationMeshes:WaitForChild("Clothing"):WaitForChild("Shoes"):FindFirstChild(Shoes.Value,true)

		if FindShoes then
			FindShoes = FindShoes:FindFirstChildOfClass("Model")
			WeldAndScale.WeldAndScale({Char = Char,WeldReference = FindShoes,Parent = CharShoesFolder,Name = "Shoes"})
		end
		RefreshColors({})
	end
	
	local CharAccessoryFolder = CharacterClothingFolder:WaitForChild('Accessory')
	local function RefreshAccessory()
		for i,v in pairs(CharAccessoryFolder:GetChildren()) do if v.Name == "Accessory" then v:Destroy() end  end
		local FindAccessory= CustomizationMeshes:WaitForChild("Clothing"):WaitForChild("Accessory"):FindFirstChild(Accessory.Value,true)
		if FindAccessory then
			FindAccessory = FindAccessory:FindFirstChildOfClass("Model")
			WeldAndScale.WeldAndScale({Char = Char,WeldReference = FindAccessory,Parent = CharAccessoryFolder,Name = "Accessory"})	
		end
		RefreshColors({})
	end
	--Head
	local function RefreshHair()
		for i,v in pairs(Char:GetChildren()) do if v.Name == "Hair" then v:Destroy() end end
		local FindHair= CustomizationMeshes:WaitForChild("Hair"):FindFirstChild(Hair.Value)
		if FindHair then
			local Hair = WeldAndScale.WeldAndScale({Char = Char,WeldReference = FindHair,Parent = Char,Name = "Hair"})	
			
			local RealHair = Hair.PrimaryPart
			CS:AddTag(RealHair,"SmartBone")

			local Text = ""
			for i,v in pairs(RealHair:GetDescendants())do
				if v:IsA("Bone") then
					if v.Name ~= "Bone" then
						Text = Text..v.Name..","
					end
				end
			end

			RealHair:SetAttribute("Roots",Text)


			local Stiffness = RealHair:GetAttribute("Stiffness")
			if not Stiffness then
				RealHair:SetAttribute("Stiffness",0.4)
			end

			local Inertia = RealHair:GetAttribute("Inertia")
			if not Inertia then
				RealHair:SetAttribute("Inertia",0.8)
			end

			local Dampning = RealHair:GetAttribute("Dampning")
			if not Dampning then
				RealHair:SetAttribute("Dampning",1)
			end

			RealHair:SetAttribute("Gravity",Vector3.new(0,20,0))
			RealHair:SetAttribute("Elasticity",1)
			
		end
		
		RefreshColors({})
	end
	
    local function RefreshFacial()
        for i,v in pairs(Char:GetChildren()) do if v.Name == "Beard" then v:Destroy() end end
        local FindHair = CustomizationMeshes:WaitForChild("Beard"):FindFirstChild(Facial.Value)
        if FindHair then
            local Hair = WeldAndScale.WeldAndScale({Char = Char,WeldReference = FindHair,Parent = Char,Name = "Beard"})	


            local RealHair = Hair.PrimaryPart
            CS:AddTag(RealHair,"SmartBone")

            local Text = ""

            for i,v in pairs(RealHair:GetDescendants())do
                if v:IsA("Bone") then
                    if v.Name ~= "Bone" then
                        Text = Text..v.Name..","
                    end
                end
            end

            RealHair:SetAttribute("Roots",Text)


            local Stiffness = RealHair:GetAttribute("Stiffness")
            if not Stiffness then
                RealHair:SetAttribute("Stiffness",0.4)
            end

            local Inertia = RealHair:GetAttribute("Inertia")
            if not Inertia then
                RealHair:SetAttribute("Inertia",0.8)
            end

            local Dampning = RealHair:GetAttribute("Dampning")
            if not Dampning then
                RealHair:SetAttribute("Dampning",1)
            end

            RealHair:SetAttribute("Gravity",Vector3.new(0,20,0))
            RealHair:SetAttribute("Elasticity",1)

        end

        RefreshColors()
    end

	---
	
	local function TempStateConnection(Params)
		local Function  = Params.Function
		local Instances = Params.Instances
		
		local Connections = {}
		for i,v in pairs(Instances)do
			if v:IsA("ValueBase") then
				local Connection = 	v.Changed:Connect(Function)
				table.insert(Connections,Connection)
			end
		end
		
		Char:GetPropertyChangedSignal("Parent"):Connect(function()
			if Char.Parent == nil then
				for i,v in pairs(Connections) do v:Disconnect() end
			end
		end)
	end
	
	local WidthScale = hum:WaitForChild("BodyWidthScale")
	local HeightScale = hum:WaitForChild("BodyHeightScale")
	local DepthScale = hum:WaitForChild("BodyDepthScale")

	
	local function RefreshClothes()
		RefreshPants()
		RefreshShirt()
		RefreshAccessory()
		RefreshShoes()
	end
	
	RefreshHair()
    RefreshFacial()

	
	local function RefreshProportions()
	
		WidthScale.Value = WidthTable[Width.Value]
		HeightScale.Value = HeightTable[Height.Value]
		DepthScale.Value = DepthTable[Depth.Value]

		RefreshClothes()
	end
	
	local Head = Char:WaitForChild("Head")

	local function RefreshFace()
		
		for i,v in pairs(Head:GetChildren()) do
			if v:IsA("Decal") then
                if v.Name == "Mouth" or v.Name == "Eyes" or v.Name == "Nose" or v.Name == "Blink" or v.Name == "Eyebrows" or v.Name == "Pupil" then
					v:Destroy()
				end
			end
		end
		
		local FindNose = CustomizationMeshes:WaitForChild("FaceDecals"):WaitForChild("Nose"):FindFirstChild(Nose.Value)
		local FindMouth = CustomizationMeshes:WaitForChild("FaceDecals"):WaitForChild("Mouth"):FindFirstChild(Mouth.Value)
		local FindEyes = CustomizationMeshes:WaitForChild("FaceDecals"):WaitForChild("Eyes"):FindFirstChild(Eyes.Value)
		
		if FindNose and FindMouth and FindEyes then
			FindNose,FindMouth,FindEyes = FindNose:Clone(),FindMouth:Clone(),FindEyes:Clone()

			FindNose.Parent = Head
			FindMouth.Parent = Head

            if FindEyes then
                local EyesClone = FindEyes:Clone()
                for i,v in next, EyesClone:GetChildren() do
                    v.Parent = Head
                end
            end
			
			--local Blink = FindEyes:FindFirstChild("Blink")
			--Blink.Parent = Head
			
			FindNose.Name = "Nose"
			FindMouth.Name = "Mouth"

		--	FindEyes.Name = "Eyes"
		
		end

        RefreshColors({})

	end
	
	RefreshFace()
	
	local RaceSkinColors = CustomizationMeshes:WaitForChild("RaceSkinColors") 
	local HumanSkinColors = RaceSkinColors:WaitForChild("Human")
	local function RefreshSkin()
		local FindSkinColors = RaceSkinColors:FindFirstChild(RaceType.Value)
		if FindSkinColors then
			local FindSkinColor = FindSkinColors:FindFirstChild(SkinColor.Value)
			if FindSkinColor then
				for i,v in pairs(Char:GetChildren())do
					if v:IsA("BasePart") then
						v.Color = FindSkinColor.Value
					end
				end
			end	

		else
			local FindSkinColor = HumanSkinColors:FindFirstChild(SkinColor.Value)
			if FindSkinColor then
				for i,v in pairs(Char:GetChildren())do
					if v:IsA("BasePart") then
						v.Color = FindSkinColor.Value
					end
				end
			end	
		end
	end
	
	local function RefreshBuild()
		for i,v in pairs(Char:GetChildren())do
			if v.Name == "Build" then
				v:Destroy()
			end
		end
		
		local FindBuild = CustomizationMeshes:WaitForChild("Build"):FindFirstChild(Build.Value)
		if FindBuild then
			for i,v in pairs(FindBuild:GetChildren())do
				local clone = v:Clone()
				clone.Parent = Char
			end
		end
	
		
	end
	

	local function RefreshRace()
		for i,v in pairs(CharacterRaceAdditions:GetChildren()) do
			v:Destroy()
		end
		
		local FindRaceType = CustomizationMeshes:WaitForChild("RaceAdditions"):FindFirstChild(RaceType.Value)
		print(FindRaceType)
		if FindRaceType then
			local FindBodyType = FindRaceType:FindFirstChild(BodyType.Value)
			print(FindBodyType)
			if FindBodyType then
				 WeldAndScale.WeldAndScale({Char = Char,WeldReference = FindBodyType,Parent = CharacterRaceAdditions})	
			end
		end
	end
	
	
	local function RandomBodyType()
		--local RaceType = Player:WaitForChild("Data"):WaitForChild('CharacterData'):WaitForChild("Race"):WaitForChild("RaceType")
	--	local BodyType = Player:WaitForChild("Data"):WaitForChild('CharacterData'):WaitForChild("Race"):WaitForChild("BodyType")
		local FindRaceAdditions = RaceAdditions:FindFirstChild(RaceType.Value)
		if FindRaceAdditions then
			BodyType.Value = math.random(1,#FindRaceAdditions:GetChildren())
		else
			BodyType.Value = 0
		end
	end

	
	RefreshRace()
	
	
	RefreshSkin()

	
	RefreshProportions()

	RefreshOrder()
	
	RefreshBuild()
	
	local Player = game.Players:GetPlayerFromCharacter(Char)
	if Player then
		local Data = Player:WaitForChild("Data")
		local CharacterData = Data:WaitForChild("CharacterData")
		local Body = CharacterData:WaitForChild("Body")
		
		local Clothes = CharacterData:WaitForChild("Clothes")
		local Head = CharacterData:WaitForChild("Head")
		local Race = CharacterData:WaitForChild("Race")
		local ColorData = CharacterData:WaitForChild("Color")
		local SkinColor = Body:WaitForChild("SkinColor")


		local Pants = Clothes:WaitForChild("Pants")
		local Shirt = Clothes:WaitForChild("Shirt")
		local Accessory = Clothes:WaitForChild("Accessory")
		local Shoes = Clothes:WaitForChild("Shoes")
		
		local PantsInstances = Body:GetChildren()
		table.insert(PantsInstances,Pants)
		TempStateConnection({Function = RefreshPants,Instances = PantsInstances})
		local ShirtsInstances = Body:GetChildren()
		table.insert(ShirtsInstances,Shirt)
		TempStateConnection({Function = RefreshShirt,Instances = ShirtsInstances})
		local ShoesInstances = Body:GetChildren()
		table.insert(ShoesInstances,Shoes)
		TempStateConnection({Function = RefreshShoes,Instances = ShoesInstances})

		local AccessoryInstances = Body:GetChildren()
		table.insert(AccessoryInstances,Accessory)
		TempStateConnection({Function = RefreshAccessory,Instances = AccessoryInstances})
		TempStateConnection({Function = RefreshProportions,Instances = Body:GetChildren()})
		TempStateConnection({Function = RefreshHair,Instances = Head:GetChildren()})
        TempStateConnection({Function = RefreshFacial,Instances = Head:GetChildren()})
		TempStateConnection({Function = RefreshSkin,Instances = {SkinColor}})
		local function UpdateColor()
			RefreshColors({Tween = true})
		end

		
		TempStateConnection({Function = RandomBodyType,Instances = {RaceType}})
		TempStateConnection({Function = RefreshBuild,Instances = {Build}})
		
		
		TempStateConnection({Function = UpdateColor,Instances = ColorData:GetDescendants()})
		TempStateConnection({Function = RefreshRace,Instances = {RaceType,BodyType}})

		
		TempStateConnection({Function = UpdateColor,Instances = ColorData:GetDescendants()})
		TempStateConnection({Function = RefreshFace,Instances = {Nose,Mouth,Eyes}})
		
		local UnlockedClothes = CharacterData:WaitForChild("UnlockedClothing")
		for i,v in pairs(DefaultShirts)do
			_G.SetClothingData({Player = Player,Clothing = v,Type = "Shirt"})
		end
		for i,v in pairs(DefaultPants)do
			_G.SetClothingData({Player = Player,Clothing = v,Type = "Pants"})
		end
		for i,v in pairs(DefaultAccessories)do
			_G.SetClothingData({Player = Player,Clothing = v,Type = "Accessory"})
		end
		for i,v in pairs(DefaultShoes)do
			_G.SetClothingData({Player = Player,Clothing = v,Type = "Shoes"})
		end

	end
	

	
	
	
end




game.Players.PlayerAdded:Connect(function(Player)
	print(Player)
	local Data = Player:WaitForChild("Data",200)
	if Data then
		local Char = Player.Character or Player.CharacterAdded:Wait()

		local CharacterData = Data:WaitForChild("CharacterData")
		local Body = CharacterData:WaitForChild("Body")
		local Clothes = CharacterData:WaitForChild("Clothes")
		local Head = CharacterData:WaitForChild("Head")
		local Race = CharacterData:WaitForChild("Race")
		
		local Pants = Clothes:WaitForChild("Pants")
		local Shirt = Clothes:WaitForChild("Shirt")
		local Accessory = Clothes:WaitForChild("Accessory")
		local Shoes = Clothes:WaitForChild("Shoes")
		
		local Build = CharacterData:WaitForChild("Misc"):WaitForChild("Build")

		
		local Facial = Head:WaitForChild("Facial")
		local Eyes = Head:WaitForChild("Eyes")
		local Hair = Head:WaitForChild("Hair")
		local Mouth = Head:WaitForChild("Mouth")
		local Nose = Head:WaitForChild("Nose")
		
		local RaceType = Race:WaitForChild('RaceType')
		local BodyType = Race:WaitForChild("BodyType")
		
		local Depth = Body:WaitForChild("Depth")
		local Height = Body:WaitForChild("Height")
		local Width = Body:WaitForChild("Width")
		local SkinColor = Body:WaitForChild("SkinColor")
		
		local ColorData = CharacterData:WaitForChild("Color")
	
		
		Player.CharacterAdded:Connect(function()
			Char = Player.Character or Player.CharacterAdded:Wait()
			LoadCustomization({Char = Char,Build = Build,Shoes = Shoes,Depth =Depth,Height = Height,Width = Width,SkinColor =SkinColor,Pants = Pants,Shirt = Shirt,Accessory = Accessory,Nose = Nose,Facial = Facial,Eyes = Eyes,Mouth = Mouth,RaceType = RaceType,BodyType = BodyType,Hair = Hair,ColorData = ColorData})
		end)
		LoadCustomization({Char = Char,Build = Build,Shoes = Shoes,Depth =Depth,Height = Height,Width = Width,SkinColor =SkinColor,Pants = Pants,Shirt = Shirt,Accessory = Accessory,Nose = Nose,Facial = Facial,Eyes = Eyes,Mouth = Mouth,RaceType = RaceType,BodyType = BodyType,Hair = Hair,ColorData = ColorData})
		
	
	end
end)

CustomizeEvent.OnServerEvent:Connect(function(Player,Params)
	
	local Category = Params.Category
	local Item = Params.Item
	local Action = Params.Action
	local Shop = Params.Shop
	
	local Data = Player:WaitForChild("Data")
	local CharacterData = Data:WaitForChild("CharacterData")
	
	local Body = CharacterData:WaitForChild("Body")
	local Clothes = CharacterData:WaitForChild("Clothes")
	local Head = CharacterData:WaitForChild("Head")
	local Misc = CharacterData:WaitForChild("Misc")

	
	if Action == "Left" or Action == "Right" then
		
	
		local FindItem =  Body:FindFirstChild(Item)  or Head:FindFirstChild(Item) or Misc:FindFirstChild(Item)
			if FindItem then
				local Int =CustomizeEvent
				if Action == "Left" then
					Int = -1
				elseif Action == "Right" then
					Int = 1
				end
			
			
				if FindItem:IsDescendantOf(Body) then
					FindItem.Value = math.clamp(FindItem.Value + Int,1,5)
				else
					local FindMeshFolder = CustomizationMeshes:FindFirstChild(Item,true)
					if FindMeshFolder then
						FindItem.Value = math.clamp(FindItem.Value + Int,1,#FindMeshFolder:GetChildren())
					end
				end
				
				
			end
		
	end
	
	if Item == "SkinColor" then
		local Int = tonumber(Action)
		if Int and Int <= 14 then
			local SkinColor = Body:WaitForChild("SkinColor")
			SkinColor.Value = Int
		end
	end

	local UnlockedClothing = CharacterData:WaitForChild("UnlockedClothing")
	local UnlockedIndex = game:GetService("HttpService"):JSONDecode(UnlockedClothing.Value)
	
	if Action == "SelectClothing" then
		local FindCategory = Clothes:FindFirstChild(Category)
		if FindCategory then
			
			local FindClothes = CustomizationMeshes:WaitForChild("Clothing"):WaitForChild(Category):FindFirstChild(tostring(Item),true)
			print(FindClothes)
			print(Item)
			print(Category)
			if FindClothes then
				
			
				local Unlocked = false
				local UnlockedCategory = UnlockedIndex[Category]
				for i,v in pairs(UnlockedCategory) do
					if v == Item then

						Unlocked = true
					end
				end
				
				local Gamepass = game:GetService("ReplicatedStorage"):WaitForChild("ClothingShopData"):WaitForChild("Gamepasses"):FindFirstChild(FindClothes.Parent.Name)
				if Gamepass then
					if game:GetService("MarketplaceService"):UserOwnsGamePassAsync(Player.UserId,Gamepass.Value) then
						Unlocked = true
					else
						Unlocked = false
					end

				end
				
				print(Unlocked)

				if Unlocked then
					FindCategory.Value = Item
				end
			end
		
			
			
		end
	end
	
	if Action == "Purchase" then
		local FindShop = game:GetService("ReplicatedStorage"):WaitForChild("ClothingShopData"):FindFirstChild(Shop)
		if FindShop then
			local FindShopCategory = FindShop:FindFirstChild(Category)
			if FindShopCategory then
				local FindItem = FindShopCategory:FindFirstChild(Item)
				if FindItem then
					print("Purchase for "..FindItem.Value)
					local Veli = Player:WaitForChild("Data"):WaitForChild("Currency"):WaitForChild("Money")
					if Veli.Value >= FindItem.Value then
						Veli.Value -= FindItem.Value
						_G.SetClothingData({Player = Player,Clothing = Item,Type = FindShopCategory.Name})
						_G.Notify(Player,"Successful Purchase","Positive",nil,"Sound1")
					else
						_G.Notify(Player,"Not enough Veli","Warning",nil,"Attention")
					end
				end
			end
		end
	end
	
end)

local UpdateColorEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UpdateColorEvent")
UpdateColorEvent.OnServerEvent:Connect(function(Player,Params)
	local Data = Player:WaitForChild("Data")
	local CharacterData = Data:WaitForChild("CharacterData")
	local ColorData = CharacterData:WaitForChild("Color")
	
	local NewColor = Color3.fromRGB(Params.R,Params.G,Params.B)

	local FindItemColor = ColorData:FindFirstChild(Params.Item)
	if FindItemColor then
		local FindType = FindItemColor:FindFirstChild(Params.Type)
		if FindType then
			FindType.Value = NewColor
		end
	end
	
end)

--RaceRoll
local LootPlan = require(game:GetService("ServerStorage"):WaitForChild("Modules"):WaitForChild("UtilityModules"):WaitForChild("LootPlan")) 

local RacePlan = LootPlan.new('single')
local RaceIndex = {

	["Human"] = 90;
	["Kamado"] = 1;
	["Uchiha"] = 1;
	["Vampire"] = 1;
	["Saiyan"] = 1;
	["Fishman"] = 1;
	["Hyuga"] = 1;
	["Mink"] = 1;
	["Ymir's Subject"] = 1;
	["Pyrokinetic"] = 1;
	["BleachThing"] = 1;


}

for i,v in pairs(RaceIndex)  do
	RacePlan:AddLoot(i,v)
	
end



local SpinDebounce = false

local RaceRoll = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RaceRoll")
local function OnRaceRollRequest(Player)
	
	if not SpinDebounce then
		SpinDebounce = true
		task.delay(4,function()
			SpinDebounce = false
		end)
		local RaceSpins = Player:WaitForChild("GamePasses/Products"):WaitForChild("RaceSpins")

		if RaceSpins.Value > 0 then
			RaceSpins.Value -= 1 

			local TotalResults = {}
			for i = 1,50 do
				local RandRace = RacePlan:GetRandomLoot()
				table.insert(TotalResults,RandRace)

			end

			RaceRoll:FireClient(Player,TotalResults)
			local RaceType = Player:WaitForChild("Data"):WaitForChild('CharacterData'):WaitForChild("Race"):WaitForChild("RaceType")
			local BodyType = Player:WaitForChild("Data"):WaitForChild('CharacterData'):WaitForChild("Race"):WaitForChild("BodyType")

			RaceType.Value = TotalResults[39]
	
			
		end

	end

end
RaceRoll.OnServerEvent:Connect(OnRaceRollRequest)



