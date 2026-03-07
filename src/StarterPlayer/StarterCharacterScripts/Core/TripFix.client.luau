print("TripFix is enabled")

local stateType = Enum.HumanoidStateType

local character = script.Parent.Parent
local humanoid = character:WaitForChild("Humanoid")

humanoid:SetStateEnabled(stateType.FallingDown, false)
humanoid:SetStateEnabled(stateType.Ragdoll, false)