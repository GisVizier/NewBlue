--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CustomizationConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("CustomizationConfig"))

local ProportionHandler = {}

function ProportionHandler.Apply(char: Model, width: number, height: number, depth: number)
	local hum = char:FindFirstChild("Humanoid") :: Humanoid?
	if not hum then
		return
	end

	local widthScale = hum:FindFirstChild("BodyWidthScale") :: NumberValue?
	local heightScale = hum:FindFirstChild("BodyHeightScale") :: NumberValue?
	local depthScale = hum:FindFirstChild("BodyDepthScale") :: NumberValue?

	if widthScale and CustomizationConfig.WidthTable[width] then
		widthScale.Value = CustomizationConfig.WidthTable[width]
	end
	if heightScale and CustomizationConfig.HeightTable[height] then
		heightScale.Value = CustomizationConfig.HeightTable[height]
	end
	if depthScale and CustomizationConfig.DepthTable[depth] then
		depthScale.Value = CustomizationConfig.DepthTable[depth]
	end
end

return ProportionHandler
