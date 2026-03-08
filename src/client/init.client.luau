--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VERBOSE = true

local initModules: { [string]: { __init: (any) -> () } } = {}

local function weakPrint(message: string)
	if VERBOSE then
		print(`[Client]: {message}`)
	end
end

local function isSubModule(moduleScript: ModuleScript, rootInstance: Instance): boolean
	local currentInstance = moduleScript.Parent
	while currentInstance and currentInstance ~= rootInstance do
		if currentInstance:IsA("ModuleScript") then
			return true
		end
		currentInstance = currentInstance.Parent
	end
	return false
end

local function isDisabled(moduleScript: ModuleScript): boolean
	return string.sub(moduleScript.Name, 1, 1) == "."
end

local function loadModules()
	for _, path in { script, ReplicatedStorage.Shared } do
		for _, descendant in path:GetDescendants() do
			if descendant:IsA("ModuleScript") and not isSubModule(descendant, path) and not isDisabled(descendant) then
				local success, result = pcall(require, descendant)
				if success then
					if type(result) == "table" and type(result.__init) == "function" then
						initModules[descendant.Name] = result
					end
				else
					warn(`[Client]: Failed to require {descendant:GetFullName()}\n{result}`)
				end
			end
		end
	end
end

local function startModules()
	for name, module in initModules do
		task.defer(function()
			xpcall(module.__init, function(err)
				warn(`[Client]: Failed to initialise {name}\n{err}\n{debug.traceback()}`)
			end)
		end)
	end
end

local function init()
	if not ReplicatedStorage:GetAttribute("ServerLoaded") then
		ReplicatedStorage:GetAttributeChangedSignal("ServerLoaded"):Wait()
	end

	local startTime = os.clock()

	weakPrint("Loading modules...")
	loadModules()

	weakPrint("Starting modules...")
	startModules()

	weakPrint(string.format("Client loaded in %.3f seconds", os.clock() - startTime))

	ReplicatedStorage:SetAttribute("ClientLoaded", true)
end

init()
