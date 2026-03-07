--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PhysicsConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("PhysicsConfig"))

local WindController = {}

function WindController:Init()
end

function WindController:Start()
	local wind = PhysicsConfig.Wind

	local WindLines = require(script.WindLines)
	local WindShake = require(script.WindShake)

	WindLines:Init({
		Direction = wind.Direction,
		Speed = wind.Speed,
		Lifetime = wind.LineLifetime,
		SpawnRate = wind.LineSpawnRate,
	})

	WindShake:SetDefaultSettings({
		WindSpeed = wind.Speed,
		WindDirection = wind.Direction,
		WindPower = wind.Power,
	})
	WindShake:Init()
end

return WindController
