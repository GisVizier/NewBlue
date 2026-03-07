--!strict

local stateType = Enum.HumanoidStateType
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid") :: Humanoid

humanoid:SetStateEnabled(stateType.FallingDown, false)
humanoid:SetStateEnabled(stateType.Ragdoll, false)
