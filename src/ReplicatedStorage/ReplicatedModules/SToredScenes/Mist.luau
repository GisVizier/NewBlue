local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()

local module = {
	Engage = function()
		local CharClone = Char:Clone()
		CharClone.Parent = workspace
		local CharClonehum = CharClone:WaitForChild("Humanoid")

		local Scene = script.Mist
		Scene.Parent = workspace
		Scene = workspace:WaitForChild("Mist")
		local SceneDummy = Scene:WaitForChild("SceneDummy")

		local LeftHand = CharClone:WaitForChild("LeftHand")
		local Kunai = script["BezierCircle.009"]:Clone()
		local KunaiMotor = Instance.new("Motor6D")
		KunaiMotor.Parent = LeftHand
		KunaiMotor.Part0 = LeftHand
		KunaiMotor.Part1 = Kunai
		KunaiMotor.Name = Kunai.Name
		Kunai.Parent = CharClone

		CharClone.PrimaryPart.Anchored = true
		CharClone:PivotTo(SceneDummy.PrimaryPart.CFrame)
		SceneDummy:Destroy()
		CharClonehum:LoadAnimation(script.SceneAnimation):Play()

		local camera = workspace.CurrentCamera
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = CharClone.PrimaryPart.CFrame * CFrame.new(0, 2, 8)

		local Ambience = script.Ambience:Clone()
		Ambience.Parent = workspace
		Ambience:Play()

		local RainUtil = require(ReplicatedStorage:WaitForChild("Assets"):WaitForChild("ReplicatedModules"):WaitForChild("Utilities"):WaitForChild("RainUtil"))
		RainUtil:Enable()
		Lighting.TimeOfDay = "21:54:00"
	end,
}

return module
