--!strict

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local BoatTween = require(ReplicatedStorage.Packages.BoatTween) -- temp
local Debris2 = require(ReplicatedStorage.Shared.Lib.Debris2)

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local function playTween(Object, Info)
	local Tween = BoatTween:Create(Object, Info)
	if Tween then
		Tween:Play()
		Tween.Completed:Connect(function()
			Tween:Destroy()
		end)
	end
end

local function tweenGuiTransparency(GuiObject: GuiObject, Start, End, Time: number)
	local Index = {}
	table.insert(Index, GuiObject)
	for i, v in pairs(GuiObject:GetDescendants()) do
		if v:IsA("GuiObject") then
			table.insert(Index, v)
		end
	end
	for i, v in pairs(Index) do
		if v:IsA("GuiObject") then
			local UIGradient: UIGradient = v:FindFirstChildOfClass("UIGradient") :: any
			local PrevTransparency
			if not UIGradient then
				UIGradient = Instance.new("UIGradient")
				Debris2:AddItem(UIGradient, Time + 0.1)
			else
				PrevTransparency = UIGradient.Transparency
			end
			local FinalStart =
				NumberSequence.new({ NumberSequenceKeypoint.new(0, Start), NumberSequenceKeypoint.new(1, Start) })
			if Start == 0 then
				if PrevTransparency then
					FinalStart = PrevTransparency
				end
			end
			local FinalEnd =
				NumberSequence.new({ NumberSequenceKeypoint.new(0, End), NumberSequenceKeypoint.new(1, End) })
			if End == 0 then
				if PrevTransparency then
					FinalEnd = PrevTransparency
				end
			end
			UIGradient.Transparency = FinalStart
			UIGradient.Parent = v
			playTween(UIGradient, { EasingStyle = "Sine", Time = Time, Goal = { Transparency = FinalEnd } })
			if PrevTransparency then
				task.delay(Time + 0.1, function()
					UIGradient.Transparency = PrevTransparency
				end)
			end
		end
	end
end

