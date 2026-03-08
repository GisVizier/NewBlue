--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local MainConfig = require(ReplicatedStorage.Shared.Registry.Config)
local Tag = require(ReplicatedStorage.Shared.Utility.Tag)
local Visualise = require(ReplicatedStorage.Shared.Utility.Visualise)

local DEBUG: boolean = RunService:IsStudio()

local mapRaycastParams = RaycastParams.new()
mapRaycastParams.FilterDescendantsInstances = { workspace.Map }
mapRaycastParams.FilterType = Enum.RaycastFilterType.Include

local function logWarn(source: string, message: string, includeTraceback: boolean?)
	message = `[{source}]: {message}`
	if includeTraceback and DEBUG then
		message ..= `\nTraceback: {debug.traceback(nil, 2)}`
	end
	warn(message)
end

local function log(fnName: string, message: string)
	logWarn(`Util.{fnName}`, message, true)
end

local Util = {}

function Util.getMousePos(player: Player): Vector3
	local mousePart: Part? = workspace.Ignore.Mice:FindFirstChild(`Mouse{player.UserId}`)
	return mousePart and mousePart.Position or Vector3.zero
end

function Util.raycast(
	origin: Vector3,
	direction: Vector3,
	raycastParams: RaycastParams?,
	visualise: boolean?
): RaycastResult?
	raycastParams = raycastParams or mapRaycastParams
	if visualise then
		task.spawn(Visualise.raycast, origin, direction, raycastParams)
	end
	return Workspace:Raycast(origin, direction, raycastParams)
end

function Util.inAir(char: Model, visualiseRaycast: boolean?): boolean
	if Tag.has(char, Tag.Enum.Airborne) then
		return true
	end

	local root = Util.getRoot(char)
	if not root then
		return false
	end
	local rootCF = root.CFrame
	local result = Util.raycast(rootCF.Position, rootCF.UpVector * -5, mapRaycastParams, visualiseRaycast)
	if result ~= nil and result.Instance and result.Instance:IsA("BasePart") and result.Instance.CanCollide then
		return false
	end

	local hum = Util.getHum(char)
	if not hum then
		return false
	end

	local state = hum:GetState()
	return (state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping)
		and hum.FloorMaterial == Enum.Material.Air
end

function Util.searchAnDestroy(instance: Instance, className: string, name: string): Instance?
	local existingChild: Instance? = nil

	for _, child in instance:GetChildren() do
		if child:IsA(className) then
			if not existingChild and child.Name == name then
				existingChild = child
			else
				child:Destroy()
			end
		end
	end

	return existingChild
end

function Util.isLive(char: Model): boolean
	return char
		and char:IsA("Model")
		and char.Parent ~= nil
		and char.Parent == workspace.Live
		and char:HasTag(MainConfig.TAG.LIVE)
end

function Util.isAlive(char: Model): boolean
	local humanoid = Util.getHum(char)
	if
		not humanoid
		or humanoid.Health <= 0
		or humanoid.Health ~= humanoid.Health
		or humanoid:GetState() == Enum.HumanoidStateType.Dead
	then
		return false
	end
	return true
end

function Util.log(source: string, message: string, includeTraceback: boolean?)
	message = `[{source}]: {message}`
	if includeTraceback and DEBUG then
		message ..= `\nTraceback: {debug.traceback(nil, 2)}`
	end
	print(message)
end

Util.logWarn = logWarn

function Util.getTorso(char: Model): BasePart?
	if not char or not char:IsA("Model") or not char.Parent then
		log("getTorso", "Invalid character")
		return
	end

	local torso: BasePart? = char:FindFirstChild("Torso") :: BasePart
	if torso ~= nil and not torso:IsA("BasePart") then
		torso = nil
	end
	if not torso then
		log("getTorso", `No torso found in {char:GetFullName()}`)
	end

	return torso
end

function Util.getRoot(char: Model): BasePart?
	if not char or not char:IsA("Model") or not char.Parent then
		log("getRoot", "Invalid character")
		return
	end

	if char.PrimaryPart ~= nil then
		return char.PrimaryPart
	end

	local root: BasePart? = char:FindFirstChild("HumanoidRootPart") :: BasePart
	if root ~= nil and not root:IsA("BasePart") then
		root = nil
	end
	if not root then
		log("getRoot", `No root found in {char:GetFullName()}`)
	end

	return root
end

