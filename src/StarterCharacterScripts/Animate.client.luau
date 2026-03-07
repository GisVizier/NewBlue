--!strict
-- Animation controller - adapted from Roblox default Animate script
-- Fixed: :connect() -> :Connect(), wait() -> task.wait(), animation IDs from config

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local AnimationIds = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("AnimationIds"))

local Character = script.Parent
local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
local pose = "Standing"

local userNoUpdateOnLoopSuccess, userNoUpdateOnLoopValue = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserNoUpdateOnLoop")
end)
local userNoUpdateOnLoop = userNoUpdateOnLoopSuccess and userNoUpdateOnLoopValue

local userEmoteToRunThresholdChange do
	local success, value = pcall(function()
		return UserSettings():IsUserFeatureEnabled("UserEmoteToRunThresholdChange")
	end)
	userEmoteToRunThresholdChange = success and value
end

local userPlayEmoteByIdAnimTrackReturn do
	local success, value = pcall(function()
		return UserSettings():IsUserFeatureEnabled("UserPlayEmoteByIdAnimTrackReturn2")
	end)
	userPlayEmoteByIdAnimTrackReturn = success and value
end

local AnimationSpeedDampeningObject = script:FindFirstChild("ScaleDampeningPercent")
local HumanoidHipHeight = 2

local EMOTE_TRANSITION_TIME = 0.1

local currentAnim = ""
local currentAnimInstance = nil
local currentAnimTrack = nil
local currentAnimKeyframeHandler = nil
local currentAnimSpeed = 1.0

local runAnimTrack = nil
local runAnimKeyframeHandler = nil

local PreloadedAnims = {}

local animTable = {}
local animNames = AnimationIds.Animations
local emoteNames = AnimationIds.Emotes

math.randomseed(tick())

local function findExistingAnimationInSet(set, anim)
	if set == nil or anim == nil then
		return 0
	end
	for idx = 1, set.count, 1 do
		if set[idx].anim.AnimationId == anim.AnimationId then
			return idx
		end
	end
	return 0
end

local function configureAnimationSet(name, fileList)
	if animTable[name] ~= nil then
		for _, connection in pairs(animTable[name].connections) do
			connection:Disconnect()
		end
	end
	animTable[name] = {}
	animTable[name].count = 0
	animTable[name].totalWeight = 0
	animTable[name].connections = {}

	local allowCustomAnimations = true
	local success, _ = pcall(function()
		allowCustomAnimations = game:GetService("StarterPlayer").AllowCustomAnimations
	end)
	if not success then
		allowCustomAnimations = true
	end

	local config = script:FindFirstChild(name)
	if allowCustomAnimations and config ~= nil then
		table.insert(animTable[name].connections, config.ChildAdded:Connect(function()
			configureAnimationSet(name, fileList)
		end))
		table.insert(animTable[name].connections, config.ChildRemoved:Connect(function()
			configureAnimationSet(name, fileList)
		end))

		local idx = 0
		for _, childPart in pairs(config:GetChildren()) do
			if childPart:IsA("Animation") then
				local newWeight = 1
				local weightObject = childPart:FindFirstChild("Weight")
				if weightObject ~= nil then
					newWeight = weightObject.Value
				end
				animTable[name].count = animTable[name].count + 1
				idx = animTable[name].count
				animTable[name][idx] = {}
				animTable[name][idx].anim = childPart
				animTable[name][idx].weight = newWeight
				animTable[name].totalWeight = animTable[name].totalWeight + animTable[name][idx].weight
				table.insert(animTable[name].connections, childPart.Changed:Connect(function()
					configureAnimationSet(name, fileList)
				end))
				table.insert(animTable[name].connections, childPart.ChildAdded:Connect(function()
					configureAnimationSet(name, fileList)
				end))
				table.insert(animTable[name].connections, childPart.ChildRemoved:Connect(function()
					configureAnimationSet(name, fileList)
				end))
			end
		end
	end

	if animTable[name].count <= 0 then
		for idx, anim in pairs(fileList) do
			animTable[name][idx] = {}
			animTable[name][idx].anim = Instance.new("Animation")
			animTable[name][idx].anim.Name = name
			animTable[name][idx].anim.AnimationId = anim.id
			animTable[name][idx].weight = anim.weight
			animTable[name].count = animTable[name].count + 1
			animTable[name].totalWeight = animTable[name].totalWeight + anim.weight
		end
	end

	for _, animType in pairs(animTable) do
		for idx = 1, animType.count, 1 do
			if PreloadedAnims[animType[idx].anim.AnimationId] == nil then
				Humanoid:LoadAnimation(animType[idx].anim)
				PreloadedAnims[animType[idx].anim.AnimationId] = true
			end
		end
	end
