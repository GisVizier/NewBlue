--!strict

local CONE_HEIGHT = 0.25
local LINE_THICKNESS = 5
local TRANSPARENCY = 0.5
local ALWAYS_ON_TOP = true
local VISUAL_LIFETIME = 5

local Visualise = {}

function Visualise.raycast(origin: Vector3, direction: Vector3, raycastParams: RaycastParams?)
	local lineLength = direction.Magnitude - CONE_HEIGHT

	local rootPart = Instance.new("Part")
	rootPart.Transparency = 1
	rootPart.Parent = workspace.Terrain
	rootPart.Size = Vector3.one / 100
	rootPart.CFrame = CFrame.lookAt(origin, origin + direction)
	rootPart.CanCollide = false
	rootPart.CanQuery = false
	rootPart.CanTouch = false
	rootPart.Anchored = true

	local line = Instance.new("LineHandleAdornment")
	line.Color3 = Color3.new(0, 1, 0)
	line.Transparency = TRANSPARENCY
	line.Adornee = rootPart
	line.AlwaysOnTop = ALWAYS_ON_TOP
	line.Length = lineLength
	line.Parent = rootPart
	line.Thickness = LINE_THICKNESS
	line.ZIndex = 1

	local endPoint = Instance.new("ConeHandleAdornment")
	endPoint.Color3 = Color3.new(0, 1, 0)
	endPoint.Transparency = 0.5
	endPoint.Adornee = rootPart
	endPoint.AlwaysOnTop = ALWAYS_ON_TOP
	endPoint.CFrame = CFrame.new(0, 0, -lineLength)
	endPoint.Height = CONE_HEIGHT
	endPoint.Parent = rootPart
	endPoint.Radius = 0.05
	endPoint.SizeRelativeOffset = Vector3.new(0, 0, CONE_HEIGHT * 2)
	endPoint.ZIndex = 1

	local raycastResult = workspace:Raycast(origin, direction, raycastParams)
	if raycastResult ~= nil then
		local hitPoint = Instance.new("ConeHandleAdornment")
		hitPoint.Color3 = Color3.new(1, 0, 0)
		hitPoint.Transparency = 0.5
		hitPoint.Adornee = rootPart
		hitPoint.AlwaysOnTop = ALWAYS_ON_TOP
		hitPoint.CFrame = CFrame.new(0, 0, -raycastResult.Distance)
		hitPoint.Height = CONE_HEIGHT
		hitPoint.Parent = rootPart
		hitPoint.Radius = 0.1
		hitPoint.SizeRelativeOffset = Vector3.new(0, 0, CONE_HEIGHT * 2)
		hitPoint.ZIndex = 0
	end

	task.delay(VISUAL_LIFETIME, rootPart.Destroy, rootPart)
end

return Visualise
