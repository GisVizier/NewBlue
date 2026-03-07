--!strict

local CollectionService = game:GetService("CollectionService")

local CustomizationConfig = require(script.Parent.Parent.Config.CustomizationConfig)

local function CalcSizeOffset(size: Vector3, char: Model): Vector3
	local hum = char:WaitForChild("Humanoid") :: Humanoid
	local depthScale = (hum:WaitForChild("BodyDepthScale") :: NumberValue).Value
	local heightScale = (hum:WaitForChild("BodyHeightScale") :: NumberValue).Value
	local widthScale = (hum:WaitForChild("BodyWidthScale") :: NumberValue).Value

	return Vector3.new(size.X * widthScale, size.Y * heightScale, size.Z * depthScale)
end

local function ScaleWeld(weld: Instance, char: Model)
	local hum = char:WaitForChild("Humanoid") :: Humanoid
	local depthScale = (hum:WaitForChild("BodyDepthScale") :: NumberValue).Value
	local heightScale = (hum:WaitForChild("BodyHeightScale") :: NumberValue).Value
	local widthScale = (hum:WaitForChild("BodyWidthScale") :: NumberValue).Value

	if weld:IsA("Bone") then
		local pos = weld.Position
		weld.Position = Vector3.new(pos.X * widthScale, pos.Y * heightScale, pos.Z * depthScale)
	else
		local motor = weld :: Motor6D
		local rx0, ry0, rz0 = motor.C0:ToOrientation()
		local p0 = motor.C0.Position
		motor.C0 = CFrame.new(p0.X * widthScale, p0.Y * heightScale, p0.Z * depthScale) * CFrame.Angles(rx0, ry0, rz0)

		local rx1, ry1, rz1 = motor.C1:ToOrientation()
		local p1 = motor.C1.Position
		motor.C1 = CFrame.new(p1.X * widthScale, p1.Y * heightScale, p1.Z * depthScale) * CFrame.Angles(rx1, ry1, rz1)
	end
end

local function SetupSmartBone(part: BasePart)
	CollectionService:AddTag(part, "SmartBone")

	local rootNames = {}
	for _, desc in part:GetDescendants() do
		if desc:IsA("Bone") and desc.Name ~= "Bone" then
			table.insert(rootNames, desc.Name)
		end
	end
	part:SetAttribute("Roots", table.concat(rootNames, ","))

	local defaults = CustomizationConfig.SmartBoneDefaults
	if not part:GetAttribute("Stiffness") then
		part:SetAttribute("Stiffness", defaults.Stiffness)
	end
	if not part:GetAttribute("Inertia") then
		part:SetAttribute("Inertia", defaults.Inertia)
	end
	if not part:GetAttribute("Dampning") then
		part:SetAttribute("Dampning", defaults.Dampning)
	end
	part:SetAttribute("Gravity", defaults.Gravity)
	part:SetAttribute("Elasticity", defaults.Elasticity)
end

export type WeldAndScaleParams = {
	Char: Model,
	WeldReference: Instance,
	Parent: Instance,
	Name: string?,
	NoScale: boolean?,
	WeaponWeldBool: boolean?,
}

local WeldAndScale = {}

function WeldAndScale.WeldAndScale(params: WeldAndScaleParams): Model
	local char = params.Char
	local noScale = params.NoScale
	local weaponWeldBool = params.WeaponWeldBool
	local name = params.Name
	local weldReference = params.WeldReference
	local parent = params.Parent

	local hum = char:WaitForChild("Humanoid") :: Humanoid

	local hasBone = false
	local newModel = weldReference:Clone() :: Model

	for _, v in newModel:GetDescendants() do
		if v:IsA("Bone") then
			hasBone = true
			break
		end
	end

	for _, v in newModel:GetDescendants() do
		if v:IsA("BasePart") then
			v.CanCollide = false
			v.Anchored = false
			v.CanQuery = false
			v.Massless = true
			v:SetAttribute("Transparency", v.Transparency)
			v:SetAttribute("Material", string.split(tostring(v.Material), ".")[3])
			v:SetAttribute("OriginalTransparency", v.Transparency)
		end
	end

	for _, v in newModel:GetChildren() do
		local findBodyPart = char:FindFirstChild(v.Name)
		if findBodyPart and v:IsA("Model") then
			local primaryPart = v.PrimaryPart

			for _, e in v:GetChildren() do
				if e:IsA("BasePart") and e ~= primaryPart then
					if findBodyPart.Name ~= "Head" then
						if not noScale then
							e.Size = CalcSizeOffset(e.Size, char)
						end
						e.CanCollide = false
						e.Anchored = false
						e.Massless = true
						e.CanQuery = false
					end
				end
			end

			if primaryPart then
				local findAccessoryWeld = primaryPart:FindFirstChildOfClass("Motor6D") or primaryPart:FindFirstChildOfClass("Weld")
				if findAccessoryWeld or weaponWeldBool then
					if weaponWeldBool then
						local motor6D = primaryPart:FindFirstChildOfClass("Motor6D")
						if not motor6D then
							motor6D = Instance.new("Motor6D")
							motor6D.Parent = findBodyPart
							motor6D.Part0 = findBodyPart
							motor6D.Part1 = primaryPart
							ScaleWeld(motor6D, char)
						else
							motor6D.Part0 = findBodyPart
							motor6D.Part1 = primaryPart
							motor6D.Parent = findBodyPart
							motor6D.Name = "Motor6D"
							ScaleWeld(motor6D, char)
						end
					else
						local accessoryWeld = findAccessoryWeld:Clone()
						findAccessoryWeld:Destroy()
						if findBodyPart.Name ~= "Head" then
							ScaleWeld(accessoryWeld, char)
						end

						accessoryWeld.Name = "AccessoryWeld"
						accessoryWeld.Parent = primaryPart
						if findAccessoryWeld.Name == primaryPart.Name then
							accessoryWeld.Part0 = findBodyPart
							accessoryWeld.Part1 = primaryPart
						else
							accessoryWeld.Part0 = primaryPart
							accessoryWeld.Part1 = findBodyPart
						end
					end

					for _, e in v:GetChildren() do
						if findBodyPart.Name ~= "Head" then
							local findWeld = e:FindFirstChildOfClass("Motor6D") or e:FindFirstChildOfClass("Weld")
							if findWeld then
								if not hasBone then
									if not noScale then
										ScaleWeld(findWeld, char)
									end
								end
							end
						end
					end
				end
			else
				for _, e in v:GetDescendants() do
					if e:IsA("BasePart") then
						local findWeld = e:FindFirstChildOfClass("Motor6D") or e:FindFirstChildOfClass("Weld")
						if findWeld then
							local weldClone = findWeld:Clone()
							findWeld:Destroy()
							weldClone.Parent = e
							weldClone.Part0 = e
							weldClone.Part1 = findBodyPart
							if findBodyPart.Name ~= "Head" then
								ScaleWeld(weldClone, char)
							end
						end
					end
				end
			end
		end
	end

	if name then
		newModel.Name = name
	end

	newModel.Parent = parent

	local smart = newModel:FindFirstChild("Smart", true)
	if smart and smart:IsA("BasePart") then
		SetupSmartBone(smart)
	end

	local animation = newModel:FindFirstChild("Animation", true)
	local animController = newModel:FindFirstChild("AnimationController", true)
	if animation and animController and animation:IsA("Animation") and animController:IsA("AnimationController") then
		animController:LoadAnimation(animation):Play()
	end

	return newModel
end

WeldAndScale.SetupSmartBone = SetupSmartBone

return WeldAndScale