end

local function scriptChildModified(child)
	local fileList = animNames[child.Name]
	if fileList ~= nil then
		configureAnimationSet(child.Name, fileList)
	end
end

script.ChildAdded:Connect(scriptChildModified)
script.ChildRemoved:Connect(scriptChildModified)

for name, fileList in pairs(animNames) do
	configureAnimationSet(name, fileList)
end

-- ANIMATION
local toolAnim = "None"
local toolAnimTime = 0
local jumpAnimTime = 0
local jumpAnimDuration = 0.31
local toolTransitionTime = 0.1
local fallTransitionTime = 0.2
local currentlyPlayingEmote = false

local function stopAllAnimations()
	local oldAnim = currentAnim
	if emoteNames[oldAnim] ~= nil and emoteNames[oldAnim] == false then
		oldAnim = "idle"
	end
	if currentlyPlayingEmote then
		oldAnim = "idle"
		currentlyPlayingEmote = false
	end

	currentAnim = ""
	currentAnimInstance = nil
	if currentAnimKeyframeHandler ~= nil then
		currentAnimKeyframeHandler:Disconnect()
	end
	if currentAnimTrack ~= nil then
		currentAnimTrack:Stop()
		currentAnimTrack:Destroy()
		currentAnimTrack = nil
	end
	if runAnimKeyframeHandler ~= nil then
		runAnimKeyframeHandler:Disconnect()
	end
	if runAnimTrack ~= nil then
		runAnimTrack:Stop()
		runAnimTrack:Destroy()
		runAnimTrack = nil
	end
	return oldAnim
end

local function getHeightScale()
	if Humanoid then
		if not Humanoid.AutomaticScalingEnabled then
			return 1
		end
		local scale = Humanoid.HipHeight / HumanoidHipHeight
		if AnimationSpeedDampeningObject == nil then
			AnimationSpeedDampeningObject = script:FindFirstChild("ScaleDampeningPercent")
		end
		if AnimationSpeedDampeningObject ~= nil then
			scale = 1 + (Humanoid.HipHeight - HumanoidHipHeight) * AnimationSpeedDampeningObject.Value / HumanoidHipHeight
		end
		return scale
	end
	return 1
end

local function rootMotionCompensation(speed)
	local speedScaled = speed * 1.25
	local heightScale = getHeightScale()
	return speedScaled / heightScale
end

local smallButNotZero = 0.0001

local function rollAnimation(animName)
	local roll = math.random(1, animTable[animName].totalWeight)
	local idx = 1
	while roll > animTable[animName][idx].weight do
		roll = roll - animTable[animName][idx].weight
		idx = idx + 1
	end
	return idx
end

-- Forward declarations
local playAnimation
local setAnimationSpeed
local keyFrameReachedFunc
local playToolAnimation
local toolKeyFrameReachedFunc

