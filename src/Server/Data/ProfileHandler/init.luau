local PlayerService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataConfig = require(script.Parent.DataConfig)
local DataGlobal = require(script.Parent.DataGlobal)
local ReplicaServer = require(ReplicatedStorage:WaitForChild("Assets"):WaitForChild("ReplicaServer"))
local storeVersion = DataConfig.DataStore.StoreVersion

local Default = require(script.Parent.Default)
local OnFirstJoin = require(script.Parent.OnFirstJoin)
local PeekableData = require(script.Parent.Peekable)
local Revisions = require(script.Parent.Revisions)
local ProfileStore = require(script:FindFirstChild("ProfileStore"))

local module = {}

local activeReplicas: { [number]: any } = {}
local activePeekables: { [number]: any } = {}
local activeProfiles = {}

local function syncPeekable(userId: number, path: { string }, value: any)
	local Peekable = activePeekables[userId]
	if not Peekable then
		return
	end
	local pathStr = table.concat(path, ".")
	for peekPath, _ in PeekableData do
		if pathStr == peekPath or pathStr:match("^" .. peekPath:gsub("%.", "%%.") .. "%.") then
			Peekable:Set(path, value)
			break
		end
	end
end

local Token = ReplicaServer.Token("PlayerData")
local PeekToken = ReplicaServer.Token("PeekableData")
local GameProfileStore = ProfileStore.New("PlayerData" .. tostring(storeVersion), Default)

if DataConfig.DataStore.Disabled then
	GameProfileStore = GameProfileStore.Mock
end

local Redacted, Revised = Revisions.IsRedacted, Revisions.GetNewName
local ss = string.split

function module.playerRemoval(player: Player)
	local playerData = activeReplicas[player.UserId]

	if playerData ~= nil then
		playerData:Destroy()
	end
end

local function updateKeys(Data, path: string)
	for key, value in Data do
		local pathKey = if path == "" then key else path .. "." .. key
		local redacted = Redacted(key, pathKey)

		if redacted then
			Data[key] = nil
		else
			local newKey = Revised(key, pathKey)
			if newKey ~= key then
				Data[newKey] = value
				Data[key] = nil
			end
			if type(value) == "table" then
				updateKeys(value, pathKey)
			end
		end
	end
end

function module:CompleteData<T>(Data: T): T
	updateKeys(Data, "")
	return DataGlobal.FillTable(Data, Default)
end

local function GetPeekableData(Data: typeof(Default)): {}
	local Peekable = {}

	for path, _ in PeekableData do
		path = ss(path, ".")

		if #path > 1 then
			local referenceData = Data
			local peekReference = Peekable
			local lastIndex = #path

			for i, key in path do
				referenceData = referenceData[key]

				if i ~= lastIndex then
					peekReference[key] = peekReference[key] or {}
					peekReference = peekReference[key]
				else
					peekReference[key] = referenceData
				end
			end
		else
			local key = path[1]
			local referenceData = Data[key]

			if referenceData ~= nil then
				Peekable[key] = referenceData
			end
		end
	end

	return Peekable
end

function module.LoadPlayerData(player: Player): any | false
	local userId = player.UserId

	if activeReplicas[userId] then
		activeReplicas[userId]:Destroy()
		warn("Old data session found, Ending Profile Session for: " .. player.Name)
		task.wait()
	end

	local playerProfile = GameProfileStore:StartSessionAsync("Player_" .. userId)

	if playerProfile then
		playerProfile:AddUserId(userId)

		if not player:IsDescendantOf(PlayerService) then
			playerProfile:EndSession()
		else
			local ProfileData = playerProfile.Data

			if not ProfileData.FirstJoin then
				OnFirstJoin(ProfileData)
			end

			local Data = ReplicaServer.New({
				Token = Token,
				Data = module:CompleteData(ProfileData),
				Tags = { UserId = userId },
			})

			local Peekable = ReplicaServer.New({
				Token = PeekToken,
				Data = GetPeekableData(Data.Data),
				Tags = { UserId = userId },
			})

			activeProfiles[userId] = playerProfile
			activeReplicas[userId] = Data
			activePeekables[userId] = Peekable

			playerProfile.OnAfterSave:Connect(function() end)

			Peekable:Replicate()

			local function subscribeWhenReady()
				if not player:IsDescendantOf(PlayerService) then
					return
				end
				if ReplicaServer.ReadyPlayers[player] then
					Data:Subscribe(player)
				else
					local conn
					conn = ReplicaServer.NewReadyPlayer:Connect(function(readyPlayer)
						if readyPlayer == player then
							conn:Disconnect()
							if activeReplicas[userId] == Data then
								Data:Subscribe(player)
							end
						end
					end)
					Data.Maid:Add(function()
						if conn then
							pcall(conn.Disconnect, conn)
						end
					end)
				end
			end
			subscribeWhenReady()

			Data.Maid:Add(function()
				playerProfile:EndSession()
				Peekable:Destroy()

				activeProfiles[userId] = nil
				activeReplicas[userId] = nil
				activePeekables[userId] = nil
			end)

			player:SetAttribute("Data_Loaded", true)

			return Data
		end
	else
		warn("[Data] Failed to load for", player.Name, "- kicking")
		player:Kick("Data failed to load, Rejoin!")
	end

	return false
end

function module.GetReplica(player: Player | number): any?
	if typeof(player) == "number" then
		return activeReplicas[player]
	else
		return activeReplicas[player.UserId]
	end
end

function module.GetProfile(player: Player | number): any?
	if typeof(player) == "number" then
		return activeProfiles[player]
	else
		return activeProfiles[player.UserId]
	end
end

function module.SetData(player: Player | number, path: { string }, value: any)
	local userId = typeof(player) == "number" and player or player.UserId
	local replica = activeReplicas[userId]
	if not replica then
		warn("[Data] SetData - no replica for", tostring(userId))
		return
	end
	replica:Set(path, value)
	syncPeekable(userId, path, value)
end

PlayerService.PlayerAdded:Connect(function(player)
	task.defer(function()
		module.LoadPlayerData(player)
	end)
end)

PlayerService.PlayerRemoving:Connect(function(plr)
	task.wait()
	module.playerRemoval(plr)
end)

-- Load data for players already in game (e.g. when script hot-reloads)
for _, player in PlayerService:GetPlayers() do
	task.defer(function()
		module.LoadPlayerData(player)
	end)
end

return module
