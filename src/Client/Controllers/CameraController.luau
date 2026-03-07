--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local CameraController = {}

function CameraController:Init()
end

function CameraController:Start()
	local cameraPoints = workspace:WaitForChild("CameraPoints")
	local camOrigin = cameraPoints:WaitForChild("CamOrigin")
	local startCam = cameraPoints:WaitForChild("StartCam")

	-- Position player at customize point on first spawn
	local player = Players.LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")
	local points = workspace:WaitForChild("Points")
	local customizePoint = points:FindFirstChild("CustomizePoint")
	if customizePoint then
		hrp.CFrame = customizePoint.CFrame
	end

	-- Smooth camera orbit on RenderStepped
	RunService.RenderStepped:Connect(function()
		local originRotation = camOrigin.CFrame * CFrame.Angles(0, math.rad(0.05), 0)
		local startCamRotation = camOrigin.CFrame * CFrame.new(0, 0, 15)
		camOrigin.CFrame = originRotation
		startCam.CFrame = startCamRotation
	end)
end

return CameraController
