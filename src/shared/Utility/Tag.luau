--!strict

local RunService = game:GetService("RunService")

local DEBUG = RunService:IsStudio()

local TAGS = table.freeze({
	Attacking = "Attacking",
	Blocking = "Blocking",
	EndLag = "EndLag",
	Ragdoll = "Ragdoll",
	Dashing = "Dashing",
	Airborne = "Airborne",
	IFrame = "IFrame",
	Sprinting = "Sprinting",
	DontAutoRotate = "DontAutoRotate",
	CantSprint = "CantSprint",
	Slowed = "Slowed",
	Immobile = "Immobile",
	CantJump = "CantJump",
	PerformingAbility = "PerformingAbility",
	Hitstun = "Hitstun",
	SuperArmour = "SuperArmour",
	HyperArmour = "HyperArmour",
	Rushing = "Rushing",
})

local function log(fnName: string, message: string)
	local log = `[Tag.{fnName}]: {message}`
	if DEBUG then
		log ..= `\nTraceback: {debug.traceback(nil, 2)}`
	end
	warn(log)
end

local Tag = {}

-- tag list
Tag.Enum = TAGS

-- add tag to character
function Tag.add(char: Model, tag: string, duration: number?)
	if not char or not char:IsA("Model") or not char.Parent then
		log("add", "Invalid character")
		return
	end

	if not tag or typeof(tag) ~= "string" or tag == "" or not TAGS[tag] then
		log("add", "Invalid tag")
		return
	end

	if duration ~= nil and typeof(duration) ~= "number" then
		log("add", "Invalid duration")
		return
	end

	local attr = char:GetAttribute(tag)
	local currentValue: number = if typeof(attr) == "number" then attr else 0
	local newValue = currentValue + 1

	char:SetAttribute(tag, newValue)

	if duration ~= nil then
		task.delay(duration, function()
			if not char.Parent then
				return
			end

			local currentValue = char:GetAttribute(tag)
			if typeof(currentValue) ~= "number" then
				return
			end

			newValue = currentValue - 1
			if newValue > 0 then
				char:SetAttribute(tag, newValue)
			else
				char:SetAttribute(tag, nil)
			end
		end)
	end
end

-- remove tag from character
function Tag.remove(char: Model, tag: string)
	if not char or not char:IsA("Model") or not char.Parent then
		log("remove", "Invalid character")
		return
	end

	if not tag or typeof(tag) ~= "string" or tag == "" or not TAGS[tag] then
		log("remove", "Invalid tag")
		return
	end

	local currentValue = char:GetAttribute(tag)
	if typeof(currentValue) ~= "number" then
		return
	end

	local newValue = currentValue - 1
	if newValue > 0 then
		char:SetAttribute(tag, newValue)
	else
		char:SetAttribute(tag, nil)
	end
end

-- clear tag from character
function Tag.clear(char: Model, tag: string)
	if not char or not char:IsA("Model") or not char.Parent then
		log("clear", "Invalid character")
		return
	end

	if not tag or typeof(tag) ~= "string" or tag == "" or not TAGS[tag] then
		log("clear", "Invalid tag")
		return
	end

	char:SetAttribute(tag, nil)
end

-- check if character has tag
function Tag.has(char: Model, tag: string): boolean
	if not char or not char:IsA("Model") or not char.Parent then
		log("has", "Invalid character")
		return false
	end

	if not tag or typeof(tag) ~= "string" or tag == "" or not TAGS[tag] then
		log("has", "Invalid tag")
		return false
	end

	local value = char:GetAttribute(tag)
	return typeof(value) == "number" and value > 0
end

return Tag
