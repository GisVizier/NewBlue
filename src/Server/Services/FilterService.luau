--!strict

local TextService = game:GetService("TextService")

local Net = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Net"))

local FilterService = {}

function FilterService:Init()
end

function FilterService:Start()
	Net.listen("FilterRequest", function(player: Player, text: any)
		if type(text) ~= "string" then
			return ""
		end
		if #text == 0 or #text > 200 then
			return ""
		end
		return self:_filterText(player, text)
	end)
end

function FilterService:_filterText(player: Player, text: string): string
	local textObject
	local success, err = pcall(function()
		textObject = TextService:FilterStringAsync(text, player.UserId)
	end)
	if not success or not textObject then
		warn("[FilterService] Filter error:", err)
		return ""
	end

	local filteredMessage
	local filterSuccess, filterErr = pcall(function()
		filteredMessage = textObject:GetNonChatStringForBroadcastAsync()
	end)
	if not filterSuccess or not filteredMessage then
		warn("[FilterService] Broadcast filter error:", filterErr)
		return ""
	end

	return filteredMessage
end

return FilterService
