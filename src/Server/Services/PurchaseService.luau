--!strict

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local DataService = require(script.Parent.DataService)

type ProductHandler = {
	ProductId: number,
	Engage: (player: Player, data: any) -> boolean,
}

local ProductHandlers: { [number]: ProductHandler } = {}

local PurchaseService = {}

function PurchaseService:Init()
	-- Register product handlers
	-- Realm purchase (product ID stored in the original as a child BoolValue name)
	-- For now, we register known product handlers directly
end

function PurchaseService:Start()
	MarketplaceService.ProcessReceipt = function(receiptInfo)
		return self:_processReceipt(receiptInfo)
	end
end

function PurchaseService:RegisterProduct(productId: number, handler: (player: Player, data: any) -> boolean)
	ProductHandlers[productId] = {
		ProductId = productId,
		Engage = handler,
	}
end

function PurchaseService:_processReceipt(receiptInfo: any): Enum.ProductPurchaseDecision
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local handler = ProductHandlers[receiptInfo.ProductId]
	if not handler then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local data = DataService.GetData(player)
	if not data then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local success = false
	local ok, err = pcall(function()
		success = handler.Engage(player, data)
	end)

	if not ok then
		warn("[PurchaseService] Error processing receipt:", err)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if success then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end

return PurchaseService
