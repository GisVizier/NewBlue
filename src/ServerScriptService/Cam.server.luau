print("balls")
local Points = game.Workspace:WaitForChild("Points")
game.Players.PlayerAdded:Connect(function(Player)
	print(Player)
	local Char = game.Workspace:WaitForChild(Player.Name)
	local hrp = Char:WaitForChild("HumanoidRootPart")
	print(Char)
	hrp.CFrame = Points:WaitForChild("CustomizePoint").CFrame
end)



--Camera
local CameraPoints = game.Workspace:WaitForChild("CameraPoints")
local StartCam = CameraPoints:WaitForChild("StartCam")
local CamOrigin = CameraPoints:WaitForChild("CamOrigin")
local Camera = game.Workspace.CurrentCamera


spawn(function()
	while wait() do
		local OriginRotation = CamOrigin.CFrame * CFrame.Angles(0,math.rad(0.05),0)
		local StartCamRotation = CamOrigin.CFrame * CFrame.new(0,0,15) * CFrame.Angles(0,0,0)
		CamOrigin.CFrame = OriginRotation
		StartCam.CFrame = StartCamRotation
			
	end
end)

