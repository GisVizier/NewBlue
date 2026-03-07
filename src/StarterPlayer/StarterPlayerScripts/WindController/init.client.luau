local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local WIND_DIRECTION = Vector3.new(1,0,0.3)
local WIND_SPEED = 20
local WIND_POWER = 0.5
local SHAKE_RADIUS = 120

local WindLines = require(script.WindLines)
local WindShake = require(script.WindShake)

WindLines:Init({
	Direction = WIND_DIRECTION;
	Speed = WIND_SPEED;
	Lifetime = 1.5;
	SpawnRate = 11;
})




WindShake:SetDefaultSettings({
	WindSpeed = WIND_SPEED;
	WindDirection = WIND_DIRECTION;
	WindPower = WIND_POWER;
})
WindShake:Init()

--[[
game.Lighting:GetAttributeChangedSignal("WindDirection"):Connect(function()
	print("Changed")
	--WindShake:SetDefaultSettings({Speed = game.Lighting:GetAttribute("WindSpeed"),Direction = game.Lighting:GetAttribute("WindDirection"),Power = game.Lighting:GetAttribute("WindPower")})
	--WindShake:UpdateAllObjectSettings({Speed = game.Lighting:GetAttribute("WindSpeed"),Direction = game.Lighting:GetAttribute("WindDirection"),Power = game.Lighting:GetAttribute("WindPower")})
	WindLines:Init({Speed = game.Lighting:GetAttribute("WindSpeed"),Direction = game.Lighting:GetAttribute("WindDirection"),Power = game.Lighting:GetAttribute("WindPower"),Lifetime = 1.5,SpawnRate = 11})
	print(game.Lighting:GetAttribute("WindSpeed"))
	print(game.Lighting:GetAttribute("WindPower"))
--	WindLines:Init({Speed = 20,Direction = game.Lighting:GetAttribute("WindDirection"),Power = 0.5,Lifetime = 1.5,SpawnRate = 11})

	


	print(game.Lighting:GetAttribute("WindDirection"))
end)
--]]