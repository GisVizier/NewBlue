local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()

local module = {
	Engage = function()
		local CharClone = Char:Clone()
		CharClone.Parent = workspace
		local CharClonehum = CharClone:WaitForChild("Humanoid")

		local Scene = script.Scene
		Scene.Parent = workspace
		Scene = workspace:WaitForChild("Scene")
		local SceneDummy = Scene:WaitForChild("SceneDummy")

		local Music = script.Music:Clone()
		Music.Parent = workspace
		Music.Volume = 0
		Music:Play()
		TweenService:Create(Music, TweenInfo.new(1, Enum.EasingStyle.Sine), { Volume = 10 }):Play()

		local oldAtmo = Lighting:FindFirstChildOfClass("Atmosphere")
		if oldAtmo then
			oldAtmo:Destroy()
		end
		local NewAtmosphere = script.Atmosphere:Clone()
		NewAtmosphere.Parent = Lighting
		local Clouds = script.Clouds:Clone()
		Clouds.Parent = workspace.Terrain
		Lighting.TimeOfDay = "04:24:00"
		Lighting.Sky.MoonAngularSize = 60

		CharClone.PrimaryPart.Anchored = true
		CharClone:PivotTo(SceneDummy.PrimaryPart.CFrame)
		SceneDummy:Destroy()
		local Anim = CharClonehum:LoadAnimation(script.SceneAnimation)
		Anim:Play()
		Anim:AdjustSpeed(0.3)

		local camera = workspace.CurrentCamera
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = CharClone.PrimaryPart.CFrame * CFrame.new(0, 2, 8)

		local Ambience = script.Ambience:Clone()
		Ambience.Parent = workspace
		Ambience:Play()

		local RainUtil = require(ReplicatedStorage:WaitForChild("Assets"):WaitForChild("ReplicatedModules"):WaitForChild("Utilities"):WaitForChild("RainUtil"))
		RainUtil:Enable()
	end,
}

return module
