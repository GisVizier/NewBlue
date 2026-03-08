local CustomisationService = require(script.Parent.Parent.Parent.CustomisationService)

return function(context)
	local player = context.Executor
	local isCustomising = not player:GetAttribute("IsCustomising")

	CustomisationService.setState(player, isCustomising)

	return `{isCustomising and "Entering" or "Exiting"} customization mode.`
end
