local FilterRequest =game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("FilterRequest")
local TextService =game:GetService("TextService")

local function OnFilterRequest(Player,Text)
	local function getTextObject(message, fromPlayerId)
		local textObject
		local success, errorMessage = pcall(function()
			textObject = TextService:FilterStringAsync(message, fromPlayerId)
		end)
		if success then
			return textObject
		elseif errorMessage then
			print("Error generating TextFilterResult:", errorMessage)
		end
		return false
	end

	local function getFilteredMessage(textObject)
		local filteredMessage
		local success, errorMessage = pcall(function()
			filteredMessage = textObject:GetNonChatStringForBroadcastAsync()
		end)
		if success then
			return filteredMessage
		elseif errorMessage then
			print("Error filtering message:", errorMessage)
		end
		return false
	end

	-- Fired when client sends a request to write on the sign
	local function onSetSignText(player, text)
		if text ~= "" then
			-- Filter the incoming message and send the filtered message
			local messageObject = getTextObject(text, player.UserId)
			local filteredText = ""
			filteredText = getFilteredMessage(messageObject)
			print(filteredText)
			return filteredText
		end
	end

	local MEssage = onSetSignText(Player,Text)
	print(MEssage)
	
	return MEssage
end


FilterRequest.OnServerInvoke = OnFilterRequest