local function setRunSpeed(speed)
	local normalizedWalkSpeed = 0.5
	local normalizedRunSpeed = 1
	local runSpeed = rootMotionCompensation(speed)

	local walkAnimationWeight = smallButNotZero
	local runAnimationWeight = smallButNotZero
	local walkAnimationTimewarp = runSpeed / normalizedWalkSpeed
	local runAnimationTimerwarp = runSpeed / normalizedRunSpeed

	if runSpeed <= normalizedWalkSpeed then
		walkAnimationWeight = 1
	elseif runSpeed < normalizedRunSpeed then
		local fadeInRun = (runSpeed - normalizedWalkSpeed) / (normalizedRunSpeed - normalizedWalkSpeed)
		walkAnimationWeight = 1 - fadeInRun
		runAnimationWeight = fadeInRun
		walkAnimationTimewarp = 1
		runAnimationTimerwarp = 1
	else
		runAnimationWeight = 1
	end
	currentAnimTrack:AdjustWeight(walkAnimationWeight)
	runAnimTrack:AdjustWeight(runAnimationWeight)
	currentAnimTrack:AdjustSpeed(walkAnimationTimewarp)
	runAnimTrack:AdjustSpeed(runAnimationTimerwarp)
end

setAnimationSpeed = function(speed)
	if currentAnim == "walk" then
		setRunSpeed(speed)
	else
		if speed ~= currentAnimSpeed then
			currentAnimSpeed = speed
			currentAnimTrack:AdjustSpeed(currentAnimSpeed)
		end
	end
end

keyFrameReachedFunc = function(frameName)
	if frameName == "End" then
		if currentAnim == "walk" then
			if userNoUpdateOnLoop == true then
				if runAnimTrack.Looped ~= true then
					runAnimTrack.TimePosition = 0.0
				end
				if currentAnimTrack.Looped ~= true then
					currentAnimTrack.TimePosition = 0.0
				end
			else
				runAnimTrack.TimePosition = 0.0
				currentAnimTrack.TimePosition = 0.0
			end
		else
			local repeatAnim = currentAnim
			if emoteNames[repeatAnim] ~= nil and emoteNames[repeatAnim] == false then
				repeatAnim = "idle"
			end
			if currentlyPlayingEmote then
				if currentAnimTrack.Looped then
					return
				end
				repeatAnim = "idle"
				currentlyPlayingEmote = false
			end
			local animSpeed = currentAnimSpeed
			playAnimation(repeatAnim, 0.15, Humanoid)
			setAnimationSpeed(animSpeed)
		end
	end
end

local function switchToAnim(anim, animName, transitionTime, humanoid)
	if anim ~= currentAnimInstance then
		if currentAnimTrack ~= nil then
			currentAnimTrack:Stop(transitionTime)
			currentAnimTrack:Destroy()
		end
		if runAnimTrack ~= nil then
			runAnimTrack:Stop(transitionTime)
			runAnimTrack:Destroy()
			if userNoUpdateOnLoop == true then
				runAnimTrack = nil
			end
		end

		currentAnimSpeed = 1.0
		currentAnimTrack = humanoid:LoadAnimation(anim)
		currentAnimTrack.Priority = Enum.AnimationPriority.Core
		currentAnimTrack:Play(transitionTime)
		currentAnim = animName
		currentAnimInstance = anim

		if currentAnimKeyframeHandler ~= nil then
			currentAnimKeyframeHandler:Disconnect()
		end
		currentAnimKeyframeHandler = currentAnimTrack.KeyframeReached:Connect(keyFrameReachedFunc)

		if animName == "walk" then
			local runAnimName = "run"
			local runIdx = rollAnimation(runAnimName)
			runAnimTrack = humanoid:LoadAnimation(animTable[runAnimName][runIdx].anim)
			runAnimTrack.Priority = Enum.AnimationPriority.Core
			runAnimTrack:Play(transitionTime)
			if runAnimKeyframeHandler ~= nil then
				runAnimKeyframeHandler:Disconnect()
			end
			runAnimKeyframeHandler = runAnimTrack.KeyframeReached:Connect(keyFrameReachedFunc)
		end
	end
end

