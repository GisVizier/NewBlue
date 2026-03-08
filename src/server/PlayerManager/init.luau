--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)
local Profiles = require(script.Profiles)
local Util = require(ReplicatedStorage.Shared.Utility.Util)

local CAMERA_MAX_ZOOM = 20
local CAMERA_MIN_ZOOM = 10

local bootBridge = BridgeNet2.ServerBridge("boot")

local function loadPlayer(player: Player)
	if not player:GetAttribute("Loaded") then
		player:LoadCharacterAsync()
		player:SetAttribute("Loaded", true)
	end
	return true
end

local function configPlayerSettings(player: Player)
	player.CameraMaxZoomDistance = CAMERA_MAX_ZOOM
	player.CameraMinZoomDistance = CAMERA_MIN_ZOOM
	player.CameraMode = Enum.CameraMode.Classic
	player.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
	player.DevComputerCameraMode = Enum.DevComputerCameraMovementMode.Classic
	player.DevEnableMouseLock = false
	player.DevTouchCameraMode = Enum.DevTouchCameraMovementMode.Classic
	player.DevComputerMovementMode = Enum.DevComputerMovementMode.KeyboardMouse
	player.DevTouchMovementMode = Enum.DevTouchMovementMode.UserChoice
end

local function onPlayerAdded(player: Player)
	Profiles.add(player)
	configPlayerSettings(player)

	local function onCharacterAdded(char: Model)
		local hum = Util.waitForHum(char)
		if not hum then
			return
		end

		local function onDied()
			task.delay(Players.RespawnTime, function()
				if player.Parent == Players and not player:GetAttribute("IsCustomising") then
					player:LoadCharacterAsync()
				end
			end)
		end

		hum.Died:Once(onDied)
	end

	player.CharacterAdded:Connect(onCharacterAdded)

	if player.Character then
		onCharacterAdded(player.Character)
	end
end

local function onPlayerRemoving(player: Player)
	Profiles.remove(player)
end

local function init()
	bootBridge.OnServerInvoke = loadPlayer

	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	for _, player in Players:GetPlayers() do
		task.defer(onPlayerAdded, player)
	end
end

return { __init = init }
