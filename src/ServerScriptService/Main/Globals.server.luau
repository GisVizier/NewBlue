local NotificationModule = require(game:GetService("ServerStorage"):WaitForChild("Modules"):WaitForChild("UtilityModules"):WaitForChild("NotificationModule"))
_G.Notify = function(Player,Message,NotifyType,Duration,Sound)

	if not Duration then
		Duration = 5
	end

	local NotifyEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Gui"):WaitForChild("Notify")
	NotifyEvent:FireClient(Player,NotifyType,Message,Duration,Sound)

end

local NativeClothingTypes = {
	[1] = "Shirt";
	[2] = "Pants";
	[3] = "Shoes";
	[4] = "Accessory";

}



_G.SetClothingData = function(Params)
	local Player = Params.Player
	local Type = Params.Type
	local Clothing = Params.Clothing
	
	local UnlockedClothing = Player:WaitForChild("Data"):WaitForChild("CharacterData"):WaitForChild("UnlockedClothing")
	local UnlockedIndex = game:GetService("HttpService"):JSONDecode(UnlockedClothing.Value)
	
	for i,v in pairs(NativeClothingTypes)do
		if not UnlockedIndex[v] then
			UnlockedIndex[v] = {}
		end
	end
	
	if UnlockedIndex[Type] then
		if not UnlockedIndex[Type][Clothing] then
			UnlockedIndex[Type][Clothing] = Clothing
		end
	end
	
	
	if Type =="Shoes" then
		print(UnlockedIndex[Type])
	end
	print(UnlockedIndex)
	UnlockedIndex = game:GetService("HttpService"):JSONEncode(UnlockedIndex)
	UnlockedClothing.Value = UnlockedIndex
end

print(_G.Notify)

print("Balls")