playAnimation = function(animName, transitionTime, humanoid)
	local idx = rollAnimation(animName)
	local anim = animTable[animName][idx].anim
	switchToAnim(anim, animName, transitionTime, humanoid)
	currentlyPlayingEmote = false
end

local function playEmote(emoteAnim, transitionTime, humanoid)
	switchToAnim(emoteAnim, emoteAnim.Name, transitionTime, humanoid)
	currentlyPlayingEmote = true
end

-- Tool animations
local toolAnimName = ""
local toolAnimTrack = nil
local toolAnimInstance = nil
local currentToolAnimKeyframeHandler = nil

toolKeyFrameReachedFunc = function(frameName)
	if frameName == "End" then
		playToolAnimation(toolAnimName, 0.0, Humanoid)
	end
end

playToolAnimation = function(animName, transitionTime, humanoid, priority)
	local idx = rollAnimation(animName)
	local anim = animTable[animName][idx].anim
	if toolAnimInstance ~= anim then
		if toolAnimTrack ~= nil then
			toolAnimTrack:Stop()
			toolAnimTrack:Destroy()
			transitionTime = 0
		end
		toolAnimTrack = humanoid:LoadAnimation(anim)
		if priority then
			toolAnimTrack.Priority = priority
		end
		toolAnimTrack:Play(transitionTime)
		toolAnimName = animName
		toolAnimInstance = anim
		currentToolAnimKeyframeHandler = toolAnimTrack.KeyframeReached:Connect(toolKeyFrameReachedFunc)
	end
end

local function stopToolAnimations()
	if currentToolAnimKeyframeHandler ~= nil then
		currentToolAnimKeyframeHandler:Disconnect()
	end
	toolAnimName = ""
	toolAnimInstance = nil
	if toolAnimTrack ~= nil then
		toolAnimTrack:Stop()
		toolAnimTrack:Destroy()
		toolAnimTrack = nil
	end
end

-- State handlers
local function onRunning(speed)
	local movedDuringEmote = userEmoteToRunThresholdChange and currentlyPlayingEmote and Humanoid.MoveDirection == Vector3.new(0, 0, 0)
	local speedThreshold = if movedDuringEmote then Humanoid.WalkSpeed else 0.75
	if speed > speedThreshold then
		local scale = 16.0
		playAnimation("walk", 0.2, Humanoid)
		setAnimationSpeed(speed / scale)
		pose = "Running"
	else
		if emoteNames[currentAnim] == nil and not currentlyPlayingEmote then
			playAnimation("idle", 0.2, Humanoid)
			pose = "Standing"
		end
	end
end

local function onDied()
	pose = "Dead"
end

local function onJumping()
	playAnimation("jump", 0.1, Humanoid)
	jumpAnimTime = jumpAnimDuration
	pose = "Jumping"
end

local function onClimbing(speed)
	local scale = 5.0
	playAnimation("climb", 0.1, Humanoid)
	setAnimationSpeed(speed / scale)
	pose = "Climbing"
end

local function onGettingUp()
	pose = "GettingUp"
end

local function onFreeFall()
	if jumpAnimTime <= 0 then
		playAnimation("fall", fallTransitionTime, Humanoid)
	end
	pose = "FreeFall"
end

local function onFallingDown()
	pose = "FallingDown"
end

local function onSeated()
	pose = "Seated"
end

local function onPlatformStanding()
	pose = "PlatformStanding"
end

local function onSwimming(speed)
	if speed > 1.00 then
		local scale = 10.0
		playAnimation("swim", 0.4, Humanoid)
		setAnimationSpeed(speed / scale)
		pose = "Swimming"
	else
		playAnimation("swimidle", 0.4, Humanoid)
		pose = "Standing"
	end
end

local function getToolAnim(tool)
	for _, c in tool:GetChildren() do
		if c.Name == "toolanim" and c.ClassName == "StringValue" then
			return c
		end
	end
	return nil
end

