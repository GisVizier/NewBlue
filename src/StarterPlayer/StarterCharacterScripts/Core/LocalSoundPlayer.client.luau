local LocalSoundEvent = game:GetService("ReplicatedStorage").Remotes.LocalSoundEvent
local SS = 	game:GetService("SoundService")
LocalSoundEvent.OnClientEvent:Connect(function(Sound)
	local FindSound = script:FindFirstChild(Sound)
	if FindSound then
		SS:PlayLocalSound(FindSound)
	end
end)