--!strict

--[[
    DataService — thin wrapper around ProfileHandler.
    Preserves the API surface used by CustomizationService, PurchaseService, RealmService.
    ProfileHandler handles PlayerAdded/Removing and auto-loads data.
]]

local Players = game:GetService("Players")

local ProfileHandler = require(script.Parent.Parent.Data.ProfileHandler)

local DataService = {}

function DataService:Init()
end

function DataService:Start()
end

function DataService.GetData(player: Player): any?
	local replica = ProfileHandler.GetReplica(player)
	if replica then
		return replica.Data
	end
	return nil
end

function DataService.GetProfile(player: Player): any?
	return ProfileHandler.GetProfile(player)
end

function DataService.SetData(player: Player, path: string, value: any)
	local keys = string.split(path, ".")
	ProfileHandler.SetData(player, keys, value)
end

function DataService.WaitForData(player: Player): any?
	if not player:GetAttribute("Data_Loaded") then
		local start = os.clock()
		while not player:GetAttribute("Data_Loaded") do
			task.wait(0.1)
			if os.clock() - start > 30 or not player:IsDescendantOf(Players) then
				return nil
			end
		end
	end
	return DataService.GetData(player)
end

return DataService
