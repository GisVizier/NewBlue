--!strict

local RunService = game:GetService("RunService")

local DEBUG = RunService:IsStudio()

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

function Util.log(source: string, message: string, includeTraceback: boolean?)
	message = `[{source}]: {message}`
	if includeTraceback and DEBUG then
		message ..= `\nTraceback: {debug.traceback(nil, 2)}`
	end
	print(message)
end

Util.logWarn = logWarn

function Util.waitForAnimator(hum: Humanoid): Animator?
	if not hum or not hum.Parent or not hum:IsA("Humanoid") then
		log("waitForAnimator", "Invalid humanoid")
		return
	end

	local animator: Animator? = nil

	animator = hum:WaitForChild("Animator", 3) :: Animator
	if animator and not animator:IsA("Animator") then
		animator = nil
	end

	if not animator and hum.Parent then
		animator = hum:FindFirstChildOfClass("Animator")
		if not animator then
			log("waitForAnimator", `No animator found in {hum:GetFullName()}`)
		end
	end

	return animator
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
	if not char or not char.Parent or not char:IsA("Model") then
		log("waitForHum", "Invalid character")
		return
	end

	local hum: Humanoid? = nil

	hum = char:WaitForChild("Humanoid", 3) :: Humanoid
	if hum and not hum:IsA("Humanoid") then
		hum = nil
	end

	if not hum and char.Parent then
		hum = char:FindFirstChildOfClass("Humanoid")
		if not hum then
			log("waitForHum", `No humanoid found in {char:GetFullName()}`)
		end
	end

	return hum
end

return Util
