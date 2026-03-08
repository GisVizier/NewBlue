--!strict

local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local BootConfig = require(ReplicatedFirst.BootConfig)

local player = Players.LocalPlayer

local function weakPrint(message: string)
	if BootConfig.VERBOSE then
		print(`[Boot]: {message}`)
	end
end

local function waitForSignalOrTimeout(signal: RBXScriptSignal, predicate: (() -> boolean)?): boolean
	local resolved = false
	local bindableEvent = Instance.new("BindableEvent")

	local function tryResolve()
		if resolved then
			return
		end
		if predicate and not predicate() then
			return
		end
		resolved = true
		bindableEvent:Fire(true)
	end

	local connection = signal:Connect(tryResolve)

	task.delay(60, function()
		if not resolved then
			resolved = true
			bindableEvent:Fire(false)
		end
	end)

	local success = bindableEvent.Event:Wait()
	connection:Disconnect()
	bindableEvent:Destroy()
	return success
end

local function waitForAttribute(instance: Instance, attribute: string): boolean
	if instance:GetAttribute(attribute) then
		return true
	end
	return waitForSignalOrTimeout(instance:GetAttributeChangedSignal(attribute), function()
		return instance:GetAttribute(attribute) == true
	end)
end

local function init()
	local startTime = os.clock()
	weakPrint(`Boot started...`)

	UserInputService.MouseIconEnabled = false
	ReplicatedFirst:RemoveDefaultLoadingScreen()

	for _, coreGuiType in BootConfig.CORE_GUI_TYPES_TO_DISABLE do
		StarterGui:SetCoreGuiEnabled(coreGuiType, false)
	end

	local playerGui = player.PlayerGui
	local teleportGui = TeleportService:GetArrivingTeleportGui()
	if teleportGui then
		teleportGui.Parent = playerGui
	end

	local loadingScreenGui = ReplicatedFirst:WaitForChild("LoadingScreenGui")
	loadingScreenGui.Parent = playerGui
	TeleportService:SetTeleportGui(loadingScreenGui)

	if teleportGui then
		teleportGui:Destroy()
	end

	if not game:IsLoaded() then
		game.Loaded:Wait()
	end

	-- set random gfx background. make this a config list
	local gfxImageLabel = loadingScreenGui.Pattern.GFX
	local gfx = gfxImageLabel:GetChildren()
	gfxImageLabel.Image = gfx[math.random(1, #gfx)].Texture

	local coreCall
	do
		local MAX_RETRIES = 8
		function coreCall(method, ...)
			local result = {}
			for retries = 1, MAX_RETRIES do
				result = { pcall(StarterGui[method], StarterGui, ...) }
				if result[1] then
					break
				end
				RunService.Stepped:Wait()
			end
			return unpack(result)
		end
	end
	coreCall("SetCore", "ResetButtonCallback", false)

	local frames = Workspace:WaitForChild("Frames")
	while task.wait() do
		if #frames:GetChildren() > 200 then
			break
		end
		warn("frames not loaded!") -- i wanna see if this is needed
	end

	local FrameLoader = {}
	table.insert(FrameLoader, gfxImageLabel.Image)
	local FrameIndex = {}
	local FramePlacer = loadingScreenGui.Pattern:WaitForChild("FramePlacer")
	for i, v in pairs(frames:GetChildren()) do
		local ImageLabel = Instance.new("ImageLabel")
		ImageLabel.Name = v.Name
		ImageLabel.Image = v.Texture
		ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		ImageLabel.Position = UDim2.new(0.52, 0, 0.5, 0)
		ImageLabel.Size = UDim2.new(1, 0, 1, 0)
		ImageLabel.BackgroundTransparency = 1
		ImageLabel.ZIndex = -1
		ImageLabel.Parent = FramePlacer
		FrameIndex[v.Name] = ImageLabel
		table.insert(FrameLoader, ImageLabel.Image)
	end
	ContentProvider:PreloadAsync(FrameLoader)

	task.wait(1)
	SoundService:PlayLocalSound(loadingScreenGui.LogoSound)

	local LastFrame
	for i = 1, #frames:GetChildren() do
		local v = FrameIndex[tostring(i)]
		if v then
			v.ZIndex = 100
			task.wait(0.01)
			if LastFrame then
				LastFrame:Destroy()
			end
			LastFrame = v
		else
			-- why is this happening?
			--warn("NO " .. i)
		end
	end

	LastFrame:TweenSize(UDim2.new(0.8, 0, 0.8, 0), Enum.EasingDirection.In, Enum.EasingStyle.Back, 1.5, true)
	LastFrame:TweenPosition(UDim2.new(0.52, 0, 0.35, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 1.5, true)
	task.wait(2.1)

	loadingScreenGui.Pattern.Logo.Visible = true
	loadingScreenGui.Pattern.Loading.Visible = true

	local Logo = loadingScreenGui.Pattern:WaitForChild("Logo")
	local Gradient = Logo:WaitForChild("UIGradient")
	Logo.Visible = false
	TweenService:Create(LastFrame, TweenInfo.new(0.5, Enum.EasingStyle.Sine), { ImageColor3 = Color3.new(0, 0, 0) })
		:Play()
	task.wait(0.5)
	LastFrame.ImageColor3 = Color3.new(1, 1, 1)
	Gradient.Parent = LastFrame
	Logo = LastFrame
	--print(Logo)
	local Black = Logo:Clone()
	Logo.ZIndex = 101

	--print(Black)
	Black.ImageColor3 = Color3.new(0, 0, 0)
	Black.Parent = loadingScreenGui.Pattern
	Black.UIGradient:Destroy()

	Logo.ImageTransparency = 1
	TweenService:Create(Logo, TweenInfo.new(0.4, Enum.EasingStyle.Sine), { ImageTransparency = 0 }):Play()
	-- wait server

	loadingScreenGui.Pattern.Loading.Text = "Loading Server"
	task.wait(1) -- mock load
	if not waitForAttribute(ReplicatedStorage, "ServerLoaded") then
		player:Kick("Server failed to load. Please rejoin.")
		return
	end

	loadingScreenGui.Pattern.Loading.Text = "Loading Profile"
	task.wait(1) -- mock load
	if not waitForAttribute(player, "ProfileLoaded") then
		player:Kick("Profile failed to load. Please rejoin.")
		return
	end

	local Signal = require(ReplicatedStorage.Packages:WaitForChild("Signal"))
	local skipSignal = Signal.new()

	local assetsLoaded = false
	local skipRequested = false
	skipSignal:Once(function()
		warn("signal received")
		assetsLoaded = true
		skipRequested = true
	end)

	loadingScreenGui.Pattern.Skip.TextButton.Activated:Connect(function()
		--warn("signal fired")
		-- assetsLoaded = true
		-- skipRequested = true
		skipSignal:Fire()
	end)

	UserInputService.MouseIconEnabled = true
	loadingScreenGui.Pattern.Skip.Visible = true
	loadingScreenGui.Pattern.Loading.Text = "Loading Assets"
	loadingScreenGui.Pattern.RemainingAssets.Visible = true

	task.wait(1)

	task.spawn(function()
		local Assets = {}
		for i, v in pairs(ReplicatedStorage.Assets.CustomizeMeshes:GetDescendants()) do
			if v:IsA("MeshPart") then
				table.insert(Assets, v)
			end
		end

		local Progress = 20
		if not skipRequested then
			TweenService
				:Create(
					Gradient,
					TweenInfo.new(0.1, Enum.EasingStyle.Sine),
					{ Offset = Vector2.new(Progress / 100, 0) }
				)
				:Play()
		end

		local RemainingProgress = 100 - Progress
		local TotalAssets = #Assets
		local RemainingAssets = TotalAssets
		for i, v in pairs(Assets) do
			local NewProgress = RemainingProgress * (i / TotalAssets)
			if not skipRequested then
				TweenService:Create(
					Gradient,
					TweenInfo.new(0.1, Enum.EasingStyle.Sine),
					{ Offset = Vector2.new((NewProgress / 100) + Progress / 100, 0) }
				):Play()
			end
			RemainingAssets -= 1
			if not skipRequested then
				--warn(1)
				loadingScreenGui.Pattern.RemainingAssets.Text = TotalAssets - RemainingAssets .. " / " .. TotalAssets
			end
			ContentProvider:PreloadAsync({ v })
			RunService.RenderStepped:Wait()
		end

		skipSignal:Fire()
	end)

	if not assetsLoaded then
		skipSignal:Wait()
	end
	--warn(1111111)
	skipSignal:Destroy()

	loadingScreenGui.Pattern.Skip.Visible = false
	loadingScreenGui.Pattern.RemainingAssets.Visible = false
	UserInputService.MouseIconEnabled = false

	loadingScreenGui.Pattern.Loading.Text = "Loading Client"
	if not waitForAttribute(ReplicatedStorage, "ClientLoaded") then
		player:Kick("Client failed to load. Please rejoin.")
		return
	end

	weakPrint(string.format("Booted in %.3f seconds", os.clock() - startTime))
	loadingScreenGui.Pattern.Loading.Text = "Loading Complete!"
	task.wait(1)
	loadingScreenGui.Pattern.Loading.Text = "PRESS ANY BUTTON TO CONTINUE"

	local BridgeNet2 = require(ReplicatedStorage.Packages:WaitForChild("BridgeNet2"))

	local bridge = BridgeNet2.ClientBridge("boot")

	local conn: RBXScriptConnection = nil
	conn = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		local isMouseClick = input.UserInputType == Enum.UserInputType.MouseButton1
		local isValidInput = input.UserInputType == Enum.UserInputType.Keyboard
			or input.UserInputType == Enum.UserInputType.Gamepad1
			or isMouseClick

		if isValidInput and (isMouseClick or not gameProcessedEvent) then
			conn:Disconnect()
			loadingScreenGui.Pattern.RemainingAssets.Text = ""

			local currentAttempt = 0
			local success = false

			for i = 1, BootConfig.INVOKE_MAX_RETRIES do
				currentAttempt = i
				local thisAttempt = i

				task.spawn(function()
					local ok, result = pcall(function()
						return bridge:InvokeServerAsync()
					end)
					if thisAttempt == currentAttempt then
						success = ok and result == true
					end
				end)

				local start = os.clock()
				while os.clock() - start < BootConfig.INVOKE_TIMEOUT do
					if success then
						break
					end
					task.wait()
				end

				if success then
					break
				end

				warn(`[Boot]: Failed to invoke bridge (Attempt {i}/{BootConfig.INVOKE_MAX_RETRIES})`)
			end

			if not success then
				player:Kick("Failed to boot. Please rejoin.")
				return
			end

			--scope:doCleanup()

			local Bg = loadingScreenGui:FindFirstChild("Bg")
			TweenService:Create(Bg, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { BackgroundTransparency = 0 }):Play()
			task.wait(0.12)
			loadingScreenGui.Pattern.Visible = false
			TweenService:Create(Bg, TweenInfo.new(0.3, Enum.EasingStyle.Sine), { BackgroundTransparency = 1 }):Play()

			UserInputService.MouseIconEnabled = true

			task.delay(1, function()
				--loadingScreenGui:Destroy()
			end)
		end
	end)
end

init()
