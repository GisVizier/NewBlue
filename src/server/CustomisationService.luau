--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)

local customizationBridge = BridgeNet2.ServerBridge("customise")

local CustomizationService = {}

local function setState(player: Player, isCustomizing: boolean)
	if isCustomizing then
		player:SetAttribute("IsCustomising", true)

		local char = player.Character
		if char then
			char:Destroy()
			player.Character = nil
		end
	else
		player:LoadCharacterAsync()
		player:SetAttribute("IsCustomising", false)
	end
end

function CustomizationService.__init()
	customizationBridge:Connect(function(player: Player, isCustomizing: unknown)
		if type(isCustomizing) == "boolean" then
			setState(player, isCustomizing)
		end
	end)
end

CustomizationService.setState = setState

return CustomizationService
