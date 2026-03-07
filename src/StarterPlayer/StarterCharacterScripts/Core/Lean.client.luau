local Player = game.Players.LocalPlayer
local Character = Player.Character or Player:WaitForCharacter()
local Waist = Character:WaitForChild("UpperTorso"):WaitForChild("Waist")
local Root = Character:WaitForChild("LowerTorso"):WaitForChild("Root")
local Humanoid = Character.Humanoid
local PrimaryPart = Character.PrimaryPart
local Vector = Vector3.new()
local RootC0 = Root.C0
local WaistC0 = Waist.C0

game["Run Service"].Heartbeat:connect(function ()
	if Character.PrimaryPart and Character:FindFirstChild("Humanoid") then
		local PPC = PrimaryPart.CFrame
		local pos = Vector3.new(0, 1, 0):Cross(Vector)
		local Magnitude = pos.magnitude
		local CheckMovement = (CFrame.new((PPC * CFrame.new(0, -2, 0)).p) * CFrame.fromAxisAngle(Vector3.new(1, 0, 0) or pos.unit, (math.asin(pos.magnitude))) * CFrame.new(Vector3.new(), Humanoid.MoveDirection)).lookVector:Dot(PPC.rightVector)
		if math.abs(CheckMovement) > 0.__5 then
			local AutoRotate = Character.Humanoid.AutoRotate
			local v18 = math.rad(math.clamp(math.deg(CheckMovement * -(0.125 * PrimaryPart.Velocity.magnitude)), -4, 4))
			Root.C0 = Root.C0:lerp(RootC0 * CFrame.Angles(0, 0, v18), 0.125)
			Waist.C0 = Waist.C0:lerp(WaistC0 * CFrame.Angles(0, 0, v18), 0.125)
		else
			Root.C0 = Root.C0:lerp(RootC0, 0.125)
			Waist.C0 = Waist.C0:lerp(WaistC0, 0.125)
		end

	end
end)