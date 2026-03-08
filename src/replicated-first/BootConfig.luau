--!strict

local BootConfig = {
	VERBOSE = true,
	PRELOAD_ANIMATIONS = true,
	INVOKE_MAX_RETRIES = 3,
	INVOKE_TIMEOUT = 5,
	BOOT_STAGE_TIMEOUT = 60,
	CORE_GUI_TYPES_TO_DISABLE = {
		Enum.CoreGuiType.EmotesMenu,
		Enum.CoreGuiType.Backpack,
		Enum.CoreGuiType.PlayerList,
		Enum.CoreGuiType.Health,
	},
}

return table.freeze(BootConfig)
