--!strict

local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Constants"))
local PlaceIds = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("PlaceIds"))
local Net = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Net"))
local NotificationService = require(script.Parent.NotificationService)
local DataService = require(script.Parent.DataService)

local REALM_VER = Constants.REALM_DATA_VERSION
local RealmStore = DataStoreService:GetDataStore("RealmData" .. REALM_VER)

local generateDebounces: { [number]: boolean } = {}
local banDebounces: { [number]: boolean } = {}

local RealmService = {}

function RealmService:Init()
end

function RealmService:Start()
	-- Subscribe to player updates from reserved servers
	pcall(function()
		MessagingService:SubscribeAsync("PlayerUpdate", function(message)
			local ok, messageData = pcall(function()
				return HttpService:JSONDecode(message.Data)
			end)
			if not ok or not messageData then
				return
			end

			local realmData = ReplicatedStorage:WaitForChild("Assets"):FindFirstChild("RealmData")
			if not realmData then
				return
			end

			local reservedID = realmData:FindFirstChild("ReservedID")
			local activePlayers = realmData:FindFirstChild("Active Players")
			if reservedID and activePlayers and reservedID.Value == messageData.Reserved then
				activePlayers.Value = #messageData.Players
			end
		end)
	end)

	-- Poll for stale player counts
	task.spawn(function()
		local lastReceived = tick()
		while true do
			task.wait(20)
			if tick() - lastReceived > 20 then
				local realmData = ReplicatedStorage:WaitForChild("Assets"):FindFirstChild("RealmData")
				if realmData then
					local activePlayers = realmData:FindFirstChild("Active Players")
					if activePlayers then
						activePlayers.Value = 0
					end
				end
			end
		end
	end)

	Players.PlayerAdded:Connect(function(player)
		self:_onPlayerAdded(player)
	end)

	Net.listen("RealmRequest", function(player: Player, params: any)
		if type(params) ~= "table" or type(params.Action) ~= "string" then
			return
		end
		self:_onRealmRequest(player, params)
	end)
end

function RealmService:_onPlayerAdded(player: Player)
	local data = DataService.WaitForData(player)
	if not data then
		return
	end

	local realmCode = data.GamePasses.Products.Realm.RealmCode
	if realmCode == "" then
		return
	end

	local ok, id = pcall(function()
		return RealmStore:GetAsync("RealmIds/" .. realmCode .. "Ver" .. REALM_VER)
	end)

	if ok and id then
		local realmData = ReplicatedStorage:WaitForChild("Assets"):FindFirstChild("RealmData")
		if realmData then
			local reservedID = realmData:FindFirstChild("ReservedID")
			if reservedID then
				reservedID.Value = id
			end
		end

		pcall(function()
			self:_verifyBanList(player)
		end)
	end
end

function RealmService:_verifyBanList(player: Player)
	local ok, banList = pcall(function()
		return RealmStore:GetAsync("Ban/" .. player.UserId .. "Ver" .. REALM_VER)
	end)
	if not ok then
		return
	end
	if not banList then
		pcall(function()
			RealmStore:SetAsync("Ban/" .. player.UserId .. "Ver" .. REALM_VER, HttpService:JSONEncode({}))
		end)
	end
	self:_updateBannedPlayers(player)
end

function RealmService:_updateBannedPlayers(player: Player)
	local ok, banList = pcall(function()
		return RealmStore:GetAsync("Ban/" .. player.UserId .. "Ver" .. REALM_VER)
	end)
	if ok then
		local realmData = ReplicatedStorage:WaitForChild("Assets"):FindFirstChild("RealmData")
		if realmData then
			local bannedPlayers = realmData:FindFirstChild("BannedPlayers")
			if bannedPlayers then
				bannedPlayers.Value = banList or ""
			end
		end
	end
end

