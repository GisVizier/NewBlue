--!strict

local TweenService = game:GetService("TweenService")

local ColorHandler = {}

function ColorHandler.RefreshColors(char: Model, colorData: any, tween: boolean?)
	local shouldTween = if tween ~= nil then tween else true

	local hairColorData = colorData.Hair.Primary
	local hairColor = Color3.fromRGB(hairColorData.R, hairColorData.G, hairColorData.B)
	local hair = char:FindFirstChild("Hair")

	if hair then
		local head = char:FindFirstChild("Head")
		if head then
			for _, v in head:GetDescendants() do
				if v:IsA("Decal") and v.Name == "Eyebrows" then
					if shouldTween then
						TweenService:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Sine), { Color3 = hairColor }):Play()
					else
						v.Color3 = hairColor
					end
				end
			end
		end

		for _, v in hair:GetDescendants() do
			if v:IsA("BasePart") then
				if v.Name == "DONTCHANGE" then
					continue
				end
				if shouldTween then
					TweenService:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Sine), { Color = hairColor }):Play()
				else
					v.Color = hairColor
				end
			end
		end
	end

	local beardColorData = colorData.Facial.Primary
	local beardColor = Color3.fromRGB(beardColorData.R, beardColorData.G, beardColorData.B)
	local beard = char:FindFirstChild("Beard")

	if beard then
		for _, v in beard:GetDescendants() do
			if v:IsA("BasePart") then
				if shouldTween then
					TweenService:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Sine), { Color = beardColor }):Play()
				else
					v.Color = beardColor
				end
			end
		end
	end
end

function ColorHandler.SetColor(data: any, item: string, colorType: string, r: number, g: number, b: number)
	local colorData = data.Data.CharacterData.Color
	if not colorData[item] then
		return
	end
	if not colorData[item][colorType] then
		return
	end
	colorData[item][colorType] = {
		R = math.clamp(math.floor(r), 0, 255),
		G = math.clamp(math.floor(g), 0, 255),
		B = math.clamp(math.floor(b), 0, 255),
	}
end

return ColorHandler
