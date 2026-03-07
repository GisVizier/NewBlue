--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local MovementController = {}

function MovementController:Init()
end

function MovementController:Start()
	local player = Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local waist = character:WaitForChild("UpperTorso"):WaitForChild("Waist") :: Motor6D
	local root = character:WaitForChild("LowerTorso"):WaitForChild("Root") :: Motor6D
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	local primaryPart = character.PrimaryPart

	local vector = Vector3.new()
	local rootC0 = root.C0
	local waistC0 = waist.C0

	RunService.Heartbeat:Connect(function()
		if not primaryPart or not character:FindFirstChild("Humanoid") then
			return
		end

		local ppc = primaryPart.CFrame
		local pos = Vector3.new(0, 1, 0):Cross(vector)
		local checkMovement = (
			CFrame.new((ppc * CFrame.new(0, -2, 0)).Position)
			* CFrame.fromAxisAngle(Vector3.new(1, 0, 0) or pos.Unit, math.asin(pos.Magnitude))
			* CFrame.new(Vector3.new(), humanoid.MoveDirection)
		).LookVector:Dot(ppc.RightVector)

		if math.abs(checkMovement) > 0.5 then
			local v18 = math.rad(math.clamp(math.deg(checkMovement * -(0.125 * primaryPart.AssemblyLinearVelocity.Magnitude)), -4, 4))
			root.C0 = root.C0:Lerp(rootC0 * CFrame.Angles(0, 0, v18), 0.125)
			waist.C0 = waist.C0:Lerp(waistC0 * CFrame.Angles(0, 0, v18), 0.125)
		else
			root.C0 = root.C0:Lerp(rootC0, 0.125)
			waist.C0 = waist.C0:Lerp(waistC0, 0.125)
		end
	end)
end

return MovementController
