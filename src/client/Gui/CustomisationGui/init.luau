--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)
local Button = require(script.Parent.Components.Button)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Util = require(ReplicatedStorage.Shared.Utility.Util)

local USER_IDS = { 60541768, 290622415, 3227875212 }

local bridge = BridgeNet2.ClientBridge("customise")
local scoped = Fusion.scoped
local scope = scoped(Fusion, { Button = Button })
local isVisible = scope:Value(false)
local isRandomising = scope:Value(false)
local worldModel = scope:New("WorldModel")({})
local starterCharacter = StarterPlayer:WaitForChild("StarterCharacter")
local idleAnimation = ReplicatedStorage.Assets.Animation.Customisation.Idle

local Children = Fusion.Children

local function updateCameraForCharacter(char: Model, camera: Camera)
	local modelCenter, modelSize = char:GetBoundingBox()
	local fov = 45
	camera.FieldOfView = fov
	local height = modelSize.Y
	local width = modelSize.X
	local depth = modelSize.Z
	local maxDimension = math.max(height, width, depth)
	local distance = (maxDimension / 2) / math.tan(math.rad(fov / 2))
	local offset = modelCenter.LookVector * (distance + 0.9)
	camera.CFrame = CFrame.new(modelCenter.Position + offset, modelCenter.Position)
end

local function applyRandomDescription(hum: Humanoid, onComplete: ((boolean) -> ())?)
	local randomUserId = USER_IDS[math.random(1, #USER_IDS)]
	task.spawn(function()
		local success, humanoidDescription = pcall(function()
			return Players:GetHumanoidDescriptionFromUserId(randomUserId)
		end)

		if success and humanoidDescription then
			humanoidDescription.Head = 0
			humanoidDescription.LeftArm = 0
			humanoidDescription.LeftLeg = 0
			humanoidDescription.RightArm = 0
			humanoidDescription.RightLeg = 0
			humanoidDescription.Torso = 0
			hum:ApplyDescriptionAsync(humanoidDescription)
		else
			warn("Failed to load HumanoidDescription for UserId:", randomUserId)
		end

		if onComplete then
			onComplete(success == true and humanoidDescription ~= nil)
		end
	end)
end

local function init()
	local player = Players.LocalPlayer
	local camera = scope:New("Camera")({}) :: Camera

	scope:New("ScreenGui")({
		Enabled = isVisible,
		IgnoreGuiInset = true,
		Name = "CustomisationGui",
		Parent = player.PlayerGui,

		[Children] = {
			scope:New("Frame")({
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),

				[Children] = {
					scope:New("ViewportFrame")({
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						CurrentCamera = camera,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.8, 0.8),

						[Children] = { worldModel, camera },
					}),

					scope:Button({
						Name = "BackButton",
						Position = UDim2.fromScale(0.05, 0.95),
						AnchorPoint = Vector2.new(0, 1),
						Content = { "Back" },
						OnClick = function()
							bridge:Fire(false)
						end,
					}),

					scope:Button({
						Name = "RandomiseButton",
						Position = UDim2.fromScale(0.95, 0.95),
						AnchorPoint = Vector2.new(1, 1),
						Disabled = isRandomising,
						Content = scope:Computed(function(use)
							return if use(isRandomising)
								then { "rbxassetid://14922766443", "Loading..." }
								else { "rbxassetid://14922766443", "Randomise" }
						end),
						OnClick = function()
							if Fusion.peek(isRandomising) then
								return
							end

							local char = worldModel:FindFirstChildWhichIsA("Model")
							if char then
								local hum = char:FindFirstChildOfClass("Humanoid")
								if hum then
									isRandomising:set(true)
									applyRandomDescription(hum, function(success)
										if success then
											updateCameraForCharacter(char, camera)
										end
										isRandomising:set(false)
									end)
								end
							end
						end,
					}),
				},
			}),
		},
	})

	Observers.observeAttribute(player, "IsCustomising", function(value)
		if type(value) ~= "boolean" then
			return nil
		end

		isVisible:set(value)

		if not value then
			return nil
		end

		local trove = Trove.new()

		local char = trove:Clone(starterCharacter)
		char.Parent = worldModel

		local hum = Util.waitForHum(char)
		if hum then
			local animator = Util.waitForAnimator(hum)
			if animator then
				animator:LoadAnimation(idleAnimation):Play()
			end
		end

		updateCameraForCharacter(char, camera)

		return trove:WrapClean()
	end, function(value: unknown)
		return type(value) == "boolean"
	end)
end

return { __init = init }
