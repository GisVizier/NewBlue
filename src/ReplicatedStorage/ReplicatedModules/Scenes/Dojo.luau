local Player = game.Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()


local module = {


	Engage =function()
		
		local CharClone = Char:Clone()
		CharClone.Parent = game.Workspace
		local CharClonehum = CharClone:WaitForChild("Humanoid")
		
		
		game.Lighting:SetAttribute("WindDirection",Vector3.new(20,0,0))
		game.Lighting:SetAttribute("WindStrength",1)
		game.Lighting:SetAttribute("WindSpeed",1)

		
		local Scene = script.Scene
		Scene.Parent = game.Workspace
		Scene = game.Workspace:WaitForChild("Scene")
		

	
		
		local SceneDummy = Scene:WaitForChild("SceneDummy")
		
		
	
		game.Lighting.Atmosphere:Destroy()
		local NewAtmosphere = script.Atmosphere:Clone()
		NewAtmosphere.Parent = game.Lighting
		game.Lighting.TimeOfDay = "14:48:00"
		
		CharClone.PrimaryPart.Anchored = true
		CharClone:SetPrimaryPartCFrame(SceneDummy.PrimaryPart.CFrame)
		SceneDummy:Destroy()
		CharClonehum:LoadAnimation(script.SceneAnimation):Play()
		_G.Cinematic({Parent = CharClone.PrimaryPart})
		local Ambience = script.Ambience:Clone()
		Ambience.Parent = game.Workspace
		Ambience:Play()
		
		local Music= script.Music
		Music.Parent = game.Workspace
		Music:Play()
	
	end,



}

return module
