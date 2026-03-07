local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()

local module = {
	Engage = function()
		local CharClone = Char:Clone()
		CharClone.Parent = workspace
		local CharClonehum = CharClone:WaitForChild("Humanoid")

		Lighting:SetAttribute("WindDirection", Vector3.new(20, 0, 0))
		Lighting:SetAttribute("WindStrength", 1)
		Lighting:SetAttribute("WindSpeed", 1)

		local Scene = script.Scene
		Scene.Parent = workspace
		Scene = workspace:WaitForChild("Scene")

		local SceneDummy = Scene:WaitForChild("SceneDummy")

		local oldAtmo = Lighting:FindFirstChildOfClass("Atmosphere")
		if oldAtmo then
			oldAtmo:Destroy()
		end
		local NewAtmosphere = script.Atmosphere:Clone()
		NewAtmosphere.Parent = Lighting
		Lighting.TimeOfDay = "14:48:00"

		CharClone.PrimaryPart.Anchored = true
		CharClone:PivotTo(SceneDummy.PrimaryPart.CFrame)
		SceneDummy:Destroy()
		CharClonehum:LoadAnimation(script.SceneAnimation):Play()

		-- Cinematic camera
		local camera = workspace.CurrentCamera
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = CharClone.PrimaryPart.CFrame * CFrame.new(0, 2, 8)

		local Ambience = script.Ambience:Clone()
		Ambience.Parent = workspace
		Ambience:Play()

		local Music = script.Music
		Music.Parent = workspace
		Music:Play()
	end,
}

return module
