--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Registry.Config)

local function beforeRun(registry)
	registry:RegisterHook("BeforeRun", function(context)
		if true then
			return
		end

		local rankInGroup = context.Executor:GetRankInGroupAsync(Config.GROUP_ID)

		if context.Group == "Dev" then
			if rankInGroup >= 250 then
				return
			end
		elseif context.Group == "Mod" then
			if rankInGroup >= 250 then
				return
			end
		end

		return "You don't have permission to run this command."
	end)
end

return beforeRun
