--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Registry.Config)

local player = Players.LocalPlayer

local function init()
	local module: ModuleScript? = ReplicatedStorage:WaitForChild("CmdrClient", 60)
	if not module then
		return
	end

	-- if player:IsInGroupAsync(Config.GROUP_ID) then
	local CmdrClient = require(module)
	CmdrClient:SetActivationKeys({ Enum.KeyCode.F2 })
	-- else
	-- 	module:Destroy()
	-- end
end

return { __init = init }