local function onCharacterAdded(char: Model)
	--task.wait(3)
	local CustomizePoint = Workspace:WaitForChild("DefaultPoints"):WaitForChild("CustomizePoint")
	char:PivotTo(CustomizePoint.CFrame)

	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Size = 12
	blurEffect.Parent = Lighting

	-- do -- scene
	-- 	local Lighting = game:GetService("Lighting")

	-- 	local CharClone = char:Clone()
	-- 	CharClone.Parent = workspace
	-- 	local CharClonehum = CharClone:WaitForChild("Humanoid")

	-- 	Lighting:SetAttribute("WindDirection", Vector3.new(20, 0, 0))
	-- 	Lighting:SetAttribute("WindStrength", 1)
	-- 	Lighting:SetAttribute("WindSpeed", 1)

	-- 	local Scene = script.Scene
	-- 	Scene.Parent = workspace
	-- 	Scene = workspace:WaitForChild("Scene")

	-- 	local SceneDummy = Scene:WaitForChild("SceneDummy")

	-- 	local oldAtmo = Lighting:FindFirstChildOfClass("Atmosphere")
	-- 	if oldAtmo then
	-- 		oldAtmo:Destroy()
	-- 	end
	-- 	local NewAtmosphere = script.Atmosphere:Clone()
	-- 	NewAtmosphere.Parent = Lighting
	-- 	Lighting.TimeOfDay = "14:48:00"

	-- 	CharClone.PrimaryPart.Anchored = true
	-- 	CharClone:PivotTo(SceneDummy.PrimaryPart.CFrame)
	-- 	SceneDummy:Destroy()
	-- 	CharClonehum:LoadAnimation(script.SceneAnimation):Play()

	-- 	-- Cinematic camera
	-- 	local camera = workspace.CurrentCamera
	-- 	camera.CameraType = Enum.CameraType.Scriptable
	-- 	camera.CFrame = CharClone.PrimaryPart.CFrame * CFrame.new(0, 2, 8)

	-- 	local Ambience = script.Ambience:Clone()
	-- 	Ambience.Parent = workspace
	-- 	Ambience:Play()

	-- 	local Music = script.Music
	-- 	Music.Parent = workspace
	-- 	Music:Play()
	-- end

	local transitionsGui = player.PlayerGui.Transitions
	TweenService:Create(transitionsGui.Grey, TweenInfo.new(0.3, Enum.EasingStyle.Sine), { BackgroundTransparency = 0 })
		:Play()

	TweenService:Create(blurEffect, TweenInfo.new(1.5, Enum.EasingStyle.Sine), { Size = 0 }):Play()
	Debris2:AddItem(blurEffect, 2)

	camera.FieldOfView = 100
	TweenService:Create(camera, TweenInfo.new(1, Enum.EasingStyle.Sine), { FieldOfView = 70 }):Play()

	local mainMenuGui = player.PlayerGui.Main

	local MainButtons = mainMenuGui:WaitForChild("Main Buttons")
	local Buttons = mainMenuGui:WaitForChild("Buttons")
	for i, v in pairs(MainButtons:GetChildren()) do
		if v:IsA("Frame") then
			local Button = v:FindFirstChild("TextButton")
			Button.Position = UDim2.new(-1.5, 0, 0, 0)
		end
	end
	Buttons.Position = UDim2.new(-1.5, 0, 0.775, 0)

	SoundService:PlayLocalSound(mainMenuGui.Transition1)

	tweenGuiTransparency(mainMenuGui:FindFirstChild("Logo"), 1, 0, 0.6)

	for i, v in pairs(MainButtons:GetChildren()) do
		if v:IsA("Frame") then
			local Button = v:FindFirstChild("TextButton")
			Button:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.6, true)
			tweenGuiTransparency(Button, 1, 0, 0.6)
			task.wait(0.15)
			SoundService:PlayLocalSound(mainMenuGui.Spawn)
		end
	end

	Buttons:TweenPosition(UDim2.new(0.05, 0, 0.775, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 1, true)
	tweenGuiTransparency(Buttons, 1, 0, 1)
	task.wait(0.5)
	SoundService:PlayLocalSound(mainMenuGui.Spawn)

	for i, v in pairs(MainButtons:GetChildren()) do
		local Button = v:FindFirstChild("TextButton")
		local RayFrame = v:FindFirstChild("Ray")
		if Button and RayFrame then
			--_G.ApplyButtonHover(Button, true)
			--_G.ApplyClick(Button)
			v.MouseEnter:Connect(function()
				RayFrame.Visible = true
				RayFrame.Size = UDim2.new(0, 0, 1.001, 0)
				RayFrame:TweenSize(
					UDim2.new(1.466, 0, 1.001, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Sine,
					0.15,
					true
				)
				Button:TweenPosition(
					UDim2.new(0.2, 0, 0, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Sine,
					0.3,
					true
				)
			end)

			v.MouseLeave:Connect(function()
				RayFrame:TweenSize(
					UDim2.new(0, 0, 1.001, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Sine,
					0.15,
					true
				)
				Button:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.3, true)
			end)

			Button.MouseButton1Click:Connect(function()
				RayFrame:TweenSize(
					UDim2.new(0, 0, 1.001, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Sine,
					0.15,
					true
				)
				Button:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.3, true)
				for _, e in pairs(Button:GetChildren()) do
					if e:IsA("UIStroke") then
						e:Destroy()
					end
				end
			end)
		end
	end

	for i, v in pairs(Buttons:GetChildren()) do
		if v:IsA("TextButton") then
			--_G.ApplyButtonHover(v, true)
			--_G.ApplyClick(v)
			v.MouseEnter:Connect(function()
				v:TweenPosition(UDim2.new(0.2, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.3, true)
			end)

			v.MouseLeave:Connect(function()
				v:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.3, true)
			end)
		end
	end

	Workspace:WaitForChild("Camera").CameraType = Enum.CameraType.Scriptable
	Workspace.Camera.CFrame = Workspace:WaitForChild("RaceScene"):WaitForChild("RaceCam", 5).CFrame
end

local function init()
	player.CharacterAdded:Connect(onCharacterAdded)

	if player.Character then
		task.defer(onCharacterAdded, player.Character)
	end
end

return { __init = init }
