--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ProfileStore = require(script.Parent.ProfileStore)
local ProfileTemplate = require(ReplicatedStorage.Shared.Registry.ProfileTemplate)
local Replion = require(ReplicatedStorage.Packages.Replion)
local Util = require(ReplicatedStorage.Shared.Utility.Util)

local STORE_NAME = "profiles"
local DEBUG = true

local liveProfileStore = ProfileStore.New(STORE_NAME, ProfileTemplate)
local profileStore = RunService:IsStudio() and liveProfileStore.Mock or liveProfileStore
local cache: { [Player]: { profile: typeof(profileStore:StartSessionAsync(...)), replion: Replion.ServerReplion } } = {}

local Profiles = {}

function Profiles.add(player: Player)
	local startTime = os.clock()
	local profile = profileStore:StartSessionAsync(`{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	if profile then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile.OnSessionEnd:Connect(function()
			if cache[player] then
				cache[player].replion:Destroy()
				cache[player] = nil
			end
			player:Kick("Profile session end - Please rejoin")
		end)

		if player.Parent == Players then
			local replion = Replion.Server.new({
				Channel = "Profile",
				ReplicateTo = player,
				Data = profile.Data,
			})

			cache[player] = {
				profile = profile,
				replion = replion,
			}

			replion:OnDataChange(function(newData)
				profile.Data = newData
				profile:Save()
			end)

			player:SetAttribute("ProfileLoaded", true)

			if DEBUG then
				local elapsedTime = os.clock() - startTime
				Util.log(script.Name, string.format("@%s Profile loaded successfully! %.2fs", player.Name, elapsedTime))
			end
		else
			profile:EndSession()
		end
	else
		player:Kick("Profile failed to load - Please rejoin")
	end
end

function Profiles.remove(player: Player)
	local entry = cache[player]
	if entry and entry.profile then
		entry.profile:EndSession()
	end
end

return Profiles
