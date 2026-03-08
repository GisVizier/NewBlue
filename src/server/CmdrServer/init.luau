--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function init()
	local Cmdr = require(ReplicatedStorage.Packages.Cmdr)
	Cmdr:RegisterHooksIn(script.Hooks)
	Cmdr:RegisterTypesIn(script.Types)
	Cmdr:RegisterCommandsIn(script.Commands)
end

return { __init = init }
