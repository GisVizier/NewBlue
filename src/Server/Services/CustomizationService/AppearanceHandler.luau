--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeldAndScale = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"):WaitForChild("WeldAndScale"))

local CustomizationMeshes = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("CustomizeMeshes")

local AppearanceHandler = {}

local function setupSmartBone(part: BasePart)
	WeldAndScale.SetupSmartBone(part)
end

function AppearanceHandler.RefreshHair(char: Model, hairId: any)
	for _, v in char:GetChildren() do
		if v.Name == "Hair" then
			v:Destroy()
		end
	end
	local findHair = CustomizationMeshes:WaitForChild("Hair"):FindFirstChild(tostring(hairId))
	if findHair then
		local hair = WeldAndScale.WeldAndScale({ Char = char, WeldReference = findHair, Parent = char, Name = "Hair" })
		local realHair = hair.PrimaryPart
		if realHair then
			setupSmartBone(realHair)
		end
	end
end

function AppearanceHandler.RefreshFacial(char: Model, facialId: any)
	for _, v in char:GetChildren() do
		if v.Name == "Beard" then
			v:Destroy()
		end
	end
	local findBeard = CustomizationMeshes:WaitForChild("Beard"):FindFirstChild(tostring(facialId))
	if findBeard then
		local beard = WeldAndScale.WeldAndScale({ Char = char, WeldReference = findBeard, Parent = char, Name = "Beard" })
		local realBeard = beard.PrimaryPart
		if realBeard then
			setupSmartBone(realBeard)
		end
	end
end

function AppearanceHandler.RefreshFace(char: Model, eyesId: any, mouthId: any, noseId: any)
	local head = char:WaitForChild("Head")
	for _, v in head:GetChildren() do
		if v:IsA("Decal") then
			if v.Name == "Mouth" or v.Name == "Eyes" or v.Name == "Nose" or v.Name == "Blink" or v.Name == "Eyebrows" or v.Name == "Pupil" then
				v:Destroy()
			end
		end
	end

	local findNose = CustomizationMeshes:WaitForChild("FaceDecals"):WaitForChild("Nose"):FindFirstChild(tostring(noseId))
	local findMouth = CustomizationMeshes:WaitForChild("FaceDecals"):WaitForChild("Mouth"):FindFirstChild(tostring(mouthId))
	local findEyes = CustomizationMeshes:WaitForChild("FaceDecals"):WaitForChild("Eyes"):FindFirstChild(tostring(eyesId))

	if findNose and findMouth and findEyes then
		local noseClone = findNose:Clone()
		local mouthClone = findMouth:Clone()
		local eyesClone = findEyes:Clone()

		noseClone.Parent = head
		mouthClone.Parent = head

		if eyesClone then
			local eyesCopy = eyesClone:Clone()
			for _, v in eyesCopy:GetChildren() do
				v.Parent = head
			end
		end

		noseClone.Name = "Nose"
		mouthClone.Name = "Mouth"
	end
end

function AppearanceHandler.RefreshSkin(char: Model, raceType: string, skinColor: number)
	local raceSkinColors = CustomizationMeshes:WaitForChild("RaceSkinColors")
	local skinFolder = raceSkinColors:FindFirstChild(raceType)
	if not skinFolder then
		skinFolder = raceSkinColors:WaitForChild("Human")
	end

	local findColor = skinFolder:FindFirstChild(tostring(skinColor))
	if findColor and findColor:IsA("Color3Value") then
		for _, v in char:GetChildren() do
			if v:IsA("BasePart") then
				v.Color = findColor.Value
			end
		end
	end
end

function AppearanceHandler.RefreshBuild(char: Model, buildId: any)
	for _, v in char:GetChildren() do
		if v.Name == "Build" then
			v:Destroy()
		end
	end

	local findBuild = CustomizationMeshes:WaitForChild("Build"):FindFirstChild(tostring(buildId))
	if findBuild then
		for _, v in findBuild:GetChildren() do
			local clone = v:Clone()
			clone.Parent = char
		end
	end
end

return AppearanceHandler
