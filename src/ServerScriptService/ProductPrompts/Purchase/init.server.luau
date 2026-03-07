local PurchaseEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Purchase")
local MS =game:GetService("MarketplaceService")

local PromptIndex = {}
for i,v in pairs(script:GetChildren())do
	if v:IsA("ModuleScript") then
		PromptIndex[tonumber(v:FindFirstChildOfClass("BoolValue").Name)] = require(v)
	end
end

local function ProcessRecept(receiptInfo)
	print(receiptInfo)
	local Player = game.Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if PromptIndex[receiptInfo.ProductId] then
		if not Player then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		else
			local Sucess = PromptIndex[receiptInfo.ProductId].Engage(Player)
			if Sucess then
				return Enum.ProductPurchaseDecision.PurchaseGranted
			else
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end
		end
	end
	
end

MS.ProcessReceipt = ProcessRecept

PurchaseEvent.OnServerEvent:Connect(function(Player,Prompt)

end)

