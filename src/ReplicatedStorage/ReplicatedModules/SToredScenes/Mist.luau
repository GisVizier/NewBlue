local Player = game.Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()


local module = {


	Engage =function()
		
		local CharClone = Char:Clone()
		CharClone.Parent = game.Workspace
		local CharClonehum = CharClone:WaitForChild("Humanoid")
		
		local Scene = script.Mist
		Scene.Parent = game.Workspace
		Scene = game.Workspace:WaitForChild("Mist")
		local CustomizePoint = Scene:WaitForChild("CustomizePoint")
		local SceneDummy = Scene:WaitForChild("SceneDummy")
		
	
		
		local LeftHand = CharClone:WaitForChild("LeftHand")
		local Kunai = script["BezierCircle.009"]:Clone()
		local KunaiMotor = Instance.new('Motor6D')
		KunaiMotor.Parent = LeftHand
		KunaiMotor.Part0 = LeftHand
		KunaiMotor.Part1 = Kunai
		KunaiMotor.Name = Kunai.Name
		Kunai.Parent = CharClone
		
		
		CharClone.PrimaryPart.Anchored = true
		CharClone:SetPrimaryPartCFrame(SceneDummy.PrimaryPart.CFrame)
		SceneDummy:Destroy()
		CharClonehum:LoadAnimation(script.SceneAnimation):Play()
		_G.Cinematic({Parent = CharClone.PrimaryPart})
		local Ambience = script.Ambience:Clone()
		Ambience.Parent = game.Workspace
		Ambience:Play()
		local RainUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("ReplicatedModules"):WaitForChild("Utilities"):WaitForChild("RainUtil"))
		RainUtil:Enable()
		game.Lighting.TimeOfDay = "21:54:00"
		
	end,



}

return module