local function animateTool()
	if toolAnim == "None" then
		playToolAnimation("toolnone", toolTransitionTime, Humanoid, Enum.AnimationPriority.Idle)
		return
	end
	if toolAnim == "Slash" then
		playToolAnimation("toolslash", 0, Humanoid, Enum.AnimationPriority.Action)
		return
	end
	if toolAnim == "Lunge" then
		playToolAnimation("toollunge", 0, Humanoid, Enum.AnimationPriority.Action)
		return
	end
end

local lastTick = 0

local function stepAnimate(currentTime)
	local deltaTime = currentTime - lastTick
	lastTick = currentTime

	if jumpAnimTime > 0 then
		jumpAnimTime = jumpAnimTime - deltaTime
	end

	if pose == "FreeFall" and jumpAnimTime <= 0 then
		playAnimation("fall", fallTransitionTime, Humanoid)
	elseif pose == "Seated" then
		playAnimation("sit", 0.5, Humanoid)
		return
	elseif pose == "Running" then
		playAnimation("walk", 0.2, Humanoid)
	elseif pose == "Dead" or pose == "GettingUp" or pose == "FallingDown" or pose == "Seated" or pose == "PlatformStanding" then
		stopAllAnimations()
	end

	local tool = Character:FindFirstChildOfClass("Tool")
	if tool and tool:FindFirstChild("Handle") then
		local animStringValueObject = getToolAnim(tool)
		if animStringValueObject then
			toolAnim = animStringValueObject.Value
			animStringValueObject.Parent = nil
			toolAnimTime = currentTime + 0.3
		end
		if currentTime > toolAnimTime then
			toolAnimTime = 0
			toolAnim = "None"
		end
		animateTool()
	else
		stopToolAnimations()
		toolAnim = "None"
		toolAnimInstance = nil
		toolAnimTime = 0
	end
end

-- Connect events
Humanoid.Died:Connect(onDied)
Humanoid.Running:Connect(onRunning)
Humanoid.Jumping:Connect(onJumping)
Humanoid.Climbing:Connect(onClimbing)
Humanoid.GettingUp:Connect(onGettingUp)
Humanoid.FreeFalling:Connect(onFreeFall)
Humanoid.FallingDown:Connect(onFallingDown)
Humanoid.Seated:Connect(onSeated)
Humanoid.PlatformStanding:Connect(onPlatformStanding)
Humanoid.Swimming:Connect(onSwimming)

-- Emote chat hook
Players.LocalPlayer.Chatted:Connect(function(msg)
	local emote = ""
	if string.sub(msg, 1, 3) == "/e " then
		emote = string.sub(msg, 4)
	elseif string.sub(msg, 1, 7) == "/emote " then
		emote = string.sub(msg, 8)
	end
	if pose == "Standing" and emoteNames[emote] ~= nil then
		playAnimation(emote, EMOTE_TRANSITION_TIME, Humanoid)
	end
end)

-- Emote bindable hook
local playEmoteBindable = script:FindFirstChild("PlayEmote")
if playEmoteBindable and playEmoteBindable:IsA("BindableFunction") then
	playEmoteBindable.OnInvoke = function(emote)
		if pose ~= "Standing" then
			return false
		end
		if emoteNames[emote] ~= nil then
			playAnimation(emote, EMOTE_TRANSITION_TIME, Humanoid)
			if userPlayEmoteByIdAnimTrackReturn then
				return true, currentAnimTrack
			else
				return true
			end
		elseif typeof(emote) == "Instance" and emote:IsA("Animation") then
			playEmote(emote, EMOTE_TRANSITION_TIME, Humanoid)
			if userPlayEmoteByIdAnimTrackReturn then
				return true, currentAnimTrack
			else
				return true
			end
		end
		return false
	end
end

if Character.Parent ~= nil then
	playAnimation("idle", 0.1, Humanoid)
	pose = "Standing"
end

while Character.Parent ~= nil do
	local _, currentGameTime = task.wait(0.1)
	stepAnimate(currentGameTime)
end
