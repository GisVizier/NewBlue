--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local deepFreeze = require(ReplicatedStorage.Shared.Utility.deepFreeze)

local Config = {
	GAME_VERSION = "v.0.1.0",

	DEFAULT_JUMP_POWER = 50,

	GROUP_ID = 35786685,

	TAG = {
		LIVE = "Live",
		NAMEPLATE = "Nameplate",
		MATCH_READY = "MatchReady",
	},

	COLLISION_GROUP = {
		LIVE = "Live",
		ALT = "Alt",
	},

	ATTACK = {
		COMBO_RESET_WINDOW = 1,
		COMBO_MAX = 5,
		UPTILT_COOLDOWN = 2,
		DOWNSLAM_COOLDOWN = 2,
	},

	BLOCK = {
		TOGGLE_COOLDOWN = 0.15,
	},
}

return deepFreeze(Config)