function RealmService:_generate(player: Player)
	local data = DataService.GetData(player)
	if not data then
		return
	end

	local reservedServer, reservedId
	local succ, err = pcall(function()
		reservedServer, reservedId = TeleportService:ReserveServer(PlaceIds.FirstSea)
	end)

	if not succ then
		warn("[RealmService] Error generating realm:", err)
		return
	end

	local randomCode = string.split(HttpService:GenerateGUID(false), "-")[1]
	data.GamePasses.Products.Realm.RealmCode = randomCode

	local ok1, e1 = pcall(function()
		RealmStore:SetAsync("RealmOwners/" .. player.UserId .. "Ver" .. REALM_VER, randomCode)
	end)
	local ok2, e2 = pcall(function()
		RealmStore:SetAsync("RealmCodes/" .. randomCode .. "Ver" .. REALM_VER, reservedServer)
	end)
	local ok3, e3 = pcall(function()
		RealmStore:SetAsync("UserIds/" .. randomCode .. "Ver" .. REALM_VER, player.UserId)
	end)
	local ok4, e4 = pcall(function()
		RealmStore:SetAsync("RealmIds/" .. randomCode .. "Ver" .. REALM_VER, reservedId)
	end)
	local ok5, e5 = pcall(function()
		RealmStore:SetAsync(
			"RealmExpirations/" .. randomCode .. "Ver" .. REALM_VER,
			data.GamePasses.Products.Realm.DatePurchased + Constants.REALM_DURATION
		)
	end)

	local realmData = ReplicatedStorage:WaitForChild("Assets"):FindFirstChild("RealmData")
	if realmData then
		local reservedIDValue = realmData:FindFirstChild("ReservedID")
		if reservedIDValue then
			reservedIDValue.Value = reservedId
		end
	end
end

function RealmService:_eliminate(userId: number)
	local ok, realmCode = pcall(function()
		return RealmStore:GetAsync("RealmOwners/" .. userId .. "Ver" .. REALM_VER)
	end)
	if not ok or not realmCode then
		return
	end

	local ok2, realmPlace = pcall(function()
		return RealmStore:GetAsync("RealmCodes/" .. realmCode .. "Ver" .. REALM_VER)
	end)
	local ok3, realmId = pcall(function()
		return RealmStore:GetAsync("RealmIds/" .. realmCode .. "Ver" .. REALM_VER)
	end)
	local ok4, realmExpiration = pcall(function()
		return RealmStore:GetAsync("RealmExpirations/" .. realmCode .. "Ver" .. REALM_VER)
	end)

	if realmPlace and realmId and realmExpiration then
		pcall(function()
			RealmStore:RemoveAsync("RealmOwners/" .. userId .. "Ver" .. REALM_VER)
		end)
		pcall(function()
			RealmStore:RemoveAsync("RealmCodes/" .. realmCode .. "Ver" .. REALM_VER)
		end)
		pcall(function()
			RealmStore:RemoveAsync("RealmIds/" .. realmCode .. "Ver" .. REALM_VER)
		end)
		pcall(function()
			RealmStore:RemoveAsync("RealmExpirations/" .. realmCode .. "Ver" .. REALM_VER)
		end)
		pcall(function()
			RealmStore:RemoveAsync("UserIds/" .. realmCode .. "Ver" .. REALM_VER)
		end)

		pcall(function()
			local message = { Function = "RealmShutdown", Params = { Reserved = realmId } }
			MessagingService:PublishAsync("GlobalFunction", HttpService:JSONEncode(message))
		end)
	end
end

