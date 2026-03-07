--!strict

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local ProfileService = require(ServerStorage:WaitForChild("Modules"):WaitForChild("Data"):WaitForChild("ProfileService"))
local DataTemplate = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("DataTemplate"))
local DataMigrations = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("DataMigrations"))
local Constants = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Constants"))

local ProfileStore = ProfileService.GetProfileStore(Constants.DATA_STORE_VERSION, DataTemplate)

local Profiles: { [Player]: any } = {}

local DataService = {}

function DataService:Init()
end

function DataService:Start()
	Players.PlayerAdded:Connect(function(player)
		self:_loadProfile(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:_releaseProfile(player)
	end)

	for _, player in Players:GetPlayers() do
		task.spawn(function()
			self:_loadProfile(player)
		end)
	end

	task.spawn(function()
		while true do
			task.wait(Constants.AUTO_SAVE_PERIOD)
			for _, player in Players:GetPlayers() do
				local profile = Profiles[player]
				if profile then
					profile:Save()
				end
			end
		end
	end)
end

function DataService:_loadProfile(player: Player)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)
	if not profile then
		player:Kick("Failed to load data. Please rejoin.")
		return
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()

	DataMigrations.Run(profile.Data)

	profile:ListenToRelease(function()
		Profiles[player] = nil
		player:Kick("Data session released. Please rejoin.")
	end)

	if not player:IsDescendantOf(Players) then
		profile:Release()
		return
	end

	Profiles[player] = profile

	local readyFlag = Instance.new("BoolValue")
	readyFlag.Name = "DataReady"
	readyFlag.Parent = player
end

function DataService:_releaseProfile(player: Player)
	local profile = Profiles[player]
	if profile then
		profile:Release()
		Profiles[player] = nil
	end
end

function DataService.GetData(player: Player): any?
	local profile = Profiles[player]
	if profile then
		return profile.Data
	end
	return nil
end

function DataService.GetProfile(player: Player): any?
	return Profiles[player]
end

function DataService.SetData(player: Player, path: string, value: any)
	local profile = Profiles[player]
	if not profile then
		return
	end

	local keys = string.split(path, ".")
	local current = profile.Data
	for i = 1, #keys - 1 do
		current = current[keys[i]]
		if not current then
			return
		end
	end

	current[keys[#keys]] = value
end

function DataService.WaitForData(player: Player): any?
	player:WaitForChild("DataReady", 30)
	return DataService.GetData(player)
end

return DataService