function Util.getRootFr(char: Model): BasePart
	local root = Util.getRoot(char)
	if not root then
		error("expected root missing")
	end
	return root
end

function Util.waitForRoot(char: Model): BasePart?
	if not char or not char:IsA("Model") or not char.Parent then
		log("waitForRoot", "Invalid character")
		return
	end

	if char.PrimaryPart ~= nil then
		return char.PrimaryPart
	end

	local root: BasePart? = nil

	root = char:WaitForChild("HumanoidRootPart", 3) :: BasePart
	if root ~= nil and not root:IsA("BasePart") then
		root = nil
	end

	if not root and char.Parent then
		root = char:FindFirstChild("HumanoidRootPart") :: BasePart
		if not root then
			log("waitForRoot", `No root found in {char:GetFullName()}`)
		end
	end

	return root
end

function Util.getRootAtt(root: BasePart): Attachment?
	if not root or not root:IsA("BasePart") or not root.Parent then
		log("getRootAtt", "Invalid root")
		return
	end

	local rootAtt: Attachment? = root:FindFirstChild("RootAttachment") :: Attachment
	if rootAtt ~= nil and not rootAtt:IsA("Attachment") then
		rootAtt = nil
	end
	if not rootAtt then
		log("getRootAtt", `No root attachment found in {root:GetFullName()}`)
	end

	return rootAtt
end

function Util.getRootAttFr(root: BasePart): Attachment
	local rootAtt = Util.getRootAtt(root)
	if not rootAtt then
		local att = Instance.new("Attachment")
		att.Name = "RootAttachment"
		att.Parent = root
		return att
	end
	return rootAtt
end

function Util.waitForRootAtt(root: BasePart): Attachment?
	if not root or not root:IsA("BasePart") or not root.Parent then
		log("waitForRootAtt", "Invalid root")
		return
	end

	local rootAtt: Attachment? = nil

	rootAtt = root:WaitForChild("RootAttachment", 3) :: Attachment
	if rootAtt ~= nil and not rootAtt:IsA("Attachment") then
		rootAtt = nil
	end

	if not rootAtt and root.Parent then
		rootAtt = root:FindFirstChild("RootAttachment") :: Attachment
		if rootAtt ~= nil and not rootAtt:IsA("Attachment") then
			rootAtt = nil
		end
		if not rootAtt then
			log("waitForRootAtt", `No root attachment found in {root:GetFullName()}`)
		end
	end

	return rootAtt
end

function Util.getHum(char: Model): Humanoid?
	if not char or not char:IsA("Model") or not char.Parent then
		log("getHum", "Invalid character")
		return
	end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then
		log("getHum", `No humanoid found in {char:GetFullName()}`)
	end

	return hum
end

function Util.getHumFr(char: Model): Humanoid
	local hum = Util.getHum(char)
	if not hum then
		error("expected hum missing")
	end
	return hum
end

function Util.waitForHum(char: Model): Humanoid?
	if not char or not char:IsA("Model") or not char.Parent then
		log("getHumAsync", "Invalid character")
		return
	end

	local hum: Humanoid? = nil

	hum = char:WaitForChild("Humanoid", 3) :: Humanoid
	if hum ~= nil and not hum:IsA("Humanoid") then
		hum = nil
	end

	if not hum and char.Parent then
		hum = char:FindFirstChildOfClass("Humanoid")
		if not hum then
			log("getHumAsync", `No humanoid found in {char:GetFullName()}`)
		end
	end

	return hum
end

function Util.getAnimator(hum: Humanoid): Animator?
	if not hum or not hum:IsA("Humanoid") or not hum.Parent then
		log("getAnimator", "Invalid humanoid")
		return
	end

	local animator = hum:FindFirstChildOfClass("Animator")
	if not animator then
		log("getAnimator", `No animator found in {hum:GetFullName()}`)
	end

	return animator
end

function Util.waitForAnimator(hum: Humanoid): Animator?
	if not hum or not hum:IsA("Humanoid") or not hum.Parent then
		log("getAnimatorAsync", "Invalid humanoid")
		return
	end

	local animator: Animator? = nil

	animator = hum:WaitForChild("Animator", 3) :: Animator
	if animator ~= nil and not animator:IsA("Animator") then
		animator = nil
	end

	if not animator and hum.Parent then
		animator = hum:FindFirstChildOfClass("Animator")
		if not animator then
			log("getAnimatorAsync", `No animator found in {hum:GetFullName()}`)
		end
	end

	return animator
end

return Util