function RealmService:_onRealmRequest(player: Player, params: any)
	local action = params.Action
	local data = DataService.GetData(player)
	if not data then
		return
	end

	local realmData = data.GamePasses.Products.Realm
	local passedTime = tick() - realmData.DatePurchased
	local playerOwnsRealm = passedTime <= Constants.REALM_DURATION and realmData.DatePurchased > 0
	local userId = player.UserId

	if action == "Generate" and playerOwnsRealm then
		if generateDebounces[userId] then
			NotificationService.Send(player, "Code Processing", "Negative")
			return
		end
		generateDebounces[userId] = true
		NotificationService.Send(player, "Generating Code", "Positive")
		self:_eliminate(userId)
		self:_generate(player)
		generateDebounces[userId] = nil
	elseif action == "Ban" and playerOwnsRealm then
		if banDebounces[userId] then
			NotificationService.Send(player, "Busy", "Negative")
			return
		end

		local user = params.User
		if type(user) ~= "string" then
			return
		end

		local findPlayer: number?
		local succ, _ = pcall(function()
			findPlayer = Players:GetUserIdFromNameAsync(user)
		end)

		if not succ or not findPlayer then
			NotificationService.Send(player, "Player Does Not Exist", "Negative")
			return
		end

		if findPlayer == userId then
			NotificationService.Send(player, "You can't ban yourself", "Negative")
			return
		end

		banDebounces[userId] = true

		local ok, rawBanList = pcall(function()
			return RealmStore:GetAsync("Ban/" .. userId .. "Ver" .. REALM_VER)
		end)
		if not ok or not rawBanList then
			banDebounces[userId] = nil
			return
		end

		local banOk, banList = pcall(function()
			return HttpService:JSONDecode(rawBanList)
		end)
		if not banOk then
			banDebounces[userId] = nil
			return
		end

		local found = false
		for _, v in pairs(banList) do
			if v == findPlayer then
				found = true
				break
			end
		end

		if found then
			NotificationService.Send(player, "Player is already banned", "Negative")
			banDebounces[userId] = nil
			return
		end

		NotificationService.Send(player, "Banning", "Negative")
		table.insert(banList, findPlayer)

		pcall(function()
			RealmStore:SetAsync("Ban/" .. userId .. "Ver" .. REALM_VER, HttpService:JSONEncode(banList))
		end)
		self:_updateBannedPlayers(player)
		banDebounces[userId] = nil
		NotificationService.Send(player, "Player has been banned", "Negative")
	elseif action == "Revoke" and playerOwnsRealm then
		if banDebounces[userId] then
			NotificationService.Send(player, "Busy", "Negative")
			return
		end

		local user = params.User
		if type(user) ~= "string" then
			return
		end

		local findPlayer: number?
		pcall(function()
			findPlayer = Players:GetUserIdFromNameAsync(user)
		end)

		if not findPlayer then
			return
		end

		banDebounces[userId] = true

		local ok, rawBanList = pcall(function()
			return RealmStore:GetAsync("Ban/" .. userId .. "Ver" .. REALM_VER)
		end)
		if not ok or not rawBanList then
			banDebounces[userId] = nil
			return
		end

		local banOk, banList = pcall(function()
			return HttpService:JSONDecode(rawBanList)
		end)
		if not banOk then
			banDebounces[userId] = nil
			return
		end

		local removed = false
		for i, v in pairs(banList) do
			if v == findPlayer then
				removed = true
				table.remove(banList, i)
				break
			end
		end

		if removed then
			NotificationService.Send(player, "Revoking", "Negative")
			pcall(function()
				RealmStore:SetAsync("Ban/" .. userId .. "Ver" .. REALM_VER, HttpService:JSONEncode(banList))
			end)
			self:_updateBannedPlayers(player)
			NotificationService.Send(player, "Ban has been revoked", "Positive")
		end
		banDebounces[userId] = nil
	elseif action == "Join" then
		local code = params.Code
		if type(code) ~= "string" or #code == 0 then
			return
		end

		local ok1, realmPlace = pcall(function()
			return RealmStore:GetAsync("RealmCodes/" .. code .. "Ver" .. REALM_VER)
		end)
		local ok2, realmExpiration = pcall(function()
			return RealmStore:GetAsync("RealmExpirations/" .. code .. "Ver" .. REALM_VER)
		end)
		local ok3, ownerUserId = pcall(function()
			return RealmStore:GetAsync("UserIds/" .. code .. "Ver" .. REALM_VER)
		end)

		if not realmPlace or not realmExpiration then
			NotificationService.Send(player, "Server Does Not Exist", "Negative")
			return
		end

		-- Check ban list
		if ownerUserId then
			local banOk, rawBanList = pcall(function()
				return RealmStore:GetAsync("Ban/" .. ownerUserId .. "Ver" .. REALM_VER)
			end)
			if banOk and rawBanList then
				local decOk, banList = pcall(function()
					return HttpService:JSONDecode(rawBanList)
				end)
				if decOk and banList then
					for _, v in pairs(banList) do
						if v == userId then
							NotificationService.Send(player, "You are banned from this realm", "Negative")
							return
						end
					end
				end
			end
		end

		local timeRemaining = realmExpiration - tick()
		if timeRemaining <= 0 then
			self:_eliminate(ownerUserId)
			NotificationService.Send(player, "Server Has Expired", "Negative")
		else
			NotificationService.Send(player, "Teleporting", "Positive")
			pcall(function()
				TeleportService:TeleportToPrivateServer(PlaceIds.FirstSea, realmPlace, Players:GetPlayers())
			end)
		end
	end
end

return RealmService
