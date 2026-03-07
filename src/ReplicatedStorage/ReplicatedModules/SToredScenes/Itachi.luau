local Player = game.Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()


local module = {


	Engage =function()
		
		local CharClone = Char:Clone()
		CharClone.Parent = game.Workspace
		local CharClonehum = CharClone:WaitForChild("Humanoid")
		
		
		local Scene = script.Scene
		Scene.Parent = game.Workspace
		Scene = game.Workspace:WaitForChild("Scene")
	--	local CustomizePoint = Scene:WaitForChild("CustomizePoint")
		local SceneDummy = Scene:WaitForChild("SceneDummy")
		
		--Char:SetPrimaryPartCFrame(CustomizePoint.CFrame)
		
	--[[
		local Highlight = Instance.new("Highlight")
		Highlight.OutlineTransparency = 1
		Highlight.FillTransparency = 0
		Highlight.FillColor = Color3.new(0, 0, 0)
		Highlight.Parent = CharClone
		Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		--]]
		
		game.Lighting.Atmosphere:Destroy()
		local NewAtmoshpere = script.Atmosphere:Clone()
		NewAtmoshpere.Parent = game.Lighting
		local Clouds = script.Clouds:Clone()
		Clouds.Parent = game.Workspace.Terrain
		game.Lighting.TimeOfDay = "04:24:00"
		game.Lighting.Sky.MoonAngularSize = 60
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
		
	end,



}

return module
