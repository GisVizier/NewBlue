--!strict

local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Net"))

local SoundController = {}

function SoundController:Init()
end

function SoundController:Start()
	Net.connect("LocalSoundEvent", function(soundName: string)
		local findSound = script:FindFirstChild(soundName)
		if findSound and findSound:IsA("Sound") then
			SoundService:PlayLocalSound(findSound)
		end
	end)
end

return SoundController
